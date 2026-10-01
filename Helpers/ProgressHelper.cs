using System;
using System.Data;
using System.Data.SqlClient;
namespace LearningSystem.Helpers
{
    public static class ProgressHelper
    {
        // Both the progress number and CourseHome ticks use this same definition of done.
        internal static DataTable PublishedItems(int learnerID, int courseID)
        {
            return DatabaseHelper.ExecuteTable(@"
SELECT t.TopicID,t.Title AS TopicTitle,t.SortOrder AS TopicOrder,m.MaterialID AS ItemID,m.Title,m.MaterialType AS ItemType,m.SortOrder,0 AS ItemKind,CAST(NULL AS nvarchar(10)) AS GameTemplate,
 CAST(CASE WHEN EXISTS(SELECT 1 FROM dbo.MaterialCompletion x WHERE x.MaterialID=m.MaterialID AND x.LearnerID=@user) THEN 1 ELSE 0 END AS bit) AS Done
FROM dbo.Material m JOIN dbo.Topic t ON t.TopicID=m.TopicID WHERE t.CourseID=@course AND m.Status='Published'
UNION ALL
SELECT t.TopicID,t.Title,t.SortOrder,a.ActivityID,a.Title,a.ActivityType,a.SortOrder,1,a.GameTemplate,
 CAST(CASE WHEN (a.ActivityType='Discussion' AND EXISTS(SELECT 1 FROM dbo.DiscussionPost p WHERE p.ActivityID=a.ActivityID AND p.UserID=@user))
 OR (a.ActivityType IN ('Quiz','SelfAssessment','Game','Scenario') AND EXISTS(SELECT 1 FROM dbo.Attempt x WHERE x.ActivityID=a.ActivityID AND x.LearnerID=@user)) THEN 1 ELSE 0 END AS bit)
FROM dbo.Activity a JOIN dbo.Topic t ON t.TopicID=a.TopicID WHERE t.CourseID=@course AND a.Status='Published'
ORDER BY TopicOrder,TopicID,ItemKind,SortOrder,ItemID",
                new[] { new SqlParameter("@user", learnerID), new SqlParameter("@course", courseID) });
        }
        public static decimal CalculatePercent(int learnerID, int courseID)
        {
            DataTable items = PublishedItems(learnerID, courseID);
            if (items.Rows.Count == 0) return 0m;
            int done = 0;
            foreach (DataRow row in items.Rows) if ((bool)row["Done"]) done++;
            return Math.Round(done * 100m / items.Rows.Count, 2, MidpointRounding.AwayFromZero);
        }
    }
}
