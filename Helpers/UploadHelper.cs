using System;
using System.IO;
using System.Web;

namespace LearningSystem.Helpers
{
    public static class UploadHelper
    {
        public static ValidationResult Validate(HttpPostedFile file, string materialType, bool isCourseCover)
        {
            if (file == null || file.ContentLength <= 0)
                return new ValidationResult { IsValid = false, Message = "Choose a nonempty file." };
            string extension = Path.GetExtension(file.FileName).ToLowerInvariant();
            int limit = 0;
            bool allowed = false;
            if (materialType == "Image")
            {
                limit = 2 * 1024 * 1024;
                allowed = extension == ".jpg" || extension == ".jpeg" || extension == ".png" || (!isCourseCover && extension == ".gif");
            }
            else if (!isCourseCover && materialType == "PDF") { limit = 10 * 1024 * 1024; allowed = extension == ".pdf"; }
            else if (!isCourseCover && materialType == "Video") { limit = 25 * 1024 * 1024; allowed = extension == ".mp4"; }
            else if (!isCourseCover && materialType == "Audio") { limit = 10 * 1024 * 1024; allowed = extension == ".mp3"; }
            return new ValidationResult { IsValid = allowed && file.ContentLength <= limit,
                Message = "Choose an allowed file: image up to 2 MB (covers JPG/PNG), PDF or MP3 up to 10 MB, or MP4 up to 25 MB." };
        }
        public static string Save(HttpPostedFile file, string materialType, bool isCourseCover)
        {
            ValidationResult check = Validate(file, materialType, isCourseCover);
            if (!check.IsValid) throw new ArgumentException(check.Message);
            string folder = materialType == "Image" ? "Images" : materialType == "PDF" ? "Documents" : materialType;
            string relative = "~/Uploads/" + folder + "/" + Guid.NewGuid().ToString("D") + Path.GetExtension(file.FileName).ToLowerInvariant();
            string path = GetValidatedPath(relative);
            Directory.CreateDirectory(Path.GetDirectoryName(path));
            try { file.SaveAs(path); }
            catch
            {
                Cleanup(relative);
                throw;
            }
            return relative;
        }
        internal static string Cleanup(string path)
        {
            if (String.IsNullOrEmpty(path)) return "";
            GetValidatedPath(path);
            ValidationResult result = DeleteHelper.CleanupFiles(new System.Collections.Generic.List<string> { path });
            return result.Message.Contains("manual cleanup") ? result.Message : "";
        }
        // Validate before SQL deletion as well as immediately before touching disk.
        internal static string GetValidatedPath(string appRelativePath)
        {
            if (String.IsNullOrEmpty(appRelativePath)) return null;
            string[] parts = appRelativePath.Split('/');
            if (parts.Length != 4 || parts[0] != "~" || parts[1] != "Uploads")
                throw new ArgumentException("Invalid upload path.");
            string extension = Path.GetExtension(parts[3]).ToLowerInvariant();
            Guid fileID;
            if (!Guid.TryParseExact(Path.GetFileNameWithoutExtension(parts[3]), "D", out fileID))
                throw new ArgumentException("Invalid upload filename.");
            bool allowed = (parts[2] == "Images" && (extension == ".jpg" || extension == ".jpeg" || extension == ".png" || extension == ".gif"))
                || (parts[2] == "Documents" && extension == ".pdf")
                || (parts[2] == "Video" && extension == ".mp4")
                || (parts[2] == "Audio" && extension == ".mp3");
            if (!allowed) throw new ArgumentException("Invalid upload folder or extension.");
            string root = Path.GetFullPath(HttpContext.Current.Server.MapPath("~/Uploads/" + parts[2]));
            string path = Path.GetFullPath(Path.Combine(root, parts[3]));
            if (!path.StartsWith(root + Path.DirectorySeparatorChar, StringComparison.OrdinalIgnoreCase))
                throw new ArgumentException("Invalid upload path.");
            // Refuse redirected directories/files so cleanup cannot escape the upload roots.
            string uploads = HttpContext.Current.Server.MapPath("~/Uploads");
            foreach (string candidate in new[] { uploads, root, path })
                if ((Directory.Exists(candidate) || File.Exists(candidate))
                    && (File.GetAttributes(candidate) & FileAttributes.ReparsePoint) != 0)
                    throw new ArgumentException("Redirected upload paths are not supported.");
            return path;
        }

        public static void Delete(string appRelativePath)
        {
            string path = GetValidatedPath(appRelativePath);
            if (path != null) File.Delete(path);
        }
    }
}
