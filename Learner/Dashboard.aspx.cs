using System;
using System.Collections.Generic;
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
                string name=Convert.ToString(Session["FullName"]);
                litGreeting.Text="Welcome back, "+name.Split(' ')[0];
                HashSet<DateTime> days=EngagementHelper.ActiveDays(user);
                int streak=EngagementHelper.Streak(days);
                litStreak.Text=UiHelper.Plural(streak,"day");
                litWeek.Text=EngagementHelper.WeekStrip(days);
                litIntro.Text=streak==0 ? "Finish one lesson or activity today to start a new learning streak." : days.Contains(DateTime.UtcNow.Date) ? "You have studied today. Keep the streak going tomorrow." : "Complete something today to keep your streak alive.";

                DataTable courses=DatabaseHelper.ExecuteTable("SELECT c.CourseID,c.Title,c.Status,c.CoverImagePath,s.SubjectName FROM dbo.Enrolment e JOIN dbo.Course c ON c.CourseID=e.CourseID JOIN dbo.Subject s ON s.SubjectID=c.SubjectID WHERE e.LearnerID=@user ORDER BY e.EnrolDate DESC,c.CourseID DESC",new[] {new SqlParameter("@user",user)});
                int completed=0;
                foreach(DataRow row in courses.Rows) if((string)row["Status"]=="Published" && ProgressHelper.CalculatePercent(user,(int)row["CourseID"])==100m) completed++;
                litCourses.Text=courses.Rows.Count.ToString(CultureInfo.InvariantCulture);
                litCoursesNote.Text=completed+" completed, "+(courses.Rows.Count-completed)+" in progress";
                litDone.Text=EngagementHelper.CompletedItems(user).ToString(CultureInfo.InvariantCulture);
                decimal? score=EngagementHelper.AverageBestScore(user);
                litScore.Text=score.HasValue ? score.Value.ToString("0",CultureInfo.InvariantCulture)+"%" : "None yet";

                ShowContinue(user);
                ShowCourses(user,courses);
                gvResults.DataSource=ResultsHelper.Attempts(false,0,0,5);gvResults.DataBind();
                CourseHelper.Cards(phSuggested,DatabaseHelper.ExecuteTable(@"SELECT TOP (3) c.IsPaid,c.PriceNPR,c.CourseID,c.Title,c.Description,c.CoverImagePath,s.SubjectName,u.FullName AS TeacherName
FROM dbo.Course c JOIN dbo.Subject s ON s.SubjectID=c.SubjectID JOIN dbo.[User] u ON u.UserID=c.TeacherID
WHERE c.Status='Published' AND NOT EXISTS (SELECT 1 FROM dbo.Enrolment e WHERE e.CourseID=c.CourseID AND e.LearnerID=@user)
ORDER BY CASE WHEN c.SubjectID IN (SELECT c2.SubjectID FROM dbo.Enrolment e2 JOIN dbo.Course c2 ON c2.CourseID=e2.CourseID WHERE e2.LearnerID=@user) THEN 0 ELSE 1 END,
 (SELECT COUNT(*) FROM dbo.Enrolment e3 WHERE e3.CourseID=c.CourseID) DESC, c.CourseID",new[] {new SqlParameter("@user",user)}));
            }
            catch(SqlException) {MessageHelper.SetError("Your dashboard is temporarily unavailable.");}
        }

        // "Continue learning": the most recently studied course and its first unfinished item.
        private void ShowContinue(int user)
        {
            int courseID=EngagementHelper.LastCourse(user);
            if(courseID==0)
            {
                phContinue.Controls.Add(new LiteralControl("<div class=\"empty-state\">"+UiHelper.Icon("compass")+"<strong>Start your first course</strong><p>Browse the catalogue, open a free preview and enrol when you are ready.</p><a class=\"button\" href=\"../Courses.aspx\">Browse courses</a></div>"));
                return;
            }
            DataRow course=CourseHelper.Find(courseID);
            DataRow next=CourseHelper.NextItem(user,courseID);
            string link=next==null ? "CourseHome.aspx?id="+courseID : ResolveUrl(CourseHelper.ItemLink(next,true));
            string action=next==null ? "Review the course" : "Continue: "+CourseHelper.Encode(next["Title"]);
            string detail=next==null ? "You have completed every item in this course. Your certificate is ready." : "Next up is a "+CourseHelper.Encode(CourseHelper.ItemLabel(next)).ToLowerInvariant()+" in this course.";
            phContinue.Controls.Add(new LiteralControl("<section class=\"continue-card\" aria-labelledby=\"continue-title\">"+CourseHelper.CoverHtml(course,"")
                +"<div><p class=\"eyebrow\">Continue learning</p><h2 id=\"continue-title\">"+CourseHelper.Encode(course["Title"])+"</h2><p>"+detail+"</p>"
                +CourseHelper.Progress(user,courseID)+"<div class=\"actions\"><a class=\"button\" href=\""+link+"\">"+action+"</a><a href=\"CourseHome.aspx?id="+courseID+"\">Course outline</a></div></div></section>"));
        }

        private void ShowCourses(int user,DataTable courses)
        {
            if(courses.Rows.Count==0){phCourses.Controls.Add(new LiteralControl("<div class=\"empty-state\"><strong>No courses yet</strong><p>Courses you enrol in will appear here with your progress.</p></div>"));return;}
            StringBuilder html=new StringBuilder("<div class=\"course-grid\">");
            foreach(DataRow row in courses.Rows)
            {
                bool available=(string)row["Status"]=="Published";
                html.Append("<article class=\"course-card\">").Append(CourseHelper.CoverHtml(row,"course-cover")).Append("<div class=\"course-body\"><p class=\"course-subject\">").Append(CourseHelper.Encode(row["SubjectName"])).Append("</p><h3>");
                if(available)html.Append("<a href=\"CourseHome.aspx?id=").Append(row["CourseID"]).Append("\">").Append(CourseHelper.Encode(row["Title"])).Append("</a>");
                else html.Append(CourseHelper.Encode(row["Title"]));
                html.Append("</h3>");
                if(available)html.Append(CourseHelper.Progress(user,(int)row["CourseID"]));
                else html.Append("<p class=\"muted\">Currently unavailable. Your saved results are kept.</p>");
                html.Append("</div></article>");
            }
            phCourses.Controls.Add(new LiteralControl(html.Append("</div>").ToString()));
        }
    }
}
