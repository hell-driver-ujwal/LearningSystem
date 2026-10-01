using System;
using System.Web;
using System.Web.UI;
using LearningSystem.Helpers;
namespace LearningSystem.Account {
 public partial class Login : Page {
  protected void Page_Load(object sender, EventArgs e) {
   if(CurrentUserHelper.IsAuthenticated()) Response.Redirect(CurrentUserHelper.GetDashboardUrl());
   if(Request.QueryString["inactive"]=="1") MessageHelper.SetError("Your account is no longer active.");
   string query="?ReturnUrl="+HttpUtility.UrlEncode(Request.QueryString["ReturnUrl"] ?? "");
   lnkStudent.NavigateUrl="StudentLogin.aspx"+query;lnkTeacher.NavigateUrl="TeacherLogin.aspx"+query;lnkAdmin.NavigateUrl="AdminLogin.aspx"+query;
  }
 }
}