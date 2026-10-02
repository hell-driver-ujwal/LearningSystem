using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Security.Cryptography;
using System.Text;
using System.Web;
namespace LearningSystem.Helpers
{
    public class QuizSubmissionAnswer
    {
        public int QuestionID { get; set; }
        public int? SelectedOptionID { get; set; }
    }
    internal class QuizRun
    {
        internal int UserID;
        internal string Token;
        internal DateTime Started;
        internal string Definition;
        internal int AttemptID;
        internal string Feedback;
        internal bool Finished;
    }
    public static class SubmissionHelper
    {
        public static string CreateToken(int activityID)
        {
            string key="SubmissionToken_"+activityID;
            string token=HttpContext.Current.Session[key] as string;
            if(token==null) {token=Guid.NewGuid().ToString("N");HttpContext.Current.Session[key]=token;}
            return token;
        }
        public static bool ConsumeToken(int activityID,string token)
        {
            string key="SubmissionToken_"+activityID;
            if(token==null || (string)HttpContext.Current.Session[key]!=token)return false;
            HttpContext.Current.Session.Remove(key);return true;
        }
    }
    public static class QuizHelper
    {
        internal static DataTable Questions(int id,SqlConnection c=null,SqlTransaction t=null)
        {
            // This table stays on the server. Renderers explicitly select public fields.
            const string sql="SELECT q.QuestionID,q.QuestionText,q.Marks,q.SortOrder,o.OptionID,o.OptionText,o.IsCorrect FROM dbo.QuizQuestion q LEFT JOIN dbo.QuizOption o ON o.QuestionID=q.QuestionID WHERE q.ActivityID=@id ORDER BY q.SortOrder,q.QuestionID,o.OptionID";
            return c==null ? DatabaseHelper.ExecuteTable(sql,ActivityHelper.ID(id)) : DatabaseHelper.ExecuteTable(c,t,sql,ActivityHelper.ID(id));
        }
        private static string Fingerprint(DataRow activity,DataTable questions)
        {
            StringBuilder text=new StringBuilder();
            foreach(string name in new[] {"TopicID","ActivityType","SortOrder","TimeLimitMinutes","MaxAttempts"})text.Append(activity[name]).Append('|');
            // Length-prefix every cell so content cannot create an ambiguous definition.
            foreach(DataRow row in questions.Rows) foreach(object value in row.ItemArray) {string s=Convert.ToString(value);text.Append(s.Length).Append(':').Append(s);}
            using(SHA256 hash=SHA256.Create())return Convert.ToBase64String(hash.ComputeHash(Encoding.UTF8.GetBytes(text.ToString())));
        }
        private static Dictionary<string,QuizRun> Runs(int id,bool preview)
        {
            string key=(preview ? "QuizPreview_" : "QuizRun_")+id;
            var runs=HttpContext.Current.Session[key] as Dictionary<string,QuizRun>;
            if(runs==null){runs=new Dictionary<string,QuizRun>();HttpContext.Current.Session[key]=runs;}
            return runs;
        }
        internal static QuizRun GetRun(int id,string token,bool preview)
        {
            QuizRun run;
            if(token==null || !Runs(id,preview).TryGetValue(token,out run) || run.UserID!=CurrentUserHelper.GetUserID())return null;
            return run;
        }
        internal static int AttemptCount(int id,SqlConnection c=null,SqlTransaction t=null)
        {
            const string sql="SELECT COUNT(*) FROM dbo.Attempt WHERE ActivityID=@id AND LearnerID=@user";
            var p=new[] {new SqlParameter("@id",id),new SqlParameter("@user",CurrentUserHelper.GetUserID().GetValueOrDefault())};
            return Convert.ToInt32(c==null ? DatabaseHelper.ExecuteScalar(sql,p) : DatabaseHelper.ExecuteScalar(c,t,sql,p));
        }
        public static DateTime Start(int activityID) { return Begin(activityID,false).Started; }
        internal static QuizRun Begin(int id,bool preview)
        {
            DataRow a=ActivityHelper.Find(id);
            if(a==null || (string)a["ActivityType"]!="Quiz" || !AccessHelper.CanAccessActivity(CurrentUserHelper.GetUserID().GetValueOrDefault(),id,preview))throw new UnauthorizedAccessException();
            if(!PublishHelper.CheckQuiz(id).IsValid)throw new InvalidOperationException("This quiz needs valid questions before it can be played.");
            int minutes=(int)a["TimeLimitMinutes"];
            foreach(QuizRun existing in Runs(id,preview).Values)
                if(existing.UserID==CurrentUserHelper.GetUserID() && !existing.Finished)
                {
                    bool startValid=preview || (HttpContext.Current.Session["QuizStart_"+id] is DateTime && (DateTime)HttpContext.Current.Session["QuizStart_"+id]==existing.Started);
                    if(startValid && (minutes==0 || DateTime.UtcNow<=existing.Started.AddMinutes(minutes).AddSeconds(30)))return existing;
                    existing.Finished=true;
                }
            if(!preview && (int)a["MaxAttempts"]>0 && AttemptCount(id)>=(int)a["MaxAttempts"])throw new InvalidOperationException("No attempts remain.");
            if(!preview)HttpContext.Current.Session.Remove("SubmissionToken_"+id);
            var run=new QuizRun {UserID=CurrentUserHelper.GetUserID().Value,Token=preview ? Guid.NewGuid().ToString("N") : SubmissionHelper.CreateToken(id),Started=DateTime.UtcNow,Definition=Fingerprint(a,Questions(id))};
            Runs(id,preview).Add(run.Token,run);
            if(!preview)HttpContext.Current.Session["QuizStart_"+id]=run.Started;
            return run;
        }
        public static int Submit(int activityID,QuizSubmissionAnswer[] answers)
        {
            return SubmitRun(activityID,answers,HttpContext.Current.Session["SubmissionToken_"+activityID] as string,false).AttemptID;
        }
        internal static QuizRun SubmitRun(int id,QuizSubmissionAnswer[] answers,string token,bool preview)
        {
            QuizRun run=GetRun(id,token,preview);
            if(run==null)throw new InvalidOperationException("Quiz session expired. Restart if attempts remain.");
            using(var c=DatabaseHelper.OpenConnection())
            using(var t=c.BeginTransaction(IsolationLevel.Serializable))
            {
                if(!AccessHelper.ActivityAccess(c,t,run.UserID,id,preview))throw new UnauthorizedAccessException();
                DataRow a=ActivityHelper.Find(id,c,t);
                if(a==null || (string)a["ActivityType"]!="Quiz")throw new UnauthorizedAccessException();
                if(run.Finished)
                {
                    if(run.AttemptID>0 || (preview && run.Feedback!=null))return run;
                    throw new InvalidOperationException("This run expired. Restart if attempts remain.");
                }
                DateTime now=DateTime.UtcNow;
                bool startValid=preview || (HttpContext.Current.Session["QuizStart_"+id] is DateTime && (DateTime)HttpContext.Current.Session["QuizStart_"+id]==run.Started);
                if(!startValid || run.Started>now || (!preview && (string)HttpContext.Current.Session["SubmissionToken_"+id]!=token) || ((int)a["TimeLimitMinutes"]>0 && now>run.Started.AddMinutes((int)a["TimeLimitMinutes"]).AddSeconds(30)))
                {run.Finished=true;throw new InvalidOperationException("The quiz session or time limit expired. Nothing was saved. Restart if attempts remain.");}
                DataTable questions=Questions(id,c,t);
                if(run.Definition!=Fingerprint(a,questions)) {run.Finished=true;throw new InvalidOperationException("The quiz definition changed after Start. Nothing was saved; restart the quiz.");}
                if(!preview && (int)a["MaxAttempts"]>0 && AttemptCount(id,c,t)>=(int)a["MaxAttempts"])throw new InvalidOperationException("No attempts remain. Nothing was saved.");
                Dictionary<int,int?> chosen=new Dictionary<int,int?>();
                foreach(QuizSubmissionAnswer answer in answers)
                {
                    if(chosen.ContainsKey(answer.QuestionID))throw new InvalidOperationException("A question was submitted more than once.");
                    bool found=false,optionValid=!answer.SelectedOptionID.HasValue;
                    foreach(DataRow q in questions.Rows) if((int)q["QuestionID"]==answer.QuestionID) {found=true;if(!q.IsNull("OptionID") && answer.SelectedOptionID==(int)q["OptionID"])optionValid=true;}
                    if(!found || !optionValid)throw new InvalidOperationException("An answer does not belong to this quiz question.");
                    chosen.Add(answer.QuestionID,answer.SelectedOptionID);
                }
                int total=0,earned=0,last=0;
                foreach(DataRow q in questions.Rows)
                {
                    int question=(int)q["QuestionID"];
                    if(last!=question){total+=(int)q["Marks"];last=question;if(!chosen.ContainsKey(question))chosen.Add(question,null);}
                    if(!q.IsNull("OptionID") && chosen[question]==(int)q["OptionID"] && (bool)q["IsCorrect"])earned+=(int)q["Marks"];
                }
                if(total==0)throw new InvalidOperationException("No valid quiz questions are available.");
                decimal percent=Math.Round(earned*100m/total,2,MidpointRounding.AwayFromZero);
                string feedback=Review(questions,chosen,percent);
                if(!preview)
                {
                    int attempt=Convert.ToInt32(DatabaseHelper.ExecuteScalar(c,t,"INSERT dbo.Attempt(ActivityID,LearnerID,ScorePercent,TimeTakenSeconds) VALUES(@id,@user,@score,@seconds); SELECT CAST(SCOPE_IDENTITY() AS int)",new[] {new SqlParameter("@id",id),new SqlParameter("@user",run.UserID),new SqlParameter("@score",percent),new SqlParameter("@seconds",(int)Math.Min(Int32.MaxValue,Math.Floor((now-run.Started).TotalSeconds)))}));
                    foreach(var answer in chosen) DatabaseHelper.ExecuteNonQuery(c,t,"INSERT dbo.QuizAnswer(AttemptID,QuestionID,SelectedOptionID) VALUES(@attempt,@question,@option)",new[] {new SqlParameter("@attempt",attempt),new SqlParameter("@question",answer.Key),new SqlParameter("@option",answer.Value.HasValue ? (object)answer.Value.Value : DBNull.Value)});
                    t.Commit();run.AttemptID=attempt;
                    SubmissionHelper.ConsumeToken(id,token);
                }
                // Preview creates no database records; its feedback lives only in this session.
                run.Feedback=feedback;run.Finished=true;return run;
            }
        }
        internal static string Review(DataTable questions,Dictionary<int,int?> chosen,decimal percent)
        {
            StringBuilder list=new StringBuilder("<ol class=\"answer-review\">");
            int last=0,questionCount=0,rightCount=0;
            foreach(DataRow q in questions.Rows)
            {
                int question=(int)q["QuestionID"];
                if(last!=question)
                {
                    if(last!=0)list.Append("</ul></li>");last=question;questionCount++;
                    int? selected;chosen.TryGetValue(question,out selected);
                    bool right=false;foreach(DataRow option in questions.Rows)if((int)option["QuestionID"]==question && !option.IsNull("OptionID") && selected==(int)option["OptionID"] && (bool)option["IsCorrect"])right=true;
                    if(right)rightCount++;
                    list.Append("<li class=\"").Append(right ? "right" : "wrong").Append("\"><h3>").Append(CourseHelper.Encode(q["QuestionText"])).Append("</h3><p><strong>")
                        .Append(right ? "Correct" : selected.HasValue ? "Not quite" : "Not answered").Append("</strong>, ").Append(right ? q["Marks"].ToString() : "0").Append(" of ").Append(q["Marks"]).Append(q["Marks"].ToString()=="1" ? " mark" : " marks").Append("</p><ul>");
                }
                bool mine=!q.IsNull("OptionID") && chosen.ContainsKey(question) && chosen[question]==(int)q["OptionID"];
                bool correct=!q.IsNull("IsCorrect") && (bool)q["IsCorrect"];
                list.Append("<li>").Append(CourseHelper.Encode(q["OptionText"]));
                if(mine)list.Append(" <span class=\"chip").Append(correct ? " green" : " accent").Append("\">Your answer</span>");
                if(correct)list.Append(" <span class=\"chip green\">Correct answer</span>");
                list.Append("</li>");
            }
            if(last!=0)list.Append("</ul></li>");
            list.Append("</ol>");
            string value=percent.ToString("0.##",System.Globalization.CultureInfo.InvariantCulture);
            string message=percent>=80m ? "Excellent work. You have a strong grasp of this topic." : percent>=50m ? "Good effort. Review the questions below, then try again to improve your score." : "Keep going. Re-read the lesson, then use the review below before your next try.";
            return "<section class=\"result-panel\" aria-label=\"Your score\">"+GameUiHelper.ResultArt(percent,"Quiz")+"<div><h2>"+rightCount+" of "+questionCount+" questions correct</h2><p>"+message+"</p></div></section><h2>Answer review</h2>"+list;
        }
    }
}
