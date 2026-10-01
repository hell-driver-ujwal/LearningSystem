using System;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Web.UI;
using LearningSystem.Helpers;
namespace LearningSystem
{
    public partial class Help : Page
    {
        protected void Page_Load(object sender,EventArgs e)
        {
            try
            {
                string role=CurrentUserHelper.GetRole();
                if(role!="")AccessHelper.RequireRole(new[] {"Learner","Teacher","Admin"});
                DataTable rows=DatabaseHelper.ExecuteTable("SELECT Question,Answer,Audience FROM dbo.FAQ WHERE Audience='All' OR Audience=@role OR @role='Admin' ORDER BY SortOrder,FAQID",new[] {new SqlParameter("@role",SqlDbType.NVarChar,7){Value=role}});
                StringBuilder html=new StringBuilder();
                foreach(string audience in new[] {"All","Learner","Teacher"})
                {
                    StringBuilder group=new StringBuilder();
                    foreach(DataRow row in rows.Rows)if((string)row["Audience"]==audience)group.Append("<details><summary>"+CourseHelper.Encode(row["Question"])+"</summary><p class=\"preserve-lines\">"+CourseHelper.Encode(row["Answer"])+"</p></details>");
                    if(group.Length>0)html.Append("<h3>"+audience+"</h3>"+group);
                }
                litFAQ.Text=html.Length==0 ? "<p>No FAQs are available for your audience yet.</p>" : html.ToString();
            }
            catch(SqlException){MessageHelper.SetError("The managed FAQs could not be loaded. The getting-started guidance remains available.");}
        }
    }
}