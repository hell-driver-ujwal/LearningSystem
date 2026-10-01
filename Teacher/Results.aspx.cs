using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using LearningSystem.Helpers;
namespace LearningSystem.Teacher
{
    public partial class Results : Page
    {
        private const bool TeacherView=true;
        protected void Page_Load(object sender,EventArgs e)
        {
            AccessHelper.RequireRole(new[] {"Teacher"});
            try
            {
                int course=ResultsHelper.FilterID(Request.QueryString["courseId"]),activity=ResultsHelper.FilterID(Request.QueryString["activityId"]);
                ResultsHelper.RequireFilters(TeacherView,course,activity);
                if(IsPostBack)
                {
                    // Validate each posted selection before handling filter changes or paging.
                    ResultsHelper.RequireFilters(TeacherView,ResultsHelper.FilterID(ddlCourse.SelectedValue),0);
                    ResultsHelper.RequireFilters(TeacherView,0,ResultsHelper.FilterID(ddlActivity.SelectedValue));
                }
                else
                {
                    ddlCourse.DataSource=ResultsHelper.Courses(TeacherView);ddlCourse.DataTextField="Title";ddlCourse.DataValueField="CourseID";ddlCourse.DataBind();ddlCourse.Items.Insert(0,new ListItem("All courses",""));
                    if(course>0)ddlCourse.SelectedValue=course.ToString();BindActivities(course);
                    if(activity>0)ddlActivity.SelectedValue=activity.ToString();BindResults();
                }
            }
            catch(UnauthorizedAccessException){Response.Redirect("~/AccessDenied.aspx");}
            catch(SqlException){MessageHelper.SetError("Results could not be loaded. Please try again.");}
        }
        private void BindActivities(int course)
        {
            ddlActivity.DataSource=ResultsHelper.Activities(TeacherView,course);ddlActivity.DataTextField="Label";ddlActivity.DataValueField="ActivityID";ddlActivity.DataBind();ddlActivity.Items.Insert(0,new ListItem("All activities",""));
        }
        private void BindResults()
        {
            int course=ResultsHelper.FilterID(ddlCourse.SelectedValue),activity=ResultsHelper.FilterID(ddlActivity.SelectedValue);
            ResultsHelper.RequireFilters(TeacherView,course,activity);
            DataTable rows=ResultsHelper.Attempts(TeacherView,course,activity);
            litCharts.Text=ChartHelper.ScoreSpread(rows);
            if(gvResults.PageIndex*gvResults.PageSize>=rows.Rows.Count)gvResults.PageIndex=0;
            gvResults.DataSource=rows;gvResults.DataBind();gvScores.DataSource=ResultsHelper.ScoreSummary(TeacherView,course,activity);gvScores.DataBind();
                        pnlSA.Visible=false;pnlScenario.Visible=false;
            int selectedCourse=course;
            if(activity>0)
            {
                DataRow a=ActivityHelper.Find(activity);selectedCourse=(int)a["CourseID"];
                if((string)a["ActivityType"]=="SelfAssessment"){pnlSA.Visible=true;gvSA.DataSource=SelfAssessmentHelper.Summary(activity);gvSA.DataBind();}
                if((string)a["ActivityType"]=="Scenario"){pnlScenario.Visible=true;gvScenario.DataSource=ScenarioHelper.Summary(activity);gvScenario.DataBind();}
            }
            lnkLearners.Visible=selectedCourse>0;lnkLearners.NavigateUrl="CourseLearners.aspx?id="+selectedCourse;
        }
        protected void CourseChanged(object sender,EventArgs e)
        {
            try{int course=ResultsHelper.FilterID(ddlCourse.SelectedValue);ResultsHelper.RequireFilters(TeacherView,course,0);Response.Redirect(ResultsHelper.FilterUrl("Results.aspx",course,0));}
            catch(UnauthorizedAccessException){Response.Redirect("~/AccessDenied.aspx");}
        }
        protected void ApplyFilters(object sender,EventArgs e)
        {
            if(!Page.IsValid)return;
            try{int course=ResultsHelper.FilterID(ddlCourse.SelectedValue),activity=ResultsHelper.FilterID(ddlActivity.SelectedValue);ResultsHelper.RequireFilters(TeacherView,course,activity);Response.Redirect(ResultsHelper.FilterUrl("Results.aspx",course,activity));}
            catch(UnauthorizedAccessException){Response.Redirect("~/AccessDenied.aspx");}
            catch(SqlException){MessageHelper.SetError("Filters could not be applied. Please try again.");}
        }
        protected void ChangePage(object sender,GridViewPageEventArgs e)
        {
            try{gvResults.PageIndex=e.NewPageIndex;BindResults();}
            catch(UnauthorizedAccessException){Response.Redirect("~/AccessDenied.aspx");}
            catch(SqlException){MessageHelper.SetError("Results could not be loaded. Please try again.");}
        }
        protected void ClearFilters(object sender,EventArgs e){Response.Redirect("Results.aspx");}
    }
}

