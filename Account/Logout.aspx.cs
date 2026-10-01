using System;
using System.Web.UI;
using LearningSystem.Helpers;
namespace LearningSystem.Account
{
    public partial class Logout : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            AuthenticationHelper.SignOut();
            Response.Redirect("~/Default.aspx");
        }
    }
}
