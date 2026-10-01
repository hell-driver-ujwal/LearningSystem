using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Text.RegularExpressions;
namespace LearningSystem.Helpers
{
    public static partial class GameHelper
    {
        internal static readonly string[] Templates = { "Matching", "Memory", "Scramble", "Sort", "Flashcards", "FillBlank", "TrueFalse", "Sequence" };
        internal static bool IsTemplate(string value) { return Array.IndexOf(Templates, value) >= 0; }
        // Friendly names shown to learners and lecturers; the database keeps the short template value.
        internal static string TemplateName(string value)
        {
            switch (value)
            {
                case "Scramble": return "Word scramble";
                case "Sort": return "Sort into groups";
                case "FillBlank": return "Fill in the blank";
                case "TrueFalse": return "True or false speed round";
                case "Sequence": return "Put in order";
                default: return value;
            }
        }
        // Largest number of items each template can hold, so a game stays playable on a phone.
        internal static int MaxItems(string template)
        {
            switch (template)
            {
                case "Memory": return 12;
                case "Sequence": return 10;
                case "FillBlank": return 15;
                case "TrueFalse": return 20;
                default: return 30;
            }
        }
        internal static bool IsBlankSentence(string sentence)
        {
            int first = sentence.IndexOf("___", StringComparison.Ordinal);
            return first >= 0 && sentence.IndexOf("___", first + 3, StringComparison.Ordinal) < 0;
        }
        internal static int Position(object value)
        {
            int position;
            return Int32.TryParse(Convert.ToString(value), out position) ? position : 0;
        }
        internal static DataTable Items(int id,SqlConnection c=null,SqlTransaction t=null)
        {
            const string sql="SELECT i.ItemID,i.ItemText,i.MatchText,i.GroupID,g.GroupName FROM dbo.GameItem i LEFT JOIN dbo.GameGroup g ON g.GroupID=i.GroupID WHERE i.ActivityID=@id ORDER BY i.ItemID";
            return c==null ? DatabaseHelper.ExecuteTable(sql,ActivityHelper.ID(id)) : DatabaseHelper.ExecuteTable(c,t,sql,ActivityHelper.ID(id));
        }
        internal static DataTable Groups(int id,SqlConnection c=null,SqlTransaction t=null)
        {
            const string sql="SELECT GroupID,GroupName FROM dbo.GameGroup WHERE ActivityID=@id ORDER BY GroupID";
            return c==null ? DatabaseHelper.ExecuteTable(sql,ActivityHelper.ID(id)) : DatabaseHelper.ExecuteTable(c,t,sql,ActivityHelper.ID(id));
        }
        private static DataRow RequireGame(SqlConnection c,SqlTransaction t,int id,bool content)
        {
            AccessHelper.RequireOwner(c,t,id,"Activity");
            DataRow a=ActivityHelper.Find(id,c,t);
            if(a==null || (string)a["ActivityType"]!="Game")throw new UnauthorizedAccessException();
            if(content && ContentLockHelper.HasAttempts(c,t,id))throw new InvalidOperationException("Game content is locked because attempts exist.");
            return a;
        }
        internal static int SaveSettings(int id,int topic,string title,string description,int order,string template,string status)
        {
            ActivityHelper.CheckText(title,3,100,"Title");ActivityHelper.CheckText(description,0,1000,"Description");
            if(order<1 || !IsTemplate(template) || (status!="Draft" && status!="Published"))throw new InvalidOperationException("Check the order, template and publication setting.");
            using(var c=DatabaseHelper.OpenConnection())
            using(var t=c.BeginTransaction(IsolationLevel.Serializable))
            {
                AccessHelper.RequireOwner(c,t,topic,"Topic");
                int course=Convert.ToInt32(DatabaseHelper.ExecuteScalar(c,t,"SELECT CourseID FROM dbo.Topic WHERE TopicID=@id",ActivityHelper.ID(topic)));
                if(id>0)
                {
                    DataRow old=RequireGame(c,t,id,false);
                    if((int)old["TopicID"]!=topic)throw new UnauthorizedAccessException();
                    bool templateChanged=(string)old["GameTemplate"]!=template;
                    if(ContentLockHelper.HasAttempts(c,t,id) && (templateChanged || (int)old["SortOrder"]!=order))throw new InvalidOperationException("Template and structural ordering are locked after attempts.");
                    if(templateChanged && (Items(id,c,t).Rows.Count>0 || Groups(id,c,t).Rows.Count>0))throw new InvalidOperationException("Remove game items and empty groups before changing the template.");
                }
                var p=new[] {new SqlParameter("@id",id),new SqlParameter("@topic",topic),new SqlParameter("@title",title),new SqlParameter("@description",description.Length==0 ? (object)DBNull.Value : description),new SqlParameter("@order",order),new SqlParameter("@template",template),new SqlParameter("@status",status)};
                if(id==0)id=Convert.ToInt32(DatabaseHelper.ExecuteScalar(c,t,"INSERT dbo.Activity(TopicID,ActivityType,Title,Description,SortOrder,GameTemplate,Status) VALUES(@topic,'Game',@title,@description,@order,@template,@status);SELECT CAST(SCOPE_IDENTITY() AS int)",p));
                else DatabaseHelper.ExecuteNonQuery(c,t,"UPDATE dbo.Activity SET Title=@title,Description=@description,SortOrder=@order,GameTemplate=@template,Status=@status WHERE ActivityID=@id",p);
                if(status=="Published")CheckPublished(c,t,id);
                AccessHelper.TouchCourse(c,t,course);t.Commit();return id;
            }
        }
        private static void CheckPublished(SqlConnection c,SqlTransaction t,int id)
        {
            ValidationResult check=PublishHelper.CheckGame(c,t,id);
            if(!check.IsValid)throw new InvalidOperationException(check.Message+" Save as Draft or unpublish first.");
        }
        internal static void SaveItem(int activity,int item,string text,string match,int group,bool delete)
        {
            using(var c=DatabaseHelper.OpenConnection())
            using(var t=c.BeginTransaction(IsolationLevel.Serializable))
            {
                DataRow a=RequireGame(c,t,activity,true);string template=(string)a["GameTemplate"];
                DataTable items=Items(activity,c,t);
                if(item>0 && items.Select("ItemID="+item).Length!=1)throw new UnauthorizedAccessException();
                if(delete)DatabaseHelper.ExecuteNonQuery(c,t,"DELETE dbo.GameItem WHERE ItemID=@item AND ActivityID=@id",new[] {new SqlParameter("@item",item),new SqlParameter("@id",activity)});
                else
                {
                    ActivityHelper.CheckText(text,1,100,"Item text");
                    if(template=="Scramble" && !Regex.IsMatch(text,"^[A-Za-z]{3,15}$"))throw new InvalidOperationException("Scramble words must contain 3 to 15 letters (A to Z) only.");
                    if(template!="Sort")ActivityHelper.CheckText(match,1,200,template=="Scramble" ? "Hint" : template=="FillBlank" || template=="TrueFalse" ? "Sentence" : template=="Sequence" ? "Position" : "Match text");
                    if(template=="Sort" && Convert.ToInt32(DatabaseHelper.ExecuteScalar(c,t,"SELECT COUNT(*) FROM dbo.GameGroup WHERE GroupID=@group AND ActivityID=@id",new[] {new SqlParameter("@group",group),new SqlParameter("@id",activity)}))!=1)throw new InvalidOperationException("Choose a group belonging to this game.");
                    if(template=="FillBlank" && !IsBlankSentence(match))throw new InvalidOperationException("The sentence must contain exactly one blank written as three underscores: ___");
                    if(template=="TrueFalse" && text!="True" && text!="False")throw new InvalidOperationException("Choose True or False as the correct answer.");
                    if(template=="Sequence" && (Position(match)<1 || Position(match)>MaxItems(template)))throw new InvalidOperationException("The position must be a whole number from 1 to "+MaxItems(template)+".");
                    // True/False answers repeat by design, and two sentences may share an answer word.
                    bool distinctText=template!="TrueFalse" && template!="FillBlank";
                    bool distinctMatch=template!="Scramble" && template!="Sort" && template!="Flashcards";
                    foreach(DataRow other in items.Rows)
                    {
                        if((int)other["ItemID"]==item)continue;
                        if(distinctText && String.Equals(text,(string)other["ItemText"],StringComparison.OrdinalIgnoreCase))throw new InvalidOperationException("Each item must be different from the others in this game.");
                        if(distinctMatch && String.Equals(match,Convert.ToString(other["MatchText"]),StringComparison.OrdinalIgnoreCase))throw new InvalidOperationException(template=="Sequence" ? "Each step needs its own position." : "Each match, sentence or statement must be different from the others in this game.");
                    }
                    if(item==0 && items.Rows.Count>=MaxItems(template))throw new InvalidOperationException(TemplateName(template)+" supports at most "+MaxItems(template)+" items.");
                    DatabaseHelper.ExecuteNonQuery(c,t,item==0 ? "INSERT dbo.GameItem(ActivityID,ItemText,MatchText,GroupID) VALUES(@id,@text,@match,@group)" : "UPDATE dbo.GameItem SET ItemText=@text,MatchText=@match,GroupID=@group WHERE ItemID=@item AND ActivityID=@id",new[] {new SqlParameter("@id",activity),new SqlParameter("@item",item),new SqlParameter("@text",text),new SqlParameter("@match",template=="Sort" ? (object)DBNull.Value : match),new SqlParameter("@group",template=="Sort" ? (object)group : DBNull.Value)});
                }
                if((string)a["Status"]=="Published")CheckPublished(c,t,activity);
                AccessHelper.TouchCourse(c,t,(int)a["CourseID"]);t.Commit();
            }
        }
        internal static void SaveGroup(int activity,int group,string name,bool delete)
        {
            using(var c=DatabaseHelper.OpenConnection())
            using(var t=c.BeginTransaction(IsolationLevel.Serializable))
            {
                DataRow a=RequireGame(c,t,activity,true);
                if((string)a["GameTemplate"]!="Sort")throw new InvalidOperationException("Groups belong only to Sort games.");
                DataTable groups=Groups(activity,c,t);
                if(group>0 && groups.Select("GroupID="+group).Length!=1)throw new UnauthorizedAccessException();
                if(delete)
                {
                    if(Convert.ToInt32(DatabaseHelper.ExecuteScalar(c,t,"SELECT COUNT(*) FROM dbo.GameItem WHERE GroupID=@id",ActivityHelper.ID(group)))>0)throw new InvalidOperationException("Move or delete this group's items before deleting the group.");
                    DatabaseHelper.ExecuteNonQuery(c,t,"DELETE dbo.GameGroup WHERE GroupID=@group AND ActivityID=@id",new[] {new SqlParameter("@group",group),new SqlParameter("@id",activity)});
                }
                else
                {
                    ActivityHelper.CheckText(name,1,50,"Group name");
                    if(group==0 && groups.Rows.Count>=4)throw new InvalidOperationException("Sort supports at most four groups.");
                    foreach(DataRow other in groups.Rows)if((int)other["GroupID"]!=group && String.Equals(name,(string)other["GroupName"],StringComparison.OrdinalIgnoreCase))throw new InvalidOperationException("Group names must be distinct.");
                    DatabaseHelper.ExecuteNonQuery(c,t,group==0 ? "INSERT dbo.GameGroup(ActivityID,GroupName) VALUES(@id,@name)" : "UPDATE dbo.GameGroup SET GroupName=@name WHERE GroupID=@group AND ActivityID=@id",new[] {new SqlParameter("@id",activity),new SqlParameter("@group",group),new SqlParameter("@name",name)});
                }
                if((string)a["Status"]=="Published")CheckPublished(c,t,activity);
                AccessHelper.TouchCourse(c,t,(int)a["CourseID"]);t.Commit();
            }
        }
        internal static DataTable TeacherResults(int id)
        {
            using(var c=DatabaseHelper.OpenConnection())
            using(var t=c.BeginTransaction(IsolationLevel.Serializable))
            {
                RequireGame(c,t,id,false);
                DataTable rows=DatabaseHelper.ExecuteTable(c,t,"SELECT u.FullName,a.AttemptID,a.SubmittedAt,a.ScorePercent,a.TimeTakenSeconds FROM dbo.Attempt a JOIN dbo.[User] u ON u.UserID=a.LearnerID WHERE a.ActivityID=@id ORDER BY a.SubmittedAt DESC,a.AttemptID DESC",ActivityHelper.ID(id));
                t.Commit();return rows;
            }
        }
    }
    public static partial class PublishHelper
    {
        public static ValidationResult CheckGame(int activityID){using(var c=DatabaseHelper.OpenConnection())return CheckGame(c,null,activityID);}
        internal static ValidationResult CheckGame(SqlConnection c,SqlTransaction t,int id)
        {
            DataRow a=ActivityHelper.Find(id,c,t);
            bool valid=a!=null && (string)a["ActivityType"]=="Game";
            string template=valid ? Convert.ToString(a["GameTemplate"]) : "";
            DataTable items=GameHelper.Items(id,c,t),groups=GameHelper.Groups(id,c,t);
            valid=valid && GameHelper.IsTemplate(template);
            if(template=="Matching")valid=valid && items.Rows.Count>=4;
            if(template=="Memory")valid=valid && items.Rows.Count>=4 && items.Rows.Count<=12;
            if(template=="Scramble" || template=="FillBlank" || template=="Sequence")valid=valid && items.Rows.Count>=3;
            if(template=="Flashcards" || template=="TrueFalse")valid=valid && items.Rows.Count>=4;
            if(valid)valid=items.Rows.Count<=GameHelper.MaxItems(template);
            if(template=="Sort")
            {
                valid=valid && groups.Rows.Count>=2 && groups.Rows.Count<=4;
                foreach(DataRow group in groups.Rows)if(items.Select("GroupID="+group["GroupID"]).Length<2)valid=false;
            }
            var texts=new HashSet<string>(StringComparer.OrdinalIgnoreCase);var matches=new HashSet<string>(StringComparer.OrdinalIgnoreCase);
            foreach(DataRow item in items.Rows)
            {
                string text=Convert.ToString(item["ItemText"]).Trim(),match=Convert.ToString(item["MatchText"]).Trim();
                bool distinctText=template!="TrueFalse" && template!="FillBlank";
                if(text.Length<1 || text.Length>100 || (distinctText && !texts.Add(text)))valid=false;
                if(template=="Sort") {if(item.IsNull("GroupID") || groups.Select("GroupID="+item["GroupID"]).Length!=1)valid=false;}
                else if(match.Length<1 || match.Length>200)valid=false;
                if((template=="Matching" || template=="Memory" || template=="FillBlank" || template=="TrueFalse" || template=="Sequence") && !matches.Add(match))valid=false;
                if(template=="Scramble" && !Regex.IsMatch(text,"^[A-Za-z]{3,15}$"))valid=false;
                if(template=="FillBlank" && !GameHelper.IsBlankSentence(match))valid=false;
                if(template=="TrueFalse" && text!="True" && text!="False")valid=false;
                // Sequence positions must be exactly 1, 2, 3 ... with no gaps.
                if(template=="Sequence" && (GameHelper.Position(match)<1 || GameHelper.Position(match)>items.Rows.Count))valid=false;
            }
            return new ValidationResult {IsValid=valid,Message="Publish needs valid, distinct items: Matching at least 4 pairs; Memory 4 to 12 pairs; Word scramble at least 3 words with hints; Sort 2 to 4 groups with at least 2 items in each; Flashcards and True or false at least 4 items; Fill in the blank and Put in order at least 3 items, with positions numbered 1, 2, 3 without gaps."};
        }
    }
}
