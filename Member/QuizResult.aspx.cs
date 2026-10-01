using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using LearningSystem.Helpers;
namespace LearningSystem.Member
{
    public partial class QuizResult : Page
    {
        protected void Page_Load(object sender,EventArgs e)
        {
            lnkMyResults.Visible=CurrentUserHelper.GetRole()=="Learner";
            AccessHelper.RequireRole(new[] {"Learner","Teacher","Admin"});int id=CourseHelper.QueryID("id");
            if(!AccessHelper.CanViewAttempt(CurrentUserHelper.GetUserID().Value,id)){Response.Redirect("~/AccessDenied.aspx");return;}
            DataTable attempts=DatabaseHelper.ExecuteTable("SELECT r.*,a.Title FROM dbo.Attempt r JOIN dbo.Activity a ON a.ActivityID=r.ActivityID WHERE r.AttemptID=@id AND a.ActivityType='Quiz'",ActivityHelper.ID(id));
            if(attempts.Rows.Count!=1){Response.Redirect("~/NotFound.aspx");return;}
            DataRow attempt=attempts.Rows[0];int activity=(int)attempt["ActivityID"];
            DataRow a=ActivityHelper.Find(activity);
            if(CurrentUserHelper.GetRole()=="Learner" && !ActivityHelper.Published(a)){Response.Redirect("~/NotFound.aspx");return;}
            litTitle.Text=Convert.ToString(attempt["Title"]);Title=litTitle.Text+" result";
            litDate.Text="Submitted "+((DateTime)attempt["SubmittedAt"]).ToString("d MMMM yyyy, HH:mm",System.Globalization.CultureInfo.InvariantCulture)+" UTC. Time taken: "+UiHelper.Plural(Convert.ToInt32(attempt["TimeTakenSeconds"])/60,"minute")+" "+(Convert.ToInt32(attempt["TimeTakenSeconds"])%60)+" seconds.";
            var chosen=new Dictionary<int,int?>();
            foreach(DataRow answer in DatabaseHelper.ExecuteTable("SELECT QuestionID,SelectedOptionID FROM dbo.QuizAnswer WHERE AttemptID=@id",ActivityHelper.ID(id)).Rows)chosen.Add((int)answer["QuestionID"],answer.IsNull("SelectedOptionID") ? (int?)null : (int)answer["SelectedOptionID"]);
            litReview.Text=QuizHelper.Review(QuizHelper.Questions(activity),chosen,(decimal)attempt["ScorePercent"]);
            ((SiteMaster)Master).Breadcrumb=BreadcrumbHelper.ForAttempt(id);
            lnkBack.NavigateUrl=ActivityHelper.Back(a);lnkRetry.NavigateUrl="Quiz.aspx?id="+activity+(CurrentUserHelper.GetRole()=="Learner" ? "" : "&preview=1");
        }
    }
}

