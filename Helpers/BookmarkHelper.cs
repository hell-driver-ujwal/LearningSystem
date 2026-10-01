using System;
using System.Data;
using System.Data.SqlClient;
namespace LearningSystem.Helpers
{
    internal static class BookmarkHelper
    {
        internal static bool Exists(int material)
        {
            return Convert.ToInt32(DatabaseHelper.ExecuteScalar("SELECT COUNT(*) FROM dbo.Bookmark WHERE LearnerID=@user AND MaterialID=@id",new[] {new SqlParameter("@user",CurrentUserHelper.GetUserID().Value),new SqlParameter("@id",material)}))>0;
        }
        internal static void Set(int material, bool add)
        {
            AccessHelper.RequireRole(new[] {"Learner"});
            int user=CurrentUserHelper.GetUserID().Value;
            using(SqlConnection c=DatabaseHelper.OpenConnection())
            using(SqlTransaction t=c.BeginTransaction(IsolationLevel.Serializable))
            {
                int allowed=Convert.ToInt32(DatabaseHelper.ExecuteScalar(c,t,"SELECT COUNT(*) FROM dbo.Material m JOIN dbo.Topic t ON t.TopicID=m.TopicID JOIN dbo.Course c ON c.CourseID=t.CourseID JOIN dbo.Enrolment e ON e.CourseID=c.CourseID JOIN dbo.[User] u ON u.UserID=e.LearnerID WHERE m.MaterialID=@id AND e.LearnerID=@user AND m.Status='Published' AND c.Status='Published' AND u.Status='Active' AND u.Role='Learner'",new[] {new SqlParameter("@id",material),new SqlParameter("@user",user)}));
                if(allowed!=1)throw new UnauthorizedAccessException();
                DatabaseHelper.ExecuteNonQuery(c,t,add ? "IF NOT EXISTS(SELECT 1 FROM dbo.Bookmark WHERE LearnerID=@user AND MaterialID=@id) INSERT dbo.Bookmark(LearnerID,MaterialID) VALUES(@user,@id)" : "DELETE FROM dbo.Bookmark WHERE LearnerID=@user AND MaterialID=@id",new[] {new SqlParameter("@user",user),new SqlParameter("@id",material)});
                t.Commit();
            }
        }
        internal static DataTable List()
        {
            AccessHelper.RequireRole(new[] {"Learner"});
            return DatabaseHelper.ExecuteTable("SELECT b.MaterialID,b.CreatedDate,m.Title,c.Title AS CourseTitle,CAST(CASE WHEN m.Status='Published' AND c.Status='Published' AND EXISTS(SELECT 1 FROM dbo.Enrolment e WHERE e.CourseID=c.CourseID AND e.LearnerID=@user) THEN 1 ELSE 0 END AS bit) AS Available FROM dbo.Bookmark b JOIN dbo.Material m ON m.MaterialID=b.MaterialID JOIN dbo.Topic t ON t.TopicID=m.TopicID JOIN dbo.Course c ON c.CourseID=t.CourseID WHERE b.LearnerID=@user ORDER BY b.CreatedDate DESC,b.MaterialID DESC",new[] {new SqlParameter("@user",CurrentUserHelper.GetUserID().Value)});
        }
    }
}
