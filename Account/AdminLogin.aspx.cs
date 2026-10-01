using System;
using System.Web.UI;
using LearningSystem.Helpers;
namespace LearningSystem.Account {
 public partial class AdminLogin : Page {
  protected void Page_Load(object sender, EventArgs e) {
   if(CurrentUserHelper.IsAuthenticated()) Response.Redirect(CurrentUserHelper.GetDashboardUrl());
  }
  protected void btnLogin_Click(object sender, EventArgs e) {
   if (!Page.IsValid) return;
   PortalLoginHelper.Login(this,txtEmail.Text,txtPassword.Text,"Admin");
  }
 }
}
