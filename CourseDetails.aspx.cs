using System;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Text;
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
                DataRow stats=CourseHelper.Stats(courseID);
                Title=(string)row["Title"];litTitle.Text=Title;litDescription.Text=(string)row["Description"];
                MetaDescription=Shorten((string)row["Description"],155);
                litSubject.Text=(string)row["SubjectName"];
                litPrice.Text=(bool)row["IsPaid"] ? UiHelper.Money((decimal)row["PriceNPR"]) : "Free";
                litMetadata.Text="Last updated "+((DateTime)row["LastUpdated"]).ToString("d MMMM yyyy",CultureInfo.InvariantCulture);
                litFacts.Text=Facts(row,stats);
                litIncludes.Text=Includes(stats);
                litPractice.Text=Practice(stats);
                litContentSummary.Text=UiHelper.Plural((int)stats["Topics"],"topic")+", "+UiHelper.Plural((int)stats["Lessons"],"lesson")+" and "+UiHelper.Plural((int)stats["Activities"],"practice activity","practice activities")+".";
                litLecturer.Text=Lecturer(row);
                imgCover.Visible=!row.IsNull("CoverImagePath");imgCover.ImageUrl="~/Media.ashx?courseId="+courseID;imgCover.AlternateText="Cover image for "+Title;
                ((SiteMaster)Master).Breadcrumb=new[] { new BreadcrumbItem{Text="Home",Url="~/Default.aspx"},new BreadcrumbItem{Text="Courses",Url="~/Courses.aspx"},new BreadcrumbItem{Text=(string)row["SubjectName"],Url="~/Courses.aspx?subjectId="+row["SubjectID"]},new BreadcrumbItem{Text=Title} };
                string role=CurrentUserHelper.GetRole();
                bool paid=(bool)row["IsPaid"];
                if(!CurrentUserHelper.IsAuthenticated())
                {
                    lnkLogin.Visible=true;lnkJoin.Visible=true;lnkLogin.NavigateUrl="~/Account/StudentLogin.aspx?ReturnUrl="+HttpUtility.UrlEncode("~/CourseDetails.aspx?id="+courseID);
                    litEnrolNote.Text="Free preview lessons are open to everyone. Log in as a learner to enrol.";
                }
                else if(role=="Learner")
                {
                    bool enrolled=AccessHelper.IsEnrolled(CurrentUserHelper.GetUserID().Value,courseID);
                    btnEnrol.Text=paid ? "Buy with eSewa" : "Enrol for free";btnEnrol.Visible=!enrolled;lnkStudy.Visible=enrolled;lnkStudy.NavigateUrl="~/Learner/CourseHome.aspx?id="+courseID;
                    litEnrolNote.Text=enrolled ? "You are enrolled. Your progress is saved automatically." : paid ? "One payment gives lasting access, even if you leave and rejoin." : "Free to join. You can leave at any time and keep your results.";
                }
                else litEnrolNote.Text="Lecturer and administrator accounts cannot enrol. Use a learner account to take this course.";
                CourseHelper.Outline(phOutline,courseID,false);
                BindReviews(stats);
            }
            catch(SqlException) { Response.Redirect("~/Error.aspx"); }
        }
        private static string Shorten(string text,int length)
        {
            return text.Length<=length ? text : text.Substring(0,text.LastIndexOf(' ',length-1))+"...";
        }
        private string Facts(DataRow row,DataRow stats)
        {
            StringBuilder html=new StringBuilder("<ul class=\"course-facts\">");
            html.Append("<li>").Append(UiHelper.Icon("user")).Append(CourseHelper.Encode(row["TeacherName"])).Append("</li>");
            html.Append("<li>").Append(UiHelper.Icon("users")).Append(UiHelper.Plural((int)stats["Learners"],"learner")).Append(" enrolled</li>");
            if((int)stats["Reviews"]>0)html.Append("<li>").Append(UiHelper.Icon("star")).Append(Convert.ToDecimal(stats["Rating"]).ToString("0.0",CultureInfo.InvariantCulture)).Append(" from ").Append(UiHelper.Plural((int)stats["Reviews"],"review")).Append("</li>");
            html.Append("<li>").Append(UiHelper.Icon("layers")).Append(UiHelper.Plural((int)stats["Topics"],"topic")).Append("</li></ul>");
            return html.ToString();
        }
        private static string Includes(DataRow stats)
        {
            StringBuilder html=new StringBuilder("<ul class=\"includes\" aria-label=\"This course includes\">");
            Include(html,"book",(int)stats["Lessons"],"lesson","lessons");
            Include(html,"play",(int)stats["MediaLessons"],"video or audio lesson","video and audio lessons");
            Include(html,"code",(int)stats["CodeLabs"],"code lab","code labs");
            Include(html,"quiz",(int)stats["Quizzes"],"quiz","quizzes");
            Include(html,"puzzle",(int)stats["Games"],"learning game","learning games");
            Include(html,"route",(int)stats["Scenarios"],"decision scenario","decision scenarios");
            html.Append("<li>").Append(UiHelper.Icon("award")).Append("Certificate of completion</li></ul>");
            return html.ToString();
        }
        private static void Include(StringBuilder html,string icon,int count,string one,string many)
        {
            if(count>0)html.Append("<li>").Append(UiHelper.Icon(icon)).Append(UiHelper.Plural(count,one,many)).Append("</li>");
        }
        // One card per kind of activity that this course actually contains.
        private static string Practice(DataRow stats)
        {
            StringBuilder html=new StringBuilder("<div class=\"practice-grid\">");
            if((int)stats["Quizzes"]>0)html.Append("<article>").Append(UiHelper.TypeMark("Quiz")).Append("<h3>Quizzes</h3><p>Marked instantly, with every answer explained afterwards.</p></article>");
            if((int)stats["Games"]>0)html.Append("<article>").Append(UiHelper.TypeMark("Game")).Append("<h3>Learning games</h3><p>Quick rounds that turn key terms and steps into practice.</p></article>");
            if((int)stats["CodeLabs"]>0)html.Append("<article>").Append(UiHelper.TypeMark("Code")).Append("<h3>Code labs</h3><p>Edit real code and see the result straight away.</p></article>");
            if((int)stats["Scenarios"]>0)html.Append("<article>").Append(UiHelper.TypeMark("Scenario")).Append("<h3>Scenarios</h3><p>Make choices in a realistic situation and see the outcome.</p></article>");
            html.Append("</div>");
            return html.ToString();
        }
        private static string Lecturer(DataRow row)
        {
            int courses=Convert.ToInt32(DatabaseHelper.ExecuteScalar("SELECT COUNT(*) FROM dbo.Course WHERE TeacherID=@id AND Status='Published'",new[] {new SqlParameter("@id",row["TeacherID"])}));
            string role=(string)row["TeacherRole"]=="Admin" ? "Inkwell learning team" : "Lecturer";
            return "<div class=\"lecturer-card\"><span class=\"avatar large\" aria-hidden=\"true\">"
                +CourseHelper.Encode(UiHelper.Initial((string)row["TeacherName"]))+"</span><span><strong>"+CourseHelper.Encode(row["TeacherName"])+"</strong><br /><span class=\"muted\">"+role+", "+UiHelper.Plural(courses,"published course")+"</span></span></div>";
        }
        protected string Stars(object rating)
        {
            int value=Convert.ToInt32(rating);
            return new string('★',value)+new string('☆',5-value);
        }
        protected void Enrol(object sender,EventArgs e)
        {
            if (!Page.IsValid) return;
            AccessHelper.RequireRole(new[] {"Learner"});
            try
            {
                if (!PaymentHelper.Enrol(courseID)) { Response.Redirect("~/Learner/Checkout.aspx?courseId="+courseID); return; }
                MessageHelper.SetSuccess("You are enrolled. Start with the first lesson below.");Response.Redirect("~/Learner/CourseHome.aspx?id="+courseID);
            }
            catch(SqlException) { MessageHelper.SetError("Enrolment could not be saved. Please try again."); }
            catch(InvalidOperationException ex) { MessageHelper.SetError(ex.Message); }
        }
        private void BindReviews(DataRow stats)
        {
            litRating.Text=(int)stats["Reviews"]==0 ? "Reviews come only from learners enrolled in this course." : "Average "+Convert.ToDecimal(stats["Rating"]).ToString("0.0",CultureInfo.InvariantCulture)+" out of 5 from "+UiHelper.Plural((int)stats["Reviews"],"review")+".";
            lnkCancelReview.NavigateUrl="CourseDetails.aspx?id="+courseID+"#reviews";
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
            int rating;if(!Int32.TryParse(txtRating.Text,out rating)){MessageHelper.SetError("Enter a whole-number rating.");return;}
            try{ReviewHelper.Save(courseID,rating,txtComment.Text);MessageHelper.SetSuccess("Thank you. Your review is saved.");Response.Redirect("CourseDetails.aspx?id="+courseID+"#reviews");}
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
        }
    }
}
