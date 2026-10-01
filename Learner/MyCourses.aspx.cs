using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using LearningSystem.Helpers;
namespace LearningSystem.Learner
{
    public partial class MyCourses : Page
    {
        protected void Page_Load(object sender,EventArgs e)
        {
            AccessHelper.RequireRole(new[] {"Learner"});
            if(IsPostBack)return;
            try
            {
                gvCourses.DataSource=DatabaseHelper.ExecuteTable("SELECT c.CourseID,c.Title,c.Status FROM dbo.Enrolment e JOIN dbo.Course c ON c.CourseID=e.CourseID WHERE e.LearnerID=@user ORDER BY e.EnrolDate DESC,c.CourseID DESC",new[] {new SqlParameter("@user",CurrentUserHelper.GetUserID().Value)});gvCourses.DataBind();
            }
            catch(SqlException) { MessageHelper.SetError("Your courses could not be loaded."); }
        }
        protected bool CanPrint(object courseID){return ProgressHelper.CalculatePercent(CurrentUserHelper.GetUserID().Value,Convert.ToInt32(courseID))==100m;}
        protected string ProgressFor(object courseID) { return CourseHelper.Progress(CurrentUserHelper.GetUserID().Value,Convert.ToInt32(courseID)); }
        protected void CourseCommand(object sender,GridViewCommandEventArgs e)
        {
            if (!Page.IsValid) return;
            if(e.CommandName!="LeaveCourse")return;
            int courseID;
            if(!Int32.TryParse(Convert.ToString(e.CommandArgument),out courseID)||courseID<1) {Response.Redirect("~/AccessDenied.aspx");return;}
            try
            {
                using(SqlConnection connection=DatabaseHelper.OpenConnection())
                using(SqlTransaction transaction=connection.BeginTransaction(IsolationLevel.Serializable))
                {
                    int changed=DatabaseHelper.ExecuteNonQuery(connection,transaction,"DELETE e FROM dbo.Enrolment e JOIN dbo.[User] u ON u.UserID=e.LearnerID WHERE e.CourseID=@course AND e.LearnerID=@user AND u.Role='Learner' AND u.Status='Active'",new[] {new SqlParameter("@course",courseID),new SqlParameter("@user",CurrentUserHelper.GetUserID().Value)});
                    if(changed!=1) { Response.Redirect("~/AccessDenied.aspx");return; }
                    // Retain all learning records under Q31. Only the enrolment is removed.
                    transaction.Commit();
                }
                MessageHelper.SetSuccess("You left the course. Your learning records have been retained.");Response.Redirect("MyCourses.aspx");
            }
            catch(SqlException) { MessageHelper.SetError("You could not leave the course. Please try again."); }
        }
    }
}
