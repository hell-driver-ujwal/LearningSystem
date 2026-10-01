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
        private const int PageSize = 9;
        private int PageNumber { get { return (int)(ViewState["PageNumber"] ?? 0); } set { ViewState["PageNumber"] = value; } }
        protected void Page_Load(object sender, EventArgs e)
        {
            txtSearch.Text = txtSearch.Text.Trim();
            if (IsPostBack) return;
            try
            {
                ddlSubject.DataSource = DatabaseHelper.ExecuteTable("SELECT SubjectID,SubjectName FROM dbo.Subject ORDER BY SubjectName", null);
                ddlSubject.DataTextField = "SubjectName"; ddlSubject.DataValueField = "SubjectID"; ddlSubject.DataBind(); ddlSubject.Items.Insert(0, new ListItem("All subjects", "0"));
                if (Request.QueryString["subjectId"] != null)
                {
                    int subject;
                    if (!Int32.TryParse(Request.QueryString["subjectId"], out subject) || subject < 1 || ddlSubject.Items.FindByValue(subject.ToString()) == null) { Response.Redirect("~/NotFound.aspx"); return; }
                    ddlSubject.SelectedValue = subject.ToString();
                }
                // Only the listed values are accepted; anything else falls back to the default option.
                SelectIfListed(ddlPrice, Request.QueryString["price"]);
                SelectIfListed(ddlSort, Request.QueryString["sort"]);
                txtSearch.Text = (Request.QueryString["q"] ?? "").Trim();
                if (txtSearch.Text.Length > 50) { MessageHelper.SetError("Search must be at most 50 characters."); txtSearch.Text = ""; }
                if (ddlSubject.SelectedValue != "0") Title = ddlSubject.SelectedItem.Text + " courses";
                BindCourses();
            }
            catch (SqlException) { MessageHelper.SetError("The catalogue is temporarily unavailable."); }
        }
        private static void SelectIfListed(DropDownList list, string value)
        {
            if (value != null && list.Items.FindByValue(value) != null) list.SelectedValue = value;
        }
        private void BindCourses()
        {
            try
            {
                int subject; if (!Int32.TryParse(ddlSubject.SelectedValue, out subject)) subject = 0;
                // Treat wildcard characters as literal search text, not SQL LIKE patterns.
                string search = txtSearch.Text.Replace("~", "~~").Replace("%", "~%").Replace("_", "~_").Replace("[", "~[");
                int paid = ddlPrice.SelectedValue == "paid" ? 1 : ddlPrice.SelectedValue == "free" ? 0 : -1;
                string filter = " FROM dbo.Course c JOIN dbo.Subject s ON s.SubjectID=c.SubjectID JOIN dbo.[User] u ON u.UserID=c.TeacherID WHERE c.Status='Published' AND (@subject=0 OR c.SubjectID=@subject) AND (@paid=-1 OR c.IsPaid=@paid) AND (c.Title LIKE @search ESCAPE '~' OR c.Description LIKE @search ESCAPE '~')";
                // The ORDER BY text comes only from this fixed list, never from the request.
                string order = ddlSort.SelectedValue == "title" ? "c.Title,c.CourseID" : ddlSort.SelectedValue == "popular" ? "(SELECT COUNT(*) FROM dbo.Enrolment e WHERE e.CourseID=c.CourseID) DESC,c.CourseID" : "c.CreatedDate DESC,c.CourseID DESC";
                int count = Convert.ToInt32(DatabaseHelper.ExecuteScalar("SELECT COUNT(*)" + filter, Parameters(subject, paid, search, 0)));
                int pages = Math.Max(1, (count + PageSize - 1) / PageSize); PageNumber = Math.Max(0, Math.Min(PageNumber, pages - 1));
                DataTable rows = DatabaseHelper.ExecuteTable("SELECT c.IsPaid,c.PriceNPR,c.CourseID,c.Title,c.Description,c.CoverImagePath,s.SubjectName,u.FullName AS TeacherName" + filter + " ORDER BY " + order + " OFFSET @skip ROWS FETCH NEXT " + PageSize + " ROWS ONLY",
                    Parameters(subject, paid, search, PageNumber * PageSize));
                CourseHelper.Cards(phCourses, rows);
                litCount.Text = count == 0 ? "" : count == 1 ? "1 course found." : count + " courses found.";
                lblPage.Text = "Page " + (PageNumber + 1) + " of " + pages; btnPrevious.Enabled = PageNumber > 0; btnNext.Enabled = PageNumber + 1 < pages;
                btnPrevious.Visible = btnNext.Visible = lblPage.Visible = pages > 1;
            }
            catch (SqlException) { MessageHelper.SetError("The catalogue is temporarily unavailable."); }
        }
        private static SqlParameter[] Parameters(int subject, int paid, string search, int skip)
        {
            return new[] { new SqlParameter("@subject", subject), new SqlParameter("@paid", paid), new SqlParameter("@search", SqlDbType.NVarChar, 110) { Value = "%" + search + "%" }, new SqlParameter("@skip", skip) };
        }
        protected void SearchCourses(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;
            string url = "Courses.aspx?q=" + HttpUtility.UrlEncode(txtSearch.Text);
            if (ddlSubject.SelectedValue != "0") url += "&subjectId=" + ddlSubject.SelectedValue;
            if (ddlPrice.SelectedValue != "") url += "&price=" + ddlPrice.SelectedValue;
            if (ddlSort.SelectedValue != "") url += "&sort=" + ddlSort.SelectedValue;
            Response.Redirect(url);
        }
        protected void ClearFilters(object sender, EventArgs e) { Response.Redirect("Courses.aspx"); }
        protected void PreviousCoursesPage(object sender, EventArgs e) { Page.Validate("Search"); if (!Page.IsValid) return; PageNumber--; BindCourses(); }
        protected void NextPage(object sender, EventArgs e) { Page.Validate("Search"); if (!Page.IsValid) return; PageNumber++; BindCourses(); }
    }
}
