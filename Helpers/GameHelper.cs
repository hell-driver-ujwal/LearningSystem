using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Security.Cryptography;
using System.Text;
using System.Web;
using System.Web.Script.Serialization;
namespace LearningSystem.Helpers
{
    public class GameResult
    {
        public int timeTakenSeconds {get;set;}
        public int? moves {get;set;}
        public GameAnswer[] answers {get;set;}
    }
    public class GameAnswer
    {
        public int itemId {get;set;}
        public string value {get;set;}
    }
    internal class GameRun
    {
        internal int UserID;
        internal string Token,Definition;
        internal DateTime Started;
        internal bool Finished,Completed;
        internal int AttemptID,Seconds;
        internal decimal Score;
    }
    public static partial class GameHelper
    {
        public static GameResult ParseResult(string json)
        {
            try
            {
                if(String.IsNullOrWhiteSpace(json))throw new InvalidOperationException("Play the game before submitting.");
                var serializer=new JavaScriptSerializer();
                RejectDuplicateKeys(json,serializer);
                var root=serializer.DeserializeObject(json) as Dictionary<string,object>;
                if(root==null || !root.ContainsKey("timeTakenSeconds") || !root.ContainsKey("answers") || (root.Count!=2 && !(root.Count==3 && root.ContainsKey("moves"))))throw new InvalidOperationException("Invalid result fields.");
                if(!(root["timeTakenSeconds"] is int) || (int)root["timeTakenSeconds"]<0)throw new InvalidOperationException("Invalid reported time.");
                var result=new GameResult {timeTakenSeconds=(int)root["timeTakenSeconds"]};
                if(root.ContainsKey("moves"))
                {
                    if(!(root["moves"] is int) || (int)root["moves"]<1)throw new InvalidOperationException("Moves must be a positive integer.");
                    result.moves=(int)root["moves"];
                }
                object[] entries=root["answers"] as object[];
                if(entries==null)throw new InvalidOperationException("Answers must be an array.");
                var answers=new List<GameAnswer>();var ids=new HashSet<int>();
                foreach(object entry in entries)
                {
                    var answer=entry as Dictionary<string,object>;
                    if(answer==null || answer.Count!=2 || !answer.ContainsKey("itemId") || !answer.ContainsKey("value") || !(answer["itemId"] is int) || !(answer["value"] is string))throw new InvalidOperationException("Invalid answer fields.");
                    int id=(int)answer["itemId"];string value=(string)answer["value"];
                    if(id<1 || !ids.Add(id) || value.Length>200)throw new InvalidOperationException("Invalid or duplicate game item.");
                    answers.Add(new GameAnswer {itemId=id,value=value});
                }
                result.answers=answers.ToArray();return result;
            }
            catch(ArgumentException){throw new InvalidOperationException("Malformed game result. Play again and submit a valid result.");}
            catch(FormatException){throw new InvalidOperationException("Malformed game result.");}
        }
        private static void RejectDuplicateKeys(string json,JavaScriptSerializer serializer)
        {
            // JavaScriptSerializer accepts repeated keys. Reject them before it can overwrite a value.
            var objects=new Stack<HashSet<string>>();
            for(int i=0;i<json.Length;i++)
            {
                char ch=json[i];
                if(ch=='{')objects.Push(new HashSet<string>(StringComparer.Ordinal));
                else if(ch=='}'){if(objects.Count>0)objects.Pop();}
                else if(ch=='"')
                {
                    int start=i;i++;
                    for(;i<json.Length;i++){if(json[i]=='\\'){i++;continue;}if(json[i]=='"')break;}
                    if(i>=json.Length)throw new InvalidOperationException("Malformed JSON string.");
                    int next=i+1;while(next<json.Length && Char.IsWhiteSpace(json[next]))next++;
                    if(next<json.Length && json[next]==':' && objects.Count>0)
                    {
                        string key=serializer.Deserialize<string>(json.Substring(start,i-start+1));
                        if(!objects.Peek().Add(key))throw new InvalidOperationException("Duplicate result fields are not allowed.");
                    }
                }
            }
        }
        private static Dictionary<string,GameRun> Runs(int id,bool preview)
        {
            string key=(preview ? "GamePreview_" : "GameRun_")+id;
            var runs=HttpContext.Current.Session[key] as Dictionary<string,GameRun>;
            if(runs==null){runs=new Dictionary<string,GameRun>();HttpContext.Current.Session[key]=runs;}return runs;
        }
        internal static GameRun Run(int id,string token,bool preview)
        {
            GameRun run;
            if(token==null || !Runs(id,preview).TryGetValue(token,out run) || run.UserID!=CurrentUserHelper.GetUserID())return null;
            return run;
        }
        private static string Definition(DataRow a,DataTable items,DataTable groups)
        {
            StringBuilder text=new StringBuilder();
            foreach(string field in new[] {"TopicID","GameTemplate","SortOrder"})text.Append(a[field]).Append('|');
            foreach(DataTable table in new[] {items,groups})foreach(DataRow row in table.Rows)foreach(object value in row.ItemArray){string s=Convert.ToString(value,CultureInfo.InvariantCulture);text.Append(s.Length).Append(':').Append(s);}
            using(SHA256 hash=SHA256.Create())return Convert.ToBase64String(hash.ComputeHash(Encoding.UTF8.GetBytes(text.ToString())));
        }
        internal static GameRun Begin(int id,bool preview)
        {
            DataRow a=ActivityHelper.Require(id,"Game",preview);
            ValidationResult check=PublishHelper.CheckGame(id);
            if(!check.IsValid)throw new InvalidOperationException("This game needs valid playable content. "+check.Message);
            string definition=Definition(a,Items(id),Groups(id));
            foreach(GameRun old in Runs(id,preview).Values)
            {
                if(old.UserID!=CurrentUserHelper.GetUserID() || old.Finished)continue;
                if(old.Definition==definition)return old; // Repeated Start cannot reset server time.
                old.Finished=true;
            }
            var run=new GameRun {UserID=CurrentUserHelper.GetUserID().Value,Token=Guid.NewGuid().ToString("N"),Started=DateTime.UtcNow,Definition=definition};
            Runs(id,preview).Add(run.Token,run);return run;
        }
        private static int Elapsed(GameRun run)
        {
            double seconds=(DateTime.UtcNow-run.Started).TotalSeconds;
            if(run.Started==default(DateTime) || seconds<0 || seconds>Int32.MaxValue)throw new InvalidOperationException("The game session expired. Start again.");
            return (int)Math.Floor(seconds);
        }
        public static decimal CalculateScore(int activityID,GameResult result)
        {
            bool preview=HttpContext.Current.Request.QueryString["preview"]=="1";
            if(!AccessHelper.CanAccessActivity(CurrentUserHelper.GetUserID().GetValueOrDefault(),activityID,preview))throw new UnauthorizedAccessException();
            GameRun active=null;foreach(GameRun run in Runs(activityID,preview).Values)if(run.UserID==CurrentUserHelper.GetUserID() && !run.Finished)active=run;
            if(active==null)throw new InvalidOperationException("Start the game first.");
            DataRow a=ActivityHelper.Find(activityID);DataTable items=Items(activityID),groups=Groups(activityID);
            if(active.Definition!=Definition(a,items,groups))throw new InvalidOperationException("The game changed. Start again.");
            return Score(a,items,groups,result,Elapsed(active));
        }
        private static decimal Score(DataRow a,DataTable items,DataTable groups,GameResult result,int seconds)
        {
            string template=Convert.ToString(a["GameTemplate"]);
            if((string)a["ActivityType"]!="Game" || !IsTemplate(template) || items.Rows.Count==0 || result==null || result.answers==null || result.timeTakenSeconds<0)throw new InvalidOperationException("Invalid game result.");
            if(template=="Memory")
            {
                if(result.answers.Length!=0 || !result.moves.HasValue || result.moves.Value<items.Rows.Count || result.moves.Value<1)throw new InvalidOperationException("Memory must have no answers and at least one complete move per pair.");
                // Decimal arithmetic avoids overflow for a forged very large move count.
                decimal score=100m-5m*Math.Max(0m,(decimal)result.moves.Value-items.Rows.Count)-seconds/10;
                return Math.Round(Math.Max(0m,Math.Min(100m,score)),2,MidpointRounding.AwayFromZero);
            }
            if(result.moves.HasValue || result.answers.Length!=items.Rows.Count)throw new InvalidOperationException("Submit exactly one answer for every game item; moves is Memory-only.");
            var answers=new Dictionary<int,string>();var targets=new HashSet<int>();
            foreach(GameAnswer answer in result.answers)
            {
                if(answer==null || answer.value==null || answers.ContainsKey(answer.itemId) || items.Select("ItemID="+answer.itemId).Length!=1)throw new InvalidOperationException("A submitted item does not belong to this game or is duplicated.");
                answers.Add(answer.itemId,answer.value);
            }
            int correct=0;
            var positions=new HashSet<int>();
            foreach(DataRow item in items.Rows)
            {
                string value=answers[(int)item["ItemID"]];
                if(template=="Flashcards")
                {
                    // Flashcards are self-rated, like a self-assessment: "known" or "learning".
                    if(value!="known" && value!="learning")throw new InvalidOperationException("Rate every flashcard as known or still learning.");
                    if(value=="known")correct++;
                }
                else if(template=="FillBlank")
                {
                    if(value.Trim().Length>100)throw new InvalidOperationException("Each answer must be at most 100 characters.");
                    if(Normalise(value)==Normalise(Convert.ToString(item["ItemText"])))correct++;
                }
                else if(template=="TrueFalse")
                {
                    // "Skip" is sent when the timer runs out before an answer is chosen.
                    if(value!="True" && value!="False" && value!="Skip")throw new InvalidOperationException("Answer each statement with True or False.");
                    if(value==Convert.ToString(item["ItemText"]))correct++;
                }
                else if(template=="Sequence")
                {
                    int position;
                    if(!Int32.TryParse(value,NumberStyles.None,CultureInfo.InvariantCulture,out position) || position<1 || position>items.Rows.Count || !positions.Add(position))throw new InvalidOperationException("Give every step a different position.");
                    if(position==Position(item["MatchText"]))correct++;
                }
                else if(template=="Scramble")
                {
                    value=value.Trim();
                    if(value.Length>0 && !System.Text.RegularExpressions.Regex.IsMatch(value,"^[A-Za-z]{3,15}$"))throw new InvalidOperationException("Scramble answers must contain 3–15 letters only.");
                    if(String.Equals(value,Convert.ToString(item["ItemText"]).Trim(),StringComparison.OrdinalIgnoreCase))correct++;
                }
                else
                {
                    int target;
                    if(!Int32.TryParse(value,NumberStyles.None,CultureInfo.InvariantCulture,out target) || target<1)throw new InvalidOperationException("A target ID is invalid.");
                    if(template=="Matching")
                    {
                        if(items.Select("ItemID="+target).Length!=1 || !targets.Add(target))throw new InvalidOperationException("Matching targets must belong to this game and be used once.");
                        if(target==(int)item["ItemID"])correct++;
                    }
                    else
                    {
                        if(groups.Select("GroupID="+target).Length!=1)throw new InvalidOperationException("The selected group does not belong to this game.");
                        if(!item.IsNull("GroupID") && target==(int)item["GroupID"])correct++;
                    }
                }
            }
            return Math.Round(correct*100m/items.Rows.Count,2,MidpointRounding.AwayFromZero);
        }
        // Compare typed answers fairly: ignore case, outer spaces and repeated inner spaces.
        private static string Normalise(string value)
        {
            return System.Text.RegularExpressions.Regex.Replace(value.Trim(),"\\s+"," ").ToLowerInvariant();
        }
        internal static GameRun Submit(int id,string token,GameResult result,bool preview)
        {
            GameRun run=Run(id,token,preview);
            if(run==null)throw new InvalidOperationException("Game session expired. Start again.");
            using(var c=DatabaseHelper.OpenConnection())
            using(var t=c.BeginTransaction(IsolationLevel.Serializable))
            {
                if(!AccessHelper.ActivityAccess(c,t,run.UserID,id,preview))throw new UnauthorizedAccessException();
                if(run.Finished){if(run.Completed)return run;throw new InvalidOperationException("This game run expired. Start again.");}
                DataRow a=ActivityHelper.Find(id,c,t);DataTable items=Items(id,c,t),groups=Groups(id,c,t);
                if(run.Definition!=Definition(a,items,groups)){run.Finished=true;throw new InvalidOperationException("The game content changed. Nothing was saved. Start again.");}
                int seconds=Elapsed(run);decimal score=Score(a,items,groups,result,seconds);
                int attempt=0;
                if(!preview)
                {
                    attempt=Convert.ToInt32(DatabaseHelper.ExecuteScalar(c,t,"INSERT dbo.Attempt(ActivityID,LearnerID,ScorePercent,TimeTakenSeconds,EndingStepID) VALUES(@id,@user,@score,@seconds,NULL);SELECT CAST(SCOPE_IDENTITY() AS int)",new[] {new SqlParameter("@id",id),new SqlParameter("@user",run.UserID),new SqlParameter("@score",score),new SqlParameter("@seconds",seconds)}));
                    t.Commit();
                }
                run.Score=score;run.Seconds=seconds;run.AttemptID=attempt;run.Finished=true;run.Completed=true;return run;
            }
        }
        internal static string ClientData(int id)
        {
            DataRow a=ActivityHelper.Find(id);var items=new List<object>();var groups=new List<object>();
            string template=(string)a["GameTemplate"];
            DataTable rows=Items(id);
            // Put in order: list steps alphabetically and never send the positions, so the page does not reveal the order.
            if(template=="Sequence")rows.DefaultView.Sort="ItemText";
            foreach(DataRowView view in rows.DefaultView)
            {
                DataRow row=view.Row;string text=(string)row["ItemText"],match=Convert.ToString(row["MatchText"]);
                if(template=="Sequence")match="";
                if(template=="FillBlank")text=""; // the typed answer is checked on the server
                items.Add(new {id=(int)row["ItemID"],text=text,match=match});
            }
            foreach(DataRow row in Groups(id).Rows)groups.Add(new {id=(int)row["GroupID"],name=(string)row["GroupName"]});
            return new JavaScriptSerializer().Serialize(new {template=(string)a["GameTemplate"],items=items,groups=groups});
        }
    }
}

