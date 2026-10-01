using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using LearningSystem.Helpers;
namespace LearningSystem.Payment
{
    // A local eSewa-style payment screen: step 1 asks for the mobile number, step 2 for the 4-digit code.
    // The phone number and wrong attempts are kept in the session, never in the page, and every check happens on the server.
    public partial class EsewaDemo : Page
    {
        private int paymentID;
        private DataRow payment;
        private string PhoneKey { get { return "EsewaDemoPhone_" + paymentID; } }
        private string TriesKey { get { return "EsewaDemoTries_" + paymentID; } }

        protected void Page_Load(object sender, EventArgs e)
        {
            AccessHelper.RequireRole(new[] { "Learner" });
            Response.Cache.SetNoStore();
            paymentID = CourseHelper.QueryID("paymentId");
            try
            {
                payment = PaymentHelper.Find(paymentID);
                if ((string)payment["Status"] == "Complete") { Response.Redirect("EsewaSuccess.aspx?paymentId=" + paymentID); return; }
                if ((string)payment["Status"] != "Pending")
                {
                    MessageHelper.SetError("This payment was cancelled or failed. Start a new payment from the course page.");
                    Response.Redirect("~/CourseDetails.aspx?id=" + payment["CourseID"]); return;
                }
                litCourse.Text = (string)payment["Title"];
                litAmount.Text = UiHelper.Money((decimal)payment["AmountNPR"]);
                btnPay.Text = "Pay " + litAmount.Text;
            }
            catch (SqlException) { MessageHelper.SetError("Payments are unavailable right now. You have not been charged."); pnlPhone.Visible = false; }
        }

        protected void SendCode(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;
            string phone = txtPhone.Text.Trim();
            if (!PaymentHelper.IsValidPhone(phone)) { MessageHelper.SetError("Enter a 10-digit mobile number that starts with 97 or 98."); return; }
            Session[PhoneKey] = phone;
            Session[TriesKey] = 0;
            ShowCodeStep(phone);
        }

        protected void Pay(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;
            string phone = Session[PhoneKey] as string;
            if (!PaymentHelper.IsValidPhone(phone)) { MessageHelper.SetError("Your session expired. Enter your mobile number again."); return; }
            string code = txtCode.Text.Trim();
            try
            {
                if (!PaymentHelper.CodeMatches(phone, code))
                {
                    int tries = (Session[TriesKey] as int? ?? 0) + 1;
                    Session[TriesKey] = tries;
                    if (tries >= PaymentHelper.MaxCodeAttempts)
                    {
                        PaymentHelper.CloseDemo(paymentID, true);
                        ClearSession();
                        MessageHelper.SetError("Too many incorrect codes. The payment was stopped and you have not been charged.");
                        Response.Redirect("~/CourseDetails.aspx?id=" + payment["CourseID"]); return;
                    }
                    MessageHelper.SetError("That code is not correct. Please try again.");
                    ShowCodeStep(phone);
                    return;
                }
                int course = PaymentHelper.CompleteDemo(paymentID, phone, code);
                ClearSession();
                MessageHelper.SetSuccess("Payment successful. You are now enrolled in the course.");
                Response.Redirect("EsewaSuccess.aspx?paymentId=" + paymentID);
            }
            catch (InvalidOperationException ex) { MessageHelper.SetError(ex.Message); ShowCodeStep(phone); }
            catch (SqlException) { MessageHelper.SetError("The payment could not be completed. You have not been charged; please try again."); ShowCodeStep(phone); }
        }

        protected void ChangeNumber(object sender, EventArgs e)
        {
            ClearSession();
            pnlCode.Visible = false; pnlPhone.Visible = true;
        }

        protected void CancelPayment(object sender, EventArgs e)
        {
            try { PaymentHelper.CloseDemo(paymentID, false); }
            catch (SqlException) { }
            ClearSession();
            MessageHelper.SetError("Payment cancelled. You have not been charged.");
            Response.Redirect("~/CourseDetails.aspx?id=" + payment["CourseID"]);
        }

        private void ShowCodeStep(string phone)
        {
            pnlPhone.Visible = false; pnlCode.Visible = true;
            litMasked.Text = PaymentHelper.MaskPhone(phone);
            int left = PaymentHelper.MaxCodeAttempts - (Session[TriesKey] as int? ?? 0);
            litAttempts.Text = left + (left == 1 ? " attempt" : " attempts") + " left before the payment is stopped.";
            txtCode.Text = "";
        }

        private void ClearSession()
        {
            Session.Remove(PhoneKey);
            Session.Remove(TriesKey);
        }
    }
}
