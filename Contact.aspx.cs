using System;
using System.Data;
using System.Data.SqlClient;
using System.Text.RegularExpressions;
using System.Web.UI;
using System.Web.UI.WebControls;
using LearningSystem.Helpers;
namespace LearningSystem
{
    public partial class Contact : Page
    {
        protected void Page_Load(object sender,EventArgs e)
        {
            if(CurrentUserHelper.IsAuthenticated())AccessHelper.RequireRole(new[] {"Learner","Teacher","Admin"});
            if(!IsPostBack)
            {
                CaptchaHelper.Generate("ContactCaptcha");
                if(CurrentUserHelper.IsAuthenticated())
                {
                    try{DataTable rows=DatabaseHelper.ExecuteTable("SELECT FullName,Email FROM dbo.[User] WHERE UserID=@id",new[] {new SqlParameter("@id",CurrentUserHelper.GetUserID().Value)});if(rows.Rows.Count==1){txtName.Text=(string)rows.Rows[0]["FullName"];txtEmail.Text=(string)rows.Rows[0]["Email"];}}
                    catch(SqlException){MessageHelper.SetError("Account details could not be pre-filled. Enter them below.");}
                }
                ViewState["SendToken"]="ContactSend_"+Guid.NewGuid().ToString("N");Session[(string)ViewState["SendToken"]]=true;
            }
            lblCaptcha.Text=CaptchaHelper.Question("ContactCaptcha");
            txtName.Text=txtName.Text.Trim();txtEmail.Text=txtEmail.Text.Trim();txtSubject.Text=txtSubject.Text.Trim();txtMessage.Text=txtMessage.Text.Trim();
        }
        protected void ValidateContact(object source,ServerValidateEventArgs args)
        {
            args.IsValid=txtName.Text.Length>=2 && txtName.Text.Length<=100 && txtSubject.Text.Length>=3 && txtSubject.Text.Length<=100 && txtMessage.Text.Length>=10 && txtMessage.Text.Length<=2000 && txtEmail.Text.Length<=100 && Regex.IsMatch(txtEmail.Text,@"^[^\s@]+@[^\s@.]+(?:\.[^\s@.]+)+$");
        }
        protected void ValidateCaptcha(object source,ServerValidateEventArgs args)
        {
            args.IsValid=CaptchaHelper.Check(txtCaptcha.Text,"ContactCaptcha");
            if(!args.IsValid){CaptchaHelper.Generate("ContactCaptcha");lblCaptcha.Text=CaptchaHelper.Question("ContactCaptcha");txtCaptcha.Text="";}
        }
        protected void Send(object sender,EventArgs e)
        {
            if(!Page.IsValid)return;
            if(ViewState["SendToken"]==null || !Equals(Session[(string)ViewState["SendToken"]],true)) {MessageHelper.SetError("This form was already submitted. Reload to send another message.");return;}
            try
            {
                DatabaseHelper.ExecuteNonQuery("INSERT dbo.ContactMessage(UserID,SenderName,SenderEmail,Subject,Message,SentDate,IsRead) VALUES(@user,@name,@email,@subject,@message,SYSUTCDATETIME(),0)",new[] {new SqlParameter("@user",SqlDbType.Int){Value=(object)CurrentUserHelper.GetUserID()??DBNull.Value},new SqlParameter("@name",SqlDbType.NVarChar,100){Value=txtName.Text},new SqlParameter("@email",SqlDbType.NVarChar,100){Value=txtEmail.Text},new SqlParameter("@subject",SqlDbType.NVarChar,100){Value=txtSubject.Text},new SqlParameter("@message",SqlDbType.NVarChar,2000){Value=txtMessage.Text}});
                Session.Remove((string)ViewState["SendToken"]);Session.Remove("ContactCaptcha");MessageHelper.SetSuccess("Your message has been sent to the administrator.");Response.Redirect("Contact.aspx");
            }
            catch(SqlException){MessageHelper.SetError("Your message could not be sent. Please try again.");}
        }
    }
}