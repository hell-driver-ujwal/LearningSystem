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
            Group("Explore", new[] { "Home", "Course catalogue", "Free courses", "About us", "Help and FAQ", "Contact us" }, new[] { "Default.aspx", "Courses.aspx", "Courses.aspx?price=free", "About.aspx", "Help.aspx", "Contact.aspx" });
            Group("Legal", new[] { "Privacy policy", "Terms of use" }, new[] { "Privacy.aspx", "Terms.aspx" });
            string role = CurrentUserHelper.GetRole();
            if (role == "") Group("Account", new[] { "Log in", "Create a learner account", "Apply to teach" }, new[] { "Account/Login.aspx", "Account/Register.aspx", "Account/Register.aspx?as=lecturer" });
            else
            {
                AccessHelper.RequireRole(new[] { "Learner", "Teacher", "Admin" });
                Group("Account", new[] { "Profile", "Change password", "Log out" }, new[] { "Member/Profile.aspx", "Member/ChangePassword.aspx", "Account/Logout.aspx" });
                if (role == "Learner") Group("Learner", new[] { "Dashboard", "My courses", "My results", "My bookmarks", "My payments" }, new[] { "Learner/Dashboard.aspx", "Learner/MyCourses.aspx", "Learner/MyResults.aspx", "Learner/MyBookmarks.aspx", "Learner/MyPayments.aspx" });
                if (role == "Teacher") Group("Lecturer", new[] { "Dashboard", "My courses", "Create course", "Results" }, new[] { "Teacher/Dashboard.aspx", "Teacher/MyCourses.aspx", "Teacher/CourseEdit.aspx", "Teacher/Results.aspx" });
                if (role == "Admin") Group("Administration", new[] { "Dashboard", "Users", "Create user", "Lecturer applications", "Subjects", "All courses", "Activities", "My courses (authoring)", "Create course", "Messages", "FAQs", "Payments", "Analytics" }, new[] { "Admin/Dashboard.aspx", "Admin/Users.aspx", "Admin/UserEdit.aspx", "Admin/TeacherApplications.aspx", "Admin/Subjects.aspx", "Admin/Courses.aspx", "Admin/Activities.aspx", "Teacher/MyCourses.aspx", "Teacher/CourseEdit.aspx", "Admin/Messages.aspx", "Admin/FAQ.aspx", "Admin/Payments.aspx", "Admin/Analytics.aspx" });
            }
            litLinks.Text = links.ToString();
        }
        private void Group(string title, string[] names, string[] urls)
        {
            links.Append("<section class=\"card\"><h2>" + title + "</h2><ul>");
            for (int i = 0; i < names.Length; i++) links.Append("<li><a href=\"" + HttpUtility.HtmlAttributeEncode(ResolveUrl("~/" + urls[i])) + "\">" + HttpUtility.HtmlEncode(names[i]) + "</a></li>");
            links.Append("</ul></section>");
        }
    }
}
