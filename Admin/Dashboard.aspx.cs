using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
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
                litLearners.Text = Count("SELECT COUNT(*) FROM dbo.[User] WHERE Role='Learner' AND Status='Active'");
                litLecturers.Text = Count("SELECT COUNT(*) FROM dbo.[User] WHERE Role='Teacher' AND Status='Active'");
                litPending.Text = Count("SELECT COUNT(*) FROM dbo.[User] WHERE Role='Teacher' AND Status='Pending'");
                litCourses.Text = Count("SELECT COUNT(*) FROM dbo.Course WHERE Status='Published'");
                litAttempts.Text = Count("SELECT COUNT(*) FROM dbo.Attempt");
                litUnread.Text = Count("SELECT COUNT(*) FROM dbo.ContactMessage WHERE IsRead=0");
                litViews.Text = Count("SELECT COUNT(*) FROM dbo.PageView WHERE ViewedAt >= CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))");
                gvRoles.DataSource = DatabaseHelper.ExecuteTable("SELECT CASE r.Role WHEN 'Teacher' THEN 'Lecturer' WHEN 'Admin' THEN 'Administrator' ELSE r.Role END AS Role,COUNT(u.UserID) AS UserCount FROM (VALUES ('Learner'),('Teacher'),('Admin')) r(Role) LEFT JOIN dbo.[User] u ON u.Role=r.Role GROUP BY r.Role ORDER BY r.Role", null);
                gvRoles.DataBind();
                litCharts.Text = ChartHelper.Bars("Users by role", (DataTable)gvRoles.DataSource, "Role", "UserCount");
                gvSubjects.DataSource = DatabaseHelper.ExecuteTable("SELECT s.SubjectName,COUNT(c.CourseID) AS CourseCount FROM dbo.Subject s LEFT JOIN dbo.Course c ON c.SubjectID=s.SubjectID GROUP BY s.SubjectID,s.SubjectName ORDER BY s.SubjectName", null);
                gvSubjects.DataBind();
                litCharts.Text += ChartHelper.Bars("Courses per subject", (DataTable)gvSubjects.DataSource, "SubjectName", "CourseCount");
                gvRecent.DataSource = DatabaseHelper.ExecuteTable("SELECT TOP (5) FullName,Role,Status,CreatedDate FROM dbo.[User] ORDER BY CreatedDate DESC,UserID DESC", null);
                gvRecent.DataBind();
            }
            catch (SqlException) { MessageHelper.SetError("Statistics could not be loaded. Please try again."); }
        }

        private static string Count(string sql)
        {
            return Convert.ToString(DatabaseHelper.ExecuteScalar(sql, null));
        }
    }
}
