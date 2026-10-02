<%@ Page Title="Admin dashboard" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="LearningSystem.Admin.Dashboard" %>
<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
<div class="page-header hero-banner">
    <%= LearningSystem.Helpers.MascotHelper.Render("point") %>
    <div><h1>Admin dashboard</h1><p class="intro">An overview of accounts, courses and learning activity across Inkwell.</p></div>
    <div class="actions" style="margin:0"><a class="button" href="../Teacher/CourseEdit.aspx">Create a course</a><a class="button secondary" href="UserEdit.aspx">Add a user</a></div>
</div>
<div class="stat-grid">
    <section class="stat-card"><span class="label"><%= LearningSystem.Helpers.UiHelper.Icon("users") %>Active learners</span><p class="value"><asp:Literal ID="litLearners" runat="server" Mode="Encode" /></p><a href="Users.aspx">Manage users</a></section>
    <section class="stat-card"><span class="label"><%= LearningSystem.Helpers.UiHelper.Icon("user") %>Active lecturers</span><p class="value"><asp:Literal ID="litLecturers" runat="server" Mode="Encode" /></p><a href="TeacherApplications.aspx"><asp:Literal ID="litPending" runat="server" Mode="Encode" /> waiting for approval</a></section>
    <section class="stat-card"><span class="label"><%= LearningSystem.Helpers.UiHelper.Icon("layers") %>Published courses</span><p class="value"><asp:Literal ID="litCourses" runat="server" Mode="Encode" /></p><a href="Courses.aspx">Course oversight</a></section>
    <section class="stat-card"><span class="label"><%= LearningSystem.Helpers.UiHelper.Icon("check-circle") %>Submitted attempts</span><p class="value"><asp:Literal ID="litAttempts" runat="server" Mode="Encode" /></p><a href="Activities.aspx">All activities</a></section>
    <section class="stat-card"><span class="label"><%= LearningSystem.Helpers.UiHelper.Icon("mail") %>Unread messages</span><p class="value"><asp:Literal ID="litUnread" runat="server" Mode="Encode" /></p><a href="Messages.aspx">Open inbox</a></section>
    <section class="stat-card"><span class="label"><%= LearningSystem.Helpers.UiHelper.Icon("eye") %>Page views today</span><p class="value"><asp:Literal ID="litViews" runat="server" Mode="Encode" /></p><a href="Analytics.aspx">View analytics</a></section>
</div>
<div class="two-col section">
    <section aria-labelledby="roles-title"><h2 id="roles-title">Users by role</h2>
        <div class="table-scroll" role="region" aria-label="User counts, including inactive accounts" tabindex="0"><asp:GridView ID="gvRoles" runat="server" AutoGenerateColumns="false" Caption="All accounts, including inactive ones" UseAccessibleHeader="true" EmptyDataText="No users found."><Columns><asp:BoundField DataField="Role" HeaderText="Role" /><asp:BoundField DataField="UserCount" HeaderText="Accounts" /></Columns></asp:GridView></div></section>
    <section aria-labelledby="subjects-title"><h2 id="subjects-title">Courses per subject</h2>
        <div class="table-scroll" role="region" aria-label="Course counts, including drafts" tabindex="0"><asp:GridView ID="gvSubjects" runat="server" AutoGenerateColumns="false" Caption="Courses per subject, including drafts" UseAccessibleHeader="true" EmptyDataText="No subjects yet."><Columns><asp:BoundField DataField="SubjectName" HeaderText="Subject" HtmlEncode="true" /><asp:BoundField DataField="CourseCount" HeaderText="Courses" /></Columns></asp:GridView></div></section>
</div>
<section aria-labelledby="charts-title"><h2 id="charts-title">Charts</h2><div class="two-col"><asp:Literal ID="litCharts" runat="server" /></div></section>
<section class="section" aria-labelledby="recent-title"><h2 id="recent-title">Newest accounts</h2>
    <div class="table-scroll" role="region" aria-label="Five newest accounts" tabindex="0"><asp:GridView ID="gvRecent" runat="server" AutoGenerateColumns="false" Caption="Five newest accounts" UseAccessibleHeader="true" EmptyDataText="No accounts yet."><Columns><asp:BoundField DataField="FullName" HeaderText="Name" HtmlEncode="true" /><asp:BoundField DataField="Role" HeaderText="Role" /><asp:BoundField DataField="Status" HeaderText="Status" /><asp:BoundField DataField="CreatedDate" HeaderText="Joined (UTC)" DataFormatString="{0:d MMM yyyy}" /></Columns></asp:GridView></div>
</section>

<section class="cta-band slim" aria-labelledby="cta-title">
    <div><h2 id="cta-title">Review site analytics</h2><p>Page views counted from real visits, broken down by page and by role.</p></div>
    <div class="actions"><a class="button" href="Analytics.aspx">Open analytics <%= LearningSystem.Helpers.UiHelper.Icon("arrow-right") %></a></div>
</section>
<script src="<%: LearningSystem.Helpers.UiHelper.AssetUrl("~/Scripts/charts.js") %>" defer></script>
</asp:Content>
