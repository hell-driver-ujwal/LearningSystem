using System;
using System.Security.Cryptography;
namespace LearningSystem.Helpers
{
    public static class PasswordHelper
    {
        public static string HashPassword(string password)
        {
            byte[] salt = new byte[16];
            using (RandomNumberGenerator random = RandomNumberGenerator.Create()) random.GetBytes(salt);
            using (Rfc2898DeriveBytes derive = new Rfc2898DeriveBytes(password, salt, 100000, HashAlgorithmName.SHA256))
                return "PBKDF2$100000$" + Convert.ToBase64String(salt) + "$" + Convert.ToBase64String(derive.GetBytes(32));
        }
        public static bool VerifyPassword(string password, string storedHash)
        {
            if (password == null || storedHash == null) return false;
            string[] parts = storedHash.Split('$');
            if (parts.Length != 4 || parts[0] != "PBKDF2" || parts[1] != "100000") return false;
            try
            {
                byte[] salt = Convert.FromBase64String(parts[2]);
                byte[] expected = Convert.FromBase64String(parts[3]);
                if (salt.Length != 16 || expected.Length != 32) return false;
                using (Rfc2898DeriveBytes derive = new Rfc2898DeriveBytes(password, salt, 100000, HashAlgorithmName.SHA256))
                {
                    byte[] actual = derive.GetBytes(32);
                    int difference = 0;
                    // Compare all bytes so partial matches do not exit early.
                    for (int i = 0; i < actual.Length; i++) difference |= actual[i] ^ expected[i];
                    return difference == 0;
                }
            }
            catch (FormatException) { return false; }
        }
    }
}
