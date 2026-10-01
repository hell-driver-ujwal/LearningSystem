using System;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using LearningSystem.Helpers;
namespace LearningSystem.Teacher
{
    public partial class MaterialEdit : Page
    {
        private int materialID, topicID, courseID;
        private DataRow existing;
        protected void Page_Load(object sender, EventArgs e)
        {
            AccessHelper.RequireRole(CurrentUserHelper.AuthorRoles);
            txtTitle.Text = txtTitle.Text.Trim(); txtText.Text = txtText.Text.Trim();
            txtAlt.Text = txtAlt.Text.Trim(); txtYouTube.Text = txtYouTube.Text.Trim(); txtOrder.Text = txtOrder.Text.Trim();
            try
            {
                bool edit = Request.QueryString["id"] != null;
                if (edit == (Request.QueryString["topicId"] != null)) { Response.Redirect("~/AccessDenied.aspx"); return; }
                if (edit)
                {
                    if (!Int32.TryParse(Request.QueryString["id"], out materialID) || materialID < 1 || !AccessHelper.IsOwnerOfMaterial(CurrentUserHelper.GetUserID().Value, materialID))
                    { Response.Redirect("~/AccessDenied.aspx"); return; }
                    existing = DatabaseHelper.ExecuteTable("SELECT * FROM dbo.Material WHERE MaterialID=@id", IdParameters(materialID)).Rows[0];
                    topicID = (int)existing["TopicID"];
                }
                else if (!Int32.TryParse(Request.QueryString["topicId"], out topicID) || topicID < 1 || !AccessHelper.IsOwnerOfTopic(CurrentUserHelper.GetUserID().Value, topicID))
                { Response.Redirect("~/AccessDenied.aspx"); return; }
                DataRow topic = DatabaseHelper.ExecuteTable("SELECT CourseID,Title FROM dbo.Topic WHERE TopicID=@id", IdParameters(topicID)).Rows[0];
                courseID = (int)topic["CourseID"]; litTopic.Text = "Topic: " + topic["Title"];
                if (edit) ((SiteMaster)Master).Breadcrumb = BreadcrumbHelper.ForMaterial(materialID);
                else
                {
                    var trail = new System.Collections.Generic.List<BreadcrumbItem>(BreadcrumbHelper.ForCourse(courseID));
                    trail.Add(new BreadcrumbItem { Text = (string)topic["Title"], Url = "~/Teacher/CourseBuilder.aspx?id=" + courseID });
                    trail.Add(new BreadcrumbItem { Text = "Add material" });
                    ((SiteMaster)Master).Breadcrumb = trail.ToArray();
                }
                if (!IsPostBack)
                {
                    ViewState["SaveToken"] = CurrentUserHelper.CreateEditToken();
                    if (edit)
                    {
                        txtTitle.Text = (string)existing["Title"]; ddlType.SelectedValue = (string)existing["MaterialType"];
                        txtText.Text = Convert.ToString(existing["TextContent"]); txtAlt.Text = Convert.ToString(existing["AltText"]);
                        txtYouTube.Text = Convert.ToString(existing["YouTubeURL"]); txtOrder.Text = existing["SortOrder"].ToString();
                        ddlStatus.SelectedValue = (string)existing["Status"]; chkPreview.Checked = (bool)existing["IsPreview"];
                    }
                    else txtOrder.Text = Convert.ToString(DatabaseHelper.ExecuteScalar("SELECT ISNULL(MAX(CONVERT(bigint,SortOrder)),0)+1 FROM dbo.Material WHERE TopicID=@id", IdParameters(topicID)));
                }
                litFile.Text = existing != null && !existing.IsNull("FilePath") ? "A file is stored. Leave upload empty to keep it when the type is unchanged." : "No file stored.";
                ShowTypeFields();
            }
            catch (SqlException) { Response.Redirect("~/Error.aspx"); }
        }
        private static SqlParameter[] IdParameters(int id) { return new[] { new SqlParameter("@id", id) }; }
        private void ShowTypeFields()
        {
            pnlText.Visible = ddlType.SelectedValue == "Text" || ddlType.SelectedValue == "Code";
            lblText.Text = ddlType.SelectedValue == "Code" ? "Starter code for the code lab (HTML with optional CSS and JavaScript, 20 to 10,000 characters)" : "Lesson text (20 to 10,000 characters)";
            pnlAlt.Visible = ddlType.SelectedValue == "Image";
            pnlFile.Visible = IsFileType(ddlType.SelectedValue);
            pnlYouTube.Visible = ddlType.SelectedValue == "YouTube";
        }
        private static bool IsFileType(string type) { return type == "Image" || type == "PDF" || type == "Video" || type == "Audio"; }
        private bool HasUpload() { return fuFile.PostedFile != null && !String.IsNullOrEmpty(fuFile.PostedFile.FileName); }
        protected void ValidateMaterial(object source, ServerValidateEventArgs args)
        {
            string type = ddlType.SelectedValue;
            string error = "";
            if (!IsFileType(type) && type != "Text" && type != "Code" && type != "YouTube") error = "Choose a material type.";
            else if ((type == "Text" || type == "Code") && (txtText.Text.Length < 20 || txtText.Text.Length > 10000)) error = "Lesson text or starter code must be 20 to 10,000 characters.";
            else if (type == "Image" && (txtAlt.Text.Length < 5 || txtAlt.Text.Length > 150)) error = "Image alt text must be 5 to 150 characters.";
            else if (type == "YouTube" && !ValidYouTube(txtYouTube.Text)) error = "Enter a valid youtube.com/watch?v= video URL or youtu.be video URL.";
            if (error == "" && IsFileType(type))
            {
                if (HasUpload())
                {
                    ValidationResult check = UploadHelper.Validate(fuFile.PostedFile, type, false);
                    if (!check.IsValid) error = check.Message;
                }
                else if (existing == null || existing.IsNull("FilePath") || (string)existing["MaterialType"] != type)
                    error = "Upload a file for the selected type.";
            }
            if (ddlStatus.SelectedValue != "Draft" && ddlStatus.SelectedValue != "Published") error = "Choose Draft or Published.";
            args.IsValid = error == ""; cvMaterial.ErrorMessage = error;
        }
        private static bool ValidYouTube(string value)
        {
            Uri uri;
            if (value.Length > 500 || !Uri.TryCreate(value, UriKind.Absolute, out uri) || (uri.Scheme != "https" && uri.Scheme != "http") || uri.UserInfo != "" || !uri.IsDefaultPort) return false;
            string video = null;
            if ((uri.Host == "youtube.com" || uri.Host == "www.youtube.com") && uri.AbsolutePath == "/watch") video = HttpUtility.ParseQueryString(uri.Query)["v"];
            else if (uri.Host == "youtu.be" || uri.Host == "www.youtu.be") video = uri.AbsolutePath.TrimStart('/');
            return video != null && System.Text.RegularExpressions.Regex.IsMatch(video, "^[A-Za-z0-9_-]{11}$");
        }
        protected void SaveMaterial(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;
            if (!CurrentUserHelper.CanSaveEdit(ViewState["SaveToken"])) { MessageHelper.SetError("This form was already saved or expired. Reload the page before saving again."); return; }
            int order;
            if (!Int32.TryParse(txtOrder.Text, out order) || order < 1) return;
            string type = ddlType.SelectedValue, newPath = null, oldPath = null, savedPath = null;
            bool committed = false;
            try
            {
                if (IsFileType(type) && HasUpload()) newPath = UploadHelper.Save(fuFile.PostedFile, type, false);
                using (SqlConnection connection = DatabaseHelper.OpenConnection())
                using (SqlTransaction transaction = connection.BeginTransaction(IsolationLevel.Serializable))
                {
                    AccessHelper.RequireOwner(connection, transaction, topicID, "Topic");
                    if (materialID > 0)
                    {
                        AccessHelper.RequireOwner(connection, transaction, materialID, "Material");
                        DataRow current = DatabaseHelper.ExecuteTable(connection, transaction, "SELECT TopicID,FilePath,MaterialType FROM dbo.Material WHERE MaterialID=@id", IdParameters(materialID)).Rows[0];
                        if ((int)current["TopicID"] != topicID) { Response.Redirect("~/AccessDenied.aspx"); return; }
                        oldPath = Convert.ToString(current["FilePath"]);
                        if (!String.IsNullOrEmpty(oldPath)) UploadHelper.GetValidatedPath(oldPath);
                        if (IsFileType(type) && newPath == null && (string)current["MaterialType"] != type)
                        { MessageHelper.SetError("The stored type changed. Refresh and upload a file for this type."); return; }
                    }
                    savedPath = IsFileType(type) ? newPath ?? oldPath : null;
                    SqlParameter[] parameters = {
                        new SqlParameter("@id", materialID), new SqlParameter("@topic", topicID), new SqlParameter("@title", SqlDbType.NVarChar,100) { Value=txtTitle.Text },
                        new SqlParameter("@type", type), new SqlParameter("@status", ddlStatus.SelectedValue), new SqlParameter("@order", order), new SqlParameter("@preview", chkPreview.Checked),
                        new SqlParameter("@text", SqlDbType.NVarChar,-1) { Value=type == "Text" || type == "Code" ? (object)txtText.Text : DBNull.Value },
                        new SqlParameter("@path", SqlDbType.NVarChar,500) { Value=String.IsNullOrEmpty(savedPath) ? (object)DBNull.Value : savedPath },
                        new SqlParameter("@url", SqlDbType.NVarChar,500) { Value=type == "YouTube" ? (object)txtYouTube.Text : DBNull.Value },
                        new SqlParameter("@alt", SqlDbType.NVarChar,150) { Value=type == "Image" ? (object)txtAlt.Text : DBNull.Value }
                    };
                    DatabaseHelper.ExecuteNonQuery(connection, transaction, materialID == 0
                        ? "INSERT INTO dbo.Material (TopicID,Title,MaterialType,Status,SortOrder,IsPreview,TextContent,FilePath,YouTubeURL,AltText) VALUES (@topic,@title,@type,@status,@order,@preview,@text,@path,@url,@alt)"
                        : "UPDATE dbo.Material SET Title=@title,MaterialType=@type,Status=@status,SortOrder=@order,IsPreview=@preview,TextContent=@text,FilePath=@path,YouTubeURL=@url,AltText=@alt WHERE MaterialID=@id AND TopicID=@topic", parameters);
                    AccessHelper.TouchCourse(connection, transaction, courseID);
                    transaction.Commit(); committed = true;
                    CurrentUserHelper.CompleteEdit(ViewState["SaveToken"]);
                }
            }
            catch (SqlException) { MessageHelper.SetError("The material could not be saved. Please refresh and try again."); return; }
            catch (IOException) { MessageHelper.SetError("The file could not be saved. Please try again."); return; }
            catch (UnauthorizedAccessException) { MessageHelper.SetError("The upload folder is not writable. Contact the administrator."); return; }
            catch (ArgumentException) { MessageHelper.SetError("The file or stored path is invalid."); return; }
            finally
            {
                if (!committed && newPath != null)
                {
                    string warning = UploadHelper.Cleanup(newPath);
                    if (warning != "") MessageHelper.SetError("Material not saved. " + warning);
                }
            }
            string cleanup = oldPath != savedPath ? UploadHelper.Cleanup(oldPath) : "";
            MessageHelper.SetSuccess("Material saved. " + cleanup);
            Response.Redirect("CourseBuilder.aspx?id=" + courseID);
        }
        protected void Cancel(object sender, EventArgs e) { Response.Redirect("CourseBuilder.aspx?id=" + courseID); }
    }
}

