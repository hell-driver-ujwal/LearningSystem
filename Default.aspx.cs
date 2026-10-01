using System;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Text.RegularExpressions;
using System.Web.UI;
using LearningSystem.Helpers;
namespace LearningSystem
{
    public partial class _Default : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            ((SiteMaster)Master).MainClassName = "home";
            lnkRegister.Visible = !CurrentUserHelper.IsAuthenticated();
            try
            {
                // Real counts from the database, never hard-coded marketing numbers.
                litCourseCount.Text = Convert.ToString(DatabaseHelper.ExecuteScalar("SELECT COUNT(*) FROM dbo.Course WHERE Status='Published'", null));
                litLecturerCount.Text = Convert.ToString(DatabaseHelper.ExecuteScalar("SELECT COUNT(DISTINCT TeacherID) FROM dbo.Course WHERE Status='Published'", null));
                litActivityCount.Text = Convert.ToString(DatabaseHelper.ExecuteScalar("SELECT COUNT(*) FROM dbo.Activity a JOIN dbo.Topic t ON t.TopicID=a.TopicID JOIN dbo.Course c ON c.CourseID=t.CourseID WHERE a.Status='Published' AND c.Status='Published'", null));
                DataTable subjects = DatabaseHelper.ExecuteTable("SELECT s.SubjectID,s.SubjectName,COUNT(c.CourseID) AS CourseCount FROM dbo.Subject s LEFT JOIN dbo.Course c ON c.SubjectID=s.SubjectID AND c.Status='Published' GROUP BY s.SubjectID,s.SubjectName ORDER BY s.SubjectID", null);
                rptSubjects.DataSource = subjects; rptSubjects.DataBind(); lblNoSubjects.Visible = subjects.Rows.Count == 0;
                CourseHelper.Cards(phCourses, DatabaseHelper.ExecuteTable("SELECT TOP (6) c.IsPaid,c.PriceNPR,c.CourseID,c.Title,c.Description,c.CoverImagePath,s.SubjectName,u.FullName AS TeacherName FROM dbo.Course c JOIN dbo.Subject s ON s.SubjectID=c.SubjectID JOIN dbo.[User] u ON u.UserID=c.TeacherID WHERE c.Status='Published' ORDER BY c.CreatedDate DESC,c.CourseID DESC", null));
                rptFaq.DataSource = DatabaseHelper.ExecuteTable("SELECT TOP (4) Question,Answer FROM dbo.FAQ WHERE Audience='All' ORDER BY SortOrder,FAQID", null);
                rptFaq.DataBind();
            }
            catch (SqlException) { MessageHelper.SetError("Courses are temporarily unavailable. Please try again later."); }
        }

        // Each subject has a photo named after it, for example Assets/images/subjects/cybersecurity.jpg.
        // New subjects added by the admin use a general picture until one is supplied.
        protected string SubjectImage(object name)
        {
            string slug = Regex.Replace(Convert.ToString(name).ToLowerInvariant(), "[^a-z0-9]+", "-").Trim('-');
            string path = "~/Assets/images/subjects/" + slug + ".jpg";
            if (!File.Exists(Server.MapPath(path))) path = "~/Assets/images/subjects/general.jpg";
            return ResolveUrl(path);
        }

        protected string CourseCount(object count)
        {
            int value = Convert.ToInt32(count);
            return value == 0 ? "Courses coming soon" : UiHelper.Plural(value, "course");
        }
    }
}
