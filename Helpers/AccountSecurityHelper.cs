using System;
using System.Data;
using System.Data.SqlClient;
using System.Web;

namespace LearningSystem.Helpers
{
    internal static class AccountSecurityHelper
    {
        // Lock the row while checking/updating failures, so parallel logins cannot lose increments.
        internal static int CheckLogin(string email, string password, out string message)
        {
            return CheckLogin(email, password, null, out message);
        }
        internal static int CheckLogin(string email, string password, string portalRole, out string message)
        {
            message = "The email or password is incorrect.";
            if (email.Length > 100) return 0;
            using (SqlConnection connection = DatabaseHelper.OpenConnection())
            using (SqlTransaction transaction = connection.BeginTransaction())
            {
                DataTable rows = DatabaseHelper.ExecuteTable(connection, transaction,
                    "SELECT UserID,Role,PasswordHash,Status,FailedLoginCount,LockedUntil FROM dbo.[User] WITH (UPDLOCK,ROWLOCK) WHERE Email=@email",
                    new[] { new SqlParameter("@email", SqlDbType.NVarChar, 100) { Value = email } });
                if (rows.Rows.Count != 1) return 0;
                DataRow user = rows.Rows[0];
                DateTime now = DateTime.UtcNow;
                DateTime? until = user.IsNull("LockedUntil") ? (DateTime?)null : (DateTime)user["LockedUntil"];
                if (until.HasValue && until.Value > now)
                {
                    message = "Account temporarily locked. Try again in " + Math.Ceiling((until.Value - now).TotalMinutes) + " minute(s).";
                    return 0;
                }
                int id = (int)user["UserID"];
                if (!PasswordHelper.VerifyPassword(password, (string)user["PasswordHash"]))
                {
                    int failures = until.HasValue ? 1 : Math.Min((int)user["FailedLoginCount"], 4) + 1;
                    DatabaseHelper.ExecuteNonQuery(connection, transaction,
                        "UPDATE dbo.[User] SET FailedLoginCount=@count,LockedUntil=@until WHERE UserID=@id",
                        new[] { new SqlParameter("@id", id), new SqlParameter("@count", failures),
                            new SqlParameter("@until", SqlDbType.DateTime2) { Value = failures == 5 ? (object)now.AddMinutes(15) : DBNull.Value } });
                    transaction.Commit();
                    if (failures == 5) message = "Account temporarily locked. Try again in 15 minutes.";
                    return 0;
                }
                if (portalRole != null && (string)user["Role"] != portalRole)
                {
                    message = "This account cannot use this portal. Please use the appropriate sign-in page.";
                    return 0; // A correct password at the wrong portal is not a failed password attempt.
                }
                string status = (string)user["Status"];
                if (status != "Active")
                {
                    message = status == "Pending" ? "Your lecturer application is still being reviewed. You can log in once it is approved."
                        : status == "Rejected" ? "Your lecturer application was not approved. Please contact us if you have questions."
                        : "Your account has been deactivated. Please contact the administrator.";
                    return 0;
                }
                DatabaseHelper.ExecuteNonQuery(connection, transaction,
                    "UPDATE dbo.[User] SET FailedLoginCount=0,LockedUntil=NULL WHERE UserID=@id", new[] { new SqlParameter("@id", id) });
                transaction.Commit();
                return id;
            }
        }

        internal static bool MustChange(int userID)
        {
            return Convert.ToBoolean(DatabaseHelper.ExecuteScalar(
                "SELECT MustChangePassword FROM dbo.[User] WHERE UserID=@id", new[] { new SqlParameter("@id", userID) }));
        }

        internal static bool IsException(string path)
        {
            string p = path.ToLowerInvariant();
            if (p == "~/member/changepassword.aspx" || p == "~/account/logout.aspx"
                || p == "~/accessdenied.aspx" || p == "~/notfound.aspx" || p == "~/error.aspx"
                || p == "~/webresource.axd" || p == "~/scriptresource.axd") return true;
            // Only local presentation folders qualify. Uploads and Media.ashx are never exempt.
            string extension = System.IO.Path.GetExtension(p);
            return (p.StartsWith("~/styles/") || p.StartsWith("~/scripts/") || p.StartsWith("~/images/"))
                && (extension == ".css" || extension == ".js" || extension == ".png" || extension == ".jpg"
                    || extension == ".gif" || extension == ".svg" || extension == ".ico");
        }
    }
}
