using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using LearningSystem.Helpers;
namespace LearningSystem.Teacher
{
    public partial class QuizBuilder : Page
    {
        private static readonly string Kind="Quiz";
        private int activityID,topicID,courseID;
        protected void Page_Load(object sender,EventArgs e)
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
                if((string)activity["ActivityType"]!=Kind){Response.Redirect("~/NotFound.aspx");return;}
                topicID=(int)activity["TopicID"];
            }
            else topicID=CourseHelper.QueryID("topicId");
            if(!AccessHelper.IsOwnerOfTopic(CurrentUserHelper.GetUserID().Value,topicID)){Response.Redirect("~/AccessDenied.aspx");return;}
            courseID=Convert.ToInt32(DatabaseHelper.ExecuteScalar("SELECT CourseID FROM dbo.Topic WHERE TopicID=@id",ActivityHelper.ID(topicID)));
            ((SiteMaster)Master).Breadcrumb=edit ? BreadcrumbHelper.ForActivity(activityID) : BreadcrumbHelper.ForCourse(courseID);
            pnlQuiz.Visible=Kind=="Quiz";pnlClosed.Visible=Kind=="Discussion";
            btnDelete.Visible=edit;lnkPreview.Visible=edit;lnkPreview.NavigateUrl="~/Member/"+(Kind=="Quiz" ? "Quiz" : "Discussion")+".aspx?id="+activityID+"&preview=1";
            if(!IsPostBack)
            {
                ViewState["SaveToken"]=CurrentUserHelper.CreateEditToken();
                if(edit)
                {
                    txtTitle.Text=(string)activity["Title"];txtDescription.Text=Convert.ToString(activity["Description"]);txtOrder.Text=activity["SortOrder"].ToString();ddlStatus.SelectedValue=(string)activity["Status"];
                    if(Kind=="Quiz")
                    {
                        txtMinutes.Text=activity["TimeLimitMinutes"].ToString();txtAttempts.Text=activity["MaxAttempts"].ToString();
                        bool locked=ContentLockHelper.HasAttempts(activityID);txtMinutes.Enabled=!locked;txtAttempts.Enabled=!locked;txtOrder.Enabled=!locked;lblLock.Visible=locked;
                    }
                    else chkClosed.Checked=(bool)activity["IsClosed"];
                }
                else txtOrder.Text=Convert.ToString(DatabaseHelper.ExecuteScalar("SELECT ISNULL(MAX(SortOrder),0)+1 FROM dbo.Activity WHERE TopicID=@id",ActivityHelper.ID(topicID)));
                BindQuestions();
            }
        }
        protected void SaveSettings(object sender,EventArgs e)
        {
            if(!Page.IsValid)return;
            if(!CurrentUserHelper.CanSaveEdit(ViewState["SaveToken"])){MessageHelper.SetError("This form expired or was already saved. Reload the page.");return;}
            try
            {
                int order,minutes=0,attempts=0;
                if(!Int32.TryParse(txtOrder.Text,out order) || (Kind=="Quiz" && (!Int32.TryParse(txtMinutes.Text,out minutes) || !Int32.TryParse(txtAttempts.Text,out attempts))))throw new InvalidOperationException("Enter valid settings and order.");
                int id=ActivityHelper.Save(activityID,topicID,Kind,txtTitle.Text.Trim(),txtDescription.Text.Trim(),order,minutes,attempts,chkClosed.Checked,ddlStatus.SelectedValue);
                CurrentUserHelper.CompleteEdit(ViewState["SaveToken"]);MessageHelper.SetSuccess("Activity settings saved.");Response.Redirect("QuizBuilder.aspx?id="+id);
            }
            catch(InvalidOperationException ex){MessageHelper.SetError(ex.Message);}
            catch(SqlException){MessageHelper.SetError("Settings could not be saved. Check the values and try again.");}
        }
        protected void DeleteActivity(object sender,EventArgs e)
        {
            if(!Page.IsValid)return;
            try
            {
                ValidationResult result=DeleteHelper.DeleteActivity(activityID);
                if(!result.IsValid){MessageHelper.SetError(result.Message);return;}
                MessageHelper.SetSuccess(result.Message);Response.Redirect("CourseBuilder.aspx?id="+courseID);
            }
            catch(SqlException){MessageHelper.SetError("Activity could not be deleted. Please try again.");}
        }
        protected void Cancel(object sender,EventArgs e){Response.Redirect("CourseBuilder.aspx?id="+courseID);}
                private int EditingQuestion {get{return (int)(ViewState["Question"]??0);}set{ViewState["Question"]=value;}}
        private void BindQuestions()
        {
            pnlQuestions.Visible=activityID>0;lnkCancelQuestion.NavigateUrl="QuizBuilder.aspx?id="+activityID;
            if(activityID==0)return;
            bool locked=ContentLockHelper.HasAttempts(activityID);pnlQuestionForm.Visible=!locked;
            gvQuestions.DataSource=DatabaseHelper.ExecuteTable("SELECT QuestionID,QuestionText,Marks,SortOrder FROM dbo.QuizQuestion WHERE ActivityID=@id ORDER BY SortOrder,QuestionID",ActivityHelper.ID(activityID));gvQuestions.DataBind();
            txtQuestionOrder.Text=Convert.ToString(DatabaseHelper.ExecuteScalar("SELECT ISNULL(MAX(SortOrder),0)+1 FROM dbo.QuizQuestion WHERE ActivityID=@id",ActivityHelper.ID(activityID)));
        }
        protected void QuestionCommand(object sender,GridViewCommandEventArgs e)
        {
            if(!Page.IsValid)return;
            int id;if(!Int32.TryParse(Convert.ToString(e.CommandArgument),out id)){Response.Redirect("~/AccessDenied.aspx");return;}
            DataTable rows=DatabaseHelper.ExecuteTable("SELECT * FROM dbo.QuizQuestion WHERE QuestionID=@question AND ActivityID=@id",new[] {new SqlParameter("@question",id),new SqlParameter("@id",activityID)});
            if(rows.Rows.Count!=1){Response.Redirect("~/AccessDenied.aspx");return;}
            if(ContentLockHelper.HasAttempts(activityID)){MessageHelper.SetError("Quiz structure is locked after attempts.");return;}
            if(e.CommandName=="EditQuestion")
            {
                EditingQuestion=id;DataRow q=rows.Rows[0];txtQuestion.Text=(string)q["QuestionText"];txtMarks.Text=q["Marks"].ToString();txtQuestionOrder.Text=q["SortOrder"].ToString();
                var options=DatabaseHelper.ExecuteTable("SELECT OptionText,IsCorrect FROM dbo.QuizOption WHERE QuestionID=@id ORDER BY OptionID",ActivityHelper.ID(id));
                TextBox[] fields={txtOption1,txtOption2,txtOption3,txtOption4,txtOption5,txtOption6};foreach(TextBox field in fields)field.Text="";
                for(int i=0;i<options.Rows.Count;i++){fields[i].Text=(string)options.Rows[i]["OptionText"];if((bool)options.Rows[i]["IsCorrect"])ddlCorrect.SelectedValue=(i+1).ToString();}
            }
            else if(e.CommandName=="DeleteQuestion")
            {
                try{ActivityHelper.SaveQuestion(activityID,id,"",0,0,new string[0],0,true);MessageHelper.SetSuccess("Question deleted.");Response.Redirect("QuizBuilder.aspx?id="+activityID);}
                catch(InvalidOperationException ex){MessageHelper.SetError(ex.Message);}
                catch(SqlException){MessageHelper.SetError("Question could not be deleted.");}
            }
        }
        protected void ValidateOptions(object sender,ServerValidateEventArgs e)
        {
            TextBox[] fields={txtOption1,txtOption2,txtOption3,txtOption4,txtOption5,txtOption6};
            var options=new System.Collections.Generic.HashSet<string>(StringComparer.OrdinalIgnoreCase);
            int selected;e.IsValid=Int32.TryParse(ddlCorrect.SelectedValue,out selected) && selected>=1 && selected<=6;
            foreach(TextBox field in fields) {string text=field.Text.Trim();if(text.Length>0 && (text.Length>200 || !options.Add(text)))e.IsValid=false;}
            e.IsValid=e.IsValid && options.Count>=2 && fields[selected-1].Text.Trim().Length>0;
        }
        protected void SaveQuestion(object sender,EventArgs e)
        {
            if(!Page.IsValid)return;
            if(!CurrentUserHelper.CanSaveEdit(ViewState["SaveToken"])){MessageHelper.SetError("This form expired or was already saved. Reload the page.");return;}
            try
            {
                int marks,order,selected;
                if(!Int32.TryParse(txtMarks.Text,out marks) || !Int32.TryParse(txtQuestionOrder.Text,out order) || !Int32.TryParse(ddlCorrect.SelectedValue,out selected))throw new InvalidOperationException("Check question settings.");
                TextBox[] fields={txtOption1,txtOption2,txtOption3,txtOption4,txtOption5,txtOption6};
                var options=new System.Collections.Generic.List<string>();int correct=-1;
                for(int i=0;i<fields.Length;i++){string text=fields[i].Text.Trim();if(text.Length==0)continue;if(selected==i+1)correct=options.Count;options.Add(text);}
                ActivityHelper.SaveQuestion(activityID,EditingQuestion,txtQuestion.Text.Trim(),marks,order,options.ToArray(),correct,false);
                CurrentUserHelper.CompleteEdit(ViewState["SaveToken"]);MessageHelper.SetSuccess("Question saved.");Response.Redirect("QuizBuilder.aspx?id="+activityID);
            }
            catch(InvalidOperationException ex){MessageHelper.SetError(ex.Message);}
            catch(SqlException){MessageHelper.SetError("Question could not be saved. Check that options are distinct.");}
        }
    }
}



