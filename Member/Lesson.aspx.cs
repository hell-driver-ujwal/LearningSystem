using System;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Web;
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
                string type=(string)row["MaterialType"];
                Title=(string)row["Title"];litTitle.Text=Title;litType.Text=UiHelper.TypeLabel(type);litTypeMark.Text=UiHelper.TypeMark(type);
                MaterialHelper.Render(phViewer,row,preview);
                ((SiteMaster)Master).Breadcrumb=BreadcrumbHelper.ForMaterial(row,preview,false);
                pnlPreview.Visible=preview;btnComplete.Visible=!preview;
                int courseID=(int)row["CourseID"];
                // Owners (lecturer or admin author) return to their builder; other admins return to course oversight.
                bool owner=AccessHelper.IsOwnerOfCourse(CurrentUserHelper.GetUserID().Value,courseID);
                string back=preview ? (owner ? "~/Teacher/CourseBuilder.aspx?id="+courseID : "~/Admin/Courses.aspx") : "~/Learner/CourseHome.aspx?id="+courseID;
                lnkBack.NavigateUrl=back;lnkExit.NavigateUrl=back;
                if(!preview)
                {
                    bool done=Convert.ToInt32(DatabaseHelper.ExecuteScalar("SELECT COUNT(*) FROM dbo.MaterialCompletion WHERE LearnerID=@user AND MaterialID=@id",new[] {new SqlParameter("@user",CurrentUserHelper.GetUserID().Value),new SqlParameter("@id",materialID)}))>0;
                    litCompleted.Text=done ? "Lesson complete. Nice work!" : "Finished reading? Complete it to earn "+GamificationHelper.LessonXp+" XP and move on.";
                    btnComplete.Visible=!done;pnlFooter.CssClass=done ? "lesson-footer is-done" : "lesson-footer";
                }
                btnBookmark.Visible=!preview && CurrentUserHelper.GetRole()=="Learner";
                if(btnBookmark.Visible){bool saved=BookmarkHelper.Exists(materialID);btnBookmark.Text=saved ? "Remove bookmark" : "Add bookmark";btnBookmark.OnClientClick=saved ? "return confirm('Remove this bookmark?');" : "";if(!IsPostBack)ViewState["BookmarkAdd"]=!saved;}
                if(preview)BindPreviewNavigation(courseID);
                else BindLearnerNavigation(courseID,(string)row["CourseTitle"]);
            }
            catch(SqlException) {Response.Redirect("~/Error.aspx");}
        }

        // Learners move through every published lesson and activity in course order, with a sidebar outline.
        private void BindLearnerNavigation(int courseID,string courseTitle)
        {
            int user=CurrentUserHelper.GetUserID().Value;
            DataTable items=ProgressHelper.PublishedItems(user,courseID);
            int current=-1;
            for(int i=0;i<items.Rows.Count;i++) if((int)items.Rows[i]["ItemKind"]==0 && (int)items.Rows[i]["ItemID"]==materialID) current=i;
            if(current>0)SetPager(lnkPrevious,"Previous",items.Rows[current-1]);
            if(current>=0 && current+1<items.Rows.Count)SetPager(lnkNext,"Next",items.Rows[current+1]);
            StringBuilder html=new StringBuilder("<nav class=\"lesson-sidebar\" aria-label=\"Course outline\"><h2>"+CourseHelper.Encode(courseTitle)+"</h2>");
            int topic=0;
            for(int i=0;i<items.Rows.Count;i++)
            {
                DataRow item=items.Rows[i];
                if((int)item["TopicID"]!=topic)
                {
                    if(topic!=0)html.Append("</ul>");
                    topic=(int)item["TopicID"];
                    html.Append("<h3>").Append(CourseHelper.Encode(item["TopicTitle"])).Append("</h3><ul>");
                }
                string icon=(bool)item["Done"] ? "<span class=\"ok\">"+UiHelper.Icon("check-circle")+"</span>" : UiHelper.Icon(UiHelper.TypeIcon((string)item["ItemType"]));
                html.Append("<li><a href=\"").Append(ResolveUrl(CourseHelper.ItemLink(item,true))).Append("\"").Append(i==current ? " aria-current=\"page\"" : "").Append(">")
                    .Append(icon).Append("<span>").Append(CourseHelper.Encode(item["Title"])).Append((bool)item["Done"] ? "<span class=\"visually-hidden\"> (completed)</span>" : "").Append("</span></a></li>");
            }
            if(topic!=0)html.Append("</ul>");
            phSidebar.Controls.Add(new LiteralControl(html.Append("</nav>").ToString()));
        }
        private void SetPager(System.Web.UI.WebControls.HyperLink link,string direction,DataRow item)
        {
            link.Visible=true;link.NavigateUrl=CourseHelper.ItemLink(item,true);
            link.Text="<small>"+direction+": "+HttpUtility.HtmlEncode(CourseHelper.ItemLabel(item))+"</small><span>"+HttpUtility.HtmlEncode(Convert.ToString(item["Title"]))+"</span>";
        }

        // Preview shows every material, including drafts, in order.
        private void BindPreviewNavigation(int courseID)
        {
            DataTable materials=DatabaseHelper.ExecuteTable("SELECT m.MaterialID,m.Title FROM dbo.Material m JOIN dbo.Topic t ON t.TopicID=m.TopicID WHERE t.CourseID=@course ORDER BY t.SortOrder,t.TopicID,m.SortOrder,m.MaterialID",new[] {new SqlParameter("@course",courseID)});
            for(int i=0;i<materials.Rows.Count;i++)
            {
                if((int)materials.Rows[i]["MaterialID"]!=materialID)continue;
                if(i>0){lnkPrevious.Visible=true;lnkPrevious.NavigateUrl="Lesson.aspx?id="+materials.Rows[i-1]["MaterialID"]+"&preview=1";lnkPrevious.Text="<small>Previous lesson</small><span>"+HttpUtility.HtmlEncode(Convert.ToString(materials.Rows[i-1]["Title"]))+"</span>";}
                if(i+1<materials.Rows.Count){lnkNext.Visible=true;lnkNext.NavigateUrl="Lesson.aspx?id="+materials.Rows[i+1]["MaterialID"]+"&preview=1";lnkNext.Text="<small>Next lesson</small><span>"+HttpUtility.HtmlEncode(Convert.ToString(materials.Rows[i+1]["Title"]))+"</span>";}
                break;
            }
        }
        // After completing a lesson the learner goes straight to the next item in the course,
        // or back to the course path when this was the last one.
        private string NextAfterThis()
        {
            int courseID=Convert.ToInt32(DatabaseHelper.ExecuteScalar("SELECT t.CourseID FROM dbo.Material m JOIN dbo.Topic t ON t.TopicID=m.TopicID WHERE m.MaterialID=@id",new[] {new SqlParameter("@id",materialID)}));
            DataTable items=ProgressHelper.PublishedItems(CurrentUserHelper.GetUserID().Value,courseID);
            for(int i=0;i<items.Rows.Count-1;i++)
                if((int)items.Rows[i]["ItemKind"]==0 && (int)items.Rows[i]["ItemID"]==materialID) return CourseHelper.ItemLink(items.Rows[i+1],true);
            return "~/Learner/CourseHome.aspx?id="+courseID;
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
                MessageHelper.SetSuccess("Lesson complete! +"+GamificationHelper.LessonXp+" XP.");
                Response.Redirect(NextAfterThis());
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
        }
    }
}
