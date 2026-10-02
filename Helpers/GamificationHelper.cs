using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;

namespace LearningSystem.Helpers
{
    // One badge and how close the learner is to earning it.
    public class Badge
    {
        public string Name;
        public string Description;
        public string Icon;
        public int Current;
        public int Target;
        public bool Earned { get { return Current >= Target; } }
    }

    // Everything the game layer shows for one learner. Nothing here is stored:
    // like progress, it is worked out from completions, attempts and posts each time.
    public class PlayerStats
    {
        public int Xp;
        public int Level;
        public string LevelTitle;
        public int XpIntoLevel;
        public int XpForLevel;
        public int Streak;
        public int LongestStreak;
        public int TodayCount;
        public int DailyGoal;
        public int CoursesDone;
        public HashSet<DateTime> Days = new HashSet<DateTime>();
        public List<Badge> Badges = new List<Badge>();
        public int BadgesEarned { get { int n = 0; foreach (Badge b in Badges) if (b.Earned) n++; return n; } }
    }

    public static class GamificationHelper
    {
        public const int LessonXp = 10;
        public const int DiscussionXp = 15;
        public const int SelfAssessmentXp = 20;
        public const int CourseBonusXp = 100;
        public const int DailyGoalItems = 3;
        private static readonly string[] Titles = { "Ink Drop", "Scribbler", "Note Taker", "Apprentice", "Scholar", "Researcher", "Expert", "Mentor", "Master", "Legend" };

        // XP for one quiz, game or scenario, from the learner's best result on it.
        // Quizzes and games: half the best score (up to 50). Scenarios: Best 40, Acceptable 25, Poor 10.
        public static int ActivityXp(string activityType, decimal? bestScore, string bestOutcome)
        {
            if (activityType == "Quiz" || activityType == "Game")
                return bestScore.HasValue ? (int)Math.Round(bestScore.Value / 2m, MidpointRounding.AwayFromZero) : 0;
            if (activityType == "Scenario")
                return bestOutcome == "Best" ? 40 : bestOutcome == "Acceptable" ? 25 : bestOutcome == "Poor" ? 10 : 0;
            if (activityType == "SelfAssessment") return SelfAssessmentXp;
            return 0;
        }

        // XP the learner currently holds for one activity: it always comes from their best result.
        public static int BestActivityXp(int learnerID, int activityID)
        {
            DataTable best = DatabaseHelper.ExecuteTable(@"SELECT a.ActivityType, MAX(x.ScorePercent) AS BestScore,
 MAX(CASE s.Outcome WHEN 'Best' THEN 3 WHEN 'Acceptable' THEN 2 WHEN 'Poor' THEN 1 ELSE 0 END) AS BestOutcome
FROM dbo.Attempt x JOIN dbo.Activity a ON a.ActivityID=x.ActivityID LEFT JOIN dbo.SimStep s ON s.StepID=x.EndingStepID
WHERE x.LearnerID=@user AND x.ActivityID=@id GROUP BY a.ActivityType", new[] { new SqlParameter("@user", learnerID), new SqlParameter("@id", activityID) });
            if (best.Rows.Count == 0) return 0;
            DataRow row = best.Rows[0];
            int outcome = Convert.ToInt32(row["BestOutcome"]);
            return ActivityXp((string)row["ActivityType"], row.IsNull("BestScore") ? (decimal?)null : Convert.ToDecimal(row["BestScore"]),
                outcome == 3 ? "Best" : outcome == 2 ? "Acceptable" : outcome == 1 ? "Poor" : null);
        }

        // Level n starts at 50 x n x (n - 1) XP: 0, 100, 300, 600, 1000, 1500 and so on.
        public static int LevelFor(int xp)
        {
            int level = 1;
            while (50 * (level + 1) * level <= xp) level++;
            return level;
        }

        public static int LevelStart(int level) { return 50 * level * (level - 1); }

        public static string TitleFor(int level) { return Titles[Math.Min(level, Titles.Length) - 1]; }

        public static PlayerStats Load(int learnerID)
        {
            SqlParameter[] me = { new SqlParameter("@user", learnerID) };
            DataRow totals = DatabaseHelper.ExecuteTable(@"SELECT
 (SELECT COUNT(*) FROM dbo.MaterialCompletion WHERE LearnerID=@user) AS Lessons,
 (SELECT COUNT(*) FROM dbo.MaterialCompletion x JOIN dbo.Material m ON m.MaterialID=x.MaterialID WHERE x.LearnerID=@user AND m.MaterialType='Code') AS CodeLabs,
 (SELECT COUNT(DISTINCT ActivityID) FROM dbo.DiscussionPost WHERE UserID=@user) AS Discussions,
 (SELECT COUNT(*) FROM dbo.Enrolment WHERE LearnerID=@user) AS Enrolments,
 (SELECT COUNT(*) FROM dbo.MaterialCompletion WHERE LearnerID=@user AND CAST(CompletedDate AS date)=CAST(SYSUTCDATETIME() AS date))
 + (SELECT COUNT(DISTINCT ActivityID) FROM dbo.Attempt WHERE LearnerID=@user AND CAST(SubmittedAt AS date)=CAST(SYSUTCDATETIME() AS date))
 + (SELECT COUNT(DISTINCT ActivityID) FROM dbo.DiscussionPost WHERE UserID=@user AND CAST(PostedDate AS date)=CAST(SYSUTCDATETIME() AS date)) AS Today", me).Rows[0];

            // Best result on each activity the learner has attempted.
            DataTable best = DatabaseHelper.ExecuteTable(@"SELECT a.ActivityType, MAX(x.ScorePercent) AS BestScore,
 MAX(CASE s.Outcome WHEN 'Best' THEN 3 WHEN 'Acceptable' THEN 2 WHEN 'Poor' THEN 1 ELSE 0 END) AS BestOutcome
FROM dbo.Attempt x JOIN dbo.Activity a ON a.ActivityID=x.ActivityID LEFT JOIN dbo.SimStep s ON s.StepID=x.EndingStepID
WHERE x.LearnerID=@user GROUP BY x.ActivityID, a.ActivityType", new[] { new SqlParameter("@user", learnerID) });

            PlayerStats stats = new PlayerStats();
            int lessons = Convert.ToInt32(totals["Lessons"]), discussions = Convert.ToInt32(totals["Discussions"]);
            int games = 0, perfect = 0, perfectQuiz = 0, bestScenario = 0, selfAssessments = 0;
            stats.Xp = lessons * LessonXp + discussions * DiscussionXp;
            foreach (DataRow row in best.Rows)
            {
                string type = (string)row["ActivityType"];
                decimal? score = row.IsNull("BestScore") ? (decimal?)null : Convert.ToDecimal(row["BestScore"]);
                int outcome = Convert.ToInt32(row["BestOutcome"]);
                string outcomeName = outcome == 3 ? "Best" : outcome == 2 ? "Acceptable" : outcome == 1 ? "Poor" : null;
                stats.Xp += ActivityXp(type, score, outcomeName);
                if (type == "Game") games++;
                if (type == "SelfAssessment") selfAssessments++;
                if (outcome == 3) bestScenario++;
                if (score.HasValue && score.Value == 100m) { perfect++; if (type == "Quiz") perfectQuiz++; }
            }

            // Bonus for every course finished to 100 percent.
            int coursesDone = 0;
            foreach (DataRow course in DatabaseHelper.ExecuteTable("SELECT e.CourseID FROM dbo.Enrolment e JOIN dbo.Course c ON c.CourseID=e.CourseID WHERE e.LearnerID=@user AND c.Status='Published'", new[] { new SqlParameter("@user", learnerID) }).Rows)
                if (ProgressHelper.CalculatePercent(learnerID, (int)course["CourseID"]) == 100m) coursesDone++;
            stats.Xp += coursesDone * CourseBonusXp;
            stats.CoursesDone = coursesDone;

            stats.Level = LevelFor(stats.Xp);
            stats.LevelTitle = TitleFor(stats.Level);
            stats.XpIntoLevel = stats.Xp - LevelStart(stats.Level);
            stats.XpForLevel = LevelStart(stats.Level + 1) - LevelStart(stats.Level);
            stats.Days = EngagementHelper.ActiveDays(learnerID);
            stats.Streak = EngagementHelper.Streak(stats.Days);
            stats.LongestStreak = LongestStreak(stats.Days);
            stats.TodayCount = Convert.ToInt32(totals["Today"]);
            stats.DailyGoal = DailyGoalItems;

            int codeLabs = Convert.ToInt32(totals["CodeLabs"]), enrolments = Convert.ToInt32(totals["Enrolments"]);
            stats.Badges.Add(MakeBadge("First steps", "Complete your first lesson.", "book", lessons, 1));
            stats.Badges.Add(MakeBadge("Code crafter", "Complete a code lab.", "code", codeLabs, 1));
            stats.Badges.Add(MakeBadge("Quiz whiz", "Score 100% on a quiz.", "quiz", perfectQuiz, 1));
            stats.Badges.Add(MakeBadge("Game on", "Play 5 different games.", "puzzle", games, 5));
            stats.Badges.Add(MakeBadge("Big thinker", "Reach the best ending of a scenario.", "route", bestScenario, 1));
            stats.Badges.Add(MakeBadge("Voice heard", "Post in a discussion.", "chat", discussions, 1));
            stats.Badges.Add(MakeBadge("Self aware", "Complete 3 self-assessments.", "gauge", selfAssessments, 3));
            stats.Badges.Add(MakeBadge("On fire", "Study 3 days in a row.", "flame", stats.LongestStreak, 3));
            stats.Badges.Add(MakeBadge("Unstoppable", "Study 7 days in a row.", "flame", stats.LongestStreak, 7));
            stats.Badges.Add(MakeBadge("Explorer", "Enrol in 3 courses.", "compass", enrolments, 3));
            stats.Badges.Add(MakeBadge("Perfectionist", "Score 100% on 5 quizzes or games.", "star", perfect, 5));
            stats.Badges.Add(MakeBadge("Course champion", "Finish a whole course.", "award", coursesDone, 1));
            return stats;
        }

        private static Badge MakeBadge(string name, string description, string icon, int current, int target)
        {
            return new Badge { Name = name, Description = description, Icon = icon, Current = Math.Min(current, target), Target = target };
        }

        // The longest run of consecutive active days ever, so a badge stays earned after a break.
        private static int LongestStreak(HashSet<DateTime> days)
        {
            int longest = 0;
            foreach (DateTime day in days)
            {
                if (days.Contains(day.AddDays(-1))) continue; // only count from the first day of each run
                int run = 1;
                while (days.Contains(day.AddDays(run))) run++;
                longest = Math.Max(longest, run);
            }
            return longest;
        }
    }
}
