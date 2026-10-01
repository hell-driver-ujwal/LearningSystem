using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using LearningSystem.Helpers;
namespace LearningSystem.Payment {
 public partial class EsewaFailure : Page {
  protected void Page_Load(object sender,EventArgs e) {
   AccessHelper.RequireRole(new[]{"Learner"});
   Response.Cache.SetNoStore();
   Response.Headers["Referrer-Policy"]="no-referrer";
   try {
    PaymentHelper.CheckFailure(Request.QueryString["transaction_uuid"]);
    MessageHelper.SetError("The sandbox payment did not complete. No new enrolment was created.");
    Response.Redirect("~/Learner/MyPayments.aspx");
   } catch(SqlException){MessageHelper.SetError("The payment could not be saved. Keep your signed return URL and try later.");}
   catch(InvalidOperationException ex){MessageHelper.SetError(ex.Message);}
  }
 }
}
