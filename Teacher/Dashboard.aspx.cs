using System;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Web.UI;
using LearningSystem.Helpers;
namespace LearningSystem.Teacher
{
    public partial class Dashboard : Page
    {
        protected void Page_Load(object sender,EventArgs e)
        {
            // The admin's authoring tools live on the admin dashboard and My courses.
            if(CurrentUserHelper.GetRole()=="Admin"){Response.Redirect("~/Admin/Dashboard.aspx");return;}
            AccessHelper.RequireRole(new[] {"Teacher"});int user=CurrentUserHelper.GetUserID().Value;
            try
            {
                SqlParameter[] me={new SqlParameter("@user",user)};
                litGreeting.Text="Welcome back, "+UiHelper.FirstName(Convert.ToString(Session["FullName"]));
                DataTable courses=DatabaseHelper.ExecuteTable("SELECT c.CourseID,c.Title,c.Status,c.CoverImagePath,s.SubjectName,(SELECT COUNT(*) FROM dbo.Enrolment e WHERE e.CourseID=c.CourseID) AS Learners FROM dbo.Course c JOIN dbo.Subject s ON s.SubjectID=c.SubjectID WHERE c.TeacherID=@user ORDER BY c.LastUpdated DESC,c.CourseID",new[] {new SqlParameter("@user",user)});
                int published=0;foreach(DataRow row in courses.Rows)if((string)row["Status"]=="Published")published++;
                litCourses.Text=courses.Rows.Count.ToString();litCoursesNote.Text=published+" published, "+(courses.Rows.Count-published)+" in draft";
                litLearners.Text=Convert.ToString(DatabaseHelper.ExecuteScalar("SELECT COUNT(DISTINCT e.LearnerID) FROM dbo.Enrolment e JOIN dbo.Course c ON c.CourseID=e.CourseID WHERE c.TeacherID=@user",me));
                litWeek.Text=Convert.ToString(DatabaseHelper.ExecuteScalar("SELECT COUNT(*) FROM dbo.Attempt x JOIN dbo.Activity a ON a.ActivityID=x.ActivityID JOIN dbo.Topic t ON t.TopicID=a.TopicID JOIN dbo.Course c ON c.CourseID=t.CourseID WHERE c.TeacherID=@user AND x.SubmittedAt>=DATEADD(day,-7,SYSUTCDATETIME())",new[] {new SqlParameter("@user",user)}));
                litPosts.Text=Convert.ToString(DatabaseHelper.ExecuteScalar("SELECT COUNT(*) FROM dbo.DiscussionPost p JOIN dbo.Activity a ON a.ActivityID=p.ActivityID JOIN dbo.Topic t ON t.TopicID=a.TopicID JOIN dbo.Course c ON c.CourseID=t.CourseID WHERE c.TeacherID=@user",new[] {new SqlParameter("@user",user)}));
                ShowCourses(courses);
                gvResults.DataSource=ResultsHelper.Attempts(true,0,0,5);gvResults.DataBind();
            }
            catch(SqlException){MessageHelper.SetError("Your dashboard is temporarily unavailable.");}
        }
        private void ShowCourses(DataTable courses)
        {
            if(courses.Rows.Count==0){phCourses.Controls.Add(new LiteralControl("<div class=\"empty-state\">"+UiHelper.Icon("layers")+"<strong>No courses yet</strong><p>Create your first course, add a topic and publish when it is ready.</p><a class=\"button\" href=\"CourseEdit.aspx\">Create a course</a></div>"));return;}
            StringBuilder html=new StringBuilder("<div class=\"course-grid\">");
            foreach(DataRow row in courses.Rows)
            {
                bool published=(string)row["Status"]=="Published";
                html.Append("<article class=\"course-card\">").Append(CourseHelper.CoverHtml(row,"course-cover")).Append("<div class=\"course-body\"><p class=\"chip ").Append(published ? "green" : "amber").Append("\">").Append(published ? "Published" : "Draft").Append("</p><h3><a href=\"CourseBuilder.aspx?id=").Append(row["CourseID"]).Append("\">")
                    .Append(CourseHelper.Encode(row["Title"])).Append("</a></h3><p class=\"course-teacher\">").Append(CourseHelper.Encode(row["SubjectName"])).Append(", ").Append(UiHelper.Plural((int)row["Learners"],"learner")).Append("</p></div></article>");
            }
            phCourses.Controls.Add(new LiteralControl(html.Append("</div>").ToString()));
        }
    }
}
