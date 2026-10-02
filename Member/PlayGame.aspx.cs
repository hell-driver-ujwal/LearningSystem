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
            litTitle.Text=(string)activity["Title"];Title=litTitle.Text;litDescription.Text=Convert.ToString(activity["Description"]);litTemplate.Text=GameHelper.TemplateName((string)activity["GameTemplate"]);litHowTo.Text=HowTo((string)activity["GameTemplate"]);
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
                    if(run!=null && run.Completed)ShowResult(run.Score,run.Seconds,"Preview result. Nothing was saved.",null,true);
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
                pnlPlay.Visible=true;pnlResult.Visible=false;pnlStart.Visible=false;
            }
            catch(InvalidOperationException ex){MessageHelper.SetError(ex.Message);}
            catch(SqlException){MessageHelper.SetError("The game could not be started. Please try again.");}
        }
        protected void Page_PreRender(object sender,EventArgs e)
        {
            if(!pnlPlay.Visible)return;
            GameRun run=GameHelper.Run(activityID,hfRun.Value,preview);
            if(run==null || run.Finished){pnlPlay.Visible=false;pnlStart.Visible=true;return;}
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
                else {MessageHelper.SetSuccess("Result saved. Your course progress is updated.");Response.Redirect("PlayGame.aspx?id="+activityID+"&attemptId="+run.AttemptID+"&fresh=1");}
            }
            catch(UnauthorizedAccessException){Response.Redirect("~/AccessDenied.aspx");}
            catch(InvalidOperationException ex){MessageHelper.SetError(ex.Message);}
            catch(SqlException){MessageHelper.SetError("Your result could not be saved. Please try again.");}
        }
        private void ShowResult(decimal score,int seconds,string context,int? bestXp,bool celebrate)
        {
            pnlResult.Visible=true;litResultContext.Text=context;string value=score.ToString("0.##",CultureInfo.InvariantCulture);litScore.Text=value+"%";litSeconds.Text="Finished in "+UiHelper.Plural(seconds,"second")+". "+(score>=80m ? "Great work." : score>=50m ? "Good effort. Play again to beat your score." : "Review the lesson, then try again.");litRing.Text=GameUiHelper.ResultArt(score,bestXp,celebrate);btnStart.Text="Play again";
        }
        private void ShowAttempt(int attempt)
        {
            DataTable rows=DatabaseHelper.ExecuteTable("SELECT ScorePercent,TimeTakenSeconds,SubmittedAt FROM dbo.Attempt WHERE AttemptID=@attempt AND ActivityID=@id AND LearnerID=@user",new[] {new SqlParameter("@attempt",attempt),new SqlParameter("@id",activityID),new SqlParameter("@user",CurrentUserHelper.GetUserID().Value)});
            if(rows.Rows.Count!=1){Response.Redirect("~/AccessDenied.aspx");return;}
            DataRow row=rows.Rows[0];ShowResult((decimal)row["ScorePercent"],(int)row["TimeTakenSeconds"],"Saved "+((DateTime)row["SubmittedAt"]).ToString("d MMMM yyyy, HH:mm",CultureInfo.InvariantCulture)+" UTC",GamificationHelper.BestActivityXp(CurrentUserHelper.GetUserID().Value,activityID),Request.QueryString["fresh"]=="1");
        }
        private void BindHistory()
        {
            DataTable rows=DatabaseHelper.ExecuteTable("SELECT AttemptID,SubmittedAt,ScorePercent,TimeTakenSeconds FROM dbo.Attempt WHERE ActivityID=@id AND LearnerID=@user ORDER BY SubmittedAt DESC,AttemptID DESC",new[] {new SqlParameter("@id",activityID),new SqlParameter("@user",CurrentUserHelper.GetUserID().Value)});
            decimal best=0;rows.Columns.Add("ReviewUrl",typeof(string));
            foreach(DataRow row in rows.Rows){best=Math.Max(best,(decimal)row["ScorePercent"]);row["ReviewUrl"]="PlayGame.aspx?id="+activityID+"&attemptId="+row["AttemptID"];}
            litBest.Text=rows.Rows.Count==0 ? "No completed attempts yet." : "Your best score: "+best.ToString("0.##",CultureInfo.InvariantCulture)+"% from "+UiHelper.Plural(rows.Rows.Count,"attempt")+".";
            gvHistory.DataSource=rows;gvHistory.DataBind();
        }
        protected void Cancel(object sender,EventArgs e){Response.Redirect(ActivityHelper.Back(activity));}
        // Short instructions shown before the game starts.
        private static string HowTo(string template)
        {
            switch(template)
            {
                case "Matching": return "Pair each item with its match. Select an item, then select the answer that goes with it.";
                case "Memory": return "Turn over two cards at a time to find matching pairs. Fewer moves and a quicker finish give a higher score.";
                case "Scramble": return "Unscramble each word using its hint, then type the word in the box.";
                case "Sort": return "Select each item, then choose the group it belongs to.";
                case "Flashcards": return "Read each card, try to recall the answer, then flip it. Rate honestly whether you knew it.";
                case "FillBlank": return "Type the missing word or phrase for each sentence. Spelling counts, capital letters do not.";
                case "TrueFalse": return "Decide whether each statement is true or false before the timer runs out.";
                case "Sequence": return "Move the steps up or down until they are in the correct order.";
                default: return "Follow the on-screen instructions, then submit your result.";
            }
        }
    }
}

