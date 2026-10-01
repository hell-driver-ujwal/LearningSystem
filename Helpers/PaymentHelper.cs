using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Text;
using System.Web;
namespace LearningSystem.Helpers
{
    internal static class PaymentHelper
    {
        private static int Learner()
        {
            AccessHelper.RequireRole(new[] {"Learner"});
            return CurrentUserHelper.GetUserID().Value;
        }
        internal static string Price(DataRow course)
        {
            return (bool)course["IsPaid"] ? "NPR "+((decimal)course["PriceNPR"]).ToString("N2",CultureInfo.InvariantCulture) : "Free";
        }
        private static void CheckLearner(SqlConnection connection,SqlTransaction transaction,int learner)
        {
            if(Convert.ToInt32(DatabaseHelper.ExecuteScalar(connection,transaction,
                "SELECT COUNT(*) FROM dbo.[User] WHERE UserID=@user AND Role='Learner' AND Status='Active' AND MustChangePassword=0",new[]{new SqlParameter("@user",learner)}))!=1)
                throw new InvalidOperationException("An active student account is required.");
        }
        internal static bool Enrol(int courseID)
        {
            int learner=Learner();
            using(SqlConnection connection=DatabaseHelper.OpenConnection())
            using(SqlTransaction transaction=connection.BeginTransaction(IsolationLevel.Serializable))
            {
                CheckLearner(connection,transaction,learner);
                DataTable courses=DatabaseHelper.ExecuteTable(connection,transaction,"SELECT Status,IsPaid FROM dbo.Course WITH (UPDLOCK,HOLDLOCK) WHERE CourseID=@course",new[]{new SqlParameter("@course",courseID)});
                if(courses.Rows.Count!=1 || (string)courses.Rows[0]["Status"]!="Published") { HttpContext.Current.Response.Redirect("~/NotFound.aspx");return false; }
                var parameters=new[]{new SqlParameter("@user",learner),new SqlParameter("@course",courseID)};
                bool enrolled=Convert.ToInt32(DatabaseHelper.ExecuteScalar(connection,transaction,"SELECT COUNT(*) FROM dbo.Enrolment WHERE LearnerID=@user AND CourseID=@course",parameters))>0;
                if(!enrolled && (bool)courses.Rows[0]["IsPaid"] && Convert.ToInt32(DatabaseHelper.ExecuteScalar(connection,transaction,"SELECT COUNT(*) FROM dbo.Payment WHERE LearnerID=@user AND CourseID=@course AND Status='Complete' AND VerifiedDate IS NOT NULL",new[]{new SqlParameter("@user",learner),new SqlParameter("@course",courseID)}))==0) return false;
                InsertEnrolment(connection,transaction,learner,courseID);
                transaction.Commit();return true;
            }
        }
        private static void InsertEnrolment(SqlConnection connection,SqlTransaction transaction,int learner,int course)
        {
            DatabaseHelper.ExecuteNonQuery(connection,transaction,
                "IF NOT EXISTS(SELECT 1 FROM dbo.Enrolment WITH (UPDLOCK,HOLDLOCK) WHERE LearnerID=@user AND CourseID=@course) INSERT dbo.Enrolment(LearnerID,CourseID) VALUES(@user,@course)",
                new[]{new SqlParameter("@user",learner),new SqlParameter("@course",course)});
        }
        internal static int CreatePending(int courseID)
        {
            int learner=Learner();EsewaHelper.Settings();
            using(SqlConnection connection=DatabaseHelper.OpenConnection())
            using(SqlTransaction transaction=connection.BeginTransaction(IsolationLevel.Serializable))
            {
                CheckLearner(connection,transaction,learner);
                var rows=DatabaseHelper.ExecuteTable(connection,transaction,"SELECT IsPaid,PriceNPR,Status FROM dbo.Course WITH (UPDLOCK,HOLDLOCK) WHERE CourseID=@course",new[]{new SqlParameter("@course",courseID)});
                if(rows.Rows.Count!=1 || (string)rows.Rows[0]["Status"]!="Published" || !(bool)rows.Rows[0]["IsPaid"] || (decimal)rows.Rows[0]["PriceNPR"]<=0) throw new InvalidOperationException("This course is not available for purchase.");
                if(Convert.ToInt32(DatabaseHelper.ExecuteScalar(connection,transaction,"SELECT (SELECT COUNT(*) FROM dbo.Enrolment WHERE LearnerID=@user AND CourseID=@course)+(SELECT COUNT(*) FROM dbo.Payment WHERE LearnerID=@user AND CourseID=@course AND Status='Complete' AND VerifiedDate IS NOT NULL)",new[]{new SqlParameter("@user",learner),new SqlParameter("@course",courseID)}))>0) throw new InvalidOperationException("You already have access or a verified purchase. Return to the course and enrol without paying again.");
                int id=Convert.ToInt32(DatabaseHelper.ExecuteScalar(connection,transaction,"INSERT dbo.Payment(LearnerID,CourseID,TransactionUUID,AmountNPR) OUTPUT INSERTED.PaymentID VALUES(@user,@course,@uuid,@amount)",new[]{new SqlParameter("@user",learner),new SqlParameter("@course",courseID),new SqlParameter("@uuid",Guid.NewGuid().ToString("N")),new SqlParameter("@amount",SqlDbType.Decimal){Precision=10,Scale=2,Value=rows.Rows[0]["PriceNPR"]}}));
                transaction.Commit();return id;
            }
        }
        internal static DataRow Find(string uuid)
        {
            int learner=Learner();
            if(String.IsNullOrEmpty(uuid) || uuid.Length>64) throw new InvalidOperationException("The payment could not be found for your account.");
            var rows=DatabaseHelper.ExecuteTable("SELECT p.*,c.Title FROM dbo.Payment p JOIN dbo.Course c ON c.CourseID=p.CourseID WHERE p.TransactionUUID=@uuid AND p.LearnerID=@user",new[]{new SqlParameter("@uuid",uuid),new SqlParameter("@user",learner)});
            if(rows.Rows.Count!=1) { HttpContext.Current.Response.Redirect("~/AccessDenied.aspx"); throw new InvalidOperationException("The payment could not be found for your account."); }
            return rows.Rows[0];
        }
        internal static DataRow Find(int paymentID)
        {
            int learner=Learner();
            var rows=DatabaseHelper.ExecuteTable("SELECT p.*,c.Title FROM dbo.Payment p JOIN dbo.Course c ON c.CourseID=p.CourseID WHERE p.PaymentID=@id AND p.LearnerID=@user",new[]{new SqlParameter("@id",paymentID),new SqlParameter("@user",learner)});
            if(rows.Rows.Count!=1) { HttpContext.Current.Response.Redirect("~/AccessDenied.aspx"); throw new InvalidOperationException("The payment could not be found for your account."); }
            return rows.Rows[0];
        }
        internal static int Complete(string encodedResponse)
        {
            int learner=Learner();
            var data=EsewaHelper.VerifyResponse(encodedResponse);
            DataRow payment=Find(EsewaHelper.Value(data,"transaction_uuid"));
            if(EsewaHelper.Amount(data)!=(decimal)payment["AmountNPR"]) throw new InvalidOperationException("The payment amount does not match this purchase.");
            if((string)payment["Status"]=="Complete") { Enrol((int)payment["CourseID"]); return (int)payment["CourseID"]; }
            var status=EsewaHelper.Status(payment);
            if(EsewaHelper.Value(status,"status")!="COMPLETE") throw new InvalidOperationException("Payment is not yet verified complete. No enrolment was created.");
            string reference=EsewaHelper.Value(status,"ref_id");
            if(reference!="" && reference!=EsewaHelper.Value(data,"transaction_code")) throw new InvalidOperationException("The provider references do not match.");
            if(reference=="") reference=EsewaHelper.Value(data,"transaction_code");
            using(SqlConnection connection=DatabaseHelper.OpenConnection())
            using(SqlTransaction transaction=connection.BeginTransaction(IsolationLevel.Serializable))
            {
                CheckLearner(connection,transaction,learner);
                // Same course-then-payment lock order as initiation/enrolment and course deletion.
                DatabaseHelper.ExecuteScalar(connection,transaction,"SELECT CourseID FROM dbo.Course WITH (UPDLOCK,HOLDLOCK) WHERE CourseID=@course",new[]{new SqlParameter("@course",(int)payment["CourseID"])});
                var rows=DatabaseHelper.ExecuteTable(connection,transaction,"SELECT * FROM dbo.Payment WITH (UPDLOCK,HOLDLOCK) WHERE PaymentID=@id AND LearnerID=@user",new[]{new SqlParameter("@id",(int)payment["PaymentID"]),new SqlParameter("@user",learner)});
                if(rows.Rows.Count!=1 || (decimal)rows.Rows[0]["AmountNPR"]!=(decimal)payment["AmountNPR"] || (int)rows.Rows[0]["CourseID"]!=(int)payment["CourseID"] || (string)rows.Rows[0]["TransactionUUID"]!=(string)payment["TransactionUUID"]) throw new InvalidOperationException("The payment record changed. No enrolment was saved.");
                if((string)rows.Rows[0]["Status"]!="Complete")
                    DatabaseHelper.ExecuteNonQuery(connection,transaction,"UPDATE dbo.Payment SET Status='Complete',VerifiedDate=SYSUTCDATETIME(),ProviderReference=@reference WHERE PaymentID=@id",new[]{new SqlParameter("@id",(int)payment["PaymentID"]),new SqlParameter("@reference",SqlDbType.NVarChar,100){Value=reference}});
                InsertEnrolment(connection,transaction,learner,(int)payment["CourseID"]);
                transaction.Commit();
            }
            return (int)payment["CourseID"];
        }
        internal static void CheckFailure(string uuid)
        {
            DataRow payment=Find(uuid);
            if((string)payment["Status"]=="Complete") return;
            var response=EsewaHelper.Status(payment);
            string provider=EsewaHelper.Value(response,"status");
            string status=provider=="CANCELED" ? "Canceled" : provider=="NOT_FOUND" || provider=="FAILED" ? "Failed" : "Pending";
            if(status=="Pending") throw new InvalidOperationException("Payment could not yet be verified. No enrolment was created. Keep your signed success return URL if supplied by eSewa.");
            DatabaseHelper.ExecuteNonQuery("UPDATE dbo.Payment SET Status=@status WHERE PaymentID=@id AND LearnerID=@user AND Status<>'Complete'",new[]{new SqlParameter("@status",status),new SqlParameter("@id",(int)payment["PaymentID"]),new SqlParameter("@user",Learner())});
        }
        internal static string RequestForm(DataRow payment)
        {
            EsewaHelper.Settings();
            // Callers obtained this row through the current-learner Find method.
            if((int)payment["LearnerID"]!=Learner() || (string)payment["Status"]!="Pending") throw new InvalidOperationException("This payment is not pending.");
            string amount=((decimal)payment["AmountNPR"]).ToString("0.00",CultureInfo.InvariantCulture);
            string uuid=(string)payment["TransactionUUID"],product=EsewaHelper.Setting("EsewaProductCode");
            var fields=new Dictionary<string,string> {
                {"amount",amount},{"total_amount",amount},{"tax_amount","0"},{"product_service_charge","0"},{"product_delivery_charge","0"},
                {"transaction_uuid",uuid},{"product_code",product},{"signed_field_names","total_amount,transaction_uuid,product_code"},
                {"signature",EsewaHelper.Sign("total_amount="+amount+",transaction_uuid="+uuid+",product_code="+product)},
                {"success_url",EsewaHelper.Setting("HttpsOrigin").TrimEnd('/')+"/Payment/EsewaSuccess.aspx"},
                {"failure_url",EsewaHelper.Setting("HttpsOrigin").TrimEnd('/')+"/Payment/EsewaFailure.aspx?transaction_uuid="+uuid}
            };
            var html=new StringBuilder("<form class=\"payment-form\" method=\"post\" action=\""+HttpUtility.HtmlAttributeEncode(EsewaHelper.Setting("EsewaFormUrl"))+"\"><p class=\"sandbox-notice\">eSewa Sandbox — Test Payment · NPR "+amount+"</p>");
            foreach(var field in fields) html.Append("<input type=\"hidden\" name=\"").Append(field.Key).Append("\" value=\"").Append(HttpUtility.HtmlAttributeEncode(field.Value)).Append("\" />");
            html.Append("<button type=\"submit\">Continue to eSewa sandbox</button> <a class=\"button secondary\" href=\"").Append(CourseHelper.Url("~/CourseDetails.aspx?id="+payment["CourseID"])).Append("\">Cancel</a></form>");
            return html.ToString();
        }
        internal static DataTable History(string status,bool admin)
        {
            AccessHelper.RequireRole(new[]{admin ? "Admin" : "Learner"});
            if(status!="" && status!="Pending" && status!="Complete" && status!="Failed" && status!="Canceled") throw new InvalidOperationException("Choose a valid payment status.");
            return DatabaseHelper.ExecuteTable("SELECT p.*,c.Title AS CourseTitle,u.FullName AS LearnerName FROM dbo.Payment p JOIN dbo.Course c ON c.CourseID=p.CourseID JOIN dbo.[User] u ON u.UserID=p.LearnerID WHERE (@admin=1 OR p.LearnerID=@user) AND (@status='' OR p.Status=@status) ORDER BY p.CreatedDate DESC,p.PaymentID DESC",new[]{new SqlParameter("@admin",admin),new SqlParameter("@user",CurrentUserHelper.GetUserID().Value),new SqlParameter("@status",status)});
        }
    }
}

