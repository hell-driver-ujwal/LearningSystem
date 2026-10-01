using System;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using LearningSystem.Helpers;
namespace LearningSystem
{
    public partial class Courses : Page
    {
        private int PageNumber { get { return (int)(ViewState["PageNumber"] ?? 0); } set { ViewState["PageNumber"] = value; } }
        protected void Page_Load(object sender, EventArgs e)
        {
            txtSearch.Text = txtSearch.Text.Trim();
            if (IsPostBack) return;
            try
            {
                ddlSubject.DataSource = DatabaseHelper.ExecuteTable("SELECT SubjectID,SubjectName FROM dbo.Subject ORDER BY SubjectName", null);
                ddlSubject.DataTextField="SubjectName"; ddlSubject.DataValueField="SubjectID"; ddlSubject.DataBind(); ddlSubject.Items.Insert(0,new ListItem("All subjects","0"));
                if (Request.QueryString["subjectId"] != null)
                {
                    int subject;
                    if (!Int32.TryParse(Request.QueryString["subjectId"], out subject) || subject < 1 || ddlSubject.Items.FindByValue(subject.ToString()) == null) { Response.Redirect("~/NotFound.aspx"); return; }
                    ddlSubject.SelectedValue=subject.ToString();
                }
                txtSearch.Text=(Request.QueryString["q"] ?? "").Trim();
                if (txtSearch.Text.Length > 50) { MessageHelper.SetError("Search must be at most 50 characters."); txtSearch.Text=""; }
                BindCourses();
            }
            catch (SqlException) { MessageHelper.SetError("The catalogue is temporarily unavailable."); }
        }
        private void BindCourses()
        {
            try
            {
                int subject; if (!Int32.TryParse(ddlSubject.SelectedValue,out subject)) subject=0;
                // Treat wildcard characters as literal search text, not SQL LIKE patterns.
                string search=txtSearch.Text.Replace("~","~~").Replace("%","~%").Replace("_","~_").Replace("[","~[");
                string filter=" FROM dbo.Course c JOIN dbo.Subject s ON s.SubjectID=c.SubjectID JOIN dbo.[User] u ON u.UserID=c.TeacherID WHERE c.Status='Published' AND (@subject=0 OR c.SubjectID=@subject) AND (c.Title LIKE @search ESCAPE '~' OR c.Description LIKE @search ESCAPE '~')";
                int count=Convert.ToInt32(DatabaseHelper.ExecuteScalar("SELECT COUNT(*)"+filter,new[] {new SqlParameter("@subject",subject),new SqlParameter("@search",SqlDbType.NVarChar,110){Value="%"+search+"%"}}));
                int pages=Math.Max(1,(count+5)/6); PageNumber=Math.Max(0,Math.Min(PageNumber,pages-1));
                DataTable rows=DatabaseHelper.ExecuteTable("SELECT c.IsPaid,c.PriceNPR,c.CourseID,c.Title,c.Description,c.CoverImagePath,s.SubjectName,u.FullName AS TeacherName"+filter+" ORDER BY c.CreatedDate DESC,c.CourseID DESC OFFSET @skip ROWS FETCH NEXT 6 ROWS ONLY",
                    new[] {new SqlParameter("@subject",subject),new SqlParameter("@search",SqlDbType.NVarChar,110){Value="%"+search+"%"},new SqlParameter("@skip",PageNumber*6)});
                CourseHelper.Cards(phCourses,rows); lblPage.Text="Page "+(PageNumber+1)+" of "+pages; btnPrevious.Enabled=PageNumber>0; btnNext.Enabled=PageNumber+1<pages;
            }
            catch (SqlException) { MessageHelper.SetError("The catalogue is temporarily unavailable."); }
        }
        protected void SearchCourses(object sender,EventArgs e)
        {
            if (!Page.IsValid) return;
            Response.Redirect("Courses.aspx?"+(ddlSubject.SelectedValue=="0" ? "" : "subjectId="+ddlSubject.SelectedValue+"&")+"q="+HttpUtility.UrlEncode(txtSearch.Text));
        }
        protected void ClearFilters(object sender,EventArgs e) { Response.Redirect("Courses.aspx"); }
        protected void PreviousCoursesPage(object sender,EventArgs e) { Page.Validate("Search"); if (!Page.IsValid) return; PageNumber--; BindCourses(); }
        protected void NextPage(object sender,EventArgs e) { Page.Validate("Search"); if (!Page.IsValid) return; PageNumber++; BindCourses(); }
    }
}


