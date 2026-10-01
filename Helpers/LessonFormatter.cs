using System.Collections.Generic;
using System.Text;
using System.Text.RegularExpressions;
using System.Web;

namespace LearningSystem.Helpers
{
    // Turns a plain-text lesson into simple, safe HTML.
    // Every line is HTML-encoded first, so a lecturer can never inject markup or scripts.
    // Supported formatting:
    //   ## Section heading        ### Smaller heading
    //   - bullet point            1. numbered step
    //   > tip or key idea         ``` (start / end of a code block)
    //   **bold words**            `inline code`
    internal static class LessonFormatter
    {
        internal static string ToHtml(string text)
        {
            StringBuilder html = new StringBuilder();
            List<string> paragraph = new List<string>();
            string openList = null;
            bool inCode = false;
            foreach (string line in (text ?? "").Replace("\r\n", "\n").Split('\n'))
            {
                string trimmed = line.Trim();
                if (inCode)
                {
                    if (trimmed == "```") { html.Append("</code></pre>"); inCode = false; }
                    else html.Append(HttpUtility.HtmlEncode(line)).Append('\n');
                    continue;
                }
                if (trimmed.StartsWith("```"))
                {
                    Flush(html, paragraph); openList = CloseList(html, openList);
                    html.Append("<pre class=\"lesson-code\"><code>"); inCode = true;
                }
                else if (trimmed == "") { Flush(html, paragraph); openList = CloseList(html, openList); }
                else if (trimmed.StartsWith("### ")) { Flush(html, paragraph); openList = CloseList(html, openList); html.Append("<h3>").Append(Inline(trimmed.Substring(4))).Append("</h3>"); }
                else if (trimmed.StartsWith("## ")) { Flush(html, paragraph); openList = CloseList(html, openList); html.Append("<h2>").Append(Inline(trimmed.Substring(3))).Append("</h2>"); }
                else if (trimmed.StartsWith("> ")) { Flush(html, paragraph); openList = CloseList(html, openList); html.Append("<aside class=\"lesson-tip\"><p>").Append(Inline(trimmed.Substring(2))).Append("</p></aside>"); }
                else if (trimmed.StartsWith("- ")) { Flush(html, paragraph); openList = OpenList(html, openList, "ul"); html.Append("<li>").Append(Inline(trimmed.Substring(2))).Append("</li>"); }
                else if (Regex.IsMatch(trimmed, @"^\d{1,2}\.\s"))
                {
                    Flush(html, paragraph); openList = OpenList(html, openList, "ol");
                    html.Append("<li>").Append(Inline(trimmed.Substring(trimmed.IndexOf('.') + 1).Trim())).Append("</li>");
                }
                else { openList = CloseList(html, openList); paragraph.Add(trimmed); }
            }
            Flush(html, paragraph); CloseList(html, openList);
            if (inCode) html.Append("</code></pre>");
            return html.ToString();
        }

        private static void Flush(StringBuilder html, List<string> paragraph)
        {
            if (paragraph.Count == 0) return;
            html.Append("<p>").Append(Inline(string.Join(" ", paragraph))).Append("</p>");
            paragraph.Clear();
        }

        private static string OpenList(StringBuilder html, string openList, string tag)
        {
            if (openList == tag) return tag;
            CloseList(html, openList);
            html.Append('<').Append(tag).Append('>');
            return tag;
        }

        private static string CloseList(StringBuilder html, string openList)
        {
            if (openList != null) html.Append("</").Append(openList).Append('>');
            return null;
        }

        // Encode first, then add the two inline styles. The patterns cannot create attributes or tags of their own.
        private static string Inline(string text)
        {
            string encoded = HttpUtility.HtmlEncode(text);
            encoded = Regex.Replace(encoded, @"\*\*(.+?)\*\*", "<strong>$1</strong>");
            encoded = Regex.Replace(encoded, @"`([^`]+)`", "<code>$1</code>");
            return encoded;
        }
    }
}
