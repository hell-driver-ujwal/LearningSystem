using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using LearningSystem.Helpers;

namespace LearningSystem.Admin
{
    public partial class Subjects : Page
    {

        protected void Page_Load(object sender, EventArgs e)
        {
            AccessHelper.RequireRole(new[] { "Admin" });
            txtName.Text = txtName.Text.Trim();
            txtDescription.Text = txtDescription.Text.Trim();
            if (!IsPostBack) BindSubjects();
        }
        private void BindSubjects()
        {
            try
            {
                gvSubjects.DataSource = DatabaseHelper.ExecuteTable("SELECT s.SubjectID,s.SubjectName,s.Description,COUNT(c.CourseID) AS CourseCount FROM dbo.Subject s LEFT JOIN dbo.Course c ON c.SubjectID=s.SubjectID GROUP BY s.SubjectID,s.SubjectName,s.Description ORDER BY s.SubjectName", null);
                gvSubjects.DataBind();
            }
            catch (SqlException) { MessageHelper.SetError("Subjects could not be loaded. Please try again."); }
        }
        protected void ValidateSubject(object source, ServerValidateEventArgs args)
        {
            int id = 0;
            if (hfSubjectID.Value != "" && (!Int32.TryParse(hfSubjectID.Value, out id) || id < 1))
            { args.IsValid = false; cvSubject.ErrorMessage = "Choose a subject from the list."; return; }
            try
            {
                args.IsValid = Convert.ToInt32(DatabaseHelper.ExecuteScalar("SELECT COUNT(*) FROM dbo.Subject WHERE SubjectName=@name AND SubjectID<>@id",
                    new[] { new SqlParameter("@name", SqlDbType.NVarChar, 50) { Value = txtName.Text }, new SqlParameter("@id", id) })) == 0;
            }
            catch (SqlException) { args.IsValid = false; cvSubject.ErrorMessage = "Subject validation is unavailable."; }
        }
        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;
            int id = String.IsNullOrEmpty(hfSubjectID.Value) ? 0 : Int32.Parse(hfSubjectID.Value);
            try
            {
                int changed = DatabaseHelper.ExecuteNonQuery(id == 0
                    ? "INSERT INTO dbo.Subject (SubjectName,Description) VALUES (@name,@description)"
                    : "UPDATE dbo.Subject SET SubjectName=@name,Description=@description WHERE SubjectID=@id",
                    new[] { new SqlParameter("@name", SqlDbType.NVarChar, 50) { Value = txtName.Text },
                        new SqlParameter("@description", SqlDbType.NVarChar, 300) { Value = txtDescription.Text == "" ? (object)DBNull.Value : txtDescription.Text },
                        new SqlParameter("@id", id) });
                if (changed == 0) { MessageHelper.SetError("The subject no longer exists."); return; }
            }
            catch (SqlException ex)
            {
                MessageHelper.SetError(ex.Number == 2601 || ex.Number == 2627 ? "That subject name already exists." : "The subject could not be saved.");
                return;
            }
            MessageHelper.SetSuccess("Subject saved.");
            Response.Redirect("~/Admin/Subjects.aspx");
        }
        protected void btnCancel_Click(object sender, EventArgs e) { Response.Redirect("~/Admin/Subjects.aspx"); }
        protected void gvSubjects_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (!Page.IsValid) return;
            int id;
            if (!Int32.TryParse(Convert.ToString(e.CommandArgument), out id) || id < 1) return;
            try
            {
                if (e.CommandName == "EditSubject")
                {
                    DataTable rows = DatabaseHelper.ExecuteTable("SELECT SubjectName,Description FROM dbo.Subject WHERE SubjectID=@id", new[] { new SqlParameter("@id", id) });
                    if (rows.Rows.Count != 1) { MessageHelper.SetError("The subject no longer exists."); return; }
                    hfSubjectID.Value = id.ToString();
                    txtName.Text = (string)rows.Rows[0]["SubjectName"];
                    txtDescription.Text = Convert.ToString(rows.Rows[0]["Description"]);
                    btnSave.Text = "Save changes";
                }
                else if (e.CommandName == "DeleteSubject")
                {
                    using (SqlConnection connection = DatabaseHelper.OpenConnection())
                    using (SqlTransaction transaction = connection.BeginTransaction(IsolationLevel.Serializable))
                    {
                        ValidationResult check = DeleteHelper.CheckSubject(connection, transaction, id);
                        if (!check.IsValid) { MessageHelper.SetError(check.Message); return; }
                        int changed = DatabaseHelper.ExecuteNonQuery(connection, transaction, "DELETE FROM dbo.Subject WHERE SubjectID=@id", new[] { new SqlParameter("@id", id) });
                        if (changed == 0) { MessageHelper.SetError("The subject no longer exists."); return; }
                        transaction.Commit();
                    }
                    MessageHelper.SetSuccess("Subject deleted.");
                    Response.Redirect("~/Admin/Subjects.aspx");
                }
            }
            catch (SqlException) { MessageHelper.SetError("The subject could not be changed. It may be in use; refresh and try again."); }
        }
    }
}

