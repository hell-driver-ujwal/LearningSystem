using System.Web;
namespace LearningSystem.Helpers
{
    public class PageMessage
    {
        public bool IsError { get; set; }
        public string Text { get; set; }
    }
    public static class MessageHelper
    {
        // Consumed once by the master page after redirect.
        private const string MessageKey = "PageMessage";
        public static void SetSuccess(string message)
        {
            HttpContext.Current.Session[MessageKey] = new PageMessage { Text = message, IsError = false };
        }
        public static void SetError(string message)
        {
            HttpContext.Current.Session[MessageKey] = new PageMessage { Text = message, IsError = true };
        }
        public static PageMessage TakeMessage()
        {
            PageMessage message = HttpContext.Current.Session[MessageKey] as PageMessage;
            HttpContext.Current.Session.Remove(MessageKey);
            return message;
        }
    }
}
