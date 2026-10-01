using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Web;
namespace LearningSystem.Helpers
{
    internal static partial class ScenarioHelper
    {
        internal static DataTable Steps(int id, SqlConnection c=null, SqlTransaction t=null)
        {
            const string sql="SELECT * FROM dbo.SimStep WHERE ActivityID=@id ORDER BY StepID";
            return c==null ? DatabaseHelper.ExecuteTable(sql,ActivityHelper.ID(id)) : DatabaseHelper.ExecuteTable(c,t,sql,ActivityHelper.ID(id));
        }
        internal static DataTable Choices(int id, SqlConnection c=null, SqlTransaction t=null)
        {
            const string sql="SELECT ch.* FROM dbo.SimChoice ch JOIN dbo.SimStep s ON s.StepID=ch.FromStepID WHERE s.ActivityID=@id ORDER BY ch.ChoiceID";
            return c==null ? DatabaseHelper.ExecuteTable(sql,ActivityHelper.ID(id)) : DatabaseHelper.ExecuteTable(c,t,sql,ActivityHelper.ID(id));
        }
        internal static DataRow Step(DataTable steps,int id)
        {
            foreach(DataRow row in steps.Rows)if((int)row["StepID"]==id)return row;
            throw new InvalidOperationException("The step does not belong to this scenario.");
        }
        internal static bool Outcome(string value){return value=="Best" || value=="Acceptable" || value=="Poor";}
        internal static DataRow RequireOwned(SqlConnection c,SqlTransaction t,int id,bool structure)
        {
            AccessHelper.RequireOwner(c,t,id,"Activity");DataRow a=ActivityHelper.Find(id,c,t);
            if(a==null || (string)a["ActivityType"]!="Scenario")throw new UnauthorizedAccessException();
            if(structure && ContentLockHelper.HasAttempts(c,t,id))throw new InvalidOperationException("Scenario structure is locked because attempts exist. Title, description and publication remain editable.");
            return a;
        }
        internal static void KeepPublishedValid(SqlConnection c,SqlTransaction t,DataRow a)
        {
            if((string)a["Status"]!="Published")return;
            ValidationResult check=PublishHelper.CheckScenario(c,t,(int)a["ActivityID"]);
            if(!check.IsValid)throw new InvalidOperationException(check.Message+" Unpublish before making this change.");
        }
        internal static int SaveSettings(int id,int topic,string title,string description,int order,string status)
        {
            ActivityHelper.CheckText(title,3,100,"Title");ActivityHelper.CheckText(description,10,1000,"Introduction");
            if(order<1 || (status!="Draft" && status!="Published"))throw new InvalidOperationException("Choose a valid status and positive order.");
            using(var c=DatabaseHelper.OpenConnection())using(var t=c.BeginTransaction(IsolationLevel.Serializable))
            {
                AccessHelper.RequireOwner(c,t,topic,"Topic");
                int course=Convert.ToInt32(DatabaseHelper.ExecuteScalar(c,t,"SELECT CourseID FROM dbo.Topic WHERE TopicID=@id",ActivityHelper.ID(topic)));
                if(id>0)
                {
                    DataRow old=RequireOwned(c,t,id,false);
                    if((int)old["TopicID"]!=topic)throw new UnauthorizedAccessException();
                    if(ContentLockHelper.HasAttempts(c,t,id) && (int)old["SortOrder"]!=order)throw new InvalidOperationException("Structural order is locked after attempts.");
                }
                var p=new[] {new SqlParameter("@id",id),new SqlParameter("@topic",topic),new SqlParameter("@title",title),new SqlParameter("@description",description),new SqlParameter("@order",order),new SqlParameter("@status",status)};
                if(id==0)id=Convert.ToInt32(DatabaseHelper.ExecuteScalar(c,t,"INSERT dbo.Activity(TopicID,ActivityType,Title,Description,SortOrder,Status) VALUES(@topic,'Scenario',@title,@description,@order,@status);SELECT CAST(SCOPE_IDENTITY() AS int)",p));
                else DatabaseHelper.ExecuteNonQuery(c,t,"UPDATE dbo.Activity SET Title=@title,Description=@description,SortOrder=@order,Status=@status WHERE ActivityID=@id",p);
                KeepPublishedValid(c,t,ActivityHelper.Find(id,c,t));AccessHelper.TouchCourse(c,t,course);t.Commit();return id;
            }
        }
        internal static void SaveStart(int id,int step)
        {
            using(var c=DatabaseHelper.OpenConnection())using(var t=c.BeginTransaction(IsolationLevel.Serializable))
            {
                DataRow a=RequireOwned(c,t,id,true);Step(Steps(id,c,t),step);
                DatabaseHelper.ExecuteNonQuery(c,t,"UPDATE dbo.Activity SET StartStepID=@step WHERE ActivityID=@id",new[] {new SqlParameter("@step",step),new SqlParameter("@id",id)});
                KeepPublishedValid(c,t,a);AccessHelper.TouchCourse(c,t,(int)a["CourseID"]);t.Commit();
            }
        }
        internal static string SaveStep(int id,int step,string text,bool ending,string outcome,string feedback,string alt,HttpPostedFile image,bool remove)
        {
            ActivityHelper.CheckText(text,10,1000,"Step text");
            if(ending){if(!Outcome(outcome))throw new InvalidOperationException("Choose an ending outcome.");ActivityHelper.CheckText(feedback,10,500,"Ending feedback");}
            string newPath=null,oldPath=null;bool committed=false;
            try
            {
                if(image!=null && image.ContentLength>0)newPath=UploadHelper.Save(image,"Image",false);
                using(var c=DatabaseHelper.OpenConnection())using(var t=c.BeginTransaction(IsolationLevel.Serializable))
                {
                    DataRow a=RequireOwned(c,t,id,true);
                    if(step>0)oldPath=Convert.ToString(Step(Steps(id,c,t),step)["ImagePath"]);
                    if(!String.IsNullOrEmpty(oldPath))UploadHelper.GetValidatedPath(oldPath);
                    string path=newPath ?? (remove ? null : oldPath);
                    if(!String.IsNullOrEmpty(path))ActivityHelper.CheckText(alt,5,150,"Image alt text");
                    if(ending && step>0 && Convert.ToInt32(DatabaseHelper.ExecuteScalar(c,t,"SELECT COUNT(*) FROM dbo.SimChoice WHERE FromStepID=@id",ActivityHelper.ID(step)))>0)throw new InvalidOperationException("Delete outgoing choices before converting this step to an ending.");
                    var p=new[] {new SqlParameter("@id",id),new SqlParameter("@step",step),new SqlParameter("@text",text),new SqlParameter("@ending",ending),new SqlParameter("@outcome",ending ? (object)outcome : DBNull.Value),new SqlParameter("@feedback",ending ? (object)feedback : DBNull.Value),new SqlParameter("@path",String.IsNullOrEmpty(path) ? (object)DBNull.Value : path),new SqlParameter("@alt",String.IsNullOrEmpty(path) ? (object)DBNull.Value : alt)};
                    DatabaseHelper.ExecuteNonQuery(c,t,step==0 ? "INSERT dbo.SimStep(ActivityID,StepText,IsEnding,Outcome,Feedback,ImagePath,ImageAlt) VALUES(@id,@text,@ending,@outcome,@feedback,@path,@alt)" : "UPDATE dbo.SimStep SET StepText=@text,IsEnding=@ending,Outcome=@outcome,Feedback=@feedback,ImagePath=@path,ImageAlt=@alt WHERE StepID=@step AND ActivityID=@id",p);
                    KeepPublishedValid(c,t,a);AccessHelper.TouchCourse(c,t,(int)a["CourseID"]);t.Commit();committed=true;
                    if(path==oldPath)oldPath=null;
                }
            }
            finally {if(!committed && newPath!=null)UploadHelper.Cleanup(newPath);}
            return UploadHelper.Cleanup(oldPath);
        }
        internal static void SaveChoice(int id,int choice,int from,int next,string text,bool delete)
        {
            using(var c=DatabaseHelper.OpenConnection())using(var t=c.BeginTransaction(IsolationLevel.Serializable))
            {
                DataRow a=RequireOwned(c,t,id,true);
                if(choice>0)
                {
                    bool found=false;foreach(DataRow row in Choices(id,c,t).Rows)if((int)row["ChoiceID"]==choice)found=true;
                    if(!found)throw new UnauthorizedAccessException();
                }
                if(delete)
                {
                    if(choice<1)throw new InvalidOperationException("Choose an existing choice.");
                    DatabaseHelper.ExecuteNonQuery(c,t,"DELETE dbo.SimChoice WHERE ChoiceID=@id",ActivityHelper.ID(choice));
                }
                else
                {
                    ActivityHelper.CheckText(text,2,150,"Choice text");DataTable steps=Steps(id,c,t);
                    DataRow source=Step(steps,from);Step(steps,next);
                    if(from==next || (bool)source["IsEnding"])throw new InvalidOperationException("Choices must leave a non-ending step and point to a different step in this scenario.");
                    DatabaseHelper.ExecuteNonQuery(c,t,choice==0 ? "INSERT dbo.SimChoice(FromStepID,NextStepID,ChoiceText) VALUES(@from,@next,@text)" : "UPDATE dbo.SimChoice SET FromStepID=@from,NextStepID=@next,ChoiceText=@text WHERE ChoiceID=@id",new[] {new SqlParameter("@id",choice),new SqlParameter("@from",from),new SqlParameter("@next",next),new SqlParameter("@text",text)});
                }
                KeepPublishedValid(c,t,a);AccessHelper.TouchCourse(c,t,(int)a["CourseID"]);t.Commit();
            }
        }
        internal static DataTable Summary(int id)
        {
            using(var c=DatabaseHelper.OpenConnection())using(var t=c.BeginTransaction(IsolationLevel.Serializable))
            {
                RequireOwned(c,t,id,false);
                DataTable rows=DatabaseHelper.ExecuteTable(c,t,"SELECT s.StepID,s.StepText,s.Outcome,COUNT(a.AttemptID) AS Attempts FROM dbo.SimStep s JOIN dbo.Attempt a ON a.EndingStepID=s.StepID AND a.ActivityID=s.ActivityID WHERE s.ActivityID=@id GROUP BY s.StepID,s.StepText,s.Outcome ORDER BY s.StepID",ActivityHelper.ID(id));t.Commit();return rows;
            }
        }
        // Images stay inside the authorized page; direct Uploads access remains blocked.
        internal static string ImageMarkup(DataRow step)
        {
            string relative=Convert.ToString(step["ImagePath"]);if(String.IsNullOrEmpty(relative))return "";
            try
            {
                string path=UploadHelper.GetValidatedPath(relative),ext=Path.GetExtension(path).ToLowerInvariant();
                if(ext!=".jpg" && ext!=".jpeg" && ext!=".png" && ext!=".gif")return "";
                string mime=ext==".png" ? "image/png" : ext==".gif" ? "image/gif" : "image/jpeg";
                return "<img class=\"scenario-image\" src=\"data:"+mime+";base64,"+Convert.ToBase64String(File.ReadAllBytes(path))+"\" alt=\""+HttpUtility.HtmlAttributeEncode(Convert.ToString(step["ImageAlt"]))+"\" />";
            }
            catch(IOException){return "<p>Step image is unavailable.</p>";}
            catch(UnauthorizedAccessException){return "<p>Step image is unavailable.</p>";}
            catch(ArgumentException){return "<p>Step image is unavailable.</p>";}
        }
    }
    public static partial class PublishHelper
    {
        public static ValidationResult CheckScenario(int activityID){using(var c=DatabaseHelper.OpenConnection())return CheckScenario(c,null,activityID);}
        internal static ValidationResult CheckScenario(SqlConnection c,SqlTransaction t,int id)
        {
            DataRow a=ActivityHelper.Find(id,c,t);DataTable steps=ScenarioHelper.Steps(id,c,t),choices=ScenarioHelper.Choices(id,c,t);
            bool valid=a!=null && (string)a["ActivityType"]=="Scenario" && !a.IsNull("StartStepID");bool ending=false,start=false;
            foreach(DataRow s in steps.Rows)
            {
                int step=(int)s["StepID"];if(a!=null && !a.IsNull("StartStepID") && step==(int)a["StartStepID"])start=true;
                bool hasChoices=false;foreach(DataRow ch in choices.Rows)if((int)ch["FromStepID"]==step)hasChoices=true;
                if((bool)s["IsEnding"])
                {
                    ending=true;string feedback=Convert.ToString(s["Feedback"]).Trim();
                    if(!ScenarioHelper.Outcome(Convert.ToString(s["Outcome"])) || feedback.Length<10 || feedback.Length>500 || hasChoices)valid=false;
                }
                else if(!hasChoices)valid=false;
                string text=Convert.ToString(s["StepText"]).Trim(),alt=Convert.ToString(s["ImageAlt"]).Trim();
                if(text.Length<10 || text.Length>1000 || (!String.IsNullOrEmpty(Convert.ToString(s["ImagePath"])) && (alt.Length<5 || alt.Length>150)))valid=false;
            }
            foreach(DataRow ch in choices.Rows)
            {
                bool target=false;foreach(DataRow s in steps.Rows)if((int)s["StepID"]==(int)ch["NextStepID"])target=true;
                string text=Convert.ToString(ch["ChoiceText"]).Trim();
                if(!target || (int)ch["NextStepID"]==(int)ch["FromStepID"] || text.Length<2 || text.Length>150)valid=false;
            }
            return new ValidationResult {IsValid=valid && start && ending,Message="Publication requires a start step in this scenario, at least one ending with outcome and feedback, choices for every non-ending, no choices from endings, and valid destinations (no direct self-links). Loops are allowed."};
        }
    }
    public static partial class DeleteHelper
    {
        public static ValidationResult CheckStep(int stepID)
        {
            using(var c=DatabaseHelper.OpenConnection())using(var t=c.BeginTransaction(IsolationLevel.Serializable)){ValidationResult result=CheckStep(c,t,stepID);t.Commit();return result;}
        }
        private static ValidationResult CheckStep(SqlConnection c,SqlTransaction t,int step)
        {
            object value=DatabaseHelper.ExecuteScalar(c,t,"SELECT ActivityID FROM dbo.SimStep WHERE StepID=@id",ActivityHelper.ID(step));
            if(value==null)return new ValidationResult {IsValid=false,Message="Step not found."};
            DataRow a=ScenarioHelper.RequireOwned(c,t,Convert.ToInt32(value),false);
            bool blocked=ContentLockHelper.HasAttempts(c,t,(int)a["ActivityID"]) || (!a.IsNull("StartStepID") && (int)a["StartStepID"]==step) || Convert.ToInt32(DatabaseHelper.ExecuteScalar(c,t,"SELECT COUNT(*) FROM dbo.SimChoice WHERE NextStepID=@id",ActivityHelper.ID(step)))>0;
            return new ValidationResult {IsValid=!blocked,Message=blocked ? "Cannot delete: attempts exist, this is the start step, or incoming choices reference it. Select another start and remove incoming choices first; attempts permanently lock content." : "Step can be deleted."};
        }
        public static ValidationResult DeleteStep(int stepID)
        {
            string path;
            using(var c=DatabaseHelper.OpenConnection())using(var t=c.BeginTransaction(IsolationLevel.Serializable))
            {
                ValidationResult check=CheckStep(c,t,stepID);if(!check.IsValid)return check;
                DataRow s=DatabaseHelper.ExecuteTable(c,t,"SELECT * FROM dbo.SimStep WHERE StepID=@id",ActivityHelper.ID(stepID)).Rows[0];
                DataRow a=ScenarioHelper.RequireOwned(c,t,(int)s["ActivityID"],true);path=Convert.ToString(s["ImagePath"]);
                if(!String.IsNullOrEmpty(path))UploadHelper.GetValidatedPath(path);
                DatabaseHelper.ExecuteNonQuery(c,t,"DELETE dbo.SimChoice WHERE FromStepID=@id;DELETE dbo.SimStep WHERE StepID=@id",ActivityHelper.ID(stepID));
                ScenarioHelper.KeepPublishedValid(c,t,a);AccessHelper.TouchCourse(c,t,(int)a["CourseID"]);t.Commit();
            }
            string cleanup=UploadHelper.Cleanup(path);return new ValidationResult {IsValid=true,Message="Step deleted. "+cleanup};
        }
    }
}

