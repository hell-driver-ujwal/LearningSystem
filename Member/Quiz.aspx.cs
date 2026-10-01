using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Text;
using System.Web.UI;
using LearningSystem.Helpers;
namespace LearningSystem.Member
{
    public partial class Quiz : Page
    {
        private int activityID;
        private bool preview;
        private DataRow activity;
        protected void Page_Load(object sender,EventArgs e)
        {
            AccessHelper.RequireRole(new[] {"Learner","Teacher","Admin"});
            activityID=CourseHelper.QueryID("id");preview=Request.QueryString["preview"]=="1";
            if(Request.QueryString["preview"]!=null && !preview){Response.Redirect("~/NotFound.aspx");return;}
            activity=ActivityHelper.Require(activityID,"Quiz",preview);
            litTitle.Text=Convert.ToString(activity["Title"]);litDescription.Text=Convert.ToString(activity["Description"]);
            ((SiteMaster)Master).Breadcrumb=BreadcrumbHelper.ForActivity(activityID);
            pnlPreview.Visible=preview;lnkBack.NavigateUrl=ActivityHelper.Back(activity);lnkExit.NavigateUrl=lnkBack.NavigateUrl;
            if(!IsPostBack)
            {
                int used=preview ? 0 : QuizHelper.AttemptCount(activityID),limit=(int)activity["MaxAttempts"];
                int count=Convert.ToInt32(DatabaseHelper.ExecuteScalar("SELECT COUNT(*) FROM dbo.QuizQuestion WHERE ActivityID=@id",ActivityHelper.ID(activityID)));
                litIntro.Text=count+" questions. Time limit: "+((int)activity["TimeLimitMinutes"]==0 ? "Untimed" : activity["TimeLimitMinutes"]+" minutes")+". Attempts left: "+(preview ? "Unlimited in preview" : limit==0 ? "Unlimited" : Math.Max(0,limit-used).ToString())+". Unanswered questions earn zero marks.";
                btnStart.Enabled=preview || limit==0 || used<limit;
                string result=Session["QuizPreviewResult_"+activityID] as string;
                if(preview && result!=null){QuizRun run=QuizHelper.GetRun(activityID,result,true);if(run!=null && run.Finished)litFeedback.Text=run.Feedback;Session.Remove("QuizPreviewResult_"+activityID);}
            }
        }
        protected void StartQuiz(object sender,EventArgs e)
        {
            if(!Page.IsValid)return;
            try {QuizRun run=QuizHelper.Begin(activityID,preview);hfRun.Value=run.Token;ShowQuestions(run);}
            catch(InvalidOperationException ex){MessageHelper.SetError(ex.Message);}
            catch(UnauthorizedAccessException){Response.Redirect("~/AccessDenied.aspx");}
            catch(SqlException){MessageHelper.SetError("The quiz could not be started. Please try again.");}
        }
        private void ShowQuestions(QuizRun run)
        {
            pnlPlay.Visible=true;pnlIntro.Visible=false;litFeedback.Text="";
            DataTable rows=QuizHelper.Questions(activityID);
            StringBuilder html=new StringBuilder();int last=0;
            foreach(DataRow row in rows.Rows)
            {
                int id=(int)row["QuestionID"];
                if(last!=id){if(last!=0)html.Append("</fieldset>");last=id;html.Append("<fieldset><legend>").Append(CourseHelper.Encode(row["QuestionText"])).Append(" (marks: ").Append(row["Marks"]).Append(")</legend>");}
                string option=row["OptionID"].ToString();
                html.Append("<label class=\"quiz-option\"><input type=\"radio\" name=\"q_").Append(id).Append("\" value=\"").Append(option).Append("\" /> ").Append(CourseHelper.Encode(row["OptionText"])).Append("</label>");
            }
            if(last!=0)html.Append("</fieldset>");litQuestions.Text=html.ToString();
            if((int)activity["TimeLimitMinutes"]>0)
            {
                double seconds=Math.Max(0,(run.Started.AddMinutes((int)activity["TimeLimitMinutes"])-DateTime.UtcNow).TotalSeconds);
                litTimer.Text="<p id=\"quizTimer\" role=\"timer\" data-seconds=\""+Math.Ceiling(seconds).ToString(CultureInfo.InvariantCulture)+"\" data-submit=\""+btnSubmit.ClientID+"\">Time remaining</p>";
            }
            else litTimer.Text="<p>Untimed quiz</p>";
        }
        protected void SubmitQuiz(object sender,EventArgs e)
        {
            if(!Page.IsValid)return;
            try
            {
                var answers=new List<QuizSubmissionAnswer>();
                foreach(string key in Request.Form.AllKeys)
                {
                    if(key==null || !key.StartsWith("q_",StringComparison.Ordinal))continue;
                    int question,option;
                    if(!Int32.TryParse(key.Substring(2),out question) || !Int32.TryParse(Request.Form[key],out option))throw new InvalidOperationException("Invalid quiz answer.");
                    answers.Add(new QuizSubmissionAnswer {QuestionID=question,SelectedOptionID=option});
                }
                QuizRun run=QuizHelper.SubmitRun(activityID,answers.ToArray(),hfRun.Value,preview);
                if(preview){Session["QuizPreviewResult_"+activityID]=run.Token;Response.Redirect("Quiz.aspx?id="+activityID+"&preview=1");}
                else Response.Redirect("QuizResult.aspx?id="+run.AttemptID);
            }
            catch(InvalidOperationException ex){MessageHelper.SetError(ex.Message);pnlPlay.Visible=false;pnlIntro.Visible=true;}
            catch(UnauthorizedAccessException){Response.Redirect("~/AccessDenied.aspx");}
            catch(SqlException){MessageHelper.SetError("Your attempt could not be saved. Please try again.");QuizRun run=QuizHelper.GetRun(activityID,hfRun.Value,preview);if(run!=null)ShowQuestions(run);}
        }
        protected void Cancel(object sender,EventArgs e){Response.Redirect(ActivityHelper.Back(activity));}
    }
}
