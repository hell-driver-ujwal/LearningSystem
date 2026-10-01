using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using LearningSystem.Helpers;
namespace LearningSystem.Admin
{
    public partial class FAQ : Page
    {
        protected void Page_Load(object sender,EventArgs e)
        {
            AccessHelper.RequireRole(new[] {"Admin"});
            txtQuestion.Text=txtQuestion.Text.Trim();txtAnswer.Text=txtAnswer.Text.Trim();
            if(!IsPostBack){ViewState["FAQID"]=0;ViewState["SaveToken"]=CurrentUserHelper.CreateEditToken();BindFAQ();}
        }
        private void BindFAQ(){try{gvFAQ.DataSource=DatabaseHelper.ExecuteTable("SELECT * FROM dbo.FAQ ORDER BY SortOrder,FAQID",null);gvFAQ.DataBind();}catch(SqlException){MessageHelper.SetError("FAQs could not be loaded.");}}
        protected void Save(object sender,EventArgs e)
        {
            if(!Page.IsValid)return;AccessHelper.RequireRole(new[] {"Admin"});
            int order;string audience=ddlAudience.SelectedValue;
            if(!Int32.TryParse(txtOrder.Text,out order)||order<1||order>100||txtQuestion.Text.Length<5||txtQuestion.Text.Length>200||txtAnswer.Text.Length<10||txtAnswer.Text.Length>2000||(audience!="All"&&audience!="Learner"&&audience!="Teacher")){MessageHelper.SetError("Check FAQ text, audience and order.");return;}
            if(!CurrentUserHelper.CanSaveEdit(ViewState["SaveToken"])){MessageHelper.SetError("Reload before saving another FAQ.");return;}
            int id=Convert.ToInt32(ViewState["FAQID"]);
            try
            {
                int changed=DatabaseHelper.ExecuteNonQuery(id==0 ? "INSERT dbo.FAQ(Question,Answer,Audience,SortOrder) VALUES(@q,@a,@audience,@order)" : "UPDATE dbo.FAQ SET Question=@q,Answer=@a,Audience=@audience,SortOrder=@order WHERE FAQID=@id",new[] {new SqlParameter("@id",id),new SqlParameter("@q",SqlDbType.NVarChar,200){Value=txtQuestion.Text},new SqlParameter("@a",SqlDbType.NVarChar,2000){Value=txtAnswer.Text},new SqlParameter("@audience",SqlDbType.NVarChar,7){Value=audience},new SqlParameter("@order",order)});
                if(changed!=1){MessageHelper.SetError("FAQ no longer exists.");return;}CurrentUserHelper.CompleteEdit(ViewState["SaveToken"]);MessageHelper.SetSuccess("FAQ saved.");Response.Redirect("FAQ.aspx");
            }
            catch(SqlException){MessageHelper.SetError("FAQ could not be saved.");}
        }
        protected void FAQCommand(object sender,GridViewCommandEventArgs e)
        {
            if(e.CommandName!="EditFAQ"&&e.CommandName!="RemoveFAQ")return;
            if(!Page.IsValid)return;AccessHelper.RequireRole(new[] {"Admin"});
            int id;if(!Int32.TryParse(Convert.ToString(e.CommandArgument),out id)||id<1){Response.Redirect("~/AccessDenied.aspx");return;}
            try
            {
                if(e.CommandName=="EditFAQ")
                {
                    DataTable rows=DatabaseHelper.ExecuteTable("SELECT * FROM dbo.FAQ WHERE FAQID=@id",new[] {new SqlParameter("@id",id)});
                    if(rows.Rows.Count!=1){MessageHelper.SetError("FAQ no longer exists.");return;}DataRow row=rows.Rows[0];ViewState["FAQID"]=id;txtQuestion.Text=(string)row["Question"];txtAnswer.Text=(string)row["Answer"];ddlAudience.SelectedValue=(string)row["Audience"];txtOrder.Text=Convert.ToString(row["SortOrder"]);
                }
                else
                {
                    using(SqlConnection c=DatabaseHelper.OpenConnection())using(SqlTransaction t=c.BeginTransaction()){int changed=DatabaseHelper.ExecuteNonQuery(c,t,"DELETE FROM dbo.FAQ WHERE FAQID=@id",new[] {new SqlParameter("@id",id)});if(changed!=1){MessageHelper.SetError("FAQ no longer exists.");return;}t.Commit();}MessageHelper.SetSuccess("FAQ deleted.");Response.Redirect("FAQ.aspx");
                }
            }
            catch(SqlException){MessageHelper.SetError("FAQ could not be changed.");}
        }
        protected void Cancel(object sender,EventArgs e){Response.Redirect("FAQ.aspx");}
    }
}
