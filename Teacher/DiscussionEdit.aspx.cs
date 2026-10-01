using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using LearningSystem.Helpers;
namespace LearningSystem.Teacher
{
    public partial class DiscussionEdit : Page
    {
        private static readonly string Kind="Discussion";
        private int activityID,topicID,courseID;
        protected void Page_Load(object sender,EventArgs e)
        {
            AccessHelper.RequireRole(CurrentUserHelper.AuthorRoles);
            bool edit=Request.QueryString["id"]!=null;
            if(edit && Request.QueryString["topicId"]!=null){Response.Redirect("~/AccessDenied.aspx");return;}
            DataRow activity=null;
            if(edit)
            {
                activityID=CourseHelper.QueryID("id");
                if(!AccessHelper.IsOwnerOfActivity(CurrentUserHelper.GetUserID().Value,activityID)){Response.Redirect("~/AccessDenied.aspx");return;}
                activity=ActivityHelper.Find(activityID);
                if((string)activity["ActivityType"]!=Kind){Response.Redirect("~/NotFound.aspx");return;}
                topicID=(int)activity["TopicID"];
            }
            else topicID=CourseHelper.QueryID("topicId");
            if(!AccessHelper.IsOwnerOfTopic(CurrentUserHelper.GetUserID().Value,topicID)){Response.Redirect("~/AccessDenied.aspx");return;}
            courseID=Convert.ToInt32(DatabaseHelper.ExecuteScalar("SELECT CourseID FROM dbo.Topic WHERE TopicID=@id",ActivityHelper.ID(topicID)));
            ((SiteMaster)Master).Breadcrumb=edit ? BreadcrumbHelper.ForActivity(activityID) : BreadcrumbHelper.ForCourse(courseID);
            pnlQuiz.Visible=Kind=="Quiz";pnlClosed.Visible=Kind=="Discussion";
            btnDelete.Visible=edit;lnkPreview.Visible=edit;lnkPreview.NavigateUrl="~/Member/"+(Kind=="Quiz" ? "Quiz" : "Discussion")+".aspx?id="+activityID+"&preview=1";
            if(!IsPostBack)
            {
                ViewState["SaveToken"]=CurrentUserHelper.CreateEditToken();
                if(edit)
                {
                    txtTitle.Text=(string)activity["Title"];txtDescription.Text=Convert.ToString(activity["Description"]);txtOrder.Text=activity["SortOrder"].ToString();ddlStatus.SelectedValue=(string)activity["Status"];
                    if(Kind=="Quiz")
                    {
                        txtMinutes.Text=activity["TimeLimitMinutes"].ToString();txtAttempts.Text=activity["MaxAttempts"].ToString();
                        bool locked=ContentLockHelper.HasAttempts(activityID);txtMinutes.Enabled=!locked;txtAttempts.Enabled=!locked;txtOrder.Enabled=!locked;lblLock.Visible=locked;
                    }
                    else chkClosed.Checked=(bool)activity["IsClosed"];
                }
                else txtOrder.Text=Convert.ToString(DatabaseHelper.ExecuteScalar("SELECT ISNULL(MAX(SortOrder),0)+1 FROM dbo.Activity WHERE TopicID=@id",ActivityHelper.ID(topicID)));
                
            }
        }
        protected void SaveSettings(object sender,EventArgs e)
        {
            if(!Page.IsValid)return;
            if(!CurrentUserHelper.CanSaveEdit(ViewState["SaveToken"])){MessageHelper.SetError("This form expired or was already saved. Reload the page.");return;}
            try
            {
                int order,minutes=0,attempts=0;
                if(!Int32.TryParse(txtOrder.Text,out order) || (Kind=="Quiz" && (!Int32.TryParse(txtMinutes.Text,out minutes) || !Int32.TryParse(txtAttempts.Text,out attempts))))throw new InvalidOperationException("Enter valid settings and order.");
                int id=ActivityHelper.Save(activityID,topicID,Kind,txtTitle.Text.Trim(),txtDescription.Text.Trim(),order,minutes,attempts,chkClosed.Checked,ddlStatus.SelectedValue);
                CurrentUserHelper.CompleteEdit(ViewState["SaveToken"]);MessageHelper.SetSuccess("Activity settings saved.");Response.Redirect("DiscussionEdit.aspx?id="+id);
            }
            catch(InvalidOperationException ex){MessageHelper.SetError(ex.Message);}
            catch(SqlException){MessageHelper.SetError("Settings could not be saved. Check the values and try again.");}
        }
        protected void DeleteActivity(object sender,EventArgs e)
        {
            if(!Page.IsValid)return;
            try
            {
                ValidationResult result=DeleteHelper.DeleteActivity(activityID);
                if(!result.IsValid){MessageHelper.SetError(result.Message);return;}
                MessageHelper.SetSuccess(result.Message);Response.Redirect("CourseBuilder.aspx?id="+courseID);
            }
            catch(SqlException){MessageHelper.SetError("Activity could not be deleted. Please try again.");}
        }
        protected void Cancel(object sender,EventArgs e){Response.Redirect("CourseBuilder.aspx?id="+courseID);}
        
    }
}

