<%@ Page Title="My dashboard" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="LearningSystem.Learner.Dashboard" %>
<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
<%-- Player card: Inky, level, XP, streak, daily goal and badges, all worked out from real activity --%>
<asp:PlaceHolder ID="phPlayer" runat="server" />

<section aria-labelledby="quest-title">
    <h2 id="quest-title" class="visually-hidden">Your next quest</h2>
    <asp:PlaceHolder ID="phContinue" runat="server" />
</section>

<div class="stat-grid" aria-label="Your stats">
    <section class="stat-card" aria-labelledby="courses-label"><span class="label" id="courses-label"><%= LearningSystem.Helpers.UiHelper.Icon("layers") %>Courses</span><p class="value"><asp:Literal ID="litCourses" runat="server" Mode="Encode" /></p><span class="note"><asp:Literal ID="litCoursesNote" runat="server" Mode="Encode" /></span></section>
    <section class="stat-card" aria-labelledby="done-label"><span class="label" id="done-label"><%= LearningSystem.Helpers.UiHelper.Icon("check-circle") %>Items done</span><p class="value"><asp:Literal ID="litDone" runat="server" Mode="Encode" /></p><span class="note">Lessons, activities, posts</span></section>
    <section class="stat-card" aria-labelledby="score-label"><span class="label" id="score-label"><%= LearningSystem.Helpers.UiHelper.Icon("target") %>Best score average</span><p class="value"><asp:Literal ID="litScore" runat="server" Mode="Encode" /></p><span class="note">Quizzes and games</span></section>
    <section class="stat-card" aria-labelledby="week-label"><span class="label" id="week-label"><%= LearningSystem.Helpers.UiHelper.Icon("calendar") %>This week</span><asp:Literal ID="litWeek" runat="server" /></section>
</div>

<section class="section" aria-labelledby="courses-title">
    <div class="section-head"><div><h2 id="courses-title">Your courses</h2><p>Each course is a path of lessons and activities. Progress counts every item once.</p></div><a class="lead-link" href="MyCourses.aspx">Manage my courses <%= LearningSystem.Helpers.UiHelper.Icon("arrow-right") %></a></div>
    <asp:PlaceHolder ID="phCourses" runat="server" />
</section>

<section class="section" aria-labelledby="badges-title">
    <div class="section-head"><div><h2 id="badges-title">Badges</h2><p>Earn badges by learning in different ways. Locked badges show how close you are.</p></div></div>
    <asp:PlaceHolder ID="phBadges" runat="server" />
</section>

<section class="section" aria-labelledby="results-title">
    <div class="section-head"><div><h2 id="results-title">Recent results</h2><p>Your five latest submitted quizzes, games, self-assessments and scenarios.</p></div><a class="lead-link" href="MyResults.aspx">All results <%= LearningSystem.Helpers.UiHelper.Icon("arrow-right") %></a></div>
    <div class="table-scroll" role="region" aria-label="Five most recent submitted attempts" tabindex="0"><asp:GridView ID="gvResults" runat="server" AutoGenerateColumns="false" Caption="Five most recent submitted attempts" UseAccessibleHeader="true" EmptyDataText="No submitted attempts yet. Your results appear here after your first quiz or game."><Columns><asp:BoundField DataField="Title" HeaderText="Activity" HtmlEncode="true" /><asp:BoundField DataField="CourseTitle" HeaderText="Course" HtmlEncode="true" /><asp:BoundField DataField="ActivityType" HeaderText="Type" /><asp:BoundField DataField="Summary" HeaderText="Result" HtmlEncode="true" /><asp:BoundField DataField="SubmittedAt" HeaderText="Submitted (UTC)" DataFormatString="{0:d MMM yyyy, HH:mm}" /><asp:TemplateField HeaderText="Details"><ItemTemplate><asp:HyperLink ID="lnkResult" runat="server" Text='<%# Eval("LinkText") %>' NavigateUrl='<%# Eval("ResultUrl") %>' Visible='<%# !String.IsNullOrEmpty((string)Eval("ResultUrl")) %>' /></ItemTemplate></asp:TemplateField></Columns></asp:GridView></div>
</section>

<section class="section" aria-labelledby="next-title">
    <div class="section-head"><div><h2 id="next-title">Suggested next courses</h2><p>Popular courses in the subjects you are studying.</p></div></div>
    <asp:PlaceHolder ID="phSuggested" runat="server" />
</section>
</asp:Content>
