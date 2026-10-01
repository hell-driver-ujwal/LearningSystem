using System;
using System.Data;
using System.Data.SqlClient;

namespace LearningSystem.Helpers
{
    // First-party page analytics. Only the page path, the visitor's role and the time are stored:
    // no user ID, IP address, browser details or tracking cookie (see Privacy.aspx).
    public static class AnalyticsHelper
    {
        private static readonly Random Cleanup = new Random();
        public static void RecordView(string pagePath, string role)
        {
            if (String.IsNullOrEmpty(pagePath)) return;
            string path = pagePath.Length > 200 ? pagePath.Substring(0, 200) : pagePath;
            string viewer = role == "Learner" || role == "Teacher" || role == "Admin" ? role : "Visitor";
            try
            {
                DatabaseHelper.ExecuteNonQuery("INSERT dbo.PageView (PagePath, ViewerRole) VALUES (@path, @role)",
                    new[] { new SqlParameter("@path", SqlDbType.NVarChar, 200) { Value = path }, new SqlParameter("@role", SqlDbType.NVarChar, 7) { Value = viewer } });
                // About once in every 200 views, remove records older than 12 months (see Privacy.aspx).
                if (Cleanup.Next(200) == 0)
                    DatabaseHelper.ExecuteNonQuery("DELETE FROM dbo.PageView WHERE ViewedAt < DATEADD(month, -12, SYSUTCDATETIME())", null);
            }
            catch (SqlException)
            {
                // Analytics must never stop a visitor from using the page.
            }
        }

        // Views per day for the last given number of days, oldest first, including days with no views.
        public static DataTable DailyViews(int days)
        {
            return DatabaseHelper.ExecuteTable(@"WITH Days AS (
    SELECT CAST(DATEADD(day, -n.Number, CAST(SYSUTCDATETIME() AS date)) AS date) AS ViewDate
    FROM (SELECT TOP (@days) ROW_NUMBER() OVER (ORDER BY object_id) - 1 AS Number FROM sys.all_objects) n)
SELECT d.ViewDate, COUNT(v.PageViewID) AS Views
FROM Days d LEFT JOIN dbo.PageView v ON CAST(v.ViewedAt AS date) = d.ViewDate
GROUP BY d.ViewDate ORDER BY d.ViewDate", new[] { new SqlParameter("@days", days) });
        }

        public static DataTable TopPages(int days, int limit)
        {
            return DatabaseHelper.ExecuteTable("SELECT TOP (@limit) PagePath, COUNT(*) AS Views FROM dbo.PageView WHERE ViewedAt >= DATEADD(day, -@days, SYSUTCDATETIME()) GROUP BY PagePath ORDER BY COUNT(*) DESC, PagePath",
                new[] { new SqlParameter("@days", days), new SqlParameter("@limit", limit) });
        }

        public static DataTable ViewsByRole(int days)
        {
            return DatabaseHelper.ExecuteTable("SELECT ViewerRole, COUNT(*) AS Views FROM dbo.PageView WHERE ViewedAt >= DATEADD(day, -@days, SYSUTCDATETIME()) GROUP BY ViewerRole ORDER BY COUNT(*) DESC",
                new[] { new SqlParameter("@days", days) });
        }

        public static int TotalViews(int days)
        {
            return Convert.ToInt32(DatabaseHelper.ExecuteScalar("SELECT COUNT(*) FROM dbo.PageView WHERE ViewedAt >= DATEADD(day, -@days, SYSUTCDATETIME())", new[] { new SqlParameter("@days", days) }));
        }
    }
}
