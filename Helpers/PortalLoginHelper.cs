using System;
using System.Data.SqlClient;
using System.Web;
using System.Web.Security;
using System.Web.UI;
namespace LearningSystem.Helpers
{
    internal static class PortalLoginHelper
    {
        internal static void Login(Page page, string email, string password, string role)
        {
            if (!page.IsValid) return;
            if (role != "Learner" && role != "Teacher" && role != "Admin") return;
            try
            {
                string message;
                int id = AccountSecurityHelper.CheckLogin(email.Trim(), password, role, out message);
                if (id == 0) { MessageHelper.SetError(message); return; }
                AuthenticationHelper.SignIn(id);
                page.Response.Redirect(ReturnUrl(page));
            }
            catch (SqlException) { MessageHelper.SetError("Sign in is unavailable. Please try again later."); }
            catch (InvalidOperationException) { MessageHelper.SetError("Your account is no longer active."); }
        }
        internal static string ReturnUrl(Page page)
        {
            if (AccountSecurityHelper.MustChange(CurrentUserHelper.GetUserID().Value)) return "~/Member/ChangePassword.aspx";
            string fallback = CurrentUserHelper.GetDashboardUrl();
            string url = page.Request.QueryString["ReturnUrl"];
            if (String.IsNullOrEmpty(url) || url.Contains("\\") || url.Contains(":") || url.Contains("\r") || url.Contains("\n")) return fallback;
            if (url.StartsWith("~/")) url = page.ResolveUrl(url);
            string root = page.Request.ApplicationPath.TrimEnd('/') + "/";
            string path = url.Split('?')[0];
            if (!path.StartsWith(root, StringComparison.OrdinalIgnoreCase) || path.StartsWith("//") || path.Contains("..") || path.Contains("%")
                || !path.EndsWith(".aspx", StringComparison.OrdinalIgnoreCase) || path.StartsWith(root+"Account/",StringComparison.OrdinalIgnoreCase)) return fallback;
            if (!UrlAuthorizationModule.CheckUrlAccessForPrincipal(path, HttpContext.Current.User, "GET")) return fallback;
            return url;
        }
    }
}
