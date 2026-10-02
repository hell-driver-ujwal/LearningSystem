using System;
using System.Data;
using System.Globalization;
using System.Text;
using System.Web;

namespace LearningSystem.Helpers
{
    // HTML for the game layer: player card, badges, the course learning path and XP labels.
    // All numbers come from GamificationHelper, which works them out from real records.
    public static class GameUiHelper
    {
        private static string E(object value) { return HttpUtility.HtmlEncode(Convert.ToString(value, CultureInfo.InvariantCulture)); }

        // What Inky says on the dashboard, based on today's activity and the streak.
        public static string Speech(PlayerStats stats)
        {
            if (stats.TodayCount >= stats.DailyGoal) return "Daily goal done! See you tomorrow.";
            if (stats.TodayCount > 0) return (stats.DailyGoal - stats.TodayCount) + " more to reach today's goal.";
            if (stats.Streak > 0) return "Do one thing today to keep your " + stats.Streak + "-day streak!";
            return "Let's start a streak today!";
        }

        public static string PlayerCard(PlayerStats stats, string firstName, int userID)
        {
            int percent = stats.XpForLevel == 0 ? 0 : (int)Math.Round(stats.XpIntoLevel * 100.0 / stats.XpForLevel);
            int goal = Math.Min(100, (int)Math.Round(stats.TodayCount * 100.0 / stats.DailyGoal));
            bool goalDone = stats.TodayCount >= stats.DailyGoal;
            string pose = goalDone ? "cheer" : stats.Streak >= 3 ? "fire" : "wave";
            StringBuilder html = new StringBuilder();
            html.Append("<section class=\"player-card\" aria-labelledby=\"player-title\">");
            html.Append("<div class=\"player-mascot\"><p class=\"speech\">").Append(E(Speech(stats))).Append("</p>").Append(MascotHelper.Render(pose)).Append("</div>");
            html.Append("<div class=\"player-main\">");
            html.Append("<p class=\"level-pill\" data-level=\"").Append(stats.Level).Append("\" data-player=\"").Append(userID).Append("\" tabindex=\"-1\">")
                .Append(UiHelper.Icon("zap")).Append("Level ").Append(stats.Level).Append(": ").Append(E(stats.LevelTitle)).Append("</p>");
            html.Append("<h1 id=\"player-title\">Welcome back, ").Append(E(firstName)).Append("</h1>");
            // Inline CSS custom property: the bar width comes from the learner's own XP.
            html.Append("<div class=\"xp-row\"><div class=\"xp-bar\" role=\"progressbar\" aria-label=\"XP towards level ").Append(stats.Level + 1)
                .Append("\" aria-valuemin=\"0\" aria-valuemax=\"").Append(stats.XpForLevel).Append("\" aria-valuenow=\"").Append(stats.XpIntoLevel)
                .Append("\"><span style=\"--p:").Append(percent).Append("%\"></span></div><span class=\"xp-text\">").Append(stats.XpIntoLevel).Append(" / ").Append(stats.XpForLevel).Append(" XP</span></div>");
            html.Append("<ul class=\"player-stats\">");
            html.Append("<li class=\"stat-flame").Append(stats.Streak > 0 ? " lit" : "").Append("\">").Append(UiHelper.Icon("flame"))
                .Append("<span><span class=\"big\" data-count-up=\"").Append(stats.Streak).Append("\">").Append(stats.Streak).Append("</span><small>day streak</small></span></li>");
            html.Append("<li><span class=\"goal-ring").Append(goalDone ? " done" : "").Append("\" style=\"--p:").Append(goal).Append("\" aria-hidden=\"true\"></span>")
                .Append("<span><span class=\"big\">").Append(Math.Min(stats.TodayCount, stats.DailyGoal)).Append("/").Append(stats.DailyGoal).Append("</span><small>daily goal</small></span></li>");
            html.Append("<li class=\"stat-xp\">").Append(UiHelper.Icon("zap"))
                .Append("<span><span class=\"big\" data-count-up=\"").Append(stats.Xp).Append("\">").Append(stats.Xp).Append("</span><small>total XP</small></span></li>");
            html.Append("<li class=\"stat-badges\">").Append(UiHelper.Icon("award"))
                .Append("<span><span class=\"big\">").Append(stats.BadgesEarned).Append("/").Append(stats.Badges.Count).Append("</span><small>badges</small></span></li>");
            html.Append("</ul></div></section>");
            // Shown by fx.js only when the level is higher than the last one seen in this browser.
            html.Append("<template id=\"levelup-template\"><div class=\"levelup\" role=\"dialog\" aria-modal=\"true\" aria-labelledby=\"levelup-title\"><div class=\"levelup-card\">")
                .Append(MascotHelper.Render("trophy")).Append("<h2 id=\"levelup-title\">Level ").Append(stats.Level).Append("!</h2><p>You are now a <strong>")
                .Append(E(stats.LevelTitle)).Append("</strong>. Keep learning to reach level ").Append(stats.Level + 1).Append(".</p>")
                .Append("<button type=\"button\" class=\"button large accent\">Keep going</button></div></div></template>");
            return html.ToString();
        }

        public static string BadgeGrid(PlayerStats stats)
        {
            StringBuilder html = new StringBuilder("<ul class=\"badge-grid\">");
            foreach (Badge badge in stats.Badges)
            {
                html.Append("<li class=\"badge-tile").Append(badge.Earned ? "" : " locked").Append("\"><span class=\"badge-medal\" aria-hidden=\"true\">")
                    .Append(UiHelper.Icon(badge.Earned ? badge.Icon : "lock")).Append("</span><strong>").Append(E(badge.Name)).Append("</strong><span>")
                    .Append(E(badge.Description)).Append("</span>");
                if (badge.Earned) html.Append("<span class=\"visually-hidden\">Earned.</span>");
                else html.Append("<progress max=\"").Append(badge.Target).Append("\" value=\"").Append(badge.Current).Append("\" aria-label=\"")
                    .Append(E(badge.Name)).Append(" progress: ").Append(badge.Current).Append(" of ").Append(badge.Target).Append("\"></progress>");
                html.Append("</li>");
            }
            return html.Append("</ul>").ToString();
        }

        // Result art for quizzes and games: Inky reacts to the score, the ring shows it, and the label shows its XP.
        // data-celebrate asks fx.js for confetti and a sound on good scores.
        // bestXp: what the learner's best result on this activity is worth, or null (previews and other people's attempts).
        // celebrate: only straight after a result is submitted, not when an old attempt is reopened.
        public static string ResultArt(decimal score, int? bestXp, bool celebrate)
        {
            string value = score.ToString("0.##", CultureInfo.InvariantCulture);
            string pose = score >= 80m ? "cheer" : score >= 50m ? "wave" : "oops";
            string party = !celebrate ? "none" : score >= 80m ? "big" : score >= 50m ? "small" : "none";
            return "<div data-celebrate=\"" + party + "\">" + MascotHelper.Render(pose) + "</div><div style=\"display:grid;justify-items:center;gap:10px\"><div class=\"score-ring\" style=\"--value:" + value + "\"><span>" + value + "%</span></div>"
                + (bestXp.HasValue ? XpEarned(bestXp.Value, 50) : "") + "</div>";
        }

        // Scenario endings: Inky's reaction depends on the outcome; a saved best ending gets confetti.
        public static string OutcomeArt(string outcome, int? bestXp, bool celebrate)
        {
            string pose = outcome == "Best" ? "trophy" : outcome == "Acceptable" ? "think" : "oops";
            string party = !celebrate ? "none" : outcome == "Best" ? "big" : outcome == "Acceptable" ? "small" : "none";
            return "<div class=\"outcome-art\" data-celebrate=\"" + party + "\">" + MascotHelper.Render(pose)
                + (bestXp.HasValue ? XpEarned(bestXp.Value, 40) : "") + "</div>";
        }

        // XP the learner's best result on an activity is worth, shown on result pages.
        public static string XpEarned(int xp, int max)
        {
            return "<p class=\"xp-earned\">" + UiHelper.Icon("zap") + "Your best here: " + xp + " of " + max + " XP</p>";
        }

        // The course as a winding path of nodes, one per lesson or activity, in course order.
        public static string Path(DataTable items, int nextIndex)
        {
            int[] offsets = { 0, 70, 110, 70, 0, -70, -110, -70 };
            StringBuilder html = new StringBuilder("<ol class=\"path\">");
            int topic = 0, step = 0;
            for (int i = 0; i < items.Rows.Count; i++)
            {
                DataRow row = items.Rows[i];
                if ((int)row["TopicID"] != topic)
                {
                    topic = (int)row["TopicID"];
                    int total = 0, done = 0;
                    foreach (DataRow other in items.Rows) if ((int)other["TopicID"] == topic) { total++; if ((bool)other["Done"]) done++; }
                    html.Append("<li class=\"path-topic\"><h3>").Append(E(row["TopicTitle"])).Append("</h3><span>").Append(done).Append(" of ").Append(total).Append(" done</span></li>");
                    step = 0;
                }
                bool isDone = (bool)row["Done"], current = i == nextIndex;
                string state = isDone ? "done" : current ? "current" : "todo";
                string type = Convert.ToString(row["ItemType"]);
                string icon = isDone ? "check" : UiHelper.TypeIcon(type);
                html.Append("<li class=\"path-node ").Append(state).Append("\" style=\"--x:").Append(offsets[step % offsets.Length]).Append("px\"><a href=\"")
                    .Append(HttpUtility.HtmlAttributeEncode(CourseHelper.Url(CourseHelper.ItemLink(row, true)))).Append("\"").Append(current ? " aria-current=\"step\"" : "").Append(">");
                if (current) html.Append("<span class=\"go-tag\" aria-hidden=\"true\">Start</span>");
                html.Append("<span class=\"node-icon\">").Append(UiHelper.Icon(icon)).Append("</span><span class=\"node-label\">").Append(E(row["Title"]))
                    .Append("<small>").Append(E(CourseHelper.ItemLabel(row))).Append(isDone ? " · done" : current ? " · up next" : "").Append("</small></span>");
                if (current) html.Append(MascotHelper.Render("point"));
                html.Append("</a></li>");
                step++;
            }
            return html.Append("</ol>").ToString();
        }
    }
}
