using System;
using System.Data;
using System.Data.SqlClient;
using System.Web;
namespace LearningSystem.Helpers
{
    internal static class ActivityHelper
    {
        internal static SqlParameter[] ID(int id) { return new[] { new SqlParameter("@id", id) }; }
        internal static DataRow Find(int id, SqlConnection connection = null, SqlTransaction transaction = null)
        {
            const string sql = "SELECT a.*,t.CourseID,t.Title AS TopicTitle,c.Title AS CourseTitle,c.TeacherID,c.Status AS CourseStatus FROM dbo.Activity a JOIN dbo.Topic t ON t.TopicID=a.TopicID JOIN dbo.Course c ON c.CourseID=t.CourseID WHERE a.ActivityID=@id";
            DataTable rows = connection == null ? DatabaseHelper.ExecuteTable(sql, ID(id)) : DatabaseHelper.ExecuteTable(connection, transaction, sql, ID(id));
            return rows.Rows.Count == 1 ? rows.Rows[0] : null;
        }
        internal static bool Published(DataRow row) { return row != null && (string)row["Status"] == "Published" && (string)row["CourseStatus"] == "Published"; }
        internal static string Back(DataRow row)
        {
            string role = CurrentUserHelper.GetRole();
            return role == "Admin" ? "~/Admin/Activities.aspx" : role == "Teacher" ? "~/Teacher/CourseBuilder.aspx?id=" + row["CourseID"] : "~/Learner/CourseHome.aspx?id=" + row["CourseID"];
        }
        internal static DataRow Require(int id, string type, bool preview)
        {
            DataRow row = Find(id);
            if (row == null || (string)row["ActivityType"] != type || (!Published(row) && (!preview || CurrentUserHelper.GetRole() == "Learner")))
                HttpContext.Current.Response.Redirect("~/NotFound.aspx");
            if (!AccessHelper.CanAccessActivity(CurrentUserHelper.GetUserID().GetValueOrDefault(), id, preview))
                HttpContext.Current.Response.Redirect("~/AccessDenied.aspx");
            return row;
        }
        internal static void CheckText(string value, int min, int max, string name)
        {
            if (value == null || value.Length < min || value.Length > max) throw new InvalidOperationException(name + " must contain " + min + "–" + max + " characters.");
        }
        internal static int Save(int id, int topicID, string type, string title, string description, int order, int minutes, int attempts, bool closed, string status)
        {
            CheckText(title, type == "Discussion" ? 5 : 3, 100, "Title");
            CheckText(description, type == "Discussion" ? 10 : 0, 1000, "Description");
            if (order < 1 || minutes < 0 || minutes > 180 || attempts < 0 || attempts > 10 || (status != "Draft" && status != "Published")) throw new InvalidOperationException("Check settings and order.");
            using (SqlConnection connection = DatabaseHelper.OpenConnection())
            using (SqlTransaction transaction = connection.BeginTransaction(IsolationLevel.Serializable))
            {
                AccessHelper.RequireOwner(connection, transaction, topicID, "Topic");
                int course = Convert.ToInt32(DatabaseHelper.ExecuteScalar(connection, transaction, "SELECT CourseID FROM dbo.Topic WHERE TopicID=@id", ID(topicID)));
                if (id > 0)
                {
                    AccessHelper.RequireOwner(connection, transaction, id, "Activity");
                    DataRow old = Find(id, connection, transaction);
                    if ((string)old["ActivityType"] != type || (int)old["TopicID"] != topicID) throw new InvalidOperationException("Activity does not belong to this topic/type.");
                    if (type == "SelfAssessment" && ContentLockHelper.HasAttempts(connection, transaction, id) && (int)old["SortOrder"] != order) throw new InvalidOperationException("Assessment structural ordering is locked after attempts.");
                    if (type == "Quiz" && ContentLockHelper.HasAttempts(connection, transaction, id) && ((int)old["SortOrder"] != order || (int)old["TimeLimitMinutes"] != minutes || (int)old["MaxAttempts"] != attempts))
                        throw new InvalidOperationException("Quiz settings and structural ordering are locked after attempts.");
                }
                SqlParameter[] values = { new SqlParameter("@id",id), new SqlParameter("@topic",topicID), new SqlParameter("@type",type), new SqlParameter("@title",title), new SqlParameter("@description",description.Length == 0 ? (object)DBNull.Value : description), new SqlParameter("@order",order), new SqlParameter("@minutes",type == "Quiz" ? (object)minutes : DBNull.Value), new SqlParameter("@attempts",type == "Quiz" ? (object)attempts : DBNull.Value), new SqlParameter("@closed",type == "Discussion" ? (object)closed : DBNull.Value), new SqlParameter("@status",status) };
                if (id == 0) id = Convert.ToInt32(DatabaseHelper.ExecuteScalar(connection, transaction, "INSERT dbo.Activity (TopicID,ActivityType,Title,Description,SortOrder,TimeLimitMinutes,MaxAttempts,IsClosed,Status) VALUES (@topic,@type,@title,@description,@order,@minutes,@attempts,@closed,@status); SELECT CAST(SCOPE_IDENTITY() AS int)",values));
                else DatabaseHelper.ExecuteNonQuery(connection,transaction,"UPDATE dbo.Activity SET Title=@title,Description=@description,SortOrder=@order,TimeLimitMinutes=@minutes,MaxAttempts=@attempts,IsClosed=@closed,Status=@status WHERE ActivityID=@id",values);
                if (status == "Published" && type == "Quiz")
                {
                    ValidationResult check = PublishHelper.CheckQuiz(connection,transaction,id);
                    if (!check.IsValid) throw new InvalidOperationException(check.Message);
                }
                if (status == "Published" && type == "SelfAssessment")
                {
                    ValidationResult check = PublishHelper.CheckSelfAssessment(connection,transaction,id);
                    if (!check.IsValid) throw new InvalidOperationException(check.Message);
                }
                AccessHelper.TouchCourse(connection,transaction,course); transaction.Commit(); return id;
            }
        }
        internal static void SaveQuestion(int activityID,int questionID,string text,int marks,int order,string[] options,int correct,bool delete)
        {
            using (SqlConnection connection = DatabaseHelper.OpenConnection())
            using (SqlTransaction transaction = connection.BeginTransaction(IsolationLevel.Serializable))
            {
                AccessHelper.RequireOwner(connection,transaction,activityID,"Activity");
                DataRow activity = Find(activityID,connection,transaction);
                if ((string)activity["ActivityType"] != "Quiz") throw new InvalidOperationException("This is not a quiz.");
                if (ContentLockHelper.HasAttempts(connection,transaction,activityID)) throw new InvalidOperationException("Questions and options are locked because this quiz has attempts.");
                if (questionID > 0 && Convert.ToInt32(DatabaseHelper.ExecuteScalar(connection,transaction,"SELECT COUNT(*) FROM dbo.QuizQuestion WHERE QuestionID=@id AND ActivityID=@activity",new[] {new SqlParameter("@id",questionID),new SqlParameter("@activity",activityID)})) != 1) throw new InvalidOperationException("Question does not belong to this quiz.");
                if (delete) DatabaseHelper.ExecuteNonQuery(connection,transaction,"DELETE dbo.QuizQuestion WHERE QuestionID=@id",ID(questionID));
                else
                {
                    CheckText(text,5,500,"Question");
                    if(marks<1 || marks>10 || order<1 || options.Length<2 || options.Length>6 || correct<0 || correct>=options.Length) throw new InvalidOperationException("Provide 2–6 options, exactly one correct option, marks 1–10 and a positive order.");
                    for(int i=0;i<options.Length;i++)
                    {
                        CheckText(options[i],1,200,"Option");
                        for(int j=0;j<i;j++) if(String.Equals(options[i],options[j],StringComparison.OrdinalIgnoreCase)) throw new InvalidOperationException("Options must be distinct.");
                    }
                    var values = new[] {new SqlParameter("@id",questionID),new SqlParameter("@activity",activityID),new SqlParameter("@text",text),new SqlParameter("@marks",marks),new SqlParameter("@order",order)};
                    if(questionID==0) questionID=Convert.ToInt32(DatabaseHelper.ExecuteScalar(connection,transaction,"INSERT dbo.QuizQuestion(ActivityID,QuestionText,Marks,SortOrder) VALUES(@activity,@text,@marks,@order); SELECT CAST(SCOPE_IDENTITY() AS int)",values));
                    else DatabaseHelper.ExecuteNonQuery(connection,transaction,"UPDATE dbo.QuizQuestion SET QuestionText=@text,Marks=@marks,SortOrder=@order WHERE QuestionID=@id",values);
                    DatabaseHelper.ExecuteNonQuery(connection,transaction,"DELETE dbo.QuizOption WHERE QuestionID=@id",ID(questionID));
                    for(int i=0;i<options.Length;i++) DatabaseHelper.ExecuteNonQuery(connection,transaction,"INSERT dbo.QuizOption(QuestionID,OptionText,IsCorrect) VALUES(@question,@text,@correct)",new[] {new SqlParameter("@question",questionID),new SqlParameter("@text",options[i]),new SqlParameter("@correct",i==correct)});
                }
                if((string)activity["Status"]=="Published")
                {
                    ValidationResult check=PublishHelper.CheckQuiz(connection,transaction,activityID);
                    if(!check.IsValid) throw new InvalidOperationException(check.Message+" Unpublish before making this change.");
                }
                AccessHelper.TouchCourse(connection,transaction,(int)activity["CourseID"]);transaction.Commit();
            }
        }
    }
}

