using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
namespace LearningSystem.Helpers
{
    public class BreadcrumbItem
    {
        public string Text { get; set; }
        public string Url { get; set; }
    }
    public static class BreadcrumbHelper
    {
        public static BreadcrumbItem[] ForCourse(int courseID)
        {
            if (!AccessHelper.IsOwnerOfCourse(CurrentUserHelper.GetUserID().GetValueOrDefault(), courseID))
                HttpContext.Current.Response.Redirect("~/AccessDenied.aspx");
            string title = System.Convert.ToString(DatabaseHelper.ExecuteScalar("SELECT Title FROM dbo.Course WHERE CourseID=@id",
                new[] { new System.Data.SqlClient.SqlParameter("@id", courseID) }));
            return new[] { new BreadcrumbItem { Text = "Home", Url = "~/Default.aspx" },
                new BreadcrumbItem { Text = "My courses", Url = "~/Teacher/MyCourses.aspx" },
                new BreadcrumbItem { Text = title, Url = "~/Teacher/CourseBuilder.aspx?id=" + courseID } };
        }
        public static BreadcrumbItem[] ForMaterial(int materialID)
        {
            if (!AccessHelper.IsOwnerOfMaterial(CurrentUserHelper.GetUserID().GetValueOrDefault(), materialID))
                HttpContext.Current.Response.Redirect("~/AccessDenied.aspx");
            System.Data.DataRow row = DatabaseHelper.ExecuteTable("SELECT t.CourseID,t.Title AS TopicTitle,m.Title FROM dbo.Material m JOIN dbo.Topic t ON t.TopicID=m.TopicID WHERE m.MaterialID=@id",
                new[] { new System.Data.SqlClient.SqlParameter("@id", materialID) }).Rows[0];
            System.Collections.Generic.List<BreadcrumbItem> trail = new System.Collections.Generic.List<BreadcrumbItem>(ForCourse((int)row["CourseID"]));
            trail.Add(new BreadcrumbItem { Text = (string)row["TopicTitle"], Url = "~/Teacher/CourseBuilder.aspx?id=" + row["CourseID"] });
            trail.Add(new BreadcrumbItem { Text = (string)row["Title"] });
            return trail.ToArray();
        }
        internal static BreadcrumbItem[] ForMaterial(System.Data.DataRow row, bool preview, bool publicPreview)
        {
            bool owner = AccessHelper.IsOwnerOfCourse(CurrentUserHelper.GetUserID().GetValueOrDefault(), (int)row["CourseID"]);
            string courseUrl = publicPreview ? "~/CourseDetails.aspx?id=" : preview ? (owner ? "~/Teacher/CourseBuilder.aspx?id=" : "~/CourseDetails.aspx?id=") : "~/Learner/CourseHome.aspx?id=";
            // Admins exit another author's draft preview to their oversight list, not a public draft URL.
            if (preview && !owner && CurrentUserHelper.GetRole() == "Admin") courseUrl = "~/Admin/Courses.aspx";
            else courseUrl += row["CourseID"];
            return new[] { new BreadcrumbItem { Text="Home", Url="~/Default.aspx" }, new BreadcrumbItem { Text=(string)row["CourseTitle"], Url=courseUrl },
                new BreadcrumbItem { Text=(string)row["TopicTitle"], Url=courseUrl }, new BreadcrumbItem { Text=(string)row["Title"] } };
        }
        public static BreadcrumbItem[] ForActivity(int activityID)
        {
            int user=CurrentUserHelper.GetUserID().GetValueOrDefault();
            if(!AccessHelper.CanAccessActivity(user,activityID,false) && !AccessHelper.CanPreview(user,activityID))HttpContext.Current.Response.Redirect("~/AccessDenied.aspx");
            System.Data.DataRow row=ActivityHelper.Find(activityID);
            string back=ActivityHelper.Back(row);
            return new[] {new BreadcrumbItem {Text="Home",Url="~/Default.aspx"},new BreadcrumbItem {Text=(string)row["CourseTitle"],Url=back},new BreadcrumbItem {Text=(string)row["TopicTitle"],Url=back},new BreadcrumbItem {Text=(string)row["Title"]}};
        }
        public static BreadcrumbItem[] ForAttempt(int attemptID)
        {
            if(!AccessHelper.CanViewAttempt(CurrentUserHelper.GetUserID().GetValueOrDefault(),attemptID))HttpContext.Current.Response.Redirect("~/AccessDenied.aspx");
            int activity=System.Convert.ToInt32(DatabaseHelper.ExecuteScalar("SELECT ActivityID FROM dbo.Attempt WHERE AttemptID=@id",ActivityHelper.ID(attemptID)));
            System.Data.DataRow row=ActivityHelper.Find(activity);
            return new[] {new BreadcrumbItem {Text="Home",Url="~/Default.aspx"},new BreadcrumbItem {Text=(string)row["CourseTitle"],Url=ActivityHelper.Back(row)},new BreadcrumbItem {Text=(string)row["Title"]},new BreadcrumbItem {Text="Quiz result"}};
        }
        public static void Render(PlaceHolder target, BreadcrumbItem[] items)
        {
            target.Controls.Clear();
            for (int i = 0; i < items.Length; i++)
            {
                if (i > 0) target.Controls.Add(new LiteralControl(" <span aria-hidden=\"true\">›</span> "));
                string text = HttpUtility.HtmlEncode(items[i].Text);
                string url = items[i].Url;
                if (i < items.Length - 1 && url != null && url.StartsWith("~/") && !url.Contains("\\") && !url.Contains(":"))
                    target.Controls.Add(new HyperLink { Text = text, NavigateUrl = url });
                else target.Controls.Add(new LiteralControl("<span aria-current=\"page\">" + text + "</span>"));
            }
        }
    }
}


