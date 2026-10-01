using System;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Web.UI;
using LearningSystem.Helpers;
namespace LearningSystem.Payment
{
    // Receipt for a completed payment. Only the learner who paid can open it.
    public partial class EsewaSuccess : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            AccessHelper.RequireRole(new[] { "Learner" });
            Response.Cache.SetNoStore();
            int paymentID = CourseHelper.QueryID("paymentId");
            try
            {
                DataRow payment = PaymentHelper.Find(paymentID);
                if ((string)payment["Status"] != "Complete" || payment.IsNull("VerifiedDate")) { Response.Redirect("EsewaDemo.aspx?paymentId=" + paymentID); return; }
                litCourse.Text = (string)payment["Title"];
                litAmount.Text = UiHelper.Money((decimal)payment["AmountNPR"]);
                litReference.Text = Convert.ToString(payment["ProviderReference"]);
                litDate.Text = ((DateTime)payment["VerifiedDate"]).ToString("d MMMM yyyy, HH:mm", CultureInfo.InvariantCulture) + " UTC";
                lnkCourse.NavigateUrl = "~/Learner/CourseHome.aspx?id=" + payment["CourseID"];
            }
            catch (SqlException) { MessageHelper.SetError("Your receipt could not be loaded. Your payment is safe; see My payments."); }
        }
    }
}
