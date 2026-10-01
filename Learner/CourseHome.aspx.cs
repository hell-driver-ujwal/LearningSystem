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
                if(!AccessHelper.IsEnrolled(CurrentUserHelper.GetUserID().Value,id)) {Response.Redirect("~/AccessDenied.aspx");return;}
                Title=(string)row["Title"];litTitle.Text=Title;
                lnkCertificate.Visible=ProgressHelper.CalculatePercent(CurrentUserHelper.GetUserID().Value,id)==100m;lnkCertificate.NavigateUrl="Certificate.aspx?id="+id;
                ((SiteMaster)Master).Breadcrumb=new[] {new BreadcrumbItem{Text="Home",Url="~/Default.aspx"},new BreadcrumbItem{Text="My courses",Url="~/Learner/MyCourses.aspx"},new BreadcrumbItem{Text=Title}};
                litProgress.Text=CourseHelper.Progress(CurrentUserHelper.GetUserID().Value,id);CourseHelper.Outline(phOutline,id,true);
            }
            catch(SqlException) {Response.Redirect("~/Error.aspx");}
        }
    }
}
