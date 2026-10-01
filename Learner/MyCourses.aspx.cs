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
                DataTable courses=DatabaseHelper.ExecuteTable("SELECT c.CourseID,c.Title,c.Status,c.CoverImagePath,s.SubjectName FROM dbo.Enrolment e JOIN dbo.Course c ON c.CourseID=e.CourseID JOIN dbo.Subject s ON s.SubjectID=c.SubjectID WHERE e.LearnerID=@user ORDER BY e.EnrolDate DESC,c.CourseID DESC",new[] {new SqlParameter("@user",CurrentUserHelper.GetUserID().Value)});
                rptCourses.DataSource=courses;rptCourses.DataBind();lblEmpty.Visible=courses.Rows.Count==0;
            }
            catch(SqlException) { MessageHelper.SetError("Your courses could not be loaded."); }
        }
        protected bool CanPrint(object courseID){return ProgressHelper.CalculatePercent(CurrentUserHelper.GetUserID().Value,Convert.ToInt32(courseID))==100m;}
        protected string CourseCover(object item){return CourseHelper.CoverHtml(((DataRowView)item).Row,"course-cover");}
        protected string CourseTitle(object item)
        {
            DataRow row=((DataRowView)item).Row;
            if((string)row["Status"]!="Published")return CourseHelper.Encode(row["Title"]);
            return "<a href=\"CourseHome.aspx?id="+row["CourseID"]+"\">"+CourseHelper.Encode(row["Title"])+"</a>";
        }
        protected string ProgressFor(object courseID,object status)
        {
            if((string)status!="Published")return "<p class=\"muted\">Currently unavailable. Your saved results are kept.</p>";
            return CourseHelper.Progress(CurrentUserHelper.GetUserID().Value,Convert.ToInt32(courseID));
        }
        protected void CourseCommand(object sender,RepeaterCommandEventArgs e)
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
                MessageHelper.SetSuccess("You left the course. Your learning records have been kept.");Response.Redirect("MyCourses.aspx");
            }
            catch(SqlException) { MessageHelper.SetError("You could not leave the course. Please try again."); }
        }
    }
}
