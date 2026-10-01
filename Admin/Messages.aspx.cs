using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using LearningSystem.Helpers;
namespace LearningSystem.Admin
{
    public partial class Messages : Page
    {
        private int messageID;
        protected void Page_Load(object sender,EventArgs e)
        {
            AccessHelper.RequireRole(new[] {"Admin"});
            if(Request.QueryString["id"]!=null)messageID=CourseHelper.QueryID("id");
            try
            {
                if(messageID>0)
                {
                    DataTable rows=DatabaseHelper.ExecuteTable("SELECT * FROM dbo.ContactMessage WHERE MessageID=@id",new[] {new SqlParameter("@id",messageID)});
                    if(rows.Rows.Count!=1){Response.Redirect("~/NotFound.aspx");return;}
                    DataRow row=rows.Rows[0];pnlMessage.Visible=true;litSubject.Text=(string)row["Subject"];litSender.Text=row["SenderName"]+" <"+row["SenderEmail"]+"> · "+((DateTime)row["SentDate"]).ToString("yyyy-MM-dd HH:mm")+" UTC";litBody.Text=(string)row["Message"];btnRead.Enabled=!(bool)row["IsRead"];
                }
                if(!IsPostBack)BindMessages();
            }
            catch(SqlException){MessageHelper.SetError("Messages could not be loaded.");}
        }
        private void BindMessages(){gvMessages.DataSource=DatabaseHelper.ExecuteTable("SELECT * FROM dbo.ContactMessage ORDER BY SentDate DESC,MessageID DESC",null);gvMessages.DataBind();}
        protected void MarkRead(object sender,EventArgs e)
        {
            if(!Page.IsValid)return;
            AccessHelper.RequireRole(new[] {"Admin"});
            try{DatabaseHelper.ExecuteNonQuery("UPDATE dbo.ContactMessage SET IsRead=1 WHERE MessageID=@id",new[] {new SqlParameter("@id",messageID)});MessageHelper.SetSuccess("Message marked as read.");Response.Redirect("Messages.aspx?id="+messageID);}
            catch(SqlException){MessageHelper.SetError("Message could not be updated.");}
        }
        protected void MessageCommand(object sender,GridViewCommandEventArgs e)
        {
            if(!Page.IsValid)return;if(e.CommandName!="RemoveMessage")return;AccessHelper.RequireRole(new[] {"Admin"});
            int id;if(!Int32.TryParse(Convert.ToString(e.CommandArgument),out id)||id<1){Response.Redirect("~/AccessDenied.aspx");return;}
            try{using(SqlConnection c=DatabaseHelper.OpenConnection())using(SqlTransaction t=c.BeginTransaction()){int changed=DatabaseHelper.ExecuteNonQuery(c,t,"DELETE FROM dbo.ContactMessage WHERE MessageID=@id",new[] {new SqlParameter("@id",id)});if(changed!=1){MessageHelper.SetError("Message no longer exists.");return;}t.Commit();}MessageHelper.SetSuccess("Message deleted.");Response.Redirect("Messages.aspx");}
            catch(SqlException){MessageHelper.SetError("Message could not be deleted.");}
        }
        protected void ChangePage(object sender,GridViewPageEventArgs e){gvMessages.PageIndex=e.NewPageIndex;try{BindMessages();}catch(SqlException){MessageHelper.SetError("Messages could not be loaded.");}}
    }
}
