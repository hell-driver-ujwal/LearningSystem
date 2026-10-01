using System;
using System.Data;
using System.Data.SqlClient;
namespace LearningSystem.Helpers
{
    internal static class DiscussionHelper
    {
        internal static void Save(int activity,int post,int parent,string content)
        {
            ActivityHelper.CheckText(content,2,2000,"Post");
            using(var c=DatabaseHelper.OpenConnection())
            using(var t=c.BeginTransaction(IsolationLevel.Serializable))
            {
                int user=CurrentUserHelper.GetUserID().GetValueOrDefault();
                if(!AccessHelper.DiscussionPermission(c,t,user,activity,post,post==0 ? "Write" : "Edit"))throw new UnauthorizedAccessException();
                if(post==0 && parent>0 && Convert.ToInt32(DatabaseHelper.ExecuteScalar(c,t,"SELECT COUNT(*) FROM dbo.DiscussionPost WHERE PostID=@id AND ActivityID=@activity AND ParentPostID IS NULL",new[] {new SqlParameter("@id",parent),new SqlParameter("@activity",activity)}))!=1)throw new InvalidOperationException("Replies must belong to a top-level post in this discussion.");
                DatabaseHelper.ExecuteNonQuery(c,t,post==0 ? "INSERT dbo.DiscussionPost(ActivityID,UserID,ParentPostID,Content) VALUES(@activity,@user,@parent,@text)" : "UPDATE dbo.DiscussionPost SET Content=@text,EditedDate=SYSUTCDATETIME() WHERE PostID=@id AND ActivityID=@activity AND UserID=@user",new[] {new SqlParameter("@id",post),new SqlParameter("@activity",activity),new SqlParameter("@user",user),new SqlParameter("@parent",parent==0 ? (object)DBNull.Value : parent),new SqlParameter("@text",content)});
                t.Commit();
            }
        }
    }
}
