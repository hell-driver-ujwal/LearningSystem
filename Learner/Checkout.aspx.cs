using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using LearningSystem.Helpers;
namespace LearningSystem.Learner
{
    public partial class Checkout : Page
    {
        private int courseID;
        protected void Page_Load(object sender,EventArgs e)
        {
            AccessHelper.RequireRole(new[]{"Learner"});
            courseID=CourseHelper.QueryID("courseId");
            try
            {
                DataRow course=CourseHelper.Find(courseID);
                if(course==null || (string)course["Status"]!="Published"){Response.Redirect("~/NotFound.aspx");return;}
                lnkCancel.NavigateUrl="~/CourseDetails.aspx?id="+courseID;
                if(AccessHelper.IsEnrolled(CurrentUserHelper.GetUserID().Value,courseID)){Response.Redirect("~/Learner/CourseHome.aspx?id="+courseID);return;}
                if(!(bool)course["IsPaid"]){Response.Redirect(lnkCancel.NavigateUrl);return;}
                litCourse.Text=(string)course["Title"];litTeacher.Text="By "+course["TeacherName"];
                litAmount.Text=PaymentHelper.Price(course);litTotal.Text=litAmount.Text;
                imgCover.Visible=!course.IsNull("CoverImagePath");imgCover.ImageUrl="~/Media.ashx?courseId="+courseID;imgCover.AlternateText="Cover image for "+course["Title"];
                if(!IsPostBack)ViewState["PaymentToken"]=CurrentUserHelper.CreateEditToken();
            }
            catch(SqlException){MessageHelper.SetError("Checkout is unavailable. Please try later.");btnBegin.Enabled=false;}
        }
        protected void BeginPayment(object sender,EventArgs e)
        {
            if(!Page.IsValid)return;
            if(!CurrentUserHelper.CanSaveEdit(ViewState["PaymentToken"])){MessageHelper.SetError("Reload this page before starting another payment.");return;}
            try
            {
                // A learner who already paid (for example, left and is rejoining) is enrolled without paying again.
                if(PaymentHelper.Enrol(courseID)){MessageHelper.SetSuccess("You already own this course. It is open again.");Response.Redirect("~/Learner/CourseHome.aspx?id="+courseID);return;}
                int paymentID=PaymentHelper.CreatePending(courseID);CurrentUserHelper.CompleteEdit(ViewState["PaymentToken"]);
                Response.Redirect("~/Payment/EsewaDemo.aspx?paymentId="+paymentID);
            }
            catch(SqlException){MessageHelper.SetError("The payment could not be started. Please try later.");}
            catch(InvalidOperationException ex){MessageHelper.SetError(ex.Message);}
        }
    }
}
