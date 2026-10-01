using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using LearningSystem.Helpers;
namespace LearningSystem.Payment {
 public partial class EsewaSuccess : Page {
  protected void Page_Load(object sender,EventArgs e) {
   AccessHelper.RequireRole(new[]{"Learner"});
   Response.Cache.SetNoStore();
   Response.Headers["Referrer-Policy"]="no-referrer";
   try {
    int course=PaymentHelper.Complete(Request.QueryString["data"]);
    MessageHelper.SetSuccess("eSewa sandbox payment verified. Your purchase is saved.");
    Response.Redirect("~/CourseDetails.aspx?id="+course);
   } catch(SqlException){MessageHelper.SetError("The payment could not be saved. Keep your signed return URL and try later.");}
   catch(InvalidOperationException ex){MessageHelper.SetError(ex.Message);}
  }
 }
}
