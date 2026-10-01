using System;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Text;
using System.Web.UI;
using LearningSystem.Helpers;
namespace LearningSystem.Admin
{
    public partial class Analytics : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            AccessHelper.RequireRole(new[] { "Admin" });
            if (!IsPostBack) Bind();
        }
        protected void RangeChanged(object sender, EventArgs e) { Bind(); }

        private void Bind()
        {
            int days;
            if (!Int32.TryParse(ddlRange.SelectedValue, out days) || (days != 7 && days != 14 && days != 30)) days = 14;
            try
            {
                DataTable daily = AnalyticsHelper.DailyViews(days);
                int total = 0, max = 1;
                foreach (DataRow row in daily.Rows) { total += (int)row["Views"]; max = Math.Max(max, (int)row["Views"]); }
                litTotal.Text = total.ToString("N0", CultureInfo.InvariantCulture);
                litPeriod.Text = "In the last " + days + " days";
                litToday.Text = daily.Rows.Count == 0 ? "0" : daily.Rows[daily.Rows.Count - 1]["Views"].ToString();
                litAverage.Text = (total / (decimal)days).ToString("0.#", CultureInfo.InvariantCulture);

                // A simple bar list: every bar also shows its number, so the chart works without colour or images.
                StringBuilder html = new StringBuilder("<ul class=\"bar-list\">");
                foreach (DataRow row in daily.Rows)
                {
                    int views = (int)row["Views"];
                    html.Append("<li><span>").Append(((DateTime)row["ViewDate"]).ToString("ddd d MMM", CultureInfo.InvariantCulture)).Append("</span><span class=\"bar\"><span style=\"width:")
                        .Append((views * 100 / max).ToString(CultureInfo.InvariantCulture)).Append("%\"></span></span><span class=\"num\">").Append(views).Append("</span></li>");
                }
                litDaily.Text = html.Append("</ul>").ToString();

                DataTable roles = AnalyticsHelper.ViewsByRole(days);
                int signedIn = 0, roleMax = 1;
                foreach (DataRow row in roles.Rows) { roleMax = Math.Max(roleMax, (int)row["Views"]); if ((string)row["ViewerRole"] != "Visitor") signedIn += (int)row["Views"]; }
                litSignedIn.Text = total == 0 ? "0%" : (signedIn * 100 / total) + "%";
                html = new StringBuilder("<ul class=\"bar-list\">");
                foreach (DataRow row in roles.Rows)
                {
                    string role = (string)row["ViewerRole"];
                    string label = role == "Visitor" ? "Visitors (logged out)" : UiHelper.RoleLabel(role) + "s";
                    html.Append("<li><span>").Append(label).Append("</span><span class=\"bar\"><span style=\"width:").Append(((int)row["Views"] * 100 / roleMax).ToString(CultureInfo.InvariantCulture))
                        .Append("%\"></span></span><span class=\"num\">").Append(row["Views"]).Append("</span></li>");
                }
                litRoles.Text = roles.Rows.Count == 0 ? "<p class=\"muted\">No views recorded yet.</p>" : html.Append("</ul>").ToString();

                gvPages.DataSource = AnalyticsHelper.TopPages(days, 15); gvPages.DataBind();
            }
            catch (SqlException) { MessageHelper.SetError("Analytics are temporarily unavailable."); }
        }
    }
}
