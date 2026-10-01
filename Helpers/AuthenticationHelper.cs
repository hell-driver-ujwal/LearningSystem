using System;
using System.Data;
using System.Data.SqlClient;
using System.Security.Principal;
using System.Threading;
using System.Web;
using System.Web.Security;
namespace LearningSystem.Helpers
{
    public static class AuthenticationHelper
    {
        public static void SignIn(int userID)
        {
            DataTable users = DatabaseHelper.ExecuteTable("SELECT FullName, Role, Status FROM dbo.[User] WHERE UserID=@id",
                new[] { new SqlParameter("@id", SqlDbType.Int) { Value = userID } });
            if (users.Rows.Count != 1 || (string)users.Rows[0]["Status"] != "Active")
                throw new InvalidOperationException("This account is not active.");
            string role = (string)users.Rows[0]["Role"];
            HttpContext context = HttpContext.Current;
            context.Session.Clear();
            context.Session["UserID"] = userID;
            context.Session["Role"] = role;
            context.Session["FullName"] = (string)users.Rows[0]["FullName"];
            FormsAuthenticationTicket ticket = new FormsAuthenticationTicket(1, userID.ToString(), DateTime.Now,
                DateTime.Now.AddMinutes(30), false, role, FormsAuthentication.FormsCookiePath);
            context.Response.Cookies.Add(new HttpCookie(FormsAuthentication.FormsCookieName, FormsAuthentication.Encrypt(ticket))
            {
                HttpOnly = true, Secure = FormsAuthentication.RequireSSL, SameSite = SameSiteMode.Lax,
                Path = FormsAuthentication.FormsCookiePath
            });
            context.User = new GenericPrincipal(new FormsIdentity(ticket), new[] { role });
            Thread.CurrentPrincipal = context.User;
        }
        public static void SignOut()
        {
            FormsAuthentication.SignOut();
            HttpContext context = HttpContext.Current;
            context.Session.Clear();
            context.Session.Abandon();
            context.Response.Cookies.Add(new HttpCookie("ASP.NET_SessionId", "")
            { Expires = DateTime.Now.AddDays(-1), HttpOnly = true, Path = "/" });
            context.User = new GenericPrincipal(new GenericIdentity(""), new string[0]);
            Thread.CurrentPrincipal = context.User;
        }
        public static void AttachRole(HttpContext context)
        {
            FormsIdentity identity = context.User == null ? null : context.User.Identity as FormsIdentity;
            if (identity == null || identity.Ticket.Expired) return;
            string role = identity.Ticket.UserData;
            if (role != "Learner" && role != "Teacher" && role != "Admin") return;
            context.User = new GenericPrincipal(identity, new[] { role });
            Thread.CurrentPrincipal = context.User;
        }
    }
}
