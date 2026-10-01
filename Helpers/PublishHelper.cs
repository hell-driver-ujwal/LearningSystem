using System;
using System.Data.SqlClient;
namespace LearningSystem.Helpers
{
    public static partial class PublishHelper
    {
        public static ValidationResult CheckCourse(int courseID)
        {
            using (SqlConnection connection = DatabaseHelper.OpenConnection())
                return CheckCourse(connection, null, courseID);
        }
        internal static ValidationResult CheckCourse(SqlConnection connection, SqlTransaction transaction, int courseID)
        {
            int count = Convert.ToInt32(DatabaseHelper.ExecuteScalar(connection, transaction,
                "SELECT COUNT(*) FROM dbo.Topic t WHERE t.CourseID=@id AND (EXISTS (SELECT 1 FROM dbo.Material m WHERE m.TopicID=t.TopicID AND m.Status='Published') OR EXISTS (SELECT 1 FROM dbo.Activity a WHERE a.TopicID=t.TopicID AND a.Status='Published'))",
                new[] { new SqlParameter("@id", courseID) }));
            return new ValidationResult { IsValid = count > 0, Message = "Publish at least one material or activity inside a topic before publishing this course." };
        }
    }
}

