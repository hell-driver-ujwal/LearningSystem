using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using LearningSystem.Helpers;
namespace LearningSystem.Learner
{
    public partial class Certificate : Page
    {
        protected void Page_Load(object sender,EventArgs e)
        {
            AccessHelper.RequireRole(new[] {"Learner"});
            int course=CourseHelper.QueryID("id"),user=CurrentUserHelper.GetUserID().Value;
            try
            {
                DataRow row=CourseHelper.Find(course);
                if(row==null || (string)row["Status"]!="Published"){Response.Redirect("~/NotFound.aspx");return;}
                if(!AccessHelper.IsEnrolled(user,course) || ProgressHelper.CalculatePercent(user,course)!=100m){Response.Redirect("~/AccessDenied.aspx");return;}
                litLearner.Text=CurrentUserHelper.GetFullName();litCourse.Text=(string)row["Title"];litTeacher.Text=(string)row["TeacherName"];litDate.Text=DateTime.UtcNow.ToString("d MMMM yyyy",System.Globalization.CultureInfo.InvariantCulture);Title="Certificate: "+row["Title"];
            }
            catch(SqlException){Response.Redirect("~/Error.aspx");}
        }
    }
}
