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
                case "Text": html = "<div class=\"lesson-text\">" + LessonFormatter.ToHtml(Convert.ToString(row["TextContent"])) + "</div>"; break;
                case "Code":
                    // The code is only HTML-encoded into a textarea and run inside a sandboxed frame by Scripts/site.js.
                    // The textarea has no name, so it is never posted back to the server.
                    html = "<div class=\"code-lab\" data-codelab=\"true\"><div class=\"code-lab-bar\"><span class=\"code-lab-label\">Try it yourself</span>"
                        + "<span class=\"code-lab-actions\"><button type=\"button\" class=\"button small\" data-run>Run code</button><button type=\"button\" class=\"button small secondary\" data-reset>Reset</button></span></div>"
                        + "<div class=\"code-lab-panes\"><label class=\"visually-hidden\" for=\"codelab-" + row["MaterialID"] + "\">Code editor for " + title + "</label>"
                        + "<textarea id=\"codelab-" + row["MaterialID"] + "\" class=\"code-lab-editor\" spellcheck=\"false\" autocapitalize=\"off\" autocomplete=\"off\">" + CourseHelper.Encode(row["TextContent"]) + "</textarea>"
                        + "<iframe class=\"code-lab-output\" title=\"Result of the code for " + title + "\" sandbox=\"allow-scripts allow-modals\"></iframe></div>"
                        + "<p class=\"hint\">Edit the code, then choose Run code to see the result. Tab indents; press Escape then Tab to leave the editor. Changes are not saved.</p></div>";
                    break;
                case "Image": html = "<figure><img class=\"lesson-image\" src=\"" + source + "\" alt=\"" + CourseHelper.Encode(row["AltText"]) + "\" /><figcaption>" + title + "</figcaption></figure>"; break;
                case "PDF": html = "<object class=\"pdf-viewer\" data=\"" + source + "\" type=\"application/pdf\" aria-label=\"" + title + "\"><p>Your browser cannot display this PDF. Use the download link below.</p></object><p><a href=\"" + HttpUtility.HtmlAttributeEncode(media + "&download=1") + "\">Download PDF</a></p>"; break;
                case "Video":
                    html = "<video class=\"lesson-video\" controls preload=\"metadata\"><source src=\"" + source + "\" type=\"video/mp4\" />" + CaptionTrack(row, media)
                        + "Your browser does not support video playback.</video>";
                    break;
                case "Audio": html = "<audio controls preload=\"metadata\"><source src=\"" + source + "\" type=\"audio/mpeg\" />Your browser does not support audio playback.</audio>"; break;
                case "YouTube":
                    string video = YouTubeID(Convert.ToString(row["YouTubeURL"]));
                    html = video == null ? "<p>This video link is unavailable.</p>" : "<iframe class=\"youtube-viewer\" title=\"" + title + "\" src=\"https://www.youtube-nocookie.com/embed/" + video + "\" allowfullscreen loading=\"lazy\"></iframe><p>YouTube playback requires an internet connection.</p>";
                    break;
                default: html = "<p>This material type is unavailable.</p>"; break;
            }
            target.Controls.Clear(); target.Controls.Add(new LiteralControl(html));
        }
        // Adds an English caption track when a .vtt file with the same name sits beside the video.
        private static string CaptionTrack(DataRow row, string media)
        {
            try
            {
                string physical = UploadHelper.GetValidatedPath(Convert.ToString(row["FilePath"]));
                if (!System.IO.File.Exists(System.IO.Path.ChangeExtension(physical, ".vtt"))) return "";
                return "<track kind=\"captions\" srclang=\"en\" label=\"English\" default src=\"" + HttpUtility.HtmlAttributeEncode(media + "&captions=1") + "\" />";
            }
            catch (ArgumentException) { return ""; }
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

