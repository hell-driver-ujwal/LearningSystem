using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using LearningSystem.Helpers;
namespace LearningSystem.Learner
{
    public partial class CourseHome : Page
    {
        protected void Page_Load(object sender,EventArgs e)
        {
            AccessHelper.RequireRole(new[] {"Learner"});int id=CourseHelper.QueryID("id");
            try
            {
                DataRow row=CourseHelper.Find(id);
                if(row==null || (string)row["Status"]!="Published") {Response.Redirect("~/NotFound.aspx");return;}
                int user=CurrentUserHelper.GetUserID().Value;
                if(!AccessHelper.IsEnrolled(user,id)) {Response.Redirect("~/AccessDenied.aspx");return;}
                Title=(string)row["Title"];litTitle.Text=Title;litSubject.Text=(string)row["SubjectName"];litTeacher.Text="Taught by "+row["TeacherName"];
                lnkDetails.NavigateUrl="~/CourseDetails.aspx?id="+id;
                // Load the course items once; progress, the Continue button and the path all come from this table.
                DataTable items=ProgressHelper.PublishedItems(user,id);
                decimal percent=ProgressHelper.PercentOf(items);
                bool complete=percent==100m;
                lnkCertificate.Visible=complete;lnkCertificate.NavigateUrl="Certificate.aspx?id="+id;
                // The button always points at the first item the learner has not finished.
                int next=CourseHelper.FirstUnfinished(items);
                lnkNext.Visible=next>=0;
                if(next>=0){lnkNext.Text="Continue: "+CourseHelper.Encode(items.Rows[next]["Title"]);lnkNext.NavigateUrl=CourseHelper.ItemLink(items.Rows[next],true);}
                ((SiteMaster)Master).Breadcrumb=new[] {new BreadcrumbItem{Text="Home",Url="~/Default.aspx"},new BreadcrumbItem{Text="My courses",Url="~/Learner/MyCourses.aspx"},new BreadcrumbItem{Text=Title}};
                litProgress.Text=CourseHelper.ProgressBar(percent);
                ShowPath(items,next,id,complete);
            }
            catch(SqlException) {Response.Redirect("~/Error.aspx");}
        }

        // The course as a learning path; the first unfinished item is marked as up next.
        private void ShowPath(DataTable items,int next,int courseID,bool complete)
        {
            if(items.Rows.Count==0){phOutline.Controls.Add(new LiteralControl("<div class=\"empty-state\">"+MascotHelper.Render("sleep")+"<strong>Nothing here yet</strong><p>The lecturer has not published any lessons in this course yet.</p></div>"));return;}
            phOutline.Controls.Add(new LiteralControl(GameUiHelper.Path(items,next)));
            if(complete) phOutline.Controls.Add(new LiteralControl("<div class=\"path-done\" data-celebrate=\"small\">"+MascotHelper.Render("graduate")+"<h3>Course complete!</h3><p>You finished every lesson and activity. Your certificate is ready to print.</p><a class=\"button accent\" href=\"Certificate.aspx?id="+courseID+"\">Print certificate</a></div>"));
        }
    }
}
