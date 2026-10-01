using System;
using System.Web.UI;
using LearningSystem.Helpers;

namespace LearningSystem
{
    public partial class AccessDenied : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            Response.StatusCode = 403;
            Response.TrySkipIisCustomErrors = true;
            lnkDashboard.Visible = CurrentUserHelper.IsAuthenticated();
            lnkDashboard.NavigateUrl = CurrentUserHelper.GetDashboardUrl();
        }
    }
}
