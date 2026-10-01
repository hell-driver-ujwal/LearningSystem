using System;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
namespace LearningSystem.Helpers
{
    internal static class ReviewHelper
    {
        internal static string Average(int courseID)
        {
            object value = DatabaseHelper.ExecuteScalar("SELECT AVG(CAST(Rating AS decimal(10,2))) FROM dbo.Review WHERE CourseID=@id", new[] { new SqlParameter("@id", courseID) });
            return value == DBNull.Value ? "No ratings yet" : Convert.ToDecimal(value).ToString("0.00", CultureInfo.InvariantCulture) + " / 5";
        }
        internal static DataTable List(int courseID)
        {
            return DatabaseHelper.ExecuteTable("SELECT r.*,u.FullName,c.Title AS CourseTitle FROM dbo.Review r JOIN dbo.[User] u ON u.UserID=r.LearnerID JOIN dbo.Course c ON c.CourseID=r.CourseID WHERE (@id=0 OR r.CourseID=@id) ORDER BY r.PostedDate DESC,r.ReviewID DESC", new[] { new SqlParameter("@id", courseID) });
        }
        private static void RequireCourse(SqlConnection c, SqlTransaction t, int course, int learner)
        {
            int allowed = Convert.ToInt32(DatabaseHelper.ExecuteScalar(c,t,"SELECT COUNT(*) FROM dbo.Enrolment e JOIN dbo.Course c ON c.CourseID=e.CourseID JOIN dbo.[User] u ON u.UserID=e.LearnerID WHERE e.LearnerID=@user AND e.CourseID=@course AND c.Status='Published' AND u.Role='Learner' AND u.Status='Active'",new[] {new SqlParameter("@user",learner),new SqlParameter("@course",course)}));
            if (allowed != 1) throw new UnauthorizedAccessException();
        }
        internal static void Save(int course, int rating, string comment)
        {
            AccessHelper.RequireRole(new[] { "Learner" });
            comment=comment.Trim();
            if(rating<1 || rating>5 || comment.Length<10 || comment.Length>1000) throw new ArgumentException("Rating must be 1–5 and comment 10–1000 characters.");
            int user=CurrentUserHelper.GetUserID().Value;
            using(SqlConnection c=DatabaseHelper.OpenConnection())
            using(SqlTransaction t=c.BeginTransaction(IsolationLevel.Serializable))
            {
                RequireCourse(c,t,course,user);
                DatabaseHelper.ExecuteNonQuery(c,t,"IF EXISTS(SELECT 1 FROM dbo.Review WHERE CourseID=@course AND LearnerID=@user) UPDATE dbo.Review SET Rating=@rating,Comment=@comment,EditedDate=SYSUTCDATETIME() WHERE CourseID=@course AND LearnerID=@user ELSE INSERT dbo.Review(CourseID,LearnerID,Rating,Comment) VALUES(@course,@user,@rating,@comment)",new[] {new SqlParameter("@course",course),new SqlParameter("@user",user),new SqlParameter("@rating",rating),new SqlParameter("@comment",SqlDbType.NVarChar,1000){Value=comment}});
                t.Commit();
            }
        }
        internal static void Delete(int review, int course, bool admin)
        {
            AccessHelper.RequireRole(new[] {admin ? "Admin" : "Learner"});
            int user=CurrentUserHelper.GetUserID().Value;
            using(SqlConnection c=DatabaseHelper.OpenConnection())
            using(SqlTransaction t=c.BeginTransaction(IsolationLevel.Serializable))
            {
                if(!admin) RequireCourse(c,t,course,user);
                int changed=DatabaseHelper.ExecuteNonQuery(c,t,"DELETE FROM dbo.Review WHERE ReviewID=@id AND (@admin=1 OR (LearnerID=@user AND CourseID=@course))",new[] {new SqlParameter("@id",review),new SqlParameter("@admin",admin),new SqlParameter("@user",user),new SqlParameter("@course",course)});
                if(changed!=1) throw new UnauthorizedAccessException();
                t.Commit();
            }
        }
    }
}
