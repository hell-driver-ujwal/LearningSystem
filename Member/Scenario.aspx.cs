using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using LearningSystem.Helpers;
namespace LearningSystem.Member
{
    public partial class Scenario : Page
    {
        private int activityID;private bool preview;private DataRow activity;
        protected void Page_Load(object sender,EventArgs e)
        {
            lnkMyResults.Visible=CurrentUserHelper.GetRole()=="Learner";
            AccessHelper.RequireRole(new[] {"Learner","Teacher","Admin"});activityID=CourseHelper.QueryID("id");preview=Request.QueryString["preview"]=="1";
            if(Request.QueryString["preview"]!=null && !preview){Response.Redirect("~/NotFound.aspx");return;}
            activity=ActivityHelper.Require(activityID,"Scenario",preview);
            // Navigation is exclusively session-controlled, never driven by a supplied step.
            if(Request.QueryString["stepId"]!=null || Request.QueryString["nextStepId"]!=null){Response.Redirect("~/AccessDenied.aspx");return;}
            ((SiteMaster)Master).Breadcrumb=BreadcrumbHelper.ForActivity(activityID);
            litTitle.Text=(string)activity["Title"];litDescription.Text=Convert.ToString(activity["Description"]);pnlPreview.Visible=preview;btnCancel.Text=preview ? "Exit preview" : "Back to course";
            if(preview && Request.QueryString["attemptId"]!=null){Response.Redirect("~/AccessDenied.aspx");return;}
            if(!IsPostBack){if(Request.QueryString["attemptId"]!=null)ShowSaved(CourseHelper.QueryID("attemptId"));else BindStep();}
        }
        private string Url(){return "Scenario.aspx?id="+activityID+(preview ? "&preview=1" : "");}
        private void BindStep()
        {
            ScenarioRun run=ScenarioHelper.Run(activityID,preview);if(run==null)return;
            btnStart.Text="Restart scenario";
            try
            {
                DataRow step=ScenarioHelper.Current(activityID,preview,run);pnlStep.Visible=true;
                ViewState["RunToken"]=run.Token;ViewState["Revision"]=run.Revision;
                litStep.Text=(string)step["StepText"];litImage.Text=ScenarioHelper.ImageMarkup(step);
                bool ending=(bool)step["IsEnding"];pnlChoices.Visible=!ending;pnlEnding.Visible=ending;
                if(ending)
                {
                    litOutcome.Text=Convert.ToString(step["Outcome"]);litFeedback.Text=Convert.ToString(step["Feedback"]);pnlEnding.CssClass="outcome "+litOutcome.Text.ToLowerInvariant();
                    btnFinish.Visible=!run.Completed;
                    litSaved.Text=run.Completed ? (preview ? "Preview complete. Nothing was saved." : "Outcome saved. Your course progress is updated.") : "Choose Finish to save this outcome. Restarting does not save anything.";
                }
                else
                {
                    DataView choices=new DataView(ScenarioHelper.Choices(activityID));choices.RowFilter="FromStepID="+run.CurrentStepID;
                    rptChoices.DataSource=choices;rptChoices.DataBind();lblNoChoices.Visible=choices.Count==0;
                }
            }
            catch(UnauthorizedAccessException){Response.Redirect("~/AccessDenied.aspx");}
            catch(InvalidOperationException ex){MessageHelper.SetError(ex.Message);}
            catch(SqlException){MessageHelper.SetError("The scenario could not be loaded. Please try again.");}
        }
        protected void Start(object sender,EventArgs e)
        {
            if(!Page.IsValid)return;
            try{ScenarioHelper.Begin(activityID,preview);Response.Redirect(Url());}
            catch(UnauthorizedAccessException){Response.Redirect("~/AccessDenied.aspx");}
            catch(InvalidOperationException ex){MessageHelper.SetError(ex.Message);}
            catch(SqlException){MessageHelper.SetError("The scenario could not be started. Please try again.");}
        }
        protected void Choose(object sender,RepeaterCommandEventArgs e)
        {
            if(!Page.IsValid)return;
            int choice;if(e.CommandName!="Choose" || !Int32.TryParse(Convert.ToString(e.CommandArgument),out choice) || choice<1){MessageHelper.SetError("Invalid choice.");return;}
            Move(choice,false);
        }
        protected void Finish(object sender,EventArgs e){if(!Page.IsValid)return;Move(0,true);}
        private void Move(int choice,bool finish)
        {
            try{ScenarioRun run=ScenarioHelper.Move(activityID,preview,Convert.ToString(ViewState["RunToken"]),Convert.ToString(ViewState["Revision"]),choice,finish);Response.Redirect(Url()+(run.Completed && !preview ? "&attemptId="+run.AttemptID : ""));}
            catch(UnauthorizedAccessException){Response.Redirect("~/AccessDenied.aspx");}
            catch(InvalidOperationException ex){MessageHelper.SetError(ex.Message);Response.Redirect(Url());}
            catch(SqlException){MessageHelper.SetError("The choice could not be saved. Please try again.");}
        }
        private void ShowSaved(int attempt)
        {
            DataTable rows=DatabaseHelper.ExecuteTable("SELECT s.*,a.SubmittedAt FROM dbo.Attempt a JOIN dbo.SimStep s ON s.StepID=a.EndingStepID AND s.ActivityID=a.ActivityID WHERE a.AttemptID=@attempt AND a.ActivityID=@id AND a.LearnerID=@user AND s.IsEnding=1",new[] {new SqlParameter("@attempt",attempt),new SqlParameter("@id",activityID),new SqlParameter("@user",CurrentUserHelper.GetUserID().Value)});
            if(rows.Rows.Count!=1){Response.Redirect("~/AccessDenied.aspx");return;}
            DataRow step=rows.Rows[0];pnlStep.Visible=true;pnlEnding.Visible=true;pnlChoices.Visible=false;btnFinish.Visible=false;btnStart.Text="Restart scenario";
            litStep.Text=(string)step["StepText"];litImage.Text=ScenarioHelper.ImageMarkup(step);litOutcome.Text=Convert.ToString(step["Outcome"]);litFeedback.Text=Convert.ToString(step["Feedback"]);
            pnlEnding.CssClass="outcome "+litOutcome.Text.ToLowerInvariant();
            litSaved.Text="Outcome saved "+((DateTime)step["SubmittedAt"]).ToString("d MMMM yyyy, HH:mm")+" UTC. Restart to explore a different path.";
        }
        protected void Cancel(object sender,EventArgs e){Response.Redirect(ActivityHelper.Back(activity));}
    }
}


