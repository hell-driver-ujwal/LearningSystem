using System;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Web;
namespace LearningSystem.Helpers
{
    internal static class ResultsHelper
    {
        internal static int FilterID(string value)
        {
            if(String.IsNullOrEmpty(value))return 0;
            int id;if(!Int32.TryParse(value,out id) || id<1)throw new UnauthorizedAccessException();return id;
        }
        internal static void RequireFilters(bool teacher,int course,int activity)
        {
            AccessHelper.RequireRole(teacher ? CurrentUserHelper.AuthorRoles : new[] {"Learner"});int user=CurrentUserHelper.GetUserID().Value;
            if(course>0)
            {
                bool allowed=teacher ? AccessHelper.IsOwnerOfCourse(user,course) : Convert.ToInt32(DatabaseHelper.ExecuteScalar("SELECT COUNT(*) FROM dbo.Attempt x JOIN dbo.Activity a ON a.ActivityID=x.ActivityID JOIN dbo.Topic t ON t.TopicID=a.TopicID WHERE x.LearnerID=@user AND t.CourseID=@course",new[] {new SqlParameter("@user",user),new SqlParameter("@course",course)}))>0;
                if(!allowed)throw new UnauthorizedAccessException();
            }
            if(activity>0)
            {
                DataRow a=ActivityHelper.Find(activity);
                bool allowed=teacher ? AccessHelper.IsOwnerOfActivity(user,activity) : Convert.ToInt32(DatabaseHelper.ExecuteScalar("SELECT COUNT(*) FROM dbo.Attempt WHERE LearnerID=@user AND ActivityID=@id",new[] {new SqlParameter("@user",user),new SqlParameter("@id",activity)}))>0;
                if(a==null || (string)a["ActivityType"]=="Discussion" || !allowed || (course>0 && (int)a["CourseID"]!=course))throw new UnauthorizedAccessException();
            }
        }
        internal static DataTable Courses(bool teacher)
        {
            RequireFilters(teacher,0,0);
            return DatabaseHelper.ExecuteTable(teacher ? "SELECT CourseID,Title FROM dbo.Course WHERE TeacherID=@user ORDER BY Title,CourseID" : "SELECT DISTINCT c.CourseID,c.Title FROM dbo.Attempt x JOIN dbo.Activity a ON a.ActivityID=x.ActivityID JOIN dbo.Topic t ON t.TopicID=a.TopicID JOIN dbo.Course c ON c.CourseID=t.CourseID WHERE x.LearnerID=@user ORDER BY c.Title,c.CourseID",new[] {new SqlParameter("@user",CurrentUserHelper.GetUserID().Value)});
        }
        internal static DataTable Activities(bool teacher,int course)
        {
            RequireFilters(teacher,course,0);
            string restriction=teacher ? "c.TeacherID=@user" : "EXISTS(SELECT 1 FROM dbo.Attempt x WHERE x.ActivityID=a.ActivityID AND x.LearnerID=@user)";
            return DatabaseHelper.ExecuteTable("SELECT a.ActivityID,c.Title+' / '+a.Title AS Label FROM dbo.Activity a JOIN dbo.Topic t ON t.TopicID=a.TopicID JOIN dbo.Course c ON c.CourseID=t.CourseID WHERE "+restriction+" AND (@course=0 OR c.CourseID=@course) AND a.ActivityType IN ('Quiz','SelfAssessment','Game','Scenario') ORDER BY c.Title,a.Title,a.ActivityID",new[] {new SqlParameter("@user",CurrentUserHelper.GetUserID().Value),new SqlParameter("@course",course)});
        }
        internal static DataTable Attempts(bool teacher,int course,int activity,int limit=0)
        {
            RequireFilters(teacher,course,activity);
            // Only fixed SQL fragments vary; every ID and limit is a parameter.
            string scope=teacher ? "c.TeacherID=@user" : "x.LearnerID=@user";
            DataTable rows=DatabaseHelper.ExecuteTable(@"SELECT TOP (@limit) x.AttemptID,x.ActivityID,x.LearnerID,x.SubmittedAt,x.ScorePercent,x.TimeTakenSeconds,
a.Title,a.ActivityType,c.CourseID,c.Title AS CourseTitle,a.Status,c.Status AS CourseStatus,u.FullName,s.StepText AS EndingText,s.Outcome,
(SELECT SUM(CAST(r.Rating AS decimal(18,0))) FROM dbo.SAResponse r WHERE r.AttemptID=x.AttemptID) AS RatingTotal,
(SELECT COUNT(*) FROM dbo.SAResponse r WHERE r.AttemptID=x.AttemptID) AS RatingCount,
CAST(CASE WHEN EXISTS(SELECT 1 FROM dbo.Enrolment e WHERE e.CourseID=c.CourseID AND e.LearnerID=@user) THEN 1 ELSE 0 END AS bit) AS Enrolled
FROM dbo.Attempt x JOIN dbo.Activity a ON a.ActivityID=x.ActivityID JOIN dbo.Topic t ON t.TopicID=a.TopicID
JOIN dbo.Course c ON c.CourseID=t.CourseID JOIN dbo.[User] u ON u.UserID=x.LearnerID
LEFT JOIN dbo.SimStep s ON s.StepID=x.EndingStepID AND s.ActivityID=x.ActivityID
WHERE "+scope+" AND (@course=0 OR c.CourseID=@course) AND (@activity=0 OR a.ActivityID=@activity) AND a.ActivityType IN ('Quiz','SelfAssessment','Game','Scenario') ORDER BY x.SubmittedAt DESC,x.AttemptID DESC",new[] {new SqlParameter("@user",CurrentUserHelper.GetUserID().Value),new SqlParameter("@course",course),new SqlParameter("@activity",activity),new SqlParameter("@limit",limit>0 ? limit : Int32.MaxValue)});
            rows.Columns.Add("Summary",typeof(string));rows.Columns.Add("ResultUrl",typeof(string));rows.Columns.Add("LinkText",typeof(string));
            foreach(DataRow row in rows.Rows)
            {
                row["Summary"]=Summary(row);row["ResultUrl"]="";row["LinkText"]="";
                if(teacher){row["ResultUrl"]="~/Teacher/Results.aspx?courseId="+row["CourseID"]+"&activityId="+row["ActivityID"];row["LinkText"]="Activity results";}
                else if((bool)row["Enrolled"] && (string)row["Status"]=="Published" && (string)row["CourseStatus"]=="Published")
                {
                    string type=(string)row["ActivityType"];
                    row["ResultUrl"]=type=="Quiz" ? "~/Member/QuizResult.aspx?id="+row["AttemptID"] : "~/Member/"+(type=="Game" ? "PlayGame" : type)+".aspx?id="+row["ActivityID"]+"&attemptId="+row["AttemptID"];
                    row["LinkText"]="View result";
                }
            }
            return rows;
        }
        internal static string Summary(DataRow row)
        {
            string type=(string)row["ActivityType"];
            if(type=="SelfAssessment")
            {
                int count=(int)row["RatingCount"];if(count==0)return "No confidence ratings recorded";
                decimal average=(decimal)row["RatingTotal"]/count;
                return "Confidence: "+SelfAssessmentHelper.Display(average)+" / 5 — "+SelfAssessmentHelper.Level(average);
            }
            if(type=="Scenario")return Convert.ToString(row["Outcome"])+" — "+Convert.ToString(row["EndingText"]);
            string score=row.IsNull("ScorePercent") ? "No score recorded" : ((decimal)row["ScorePercent"]).ToString("F2",CultureInfo.InvariantCulture)+"%";
            if(type=="Game" && !row.IsNull("TimeTakenSeconds"))score+=" · "+row["TimeTakenSeconds"]+" seconds";
            return score;
        }
        internal static DataTable ScoreSummary(bool teacher,int course,int activity)
        {
            RequireFilters(teacher,course,activity);
            string scope=teacher ? "c.TeacherID=@user" : "x.LearnerID=@user";
            return DatabaseHelper.ExecuteTable(@"SELECT c.Title AS CourseTitle,a.Title,a.ActivityType,u.FullName,COUNT(*) AS Attempts,MAX(x.ScorePercent) AS BestScore,AVG(x.ScorePercent) AS AverageScore,
(SELECT TOP (1) y.ScorePercent FROM dbo.Attempt y WHERE y.ActivityID=a.ActivityID AND y.LearnerID=u.UserID ORDER BY y.SubmittedAt DESC,y.AttemptID DESC) AS LatestScore
FROM dbo.Attempt x JOIN dbo.Activity a ON a.ActivityID=x.ActivityID JOIN dbo.Topic t ON t.TopicID=a.TopicID JOIN dbo.Course c ON c.CourseID=t.CourseID JOIN dbo.[User] u ON u.UserID=x.LearnerID
WHERE "+scope+" AND a.ActivityType IN ('Quiz','Game') AND (@course=0 OR c.CourseID=@course) AND (@activity=0 OR a.ActivityID=@activity) GROUP BY c.Title,a.Title,a.ActivityType,a.ActivityID,u.UserID,u.FullName ORDER BY c.Title,a.Title,u.FullName,u.UserID",new[] {new SqlParameter("@user",CurrentUserHelper.GetUserID().Value),new SqlParameter("@course",course),new SqlParameter("@activity",activity)});
        }
        internal static string FilterUrl(string page,int course,int activity)
        {
            return page+"?courseId="+(course==0 ? "" : course.ToString())+"&activityId="+(activity==0 ? "" : activity.ToString());
        }
    }
}

