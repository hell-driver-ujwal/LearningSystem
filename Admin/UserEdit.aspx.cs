using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using LearningSystem.Helpers;

namespace LearningSystem.Admin
{
    public partial class UserEdit : Page
    {

        private int userID;
        private bool application;
        protected void Page_Load(object sender, EventArgs e)
        {
            AccessHelper.RequireRole(new[] { "Admin" });
            string value = Request.QueryString["id"];
            if (value != null && (!Int32.TryParse(value, out userID) || userID < 1))
            { Response.Redirect("~/AccessDenied.aspx"); return; }
            if (userID > 0)
            {
                try
                {
                    DataTable rows = DatabaseHelper.ExecuteTable("SELECT FullName,Email,Role,Status FROM dbo.[User] WHERE UserID=@id",
                        new[] { new SqlParameter("@id", userID) });
                    if (rows.Rows.Count != 1 || (string)rows.Rows[0]["Role"] == "Admin")
                    { Response.Redirect("~/AccessDenied.aspx"); return; }
                    DataRow user = rows.Rows[0];
                    application = (string)user["Status"] == "Pending" || (string)user["Status"] == "Rejected";
                    ddlRole.Enabled = false;
                    ddlStatus.Enabled = !application;
                    rfvStatus.Enabled = !application;
                    litApplication.Text = application ? "Application status: " + (string)user["Status"] + ". Use Lecturer applications to approve or reject it." : "";
                    if (!IsPostBack)
                    {
                        txtFullName.Text = (string)user["FullName"];
                        txtEmail.Text = (string)user["Email"];
                        ddlRole.SelectedValue = (string)user["Role"];
                        if (!application) ddlStatus.SelectedValue = (string)user["Status"];
                    }
                }
                catch (SqlException) { Response.Redirect("~/Error.aspx"); return; }
            }
            litMode.Text = userID == 0 ? "Create a learner or lecturer account." : "Edit account details or enter a temporary password and choose Reset password.";
            btnReset.Visible = userID > 0;
            rfvPassword.ValidationGroup = revPassword.ValidationGroup = userID == 0 ? "Save" : "Reset";
            txtFullName.Text = txtFullName.Text.Trim();
            txtEmail.Text = txtEmail.Text.Trim();
        }
        protected void ValidateUser(object source, ServerValidateEventArgs args)
        {
            args.IsValid = false;
            if (ddlRole.SelectedValue != "Learner" && ddlRole.SelectedValue != "Teacher")
            { cvUser.ErrorMessage = "Choose Learner or Lecturer."; return; }
            if (!application && ddlStatus.SelectedValue != "Active" && ddlStatus.SelectedValue != "Deactivated")
            { cvUser.ErrorMessage = "Choose Active or Deactivated."; return; }
            try
            {
                args.IsValid = Convert.ToInt32(DatabaseHelper.ExecuteScalar("SELECT COUNT(*) FROM dbo.[User] WHERE Email=@email AND UserID<>@id",
                    new[] { new SqlParameter("@email", SqlDbType.NVarChar, 100) { Value = txtEmail.Text }, new SqlParameter("@id", userID) })) == 0;
                cvUser.ErrorMessage = "That email address is already registered.";
            }
            catch (SqlException) { cvUser.ErrorMessage = "User validation is unavailable."; }
        }
        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;
            try
            {
                SqlParameter[] parameters = {
                    new SqlParameter("@id", userID),
                    new SqlParameter("@name", SqlDbType.NVarChar, 100) { Value = txtFullName.Text },
                    new SqlParameter("@email", SqlDbType.NVarChar, 100) { Value = txtEmail.Text },
                    new SqlParameter("@role", SqlDbType.NVarChar, 7) { Value = ddlRole.SelectedValue },
                    new SqlParameter("@status", SqlDbType.NVarChar, 11) { Value = ddlStatus.SelectedValue },
                    new SqlParameter("@hash", SqlDbType.NVarChar, 200) { Value = userID == 0 ? PasswordHelper.HashPassword(txtPassword.Text) : "" }
                };
                int changed = DatabaseHelper.ExecuteNonQuery(userID == 0
                    ? "INSERT INTO dbo.[User] (FullName,Email,Role,Status,PasswordHash,MustChangePassword) VALUES (@name,@email,@role,@status,@hash,1)"
                    : "UPDATE dbo.[User] SET FullName=@name,Email=@email,Status=CASE WHEN Status IN ('Active','Deactivated') THEN @status ELSE Status END WHERE UserID=@id AND Role IN ('Learner','Teacher')", parameters);
                if (changed == 0) { MessageHelper.SetError("This user can no longer be edited."); return; }
            }
            catch (SqlException ex)
            {
                MessageHelper.SetError(ex.Number == 2601 || ex.Number == 2627 ? "That email address is already registered." : "The user could not be saved.");
                return;
            }
            MessageHelper.SetSuccess("User saved.");
            Response.Redirect("~/Admin/Users.aspx");
        }
        protected void btnReset_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;
            if (userID == 0) return;
            try
            {
                int changed = DatabaseHelper.ExecuteNonQuery("UPDATE dbo.[User] SET PasswordHash=@hash,MustChangePassword=1 WHERE UserID=@id AND Role IN ('Learner','Teacher')",
                    new[] { new SqlParameter("@hash", SqlDbType.NVarChar, 200) { Value = PasswordHelper.HashPassword(txtPassword.Text) }, new SqlParameter("@id", userID) });
                if (changed == 0) { MessageHelper.SetError("This user can no longer be edited."); return; }
            }
            catch (SqlException) { MessageHelper.SetError("The password could not be reset."); return; }
            MessageHelper.SetSuccess("Temporary password saved. Give it to the user and ask them to change it after login.");
            Response.Redirect("~/Admin/Users.aspx");
        }
        protected void btnCancel_Click(object sender, EventArgs e) { Response.Redirect("~/Admin/Users.aspx"); }
    }
}

