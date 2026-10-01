using System;
using System.Security.Cryptography;
using System.Web;
namespace LearningSystem.Helpers
{
    internal static class CaptchaHelper
    {
        internal static void Generate(string key = "RegisterCaptcha")
        {
            byte[] numbers = new byte[2];
            using (RandomNumberGenerator random = RandomNumberGenerator.Create()) random.GetBytes(numbers);
            int a = numbers[0] % 9 + 1, b = numbers[1] % 9 + 1;
            HttpContext.Current.Session[key] = new[] { a, b, a + b };
        }
        internal static string Question(string key = "RegisterCaptcha")
        {
            int[] challenge = HttpContext.Current.Session[key] as int[];
            return challenge == null ? "CAPTCHA expired. Submit to receive a new question." : "What is " + challenge[0] + " + " + challenge[1] + "?";
        }
        internal static bool Check(string text, string key = "RegisterCaptcha")
        {
            int[] challenge = HttpContext.Current.Session[key] as int[];
            int answer;
            return challenge != null && Int32.TryParse(text, out answer) && answer == challenge[2];
        }
    }
}
