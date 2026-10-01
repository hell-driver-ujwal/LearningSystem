using System;
using System.Data;
using System.Data.SqlClient;
using System.Web;
namespace LearningSystem.Helpers
{
    public static class CurrentUserHelper
    {
        // Web Forms serializes requests for one session. Remove this token only after commit
        // so a double click cannot create a second course, topic or material.
        internal static string CreateEditToken()
        {
            string token = "TeacherEdit_" + Guid.NewGuid().ToString("N");
            HttpContext.Current.Session[token] = GetUserID();
            return token;
        }
        internal static bool CanSaveEdit(object token)
        {
            return token != null && Equals(HttpContext.Current.Session[(string)token], GetUserID());
        }
        internal static void CompleteEdit(object token) { HttpContext.Current.Session.Remove((string)token); }
        // Lecturers (Teacher role) and the admin can both author courses; ownership is still checked per course.
        public static readonly string[] AuthorRoles = { "Teacher", "Admin" };
        public static bool IsAuthor()
        {
            string role = GetRole();
            return role == "Teacher" || role == "Admin";
        }
        public static bool IsAuthenticated()
        {
            return HttpContext.Current.User != null && HttpContext.Current.User.Identity.IsAuthenticated;
        }
        public static int? GetUserID()
        {
            int id;
            if (IsAuthenticated() && int.TryParse(HttpContext.Current.User.Identity.Name, out id) && id > 0) return id;
            return null;
        }
        public static string GetRole()
        {
            foreach (string role in new[] { "Learner", "Teacher", "Admin" })
                if (IsAuthenticated() && HttpContext.Current.User.IsInRole(role)) return role;
            return "";
        }
        public static string GetFullName()
        {
            if (!GetUserID().HasValue) return "";
            object name = DatabaseHelper.ExecuteScalar("SELECT FullName FROM dbo.[User] WHERE UserID=@id",
                new[] { new SqlParameter("@id", SqlDbType.Int) { Value = GetUserID().Value } });
            return name == null ? "" : Convert.ToString(name);
        }
        public static bool IsActive()
        {
            if (!GetUserID().HasValue) return false;
            DataTable users = DatabaseHelper.ExecuteTable("SELECT Status, FullName FROM dbo.[User] WHERE UserID=@id AND Role=@role",
                new[] { new SqlParameter("@id", SqlDbType.Int) { Value = GetUserID().Value },
                    new SqlParameter("@role", SqlDbType.NVarChar, 7) { Value = GetRole() } });
            if (users.Rows.Count != 1 || (string)users.Rows[0]["Status"] != "Active") return false;
            // Restore the fixed session values after an application restart and refresh the display name.
            HttpContext.Current.Session["UserID"] = GetUserID().Value;
            HttpContext.Current.Session["Role"] = GetRole();
            HttpContext.Current.Session["FullName"] = (string)users.Rows[0]["FullName"];
            return true;
        }
        public static string GetDashboardUrl()
        {
            switch (GetRole())
            {
                case "Learner": return "~/Learner/Dashboard.aspx";
                case "Teacher": return "~/Teacher/Dashboard.aspx";
                case "Admin": return "~/Admin/Dashboard.aspx";
                default: return "~/Default.aspx";
            }
        }
    }
}
