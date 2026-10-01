using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using LearningSystem.Helpers;
namespace LearningSystem.Member
{
    public partial class Discussion : Page
    {
        private int activityID;
        private bool preview;
        private DataRow activity;
        private int Editing {get{return (int)(ViewState["Editing"]??0);}set{ViewState["Editing"]=value;}}
        private int ReplyTo {get{return (int)(ViewState["ReplyTo"]??0);}set{ViewState["ReplyTo"]=value;}}
        protected void Page_Load(object sender,EventArgs e)
        {
            AccessHelper.RequireRole(new[] {"Learner","Teacher","Admin"});activityID=CourseHelper.QueryID("id");preview=Request.QueryString["preview"]=="1";
            if(Request.QueryString["preview"]!=null && !preview){Response.Redirect("~/NotFound.aspx");return;}
            activity=ActivityHelper.Require(activityID,"Discussion",preview);
            litTitle.Text=Convert.ToString(activity["Title"]);litPrompt.Text=Convert.ToString(activity["Description"]);
            litStatus.Text=(bool)activity["IsClosed"] ? "Closed — read only. Authorized moderation remains available outside preview." : "Open discussion";
            ((SiteMaster)Master).Breadcrumb=BreadcrumbHelper.ForActivity(activityID);pnlPreview.Visible=preview;
            lnkBack.NavigateUrl=ActivityHelper.Back(activity);lnkExit.NavigateUrl=lnkBack.NavigateUrl;
            if(!IsPostBack){ViewState["SaveToken"]=CurrentUserHelper.CreateEditToken();BindPosts();}
            pnlEditor.Visible=!preview && (Editing>0 ? AccessHelper.CanEditPost(CurrentUserHelper.GetUserID().Value,Editing) : AccessHelper.CanWriteDiscussion(CurrentUserHelper.GetUserID().Value,activityID));
        }
        private void BindPosts()
        {
            DataTable posts=DatabaseHelper.ExecuteTable("SELECT p.*,u.FullName FROM dbo.DiscussionPost p JOIN dbo.[User] u ON u.UserID=p.UserID WHERE p.ActivityID=@id ORDER BY ISNULL(p.ParentPostID,p.PostID),CASE WHEN p.ParentPostID IS NULL THEN 0 ELSE 1 END,p.PostedDate,p.PostID",ActivityHelper.ID(activityID));
            lblEmpty.Visible=posts.Rows.Count==0;rptPosts.DataSource=posts;rptPosts.DataBind();
        }
        protected void BindPost(object sender,RepeaterItemEventArgs e)
        {
            if(e.Item.ItemType!=ListItemType.Item && e.Item.ItemType!=ListItemType.AlternatingItem)return;
            DataRowView post=(DataRowView)e.Item.DataItem;int id=(int)post["PostID"],user=CurrentUserHelper.GetUserID().Value;
            ((Button)e.Item.FindControl("btnReply")).Visible=!preview && post["ParentPostID"]==DBNull.Value && AccessHelper.CanWriteDiscussion(user,activityID);
            ((Button)e.Item.FindControl("btnEdit")).Visible=!preview && AccessHelper.CanEditPost(user,id);
            ((Button)e.Item.FindControl("btnRemove")).Visible=!preview && AccessHelper.CanDeletePost(user,id);
        }
        protected void PostCommand(object sender,RepeaterCommandEventArgs e)
        {
            if(!Page.IsValid)return;
            int id;if(preview || !Int32.TryParse(Convert.ToString(e.CommandArgument),out id)){Response.Redirect("~/AccessDenied.aspx");return;}
            DataTable rows=DatabaseHelper.ExecuteTable("SELECT * FROM dbo.DiscussionPost WHERE PostID=@post AND ActivityID=@id",new[] {new SqlParameter("@post",id),new SqlParameter("@id",activityID)});
            if(rows.Rows.Count!=1){Response.Redirect("~/AccessDenied.aspx");return;}
            int user=CurrentUserHelper.GetUserID().Value;
            if(e.CommandName=="EditPost")
            {
                if(!AccessHelper.CanEditPost(user,id)){Response.Redirect("~/AccessDenied.aspx");return;}
                Editing=id;ReplyTo=0;txtContent.Text=(string)rows.Rows[0]["Content"];litEditor.Text="Edit your post";pnlEditor.Visible=true;
            }
            else if(e.CommandName=="ReplyPost")
            {
                if(!AccessHelper.CanWriteDiscussion(user,activityID) || !rows.Rows[0].IsNull("ParentPostID")){Response.Redirect("~/AccessDenied.aspx");return;}
                ReplyTo=id;Editing=0;txtContent.Text="";litEditor.Text="Reply to "+id;pnlEditor.Visible=true;
            }
            else if(e.CommandName=="RemovePost")
            {
                try
                {
                    ValidationResult result=DeleteHelper.DeletePost(id);
                    if(!result.IsValid){Response.Redirect("~/AccessDenied.aspx");return;}
                    MessageHelper.SetSuccess(result.Message);Response.Redirect("Discussion.aspx?id="+activityID);
                }
                catch(SqlException){MessageHelper.SetError("The post could not be removed. Please try again.");}
            }
        }
        protected void SavePost(object sender,EventArgs e)
        {
            if(!Page.IsValid)return;
            if(preview){Response.Redirect("~/AccessDenied.aspx");return;}
            if(!CurrentUserHelper.CanSaveEdit(ViewState["SaveToken"])){MessageHelper.SetError("This form expired or was already saved. Reload before posting.");return;}
            try
            {
                DiscussionHelper.Save(activityID,Editing,ReplyTo,txtContent.Text.Trim());
                CurrentUserHelper.CompleteEdit(ViewState["SaveToken"]);MessageHelper.SetSuccess("Post saved.");Response.Redirect("Discussion.aspx?id="+activityID);
            }
            catch(UnauthorizedAccessException){Response.Redirect("~/AccessDenied.aspx");}
            catch(InvalidOperationException ex){MessageHelper.SetError(ex.Message);}
            catch(SqlException){MessageHelper.SetError("The post could not be saved. Please try again.");}
        }
        protected void Cancel(object sender,EventArgs e){Response.Redirect("Discussion.aspx?id="+activityID+(preview ? "&preview=1" : ""));}
    }
}
