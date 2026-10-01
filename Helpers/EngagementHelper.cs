using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Text;

namespace LearningSystem.Helpers
{
    // Learning streaks and weekly activity, calculated from saved records every time (never stored),
    // in the same way that course progress is calculated.
    internal static class EngagementHelper
    {
        // Every UTC day on which the learner completed a lesson, submitted an attempt or wrote a post.
        internal static HashSet<DateTime> ActiveDays(int learnerID)
        {
            DataTable rows = DatabaseHelper.ExecuteTable(@"
SELECT CAST(CompletedDate AS date) AS Day FROM dbo.MaterialCompletion WHERE LearnerID=@user
UNION SELECT CAST(SubmittedAt AS date) FROM dbo.Attempt WHERE LearnerID=@user
UNION SELECT CAST(PostedDate AS date) FROM dbo.DiscussionPost WHERE UserID=@user", new[] { new SqlParameter("@user", learnerID) });
            HashSet<DateTime> days = new HashSet<DateTime>();
            foreach (DataRow row in rows.Rows) days.Add(((DateTime)row["Day"]).Date);
            return days;
        }

        // Consecutive active days up to today. If nothing is done yet today, yesterday still keeps the streak alive.
        internal static int Streak(HashSet<DateTime> days)
        {
            DateTime day = DateTime.UtcNow.Date;
            if (!days.Contains(day)) day = day.AddDays(-1);
            int streak = 0;
            while (days.Contains(day)) { streak++; day = day.AddDays(-1); }
            return streak;
        }

        // Seven small squares for the last seven days, oldest first.
        internal static string WeekStrip(HashSet<DateTime> days)
        {
            StringBuilder html = new StringBuilder("<ul class=\"week-strip\" aria-label=\"Activity in the last seven days\">");
            for (int i = 6; i >= 0; i--)
            {
                DateTime day = DateTime.UtcNow.Date.AddDays(-i);
                bool active = days.Contains(day);
                html.Append("<li").Append(active ? " class=\"on\"" : "").Append("><span class=\"dot\" aria-hidden=\"true\"></span>")
                    .Append(day.ToString("ddd", CultureInfo.InvariantCulture).Substring(0, 2))
                    .Append("<span class=\"visually-hidden\">").Append(day.ToString(" d MMMM", CultureInfo.InvariantCulture)).Append(active ? ": studied" : ": no activity").Append("</span></li>");
            }
            return html.Append("</ul>").ToString();
        }

        internal static int CompletedItems(int learnerID)
        {
            return Convert.ToInt32(DatabaseHelper.ExecuteScalar(@"SELECT
 (SELECT COUNT(*) FROM dbo.MaterialCompletion WHERE LearnerID=@user)
 + (SELECT COUNT(DISTINCT ActivityID) FROM dbo.Attempt WHERE LearnerID=@user)
 + (SELECT COUNT(DISTINCT ActivityID) FROM dbo.DiscussionPost WHERE UserID=@user)", new[] { new SqlParameter("@user", learnerID) }));
        }

        // Average of the best score on each quiz and game, or null before the first attempt.
        internal static decimal? AverageBestScore(int learnerID)
        {
            object value = DatabaseHelper.ExecuteScalar(@"SELECT AVG(Best) FROM (SELECT MAX(x.ScorePercent) AS Best FROM dbo.Attempt x JOIN dbo.Activity a ON a.ActivityID=x.ActivityID
WHERE x.LearnerID=@user AND a.ActivityType IN ('Quiz','Game') GROUP BY x.ActivityID) b", new[] { new SqlParameter("@user", learnerID) });
            return value == null || value == DBNull.Value ? (decimal?)null : Math.Round(Convert.ToDecimal(value), 0, MidpointRounding.AwayFromZero);
        }

        // The enrolled, published course the learner touched most recently.
        internal static int LastCourse(int learnerID)
        {
            object value = DatabaseHelper.ExecuteScalar(@"SELECT TOP (1) CourseID FROM (
 SELECT t.CourseID, x.CompletedDate AS At FROM dbo.MaterialCompletion x JOIN dbo.Material m ON m.MaterialID=x.MaterialID JOIN dbo.Topic t ON t.TopicID=m.TopicID WHERE x.LearnerID=@user
 UNION ALL SELECT t.CourseID, x.SubmittedAt FROM dbo.Attempt x JOIN dbo.Activity a ON a.ActivityID=x.ActivityID JOIN dbo.Topic t ON t.TopicID=a.TopicID WHERE x.LearnerID=@user
 UNION ALL SELECT e.CourseID, e.EnrolDate FROM dbo.Enrolment e WHERE e.LearnerID=@user) recent
WHERE EXISTS (SELECT 1 FROM dbo.Enrolment e JOIN dbo.Course c ON c.CourseID=e.CourseID WHERE e.LearnerID=@user AND e.CourseID=recent.CourseID AND c.Status='Published')
ORDER BY At DESC", new[] { new SqlParameter("@user", learnerID) });
            return value == null ? 0 : Convert.ToInt32(value);
        }
    }
}
