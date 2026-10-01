using System;
using System.Data.SqlClient;
using System.Web.UI;
using LearningSystem.Helpers;
namespace LearningSystem.Teacher
{
    public partial class Dashboard : Page
    {
        protected void Page_Load(object sender,EventArgs e)
        {
            AccessHelper.RequireRole(new[] {"Teacher"});int user=CurrentUserHelper.GetUserID().Value;
            try
            {
                litCourses.Text=Convert.ToString(DatabaseHelper.ExecuteScalar("SELECT COUNT(*) FROM dbo.Course WHERE TeacherID=@user",new[] {new SqlParameter("@user",user)}));
                litLearners.Text=Convert.ToString(DatabaseHelper.ExecuteScalar("SELECT COUNT(DISTINCT e.LearnerID) FROM dbo.Enrolment e JOIN dbo.Course c ON c.CourseID=e.CourseID WHERE c.TeacherID=@user",new[] {new SqlParameter("@user",user)}));
                gvResults.DataSource=ResultsHelper.Attempts(true,0,0,5);gvResults.DataBind();
            }
            catch(SqlException){MessageHelper.SetError("Your dashboard is temporarily unavailable.");}
        }
    }
}
