using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using LearningSystem.Helpers;
namespace LearningSystem.Member
{
    public partial class SelfAssessment : Page
    {
        private int activityID;
        private bool preview;
        private DataRow activity;
        private DataTable statements;
        protected void Page_Init(object sender,EventArgs e)
        {
            // Recreate rating controls before postback data is loaded; never trust posted IDs.
            lnkMyResults.Visible=CurrentUserHelper.GetRole()=="Learner";
            AccessHelper.RequireRole(new[] {"Learner","Teacher","Admin"});
            activityID=CourseHelper.QueryID("id");preview=Request.QueryString["preview"]=="1";
            if(Request.QueryString["preview"]!=null && !preview){Response.Redirect("~/NotFound.aspx");return;}
            activity=ActivityHelper.Require(activityID,"SelfAssessment",preview);
            statements=SelfAssessmentHelper.Statements(activityID);
            rptStatements.DataSource=statements;rptStatements.DataBind();
        }
        protected void Page_Load(object sender,EventArgs e)
        {
            litTitle.Text=(string)activity["Title"];litDescription.Text=Convert.ToString(activity["Description"]);
            ((SiteMaster)Master).Breadcrumb=BreadcrumbHelper.ForActivity(activityID);
            pnlPreview.Visible=preview;lnkBack.NavigateUrl=ActivityHelper.Back(activity);lnkExit.NavigateUrl=lnkBack.NavigateUrl;
            lblEmpty.Visible=statements.Rows.Count==0;btnSubmit.Enabled=statements.Rows.Count>0;pnlHistory.Visible=!preview;
            if(preview && Request.QueryString["attemptId"]!=null){Response.Redirect("~/AccessDenied.aspx");return;}
            if(!IsPostBack)
            {
                ViewState["SaveToken"]=CurrentUserHelper.CreateEditToken();
                ViewState["Definition"]=SelfAssessmentHelper.Definition(statements);
                if(!preview)
                {
                    BindHistory();
                    if(Request.QueryString["attemptId"]!=null)ShowAttempt(CourseHelper.QueryID("attemptId"));
                }
                else
                {
                    object average=Session[PreviewKey()];Session.Remove(PreviewKey());
                    if(average is decimal)ShowFeedback((decimal)average,"Preview result — nothing was saved.");
                }
            }
        }
        private string PreviewKey(){return "SelfAssessmentPreview_"+CurrentUserHelper.GetUserID().Value+"_"+activityID;}
        private Dictionary<int,int> ReadRatings()
        {
            var ratings=new Dictionary<int,int>();
            foreach(RepeaterItem item in rptStatements.Items)
            {
                int statement,rating;
                string postedID=((HiddenField)item.FindControl("hfStatement")).Value;
                DropDownList field=(DropDownList)item.FindControl("ddlRating");
                // Read the raw post value as well: a missing input must not fall back to ViewState.
                string postedRating=Request.Form[field.UniqueID];
                if(!Int32.TryParse(postedID,out statement) || statement!=(int)statements.Rows[item.ItemIndex]["StatementID"] || ratings.ContainsKey(statement))throw new InvalidOperationException("A statement ID is invalid for this assessment.");
                if(!Int32.TryParse(postedRating,out rating) || rating<1 || rating>5)throw new InvalidOperationException("Rate every statement with an integer from 1 through 5.");
                ratings.Add(statement,rating);
            }
            if(ratings.Count==0)throw new InvalidOperationException("This assessment has no statements yet.");
            return ratings;
        }
        protected void ValidateRatings(object sender,ServerValidateEventArgs e)
        {
            try{ReadRatings();e.IsValid=true;}
            catch(InvalidOperationException ex){e.IsValid=false;cvRatings.ErrorMessage=ex.Message;}
        }
        protected void SubmitAssessment(object sender,EventArgs e)
        {
            if(!Page.IsValid)return;
            if(!CurrentUserHelper.CanSaveEdit(ViewState["SaveToken"])){MessageHelper.SetError("This form expired or was already submitted. Reload for a new attempt.");return;}
            try
            {
                decimal average;
                int attempt=SelfAssessmentHelper.Submit(activityID,ReadRatings(),ViewState["Definition"] as string,preview,out average);
                CurrentUserHelper.CompleteEdit(ViewState["SaveToken"]);
                if(preview){Session[PreviewKey()]=average;Response.Redirect("SelfAssessment.aspx?id="+activityID+"&preview=1");}
                else {MessageHelper.SetSuccess("Self-assessment saved. Your course progress is updated.");Response.Redirect("SelfAssessment.aspx?id="+activityID+"&attemptId="+attempt);}
            }
            catch(UnauthorizedAccessException){Response.Redirect("~/AccessDenied.aspx");}
            catch(InvalidOperationException ex){MessageHelper.SetError(ex.Message);}
            catch(SqlException){MessageHelper.SetError("The assessment could not be saved. Please try again.");}
        }
        private void ShowFeedback(decimal average,string context)
        {
            pnlResult.Visible=true;litResultContext.Text=context;
            litAverage.Text=SelfAssessmentHelper.Display(average)+" / 5";
            litLevel.Text=SelfAssessmentHelper.Level(average);litFeedback.Text=SelfAssessmentHelper.GetFeedback(average);
        }
        private void ShowAttempt(int attemptID)
        {
            DataTable attempts=DatabaseHelper.ExecuteTable("SELECT SubmittedAt FROM dbo.Attempt WHERE AttemptID=@attempt AND ActivityID=@id AND LearnerID=@user",new[] {new SqlParameter("@attempt",attemptID),new SqlParameter("@id",activityID),new SqlParameter("@user",CurrentUserHelper.GetUserID().Value)});
            if(attempts.Rows.Count!=1){Response.Redirect("~/AccessDenied.aspx");return;}
            DataTable answers=DatabaseHelper.ExecuteTable("SELECT s.StatementText,r.Rating FROM dbo.SAResponse r JOIN dbo.SAStatement s ON s.StatementID=r.StatementID WHERE r.AttemptID=@attempt AND s.ActivityID=@id ORDER BY s.SortOrder,s.StatementID",new[] {new SqlParameter("@attempt",attemptID),new SqlParameter("@id",activityID)});
            if(answers.Rows.Count==0){MessageHelper.SetError("This attempt has no saved ratings.");return;}
            int[] ratings=new int[answers.Rows.Count];for(int i=0;i<ratings.Length;i++)ratings[i]=(int)answers.Rows[i]["Rating"];
            ShowFeedback(SelfAssessmentHelper.CalculateAverage(ratings),"Submitted "+((DateTime)attempts.Rows[0]["SubmittedAt"]).ToString("yyyy-MM-dd HH:mm:ss")+" UTC");
            gvResponses.DataSource=answers;gvResponses.DataBind();
        }
        private void BindHistory()
        {
            DataTable rows=DatabaseHelper.ExecuteTable("SELECT a.AttemptID,a.SubmittedAt,SUM(CAST(r.Rating AS decimal(18,0))) AS TotalRating,COUNT(r.StatementID) AS Ratings FROM dbo.Attempt a JOIN dbo.SAResponse r ON r.AttemptID=a.AttemptID WHERE a.ActivityID=@id AND a.LearnerID=@user GROUP BY a.AttemptID,a.SubmittedAt ORDER BY a.SubmittedAt DESC,a.AttemptID DESC",new[] {new SqlParameter("@id",activityID),new SqlParameter("@user",CurrentUserHelper.GetUserID().Value)});
            rows.Columns.Add("AverageDisplay",typeof(string));rows.Columns.Add("Level",typeof(string));rows.Columns.Add("ReviewUrl",typeof(string));rows.Columns.Add("DateDisplay",typeof(string));
            foreach(DataRow row in rows.Rows)
            {
                decimal average=(decimal)row["TotalRating"]/(int)row["Ratings"];
                row["AverageDisplay"]=SelfAssessmentHelper.Display(average);row["Level"]=SelfAssessmentHelper.Level(average);
                row["ReviewUrl"]="SelfAssessment.aspx?id="+activityID+"&attemptId="+row["AttemptID"];
                row["DateDisplay"]=((DateTime)row["SubmittedAt"]).ToString("yyyy-MM-dd HH:mm:ss")+" UTC";
            }
            gvHistory.DataSource=rows;gvHistory.DataBind();
        }
        protected void Cancel(object sender,EventArgs e){Response.Redirect(ActivityHelper.Back(activity));}
    }
}

