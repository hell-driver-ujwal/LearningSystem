using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using LearningSystem.Helpers;
namespace LearningSystem.Member
{
    public partial class Lesson : Page
    {
        private int materialID;
        private bool preview;
        protected void Page_Load(object sender,EventArgs e)
        {
            AccessHelper.RequireRole(new[] {"Learner","Teacher","Admin"});
            materialID=CourseHelper.QueryID("id");preview=Request.QueryString["preview"]=="1";
            if(Request.QueryString["preview"]!=null && !preview) {Response.Redirect("~/NotFound.aspx");return;}
            try
            {
                DataRow row=MaterialHelper.Find(materialID);
                if(row==null || (!MaterialHelper.Published(row) && (!preview || CurrentUserHelper.GetRole()=="Learner"))) {Response.Redirect("~/NotFound.aspx");return;}
                if(!AccessHelper.CanAccessMaterial(CurrentUserHelper.GetUserID().Value,materialID,preview)) {Response.Redirect("~/AccessDenied.aspx");return;}
                Title=(string)row["Title"];litTitle.Text=Title;MaterialHelper.Render(phViewer,row,preview);
                ((SiteMaster)Master).Breadcrumb=BreadcrumbHelper.ForMaterial(row,preview,false);
                pnlPreview.Visible=preview;btnComplete.Visible=!preview;
                int courseID=(int)row["CourseID"];
                string back=preview ? (CurrentUserHelper.GetRole()=="Admin" ? "~/Admin/Courses.aspx" : "~/Teacher/CourseBuilder.aspx?id="+courseID) : "~/Learner/CourseHome.aspx?id="+courseID;
                lnkBack.NavigateUrl=back;lnkExit.NavigateUrl=back;
                if(!preview)
                {
                    bool done=Convert.ToInt32(DatabaseHelper.ExecuteScalar("SELECT COUNT(*) FROM dbo.MaterialCompletion WHERE LearnerID=@user AND MaterialID=@id",new[] {new SqlParameter("@user",CurrentUserHelper.GetUserID().Value),new SqlParameter("@id",materialID)}))>0;
                    litCompleted.Text=done ? "✓ Lesson completed." : "Mark this lesson complete when you have finished studying.";btnComplete.Enabled=!done;
                }
                btnBookmark.Visible=!preview && CurrentUserHelper.GetRole()=="Learner";
                if(btnBookmark.Visible){bool saved=BookmarkHelper.Exists(materialID);btnBookmark.Text=saved ? "Remove bookmark" : "Add bookmark";btnBookmark.OnClientClick=saved ? "return confirm('Remove this bookmark?');" : "";if(!IsPostBack)ViewState["BookmarkAdd"]=!saved;}
                BindNavigation(courseID);
            }
            catch(SqlException) {Response.Redirect("~/Error.aspx");}
        }
        private void BindNavigation(int courseID)
        {
            DataTable materials=DatabaseHelper.ExecuteTable("SELECT m.MaterialID FROM dbo.Material m JOIN dbo.Topic t ON t.TopicID=m.TopicID WHERE t.CourseID=@course AND (@preview=1 OR m.Status='Published') ORDER BY t.SortOrder,t.TopicID,m.SortOrder,m.MaterialID",new[] {new SqlParameter("@course",courseID),new SqlParameter("@preview",preview)});
            string suffix=preview ? "&preview=1" : "";
            for(int i=0;i<materials.Rows.Count;i++)
            {
                if((int)materials.Rows[i]["MaterialID"]!=materialID)continue;
                if(i>0){lnkPrevious.Visible=true;lnkPrevious.NavigateUrl="Lesson.aspx?id="+materials.Rows[i-1]["MaterialID"]+suffix;}
                if(i+1<materials.Rows.Count){lnkNext.Visible=true;lnkNext.NavigateUrl="Lesson.aspx?id="+materials.Rows[i+1]["MaterialID"]+suffix;}
                break;
            }
        }
        protected void MarkComplete(object sender,EventArgs e)
        {
            if (!Page.IsValid) return;
            if(preview || CurrentUserHelper.GetRole()!="Learner") {Response.Redirect("~/AccessDenied.aspx");return;}
            try
            {
                using(SqlConnection connection=DatabaseHelper.OpenConnection())
                using(SqlTransaction transaction=connection.BeginTransaction(IsolationLevel.Serializable))
                {
                    int published=Convert.ToInt32(DatabaseHelper.ExecuteScalar(connection,transaction,"SELECT COUNT(*) FROM dbo.Material m JOIN dbo.Topic t ON t.TopicID=m.TopicID JOIN dbo.Course c ON c.CourseID=t.CourseID WHERE m.MaterialID=@id AND m.Status='Published' AND c.Status='Published'",new[] {new SqlParameter("@id",materialID)}));
                    if(published!=1){Response.Redirect("~/NotFound.aspx");return;}
                    int allowed=Convert.ToInt32(DatabaseHelper.ExecuteScalar(connection,transaction,"SELECT COUNT(*) FROM dbo.Material m JOIN dbo.Topic t ON t.TopicID=m.TopicID JOIN dbo.Enrolment e ON e.CourseID=t.CourseID JOIN dbo.[User] u ON u.UserID=e.LearnerID WHERE m.MaterialID=@id AND e.LearnerID=@user AND u.Role='Learner' AND u.Status='Active'",new[] {new SqlParameter("@id",materialID),new SqlParameter("@user",CurrentUserHelper.GetUserID().Value)}));
                    if(allowed!=1){Response.Redirect("~/AccessDenied.aspx");return;}
                    DatabaseHelper.ExecuteNonQuery(connection,transaction,"IF NOT EXISTS(SELECT 1 FROM dbo.MaterialCompletion WHERE LearnerID=@user AND MaterialID=@id) INSERT dbo.MaterialCompletion (LearnerID,MaterialID) VALUES (@user,@id)",new[] {new SqlParameter("@user",CurrentUserHelper.GetUserID().Value),new SqlParameter("@id",materialID)});
                    transaction.Commit();
                }
                MessageHelper.SetSuccess("Lesson marked complete. Your progress has been updated.");Response.Redirect("Lesson.aspx?id="+materialID);
            }
            catch(SqlException) {MessageHelper.SetError("Completion could not be saved. Please try again.");}
        }
        protected void SetBookmark(object sender,EventArgs e)
        {
            if(!Page.IsValid)return;
            if(preview || CurrentUserHelper.GetRole()!="Learner"){Response.Redirect("~/AccessDenied.aspx");return;}
            try{BookmarkHelper.Set(materialID,Convert.ToBoolean(ViewState["BookmarkAdd"]));MessageHelper.SetSuccess("Bookmark updated.");Response.Redirect("Lesson.aspx?id="+materialID);}
            catch(UnauthorizedAccessException){Response.Redirect("~/AccessDenied.aspx");}
            catch(SqlException){MessageHelper.SetError("Bookmark could not be changed.");}
        }    }
}

