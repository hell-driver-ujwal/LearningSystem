using System;
using System.Configuration;
using System.Globalization;
using System.Web;

namespace LearningSystem.Helpers
{
    // Small presentation helpers shared by pages: icons, friendly labels and site settings.
    public static class UiHelper
    {
        // Site details live in Web.config appSettings so the team can change the domain or contact details in one place.
        public static string SiteName { get { return Setting("SiteName", "Inkwell"); } }
        public static string SiteOrigin { get { return Setting("SiteOrigin", "https://localhost:44393/").TrimEnd('/'); } }
        public static string ContactEmail { get { return Setting("ContactEmail", "hello@inkwellacademy.com.np"); } }
        public static string ContactAddress { get { return Setting("ContactAddress", "Putalisadak, Kathmandu 44600, Nepal"); } }
        public static string LastUpdated { get { return Setting("LastUpdated", "1 October 2026"); } }

        private static string Setting(string key, string fallback)
        {
            string value = ConfigurationManager.AppSettings[key];
            return String.IsNullOrWhiteSpace(value) ? fallback : value.Trim();
        }

        // Returns an inline SVG that points at a symbol in the sprite rendered by Site.Master.
        public static string Icon(string name)
        {
            return "<svg class=\"icon\" aria-hidden=\"true\" focusable=\"false\"><use href=\"#i-" + HttpUtility.HtmlAttributeEncode(name) + "\"></use></svg>";
        }

        // Icon name for each material or activity type.
        public static string TypeIcon(string type)
        {
            switch (type)
            {
                case "Text": return "book";
                case "Image": return "image";
                case "PDF": return "file";
                case "Video": case "YouTube": return "play";
                case "Audio": return "headphones";
                case "Code": return "code";
                case "Quiz": return "quiz";
                case "Game": return "puzzle";
                case "Scenario": return "route";
                case "SelfAssessment": return "gauge";
                case "Discussion": return "chat";
                default: return "book";
            }
        }

        // CSS modifier for the coloured square behind each type icon.
        public static string TypeClass(string type)
        {
            switch (type)
            {
                case "Quiz": return "type-quiz";
                case "Game": return "type-game";
                case "Scenario": return "type-scenario";
                case "SelfAssessment": return "type-selfassessment";
                case "Discussion": return "type-discussion";
                case "Code": return "type-code";
                default: return "type-lesson";
            }
        }

        public static string TypeMark(string type)
        {
            return "<span class=\"type-mark " + TypeClass(type) + "\">" + Icon(TypeIcon(type)) + "</span>";
        }

        // Learner-facing names: the database keeps the short fixed values.
        public static string TypeLabel(string type)
        {
            switch (type)
            {
                case "Text": return "Reading";
                case "Image": return "Diagram";
                case "PDF": return "PDF handout";
                case "Video": return "Video";
                case "YouTube": return "YouTube video";
                case "Audio": return "Audio";
                case "Code": return "Code lab";
                case "SelfAssessment": return "Self-assessment";
                default: return type;
            }
        }

        // The role value stays "Teacher" in the database; people see "Lecturer".
        public static string RoleLabel(string role)
        {
            if (role == "Teacher") return "Lecturer";
            if (role == "Admin") return "Administrator";
            return role;
        }

        public static string Initial(string name)
        {
            name = (name ?? "").Trim();
            return name.Length == 0 ? "?" : name.Substring(0, 1).ToUpperInvariant();
        }

        public static string Money(decimal amount)
        {
            return "NPR " + amount.ToString("#,0.##", CultureInfo.InvariantCulture);
        }

        // "3 days ago" style dates for activity feeds; exact UTC dates stay in tables.
        public static string Ago(DateTime utc)
        {
            TimeSpan span = DateTime.UtcNow - utc;
            if (span.TotalMinutes < 1) return "just now";
            if (span.TotalHours < 1) return Plural((int)span.TotalMinutes, "minute") + " ago";
            if (span.TotalDays < 1) return Plural((int)span.TotalHours, "hour") + " ago";
            if (span.TotalDays < 30) return Plural((int)span.TotalDays, "day") + " ago";
            return utc.ToString("d MMM yyyy", CultureInfo.InvariantCulture);
        }

        public static string Plural(int count, string word, string plural = null)
        {
            return count.ToString(CultureInfo.InvariantCulture) + " " + (count == 1 ? word : plural ?? word + "s");
        }
    }
}
