// Standalone fixture tool, compiled with the unchanged application helpers; not application code.
using System;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Collections.Generic;
using System.Security.Principal;
using System.Web;
using System.Web.SessionState;
using LearningSystem.Helpers;
class PresentationHistory
{
    static SqlParameter P(string name, object value) { return new SqlParameter(name,value); }
    static DataTable Q(string sql, params SqlParameter[] p) { return DatabaseHelper.ExecuteTable(sql,p); }
    static int N(string sql, params SqlParameter[] p) { return Convert.ToInt32(DatabaseHelper.ExecuteScalar(sql,p)); }
    static void Login(string email)
    {
        DataRow u=Q("SELECT * FROM dbo.[User] WHERE Email=@email",P("@email",email)).Rows[0];
        if((string)u["Status"]!="Active" || !PasswordHelper.VerifyPassword("Password123",(string)u["PasswordHash"])) throw new Exception("Fixture account is not active or its password differs; no password is reset: "+email);
        var context=new HttpContext(new HttpRequest("","https://localhost:44393/Default.aspx",""),new HttpResponse(new StringWriter()));
        HttpContext.Current=context;
        SessionStateUtility.AddHttpSessionStateToContext(context,new HttpSessionStateContainer(Guid.NewGuid().ToString(),new SessionStateItemCollection(),new HttpStaticObjectsCollection(),20,true,HttpCookieMode.UseCookies,SessionStateMode.InProc,false));
        context.User=new GenericPrincipal(new GenericIdentity(Convert.ToString(u["UserID"]),"Forms"),new[]{(string)u["Role"]});
        if(!CurrentUserHelper.IsActive())throw new Exception("Inactive fixture account.");
    }
    static int Course(string code) { return N("SELECT CourseID FROM dbo.Course WHERE Description LIKE @marker",P("@marker","%[[]PRESENTATION-DEMO-V1:"+code+"]%")); }
    static int Activity(int course,string type) { return N("SELECT a.ActivityID FROM dbo.Activity a JOIN dbo.Topic t ON t.TopicID=a.TopicID WHERE t.CourseID=@course AND a.ActivityType=@type",P("@course",course),P("@type",type)); }
    static int Attempts(int id) { return N("SELECT COUNT(*) FROM dbo.Attempt WHERE ActivityID=@id AND LearnerID=@user",P("@id",id),P("@user",CurrentUserHelper.GetUserID().Value)); }
    static void Quiz(int id,int count,int correct)
    {
        while(Attempts(id)<count)
        {
            var answers=new List<QuizSubmissionAnswer>();int index=0;
            foreach(DataRow q in Q("SELECT QuestionID FROM dbo.QuizQuestion WHERE ActivityID=@id ORDER BY SortOrder,QuestionID",P("@id",id)).Rows)
            {
                bool right=Attempts(id)>0 || index++<correct;
                int option=N("SELECT TOP(1) OptionID FROM dbo.QuizOption WHERE QuestionID=@q AND IsCorrect=@right ORDER BY OptionID",P("@q",q["QuestionID"]),P("@right",right));
                answers.Add(new QuizSubmissionAnswer{QuestionID=(int)q["QuestionID"],SelectedOptionID=option});
            }
            var run=QuizHelper.Begin(id,false);QuizHelper.SubmitRun(id,answers.ToArray(),run.Token,false);
        }
    }
    static void SA(int id,int count)
    {
        while(Attempts(id)<count)
        {
            DataTable statements=SelfAssessmentHelper.Statements(id);var ratings=new Dictionary<int,int>();int i=0;
            int[] values=Attempts(id)==0 ? new[]{2,3,3,4} : new[]{4,4,5,5};
            foreach(DataRow s in statements.Rows)ratings.Add((int)s["StatementID"],values[i++%4]);
            decimal average;SelfAssessmentHelper.Submit(id,ratings,SelfAssessmentHelper.Definition(statements),false,out average);
        }
    }
    static void Game(int id)
    {
        if(Attempts(id)>0)return;
        DataTable items=GameHelper.Items(id);string template=Convert.ToString(ActivityHelper.Find(id)["GameTemplate"]);
        var answers=new List<GameAnswer>();
        foreach(DataRow item in items.Rows)
        {
            string value=template=="Matching" ? Convert.ToString(item["ItemID"]) : template=="Sort" ? Convert.ToString(item["GroupID"]) : Convert.ToString(item["ItemText"]);
            if(template!="Memory")answers.Add(new GameAnswer{itemId=(int)item["ItemID"],value=value});
        }
        var run=GameHelper.Begin(id,false);
        GameHelper.Submit(id,run.Token,new GameResult{timeTakenSeconds=0,moves=template=="Memory" ? (int?)items.Rows.Count : null,answers=answers.ToArray()},false);
    }
    static void Complete(int course,int count)
    {
        DataTable materials=Q("SELECT m.MaterialID FROM dbo.Material m JOIN dbo.Topic t ON t.TopicID=m.TopicID WHERE t.CourseID=@course AND m.Status='Published' ORDER BY t.SortOrder,t.TopicID,m.SortOrder,m.MaterialID",P("@course",course));
        for(int i=0;i<Math.Min(count,materials.Rows.Count);i++)
        {
            int material=(int)materials.Rows[i][0];
            if(!AccessHelper.CanAccessMaterial(CurrentUserHelper.GetUserID().Value,material,false))throw new UnauthorizedAccessException();
            DatabaseHelper.ExecuteNonQuery("IF NOT EXISTS(SELECT 1 FROM dbo.MaterialCompletion WHERE LearnerID=@user AND MaterialID=@id) INSERT dbo.MaterialCompletion(LearnerID,MaterialID) VALUES(@user,@id)",new[]{P("@user",CurrentUserHelper.GetUserID().Value),P("@id",material)});
        }
    }
    static void Post(int id,string text)
    {
        if(N("SELECT COUNT(*) FROM dbo.DiscussionPost WHERE ActivityID=@id AND UserID=@user",P("@id",id),P("@user",CurrentUserHelper.GetUserID().Value))==0)DiscussionHelper.Save(id,0,0,text);
    }
    static void Publish(int course)
    {
        foreach(DataRow a in Q("SELECT a.ActivityID,a.ActivityType FROM dbo.Activity a JOIN dbo.Topic t ON t.TopicID=a.TopicID WHERE t.CourseID=@course",P("@course",course)).Rows)
        {
            int id=(int)a[0];string type=(string)a[1];ValidationResult check=type=="Quiz" ? PublishHelper.CheckQuiz(id) : type=="SelfAssessment" ? PublishHelper.CheckSelfAssessment(id) : type=="Game" ? PublishHelper.CheckGame(id) : type=="Scenario" ? PublishHelper.CheckScenario(id) : null;
            if(check!=null && !check.IsValid)throw new Exception(type+": "+check.Message);
            DatabaseHelper.ExecuteNonQuery("UPDATE dbo.Activity SET Status='Published' WHERE ActivityID=@id AND Status='Draft'",new[]{P("@id",id)});
        }
        var result=PublishHelper.CheckCourse(course);if(!result.IsValid)throw new Exception(result.Message);
        DatabaseHelper.ExecuteNonQuery("UPDATE dbo.Course SET Status='Published',LastUpdated=SYSUTCDATETIME() WHERE CourseID=@id AND Status='Draft'",new[]{P("@id",course)});
    }
    static int Main(string[] args)
    {
        try
        {
            DatabaseHelper.ExecuteNonQuery(File.ReadAllText(args[0]),null);
            int web=Course("web"),db=Course("db"),safe=Course("safe"),biz=Course("biz");
            foreach(int c in new[]{web,db,safe,biz})Publish(c);
            string[] emails={"ben.learner@example.test","chandra.learner@example.test","anita.learner@example.test","dina.learner@example.test"};int[] completions={2,6,11,13};
            for(int i=0;i<emails.Length;i++)
            {
                Login(emails[i]);PaymentHelper.Enrol(web);Complete(web,completions[i]);
                if(i>0)Quiz(Activity(web,"Quiz"),i==3 ? 2 : 1,i==1 ? 2 : 3);
                if(i>=2){SA(Activity(web,"SelfAssessment"),i==3 ? 2 : 1);Game(Activity(web,"Game"));}
                if(i==1 || i==3)Post(Activity(web,"Discussion"),i==1 ? "I tested the registration form with only the keyboard. Clear labels made the input order much easier to understand." : "My final page uses meaningful headings and image alternatives. I checked the narrow layout before marking the course complete.");
                if(i==3)
                {
                    int discussion=Activity(web,"Discussion");
                    int parent=N("SELECT TOP(1) PostID FROM dbo.DiscussionPost WHERE ActivityID=@id AND ParentPostID IS NULL AND UserID<>@user ORDER BY PostID",P("@id",discussion),P("@user",CurrentUserHelper.GetUserID().Value));
                    if(parent>0 && N("SELECT COUNT(*) FROM dbo.DiscussionPost WHERE ParentPostID=@parent AND UserID=@user",P("@parent",parent),P("@user",CurrentUserHelper.GetUserID().Value))==0)DiscussionHelper.Save(discussion,0,parent,"I agree. I also added a visible focus outline so someone using Tab can see which control will receive their input.");
                }
                if(i==1 || i==2){PaymentHelper.Enrol(db);Complete(db,3);Quiz(Activity(db,"Quiz"),1,3);Game(Activity(db,"Game"));}
                if(i==3)
                {
                    if(N("SELECT COUNT(*) FROM dbo.Payment WHERE LearnerID=@user AND CourseID=@course AND Status='Complete'",P("@user",CurrentUserHelper.GetUserID().Value),P("@course",safe))==0)PaymentHelper.CompleteDemo(PaymentHelper.CreatePending(safe),"9841234567","4567");
                    PaymentHelper.Enrol(safe);Complete(safe,4);Game(Activity(safe,"Game"));
                    int scenario=Activity(safe,"Scenario");
                    if(Attempts(scenario)==0)
                    {
                        ScenarioHelper.Begin(scenario,false);
                        for(int turn=0;turn<6 && !ScenarioHelper.Run(scenario,false).Completed;turn++)
                        {
                            var run=ScenarioHelper.Run(scenario,false);
                            int choice=N("SELECT TOP(1) ChoiceID FROM dbo.SimChoice WHERE FromStepID=@step ORDER BY ChoiceID",P("@step",run.CurrentStepID));
                            ScenarioHelper.Move(scenario,false,run.Token,run.Revision,choice,false);
                        }
                        if(!ScenarioHelper.Run(scenario,false).Completed)throw new Exception("Scenario fixture did not reach an ending.");
                    }
                    foreach(string outcome in new[]{"Acceptable","Poor"})
                    {
                        if(N("SELECT COUNT(*) FROM dbo.Attempt a JOIN dbo.SimStep s ON s.StepID=a.EndingStepID WHERE a.ActivityID=@id AND a.LearnerID=@user AND s.Outcome=@outcome",P("@id",scenario),P("@user",CurrentUserHelper.GetUserID().Value),P("@outcome",outcome))>0)continue;
                        ScenarioHelper.Begin(scenario,false);var run=ScenarioHelper.Run(scenario,false);
                        int choice=N("SELECT TOP(1) c.ChoiceID FROM dbo.SimChoice c JOIN dbo.SimStep s ON s.StepID=c.NextStepID WHERE c.FromStepID=@step AND s.Outcome=@outcome ORDER BY c.ChoiceID",P("@step",run.CurrentStepID),P("@outcome",outcome));
                        if(choice==0)throw new Exception("Expected a direct fixture ending choice.");
                        ScenarioHelper.Move(scenario,false,run.Token,run.Revision,choice,false);
                    }
                }
                if(i==0 && N("SELECT COUNT(*) FROM dbo.Payment WHERE LearnerID=@user AND CourseID=@course",P("@user",CurrentUserHelper.GetUserID().Value),P("@course",biz))==0)PaymentHelper.CreatePending(biz);
                if(i==1 && N("SELECT COUNT(*) FROM dbo.Payment WHERE LearnerID=@user AND CourseID=@course",P("@user",CurrentUserHelper.GetUserID().Value),P("@course",biz))==0)PaymentHelper.CloseDemo(PaymentHelper.CreatePending(biz),false);
                if(i>0 && N("SELECT COUNT(*) FROM dbo.Review WHERE LearnerID=@user AND CourseID=@course",P("@user",CurrentUserHelper.GetUserID().Value),P("@course",web))==0)ReviewHelper.Save(web,i==3 ? 5 : 4,"The step-by-step examples helped me practise accessible page structure and review my work at a realistic pace.");
                int bookmark=N("SELECT TOP(1) m.MaterialID FROM dbo.Material m JOIN dbo.Topic t ON t.TopicID=m.TopicID WHERE t.CourseID=@course ORDER BY m.MaterialID DESC",P("@course",web));BookmarkHelper.Set(bookmark,true);
                Console.WriteLine(emails[i]+" | Web progress "+ProgressHelper.CalculatePercent(CurrentUserHelper.GetUserID().Value,web)+"%");
            }
            Console.WriteLine("Courses: web="+web+", db="+db+", safe="+safe+", biz="+biz);return 0;
        }
        catch(Exception e){Console.Error.WriteLine(e.ToString());return 1;}
    }
}

