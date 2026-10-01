using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using LearningSystem.Helpers;

namespace LearningSystem.Admin
{
    public partial class Dashboard : Page
    {

        protected void Page_Load(object sender, EventArgs e)
        {
            AccessHelper.RequireRole(new[] { "Admin" });
            if (IsPostBack) return;
            try
            {
                litUnread.Text=Convert.ToString(DatabaseHelper.ExecuteScalar("SELECT COUNT(*) FROM dbo.ContactMessage WHERE IsRead=0",null));
                gvRoles.DataSource = DatabaseHelper.ExecuteTable("SELECT r.Role,COUNT(u.UserID) AS UserCount FROM (VALUES ('Learner'),('Teacher'),('Admin')) r(Role) LEFT JOIN dbo.[User] u ON u.Role=r.Role GROUP BY r.Role ORDER BY r.Role", null);
                gvRoles.DataBind();
                litCharts.Text = ChartHelper.Bars("Users by role", (DataTable)gvRoles.DataSource, "Role", "UserCount");
                gvSubjects.DataSource = DatabaseHelper.ExecuteTable("SELECT s.SubjectName,COUNT(c.CourseID) AS CourseCount FROM dbo.Subject s LEFT JOIN dbo.Course c ON c.SubjectID=s.SubjectID GROUP BY s.SubjectID,s.SubjectName ORDER BY s.SubjectName", null);
                gvSubjects.DataBind();
                litCharts.Text += ChartHelper.Bars("Courses per subject", (DataTable)gvSubjects.DataSource, "SubjectName", "CourseCount");
                litPending.Text = Convert.ToString(DatabaseHelper.ExecuteScalar("SELECT COUNT(*) FROM dbo.[User] WHERE Role='Teacher' AND Status='Pending'", null));
                litAttempts.Text = Convert.ToString(DatabaseHelper.ExecuteScalar("SELECT COUNT(*) FROM dbo.Attempt", null));
            }
            catch (SqlException) { MessageHelper.SetError("Statistics could not be loaded. Please try again."); }
        }
    }
}
