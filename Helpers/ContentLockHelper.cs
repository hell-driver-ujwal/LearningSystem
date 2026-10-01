using System;
using System.Data.SqlClient;
namespace LearningSystem.Helpers
{
    public static class ContentLockHelper
    {
        public static bool HasAttempts(int activityID) { using(var c=DatabaseHelper.OpenConnection()) return HasAttempts(c,null,activityID); }
        internal static bool HasAttempts(SqlConnection c,SqlTransaction t,int id) { return Convert.ToInt32(DatabaseHelper.ExecuteScalar(c,t,"SELECT COUNT(*) FROM dbo.Attempt WHERE ActivityID=@id",ActivityHelper.ID(id)))>0; }
        public static ValidationResult CheckCanChangeContent(int activityID) { return new ValidationResult {IsValid=!HasAttempts(activityID),Message="Content is locked after attempts. Title and description remain editable."}; }
        public static ValidationResult CheckCanChangeSettings(int activityID) { return CheckCanChangeContent(activityID); }
    }
}
