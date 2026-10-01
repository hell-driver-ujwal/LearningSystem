using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using LearningSystem.Helpers;
namespace LearningSystem
{
    public partial class _Default : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            lnkRegister.Visible = !CurrentUserHelper.IsAuthenticated();
            try
            {
                DataTable subjects = DatabaseHelper.ExecuteTable("SELECT s.SubjectID,s.SubjectName,COUNT(c.CourseID) AS CourseCount FROM dbo.Subject s LEFT JOIN dbo.Course c ON c.SubjectID=s.SubjectID AND c.Status='Published' GROUP BY s.SubjectID,s.SubjectName ORDER BY s.SubjectName", null);
                rptSubjects.DataSource = subjects; rptSubjects.DataBind(); lblNoSubjects.Visible = subjects.Rows.Count == 0;
                CourseHelper.Cards(phCourses, DatabaseHelper.ExecuteTable("SELECT TOP (6) c.IsPaid,c.PriceNPR,c.CourseID,c.Title,c.Description,c.CoverImagePath,s.SubjectName,u.FullName AS TeacherName FROM dbo.Course c JOIN dbo.Subject s ON s.SubjectID=c.SubjectID JOIN dbo.[User] u ON u.UserID=c.TeacherID WHERE c.Status='Published' ORDER BY c.CreatedDate DESC,c.CourseID DESC", null));
            }
            catch (SqlException) { MessageHelper.SetError("Courses are temporarily unavailable. Please try again later."); }
        }
    }
}

