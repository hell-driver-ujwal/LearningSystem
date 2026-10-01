using System;
using System.Data;
using System.Data.SqlClient;
using System.Web;
namespace LearningSystem.Helpers
{
    public static partial class AccessHelper
    {
        public static bool IsEnrolled(int learnerID, int courseID)
        {
            return Convert.ToInt32(DatabaseHelper.ExecuteScalar("SELECT COUNT(*) FROM dbo.Enrolment e JOIN dbo.[User] u ON u.UserID=e.LearnerID WHERE e.LearnerID=@user AND e.CourseID=@course AND u.Role='Learner' AND u.Status='Active'",
                new[] { new SqlParameter("@user", learnerID), new SqlParameter("@course", courseID) })) == 1;
        }
        public static bool CanPreviewMaterial(int userID, int materialID)
        {
            if (CurrentUserHelper.GetUserID() != userID) return false;
            return Convert.ToInt32(DatabaseHelper.ExecuteScalar("SELECT COUNT(*) FROM dbo.Material m JOIN dbo.Topic t ON t.TopicID=m.TopicID JOIN dbo.Course c ON c.CourseID=t.CourseID JOIN dbo.[User] u ON u.UserID=@user WHERE m.MaterialID=@id AND u.Status='Active' AND (u.Role='Admin' OR (u.Role='Teacher' AND c.TeacherID=u.UserID))",
                new[] { new SqlParameter("@user", userID), new SqlParameter("@id", materialID) })) == 1;
        }
        public static bool CanViewFreePreview(int materialID)
        {
            return Convert.ToInt32(DatabaseHelper.ExecuteScalar("SELECT COUNT(*) FROM dbo.Material m JOIN dbo.Topic t ON t.TopicID=m.TopicID JOIN dbo.Course c ON c.CourseID=t.CourseID WHERE m.MaterialID=@id AND m.IsPreview=1 AND m.Status='Published' AND c.Status='Published'",
                new[] { new SqlParameter("@id", materialID) })) == 1;
        }
        public static bool CanAccessMaterial(int userID, int materialID, bool preview)
        {
            if (preview) return CanPreviewMaterial(userID, materialID);
            if (CurrentUserHelper.GetUserID() != userID) return false;
            return Convert.ToInt32(DatabaseHelper.ExecuteScalar("SELECT COUNT(*) FROM dbo.Material m JOIN dbo.Topic t ON t.TopicID=m.TopicID JOIN dbo.Course c ON c.CourseID=t.CourseID JOIN dbo.Enrolment e ON e.CourseID=c.CourseID JOIN dbo.[User] u ON u.UserID=e.LearnerID WHERE m.MaterialID=@id AND e.LearnerID=@user AND u.Role='Learner' AND u.Status='Active' AND m.Status='Published' AND c.Status='Published'",
                new[] { new SqlParameter("@user", userID), new SqlParameter("@id", materialID) })) == 1;
        }
        public static bool IsOwnerOfCourse(int userID, int courseID) { return Owns(userID, courseID, "Course"); }
        public static bool IsOwnerOfTopic(int userID, int topicID) { return Owns(userID, topicID, "Topic"); }
        public static bool IsOwnerOfMaterial(int userID, int materialID) { return Owns(userID, materialID, "Material"); }
        private static bool Owns(int userID, int id, string kind)
        {
            using (SqlConnection connection = DatabaseHelper.OpenConnection())
                return Owns(connection, null, userID, id, kind);
        }
        internal static bool Owns(SqlConnection connection, SqlTransaction transaction, int userID, int id, string kind)
        {
            // Only fixed SQL fragments chosen by our code; never identifiers from a request.
            string source = "dbo.Course c";
            string predicate = "c.CourseID=@id";
            if (kind == "Topic") { source += " JOIN dbo.Topic t ON t.CourseID=c.CourseID"; predicate = "t.TopicID=@id"; }
            else if (kind == "Material") { source += " JOIN dbo.Topic t ON t.CourseID=c.CourseID JOIN dbo.Material m ON m.TopicID=t.TopicID"; predicate = "m.MaterialID=@id"; }
            else if (kind == "Activity") { source += " JOIN dbo.Topic t ON t.CourseID=c.CourseID JOIN dbo.Activity a ON a.TopicID=t.TopicID"; predicate = "a.ActivityID=@id"; }
            else if (kind != "Course") return false;
            return Convert.ToInt32(DatabaseHelper.ExecuteScalar(connection, transaction,
                "SELECT COUNT(*) FROM " + source + " JOIN dbo.[User] u ON u.UserID=c.TeacherID WHERE " + predicate + " AND c.TeacherID=@user AND u.Role IN ('Teacher','Admin') AND u.Status='Active'",
                new[] { new SqlParameter("@id", id), new SqlParameter("@user", userID) })) == 1;
        }
        internal static void RequireOwner(SqlConnection connection, SqlTransaction transaction, int id, string kind)
        {
            if (!CurrentUserHelper.IsAuthor() || !Owns(connection, transaction, CurrentUserHelper.GetUserID().GetValueOrDefault(), id, kind))
                HttpContext.Current.Response.Redirect("~/AccessDenied.aspx");
        }
        internal static void TouchCourse(SqlConnection connection, SqlTransaction transaction, int courseID)
        {
            DatabaseHelper.ExecuteNonQuery(connection, transaction,
                "UPDATE dbo.Course SET LastUpdated=SYSUTCDATETIME() WHERE CourseID=@id", new[] { new SqlParameter("@id", courseID) });
        }
        public static void RequireRole(string[] allowedRoles)
        {
            HttpContext context = HttpContext.Current;
            if (!CurrentUserHelper.IsAuthenticated())
            {
                context.Response.Redirect("~/Account/Login.aspx?ReturnUrl=" + HttpUtility.UrlEncode(context.Request.RawUrl));
                return;
            }
            if (!CurrentUserHelper.IsActive())
            {
                AuthenticationHelper.SignOut();
                context.Response.Redirect("~/Account/Login.aspx?inactive=1");
                return;
            }
            foreach (string role in allowedRoles)
                if (context.User.IsInRole(role)) return;
            context.Response.Redirect("~/AccessDenied.aspx");
        }
    }
}

