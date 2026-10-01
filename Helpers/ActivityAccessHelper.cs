using System;
using System.Data;
using System.Data.SqlClient;
namespace LearningSystem.Helpers
{
    public static partial class AccessHelper
    {
        public static bool IsOwnerOfActivity(int userID,int activityID) { return Owns(userID,activityID,"Activity"); }
        internal static bool ActivityAccess(SqlConnection c,SqlTransaction t,int user,int id,bool preview)
        {
            if(CurrentUserHelper.GetUserID()!=user)return false;
            DataRow a=ActivityHelper.Find(id,c,t); if(a==null)return false;
            DataTable users=DatabaseHelper.ExecuteTable(c,t,"SELECT Role FROM dbo.[User] WHERE UserID=@id AND Status='Active'",ActivityHelper.ID(user));
            if(users.Rows.Count!=1)return false;
            string role=(string)users.Rows[0]["Role"];
            bool owner=role=="Teacher" && (int)a["TeacherID"]==user;
            if(preview)return owner || role=="Admin";
            if(!ActivityHelper.Published(a))return false;
            if((string)a["ActivityType"]=="Discussion" && (owner || role=="Admin"))return true;
            return role=="Learner" && Convert.ToInt32(DatabaseHelper.ExecuteScalar(c,t,"SELECT COUNT(*) FROM dbo.Enrolment WHERE LearnerID=@user AND CourseID=@course",new[] {new SqlParameter("@user",user),new SqlParameter("@course",a["CourseID"])}))==1;
        }
        public static bool CanAccessActivity(int userID,int activityID,bool preview) { using(var c=DatabaseHelper.OpenConnection())return ActivityAccess(c,null,userID,activityID,preview); }
        public static bool CanPreview(int userID,int activityID) { return CanAccessActivity(userID,activityID,true); }
        public static bool CanViewAttempt(int userID,int attemptID)
        {
            if(CurrentUserHelper.GetUserID()!=userID)return false;
            return Convert.ToInt32(DatabaseHelper.ExecuteScalar("SELECT COUNT(*) FROM dbo.Attempt r JOIN dbo.Activity a ON a.ActivityID=r.ActivityID JOIN dbo.Topic t ON t.TopicID=a.TopicID JOIN dbo.Course c ON c.CourseID=t.CourseID JOIN dbo.[User] u ON u.UserID=@user WHERE r.AttemptID=@id AND u.Status='Active' AND (u.Role='Admin' OR (u.Role='Teacher' AND c.TeacherID=@user) OR (u.Role='Learner' AND r.LearnerID=@user))",new[] {new SqlParameter("@id",attemptID),new SqlParameter("@user",userID)}))==1;
        }
        internal static bool DiscussionPermission(SqlConnection c,SqlTransaction t,int user,int activity,int post,string action)
        {
            if(!ActivityAccess(c,t,user,activity,false))return false;
            DataRow a=ActivityHelper.Find(activity,c,t);
            if((string)a["ActivityType"]!="Discussion")return false;
            string role=CurrentUserHelper.GetRole();
            bool moderator=role=="Admin" || (role=="Teacher" && (int)a["TeacherID"]==user);
            if(action=="Write")return !(bool)a["IsClosed"] && role!="Admin";
            DataTable posts=DatabaseHelper.ExecuteTable(c,t,"SELECT UserID FROM dbo.DiscussionPost WHERE PostID=@id AND ActivityID=@activity",new[] {new SqlParameter("@id",post),new SqlParameter("@activity",activity)});
            if(posts.Rows.Count!=1)return false;
            if(action=="Delete" && moderator)return true;
            return !(bool)a["IsClosed"] && role!="Admin" && (int)posts.Rows[0]["UserID"]==user;
        }
        public static bool CanWriteDiscussion(int userID,int activityID) { using(var c=DatabaseHelper.OpenConnection())return DiscussionPermission(c,null,userID,activityID,0,"Write"); }
        private static bool PostPermission(int userID,int postID,string action)
        {
            using(var c=DatabaseHelper.OpenConnection())
            {
                object id=DatabaseHelper.ExecuteScalar(c,null,"SELECT ActivityID FROM dbo.DiscussionPost WHERE PostID=@id",ActivityHelper.ID(postID));
                return id!=null && DiscussionPermission(c,null,userID,Convert.ToInt32(id),postID,action);
            }
        }
        public static bool CanEditPost(int userID,int postID) { return PostPermission(userID,postID,"Edit"); }
        public static bool CanDeletePost(int userID,int postID) { return PostPermission(userID,postID,"Delete"); }
    }
    public static partial class PublishHelper
    {
        public static ValidationResult CheckQuiz(int activityID) { using(var c=DatabaseHelper.OpenConnection())return CheckQuiz(c,null,activityID); }
        internal static ValidationResult CheckQuiz(SqlConnection c,SqlTransaction t,int id)
        {
            DataTable rows=DatabaseHelper.ExecuteTable(c,t,"SELECT q.QuestionID,COUNT(o.OptionID) AS Options,SUM(CASE WHEN o.IsCorrect=1 THEN 1 ELSE 0 END) AS Correct FROM dbo.QuizQuestion q LEFT JOIN dbo.QuizOption o ON o.QuestionID=q.QuestionID WHERE q.ActivityID=@id GROUP BY q.QuestionID",ActivityHelper.ID(id));
            bool valid=rows.Rows.Count>0;
            foreach(DataRow row in rows.Rows) if((int)row["Options"]<2 || (int)row["Options"]>6 || (int)row["Correct"]!=1)valid=false;
            return new ValidationResult {IsValid=valid,Message="A published quiz needs at least one question, with 2–6 distinct options and exactly one correct option per question."};
        }
        public static ValidationResult CheckDiscussion(int activityID)
        {
            DataRow row=ActivityHelper.Find(activityID);
            return new ValidationResult {IsValid=row!=null && (string)row["ActivityType"]=="Discussion" && Convert.ToString(row["Title"]).Trim().Length>=5 && Convert.ToString(row["Description"]).Trim().Length>=10,Message="Enter a valid discussion title and prompt."};
        }
    }
    public static partial class DeleteHelper
    {
        public static ValidationResult DeletePost(int postID)
        {
            using(var c=DatabaseHelper.OpenConnection())
            using(var t=c.BeginTransaction(IsolationLevel.Serializable))
            {
                object activity=DatabaseHelper.ExecuteScalar(c,t,"SELECT ActivityID FROM dbo.DiscussionPost WHERE PostID=@id",ActivityHelper.ID(postID));
                if(activity==null || !AccessHelper.DiscussionPermission(c,t,CurrentUserHelper.GetUserID().GetValueOrDefault(),Convert.ToInt32(activity),postID,"Delete"))return new ValidationResult {IsValid=false,Message="You cannot remove this post."};
                DatabaseHelper.ExecuteNonQuery(c,t,"DELETE dbo.DiscussionPost WHERE ParentPostID=@id",ActivityHelper.ID(postID));
                DatabaseHelper.ExecuteNonQuery(c,t,"DELETE dbo.DiscussionPost WHERE PostID=@id",ActivityHelper.ID(postID));
                t.Commit();return new ValidationResult {IsValid=true,Message="Post and its replies removed."};
            }
        }
    }
}
