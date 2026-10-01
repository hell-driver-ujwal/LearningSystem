using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using LearningSystem.Helpers;

namespace LearningSystem.Admin
{
    public partial class Users : Page
    {

        protected void Page_Load(object sender, EventArgs e)
        {
            AccessHelper.RequireRole(new[] { "Admin" });
            txtSearch.Text = txtSearch.Text.Trim();
            if (!IsPostBack) BindUsers();
        }
        private void BindUsers()
        {
            if (txtSearch.Text.Length > 50) { MessageHelper.SetError("Search must be at most 50 characters."); return; }
            // Escape LIKE wildcards so search text is treated literally.
            string search = txtSearch.Text.Replace("~", "~~").Replace("%", "~%").Replace("_", "~_").Replace("[", "~[");
            try
            {
                gvUsers.DataSource = DatabaseHelper.ExecuteTable(
                    "SELECT UserID,FullName,Email,Role,Status,FailedLoginCount,LockedUntil FROM dbo.[User] WHERE (@role='' OR Role=@role) AND (@status='' OR Status=@status) AND (FullName LIKE @search ESCAPE '~' OR Email LIKE @search ESCAPE '~') ORDER BY FullName,UserID",
                    new[] { new SqlParameter("@role", SqlDbType.NVarChar, 7) { Value = ddlRole.SelectedValue },
                        new SqlParameter("@status", SqlDbType.NVarChar, 11) { Value = ddlStatus.SelectedValue },
                        new SqlParameter("@search", SqlDbType.NVarChar, 102) { Value = "%" + search + "%" } });
                gvUsers.DataBind();
            }
            catch (SqlException) { MessageHelper.SetError("Users could not be loaded."); }
        }
        protected void btnSearch_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;
            gvUsers.PageIndex = 0;
            BindUsers();
        }
        protected void btnCancel_Click(object sender, EventArgs e) { Response.Redirect("~/Admin/Users.aspx"); }
        protected void gvUsers_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvUsers.PageIndex = e.NewPageIndex;
            BindUsers();
        }
        protected void gvUsers_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName != "DeleteUser" && e.CommandName != "ActivateUser" && e.CommandName != "DeactivateUser" && e.CommandName != "UnlockUser") return;
            if (!Page.IsValid) return;
            int id;
            if (!Int32.TryParse(Convert.ToString(e.CommandArgument), out id) || id < 1) return;
            try
            {
                if (e.CommandName == "UnlockUser")
                {
                    int changed = DatabaseHelper.ExecuteNonQuery("UPDATE dbo.[User] SET FailedLoginCount=0,LockedUntil=NULL WHERE UserID=@id AND Role IN ('Learner','Teacher')", new[] { new SqlParameter("@id", id) });
                    if (changed != 1) { MessageHelper.SetError("This account cannot be unlocked here."); return; }
                    MessageHelper.SetSuccess("Account unlocked; failed-login count reset.");
                }
                else if (e.CommandName == "DeleteUser")
                {
                    ValidationResult result = DeleteHelper.DeleteUser(id);
                    if (!result.IsValid) { MessageHelper.SetError(result.Message); return; }
                    MessageHelper.SetSuccess(result.Message);
                }
                else
                {
                    // Role/status predicates also protect against stale pages and forged admin actions.
                    int changed = DatabaseHelper.ExecuteNonQuery(
                        "UPDATE dbo.[User] SET Status=@next WHERE UserID=@id AND UserID<>@actor AND Role IN ('Learner','Teacher') AND Status=@previous",
                        new[] { new SqlParameter("@id", id), new SqlParameter("@actor", CurrentUserHelper.GetUserID().Value),
                            new SqlParameter("@next", SqlDbType.NVarChar, 11) { Value = e.CommandName == "ActivateUser" ? "Active" : "Deactivated" },
                            new SqlParameter("@previous", SqlDbType.NVarChar, 11) { Value = e.CommandName == "ActivateUser" ? "Deactivated" : "Active" } });
                    if (changed == 0) { MessageHelper.SetError("Admin accounts and application statuses cannot be changed here."); return; }
                    MessageHelper.SetSuccess("User status updated.");
                }
            }
            catch (SqlException) { MessageHelper.SetError("The user could not be changed. No partial deletion was saved."); return; }
            Response.Redirect("~/Admin/Users.aspx");
        }
    }
}

