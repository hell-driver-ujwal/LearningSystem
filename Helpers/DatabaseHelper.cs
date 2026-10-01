using System.Configuration;
using System.Data;
using System.Data.SqlClient;
namespace LearningSystem.Helpers
{
    public static class DatabaseHelper
    {
        public static SqlConnection OpenConnection()
        {
            SqlConnection connection = new SqlConnection(ConfigurationManager.ConnectionStrings["LearningSystemDb"].ConnectionString);
            try { connection.Open(); return connection; }
            catch { connection.Dispose(); throw; }
        }
        public static DataTable ExecuteTable(string sql, SqlParameter[] parameters)
        {
            using (SqlConnection connection = OpenConnection()) return ExecuteTable(connection, null, sql, parameters);
        }
        public static object ExecuteScalar(string sql, SqlParameter[] parameters)
        {
            using (SqlConnection connection = OpenConnection()) return ExecuteScalar(connection, null, sql, parameters);
        }
        public static int ExecuteNonQuery(string sql, SqlParameter[] parameters)
        {
            using (SqlConnection connection = OpenConnection()) return ExecuteNonQuery(connection, null, sql, parameters);
        }
        public static DataTable ExecuteTable(SqlConnection connection, SqlTransaction transaction, string sql, SqlParameter[] parameters)
        {
            using (SqlCommand command = CreateCommand(connection, transaction, sql, parameters))
            using (SqlDataAdapter adapter = new SqlDataAdapter(command))
            {
                DataTable table = new DataTable();
                adapter.Fill(table);
                return table;
            }
        }
        public static object ExecuteScalar(SqlConnection connection, SqlTransaction transaction, string sql, SqlParameter[] parameters)
        {
            using (SqlCommand command = CreateCommand(connection, transaction, sql, parameters)) return command.ExecuteScalar();
        }
        public static int ExecuteNonQuery(SqlConnection connection, SqlTransaction transaction, string sql, SqlParameter[] parameters)
        {
            using (SqlCommand command = CreateCommand(connection, transaction, sql, parameters)) return command.ExecuteNonQuery();
        }
        private static SqlCommand CreateCommand(SqlConnection connection, SqlTransaction transaction, string sql, SqlParameter[] parameters)
        {
            SqlCommand command = new SqlCommand(sql, connection, transaction);
            if (parameters != null) command.Parameters.AddRange(parameters);
            return command;
        }
    }
}
