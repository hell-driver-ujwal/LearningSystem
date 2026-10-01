using System;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Web.UI;
using System.Web.UI.WebControls;
using LearningSystem.Helpers;
namespace LearningSystem.Teacher
{
    public partial class CourseEdit : Page
    {
        private int courseID;
        protected void Page_Load(object sender, EventArgs e)
        {
            AccessHelper.RequireRole(CurrentUserHelper.AuthorRoles);
            txtTitle.Text = txtTitle.Text.Trim();
            txtDescription.Text = txtDescription.Text.Trim();
            try
            {
                if (Request.QueryString["id"] != null && (!Int32.TryParse(Request.QueryString["id"], out courseID) || courseID < 1 || !AccessHelper.IsOwnerOfCourse(CurrentUserHelper.GetUserID().Value, courseID)))
                { Response.Redirect("~/AccessDenied.aspx"); return; }
                if (courseID > 0)
                {
                    var trail = new System.Collections.Generic.List<BreadcrumbItem>(BreadcrumbHelper.ForCourse(courseID));
                    trail.Add(new BreadcrumbItem { Text = "Course details" });
                    ((SiteMaster)Master).Breadcrumb = trail.ToArray();
                }
                if (IsPostBack) return;
                ViewState["SaveToken"] = CurrentUserHelper.CreateEditToken();
                ddlSubject.DataSource = DatabaseHelper.ExecuteTable("SELECT SubjectID,SubjectName FROM dbo.Subject ORDER BY SubjectName", null);
                ddlSubject.DataTextField = "SubjectName"; ddlSubject.DataValueField = "SubjectID"; ddlSubject.DataBind();
                ddlSubject.Items.Insert(0, new ListItem("Choose a subject", ""));
                if (courseID == 0) return;
                DataRow row = DatabaseHelper.ExecuteTable("SELECT Title,Description,SubjectID,CoverImagePath,IsPaid,PriceNPR FROM dbo.Course WHERE CourseID=@id", new[] { new SqlParameter("@id", courseID) }).Rows[0];
                ddlPricing.SelectedValue = (bool)row["IsPaid"] ? "Paid" : "Free"; txtPrice.Text = ((decimal)row["PriceNPR"]).ToString("0.00", System.Globalization.CultureInfo.InvariantCulture);
                txtTitle.Text = (string)row["Title"]; txtDescription.Text = (string)row["Description"];
                ddlSubject.SelectedValue = row["SubjectID"].ToString();
                litCover.Text = row.IsNull("CoverImagePath") ? "No cover uploaded." : "A cover is already uploaded.";
            }
            catch (SqlException) { Response.Redirect("~/Error.aspx"); }
        }
        protected override void OnPreRender(EventArgs e) { txtPrice.Enabled=ddlPricing.SelectedValue=="Paid"; base.OnPreRender(e); }
        protected void ValidatePrice(object source, ServerValidateEventArgs args)
        {
            decimal price;
            args.IsValid = ddlPricing.SelectedValue=="Free" || (ddlPricing.SelectedValue=="Paid" &&
                Decimal.TryParse(txtPrice.Text,System.Globalization.NumberStyles.AllowDecimalPoint,System.Globalization.CultureInfo.InvariantCulture,out price)
                && price>0 && price<=99999999.99m && Decimal.Round(price,2)==price);
        }
        protected void ValidateCourse(object source, ServerValidateEventArgs args)
        {
            args.IsValid = true;
            if (fuCover.PostedFile != null && !String.IsNullOrEmpty(fuCover.PostedFile.FileName))
            {
                ValidationResult check = UploadHelper.Validate(fuCover.PostedFile, "Image", true);
                args.IsValid = check.IsValid; cvCourse.ErrorMessage = check.Message;
            }
        }
        protected void SaveCourse(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;
            if (!CurrentUserHelper.CanSaveEdit(ViewState["SaveToken"])) { MessageHelper.SetError("This form was already saved or expired. Reload the page before saving again."); return; }
            decimal price = ddlPricing.SelectedValue=="Paid" ? Decimal.Parse(txtPrice.Text,System.Globalization.CultureInfo.InvariantCulture) : 0m;
            int subject;
            if (!Int32.TryParse(ddlSubject.SelectedValue, out subject)) return;
            string newPath = null, oldPath = null;
            bool committed = false;
            try
            {
                if (fuCover.HasFile) newPath = UploadHelper.Save(fuCover.PostedFile, "Image", true);
                using (SqlConnection connection = DatabaseHelper.OpenConnection())
                using (SqlTransaction transaction = connection.BeginTransaction(IsolationLevel.Serializable))
                {
                    if (Convert.ToInt32(DatabaseHelper.ExecuteScalar(connection, transaction,
                        "SELECT COUNT(*) FROM dbo.[User] WHERE UserID=@id AND Role IN ('Teacher','Admin') AND Status='Active'", new[] { new SqlParameter("@id", CurrentUserHelper.GetUserID().Value) })) != 1)
                    { Response.Redirect("~/AccessDenied.aspx"); return; }
                    if (courseID > 0)
                    {
                        AccessHelper.RequireOwner(connection, transaction, courseID, "Course");
                        oldPath = Convert.ToString(DatabaseHelper.ExecuteScalar(connection, transaction, "SELECT CoverImagePath FROM dbo.Course WHERE CourseID=@id", new[] { new SqlParameter("@id", courseID) }));
                        if (!String.IsNullOrEmpty(oldPath)) UploadHelper.GetValidatedPath(oldPath);
                    }
                    if (Convert.ToInt32(DatabaseHelper.ExecuteScalar(connection, transaction, "SELECT COUNT(*) FROM dbo.Subject WHERE SubjectID=@subject", new[] { new SqlParameter("@subject", subject) })) != 1)
                    { MessageHelper.SetError("Choose an existing subject."); return; }
                    string path = newPath ?? oldPath;
                    SqlParameter[] parameters = {
                        new SqlParameter("@paid", ddlPricing.SelectedValue=="Paid"), new SqlParameter("@price", SqlDbType.Decimal) { Precision=10, Scale=2, Value=price },
                        new SqlParameter("@id", courseID), new SqlParameter("@teacher", CurrentUserHelper.GetUserID().Value),
                        new SqlParameter("@subject", subject), new SqlParameter("@title", SqlDbType.NVarChar,100) { Value=txtTitle.Text },
                        new SqlParameter("@description", SqlDbType.NVarChar,1000) { Value=txtDescription.Text },
                        new SqlParameter("@path", SqlDbType.NVarChar,500) { Value=String.IsNullOrEmpty(path) ? (object)DBNull.Value : path }
                    };
                    if (courseID == 0)
                        courseID = Convert.ToInt32(DatabaseHelper.ExecuteScalar(connection, transaction,
                            "INSERT INTO dbo.Course (TeacherID,SubjectID,Title,Description,CoverImagePath,Status,IsPaid,PriceNPR) OUTPUT INSERTED.CourseID VALUES (@teacher,@subject,@title,@description,@path,'Draft',@paid,@price)", parameters));
                    else
                        DatabaseHelper.ExecuteNonQuery(connection, transaction, "UPDATE dbo.Course SET IsPaid=@paid,PriceNPR=@price,SubjectID=@subject,Title=@title,Description=@description,CoverImagePath=@path,LastUpdated=SYSUTCDATETIME() WHERE CourseID=@id AND TeacherID=@teacher", parameters);
                    transaction.Commit(); committed = true;
                    CurrentUserHelper.CompleteEdit(ViewState["SaveToken"]);
                }
            }
            catch (SqlException) { MessageHelper.SetError("The course could not be saved. Please try again."); return; }
            catch (IOException) { MessageHelper.SetError("The cover could not be saved. Please try again."); return; }
            catch (UnauthorizedAccessException) { MessageHelper.SetError("The upload folder is not writable. Contact the administrator."); return; }
            catch (ArgumentException) { MessageHelper.SetError("The cover file or stored path is invalid."); return; }
            finally
            {
                if (!committed && newPath != null)
                {
                    string warning = UploadHelper.Cleanup(newPath);
                    if (warning != "") MessageHelper.SetError("Course not saved. " + warning);
                }
            }
            string cleanup = newPath == null ? "" : UploadHelper.Cleanup(oldPath);
            MessageHelper.SetSuccess("Course saved. " + cleanup);
            Response.Redirect("CourseBuilder.aspx?id=" + courseID);
        }
        protected void Cancel(object sender, EventArgs e) { Response.Redirect(courseID == 0 ? "MyCourses.aspx" : "CourseBuilder.aspx?id=" + courseID); }
    }
}
