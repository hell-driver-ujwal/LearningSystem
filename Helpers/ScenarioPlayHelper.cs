using System;
using System.Data;
using System.Data.SqlClient;
using System.Security.Cryptography;
using System.Text;
using System.Web;
namespace LearningSystem.Helpers
{
    internal class ScenarioRun
    {
        internal int UserID,CurrentStepID,AttemptID;
        internal string Token,Revision,Definition;
        internal bool Completed;
    }
    internal static partial class ScenarioHelper
    {
        private static string RunKey(int id,bool preview){return (preview ? "ScenarioPreview_" : "ScenarioRun_")+id;}
        internal static ScenarioRun Run(int id,bool preview)
        {
            var run=HttpContext.Current.Session[RunKey(id,preview)] as ScenarioRun;
            return run!=null && run.UserID==CurrentUserHelper.GetUserID().GetValueOrDefault() ? run : null;
        }
        private static DataRow RequirePlay(SqlConnection c,SqlTransaction t,int id,bool preview)
        {
            if(!AccessHelper.ActivityAccess(c,t,CurrentUserHelper.GetUserID().GetValueOrDefault(),id,preview))throw new UnauthorizedAccessException();
            DataRow a=ActivityHelper.Find(id,c,t);
            if(a==null || (string)a["ActivityType"]!="Scenario")throw new UnauthorizedAccessException();
            return a;
        }
        private static string Definition(DataRow a,DataTable steps,DataTable choices)
        {
            // Length prefixes distinguish text containing separators. No schema version column is needed.
            var text=new StringBuilder();text.Append(Convert.ToString(a["StartStepID"])).Append(':');
            foreach(DataTable table in new[] {steps,choices})
                foreach(DataRow row in table.Rows)
                    foreach(object cell in row.ItemArray){string value=Convert.ToString(cell);text.Append(value.Length).Append(':').Append(value);}
            using(var hash=SHA256.Create())return Convert.ToBase64String(hash.ComputeHash(Encoding.UTF8.GetBytes(text.ToString())));
        }
        internal static void Begin(int id,bool preview)
        {
            ScenarioRun run;
            using(var c=DatabaseHelper.OpenConnection())using(var t=c.BeginTransaction(IsolationLevel.Serializable))
            {
                DataRow a=RequirePlay(c,t,id,preview);
                if(a.IsNull("StartStepID"))throw new InvalidOperationException("Set a start step before playing this scenario.");
                DataTable steps=Steps(id,c,t);int start=(int)a["StartStepID"];Step(steps,start);
                run=new ScenarioRun {UserID=CurrentUserHelper.GetUserID().Value,CurrentStepID=start,Token=Guid.NewGuid().ToString("N"),Revision=Guid.NewGuid().ToString("N"),Definition=Definition(a,steps,Choices(id,c,t))};
                t.Commit();
            }
            // Starting/restarting only changes session. Even an ending start requires an explicit Finish.
            HttpContext.Current.Session[RunKey(id,preview)]=run;
        }
        internal static DataRow Current(int id,bool preview,ScenarioRun run)
        {
            using(var c=DatabaseHelper.OpenConnection())using(var t=c.BeginTransaction(IsolationLevel.Serializable))
            {
                DataRow a=RequirePlay(c,t,id,preview);DataTable steps=Steps(id,c,t);
                if(run==null || run!=Run(id,preview))throw new InvalidOperationException("Start this scenario first.");
                if(run.Definition!=Definition(a,steps,Choices(id,c,t)))throw new InvalidOperationException("The scenario changed. Restart before continuing.");
                DataRow step=Step(steps,run.CurrentStepID);t.Commit();return step;
            }
        }
        internal static ScenarioRun Move(int id,bool preview,string token,string revision,int choice,bool finish)
        {
            ScenarioRun run=Run(id,preview);
            if(run==null || run.Token!=token || run.Revision!=revision || run.Completed)throw new InvalidOperationException("This page is no longer the current step. Reload or restart the scenario.");
            int next,attempt=0;bool completed;
            using(var c=DatabaseHelper.OpenConnection())using(var t=c.BeginTransaction(IsolationLevel.Serializable))
            {
                DataRow a=RequirePlay(c,t,id,preview);DataTable steps=Steps(id,c,t),choices=Choices(id,c,t);
                if(run.Definition!=Definition(a,steps,choices))throw new InvalidOperationException("The scenario changed. Nothing was saved. Restart before continuing.");
                DataRow current=Step(steps,run.CurrentStepID);next=run.CurrentStepID;
                if(finish)
                {
                    if(!(bool)current["IsEnding"] || choice!=0)throw new InvalidOperationException("Only a reached ending can be completed.");
                }
                else
                {
                    if((bool)current["IsEnding"])throw new InvalidOperationException("An ending has no outgoing choices.");
                    DataRow selected=null;
                    foreach(DataRow row in choices.Rows)if((int)row["ChoiceID"]==choice && (int)row["FromStepID"]==run.CurrentStepID)selected=row;
                    if(selected==null)throw new InvalidOperationException("That choice is not available at your current step.");
                    next=(int)selected["NextStepID"];
                    if(next==run.CurrentStepID)throw new InvalidOperationException("Direct self-links are invalid.");
                }
                DataRow destination=Step(steps,next);completed=(bool)destination["IsEnding"];
                if(completed)
                {
                    string feedback=Convert.ToString(destination["Feedback"]).Trim();
                    if(!Outcome(Convert.ToString(destination["Outcome"])) || feedback.Length<10 || feedback.Length>500)throw new InvalidOperationException("This ending needs a valid outcome and feedback.");
                    foreach(DataRow row in choices.Rows)if((int)row["FromStepID"]==next)throw new InvalidOperationException("Ending steps cannot have choices.");
                    if(!preview)attempt=Convert.ToInt32(DatabaseHelper.ExecuteScalar(c,t,"INSERT dbo.Attempt(ActivityID,LearnerID,EndingStepID,ScorePercent,TimeTakenSeconds,SubmittedAt) VALUES(@id,@user,@ending,NULL,NULL,SYSUTCDATETIME());SELECT CAST(SCOPE_IDENTITY() AS int)",new[] {new SqlParameter("@id",id),new SqlParameter("@user",run.UserID),new SqlParameter("@ending",next)}));
                }
                t.Commit();
            }
            // Update session only after commit. ASP.NET serializes requests for this session.
            run.CurrentStepID=next;run.Completed=completed;run.AttemptID=attempt;run.Revision=Guid.NewGuid().ToString("N");return run;
        }
    }
}
