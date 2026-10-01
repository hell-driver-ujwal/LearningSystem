using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Security.Cryptography;
using System.Text;
namespace LearningSystem.Helpers
{
    public static class SelfAssessmentHelper
    {
        public static decimal CalculateAverage(int[] ratings)
        {
            if (ratings == null || ratings.Length == 0) throw new InvalidOperationException("Rate every statement before submitting.");
            decimal sum = 0;
            foreach (int rating in ratings)
            {
                if (rating < 1 || rating > 5) throw new InvalidOperationException("Each rating must be an integer from 1 through 5.");
                sum += rating;
            }
            return sum / ratings.Length;
        }
        internal static string Level(decimal average)
        {
            if (average < 1 || average > 5) throw new ArgumentOutOfRangeException("average");
            return average < 2.50m ? "Needs Improvement" : average < 4m ? "Developing" : "Confident";
        }
        public static string GetFeedback(decimal average)
        {
            string level = Level(average);
            if (level == "Needs Improvement") return "Review this topic and practise the key concepts before moving on.";
            if (level == "Developing") return "You have some confidence in this topic, but more practice would help strengthen your understanding.";
            return "You feel confident with this topic. Continue practising to maintain and apply your understanding.";
        }
        internal static string Display(decimal average) { return Math.Round(average, 2, MidpointRounding.AwayFromZero).ToString("0.00", CultureInfo.InvariantCulture); }
        internal static DataTable Statements(int id, SqlConnection c = null, SqlTransaction t = null)
        {
            const string sql = "SELECT StatementID,StatementText,SortOrder FROM dbo.SAStatement WHERE ActivityID=@id ORDER BY SortOrder,StatementID";
            return c == null ? DatabaseHelper.ExecuteTable(sql, ActivityHelper.ID(id)) : DatabaseHelper.ExecuteTable(c, t, sql, ActivityHelper.ID(id));
        }
        internal static string Definition(DataTable statements)
        {
            StringBuilder value = new StringBuilder();
            foreach (DataRow row in statements.Rows)
                foreach (object field in row.ItemArray) { string s = Convert.ToString(field, CultureInfo.InvariantCulture); value.Append(s.Length).Append(':').Append(s); }
            using (SHA256 hash = SHA256.Create()) return Convert.ToBase64String(hash.ComputeHash(Encoding.UTF8.GetBytes(value.ToString())));
        }
        internal static int Submit(int id, Dictionary<int,int> ratings, string definition, bool preview, out decimal average)
        {
            using (SqlConnection c = DatabaseHelper.OpenConnection())
            using (SqlTransaction t = c.BeginTransaction(IsolationLevel.Serializable))
            {
                int user = CurrentUserHelper.GetUserID().GetValueOrDefault();
                if (!AccessHelper.ActivityAccess(c,t,user,id,preview)) throw new UnauthorizedAccessException();
                DataRow activity = ActivityHelper.Find(id,c,t);
                if (activity == null || (string)activity["ActivityType"] != "SelfAssessment") throw new UnauthorizedAccessException();
                DataTable statements = Statements(id,c,t);
                if (definition != Definition(statements)) throw new InvalidOperationException("Statements changed while this form was open. Reload and rate the current statements.");
                if (statements.Rows.Count == 0 || ratings.Count != statements.Rows.Count) throw new InvalidOperationException("Rate every statement exactly once.");
                int[] values = new int[statements.Rows.Count];
                for (int i=0; i<statements.Rows.Count; i++)
                    if (!ratings.TryGetValue((int)statements.Rows[i]["StatementID"], out values[i])) throw new InvalidOperationException("A rating does not belong to this assessment. Rate every statement.");
                average = CalculateAverage(values);
                if (preview) return 0; // No insert, update or delete in preview.
                int attempt = Convert.ToInt32(DatabaseHelper.ExecuteScalar(c,t,"INSERT dbo.Attempt(ActivityID,LearnerID,ScorePercent,TimeTakenSeconds,EndingStepID) VALUES(@id,@user,NULL,NULL,NULL); SELECT CAST(SCOPE_IDENTITY() AS int)",new[] {new SqlParameter("@id",id),new SqlParameter("@user",user)}));
                foreach (var rating in ratings)
                    DatabaseHelper.ExecuteNonQuery(c,t,"INSERT dbo.SAResponse(AttemptID,StatementID,Rating) VALUES(@attempt,@statement,@rating)",new[] {new SqlParameter("@attempt",attempt),new SqlParameter("@statement",rating.Key),new SqlParameter("@rating",rating.Value)});
                t.Commit(); return attempt;
            }
        }
        internal static void SaveStatement(int activityID, int statementID, string text, int order, bool delete)
        {
            using (SqlConnection c = DatabaseHelper.OpenConnection())
            using (SqlTransaction t = c.BeginTransaction(IsolationLevel.Serializable))
            {
                AccessHelper.RequireOwner(c,t,activityID,"Activity");
                DataRow activity = ActivityHelper.Find(activityID,c,t);
                if (activity == null || (string)activity["ActivityType"] != "SelfAssessment") throw new UnauthorizedAccessException();
                if (ContentLockHelper.HasAttempts(c,t,activityID)) throw new InvalidOperationException("Statements are locked because this assessment has attempts.");
                if (statementID > 0 && Convert.ToInt32(DatabaseHelper.ExecuteScalar(c,t,"SELECT COUNT(*) FROM dbo.SAStatement WHERE StatementID=@id AND ActivityID=@activity",new[] {new SqlParameter("@id",statementID),new SqlParameter("@activity",activityID)})) != 1) throw new UnauthorizedAccessException();
                if (delete) DatabaseHelper.ExecuteNonQuery(c,t,"DELETE dbo.SAStatement WHERE StatementID=@id AND ActivityID=@activity",new[] {new SqlParameter("@id",statementID),new SqlParameter("@activity",activityID)});
                else
                {
                    ActivityHelper.CheckText(text,5,200,"Statement");
                    if (order < 1) throw new InvalidOperationException("Statement order must be a positive integer.");
                    DatabaseHelper.ExecuteNonQuery(c,t,statementID==0 ? "INSERT dbo.SAStatement(ActivityID,StatementText,SortOrder) VALUES(@activity,@text,@order)" : "UPDATE dbo.SAStatement SET StatementText=@text,SortOrder=@order WHERE StatementID=@id AND ActivityID=@activity",new[] {new SqlParameter("@id",statementID),new SqlParameter("@activity",activityID),new SqlParameter("@text",text),new SqlParameter("@order",order)});
                }
                if ((string)activity["Status"] == "Published" && !PublishHelper.CheckSelfAssessment(c,t,activityID).IsValid) throw new InvalidOperationException("A published assessment needs at least one statement. Unpublish before removing the last statement.");
                AccessHelper.TouchCourse(c,t,(int)activity["CourseID"]); t.Commit();
            }
        }
        internal static DataTable Summary(int id)
        {
            using (SqlConnection c = DatabaseHelper.OpenConnection())
            using (SqlTransaction t = c.BeginTransaction(IsolationLevel.Serializable))
            {
                AccessHelper.RequireOwner(c,t,id,"Activity");
                DataTable rows=DatabaseHelper.ExecuteTable(c,t,"SELECT s.StatementID,s.StatementText,COUNT(r.AttemptID) AS Responses,SUM(CAST(r.Rating AS decimal(18,0))) AS TotalRating FROM dbo.SAStatement s JOIN dbo.Activity a ON a.ActivityID=s.ActivityID LEFT JOIN (SELECT r.StatementID,r.AttemptID,r.Rating FROM dbo.SAResponse r JOIN dbo.Attempt x ON x.AttemptID=r.AttemptID WHERE x.ActivityID=@id) r ON r.StatementID=s.StatementID WHERE s.ActivityID=@id AND a.ActivityType='SelfAssessment' GROUP BY s.StatementID,s.StatementText,s.SortOrder ORDER BY s.SortOrder,s.StatementID",ActivityHelper.ID(id));
                rows.Columns.Add("AverageDisplay",typeof(string));
                foreach(DataRow row in rows.Rows) row["AverageDisplay"]=(int)row["Responses"]==0 ? "No ratings yet" : Display((decimal)row["TotalRating"]/(int)row["Responses"]);
                t.Commit();return rows;
            }
        }
    }
    public static partial class PublishHelper
    {
        public static ValidationResult CheckSelfAssessment(int activityID) { using(var c=DatabaseHelper.OpenConnection())return CheckSelfAssessment(c,null,activityID); }
        internal static ValidationResult CheckSelfAssessment(SqlConnection c,SqlTransaction t,int id)
        {
            int count=Convert.ToInt32(DatabaseHelper.ExecuteScalar(c,t,"SELECT COUNT(*) FROM dbo.SAStatement s JOIN dbo.Activity a ON a.ActivityID=s.ActivityID WHERE s.ActivityID=@id AND a.ActivityType='SelfAssessment' AND LEN(LTRIM(RTRIM(s.StatementText))) BETWEEN 5 AND 200",ActivityHelper.ID(id)));
            return new ValidationResult {IsValid=count>0,Message="A published self-assessment needs at least one valid statement."};
        }
    }
}
