<%@ Page Title="Lecturer dashboard" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="LearningSystem.Teacher.Dashboard" %>
<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
<div class="page-header hero-banner">
    <div><h1><asp:Literal ID="litGreeting" runat="server" Mode="Encode" /></h1><p class="intro">Your courses, your learners and their latest results.</p></div>
    <div class="actions" style="margin:0"><a class="button" href="CourseEdit.aspx"><%= LearningSystem.Helpers.UiHelper.Icon("plus") %> Create a course</a><a class="button secondary" href="Results.aspx">All results</a></div>
</div>
<div class="stat-grid">
    <section class="stat-card"><span class="label"><%= LearningSystem.Helpers.UiHelper.Icon("layers") %>My courses</span><p class="value"><asp:Literal ID="litCourses" runat="server" Mode="Encode" /></p><span class="note"><asp:Literal ID="litCoursesNote" runat="server" Mode="Encode" /></span></section>
    <section class="stat-card"><span class="label"><%= LearningSystem.Helpers.UiHelper.Icon("users") %>Enrolled learners</span><p class="value"><asp:Literal ID="litLearners" runat="server" Mode="Encode" /></p><span class="note">Different learners across your courses</span></section>
    <section class="stat-card"><span class="label"><%= LearningSystem.Helpers.UiHelper.Icon("check-circle") %>Attempts this week</span><p class="value"><asp:Literal ID="litWeek" runat="server" Mode="Encode" /></p><span class="note">Submitted in the last 7 days</span></section>
    <section class="stat-card"><span class="label"><%= LearningSystem.Helpers.UiHelper.Icon("chat") %>Discussion posts</span><p class="value"><asp:Literal ID="litPosts" runat="server" Mode="Encode" /></p><span class="note">Across your discussions</span></section>
</div>
<section class="section" aria-labelledby="courses-title">
    <div class="section-head"><div><h2 id="courses-title">Your courses</h2><p>Open a course to add topics, lessons and activities.</p></div><a class="lead-link" href="MyCourses.aspx">Manage and publish <%= LearningSystem.Helpers.UiHelper.Icon("arrow-right") %></a></div>
    <asp:PlaceHolder ID="phCourses" runat="server" />
</section>
<section class="section" aria-labelledby="recent-title">
    <h2 id="recent-title">Recent attempts</h2>
    <div class="table-scroll" role="region" aria-label="Five most recent attempts in your courses" tabindex="0"><asp:GridView ID="gvResults" runat="server" AutoGenerateColumns="false" Caption="Five most recent attempts in your courses" UseAccessibleHeader="true" EmptyDataText="No learner attempts in your courses yet."><Columns><asp:BoundField DataField="FullName" HeaderText="Learner" HtmlEncode="true" /><asp:BoundField DataField="Title" HeaderText="Activity" HtmlEncode="true" /><asp:BoundField DataField="CourseTitle" HeaderText="Course" HtmlEncode="true" /><asp:BoundField DataField="Summary" HeaderText="Result" HtmlEncode="true" /><asp:BoundField DataField="SubmittedAt" HeaderText="Submitted (UTC)" DataFormatString="{0:d MMM yyyy, HH:mm}" /><asp:HyperLinkField DataNavigateUrlFields="CourseID,ActivityID" DataNavigateUrlFormatString="Results.aspx?courseId={0}&amp;activityId={1}" Text="Activity results" HeaderText="Details" /></Columns></asp:GridView></div>
</section>

<section class="cta-band slim" aria-labelledby="cta-title">
    <div><h2 id="cta-title">See how your learners are doing</h2><p>Open the results for any activity to see scores, answers and confidence ratings.</p></div>
    <div class="actions"><a class="button" href="Results.aspx">Open results <%= LearningSystem.Helpers.UiHelper.Icon("arrow-right") %></a></div>
</section>
</asp:Content>
