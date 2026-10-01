using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using LearningSystem.Helpers;
namespace LearningSystem
{
    public partial class Preview : Page
    {
        protected void Page_Load(object sender,EventArgs e)
        {
            int id=CourseHelper.QueryID("id");
            try
            {
                if(!AccessHelper.CanViewFreePreview(id)) { Response.Redirect("~/NotFound.aspx");return; }
                DataRow row=MaterialHelper.Find(id);
                if(!MaterialHelper.Published(row) || !(bool)row["IsPreview"]) { Response.Redirect("~/NotFound.aspx");return; }
                Title="Free preview: "+row["Title"];litTitle.Text=(string)row["Title"];
                MaterialHelper.Render(phViewer,row,false);
                ((SiteMaster)Master).Breadcrumb=BreadcrumbHelper.ForMaterial(row,false,true);
                lnkExit.NavigateUrl="~/CourseDetails.aspx?id="+row["CourseID"];
            }
            catch(SqlException) { Response.Redirect("~/Error.aspx"); }
        }
    }
}


