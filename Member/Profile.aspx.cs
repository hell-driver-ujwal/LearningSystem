using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using LearningSystem.Helpers;
namespace LearningSystem.Member
{
    public partial class Profile : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                try
                {
                    DataTable users = DatabaseHelper.ExecuteTable("SELECT FullName, Email, Role, Status FROM dbo.[User] WHERE UserID=@id",
                        new[] { new SqlParameter("@id", SqlDbType.Int) { Value = CurrentUserHelper.GetUserID().Value } });
                    if (users.Rows.Count != 1) { Response.Redirect("~/Account/Logout.aspx"); return; }
                    txtFullName.Text = (string)users.Rows[0]["FullName"];
                    txtEmail.Text = (string)users.Rows[0]["Email"];
                    litDetails.Text = (string)users.Rows[0]["Role"] + " · " + (string)users.Rows[0]["Status"];
                }
                catch (SqlException) { Response.Redirect("~/Error.aspx"); }
            }
            txtFullName.Text = txtFullName.Text.Trim();
            txtEmail.Text = txtEmail.Text.Trim();
        }
        protected void ValidateEmail(object source, ServerValidateEventArgs args)
        {
            try
            {
                object count = DatabaseHelper.ExecuteScalar("SELECT COUNT(*) FROM dbo.[User] WHERE Email=@email AND UserID<>@id",
                    new[] { new SqlParameter("@email", SqlDbType.NVarChar, 100) { Value = txtEmail.Text },
                        new SqlParameter("@id", SqlDbType.Int) { Value = CurrentUserHelper.GetUserID().Value } });
                args.IsValid = Convert.ToInt32(count) == 0;
                cvEmail.ErrorMessage = "That email address is already registered.";
            }
            catch (SqlException) { args.IsValid = false; cvEmail.ErrorMessage = "Profile is unavailable. Please try again later."; }
        }
        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;
            try
            {
                int changed = DatabaseHelper.ExecuteNonQuery("UPDATE dbo.[User] SET FullName=@name, Email=@email WHERE UserID=@id AND Status=@status",
                    new[] { new SqlParameter("@name", SqlDbType.NVarChar, 100) { Value = txtFullName.Text },
                        new SqlParameter("@email", SqlDbType.NVarChar, 100) { Value = txtEmail.Text },
                        new SqlParameter("@id", SqlDbType.Int) { Value = CurrentUserHelper.GetUserID().Value },
                        new SqlParameter("@status", SqlDbType.NVarChar, 11) { Value = "Active" } });
                if (changed != 1) { Response.Redirect("~/Account/Logout.aspx"); return; }
            }
            catch (SqlException ex)
            {
                MessageHelper.SetError(ex.Number == 2601 || ex.Number == 2627 ? "That email address is already registered." : "Your profile could not be saved. Please try again later.");
                return;
            }
            Session["FullName"] = txtFullName.Text;
            MessageHelper.SetSuccess("Your profile has been updated.");
            Response.Redirect("~/Member/Profile.aspx");
        }
    }
}
