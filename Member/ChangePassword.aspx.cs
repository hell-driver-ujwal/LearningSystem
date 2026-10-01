using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using LearningSystem.Helpers;
namespace LearningSystem.Member
{
    public partial class ChangePassword : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            AccessHelper.RequireRole(new[] { "Learner", "Teacher", "Admin" });
            if (AccountSecurityHelper.MustChange(CurrentUserHelper.GetUserID().Value))
            {
                if (!IsPostBack) MessageHelper.SetError("You must change your temporary password before continuing.");
                lnkCancel.Text = "Log out";
                lnkCancel.NavigateUrl = "~/Account/Logout.aspx";
            }
        }
        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;
            try
            {
                object value = DatabaseHelper.ExecuteScalar("SELECT PasswordHash FROM dbo.[User] WHERE UserID=@id AND Status=@status",
                    new[] { new SqlParameter("@id", SqlDbType.Int) { Value = CurrentUserHelper.GetUserID().Value },
                        new SqlParameter("@status", SqlDbType.NVarChar, 11) { Value = "Active" } });
                string oldHash = value as string;
                if (!PasswordHelper.VerifyPassword(txtCurrent.Text, oldHash))
                { MessageHelper.SetError("The current password is incorrect."); return; }
                if (PasswordHelper.VerifyPassword(txtPassword.Text, oldHash))
                { MessageHelper.SetError("Your new password must differ from your current password."); return; }
                int changed = DatabaseHelper.ExecuteNonQuery("UPDATE dbo.[User] SET PasswordHash=@hash,MustChangePassword=0 WHERE UserID=@id AND PasswordHash=@oldHash AND Status=@status",
                    new[] { new SqlParameter("@hash", SqlDbType.NVarChar, 200) { Value = PasswordHelper.HashPassword(txtPassword.Text) },
                        new SqlParameter("@id", SqlDbType.Int) { Value = CurrentUserHelper.GetUserID().Value },
                        new SqlParameter("@oldHash", SqlDbType.NVarChar, 200) { Value = oldHash },
                        new SqlParameter("@status", SqlDbType.NVarChar, 11) { Value = "Active" } });
                if (changed != 1) { MessageHelper.SetError("Your account changed. Please reload and try again."); return; }
            }
            catch (SqlException) { MessageHelper.SetError("Your password could not be changed. Please try again later."); return; }
            MessageHelper.SetSuccess("Your password has been changed.");
            Response.Redirect("~/Member/Profile.aspx");
        }
    }
}
