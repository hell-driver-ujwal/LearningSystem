using System;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using LearningSystem.Helpers;
namespace LearningSystem.Learner
{
    public partial class MyBookmarks : Page
    {
        protected void Page_Load(object sender,EventArgs e)
        {
            AccessHelper.RequireRole(new[] {"Learner"});
            if(!IsPostBack)try{gvBookmarks.DataSource=BookmarkHelper.List();gvBookmarks.DataBind();}catch(SqlException){MessageHelper.SetError("Bookmarks could not be loaded.");}
        }
        protected void BookmarkCommand(object sender,GridViewCommandEventArgs e)
        {
            if(!Page.IsValid)return;
            if(e.CommandName!="RemoveBookmark")return;
            int id;if(!Int32.TryParse(Convert.ToString(e.CommandArgument),out id)||id<1){Response.Redirect("~/AccessDenied.aspx");return;}
            try{BookmarkHelper.Set(id,false);MessageHelper.SetSuccess("Bookmark removed.");Response.Redirect("MyBookmarks.aspx");}
            catch(UnauthorizedAccessException){Response.Redirect("~/AccessDenied.aspx");}
            catch(SqlException){MessageHelper.SetError("Bookmark could not be removed.");}
        }
    }
}
