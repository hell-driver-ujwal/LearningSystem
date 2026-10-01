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
            DataTable rows = DatabaseHelper.ExecuteTable("SELECT c.*,s.SubjectName,u.FullName AS TeacherName FROM dbo.Course c JOIN dbo.Subject s ON s.SubjectID=c.SubjectID JOIN dbo.[User] u ON u.UserID=c.TeacherID WHERE c.CourseID=@id", new[] { new SqlParameter("@id", courseID) });
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
            return "<progress max=\"100\" value=\"" + percent + "\" aria-label=\"Course progress\">" + percent + "%</progress> <span>" + percent + "% complete</span>";
        }
        internal static void Cards(PlaceHolder target, DataTable courses)
        {
            target.Controls.Clear();
            if (courses.Rows.Count == 0) { target.Controls.Add(new LiteralControl("<p>No published courses match your selection.</p>")); return; }
            StringBuilder html = new StringBuilder("<div class=\"course-grid\">");
            foreach (DataRow row in courses.Rows)
            {
                string id = row["CourseID"].ToString();
                html.Append("<article class=\"course-card\">");
                if (!row.IsNull("CoverImagePath")) html.Append("<img class=\"course-cover\" src=\"").Append(Url("~/Media.ashx?courseId=" + id)).Append("\" alt=\"").Append(Encode(row["Title"])).Append("\" />");
                else html.Append("<div class=\"cover-placeholder\">Course cover not supplied</div>");
                html.Append("<h3><a href=\"").Append(Url("~/CourseDetails.aspx?id="+id)).Append("\">").Append(Encode(row["Title"])).Append("</a></h3><p class=\"course-subject\">").Append(Encode(row["SubjectName"])).Append("</p>");
                html.Append("<p class=\"course-rating\">Rating: ").Append(Encode(ReviewHelper.Average((int)row["CourseID"]))).Append("</p>");
                html.Append("<p class=\"course-price\">").Append(Encode(PaymentHelper.Price(row))).Append("</p>");
                if(row.Table.Columns.Contains("TeacherName"))html.Append("<p class=\"course-teacher\">By ").Append(Encode(row["TeacherName"])).Append("</p>");
                html.Append("<p class=\"course-description\">").Append(Encode(row["Description"])).Append("</p><p class=\"course-action\"><a href=\"").Append(Url("~/CourseDetails.aspx?id="+id)).Append("\" aria-label=\"View course: ").Append(Encode(row["Title"])).Append("\">View course &#8594;</a></p></article>");
            }
            html.Append("</div>"); target.Controls.Add(new LiteralControl(html.ToString()));
        }
        internal static void Outline(PlaceHolder target, int courseID, bool learner)
        {
            int user = learner ? CurrentUserHelper.GetUserID().Value : 0;
            DataTable items = ProgressHelper.PublishedItems(user, courseID);
            DataTable topics = DatabaseHelper.ExecuteTable("SELECT TopicID,Title FROM dbo.Topic WHERE CourseID=@id ORDER BY SortOrder,TopicID", new[] { new SqlParameter("@id", courseID) });
            target.Controls.Clear();
            StringBuilder html = new StringBuilder();
            if (topics.Rows.Count == 0) html.Append("<p>No published learning content is available yet.</p>");
            foreach (DataRow topic in topics.Rows)
            {
                html.Append("<section class=\"topic-card\"><h2>").Append(Encode(topic["Title"])).Append("</h2><ul class=\"lesson-list\">");
                int count = 0, activities = 0;
                foreach (DataRow item in items.Rows)
                {
                    if ((int)item["TopicID"] != (int)topic["TopicID"]) continue;
                    count++; bool material = (int)item["ItemKind"] == 0;
                    if (!material) activities++;
                    html.Append("<li>");
                    if (learner) html.Append((bool)item["Done"] ? "<span aria-label=\"Completed\">&#10003;</span> " : "<span class=\"muted\">Not completed</span> ");
                    string link = null;
                    if (material && learner) link = "~/Member/Lesson.aspx?id=" + item["ItemID"];
                    else if (material && AccessHelper.CanViewFreePreview((int)item["ItemID"])) link = "~/Preview.aspx?id=" + item["ItemID"];
                    if (!material && learner && ((string)item["ItemType"] == "Quiz" || (string)item["ItemType"] == "Discussion" || (string)item["ItemType"] == "SelfAssessment" || (string)item["ItemType"] == "Scenario")) link = "~/Member/" + item["ItemType"] + ".aspx?id=" + item["ItemID"];
                    if (!material && learner && (string)item["ItemType"] == "Game") link = "~/Member/PlayGame.aspx?id=" + item["ItemID"];
                    if (link != null) html.Append("<a href=\"").Append(Url(link)).Append("\">").Append(Encode(item["Title"])).Append("</a>");
                    else html.Append(Encode(item["Title"]));
                    html.Append(" — ").Append(Encode(item["ItemType"]));
                    if (material && !learner && link != null) html.Append(" <span class=\"badge\">Free preview</span>");
                    if (!material && learner && link == null) html.Append(" <span class=\"muted\">— activity player available in a later phase</span>");
                    html.Append("</li>");
                }
                if (count == 0) html.Append("<li>No published items in this topic.</li>");
                html.Append("</ul><p>").Append(activities).Append(" published activities</p></section>");
            }
            target.Controls.Add(new LiteralControl(html.ToString()));
        }
    }
}






