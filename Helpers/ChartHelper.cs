using System;
using System.Collections.Generic;
using System.Data;
using System.Text;
using System.Web;
using System.Web.Script.Serialization;
namespace LearningSystem.Helpers
{
    internal static class ChartHelper
    {
        internal static string Bars(string title, DataTable rows, string labelColumn, string valueColumn)
        {
            List<string> labels = new List<string>();
            List<int> values = new List<int>();
            StringBuilder table = new StringBuilder("<table><caption>" + HttpUtility.HtmlEncode(title) + "</caption><thead><tr><th scope=\"col\">Category</th><th scope=\"col\">Count</th></tr></thead><tbody>");
            foreach (DataRow row in rows.Rows)
            {
                string label = Convert.ToString(row[labelColumn]);
                int value = Convert.ToInt32(row[valueColumn]);
                labels.Add(label); values.Add(value);
                table.Append("<tr><th scope=\"row\">" + HttpUtility.HtmlEncode(label) + "</th><td>" + value + "</td></tr>");
            }
            table.Append("</tbody></table>");
            if (rows.Rows.Count == 0) return "<p>No chart data yet.</p>";
            string json = new JavaScriptSerializer().Serialize(new { labels = labels, values = values });
            return "<section class=\"chart-card\"><h3>" + HttpUtility.HtmlEncode(title)
                + "</h3><canvas class=\"bar-chart\" role=\"img\" aria-label=\"" + HttpUtility.HtmlAttributeEncode(title + "; counts in the table below.")
                + "\" data-chart=\"" + HttpUtility.HtmlAttributeEncode(json) + "\">Counts appear in the following table.</canvas>"
                + "<details><summary>Chart data</summary><div class=\"table-scroll\" tabindex=\"0\" role=\"region\" aria-label=\"Chart data\">" + table + "</div></details></section>";
        }
        internal static string ScoreSpread(DataTable attempts)
        {
            Dictionary<int, DataTable> groups = new Dictionary<int, DataTable>();
            Dictionary<int, string> titles = new Dictionary<int, string>();
            foreach (DataRow attempt in attempts.Rows)
            {
                string type = (string)attempt["ActivityType"];
                if ((type != "Quiz" && type != "Game") || attempt.IsNull("ScorePercent")) continue;
                int id = (int)attempt["ActivityID"];
                if (!groups.ContainsKey(id))
                {
                    DataTable bins = new DataTable(); bins.Columns.Add("Label"); bins.Columns.Add("Count", typeof(int));
                    foreach (string label in new[] { "0 to under 20%", "20 to under 40%", "40 to under 60%", "60 to under 80%", "80 to 100%" }) bins.Rows.Add(label, 0);
                    groups.Add(id, bins);
                    titles.Add(id, Convert.ToString(attempt["CourseTitle"]) + " / " + Convert.ToString(attempt["Title"]));
                }
                int bin = Math.Min(4, (int)(Convert.ToDecimal(attempt["ScorePercent"]) / 20));
                DataRow row = groups[id].Rows[bin]; row["Count"] = (int)row["Count"] + 1;
            }
            StringBuilder html = new StringBuilder();
            foreach (KeyValuePair<int, DataTable> group in groups) html.Append(Bars(titles[group.Key], group.Value, "Label", "Count"));
            return html.Length == 0 ? "<p>No quiz or game scores to chart. Confidence and outcomes are shown in their own summaries.</p>" : html.ToString();
        }
    }
}
