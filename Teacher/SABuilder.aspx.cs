using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using LearningSystem.Helpers;
namespace LearningSystem.Teacher
{
    public partial class SABuilder : Page
    {
        private int activityID, topicID, courseID;
        private int EditingStatement {get{return (int)(ViewState["StatementID"]??0);}set{ViewState["StatementID"]=value;}}
        protected void Page_Load(object sender, EventArgs e)
        {
            AccessHelper.RequireRole(new[] {"Teacher"});
            bool edit=Request.QueryString["id"]!=null;
            if(edit && Request.QueryString["topicId"]!=null){Response.Redirect("~/AccessDenied.aspx");return;}
            DataRow activity=null;
            if(edit)
            {
                activityID=CourseHelper.QueryID("id");
                if(!AccessHelper.IsOwnerOfActivity(CurrentUserHelper.GetUserID().Value,activityID)){Response.Redirect("~/AccessDenied.aspx");return;}
                activity=ActivityHelper.Find(activityID);
                if(activity==null || (string)activity["ActivityType"]!="SelfAssessment"){Response.Redirect("~/NotFound.aspx");return;}
                topicID=(int)activity["TopicID"];
            }
            else topicID=CourseHelper.QueryID("topicId");
            if(!AccessHelper.IsOwnerOfTopic(CurrentUserHelper.GetUserID().Value,topicID)){Response.Redirect("~/AccessDenied.aspx");return;}
            courseID=Convert.ToInt32(DatabaseHelper.ExecuteScalar("SELECT CourseID FROM dbo.Topic WHERE TopicID=@id",ActivityHelper.ID(topicID)));
            ((SiteMaster)Master).Breadcrumb=edit ? BreadcrumbHelper.ForActivity(activityID) : BreadcrumbHelper.ForCourse(courseID);
            btnDelete.Visible=edit;lnkPreview.Visible=edit;pnlStatements.Visible=edit;pnlSummary.Visible=edit;
            lnkPreview.NavigateUrl="~/Member/SelfAssessment.aspx?id="+activityID+"&preview=1";
            if(!IsPostBack)
            {
                ViewState["SaveToken"]=CurrentUserHelper.CreateEditToken();
                if(edit)
                {
                    txtTitle.Text=(string)activity["Title"];txtDescription.Text=Convert.ToString(activity["Description"]);txtOrder.Text=activity["SortOrder"].ToString();ddlStatus.SelectedValue=(string)activity["Status"];
                    bool locked=ContentLockHelper.HasAttempts(activityID);lblLock.Visible=locked;txtOrder.Enabled=!locked;pnlStatementForm.Visible=!locked;
                    gvStatements.DataSource=SelfAssessmentHelper.Statements(activityID);gvStatements.DataBind();
                    gvSummary.DataSource=SelfAssessmentHelper.Summary(activityID);gvSummary.DataBind();
                    txtStatementOrder.Text=Convert.ToString(DatabaseHelper.ExecuteScalar("SELECT ISNULL(MAX(SortOrder),0)+1 FROM dbo.SAStatement WHERE ActivityID=@id",ActivityHelper.ID(activityID)));
                }
                else txtOrder.Text=Convert.ToString(DatabaseHelper.ExecuteScalar("SELECT ISNULL(MAX(SortOrder),0)+1 FROM dbo.Activity WHERE TopicID=@id",ActivityHelper.ID(topicID)));
            }
        }
        protected void SaveSettings(object sender,EventArgs e)
        {
            if(!Page.IsValid)return;
            if(!CurrentUserHelper.CanSaveEdit(ViewState["SaveToken"])){MessageHelper.SetError("This form expired or was already saved. Reload the page.");return;}
            try
            {
                int order;if(!Int32.TryParse(txtOrder.Text,out order))throw new InvalidOperationException("Enter a positive activity order.");
                int id=ActivityHelper.Save(activityID,topicID,"SelfAssessment",txtTitle.Text.Trim(),txtDescription.Text.Trim(),order,0,0,false,ddlStatus.SelectedValue);
                CurrentUserHelper.CompleteEdit(ViewState["SaveToken"]);MessageHelper.SetSuccess("Self-assessment settings saved.");Response.Redirect("SABuilder.aspx?id="+id);
            }
            catch(InvalidOperationException ex){MessageHelper.SetError(ex.Message);}
            catch(SqlException){MessageHelper.SetError("The settings could not be saved. Please try again.");}
        }
        protected void SaveStatement(object sender,EventArgs e)
        {
            if(!Page.IsValid)return;
            if(!CurrentUserHelper.CanSaveEdit(ViewState["SaveToken"])){MessageHelper.SetError("This form expired or was already saved. Reload the page.");return;}
            try
            {
                int order;if(!Int32.TryParse(txtStatementOrder.Text,out order))throw new InvalidOperationException("Enter a positive statement order.");
                SelfAssessmentHelper.SaveStatement(activityID,EditingStatement,txtStatement.Text.Trim(),order,false);
                CurrentUserHelper.CompleteEdit(ViewState["SaveToken"]);MessageHelper.SetSuccess("Statement saved.");Response.Redirect("SABuilder.aspx?id="+activityID);
            }
            catch(UnauthorizedAccessException){Response.Redirect("~/AccessDenied.aspx");}
            catch(InvalidOperationException ex){MessageHelper.SetError(ex.Message);}
            catch(SqlException){MessageHelper.SetError("The statement could not be saved. Please try again.");}
        }
        protected void StatementCommand(object sender,GridViewCommandEventArgs e)
        {
            if(!Page.IsValid)return;
            int id;if(!Int32.TryParse(Convert.ToString(e.CommandArgument),out id) || id<1){Response.Redirect("~/AccessDenied.aspx");return;}
            try
            {
                DataTable rows=DatabaseHelper.ExecuteTable("SELECT StatementText,SortOrder FROM dbo.SAStatement WHERE StatementID=@statement AND ActivityID=@id",new[] {new SqlParameter("@statement",id),new SqlParameter("@id",activityID)});
                if(rows.Rows.Count!=1){Response.Redirect("~/AccessDenied.aspx");return;}
                if(ContentLockHelper.HasAttempts(activityID)){MessageHelper.SetError("Statements are locked after attempts.");return;}
                if(e.CommandName=="EditStatement") {EditingStatement=id;txtStatement.Text=(string)rows.Rows[0]["StatementText"];txtStatementOrder.Text=rows.Rows[0]["SortOrder"].ToString();}
                else if(e.CommandName=="DeleteStatement")
                {
                    SelfAssessmentHelper.SaveStatement(activityID,id,"",0,true);MessageHelper.SetSuccess("Statement deleted.");Response.Redirect("SABuilder.aspx?id="+activityID);
                }
            }
            catch(UnauthorizedAccessException){Response.Redirect("~/AccessDenied.aspx");}
            catch(InvalidOperationException ex){MessageHelper.SetError(ex.Message);}
            catch(SqlException){MessageHelper.SetError("The statement could not be changed. Please try again.");}
        }
        protected void DeleteAssessment(object sender,EventArgs e)
        {
            if(!Page.IsValid)return;
            if(activityID<1){Response.Redirect("~/AccessDenied.aspx");return;}
            try
            {
                ValidationResult result=DeleteHelper.DeleteActivity(activityID);
                if(!result.IsValid){MessageHelper.SetError(result.Message);return;}
                MessageHelper.SetSuccess(result.Message);Response.Redirect("CourseBuilder.aspx?id="+courseID);
            }
            catch(SqlException){MessageHelper.SetError("The assessment could not be deleted. Please try again.");}
        }
        protected void CancelStatement(object sender,EventArgs e){Response.Redirect("SABuilder.aspx?id="+activityID);}
        protected void Cancel(object sender,EventArgs e){Response.Redirect("CourseBuilder.aspx?id="+courseID);}
    }
}
