using System;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Text;
using System.Web;

namespace LearningSystem.Helpers
{
    // Serves /robots.txt (registered in Web.config). Private areas are kept out of search engines.
    public class RobotsHandler : IHttpHandler
    {
        public bool IsReusable { get { return true; } }
        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "text/plain";
            context.Response.Write("User-agent: *\n"
                + "Disallow: /Account/\nDisallow: /Admin/\nDisallow: /Teacher/\nDisallow: /Learner/\nDisallow: /Member/\nDisallow: /Payment/\nDisallow: /Media.ashx\n"
                + "Allow: /\n\nSitemap: " + UiHelper.SiteOrigin + "/sitemap.xml\n");
        }
    }

    // Serves /sitemap.xml: public pages plus every published course, with its last update date.
    public class SitemapHandler : IHttpHandler
    {
        public bool IsReusable { get { return true; } }
        public void ProcessRequest(HttpContext context)
        {
            string origin = UiHelper.SiteOrigin;
            StringBuilder xml = new StringBuilder("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<urlset xmlns=\"http://www.sitemaps.org/schemas/sitemap/0.9\">\n");
            foreach (string page in new[] { "Default.aspx", "Courses.aspx", "About.aspx", "Help.aspx", "Contact.aspx", "SiteMap.aspx", "Privacy.aspx", "Terms.aspx", "Account/Register.aspx" })
                Url(xml, origin + "/" + page, null, page == "Default.aspx" || page == "Courses.aspx" ? "daily" : "monthly");
            try
            {
                foreach (DataRow row in DatabaseHelper.ExecuteTable("SELECT SubjectID FROM dbo.Subject ORDER BY SubjectID", null).Rows)
                    Url(xml, origin + "/Courses.aspx?subjectId=" + row["SubjectID"], null, "weekly");
                foreach (DataRow row in DatabaseHelper.ExecuteTable("SELECT CourseID, LastUpdated FROM dbo.Course WHERE Status='Published' ORDER BY CourseID", null).Rows)
                    Url(xml, origin + "/CourseDetails.aspx?id=" + row["CourseID"], (DateTime)row["LastUpdated"], "weekly");
            }
            catch (SqlException)
            {
                // The static pages above are still a valid sitemap if the database is unavailable.
            }
            context.Response.ContentType = "application/xml";
            context.Response.Write(xml.Append("</urlset>\n").ToString());
        }

        private static void Url(StringBuilder xml, string location, DateTime? updated, string frequency)
        {
            xml.Append("  <url><loc>").Append(HttpUtility.HtmlEncode(location)).Append("</loc>");
            if (updated.HasValue) xml.Append("<lastmod>").Append(updated.Value.ToString("yyyy-MM-dd", CultureInfo.InvariantCulture)).Append("</lastmod>");
            xml.Append("<changefreq>").Append(frequency).Append("</changefreq></url>\n");
        }
    }
}
