using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Web;

namespace LearningSystem.Helpers
{
    public static partial class DeleteHelper
    {
        private static readonly object CleanupLogLock = new object();

        private static SqlParameter[] ID(int id)
        {
            return new[] { new SqlParameter("@id", SqlDbType.Int) { Value = id } };
        }
        private static ValidationResult Result(bool valid, string message)
        {
            return new ValidationResult { IsValid = valid, Message = message };
        }
        private static bool IsAdmin(SqlConnection connection, SqlTransaction transaction)
        {
            int? actor = CurrentUserHelper.GetUserID();
            if (!actor.HasValue || CurrentUserHelper.GetRole() != "Admin") return false;
            return Convert.ToInt32(DatabaseHelper.ExecuteScalar(connection, transaction,
                "SELECT COUNT(*) FROM dbo.[User] WITH (HOLDLOCK) WHERE UserID=@id AND Role='Admin' AND Status='Active'", ID(actor.Value))) == 1;
        }
        public static ValidationResult CheckSubject(int subjectID)
        {
            using (SqlConnection connection = DatabaseHelper.OpenConnection())
                return CheckSubject(connection, null, subjectID);
        }
        internal static ValidationResult CheckSubject(SqlConnection connection, SqlTransaction transaction, int subjectID)
        {
            return Result(Convert.ToInt32(DatabaseHelper.ExecuteScalar(connection, transaction,
                "SELECT COUNT(*) FROM dbo.Course WITH (HOLDLOCK) WHERE SubjectID=@id", ID(subjectID))) == 0,
                "This subject is used by a course and cannot be deleted.");
        }
        public static ValidationResult CheckUser(int userID)
        {
            using (SqlConnection connection = DatabaseHelper.OpenConnection())
                return CheckUser(connection, null, userID);
        }
        private static ValidationResult CheckUser(SqlConnection connection, SqlTransaction transaction, int userID)
        {
            DataTable users = DatabaseHelper.ExecuteTable(connection, transaction,
                "SELECT Role FROM dbo.[User] WITH (UPDLOCK,HOLDLOCK) WHERE UserID=@id", ID(userID));
            if (users.Rows.Count != 1) return Result(false, "The user no longer exists.");
            if ((string)users.Rows[0]["Role"] == "Admin") return Result(false, "Admin accounts cannot be changed or deleted.");
            if (Convert.ToInt32(DatabaseHelper.ExecuteScalar(connection, transaction,
                "SELECT COUNT(*) FROM dbo.Course WITH (HOLDLOCK) WHERE TeacherID=@id", ID(userID))) > 0)
                return Result(false, "This teacher owns courses and cannot be deleted.");
            if (Convert.ToInt32(DatabaseHelper.ExecuteScalar(connection, transaction,
                "SELECT COUNT(*) FROM dbo.Payment WITH (HOLDLOCK) WHERE LearnerID=@id", ID(userID))) > 0)
                return Result(false, "Payment history must be retained. Deactivate this user instead.");
            return Result(true, "");
        }
        public static ValidationResult CheckCourse(int courseID)
        {
            return Result(Convert.ToInt32(DatabaseHelper.ExecuteScalar(
                "SELECT COUNT(*) FROM dbo.Attempt a JOIN dbo.Activity v ON v.ActivityID=a.ActivityID JOIN dbo.Topic t ON t.TopicID=v.TopicID WHERE t.CourseID=@id", ID(courseID))) == 0,
                "This course has attempts. Unpublish it instead.");
        }
        public static ValidationResult CheckActivity(int activityID)
        {
            return Result(Convert.ToInt32(DatabaseHelper.ExecuteScalar(
                "SELECT COUNT(*) FROM dbo.Attempt WHERE ActivityID=@id", ID(activityID))) == 0,
                "This activity has attempts. Unpublish it instead.");
        }
        public static ValidationResult DeleteUser(int userID)
        {
            using (SqlConnection connection = DatabaseHelper.OpenConnection())
            using (SqlTransaction transaction = connection.BeginTransaction(IsolationLevel.Serializable))
            {
                if (!IsAdmin(connection, transaction)) return Result(false, "Only an active admin can delete users.");
                ValidationResult check = CheckUser(connection, transaction, userID);
                if (!check.IsValid) return check;
                // Each statement uses the same transaction: failures leave the complete account intact.
                string[] statements = {
                    "DELETE FROM dbo.QuizAnswer WHERE AttemptID IN (SELECT AttemptID FROM dbo.Attempt WHERE LearnerID=@id)",
                    "DELETE FROM dbo.SAResponse WHERE AttemptID IN (SELECT AttemptID FROM dbo.Attempt WHERE LearnerID=@id)",
                    "DELETE FROM dbo.Attempt WHERE LearnerID=@id",
                    "DELETE FROM dbo.DiscussionPost WHERE ParentPostID IN (SELECT PostID FROM dbo.DiscussionPost WHERE UserID=@id AND ParentPostID IS NULL)",
                    "DELETE FROM dbo.DiscussionPost WHERE UserID=@id AND ParentPostID IS NOT NULL",
                    "DELETE FROM dbo.DiscussionPost WHERE UserID=@id",
                    "DELETE FROM dbo.MaterialCompletion WHERE LearnerID=@id",
                    "DELETE FROM dbo.Bookmark WHERE LearnerID=@id",
                    "DELETE FROM dbo.Enrolment WHERE LearnerID=@id",
                    "DELETE FROM dbo.Review WHERE LearnerID=@id",
                    "UPDATE dbo.ContactMessage SET UserID=NULL WHERE UserID=@id",
                    "DELETE FROM dbo.[User] WHERE UserID=@id AND Role IN ('Learner','Teacher')"
                };
                foreach (string sql in statements)
                    DatabaseHelper.ExecuteNonQuery(connection, transaction, sql, ID(userID));
                transaction.Commit();
                return Result(true, "User and dependent learning records deleted. Contact history retained.");
            }
        }
        public static ValidationResult DeleteCourse(int courseID)
        {
            return DeleteContent(courseID, "Course");
        }
        public static ValidationResult DeleteActivity(int activityID)
        {
            return DeleteContent(activityID, "Activity");
        }
        public static ValidationResult CheckTopic(int topicID)
        {
            return Result(Convert.ToInt32(DatabaseHelper.ExecuteScalar(
                "SELECT COUNT(*) FROM dbo.Attempt a JOIN dbo.Activity v ON v.ActivityID=a.ActivityID WHERE v.TopicID=@id", ID(topicID))) == 0,
                "This topic has attempts. Unpublish the course instead.");
        }
        public static ValidationResult DeleteTopic(int topicID) { return DeleteContent(topicID, "Topic"); }
        public static ValidationResult DeleteMaterial(int materialID)
        {
            List<string> files = new List<string>();
            using (SqlConnection connection = DatabaseHelper.OpenConnection())
            using (SqlTransaction transaction = connection.BeginTransaction(IsolationLevel.Serializable))
            {
                AccessHelper.RequireOwner(connection, transaction, materialID, "Material");
                DataRow row = DatabaseHelper.ExecuteTable(connection, transaction,
                    "SELECT m.FilePath,t.CourseID FROM dbo.Material m JOIN dbo.Topic t ON t.TopicID=m.TopicID WHERE m.MaterialID=@id", ID(materialID)).Rows[0];
                if (!row.IsNull("FilePath"))
                {
                    string path = (string)row["FilePath"];
                    UploadHelper.GetValidatedPath(path);
                    files.Add(path);
                }
                DatabaseHelper.ExecuteNonQuery(connection, transaction, "DELETE FROM dbo.Bookmark WHERE MaterialID=@id", ID(materialID));
                DatabaseHelper.ExecuteNonQuery(connection, transaction, "DELETE FROM dbo.MaterialCompletion WHERE MaterialID=@id", ID(materialID));
                DatabaseHelper.ExecuteNonQuery(connection, transaction, "DELETE FROM dbo.Material WHERE MaterialID=@id", ID(materialID));
                AccessHelper.TouchCourse(connection, transaction, (int)row["CourseID"]);
                transaction.Commit();
            }
            return CleanupFiles(files);
        }
        private static ValidationResult DeleteContent(int id, string kind)
        {
            bool course = kind == "Course";
            bool topic = kind == "Topic";
            List<string> paths = new List<string>();
            using (SqlConnection connection = DatabaseHelper.OpenConnection())
            using (SqlTransaction transaction = connection.BeginTransaction(IsolationLevel.Serializable))
            {
                if (!IsAdmin(connection, transaction)) AccessHelper.RequireOwner(connection, transaction, id, kind);
                string parentQuery = course
                    ? "SELECT COUNT(*) FROM dbo.Course WITH (UPDLOCK,HOLDLOCK) WHERE CourseID=@id"
                    : topic ? "SELECT COUNT(*) FROM dbo.Topic WITH (UPDLOCK,HOLDLOCK) WHERE TopicID=@id" : "SELECT COUNT(*) FROM dbo.Activity WITH (UPDLOCK,HOLDLOCK) WHERE ActivityID=@id";
                if (Convert.ToInt32(DatabaseHelper.ExecuteScalar(connection, transaction, parentQuery, ID(id))) != 1)
                    return Result(false, "This content no longer exists.");
                if (course && Convert.ToInt32(DatabaseHelper.ExecuteScalar(connection,transaction,"SELECT COUNT(*) FROM dbo.Payment WITH (HOLDLOCK) WHERE CourseID=@id",ID(id)))>0)
                    return Result(false,"Payment history must be retained. Unpublish this course instead.");
                // This fragment is selected only by C#; no browser value is used as SQL text.
                string activities = course
                    ? "SELECT a.ActivityID FROM dbo.Activity a JOIN dbo.Topic t ON t.TopicID=a.TopicID WHERE t.CourseID=@id"
                    : topic ? "SELECT ActivityID FROM dbo.Activity WHERE TopicID=@id" : "SELECT ActivityID FROM dbo.Activity WHERE ActivityID=@id";
                if (Convert.ToInt32(DatabaseHelper.ExecuteScalar(connection, transaction,
                    "SELECT COUNT(*) FROM dbo.Attempt WITH (HOLDLOCK) WHERE ActivityID IN (" + activities + ")", ID(id))) > 0)
                    return Result(false, "This content has attempts. Unpublish it instead.");
                string pathQuery = "SELECT ImagePath AS FilePath FROM dbo.SimStep WHERE ActivityID IN (" + activities + ")";
                if (course) pathQuery += " UNION SELECT m.FilePath FROM dbo.Material m JOIN dbo.Topic t ON t.TopicID=m.TopicID WHERE t.CourseID=@id UNION SELECT CoverImagePath FROM dbo.Course WHERE CourseID=@id";
                if (topic) pathQuery += " UNION SELECT FilePath FROM dbo.Material WHERE TopicID=@id";
                DataTable files = DatabaseHelper.ExecuteTable(connection, transaction, pathQuery, ID(id));
                foreach (DataRow row in files.Rows)
                {
                    if (row.IsNull("FilePath")) continue;
                    string path = (string)row["FilePath"];
                    try { UploadHelper.GetValidatedPath(path); }
                    catch (ArgumentException) { return Result(false, "Content has an invalid upload path. Correct it before deletion."); }
                    if (!paths.Contains(path)) paths.Add(path);
                }
                if (course || topic)
                {
                    string materials = course ? "SELECT m.MaterialID FROM dbo.Material m JOIN dbo.Topic t ON t.TopicID=m.TopicID WHERE t.CourseID=@id" : "SELECT MaterialID FROM dbo.Material WHERE TopicID=@id";
                    DatabaseHelper.ExecuteNonQuery(connection, transaction, "DELETE FROM dbo.Bookmark WHERE MaterialID IN (" + materials + ")", ID(id));
                    DatabaseHelper.ExecuteNonQuery(connection, transaction, "DELETE FROM dbo.MaterialCompletion WHERE MaterialID IN (" + materials + ")", ID(id));
                    if (course) DatabaseHelper.ExecuteNonQuery(connection, transaction, "DELETE FROM dbo.Review WHERE CourseID=@id", ID(id));
                    if (course) DatabaseHelper.ExecuteNonQuery(connection, transaction, "DELETE FROM dbo.Enrolment WHERE CourseID=@id", ID(id));
                }
                string[] statements = {
                    "DELETE FROM dbo.DiscussionPost WHERE ActivityID IN (" + activities + ") AND ParentPostID IS NOT NULL",
                    "DELETE FROM dbo.DiscussionPost WHERE ActivityID IN (" + activities + ")",
                    "UPDATE dbo.Activity SET StartStepID=NULL WHERE ActivityID IN (" + activities + ")",
                    "DELETE FROM dbo.SimChoice WHERE FromStepID IN (SELECT StepID FROM dbo.SimStep WHERE ActivityID IN (" + activities + "))",
                    "DELETE FROM dbo.SimStep WHERE ActivityID IN (" + activities + ")",
                    "DELETE FROM dbo.GameItem WHERE ActivityID IN (" + activities + ")",
                    "DELETE FROM dbo.Activity WHERE ActivityID IN (" + activities + ")"
                };
                if (!course && !topic) AccessHelper.TouchCourse(connection, transaction, Convert.ToInt32(DatabaseHelper.ExecuteScalar(connection, transaction, "SELECT t.CourseID FROM dbo.Activity a JOIN dbo.Topic t ON t.TopicID=a.TopicID WHERE a.ActivityID=@id", ID(id))));
                foreach (string sql in statements) DatabaseHelper.ExecuteNonQuery(connection, transaction, sql, ID(id));
                if (course) DatabaseHelper.ExecuteNonQuery(connection, transaction, "DELETE FROM dbo.Course WHERE CourseID=@id", ID(id));
                if (topic)
                {
                    int courseID = Convert.ToInt32(DatabaseHelper.ExecuteScalar(connection, transaction, "SELECT CourseID FROM dbo.Topic WHERE TopicID=@id", ID(id)));
                    DatabaseHelper.ExecuteNonQuery(connection, transaction, "DELETE FROM dbo.Topic WHERE TopicID=@id", ID(id));
                    AccessHelper.TouchCourse(connection, transaction, courseID);
                }
                transaction.Commit();
            }
            return CleanupFiles(paths);
        }
        internal static ValidationResult CleanupFiles(List<string> paths)
        {
            bool failed = false;
            bool logFailed = false;
            foreach (string path in paths)
            {
                try
                {
                    // Seed content can share an image: keep files still referenced by surviving content.
                    int references = Convert.ToInt32(DatabaseHelper.ExecuteScalar(
                        "SELECT (SELECT COUNT(*) FROM dbo.Course WHERE CoverImagePath=@path) + (SELECT COUNT(*) FROM dbo.Material WHERE FilePath=@path) + (SELECT COUNT(*) FROM dbo.SimStep WHERE ImagePath=@path)",
                        new[] { new SqlParameter("@path", SqlDbType.NVarChar, 500) { Value = path } }));
                    if (references == 0) UploadHelper.Delete(path);
                }
                catch (Exception ex)
                {
                    if (!(ex is IOException) && !(ex is UnauthorizedAccessException) && !(ex is ArgumentException) && !(ex is SqlException)) throw;
                    failed = true;
                    try
                    {
                        // Paths were validated before commit. Never log arbitrary input or exception details.
                        lock (CleanupLogLock)
                            File.AppendAllText(HttpContext.Current.Server.MapPath("~/App_Data/FileCleanup.log"), DateTime.UtcNow.ToString("s") + " UTC " + path + Environment.NewLine);
                    }
                    catch (IOException) { logFailed = true; }
                    catch (UnauthorizedAccessException) { logFailed = true; }
                }
            }
            return Result(true, failed
                ? "One or more files require manual cleanup. " + (logFailed ? "The cleanup log could not be written; ask the administrator to check App_Data permissions." : "See the server's App_Data/FileCleanup.log.")
                : "Content and unreferenced uploaded files deleted.");
        }
    }
}


