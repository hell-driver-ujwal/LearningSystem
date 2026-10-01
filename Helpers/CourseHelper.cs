using System;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
namespace LearningSystem.Helpers
{
    internal static class CourseHelper
    {
        internal static DataRow Find(int courseID)
        {
            DataTable rows = DatabaseHelper.ExecuteTable("SELECT c.*,s.SubjectName,u.FullName AS TeacherName,u.Role AS TeacherRole FROM dbo.Course c JOIN dbo.Subject s ON s.SubjectID=c.SubjectID JOIN dbo.[User] u ON u.UserID=c.TeacherID WHERE c.CourseID=@id", new[] { new SqlParameter("@id", courseID) });
            return rows.Rows.Count == 1 ? rows.Rows[0] : null;
        }
        internal static int QueryID(string name)
        {
            int id;
            if (!Int32.TryParse(HttpContext.Current.Request.QueryString[name], out id) || id < 1)
                HttpContext.Current.Response.Redirect("~/NotFound.aspx");
            return id;
        }
        internal static string Encode(object value) { return HttpUtility.HtmlEncode(Convert.ToString(value, CultureInfo.InvariantCulture)); }
        internal static string Url(string path) { return VirtualPathUtility.ToAbsolute(path); }

        internal static string Progress(int learnerID, int courseID)
        {
            string percent = ProgressHelper.CalculatePercent(learnerID, courseID).ToString("0.##", CultureInfo.InvariantCulture);
            return "<span class=\"progress-row\"><progress max=\"100\" value=\"" + percent + "\" aria-label=\"Course progress\">" + percent + "%</progress> <span>" + percent + "% complete</span></span>";
        }

        // Counts shown on course cards and the course page. Only published content is counted.
        internal static DataRow Stats(int courseID)
        {
            return DatabaseHelper.ExecuteTable(@"SELECT
 (SELECT COUNT(*) FROM dbo.Topic t WHERE t.CourseID=@id) AS Topics,
 (SELECT COUNT(*) FROM dbo.Material m JOIN dbo.Topic t ON t.TopicID=m.TopicID WHERE t.CourseID=@id AND m.Status='Published') AS Lessons,
 (SELECT COUNT(*) FROM dbo.Activity a JOIN dbo.Topic t ON t.TopicID=a.TopicID WHERE t.CourseID=@id AND a.Status='Published') AS Activities,
 (SELECT COUNT(*) FROM dbo.Activity a JOIN dbo.Topic t ON t.TopicID=a.TopicID WHERE t.CourseID=@id AND a.Status='Published' AND a.ActivityType='Quiz') AS Quizzes,
 (SELECT COUNT(*) FROM dbo.Activity a JOIN dbo.Topic t ON t.TopicID=a.TopicID WHERE t.CourseID=@id AND a.Status='Published' AND a.ActivityType='Game') AS Games,
 (SELECT COUNT(*) FROM dbo.Activity a JOIN dbo.Topic t ON t.TopicID=a.TopicID WHERE t.CourseID=@id AND a.Status='Published' AND a.ActivityType='Scenario') AS Scenarios,
 (SELECT COUNT(*) FROM dbo.Material m JOIN dbo.Topic t ON t.TopicID=m.TopicID WHERE t.CourseID=@id AND m.Status='Published' AND m.MaterialType='Code') AS CodeLabs,
 (SELECT COUNT(*) FROM dbo.Material m JOIN dbo.Topic t ON t.TopicID=m.TopicID WHERE t.CourseID=@id AND m.Status='Published' AND m.MaterialType IN ('Video','Audio','YouTube')) AS MediaLessons,
 (SELECT COUNT(*) FROM dbo.Enrolment e WHERE e.CourseID=@id) AS Learners,
 (SELECT COUNT(*) FROM dbo.Review r WHERE r.CourseID=@id) AS Reviews,
 (SELECT AVG(CAST(r.Rating AS decimal(10,2))) FROM dbo.Review r WHERE r.CourseID=@id) AS Rating", new[] { new SqlParameter("@id", courseID) }).Rows[0];
        }

        internal static string CoverHtml(DataRow row, string cssClass)
        {
            if (row.IsNull("CoverImagePath"))
                return "<div class=\"cover-placeholder\" aria-hidden=\"true\">" + Encode(row["Title"]) + "</div>";
            return "<img class=\"" + cssClass + "\" src=\"" + Url("~/Media.ashx?courseId=" + row["CourseID"]) + "\" alt=\"Cover image for " + Encode(row["Title"]) + "\" loading=\"lazy\" width=\"640\" height=\"360\" />";
        }

        internal static string RatingHtml(DataRow stats)
        {
            if ((int)stats["Reviews"] == 0) return "<p class=\"course-rating muted\">No reviews yet</p>";
            string average = Convert.ToDecimal(stats["Rating"]).ToString("0.0", CultureInfo.InvariantCulture);
            return "<p class=\"course-rating\"><span class=\"star\" aria-hidden=\"true\">&#9733;</span> " + average + " <span class=\"muted\">(" + UiHelper.Plural((int)stats["Reviews"], "review") + ")</span></p>";
        }

        internal static string PriceHtml(DataRow row)
        {
            bool paid = (bool)row["IsPaid"];
            return "<p class=\"course-price" + (paid ? "" : " free") + "\">" + (paid ? Encode(UiHelper.Money((decimal)row["PriceNPR"])) : "Free") + "</p>";
        }

        internal static void Cards(PlaceHolder target, DataTable courses)
        {
            target.Controls.Clear();
            if (courses.Rows.Count == 0)
            {
                target.Controls.Add(new LiteralControl("<div class=\"empty-state\">" + UiHelper.Icon("search") + "<strong>No courses match your search</strong><p>Try a different word, choose another subject, or clear the filters to see every course.</p></div>"));
                return;
            }
            StringBuilder html = new StringBuilder("<div class=\"course-grid\">");
            foreach (DataRow row in courses.Rows)
            {
                string id = row["CourseID"].ToString();
                DataRow stats = Stats((int)row["CourseID"]);
                html.Append("<article class=\"course-card\">").Append(CoverHtml(row, "course-cover"));
                html.Append("<div class=\"course-body\"><p class=\"course-subject\">").Append(Encode(row["SubjectName"])).Append("</p>");
                html.Append("<h3><a href=\"").Append(Url("~/CourseDetails.aspx?id=" + id)).Append("\">").Append(Encode(row["Title"])).Append("</a></h3>");
                if (row.Table.Columns.Contains("TeacherName")) html.Append("<p class=\"course-teacher\">").Append(Encode(row["TeacherName"])).Append("</p>");
                html.Append("<p class=\"course-description\">").Append(Encode(row["Description"])).Append("</p>");
                html.Append("<ul class=\"course-meta\" aria-label=\"Course contents\"><li>").Append(UiHelper.Icon("book")).Append(UiHelper.Plural((int)stats["Lessons"], "lesson"))
                    .Append("</li><li>").Append(UiHelper.Icon("puzzle")).Append(UiHelper.Plural((int)stats["Activities"], "activity", "activities")).Append("</li>");
                if ((int)stats["CodeLabs"] > 0) html.Append("<li>").Append(UiHelper.Icon("code")).Append("Code labs</li>");
                html.Append("</ul><div class=\"course-foot\">").Append(PriceHtml(row)).Append(RatingHtml(stats)).Append("</div></div></article>");
            }
            html.Append("</div>"); target.Controls.Add(new LiteralControl(html.ToString()));
        }

        // Link for one published item. Learners go to the lesson or activity; visitors only see free previews.
        internal static string ItemLink(DataRow item, bool learner)
        {
            bool material = (int)item["ItemKind"] == 0;
            string type = (string)item["ItemType"];
            if (material && learner) return "~/Member/Lesson.aspx?id=" + item["ItemID"];
            if (material) return AccessHelper.CanViewFreePreview((int)item["ItemID"]) ? "~/Preview.aspx?id=" + item["ItemID"] : null;
            if (!learner) return null;
            return "~/Member/" + (type == "Game" ? "PlayGame" : type) + ".aspx?id=" + item["ItemID"];
        }

        internal static string ItemLabel(DataRow item)
        {
            string type = (string)item["ItemType"];
            if ((int)item["ItemKind"] == 1 && type == "Game" && item.Table.Columns.Contains("GameTemplate") && !item.IsNull("GameTemplate"))
                return "Game: " + GameHelper.TemplateName((string)item["GameTemplate"]).ToLowerInvariant();
            return UiHelper.TypeLabel(type);
        }

        internal static void Outline(PlaceHolder target, int courseID, bool learner)
        {
            int user = learner ? CurrentUserHelper.GetUserID().Value : 0;
            DataTable items = ProgressHelper.PublishedItems(user, courseID);
            DataTable topics = DatabaseHelper.ExecuteTable("SELECT TopicID,Title FROM dbo.Topic WHERE CourseID=@id ORDER BY SortOrder,TopicID", new[] { new SqlParameter("@id", courseID) });
            target.Controls.Clear();
            StringBuilder html = new StringBuilder();
            if (topics.Rows.Count == 0) html.Append("<div class=\"empty-state\"><strong>Content is on its way</strong><p>The lecturer has not published any topics yet.</p></div>");
            int number = 0;
            foreach (DataRow topic in topics.Rows)
            {
                number++;
                int count = 0, done = 0;
                StringBuilder list = new StringBuilder();
                foreach (DataRow item in items.Rows)
                {
                    if ((int)item["TopicID"] != (int)topic["TopicID"]) continue;
                    count++;
                    bool isDone = (bool)item["Done"];
                    if (isDone) done++;
                    string link = ItemLink(item, learner);
                    list.Append("<li>");
                    if (learner) list.Append(isDone ? "<span class=\"check\" title=\"Completed\">" + UiHelper.Icon("check") + "<span class=\"visually-hidden\">Completed: </span></span>" : "<span class=\"todo\" title=\"Not completed yet\"><span class=\"visually-hidden\">Not completed: </span></span>");
                    list.Append(UiHelper.TypeMark((string)item["ItemType"])).Append("<span class=\"item-title\">");
                    if (link != null) list.Append("<a href=\"").Append(Url(link)).Append("\">").Append(Encode(item["Title"])).Append("</a>");
                    else list.Append(Encode(item["Title"]));
                    if ((int)item["ItemKind"] == 0 && !learner && link != null) list.Append(" <span class=\"chip green\">Free preview</span>");
                    list.Append("</span><span class=\"item-type\">").Append(Encode(ItemLabel(item))).Append("</span></li>");
                }
                string summary = learner ? done + " of " + count + " done" : UiHelper.Plural(count, "item");
                html.Append("<section class=\"topic-card\"><h2 class=\"topic-head\"><span>").Append(number).Append(". ").Append(Encode(topic["Title"]))
                    .Append("</span><span class=\"muted\">").Append(summary).Append("</span></h2>");
                html.Append(count == 0 ? "<p class=\"muted\">No published items in this topic yet.</p>" : "<ul class=\"lesson-list\">" + list + "</ul>");
                html.Append("</section>");
            }
            target.Controls.Add(new LiteralControl(html.ToString()));
        }

        // The first published item the learner has not finished yet, used for "Continue learning".
        internal static DataRow NextItem(int learnerID, int courseID)
        {
            foreach (DataRow item in ProgressHelper.PublishedItems(learnerID, courseID).Rows)
                if (!(bool)item["Done"]) return item;
            return null;
        }
    }
}
