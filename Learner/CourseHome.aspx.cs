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
                bool complete=ProgressHelper.CalculatePercent(user,id)==100m;
                lnkCertificate.Visible=complete;lnkCertificate.NavigateUrl="Certificate.aspx?id="+id;
                // The button always points at the first item the learner has not finished.
                DataRow next=CourseHelper.NextItem(user,id);
                lnkNext.Visible=next!=null;
                if(next!=null){lnkNext.Text="Continue: "+next["Title"];lnkNext.NavigateUrl=CourseHelper.ItemLink(next,true);}
                ((SiteMaster)Master).Breadcrumb=new[] {new BreadcrumbItem{Text="Home",Url="~/Default.aspx"},new BreadcrumbItem{Text="My courses",Url="~/Learner/MyCourses.aspx"},new BreadcrumbItem{Text=Title}};
                litProgress.Text=CourseHelper.Progress(user,id);CourseHelper.Outline(phOutline,id,true);
            }
            catch(SqlException) {Response.Redirect("~/Error.aspx");}
        }
    }
}
