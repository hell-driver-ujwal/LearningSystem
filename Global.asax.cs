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
        // Users only ever see the friendly Error page. The technical details go to a private
        // log in App_Data (never served to the browser) so the team can find and fix the problem.
        protected void Application_Error(object sender, EventArgs e)
        {
            Exception error = Server.GetLastError();
            // Missing pages are normal (the custom 404 page handles them), so they are not logged.
            if (error == null || (error is HttpException && ((HttpException)error).GetHttpCode() == 404)) return;
            try
            {
                string line = DateTime.UtcNow.ToString("s") + " UTC " + Request.HttpMethod + " " + Request.Url.AbsolutePath + Environment.NewLine + error + Environment.NewLine + Environment.NewLine;
                System.IO.File.AppendAllText(Server.MapPath("~/App_Data/ErrorLog.txt"), line);
            }
            catch (System.IO.IOException) { }
            catch (UnauthorizedAccessException) { }
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
