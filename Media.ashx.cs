using System;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.IO;
using System.Web;
using System.Web.SessionState;
using LearningSystem.Helpers;
namespace LearningSystem
{
    public class Media : IHttpHandler, IReadOnlySessionState
    {
        public bool IsReusable { get { return false; } }
        public void ProcessRequest(HttpContext context)
        {
            context.Response.Cache.SetCacheability(HttpCacheability.NoCache);
            context.Response.Cache.SetNoStore();
            context.Response.AddHeader("X-Content-Type-Options", "nosniff");
            if (context.Request.HttpMethod != "GET" && context.Request.HttpMethod != "HEAD") { Fail(context, 405); return; }
            bool material = context.Request.QueryString["materialId"] != null;
            int id;
            string previewValue = context.Request.QueryString["preview"], downloadValue = context.Request.QueryString["download"];
            if (material == (context.Request.QueryString["courseId"] != null) || !Int32.TryParse(context.Request.QueryString[material ? "materialId" : "courseId"], out id) || id < 1
                || (previewValue != null && previewValue != "1") || (downloadValue != null && downloadValue != "1")) { Fail(context, 404); return; }
            bool preview = previewValue == "1", download = downloadValue == "1";
            try
            {
                string path, type;
                int user = CurrentUserHelper.GetUserID().GetValueOrDefault();
                if (material)
                {
                    DataRow row = MaterialHelper.Find(id);
                    if (row == null || (!MaterialHelper.Published(row) && (!preview || CurrentUserHelper.GetRole() == "Learner"))) { Fail(context, 404); return; }
                    bool allowed = preview ? AccessHelper.CanPreviewMaterial(user, id) : AccessHelper.CanViewFreePreview(id) || AccessHelper.CanAccessMaterial(user, id, false);
                    if (!allowed) { Fail(context, 403); return; }
                    type = (string)row["MaterialType"]; path = Convert.ToString(row["FilePath"]);
                }
                else
                {
                    DataRow row = CourseHelper.Find(id);
                    if (row == null || ((string)row["Status"] != "Published" && (!preview || CurrentUserHelper.GetRole() == "Learner"))) { Fail(context, 404); return; }
                    if (preview)
                    {
                        int allowed = Convert.ToInt32(DatabaseHelper.ExecuteScalar("SELECT COUNT(*) FROM dbo.[User] WHERE UserID=@user AND Status='Active' AND (Role='Admin' OR (Role='Teacher' AND UserID=@teacher))",
                            new[] { new SqlParameter("@user", user), new SqlParameter("@teacher", (int)row["TeacherID"]) }));
                        if (allowed != 1) { Fail(context, 403); return; }
                    }
                    path = Convert.ToString(row["CoverImagePath"]); type = "Image";
                }
                if (String.IsNullOrEmpty(path) || (download && type != "PDF")) { Fail(context, 404); return; }
                string physical = UploadHelper.GetValidatedPath(path);
                if (!File.Exists(physical)) { Fail(context, 404); return; }
                string mime = Mime(type, Path.GetExtension(physical).ToLowerInvariant());
                if (mime == null) { Fail(context, 404); return; }
                context.Response.ContentType = mime;
                context.Response.AddHeader("Content-Disposition", (download ? "attachment" : "inline") + "; filename=\"" + Path.GetFileName(physical) + "\"");
                SendFile(context, physical);
            }
            catch (SqlException) { Fail(context, 503); }
            catch (IOException) { Fail(context, 404); }
            catch (ArgumentException) { Fail(context, 404); }
            catch (UnauthorizedAccessException) { Fail(context, 404); }
        }
        private static string Mime(string type, string extension)
        {
            if (type == "Image")
            {
                if (extension == ".jpg" || extension == ".jpeg") return "image/jpeg";
                if (extension == ".png") return "image/png";
                if (extension == ".gif") return "image/gif";
            }
            if (type == "PDF" && extension == ".pdf") return "application/pdf";
            if (type == "Video" && extension == ".mp4") return "video/mp4";
            if (type == "Audio" && extension == ".mp3") return "audio/mpeg";
            return null;
        }
        private static void SendFile(HttpContext context, string path)
        {
            long length = new FileInfo(path).Length, start = 0, end = length - 1;
            string range = context.Request.Headers["Range"];
            context.Response.AddHeader("Accept-Ranges", "bytes");
            // A single byte range supports seeking without loading the whole video into memory.
            if (range != null)
            {
                bool valid = range.StartsWith("bytes=", StringComparison.OrdinalIgnoreCase) && !range.Contains(",");
                string[] parts = valid ? range.Substring(6).Split('-') : new string[0];
                valid = valid && parts.Length == 2;
                long number;
                if (valid && parts[0] == "")
                {
                    valid = Int64.TryParse(parts[1], out number) && number > 0;
                    if (valid) start = Math.Max(0, length - number);
                }
                else if (valid)
                {
                    valid = Int64.TryParse(parts[0], out start) && start >= 0;
                    if (valid && parts[1] != "") { valid = Int64.TryParse(parts[1], out end); end = Math.Min(end, length - 1); }
                }
                if (!valid || length == 0 || start >= length || end < start)
                { context.Response.AddHeader("Content-Range", "bytes */" + length); Fail(context, 416); return; }
                context.Response.StatusCode = 206;
                context.Response.AddHeader("Content-Range", "bytes " + start + "-" + end + "/" + length);
            }
            long count = length == 0 ? 0 : end - start + 1;
            context.Response.AddHeader("Content-Length", count.ToString(CultureInfo.InvariantCulture));
            if (context.Request.HttpMethod != "HEAD" && count > 0) context.Response.TransmitFile(path, start, count);
        }
        private static void Fail(HttpContext context, int status)
        {
            context.Response.StatusCode = status;
            context.Response.TrySkipIisCustomErrors = true;
            context.Response.SuppressFormsAuthenticationRedirect = true;
            context.Response.ContentType = "text/plain";
            if (context.Request.HttpMethod != "HEAD") context.Response.Write(status == 403 ? "Access denied." : status == 503 ? "Media is temporarily unavailable." : "Media not found or request not supported.");
        }
    }
}

