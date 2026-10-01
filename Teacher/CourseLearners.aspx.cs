using System;
using System.Data.SqlClient;
using System.Web.UI;
using LearningSystem.Helpers;
namespace LearningSystem.Teacher
{
    public partial class CourseLearners : Page
    {
        protected void Page_Load(object sender,EventArgs e)
        {
            AccessHelper.RequireRole(new[] {"Teacher"});int id=CourseHelper.QueryID("id");
            try
            {
                if(!AccessHelper.IsOwnerOfCourse(CurrentUserHelper.GetUserID().Value,id)){Response.Redirect("~/AccessDenied.aspx");return;}
                ((SiteMaster)Master).Breadcrumb=BreadcrumbHelper.ForCourse(id);
                litCourse.Text=Convert.ToString(DatabaseHelper.ExecuteScalar("SELECT Title FROM dbo.Course WHERE CourseID=@id AND TeacherID=@user",new[] {new SqlParameter("@id",id),new SqlParameter("@user",CurrentUserHelper.GetUserID().Value)}));
                // Project names only: email addresses never enter this page's data source or ViewState.
                gvLearners.DataSource=DatabaseHelper.ExecuteTable("SELECT u.FullName FROM dbo.Enrolment e JOIN dbo.[User] u ON u.UserID=e.LearnerID JOIN dbo.Course c ON c.CourseID=e.CourseID WHERE c.CourseID=@id AND c.TeacherID=@user ORDER BY u.FullName,u.UserID",new[] {new SqlParameter("@id",id),new SqlParameter("@user",CurrentUserHelper.GetUserID().Value)});gvLearners.DataBind();
                lnkResults.NavigateUrl="Results.aspx?courseId="+id;lnkBack.NavigateUrl="CourseBuilder.aspx?id="+id;
            }
            catch(SqlException){MessageHelper.SetError("Enrolled learners could not be loaded. Please try again.");}
        }
    }
}
