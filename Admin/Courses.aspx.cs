using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using LearningSystem.Helpers;

namespace LearningSystem.Admin
{
    public partial class Courses : Page
    {

        protected void Page_Load(object sender, EventArgs e)
        {
            AccessHelper.RequireRole(new[] { "Admin" });
            if (!IsPostBack) BindContent();
        }
        private void BindContent()
        {
            try
            {
                gvCourses.DataSource = DatabaseHelper.ExecuteTable("SELECT c.CourseID,c.Title,c.Status,s.SubjectName,u.FullName AS TeacherName,(SELECT COUNT(*) FROM dbo.Attempt r JOIN dbo.Activity a ON a.ActivityID=r.ActivityID JOIN dbo.Topic t ON t.TopicID=a.TopicID WHERE t.CourseID=c.CourseID) AS AttemptCount FROM dbo.Course c JOIN dbo.Subject s ON s.SubjectID=c.SubjectID JOIN dbo.[User] u ON u.UserID=c.TeacherID ORDER BY c.Title,c.CourseID", null);
                gvCourses.DataBind();
                gvReviews.DataSource=ReviewHelper.List(0);gvReviews.DataBind();
            }
            catch (SqlException) { MessageHelper.SetError("Content could not be loaded."); }
        }
        protected string PreviewLinks(object courseID)
        {
            DataTable materials = DatabaseHelper.ExecuteTable("SELECT m.MaterialID,m.Title,m.Status FROM dbo.Material m JOIN dbo.Topic t ON t.TopicID=m.TopicID WHERE t.CourseID=@id ORDER BY t.SortOrder,t.TopicID,m.SortOrder,m.MaterialID",
                new[] { new SqlParameter("@id", Convert.ToInt32(courseID)) });
            if (materials.Rows.Count == 0) return "<p>No materials in this course.</p>";
            System.Text.StringBuilder html = new System.Text.StringBuilder("<ul>");
            foreach (DataRow row in materials.Rows)
                html.Append("<li><a href=\"").Append(ResolveUrl("~/Member/Lesson.aspx?id=" + row["MaterialID"] + "&preview=1").Replace("&", "&amp;"))
                    .Append("\">").Append(System.Web.HttpUtility.HtmlEncode((string)row["Title"])).Append("</a>: ")
                    .Append(System.Web.HttpUtility.HtmlEncode((string)row["Status"])).Append("</li>");
            return html.Append("</ul>").ToString();
        }
        protected void Content_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName != "Unpublish" && e.CommandName != "DeleteContent") return;
            if (!Page.IsValid) return;
            int id;
            if (!Int32.TryParse(Convert.ToString(e.CommandArgument), out id) || id < 1) return;
            try
            {
                if (e.CommandName == "DeleteContent")
                {
                    ValidationResult result = DeleteHelper.DeleteCourse(id);
                    if (!result.IsValid) { MessageHelper.SetError(result.Message); return; }
                    MessageHelper.SetSuccess(result.Message);
                }
                else
                {
                    int changed = DatabaseHelper.ExecuteNonQuery("UPDATE dbo.Course SET Status='Draft',LastUpdated=SYSUTCDATETIME() WHERE CourseID=@id AND Status='Published'", new[] { new SqlParameter("@id", id) });
                    if (changed == 0) { MessageHelper.SetError("This content is already unpublished or no longer exists."); return; }
                    MessageHelper.SetSuccess("Content unpublished. Existing attempts are retained.");
                }
            }
            catch (SqlException) { MessageHelper.SetError("Content could not be changed. No partial database deletion was saved."); return; }
            catch (System.IO.IOException) { MessageHelper.SetError("Upload paths could not be checked. Please try again."); return; }
            catch (UnauthorizedAccessException) { MessageHelper.SetError("Upload paths could not be checked. Please contact the administrator."); return; }
            Response.Redirect("~/Admin/Courses.aspx");
        }
        protected void ReviewCommand(object sender,GridViewCommandEventArgs e)
        {
            if(!Page.IsValid)return;if(e.CommandName!="RemoveReview")return;
            int id;if(!Int32.TryParse(Convert.ToString(e.CommandArgument),out id)||id<1){Response.Redirect("~/AccessDenied.aspx");return;}
            try{ReviewHelper.Delete(id,0,true);MessageHelper.SetSuccess("Review removed.");Response.Redirect("Courses.aspx");}
            catch(UnauthorizedAccessException){Response.Redirect("~/AccessDenied.aspx");}
            catch(SqlException){MessageHelper.SetError("Review could not be removed.");}
        }    }
}

