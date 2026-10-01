using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using LearningSystem.Helpers;
namespace LearningSystem.Learner {
 public partial class Checkout : Page {
  private int courseID;
  protected void Page_Load(object sender,EventArgs e) {
   AccessHelper.RequireRole(new[]{"Learner"});
   courseID=CourseHelper.QueryID("courseId");
   try {
    DataRow course=CourseHelper.Find(courseID);
    if(course==null || (string)course["Status"]!="Published") {Response.Redirect("~/NotFound.aspx");return;}
    lnkCancel.NavigateUrl="~/CourseDetails.aspx?id="+courseID;
    litCourse.Text=(string)course["Title"];litAmount.Text=PaymentHelper.Price(course);
    if(AccessHelper.IsEnrolled(CurrentUserHelper.GetUserID().Value,courseID)){Response.Redirect("~/Learner/CourseHome.aspx?id="+courseID);return;}
    if(!(bool)course["IsPaid"]){Response.Redirect(lnkCancel.NavigateUrl);return;}
    if(!IsPostBack) ViewState["PaymentToken"]=CurrentUserHelper.CreateEditToken();
    if(Request.QueryString["paymentId"]!=null) {
     int id=CourseHelper.QueryID("paymentId");DataRow payment=PaymentHelper.Find(id);
     if((int)payment["CourseID"]!=courseID){Response.Redirect("~/AccessDenied.aspx");return;}
     litAmount.Text="NPR "+((decimal)payment["AmountNPR"]).ToString("N2",System.Globalization.CultureInfo.InvariantCulture)+" (transaction price)";
     litStatus.Text="Status: "+payment["Status"];btnBegin.Visible=false;
     if((string)payment["Status"]=="Pending") litPaymentForm.Text=PaymentHelper.RequestForm(payment);
    }
   } catch(SqlException){MessageHelper.SetError("Checkout is unavailable. Please try later.");btnBegin.Enabled=false;}
   catch(InvalidOperationException ex){MessageHelper.SetError(ex.Message);}
  }
  protected void BeginPayment(object sender,EventArgs e) {
   if(!Page.IsValid)return;
   if(!CurrentUserHelper.CanSaveEdit(ViewState["PaymentToken"])) {MessageHelper.SetError("Reload checkout before starting another payment.");return;}
   try {
    if(PaymentHelper.Enrol(courseID)){MessageHelper.SetSuccess("Your course access is ready. No new payment was needed.");Response.Redirect("~/Learner/CourseHome.aspx?id="+courseID);return;}
    int paymentID=PaymentHelper.CreatePending(courseID);CurrentUserHelper.CompleteEdit(ViewState["PaymentToken"]);
    Response.Redirect("Checkout.aspx?courseId="+courseID+"&paymentId="+paymentID);
   } catch(SqlException){MessageHelper.SetError("The payment could not be started. Please try later.");}
   catch(InvalidOperationException ex){MessageHelper.SetError(ex.Message);}
  }
 }
}
