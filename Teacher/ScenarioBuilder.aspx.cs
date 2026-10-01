using System;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Web.UI;
using System.Web.UI.WebControls;
using LearningSystem.Helpers;
namespace LearningSystem.Teacher
{
    public partial class ScenarioBuilder : Page
    {
        private int activityID,topicID,courseID;
        private int EditingStep {get{return (int)(ViewState["StepID"]??0);}set{ViewState["StepID"]=value;}}
        private int EditingChoice {get{return (int)(ViewState["ChoiceID"]??0);}set{ViewState["ChoiceID"]=value;}}
        protected void Page_Load(object sender,EventArgs e)
        {
            AccessHelper.RequireRole(CurrentUserHelper.AuthorRoles);bool edit=Request.QueryString["id"]!=null;
            if(edit && Request.QueryString["topicId"]!=null){Response.Redirect("~/AccessDenied.aspx");return;}
            DataRow a=null;
            if(edit)
            {
                activityID=CourseHelper.QueryID("id");
                if(!AccessHelper.IsOwnerOfActivity(CurrentUserHelper.GetUserID().Value,activityID)){Response.Redirect("~/AccessDenied.aspx");return;}
                a=ActivityHelper.Find(activityID);
                if(a==null || (string)a["ActivityType"]!="Scenario"){Response.Redirect("~/NotFound.aspx");return;}
                topicID=(int)a["TopicID"];
            }
            else topicID=CourseHelper.QueryID("topicId");
            if(!AccessHelper.IsOwnerOfTopic(CurrentUserHelper.GetUserID().Value,topicID)){Response.Redirect("~/AccessDenied.aspx");return;}
            courseID=Convert.ToInt32(DatabaseHelper.ExecuteScalar("SELECT CourseID FROM dbo.Topic WHERE TopicID=@id",ActivityHelper.ID(topicID)));
            ((SiteMaster)Master).Breadcrumb=edit ? BreadcrumbHelper.ForActivity(activityID) : BreadcrumbHelper.ForCourse(courseID);
            pnlContent.Visible=edit;btnPublish.Visible=edit;btnDelete.Visible=edit;lnkPreview.Visible=edit;
            lnkPreview.NavigateUrl="~/Member/Scenario.aspx?id="+activityID+"&preview=1";
            if(!IsPostBack)
            {
                ViewState["SaveToken"]=CurrentUserHelper.CreateEditToken();
                if(edit)
                {
                    txtTitle.Text=(string)a["Title"];txtDescription.Text=Convert.ToString(a["Description"]);txtOrder.Text=a["SortOrder"].ToString();ddlStatus.SelectedValue=(string)a["Status"];
                    bool locked=ContentLockHelper.HasAttempts(activityID);lblLock.Visible=locked;txtOrder.Enabled=!locked;pnlStartForm.Visible=!locked;pnlStepForm.Visible=!locked;pnlChoiceForm.Visible=!locked;
                    DataTable steps=ScenarioHelper.Steps(activityID),choices=ScenarioHelper.Choices(activityID);
                    gvSteps.DataSource=steps;gvSteps.DataBind();gvChoices.DataSource=choices;gvChoices.DataBind();
                    BindSteps(ddlStart,steps,false);BindSteps(ddlFrom,steps,true);BindSteps(ddlNext,steps,false);
                    litStart.Text=a.IsNull("StartStepID") ? "Not selected" : Convert.ToString(a["StartStepID"]);
                    if(!a.IsNull("StartStepID"))ddlStart.SelectedValue=a["StartStepID"].ToString();
                    gvSummary.DataSource=ScenarioHelper.Summary(activityID);gvSummary.DataBind();
                }
                else txtOrder.Text=Convert.ToString(DatabaseHelper.ExecuteScalar("SELECT ISNULL(MAX(SortOrder),0)+1 FROM dbo.Activity WHERE TopicID=@id",ActivityHelper.ID(topicID)));
            }
        }
        private void BindSteps(DropDownList list,DataTable steps,bool nonEnding)
        {
            list.Items.Clear();list.Items.Add(new ListItem("Choose a step",""));
            foreach(DataRow s in steps.Rows)
            {
                if(nonEnding && (bool)s["IsEnding"])continue;
                string text=(string)s["StepText"];if(text.Length>80)text=text.Substring(0,80)+"…";
                list.Items.Add(new ListItem(s["StepID"]+": "+text,s["StepID"].ToString()));
            }
        }
        private bool FormAvailable()
        {
            if(CurrentUserHelper.CanSaveEdit(ViewState["SaveToken"]))return true;
            MessageHelper.SetError("This form expired or was already saved. Reload before saving again.");return false;
        }
        private void Saved(string message)
        {
            CurrentUserHelper.CompleteEdit(ViewState["SaveToken"]);MessageHelper.SetSuccess(message);Response.Redirect("ScenarioBuilder.aspx?id="+activityID);
        }
        protected void SaveSettings(object sender,EventArgs e){if(!Page.IsValid)return;SaveSettingsCore(ddlStatus.SelectedValue);}
        protected void Publish(object sender,EventArgs e){if(!Page.IsValid)return;SaveSettingsCore("Published");}
        private void SaveSettingsCore(string status)
        {
            if(!FormAvailable())return;
            try
            {
                int order;if(!Int32.TryParse(txtOrder.Text,out order))throw new InvalidOperationException("Enter a positive order.");
                activityID=ScenarioHelper.SaveSettings(activityID,topicID,txtTitle.Text.Trim(),txtDescription.Text.Trim(),order,status);Saved(status=="Published" ? "Scenario checked and published." : "Scenario settings saved.");
            }
            catch(UnauthorizedAccessException){Response.Redirect("~/AccessDenied.aspx");}
            catch(InvalidOperationException ex){MessageHelper.SetError(ex.Message);}
            catch(SqlException){MessageHelper.SetError("The scenario could not be saved. Please try again.");}
        }
        protected void SaveStart(object sender,EventArgs e)
        {
            if(!Page.IsValid)return;if(!FormAvailable())return;
            try{int step;if(!Int32.TryParse(ddlStart.SelectedValue,out step) || step<1)throw new InvalidOperationException("Choose a start step.");ScenarioHelper.SaveStart(activityID,step);Saved("Start step saved.");}
            catch(UnauthorizedAccessException){Response.Redirect("~/AccessDenied.aspx");}
            catch(InvalidOperationException ex){MessageHelper.SetError(ex.Message);}
            catch(SqlException){MessageHelper.SetError("The start step could not be saved. Please try again.");}
        }
        protected void ValidateStep(object sender,ServerValidateEventArgs e)
        {
            e.IsValid=true;
            if(chkEnding.Checked)e.IsValid=ScenarioHelper.Outcome(ddlOutcome.SelectedValue) && txtFeedback.Text.Trim().Length>=10 && txtFeedback.Text.Trim().Length<=500;
            bool image=fuImage.HasFile;
            if(image)e.IsValid=e.IsValid && UploadHelper.Validate(fuImage.PostedFile,"Image",false).IsValid;
            if(EditingStep>0)
            {
                try{DataRow step=ScenarioHelper.Step(ScenarioHelper.Steps(activityID),EditingStep);image=image || (!chkRemoveImage.Checked && !String.IsNullOrEmpty(Convert.ToString(step["ImagePath"])));}
                catch(InvalidOperationException){e.IsValid=false;}
            }
            if(image)e.IsValid=e.IsValid && txtAlt.Text.Trim().Length>=5 && txtAlt.Text.Trim().Length<=150;
        }
        protected void SaveStep(object sender,EventArgs e)
        {
            if(!Page.IsValid)return;if(!FormAvailable())return;
            try
            {
                string cleanup=ScenarioHelper.SaveStep(activityID,EditingStep,txtStep.Text.Trim(),chkEnding.Checked,ddlOutcome.SelectedValue,txtFeedback.Text.Trim(),txtAlt.Text.Trim(),fuImage.HasFile ? fuImage.PostedFile : null,chkRemoveImage.Checked);
                Saved("Step saved. "+cleanup);
            }
            catch(UnauthorizedAccessException){MessageHelper.SetError("Access or file permission denied. The step could not be saved.");}
            catch(InvalidOperationException ex){MessageHelper.SetError(ex.Message);}
            catch(ArgumentException ex){MessageHelper.SetError(ex.Message);}
            catch(IOException){MessageHelper.SetError("The image could not be saved. Please try again.");}
            catch(SqlException){MessageHelper.SetError("The step could not be saved. Please try again.");}
        }
        protected void StepCommand(object sender,GridViewCommandEventArgs e)
        {
            if(!Page.IsValid)return;
            int step;if(!Int32.TryParse(Convert.ToString(e.CommandArgument),out step) || step<1){Response.Redirect("~/AccessDenied.aspx");return;}
            try
            {
                DataRow row=ScenarioHelper.Step(ScenarioHelper.Steps(activityID),step);
                if(ContentLockHelper.HasAttempts(activityID))throw new InvalidOperationException("Steps are locked after attempts.");
                if(e.CommandName=="EditStep")
                {
                    EditingStep=step;litEditingStep.Text=step.ToString();txtStep.Text=(string)row["StepText"];chkEnding.Checked=(bool)row["IsEnding"];ddlOutcome.SelectedValue=Convert.ToString(row["Outcome"]);txtFeedback.Text=Convert.ToString(row["Feedback"]);txtAlt.Text=Convert.ToString(row["ImageAlt"]);chkRemoveImage.Checked=false;litImage.Text=ScenarioHelper.ImageMarkup(row);
                }
                else if(e.CommandName=="DeleteStep")
                {
                    if(!FormAvailable())return;
                    ValidationResult result=DeleteHelper.DeleteStep(step);if(!result.IsValid){MessageHelper.SetError(result.Message);return;}Saved(result.Message);
                }
            }
            catch(UnauthorizedAccessException){Response.Redirect("~/AccessDenied.aspx");}
            catch(InvalidOperationException ex){MessageHelper.SetError(ex.Message);}
            catch(ArgumentException){MessageHelper.SetError("The image path is invalid. The step was not deleted.");}
            catch(SqlException){MessageHelper.SetError("The step could not be changed. Please try again.");}
        }
        protected void SaveChoice(object sender,EventArgs e)
        {
            if(!Page.IsValid)return;if(!FormAvailable())return;
            try
            {
                int from,next;if(!Int32.TryParse(ddlFrom.SelectedValue,out from) || !Int32.TryParse(ddlNext.SelectedValue,out next))throw new InvalidOperationException("Choose valid source and destination steps.");
                ScenarioHelper.SaveChoice(activityID,EditingChoice,from,next,txtChoice.Text.Trim(),false);Saved("Choice saved.");
            }
            catch(UnauthorizedAccessException){Response.Redirect("~/AccessDenied.aspx");}
            catch(InvalidOperationException ex){MessageHelper.SetError(ex.Message);}
            catch(SqlException){MessageHelper.SetError("The choice could not be saved. Please try again.");}
        }
        protected void ChoiceCommand(object sender,GridViewCommandEventArgs e)
        {
            if(!Page.IsValid)return;
            int choice;if(!Int32.TryParse(Convert.ToString(e.CommandArgument),out choice) || choice<1){Response.Redirect("~/AccessDenied.aspx");return;}
            try
            {
                DataRow row=null;foreach(DataRow ch in ScenarioHelper.Choices(activityID).Rows)if((int)ch["ChoiceID"]==choice)row=ch;
                if(row==null)throw new UnauthorizedAccessException();
                if(ContentLockHelper.HasAttempts(activityID))throw new InvalidOperationException("Choices are locked after attempts.");
                if(e.CommandName=="EditChoice")
                {
                    EditingChoice=choice;litEditingChoice.Text=choice.ToString();ddlFrom.SelectedValue=row["FromStepID"].ToString();ddlNext.SelectedValue=row["NextStepID"].ToString();txtChoice.Text=(string)row["ChoiceText"];
                }
                else if(e.CommandName=="DeleteChoice")
                {
                    if(!FormAvailable())return;ScenarioHelper.SaveChoice(activityID,choice,0,0,"",true);Saved("Choice deleted.");
                }
            }
            catch(UnauthorizedAccessException){Response.Redirect("~/AccessDenied.aspx");}
            catch(InvalidOperationException ex){MessageHelper.SetError(ex.Message);}
            catch(SqlException){MessageHelper.SetError("The choice could not be changed. Please try again.");}
        }
        protected void DeleteScenario(object sender,EventArgs e)
        {
            if(!Page.IsValid)return;if(!FormAvailable())return;
            if(activityID<1){Response.Redirect("~/AccessDenied.aspx");return;}
            try
            {
                ValidationResult result=DeleteHelper.DeleteActivity(activityID);if(!result.IsValid){MessageHelper.SetError(result.Message);return;}
                CurrentUserHelper.CompleteEdit(ViewState["SaveToken"]);MessageHelper.SetSuccess(result.Message);Response.Redirect("CourseBuilder.aspx?id="+courseID);
            }
            catch(SqlException){MessageHelper.SetError("The scenario could not be deleted. Please try again.");}
        }
        protected void CancelEdit(object sender,EventArgs e){Response.Redirect("ScenarioBuilder.aspx?id="+activityID);}
        protected void Cancel(object sender,EventArgs e){Response.Redirect("CourseBuilder.aspx?id="+courseID);}
    }
}
