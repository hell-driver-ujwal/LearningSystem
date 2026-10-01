using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using LearningSystem.Helpers;
namespace LearningSystem
{
    public partial class About : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            try
            {
                // Lecturers with at least one published course, and the subjects they teach.
                DataTable lecturers = DatabaseHelper.ExecuteTable(@"SELECT u.UserID, u.FullName,
 STUFF((SELECT DISTINCT ', ' + s.SubjectName FROM dbo.Course c2 JOIN dbo.Subject s ON s.SubjectID=c2.SubjectID WHERE c2.TeacherID=u.UserID AND c2.Status='Published' FOR XML PATH('')), 1, 2, '') AS Subjects
FROM dbo.[User] u WHERE u.Role='Teacher' AND u.Status='Active' AND EXISTS (SELECT 1 FROM dbo.Course c WHERE c.TeacherID=u.UserID AND c.Status='Published')
ORDER BY u.FullName", null);
                rptLecturers.DataSource = lecturers; rptLecturers.DataBind();
                DataRow facts = DatabaseHelper.ExecuteTable(@"SELECT
 (SELECT COUNT(*) FROM dbo.Course WHERE Status='Published') AS Courses,
 (SELECT COUNT(*) FROM dbo.Subject) AS Subjects,
 (SELECT COUNT(*) FROM dbo.Material m JOIN dbo.Topic t ON t.TopicID=m.TopicID JOIN dbo.Course c ON c.CourseID=t.CourseID WHERE m.Status='Published' AND c.Status='Published') AS Lessons,
 (SELECT COUNT(*) FROM dbo.Activity a JOIN dbo.Topic t ON t.TopicID=a.TopicID JOIN dbo.Course c ON c.CourseID=t.CourseID WHERE a.Status='Published' AND c.Status='Published') AS Activities", null).Rows[0];
                litFacts.Text = "<ul class=\"includes\"><li>" + UiHelper.Icon("layers") + UiHelper.Plural((int)facts["Courses"], "published course") + "</li><li>"
                    + UiHelper.Icon("compass") + UiHelper.Plural((int)facts["Subjects"], "subject") + "</li><li>"
                    + UiHelper.Icon("book") + UiHelper.Plural((int)facts["Lessons"], "lesson") + "</li><li>"
                    + UiHelper.Icon("puzzle") + UiHelper.Plural((int)facts["Activities"], "practice activity", "practice activities") + "</li></ul>";
            }
            catch (SqlException) { MessageHelper.SetError("Some details are temporarily unavailable."); }
        }
    }
}
