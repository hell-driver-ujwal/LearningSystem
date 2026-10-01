using System;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Text.RegularExpressions;
using System.Web;
namespace LearningSystem.Helpers
{
    // Paid courses: a learner can enrol only after a payment is completed and verified by the server.
    // Payments use a local eSewa-style demo screen (Payment/EsewaDemo.aspx), so the project runs on any machine
    // without internet access or real money.
    internal static class PaymentHelper
    {
        internal const int MaxCodeAttempts = 3;

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
                throw new InvalidOperationException("An active learner account is required.");
        }

        // Free courses enrol straight away. Paid courses need a Complete, verified payment first; returns false if payment is still needed.
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
                if(!enrolled && (bool)courses.Rows[0]["IsPaid"] && !HasVerifiedPayment(connection,transaction,learner,courseID)) return false;
                InsertEnrolment(connection,transaction,learner,courseID);
                transaction.Commit();return true;
            }
        }
        private static bool HasVerifiedPayment(SqlConnection connection,SqlTransaction transaction,int learner,int courseID)
        {
            return Convert.ToInt32(DatabaseHelper.ExecuteScalar(connection,transaction,"SELECT COUNT(*) FROM dbo.Payment WHERE LearnerID=@user AND CourseID=@course AND Status='Complete' AND VerifiedDate IS NOT NULL",new[]{new SqlParameter("@user",learner),new SqlParameter("@course",courseID)}))>0;
        }
        private static void InsertEnrolment(SqlConnection connection,SqlTransaction transaction,int learner,int course)
        {
            DatabaseHelper.ExecuteNonQuery(connection,transaction,
                "IF NOT EXISTS(SELECT 1 FROM dbo.Enrolment WITH (UPDLOCK,HOLDLOCK) WHERE LearnerID=@user AND CourseID=@course) INSERT dbo.Enrolment(LearnerID,CourseID) VALUES(@user,@course)",
                new[]{new SqlParameter("@user",learner),new SqlParameter("@course",course)});
        }

        // Starts a purchase: stores a Pending payment with the price at this moment (the browser never sends a price).
        internal static int CreatePending(int courseID)
        {
            int learner=Learner();
            using(SqlConnection connection=DatabaseHelper.OpenConnection())
            using(SqlTransaction transaction=connection.BeginTransaction(IsolationLevel.Serializable))
            {
                CheckLearner(connection,transaction,learner);
                var rows=DatabaseHelper.ExecuteTable(connection,transaction,"SELECT IsPaid,PriceNPR,Status FROM dbo.Course WITH (UPDLOCK,HOLDLOCK) WHERE CourseID=@course",new[]{new SqlParameter("@course",courseID)});
                if(rows.Rows.Count!=1 || (string)rows.Rows[0]["Status"]!="Published" || !(bool)rows.Rows[0]["IsPaid"] || (decimal)rows.Rows[0]["PriceNPR"]<=0) throw new InvalidOperationException("This course is not available for purchase.");
                if(Convert.ToInt32(DatabaseHelper.ExecuteScalar(connection,transaction,"SELECT COUNT(*) FROM dbo.Enrolment WHERE LearnerID=@user AND CourseID=@course",new[]{new SqlParameter("@user",learner),new SqlParameter("@course",courseID)}))>0
                    || HasVerifiedPayment(connection,transaction,learner,courseID)) throw new InvalidOperationException("You have already paid for this course. Return to the course page and enrol without paying again.");
                int id=Convert.ToInt32(DatabaseHelper.ExecuteScalar(connection,transaction,"INSERT dbo.Payment(LearnerID,CourseID,TransactionUUID,AmountNPR) OUTPUT INSERTED.PaymentID VALUES(@user,@course,@uuid,@amount)",new[]{new SqlParameter("@user",learner),new SqlParameter("@course",courseID),new SqlParameter("@uuid",Guid.NewGuid().ToString("N")),new SqlParameter("@amount",SqlDbType.Decimal){Precision=10,Scale=2,Value=rows.Rows[0]["PriceNPR"]}}));
                transaction.Commit();return id;
            }
        }

        // Only the signed-in learner's own payments can be read.
        internal static DataRow Find(int paymentID)
        {
            int learner=Learner();
            var rows=DatabaseHelper.ExecuteTable("SELECT p.*,c.Title FROM dbo.Payment p JOIN dbo.Course c ON c.CourseID=p.CourseID WHERE p.PaymentID=@id AND p.LearnerID=@user",new[]{new SqlParameter("@id",paymentID),new SqlParameter("@user",learner)});
            if(rows.Rows.Count!=1) { HttpContext.Current.Response.Redirect("~/AccessDenied.aspx"); throw new InvalidOperationException("The payment could not be found for your account."); }
            return rows.Rows[0];
        }

        // A Nepali mobile number: 10 digits starting with 97 or 98.
        internal static bool IsValidPhone(string phone)
        {
            return phone!=null && Regex.IsMatch(phone,"^9[78][0-9]{8}$");
        }
        // Demo verification rule: the code is the last 4 digits of the mobile number.
        internal static bool CodeMatches(string phone,string code)
        {
            return IsValidPhone(phone) && code!=null && Regex.IsMatch(code,"^[0-9]{4}$") && phone.Substring(6)==code;
        }
        internal static string MaskPhone(string phone)
        {
            return IsValidPhone(phone) ? phone.Substring(0,2)+"XXXXXX"+phone.Substring(8) : "";
        }

        // Marks a Pending payment Complete and verified, then enrols the learner, all in one transaction.
        internal static int CompleteDemo(int paymentID,string phone,string code)
        {
            int learner=Learner();
            if(!CodeMatches(phone,code)) throw new InvalidOperationException("The verification code is not correct.");
            DataRow payment=Find(paymentID);
            using(SqlConnection connection=DatabaseHelper.OpenConnection())
            using(SqlTransaction transaction=connection.BeginTransaction(IsolationLevel.Serializable))
            {
                CheckLearner(connection,transaction,learner);
                // Lock the course first, then the payment, in the same order as enrolment and course deletion.
                var course=DatabaseHelper.ExecuteTable(connection,transaction,"SELECT Status FROM dbo.Course WITH (UPDLOCK,HOLDLOCK) WHERE CourseID=@course",new[]{new SqlParameter("@course",(int)payment["CourseID"])});
                if(course.Rows.Count!=1 || (string)course.Rows[0]["Status"]!="Published") throw new InvalidOperationException("This course is no longer available. You have not been charged.");
                var rows=DatabaseHelper.ExecuteTable(connection,transaction,"SELECT Status FROM dbo.Payment WITH (UPDLOCK,HOLDLOCK) WHERE PaymentID=@id AND LearnerID=@user",new[]{new SqlParameter("@id",paymentID),new SqlParameter("@user",learner)});
                if(rows.Rows.Count!=1) throw new InvalidOperationException("The payment could not be found for your account.");
                string status=(string)rows.Rows[0]["Status"];
                if(status=="Pending")
                {
                    string reference="ESW-"+DateTime.UtcNow.ToString("yyMMdd",CultureInfo.InvariantCulture)+"-"+Guid.NewGuid().ToString("N").Substring(0,8).ToUpperInvariant()+" ("+MaskPhone(phone)+")";
                    DatabaseHelper.ExecuteNonQuery(connection,transaction,"UPDATE dbo.Payment SET Status='Complete',VerifiedDate=SYSUTCDATETIME(),ProviderReference=@reference WHERE PaymentID=@id",new[]{new SqlParameter("@id",paymentID),new SqlParameter("@reference",SqlDbType.NVarChar,100){Value=reference}});
                }
                else if(status!="Complete") throw new InvalidOperationException("This payment was cancelled or failed. Start a new payment from the course page.");
                InsertEnrolment(connection,transaction,learner,(int)payment["CourseID"]);
                transaction.Commit();
            }
            return (int)payment["CourseID"];
        }

        // Cancel (learner chose Cancel) or Failed (too many wrong codes). A Complete payment is never changed.
        internal static void CloseDemo(int paymentID,bool failed)
        {
            int learner=Learner();
            Find(paymentID);
            DatabaseHelper.ExecuteNonQuery("UPDATE dbo.Payment SET Status=@status WHERE PaymentID=@id AND LearnerID=@user AND Status='Pending'",
                new[]{new SqlParameter("@status",failed ? "Failed" : "Canceled"),new SqlParameter("@id",paymentID),new SqlParameter("@user",learner)});
        }

        internal static DataTable History(string status,bool admin)
        {
            AccessHelper.RequireRole(new[]{admin ? "Admin" : "Learner"});
            if(status!="" && status!="Pending" && status!="Complete" && status!="Failed" && status!="Canceled") throw new InvalidOperationException("Choose a valid payment status.");
            return DatabaseHelper.ExecuteTable("SELECT p.*,c.Title AS CourseTitle,u.FullName AS LearnerName FROM dbo.Payment p JOIN dbo.Course c ON c.CourseID=p.CourseID JOIN dbo.[User] u ON u.UserID=p.LearnerID WHERE (@admin=1 OR p.LearnerID=@user) AND (@status='' OR p.Status=@status) ORDER BY p.CreatedDate DESC,p.PaymentID DESC",new[]{new SqlParameter("@admin",admin),new SqlParameter("@user",CurrentUserHelper.GetUserID().Value),new SqlParameter("@status",status)});
        }
    }
}
