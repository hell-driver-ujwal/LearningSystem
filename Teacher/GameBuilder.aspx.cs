using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using LearningSystem.Helpers;
namespace LearningSystem.Teacher
{
    public partial class GameBuilder : Page
    {
        private int activityID,topicID,courseID;
        private string template;
        private int EditingItem {get{return (int)(ViewState["ItemID"]??0);}set{ViewState["ItemID"]=value;}}
        private int EditingGroup {get{return (int)(ViewState["GroupID"]??0);}set{ViewState["GroupID"]=value;}}
        protected void Page_Load(object sender,EventArgs e)
        {
            AccessHelper.RequireRole(CurrentUserHelper.AuthorRoles);bool edit=Request.QueryString["id"]!=null;
            if(edit && Request.QueryString["topicId"]!=null){Response.Redirect("~/AccessDenied.aspx");return;}
            DataRow activity=null;
            if(edit)
            {
                activityID=CourseHelper.QueryID("id");
                if(!AccessHelper.IsOwnerOfActivity(CurrentUserHelper.GetUserID().Value,activityID)){Response.Redirect("~/AccessDenied.aspx");return;}
                activity=ActivityHelper.Find(activityID);
                if(activity==null || (string)activity["ActivityType"]!="Game"){Response.Redirect("~/NotFound.aspx");return;}
                topicID=(int)activity["TopicID"];template=(string)activity["GameTemplate"];
            }
            else topicID=CourseHelper.QueryID("topicId");
            if(!AccessHelper.IsOwnerOfTopic(CurrentUserHelper.GetUserID().Value,topicID)){Response.Redirect("~/AccessDenied.aspx");return;}
            courseID=Convert.ToInt32(DatabaseHelper.ExecuteScalar("SELECT CourseID FROM dbo.Topic WHERE TopicID=@id",ActivityHelper.ID(topicID)));
            ((SiteMaster)Master).Breadcrumb=edit ? BreadcrumbHelper.ForActivity(activityID) : BreadcrumbHelper.ForCourse(courseID);
            pnlItems.Visible=edit;pnlGroups.Visible=edit && template=="Sort";pnlResults.Visible=edit;btnDelete.Visible=edit;lnkPreview.Visible=edit;
            lnkPreview.NavigateUrl="~/Member/PlayGame.aspx?id="+activityID+"&preview=1";
            pnlMatch.Visible=template!="Sort";pnlGroupChoice.Visible=template=="Sort";
            pnlItemText.Visible=template!="TrueFalse";pnlTruth.Visible=template=="TrueFalse";
            SetItemLabels();
            if(!IsPostBack)
            {
                ViewState["SaveToken"]=CurrentUserHelper.CreateEditToken();
                if(edit)
                {
                    txtTitle.Text=(string)activity["Title"];txtDescription.Text=Convert.ToString(activity["Description"]);txtOrder.Text=activity["SortOrder"].ToString();ddlStatus.SelectedValue=(string)activity["Status"];ddlTemplate.SelectedValue=template;
                    DataTable items=GameHelper.Items(activityID),groups=GameHelper.Groups(activityID);
                    bool locked=ContentLockHelper.HasAttempts(activityID);lblLock.Visible=locked;txtOrder.Enabled=!locked;
                    ddlTemplate.Enabled=!locked && items.Rows.Count==0 && groups.Rows.Count==0;
                    pnlItemForm.Visible=!locked;pnlGroupForm.Visible=!locked;
                    gvItems.DataSource=items;gvItems.DataBind();gvGroups.DataSource=groups;gvGroups.DataBind();
                    ddlGroup.DataSource=groups;ddlGroup.DataTextField="GroupName";ddlGroup.DataValueField="GroupID";ddlGroup.DataBind();ddlGroup.Items.Insert(0,new ListItem("Choose a group",""));
                    gvResults.DataSource=GameHelper.TeacherResults(activityID);gvResults.DataBind();
                }
                else txtOrder.Text=Convert.ToString(DatabaseHelper.ExecuteScalar("SELECT ISNULL(MAX(SortOrder),0)+1 FROM dbo.Activity WHERE TopicID=@id",ActivityHelper.ID(topicID)));
            }
        }
        // Each game type stores its two sides differently, so the field labels change with the template.
        private void SetItemLabels()
        {
            switch(template)
            {
                case "Scramble": lblItem.Text="Word (3 to 15 letters, A to Z only)";lblMatch.Text="Hint shown to the learner (1 to 200 characters)";break;
                case "Flashcards": lblItem.Text="Front of the card (1 to 100 characters)";lblMatch.Text="Back of the card (1 to 200 characters)";break;
                case "FillBlank": lblItem.Text="Missing word or phrase (1 to 100 characters)";lblMatch.Text="Sentence with one blank written as ___ (1 to 200 characters)";break;
                case "TrueFalse": lblMatch.Text="Statement (1 to 200 characters)";break;
                case "Sequence": lblItem.Text="Step text (1 to 100 characters)";lblMatch.Text="Position in the correct order (1, 2, 3 ...)";break;
                case "Sort": lblItem.Text="Item to sort (1 to 100 characters)";break;
                default: lblItem.Text="First side of the pair (1 to 100 characters)";lblMatch.Text="Matching second side (1 to 200 characters)";break;
            }
        }
        private string ItemText(){return template=="TrueFalse" ? ddlTruth.SelectedValue : txtItem.Text.Trim();}
        private bool FormAvailable()
        {
            if(CurrentUserHelper.CanSaveEdit(ViewState["SaveToken"]))return true;
            MessageHelper.SetError("This form expired or was already saved. Reload before saving again.");return false;
        }
        private void Saved(string message)
        {
            CurrentUserHelper.CompleteEdit(ViewState["SaveToken"]);MessageHelper.SetSuccess(message);Response.Redirect("GameBuilder.aspx?id="+activityID);
        }
        protected void SaveSettings(object sender,EventArgs e)
        {
            if(!Page.IsValid)return;
            if(!FormAvailable())return;
            try
            {
                int order;if(!Int32.TryParse(txtOrder.Text,out order))throw new InvalidOperationException("Enter a positive order.");
                activityID=GameHelper.SaveSettings(activityID,topicID,txtTitle.Text.Trim(),txtDescription.Text.Trim(),order,ddlTemplate.SelectedValue,ddlStatus.SelectedValue);Saved("Game settings saved.");
            }
            catch(UnauthorizedAccessException){Response.Redirect("~/AccessDenied.aspx");}
            catch(InvalidOperationException ex){MessageHelper.SetError(ex.Message);}
            catch(SqlException){MessageHelper.SetError("The game could not be saved. Please try again.");}
        }
        protected void ValidateItem(object sender,ServerValidateEventArgs e)
        {
            string text=ItemText(),match=txtMatch.Text.Trim();int group;
            e.IsValid=text.Length>=1 && text.Length<=100;
            if(template=="Scramble")e.IsValid=e.IsValid && System.Text.RegularExpressions.Regex.IsMatch(text,"^[A-Za-z]{3,15}$");
            if(template=="Sort")e.IsValid=e.IsValid && Int32.TryParse(ddlGroup.SelectedValue,out group) && group>0;
            else e.IsValid=e.IsValid && match.Length>=1 && match.Length<=200;
            if(template=="FillBlank")e.IsValid=e.IsValid && GameHelper.IsBlankSentence(match);
            if(template=="Sequence")e.IsValid=e.IsValid && GameHelper.Position(match)>=1 && GameHelper.Position(match)<=GameHelper.MaxItems(template);
            if(!e.IsValid)cvItem.ErrorMessage=template=="FillBlank" ? "Write the sentence with exactly one blank as three underscores: ___" : template=="Sequence" ? "Enter the step's position as a whole number from 1 to 10." : template=="Scramble" ? "Scramble words must be 3 to 15 letters with no spaces." : "Fill in both fields within the character limits shown.";
        }
        protected void SaveItem(object sender,EventArgs e)
        {
            if(!Page.IsValid)return;
            if(!FormAvailable())return;
            try{int group;Int32.TryParse(ddlGroup.SelectedValue,out group);GameHelper.SaveItem(activityID,EditingItem,ItemText(),txtMatch.Text.Trim(),group,false);Saved("Game item saved.");}
            catch(UnauthorizedAccessException){Response.Redirect("~/AccessDenied.aspx");}
            catch(InvalidOperationException ex){MessageHelper.SetError(ex.Message);}
            catch(SqlException){MessageHelper.SetError("The item could not be saved. Please try again.");}
        }
        protected void SaveGroup(object sender,EventArgs e)
        {
            if(!Page.IsValid)return;
            if(!FormAvailable())return;
            try{GameHelper.SaveGroup(activityID,EditingGroup,txtGroupName.Text.Trim(),false);Saved("Group saved.");}
            catch(UnauthorizedAccessException){Response.Redirect("~/AccessDenied.aspx");}
            catch(InvalidOperationException ex){MessageHelper.SetError(ex.Message);}
            catch(SqlException){MessageHelper.SetError("The group could not be saved. Please try again.");}
        }
        protected void ItemCommand(object sender,GridViewCommandEventArgs e)
        {
            if(!Page.IsValid)return;
            int id;if(!Int32.TryParse(Convert.ToString(e.CommandArgument),out id) || id<1){Response.Redirect("~/AccessDenied.aspx");return;}
            try
            {
                DataRow[] rows=GameHelper.Items(activityID).Select("ItemID="+id);
                if(rows.Length!=1){Response.Redirect("~/AccessDenied.aspx");return;}
                if(ContentLockHelper.HasAttempts(activityID)){MessageHelper.SetError("Game items are locked after attempts.");return;}
                if(e.CommandName=="EditItem")
                {
                    EditingItem=id;txtItem.Text=(string)rows[0]["ItemText"];txtMatch.Text=Convert.ToString(rows[0]["MatchText"]);if(template=="TrueFalse")ddlTruth.SelectedValue=(string)rows[0]["ItemText"];
                    if(!rows[0].IsNull("GroupID"))ddlGroup.SelectedValue=rows[0]["GroupID"].ToString();
                }
                else if(e.CommandName=="DeleteItem"){GameHelper.SaveItem(activityID,id,"","",0,true);Saved("Item deleted.");}
            }
            catch(UnauthorizedAccessException){Response.Redirect("~/AccessDenied.aspx");}
            catch(InvalidOperationException ex){MessageHelper.SetError(ex.Message);}
            catch(SqlException){MessageHelper.SetError("The item could not be changed. Please try again.");}
        }
        protected void GroupCommand(object sender,GridViewCommandEventArgs e)
        {
            if(!Page.IsValid)return;
            int id;if(!Int32.TryParse(Convert.ToString(e.CommandArgument),out id) || id<1){Response.Redirect("~/AccessDenied.aspx");return;}
            try
            {
                DataRow[] rows=GameHelper.Groups(activityID).Select("GroupID="+id);
                if(rows.Length!=1 || template!="Sort"){Response.Redirect("~/AccessDenied.aspx");return;}
                if(ContentLockHelper.HasAttempts(activityID)){MessageHelper.SetError("Groups are locked after attempts.");return;}
                if(e.CommandName=="EditGroup"){EditingGroup=id;txtGroupName.Text=(string)rows[0]["GroupName"];}
                else if(e.CommandName=="DeleteGroup"){GameHelper.SaveGroup(activityID,id,"",true);Saved("Group deleted.");}
            }
            catch(UnauthorizedAccessException){Response.Redirect("~/AccessDenied.aspx");}
            catch(InvalidOperationException ex){MessageHelper.SetError(ex.Message);}
            catch(SqlException){MessageHelper.SetError("The group could not be changed. Please try again.");}
        }
        protected void DeleteGame(object sender,EventArgs e)
        {
            if(!Page.IsValid)return;
            if(activityID<1){Response.Redirect("~/AccessDenied.aspx");return;}
            try
            {
                ValidationResult result=DeleteHelper.DeleteActivity(activityID);
                if(!result.IsValid){MessageHelper.SetError(result.Message);return;}
                MessageHelper.SetSuccess(result.Message);Response.Redirect("CourseBuilder.aspx?id="+courseID);
            }
            catch(SqlException){MessageHelper.SetError("The game could not be deleted. Please try again.");}
        }
        protected void CancelEdit(object sender,EventArgs e){Response.Redirect("GameBuilder.aspx?id="+activityID);}
        protected void Cancel(object sender,EventArgs e){Response.Redirect("CourseBuilder.aspx?id="+courseID);}
    }
}
