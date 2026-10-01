using System;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using LearningSystem.Helpers;
namespace LearningSystem.Account
{
    public partial class Register : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (CurrentUserHelper.IsAuthenticated()) Response.Redirect(CurrentUserHelper.GetDashboardUrl());
            if (!IsPostBack) CaptchaHelper.Generate();
            lblCaptcha.Text = CaptchaHelper.Question();
            txtFullName.Text = txtFullName.Text.Trim();
            txtEmail.Text = txtEmail.Text.Trim();
            txtReason.Text = txtReason.Text.Trim();
        }
        protected void ValidateRegistration(object source, ServerValidateEventArgs args)
        {
            args.IsValid = false;
            if (ddlRole.SelectedValue != "Learner" && ddlRole.SelectedValue != "Teacher")
            { cvRegistration.ErrorMessage = "Choose Learner or Teacher."; return; }
            if (ddlRole.SelectedValue == "Teacher" && (txtReason.Text.Length < 20 || txtReason.Text.Length > 500))
            { cvRegistration.ErrorMessage = "Teacher applications need a reason of 20–500 characters."; return; }
            try
            {
                object count = DatabaseHelper.ExecuteScalar("SELECT COUNT(*) FROM dbo.[User] WHERE Email=@email",
                    new[] { new SqlParameter("@email", SqlDbType.NVarChar, 100) { Value = txtEmail.Text } });
                args.IsValid = Convert.ToInt32(count) == 0;
                cvRegistration.ErrorMessage = "That email address is already registered.";
            }
            catch (SqlException) { cvRegistration.ErrorMessage = "Registration is unavailable. Please try again later."; }
        }
        protected void ValidateCaptcha(object source, ServerValidateEventArgs args)
        {
            args.IsValid = CaptchaHelper.Check(txtCaptcha.Text);
            if (!args.IsValid)
            {
                CaptchaHelper.Generate();
                lblCaptcha.Text = CaptchaHelper.Question();
                txtCaptcha.Text = "";
            }
        }
        protected void btnRegister_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;
            bool teacher = ddlRole.SelectedValue == "Teacher";
            try
            {
                DatabaseHelper.ExecuteNonQuery("INSERT INTO dbo.[User] (FullName, Email, PasswordHash, Role, Status, ApplicationReason) VALUES (@name,@email,@hash,@role,@status,@reason)",
                    new[] {
                        new SqlParameter("@name", SqlDbType.NVarChar, 100) { Value = txtFullName.Text },
                        new SqlParameter("@email", SqlDbType.NVarChar, 100) { Value = txtEmail.Text },
                        new SqlParameter("@hash", SqlDbType.NVarChar, 200) { Value = PasswordHelper.HashPassword(txtPassword.Text) },
                        new SqlParameter("@role", SqlDbType.NVarChar, 7) { Value = ddlRole.SelectedValue },
                        new SqlParameter("@status", SqlDbType.NVarChar, 11) { Value = teacher ? "Pending" : "Active" },
                        new SqlParameter("@reason", SqlDbType.NVarChar, 500) { Value = teacher ? (object)txtReason.Text : DBNull.Value }
                    });
            }
            catch (SqlException ex)
            {
                MessageHelper.SetError(ex.Number == 2601 || ex.Number == 2627 ? "That email address is already registered." : "Registration is unavailable. Please try again later.");
                return;
            }
            Session.Remove("RegisterCaptcha");
            MessageHelper.SetSuccess(teacher ? "Your teacher application is pending approval. You can log in after an administrator approves it." : "Registration successful. Please log in.");
            Response.Redirect(teacher ? "~/Default.aspx" : "~/Account/Login.aspx");
        }
    }
}
