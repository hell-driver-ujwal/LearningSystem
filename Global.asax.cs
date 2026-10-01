using System;
using System.Web;
using System.Web.Security;
using LearningSystem.Helpers;
namespace LearningSystem
{
    public class Global : HttpApplication
    {
        protected void Application_BeginRequest(object sender, EventArgs e)
        {
            if (!Request.IsSecureConnection)
            {
                // Fixed, explicitly configured demo origin: never derive it from Host.
                string origin = System.Configuration.ConfigurationManager.AppSettings["HttpsOrigin"];
                Response.Redirect(origin.TrimEnd('/') + Request.Url.PathAndQuery, false);
                CompleteRequest();
            }
        }
        protected void Application_PostAuthenticateRequest(object sender, EventArgs e)
        {
            AuthenticationHelper.AttachRole(Context);
            if (Request.IsAuthenticated)
            {
                try
                {
                    int userID;
                    if (Int32.TryParse(Context.User.Identity.Name, out userID))
                    {
                        bool mustChange = AccountSecurityHelper.MustChange(userID);
                        if (mustChange && !AccountSecurityHelper.IsException(Request.AppRelativeCurrentExecutionFilePath))
                        {
                            Response.Redirect("~/Member/ChangePassword.aspx", false);
                            CompleteRequest();
                            return;
                        }
                    }
                }
                catch (System.Data.SqlClient.SqlException)
                {
                    // Fail closed without looping on the friendly error page.
                    if (!Request.AppRelativeCurrentExecutionFilePath.Equals("~/Error.aspx", StringComparison.OrdinalIgnoreCase))
                    { Response.Redirect("~/Error.aspx", false); CompleteRequest(); return; }
                }
            }
            // Check the same web.config rules before Forms Authentication can convert a 401 to Login.
            if (Request.IsAuthenticated && !UrlAuthorizationModule.CheckUrlAccessForPrincipal(Request.Path, Context.User, Request.HttpMethod))
            {
                Response.Redirect("~/AccessDenied.aspx", false);
                CompleteRequest();
            }
        }
        protected void Application_EndRequest(object sender, EventArgs e)
        {
            // Wrong roles need Access Denied, rather than another Login redirect.
            if (Response.StatusCode == 401 && Request.IsAuthenticated)
            {
                Response.SuppressFormsAuthenticationRedirect = true;
                Response.Redirect("~/AccessDenied.aspx", false);
                CompleteRequest();
            }
        }
    }
}
