using System;
using System.Text;
using System.Web;
using System.Web.UI;
using LearningSystem.Helpers;
namespace LearningSystem
{
    public partial class SiteMapPage : Page
    {
        private readonly StringBuilder links = new StringBuilder();
        protected void Page_Load(object sender, EventArgs e)
        {
            Group("Public", new[] { "Home", "About", "Courses", "Help", "Contact" }, new[] { "Default.aspx", "About.aspx", "Courses.aspx", "Help.aspx", "Contact.aspx" });
            string role = CurrentUserHelper.GetRole();
            if (role == "") Group("Account", new[] { "Log in", "Register" }, new[] { "Account/Login.aspx", "Account/Register.aspx" });
            else
            {
                AccessHelper.RequireRole(new[] { "Learner", "Teacher", "Admin" });
                Group("Account", new[] { "Profile", "Change password", "Log out" }, new[] { "Member/Profile.aspx", "Member/ChangePassword.aspx", "Account/Logout.aspx" });
                if (role == "Learner") Group("Learner", new[] { "Dashboard", "My courses", "My results", "My bookmarks", "My payments" }, new[] { "Learner/Dashboard.aspx", "Learner/MyCourses.aspx", "Learner/MyResults.aspx", "Learner/MyBookmarks.aspx", "Learner/MyPayments.aspx" });
                if (role == "Teacher") Group("Teacher", new[] { "Dashboard", "My courses", "Create course", "Results" }, new[] { "Teacher/Dashboard.aspx", "Teacher/MyCourses.aspx", "Teacher/CourseEdit.aspx", "Teacher/Results.aspx" });
                if (role == "Admin") Group("Admin", new[] { "Dashboard", "Users", "Create user", "Teacher applications", "Subjects", "Courses", "Activities", "Messages", "FAQs", "Payments" }, new[] { "Admin/Dashboard.aspx", "Admin/Users.aspx", "Admin/UserEdit.aspx", "Admin/TeacherApplications.aspx", "Admin/Subjects.aspx", "Admin/Courses.aspx", "Admin/Activities.aspx", "Admin/Messages.aspx", "Admin/FAQ.aspx", "Admin/Payments.aspx" });
            }
            litLinks.Text = links.ToString();
        }
        private void Group(string title, string[] names, string[] urls)
        {
            links.Append("<section class=\"form-card\"><h2>" + title + "</h2><ul>");
            for (int i = 0; i < names.Length; i++) links.Append("<li><a href=\"" + HttpUtility.HtmlAttributeEncode(ResolveUrl("~/" + urls[i])) + "\">" + HttpUtility.HtmlEncode(names[i]) + "</a></li>");
            links.Append("</ul></section>");
        }
    }
}
