using System;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Text;
using System.Web.UI;
using LearningSystem.Helpers;
namespace LearningSystem.Learner
{
    public partial class Dashboard : Page
    {
        protected void Page_Load(object sender,EventArgs e)
        {
            AccessHelper.RequireRole(new[] {"Learner"});int user=CurrentUserHelper.GetUserID().Value;
            try
            {
                DataTable courses=DatabaseHelper.ExecuteTable("SELECT c.CourseID,c.Title,c.Status FROM dbo.Enrolment e JOIN dbo.Course c ON c.CourseID=e.CourseID WHERE e.LearnerID=@user ORDER BY e.EnrolDate DESC,c.CourseID DESC",new[] {new SqlParameter("@user",user)});
                StringBuilder html=new StringBuilder();
                if(courses.Rows.Count==0)html.Append("<p>No enrolled courses yet. Browse courses to get started.</p>");
                foreach(DataRow row in courses.Rows)
                {
                    html.Append("<article class=\"course-card\"><h3>");
                    if((string)row["Status"]=="Published")html.Append("<a href=\"CourseHome.aspx?id=").Append(row["CourseID"]).Append("\">").Append(CourseHelper.Encode(row["Title"])).Append("</a>");
                    else html.Append(CourseHelper.Encode(row["Title"])).Append(" — Currently unavailable");
                    html.Append("</h3>").Append(CourseHelper.Progress(user,(int)row["CourseID"])).Append("</article>");
                }
                phCourses.Controls.Add(new LiteralControl(html.ToString()));
                DataTable results=ResultsHelper.Attempts(false,0,0,5);
                gvResults.DataSource=results;gvResults.DataBind();
            }
            catch(SqlException) {MessageHelper.SetError("Your dashboard is temporarily unavailable.");}
        }
    }
}

