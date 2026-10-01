<%@ Page Title="My dashboard" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="LearningSystem.Learner.Dashboard" %>
<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
<div class="page-header">
    <div><h1><asp:Literal ID="litGreeting" runat="server" Mode="Encode" /></h1><p class="intro"><asp:Literal ID="litIntro" runat="server" Mode="Encode" /></p></div>
    <a class="button secondary" href="../Courses.aspx">Find a new course</a>
</div>

<div class="stat-grid">
    <section class="stat-card streak" aria-labelledby="streak-label"><span class="label" id="streak-label"><%= LearningSystem.Helpers.UiHelper.Icon("flame") %>Learning streak</span><p class="value"><asp:Literal ID="litStreak" runat="server" Mode="Encode" /></p><asp:Literal ID="litWeek" runat="server" /></section>
    <section class="stat-card" aria-labelledby="courses-label"><span class="label" id="courses-label"><%= LearningSystem.Helpers.UiHelper.Icon("layers") %>Courses</span><p class="value"><asp:Literal ID="litCourses" runat="server" Mode="Encode" /></p><span class="note"><asp:Literal ID="litCoursesNote" runat="server" Mode="Encode" /></span></section>
    <section class="stat-card" aria-labelledby="done-label"><span class="label" id="done-label"><%= LearningSystem.Helpers.UiHelper.Icon("check-circle") %>Items completed</span><p class="value"><asp:Literal ID="litDone" runat="server" Mode="Encode" /></p><span class="note">Lessons, activities and discussions</span></section>
    <section class="stat-card" aria-labelledby="score-label"><span class="label" id="score-label"><%= LearningSystem.Helpers.UiHelper.Icon("target") %>Average best score</span><p class="value"><asp:Literal ID="litScore" runat="server" Mode="Encode" /></p><span class="note">Across your quizzes and games</span></section>
</div>

<asp:PlaceHolder ID="phContinue" runat="server" />

<section class="section" aria-labelledby="courses-title">
    <div class="section-head"><div><h2 id="courses-title">Your courses</h2><p>Progress counts every published lesson and activity once.</p></div><a class="lead-link" href="MyCourses.aspx">Manage my courses <%= LearningSystem.Helpers.UiHelper.Icon("arrow-right") %></a></div>
    <asp:PlaceHolder ID="phCourses" runat="server" />
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
