using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using LearningSystem.Helpers;
namespace LearningSystem.Teacher
{
    public partial class MyCourses : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            AccessHelper.RequireRole(new[] { "Teacher" });
            if (!IsPostBack)
            {
                try
                {
                    gvCourses.DataSource = DatabaseHelper.ExecuteTable("SELECT c.CourseID,c.Title,c.Status,s.SubjectName FROM dbo.Course c JOIN dbo.Subject s ON s.SubjectID=c.SubjectID WHERE c.TeacherID=@user ORDER BY c.CreatedDate DESC,c.CourseID DESC",
                        new[] { new SqlParameter("@user", CurrentUserHelper.GetUserID().Value) });
                    gvCourses.DataBind();
                }
                catch (SqlException) { MessageHelper.SetError("Courses could not be loaded. Please try again."); }
            }
        }
        protected void CourseCommand(object sender, GridViewCommandEventArgs e)
        {
            if (!Page.IsValid) return;
            int id;
            if (!Int32.TryParse(Convert.ToString(e.CommandArgument), out id) || id < 1) { Response.Redirect("~/AccessDenied.aspx"); return; }
            try
            {
                if (!AccessHelper.IsOwnerOfCourse(CurrentUserHelper.GetUserID().Value, id)) { Response.Redirect("~/AccessDenied.aspx"); return; }
                string message;
                if (e.CommandName == "DeleteCourse")
                {
                    ValidationResult result = DeleteHelper.DeleteCourse(id);
                    if (!result.IsValid) { MessageHelper.SetError(result.Message); return; }
                    message = result.Message;
                }
                else
                {
                    if (e.CommandName != "PublishCourse" && e.CommandName != "UnpublishCourse") return;
                    bool publish = e.CommandName == "PublishCourse";
                    using (SqlConnection connection = DatabaseHelper.OpenConnection())
                    using (SqlTransaction transaction = connection.BeginTransaction(IsolationLevel.Serializable))
                    {
                        AccessHelper.RequireOwner(connection, transaction, id, "Course");
                        if (publish)
                        {
                            ValidationResult check = PublishHelper.CheckCourse(connection, transaction, id);
                            if (!check.IsValid) { MessageHelper.SetError(check.Message); return; }
                        }
                        DatabaseHelper.ExecuteNonQuery(connection, transaction,
                            "UPDATE dbo.Course SET Status=@status,LastUpdated=SYSUTCDATETIME() WHERE CourseID=@id AND Status<>@status",
                            new[] { new SqlParameter("@id", id), new SqlParameter("@status", publish ? "Published" : "Draft") });
                        transaction.Commit();
                    }
                    message = publish ? "Course published." : "Course unpublished. Existing results are retained.";
                }
                MessageHelper.SetSuccess(message);
                Response.Redirect("MyCourses.aspx");
            }
            catch (SqlException) { MessageHelper.SetError("The course could not be changed. Please refresh and try again."); }
        }
    }
}
