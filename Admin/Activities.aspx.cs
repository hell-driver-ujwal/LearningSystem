using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using LearningSystem.Helpers;

namespace LearningSystem.Admin
{
    public partial class Activities : Page
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
                gvActivities.DataSource = DatabaseHelper.ExecuteTable("SELECT a.ActivityID,a.Title,a.ActivityType,a.Status,c.Title AS CourseTitle,(SELECT COUNT(*) FROM dbo.Attempt r WHERE r.ActivityID=a.ActivityID) AS AttemptCount FROM dbo.Activity a JOIN dbo.Topic t ON t.TopicID=a.TopicID JOIN dbo.Course c ON c.CourseID=t.CourseID WHERE (@type='' OR a.ActivityType=@type) ORDER BY a.Title,a.ActivityID", new[] { new SqlParameter("@type", SqlDbType.NVarChar, 14) { Value = ddlType.SelectedValue } });
                gvActivities.DataBind();
            }
            catch (SqlException) { MessageHelper.SetError("Content could not be loaded."); }
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
                    ValidationResult result = DeleteHelper.DeleteActivity(id);
                    if (!result.IsValid) { MessageHelper.SetError(result.Message); return; }
                    MessageHelper.SetSuccess(result.Message);
                }
                else
                {
                    int changed;
                    using (SqlConnection connection = DatabaseHelper.OpenConnection())
                    using (SqlTransaction transaction = connection.BeginTransaction(IsolationLevel.Serializable))
                    {
                        int activeAdmin = Convert.ToInt32(DatabaseHelper.ExecuteScalar(connection, transaction, "SELECT COUNT(*) FROM dbo.[User] WHERE UserID=@id AND Role='Admin' AND Status='Active'", ActivityHelper.ID(CurrentUserHelper.GetUserID().GetValueOrDefault())));
                        if (activeAdmin != 1) { Response.Redirect("~/AccessDenied.aspx"); return; }
                        DataRow activity = ActivityHelper.Find(id, connection, transaction);
                        changed = DatabaseHelper.ExecuteNonQuery(connection, transaction, "UPDATE dbo.Activity SET Status='Draft' WHERE ActivityID=@id AND Status='Published'", ActivityHelper.ID(id));
                        if (changed > 0 && activity != null) AccessHelper.TouchCourse(connection, transaction, (int)activity["CourseID"]);
                        transaction.Commit();
                    }
                    if (changed == 0) { MessageHelper.SetError("This content is already unpublished or no longer exists."); return; }
                    MessageHelper.SetSuccess("Content unpublished. Existing attempts are retained.");
                }
            }
            catch (SqlException) { MessageHelper.SetError("Content could not be changed. No partial database deletion was saved."); return; }
            catch (System.IO.IOException) { MessageHelper.SetError("Upload paths could not be checked. Please try again."); return; }
            catch (UnauthorizedAccessException) { MessageHelper.SetError("Upload paths could not be checked. Please contact the administrator."); return; }
            Response.Redirect("~/Admin/Activities.aspx");
        }
        protected void btnFilter_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;
            gvActivities.PageIndex = 0;
            BindContent();
        }
        protected void Activities_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvActivities.PageIndex = e.NewPageIndex;
            BindContent();
        }
        protected void btnCancel_Click(object sender, EventArgs e) { Response.Redirect("~/Admin/Activities.aspx"); }
    }
}


