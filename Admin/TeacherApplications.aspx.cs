using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using LearningSystem.Helpers;

namespace LearningSystem.Admin
{
    public partial class TeacherApplications : Page
    {

        protected void Page_Load(object sender, EventArgs e)
        {
            AccessHelper.RequireRole(new[] { "Admin" });
            if (IsPostBack) return;
            try
            {
                gvApplications.DataSource = DatabaseHelper.ExecuteTable("SELECT UserID,FullName,Email,ApplicationReason,CreatedDate FROM dbo.[User] WHERE Role='Teacher' AND Status='Pending' ORDER BY CreatedDate,UserID", null);
                gvApplications.DataBind();
            }
            catch (SqlException) { MessageHelper.SetError("Applications could not be loaded."); }
        }
        protected void gvApplications_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (!Page.IsValid) return;
            if (e.CommandName != "Approve" && e.CommandName != "Reject") return;
            int id;
            if (!Int32.TryParse(Convert.ToString(e.CommandArgument), out id) || id < 1) return;
            try
            {
                int changed = DatabaseHelper.ExecuteNonQuery("UPDATE dbo.[User] SET Status=@status WHERE UserID=@id AND Role='Teacher' AND Status='Pending'",
                    new[] { new SqlParameter("@status", SqlDbType.NVarChar, 11) { Value = e.CommandName == "Approve" ? "Active" : "Rejected" }, new SqlParameter("@id", id) });
                if (changed == 0) { MessageHelper.SetError("This application is no longer pending. Refresh the list."); return; }
            }
            catch (SqlException) { MessageHelper.SetError("The decision could not be saved."); return; }
            MessageHelper.SetSuccess(e.CommandName == "Approve" ? "Teacher application approved." : "Teacher application rejected.");
            Response.Redirect("~/Admin/TeacherApplications.aspx");
        }
        protected void btnCancel_Click(object sender, EventArgs e) { Response.Redirect("~/Admin/Dashboard.aspx"); }
    }
}

