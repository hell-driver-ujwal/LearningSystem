using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using LearningSystem.Helpers;
namespace LearningSystem.Teacher
{
    public partial class CourseBuilder : Page
    {
        private int courseID;
        private int EditingTopic { get { return (int)(ViewState["EditingTopic"] ?? 0); } set { ViewState["EditingTopic"] = value; } }
        protected void Page_Load(object sender, EventArgs e)
        {
            AccessHelper.RequireRole(CurrentUserHelper.AuthorRoles);
            txtTitle.Text = txtTitle.Text.Trim(); txtOrder.Text = txtOrder.Text.Trim();
            try
            {
                if (!Int32.TryParse(Request.QueryString["id"], out courseID) || courseID < 1 || !AccessHelper.IsOwnerOfCourse(CurrentUserHelper.GetUserID().Value, courseID))
                { Response.Redirect("~/AccessDenied.aspx"); return; }
                ((SiteMaster)Master).Breadcrumb = BreadcrumbHelper.ForCourse(courseID);
                lnkDetails.NavigateUrl = "CourseEdit.aspx?id=" + courseID;
                lnkLearners.NavigateUrl="CourseLearners.aspx?id="+courseID;lnkResults.NavigateUrl="Results.aspx?courseId="+courseID;
                if (!IsPostBack)
                {
                    ViewState["SaveToken"] = CurrentUserHelper.CreateEditToken();
                    DataRow course = DatabaseHelper.ExecuteTable("SELECT Title,Status FROM dbo.Course WHERE CourseID=@id", IdParameters(courseID)).Rows[0];
                    litCourse.Text = (string)course["Title"]; Title = "Course builder: " + course["Title"];
                    txtOrder.Text = Convert.ToString(DatabaseHelper.ExecuteScalar("SELECT ISNULL(MAX(SortOrder),0)+1 FROM dbo.Topic WHERE CourseID=@id", IdParameters(courseID)));
                    DataTable topics = DatabaseHelper.ExecuteTable("SELECT TopicID,Title,SortOrder FROM dbo.Topic WHERE CourseID=@id ORDER BY SortOrder,TopicID", IdParameters(courseID));
                    lblEmpty.Visible = topics.Rows.Count == 0; rptTopics.DataSource = topics; rptTopics.DataBind();
                }
            }
            catch (SqlException) { Response.Redirect("~/Error.aspx"); }
        }
        private static SqlParameter[] IdParameters(int id) { return new[] { new SqlParameter("@id", id) }; }
        protected void BindTopic(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType != ListItemType.Item && e.Item.ItemType != ListItemType.AlternatingItem) return;
            int id = (int)((DataRowView)e.Item.DataItem)["TopicID"];
            GridView materials = (GridView)e.Item.FindControl("gvMaterials");
            materials.DataSource = DatabaseHelper.ExecuteTable("SELECT MaterialID,Title,MaterialType,Status,IsPreview,SortOrder FROM dbo.Material WHERE TopicID=@id ORDER BY SortOrder,MaterialID", IdParameters(id)); materials.DataBind();
            GridView activities = (GridView)e.Item.FindControl("gvActivities");
            activities.DataSource = DatabaseHelper.ExecuteTable("SELECT ActivityID,Title,ActivityType,Status,SortOrder FROM dbo.Activity WHERE TopicID=@id ORDER BY SortOrder,ActivityID", IdParameters(id)); activities.DataBind();
        }
        protected void SaveTopic(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;
            if (!CurrentUserHelper.CanSaveEdit(ViewState["SaveToken"])) { MessageHelper.SetError("This form was already saved or expired. Reload the page before saving again."); return; }
            int order;
            if (!Int32.TryParse(txtOrder.Text, out order) || order < 1 || order > 100) return;
            try
            {
                using (SqlConnection connection = DatabaseHelper.OpenConnection())
                using (SqlTransaction transaction = connection.BeginTransaction(IsolationLevel.Serializable))
                {
                    AccessHelper.RequireOwner(connection, transaction, courseID, "Course");
                    if (EditingTopic > 0)
                    {
                        AccessHelper.RequireOwner(connection, transaction, EditingTopic, "Topic");
                        if (Convert.ToInt32(DatabaseHelper.ExecuteScalar(connection, transaction, "SELECT CourseID FROM dbo.Topic WHERE TopicID=@id", IdParameters(EditingTopic))) != courseID)
                        { Response.Redirect("~/AccessDenied.aspx"); return; }
                    }
                    DatabaseHelper.ExecuteNonQuery(connection, transaction, EditingTopic == 0
                        ? "INSERT INTO dbo.Topic (CourseID,Title,SortOrder) VALUES (@course,@title,@order)"
                        : "UPDATE dbo.Topic SET Title=@title,SortOrder=@order WHERE TopicID=@id AND CourseID=@course",
                        new[] { new SqlParameter("@course", courseID), new SqlParameter("@id", EditingTopic), new SqlParameter("@title", SqlDbType.NVarChar,100) { Value=txtTitle.Text }, new SqlParameter("@order", order) });
                    AccessHelper.TouchCourse(connection, transaction, courseID); transaction.Commit();
                    CurrentUserHelper.CompleteEdit(ViewState["SaveToken"]);
                }
                MessageHelper.SetSuccess("Topic saved."); Response.Redirect("CourseBuilder.aspx?id=" + courseID);
            }
            catch (SqlException) { MessageHelper.SetError("The topic could not be saved. Please try again."); }
        }
        protected void TopicCommand(object sender, RepeaterCommandEventArgs e)
        {
            if (!Page.IsValid) return;
            int id;
            if (!Int32.TryParse(Convert.ToString(e.CommandArgument), out id)) { Response.Redirect("~/AccessDenied.aspx"); return; }
            try
            {
                DataTable rows = DatabaseHelper.ExecuteTable("SELECT Title,SortOrder FROM dbo.Topic WHERE TopicID=@id AND CourseID=@course", new[] { new SqlParameter("@id", id), new SqlParameter("@course", courseID) });
                if (rows.Rows.Count != 1 || !AccessHelper.IsOwnerOfTopic(CurrentUserHelper.GetUserID().Value, id)) { Response.Redirect("~/AccessDenied.aspx"); return; }
                if (e.CommandName == "EditTopic")
                {
                    EditingTopic = id; txtTitle.Text = (string)rows.Rows[0]["Title"]; txtOrder.Text = rows.Rows[0]["SortOrder"].ToString(); btnSave.Text = "Save topic";
                }
                else if (e.CommandName == "DeleteTopic")
                {
                    ValidationResult result = DeleteHelper.DeleteTopic(id);
                    if (!result.IsValid) { MessageHelper.SetError(result.Message); return; }
                    MessageHelper.SetSuccess(result.Message); Response.Redirect("CourseBuilder.aspx?id=" + courseID);
                }
            }
            catch (SqlException) { MessageHelper.SetError("The topic could not be changed. Please refresh and try again."); }
        }
        protected void MaterialCommand(object sender, GridViewCommandEventArgs e)
        {
            if (!Page.IsValid) return;
            if (e.CommandName != "DeleteMaterial") return;
            int id;
            if (!Int32.TryParse(Convert.ToString(e.CommandArgument), out id)) { Response.Redirect("~/AccessDenied.aspx"); return; }
            try
            {
                int parent = Convert.ToInt32(DatabaseHelper.ExecuteScalar("SELECT t.CourseID FROM dbo.Material m JOIN dbo.Topic t ON t.TopicID=m.TopicID WHERE m.MaterialID=@id", IdParameters(id)));
                if (parent != courseID || !AccessHelper.IsOwnerOfMaterial(CurrentUserHelper.GetUserID().Value, id)) { Response.Redirect("~/AccessDenied.aspx"); return; }
                ValidationResult result = DeleteHelper.DeleteMaterial(id);
                MessageHelper.SetSuccess(result.Message); Response.Redirect("CourseBuilder.aspx?id=" + courseID);
            }
            catch (SqlException) { MessageHelper.SetError("The material could not be deleted. Please try again."); }
            catch (ArgumentException) { MessageHelper.SetError("The stored upload path is invalid. Ask the administrator to check it."); }
        }
        protected void Cancel(object sender, EventArgs e) { Response.Redirect("CourseBuilder.aspx?id=" + courseID); }
    }
}



