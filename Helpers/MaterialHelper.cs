using System;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
namespace LearningSystem.Helpers
{
    internal static class MaterialHelper
    {
        internal static DataRow Find(int id)
        {
            DataTable rows = DatabaseHelper.ExecuteTable("SELECT m.*,t.CourseID,t.Title AS TopicTitle,c.Status AS CourseStatus,c.Title AS CourseTitle FROM dbo.Material m JOIN dbo.Topic t ON t.TopicID=m.TopicID JOIN dbo.Course c ON c.CourseID=t.CourseID WHERE m.MaterialID=@id", new[] { new SqlParameter("@id", id) });
            return rows.Rows.Count == 1 ? rows.Rows[0] : null;
        }
        internal static bool Published(DataRow row) { return row != null && (string)row["Status"] == "Published" && (string)row["CourseStatus"] == "Published"; }
        internal static void Render(PlaceHolder target, DataRow row, bool preview)
        {
            string title = CourseHelper.Encode(row["Title"]);
            string type = (string)row["MaterialType"];
            string media = CourseHelper.Url("~/Media.ashx?materialId=" + row["MaterialID"] + (preview ? "&preview=1" : ""));
            string source = HttpUtility.HtmlAttributeEncode(media);
            string html;
            switch (type)
            {
                case "Text": html = "<div class=\"lesson-text\">" + CourseHelper.Encode(row["TextContent"]) + "</div>"; break;
                case "Image": html = "<figure><img class=\"lesson-image\" src=\"" + source + "\" alt=\"" + CourseHelper.Encode(row["AltText"]) + "\" /><figcaption>" + title + "</figcaption></figure>"; break;
                case "PDF": html = "<object class=\"pdf-viewer\" data=\"" + source + "\" type=\"application/pdf\" aria-label=\"" + title + "\"><p>Your browser cannot display this PDF. Use the download link below.</p></object><p><a href=\"" + HttpUtility.HtmlAttributeEncode(media + "&download=1") + "\">Download PDF</a></p>"; break;
                case "Video": html = "<video class=\"lesson-video\" controls preload=\"metadata\"><source src=\"" + source + "\" type=\"video/mp4\" />Your browser does not support video playback.</video>"; break;
                case "Audio": html = "<audio controls preload=\"metadata\"><source src=\"" + source + "\" type=\"audio/mpeg\" />Your browser does not support audio playback.</audio>"; break;
                case "YouTube":
                    string video = YouTubeID(Convert.ToString(row["YouTubeURL"]));
                    html = video == null ? "<p>This video link is unavailable.</p>" : "<iframe class=\"youtube-viewer\" title=\"" + title + "\" src=\"https://www.youtube-nocookie.com/embed/" + video + "\" allowfullscreen loading=\"lazy\"></iframe><p>YouTube playback requires an internet connection.</p>";
                    break;
                default: html = "<p>This material type is unavailable.</p>"; break;
            }
            target.Controls.Clear(); target.Controls.Add(new LiteralControl(html));
        }
        private static string YouTubeID(string value)
        {
            Uri uri;
            if (!Uri.TryCreate(value, UriKind.Absolute, out uri) || (uri.Scheme != "http" && uri.Scheme != "https") || uri.UserInfo != "") return null;
            string id = null;
            if ((uri.Host == "youtube.com" || uri.Host == "www.youtube.com") && uri.AbsolutePath == "/watch") id = HttpUtility.ParseQueryString(uri.Query)["v"];
            else if (uri.Host == "youtu.be" || uri.Host == "www.youtu.be") id = uri.AbsolutePath.TrimStart('/');
            return id != null && System.Text.RegularExpressions.Regex.IsMatch(id, "^[A-Za-z0-9_-]{11}$") ? id : null;
        }
    }
}

