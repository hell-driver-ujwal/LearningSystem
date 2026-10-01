using System;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Web.UI;
using System.Web.UI.WebControls;
using LearningSystem.Helpers;
namespace LearningSystem.Member
{
    public partial class PlayGame : Page
    {
        private int activityID;
        private bool preview;
        private DataRow activity;
        private GameResult submitted;
        protected void Page_Load(object sender,EventArgs e)
        {
            lnkMyResults.Visible=CurrentUserHelper.GetRole()=="Learner";
            AccessHelper.RequireRole(new[] {"Learner","Teacher","Admin"});activityID=CourseHelper.QueryID("id");preview=Request.QueryString["preview"]=="1";
            if(Request.QueryString["preview"]!=null && !preview){Response.Redirect("~/NotFound.aspx");return;}
            activity=ActivityHelper.Require(activityID,"Game",preview);
            litTitle.Text=(string)activity["Title"];litDescription.Text=Convert.ToString(activity["Description"]);litTemplate.Text=(string)activity["GameTemplate"];
            ((SiteMaster)Master).Breadcrumb=BreadcrumbHelper.ForActivity(activityID);
            pnlPreview.Visible=preview;pnlHistory.Visible=!preview;lnkBack.NavigateUrl=ActivityHelper.Back(activity);lnkExit.NavigateUrl=lnkBack.NavigateUrl;
            if(preview && Request.QueryString["attemptId"]!=null){Response.Redirect("~/AccessDenied.aspx");return;}
            if(!IsPostBack)
            {
                if(!preview)
                {
                    BindHistory();if(Request.QueryString["attemptId"]!=null)ShowAttempt(CourseHelper.QueryID("attemptId"));
                }
                else
                {
                    string token=Session[PreviewKey()] as string;Session.Remove(PreviewKey());
                    GameRun run=GameHelper.Run(activityID,token,true);
                    if(run!=null && run.Completed)ShowResult(run.Score,run.Seconds,"Preview result — nothing was saved.");
                }
            }
        }
        private string PreviewKey(){return "GamePreviewResult_"+CurrentUserHelper.GetUserID().Value+"_"+activityID;}
        protected void StartGame(object sender,EventArgs e)
        {
            if(!Page.IsValid)return;
            try
            {
                GameRun run=GameHelper.Begin(activityID,preview);hfRun.Value=run.Token;hfResult.Value="";
                pnlPlay.Visible=true;pnlResult.Visible=false;btnStart.Visible=false;
            }
            catch(InvalidOperationException ex){MessageHelper.SetError(ex.Message);}
            catch(SqlException){MessageHelper.SetError("The game could not be started. Please try again.");}
        }
        protected void Page_PreRender(object sender,EventArgs e)
        {
            if(!pnlPlay.Visible)return;
            GameRun run=GameHelper.Run(activityID,hfRun.Value,preview);
            if(run==null || run.Finished){pnlPlay.Visible=false;btnStart.Visible=true;return;}
            int seconds=(int)Math.Max(0,Math.Min(Int32.MaxValue,(DateTime.UtcNow-run.Started).TotalSeconds));
            litGame.Text="<div id=\"gameRoot\" data-elapsed=\""+seconds+"\" data-game=\""+CourseHelper.Encode(GameHelper.ClientData(activityID))+"\"></div>";
        }
        protected void ValidateResult(object sender,ServerValidateEventArgs e)
        {
            try{submitted=GameHelper.ParseResult(Request.Form[hfResult.UniqueID]);e.IsValid=true;}
            catch(InvalidOperationException ex){e.IsValid=false;cvResult.ErrorMessage=ex.Message;}
        }
        protected void SubmitGame(object sender,EventArgs e)
        {
            if(!Page.IsValid)return;
            try
            {
                GameRun run=GameHelper.Submit(activityID,hfRun.Value,submitted,preview);
                if(preview){Session[PreviewKey()]=run.Token;Response.Redirect("PlayGame.aspx?id="+activityID+"&preview=1");}
                else {MessageHelper.SetSuccess("Game result saved. Your progress is updated.");Response.Redirect("PlayGame.aspx?id="+activityID+"&attemptId="+run.AttemptID);}
            }
            catch(UnauthorizedAccessException){Response.Redirect("~/AccessDenied.aspx");}
            catch(InvalidOperationException ex){MessageHelper.SetError(ex.Message);}
            catch(SqlException){MessageHelper.SetError("Your result could not be saved. Please try again.");}
        }
        private void ShowResult(decimal score,int seconds,string context)
        {
            pnlResult.Visible=true;litResultContext.Text=context;litScore.Text=score.ToString("F2",CultureInfo.InvariantCulture)+"%";litSeconds.Text=seconds.ToString(CultureInfo.InvariantCulture)+" seconds (server measured)";
        }
        private void ShowAttempt(int attempt)
        {
            DataTable rows=DatabaseHelper.ExecuteTable("SELECT ScorePercent,TimeTakenSeconds,SubmittedAt FROM dbo.Attempt WHERE AttemptID=@attempt AND ActivityID=@id AND LearnerID=@user",new[] {new SqlParameter("@attempt",attempt),new SqlParameter("@id",activityID),new SqlParameter("@user",CurrentUserHelper.GetUserID().Value)});
            if(rows.Rows.Count!=1){Response.Redirect("~/AccessDenied.aspx");return;}
            DataRow row=rows.Rows[0];ShowResult((decimal)row["ScorePercent"],(int)row["TimeTakenSeconds"],"Submitted "+((DateTime)row["SubmittedAt"]).ToString("yyyy-MM-dd HH:mm:ss")+" UTC");
        }
        private void BindHistory()
        {
            DataTable rows=DatabaseHelper.ExecuteTable("SELECT AttemptID,SubmittedAt,ScorePercent,TimeTakenSeconds FROM dbo.Attempt WHERE ActivityID=@id AND LearnerID=@user ORDER BY SubmittedAt DESC,AttemptID DESC",new[] {new SqlParameter("@id",activityID),new SqlParameter("@user",CurrentUserHelper.GetUserID().Value)});
            decimal best=0;rows.Columns.Add("ReviewUrl",typeof(string));
            foreach(DataRow row in rows.Rows){best=Math.Max(best,(decimal)row["ScorePercent"]);row["ReviewUrl"]="PlayGame.aspx?id="+activityID+"&attemptId="+row["AttemptID"];}
            litBest.Text=rows.Rows.Count==0 ? "No completed attempts yet." : "Best score: "+best.ToString("F2",CultureInfo.InvariantCulture)+"%";
            gvHistory.DataSource=rows;gvHistory.DataBind();
        }
        protected void Cancel(object sender,EventArgs e){Response.Redirect(ActivityHelper.Back(activity));}
    }
}

