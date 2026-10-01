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
                    foreach(DataRow row in rows.Rows)if((string)row["Audience"]==audience)group.Append("<details data-faq><summary>"+CourseHelper.Encode(row["Question"])+"</summary><p class=\"preserve-lines\">"+CourseHelper.Encode(row["Answer"])+"</p></details>");
                    if(group.Length>0)html.Append("<h3>"+(audience=="All" ? "Everyone" : audience=="Learner" ? "Learners" : "Lecturers")+"</h3>"+group);
                }
                litFAQ.Text=html.Length==0 ? "<p class=\"empty-state\">No questions have been added for you yet.</p>" : html.ToString();
            }
            catch(SqlException){MessageHelper.SetError("The managed FAQs could not be loaded. The getting-started guidance remains available.");}
        }
    }
}