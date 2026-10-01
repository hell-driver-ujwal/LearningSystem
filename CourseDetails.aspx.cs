using System;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;
using LearningSystem.Helpers;
namespace LearningSystem
{
    public partial class CourseDetails : Page
    {
        private int courseID;
        protected void Page_Load(object sender,EventArgs e)
        {
            courseID=CourseHelper.QueryID("id");
            try
            {
                DataRow row=CourseHelper.Find(courseID);
                if(row==null || (string)row["Status"]!="Published") { Response.Redirect("~/NotFound.aspx"); return; }
                Title=(string)row["Title"];litTitle.Text=Title;litDescription.Text=(string)row["Description"];
                litMetadata.Text=PaymentHelper.Price(row)+" · "+row["SubjectName"]+" · Teacher: "+row["TeacherName"]+" · Last updated: "+((DateTime)row["LastUpdated"]).ToString("yyyy-MM-dd HH:mm")+" UTC";
                imgCover.Visible=!row.IsNull("CoverImagePath");imgCover.ImageUrl="~/Media.ashx?courseId="+courseID;imgCover.AlternateText=Title;
                ((SiteMaster)Master).Breadcrumb=new[] { new BreadcrumbItem{Text="Home",Url="~/Default.aspx"},new BreadcrumbItem{Text="Courses",Url="~/Courses.aspx"},new BreadcrumbItem{Text=Title} };
                string role=CurrentUserHelper.GetRole();
                lnkLogin.Visible=!CurrentUserHelper.IsAuthenticated();lnkLogin.NavigateUrl="~/Account/StudentLogin.aspx?ReturnUrl="+HttpUtility.UrlEncode("~/CourseDetails.aspx?id="+courseID);
                if(role=="Learner")
                {
                    bool enrolled=AccessHelper.IsEnrolled(CurrentUserHelper.GetUserID().Value,courseID);
                    btnEnrol.Text=(bool)row["IsPaid"] ? "Buy / Enrol with eSewa" : "Enrol";btnEnrol.Visible=!enrolled;lnkStudy.Visible=enrolled;lnkStudy.NavigateUrl="~/Learner/CourseHome.aspx?id="+courseID;
                }
                CourseHelper.Outline(phOutline,courseID,false);
                BindReviews();
            }
            catch(SqlException) { Response.Redirect("~/Error.aspx"); }
        }
        protected void Enrol(object sender,EventArgs e)
        {
            if (!Page.IsValid) return;
            AccessHelper.RequireRole(new[] {"Learner"});
            try
            {
                if (!PaymentHelper.Enrol(courseID)) { Response.Redirect("~/Learner/Checkout.aspx?courseId="+courseID); return; }
                MessageHelper.SetSuccess("You are enrolled in this course.");Response.Redirect("~/Learner/CourseHome.aspx?id="+courseID);
            }
            catch(SqlException) { MessageHelper.SetError("Enrolment could not be saved. Please try again."); }
            catch(InvalidOperationException ex) { MessageHelper.SetError(ex.Message); }
        }
        private void BindReviews()
        {
            litRating.Text=ReviewHelper.Average(courseID);lnkCancelReview.NavigateUrl="CourseDetails.aspx?id="+courseID;
            if(CurrentUserHelper.GetRole()=="Learner")
            {
                AccessHelper.RequireRole(new[] {"Learner"});
                pnlReview.Visible=AccessHelper.IsEnrolled(CurrentUserHelper.GetUserID().Value,courseID);
            }
            txtComment.Text=txtComment.Text.Trim();
            if(IsPostBack)return;
            DataTable reviews=ReviewHelper.List(courseID);rptReviews.DataSource=reviews;rptReviews.DataBind();lblNoReviews.Visible=reviews.Rows.Count==0;
            foreach(DataRow review in reviews.Rows)
            {
                if(pnlReview.Visible && (int)review["LearnerID"]==CurrentUserHelper.GetUserID().Value)
                {txtRating.Text=Convert.ToString(review["Rating"]);txtComment.Text=(string)review["Comment"];ViewState["ReviewID"]=review["ReviewID"];btnDeleteReview.Visible=true;break;}
            }
        }
        protected void SaveReview(object sender,EventArgs e)
        {
            if(!Page.IsValid)return;
            int rating;if(!Int32.TryParse(txtRating.Text,out rating)){MessageHelper.SetError("Enter an integer rating.");return;}
            try{ReviewHelper.Save(courseID,rating,txtComment.Text);MessageHelper.SetSuccess("Review saved.");Response.Redirect("CourseDetails.aspx?id="+courseID+"#reviews");}
            catch(UnauthorizedAccessException){Response.Redirect("~/AccessDenied.aspx");}
            catch(ArgumentException ex){MessageHelper.SetError(ex.Message);}
            catch(SqlException){MessageHelper.SetError("Review could not be saved.");}
        }
        protected void DeleteReview(object sender,EventArgs e)
        {
            if(!Page.IsValid)return;
            try{ReviewHelper.Delete(Convert.ToInt32(ViewState["ReviewID"]),courseID,false);MessageHelper.SetSuccess("Review deleted.");Response.Redirect("CourseDetails.aspx?id="+courseID+"#reviews");}
            catch(UnauthorizedAccessException){Response.Redirect("~/AccessDenied.aspx");}
            catch(SqlException){MessageHelper.SetError("Review could not be deleted.");}
        }    }
}
