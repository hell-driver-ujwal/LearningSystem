<%@ Page Title="Admin Dashboard" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="LearningSystem.Admin.Dashboard" %>
<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
<h1>Admin Dashboard</h1>
<p class="intro">Account, course and learning activity counts across the system.</p>
<div class="cards">
<section class="card"><h2>Applications</h2><p class="stat"><asp:Literal ID="litPending" runat="server" Mode="Encode" /></p><a href="TeacherApplications.aspx">Review pending teachers</a></section>
<section class="card"><h2>Submitted attempts</h2><p class="stat"><asp:Literal ID="litAttempts" runat="server" Mode="Encode" /></p><p>Total across all activity types.</p></section>
</div>
<div class="cards">
<section><h2>Users by role</h2>
<div class="table-scroll" role="region" aria-label="User counts, including inactive accounts" tabindex="0"><asp:GridView ID="gvRoles" runat="server" AutoGenerateColumns="false" Caption="User counts, including inactive accounts" UseAccessibleHeader="true" EmptyDataText="No users found."><Columns>
<asp:BoundField DataField="Role" HeaderText="Role" /><asp:BoundField DataField="UserCount" HeaderText="Users" />
</Columns></asp:GridView></div></section>
<section><h2>Courses per subject</h2>
<div class="table-scroll" role="region" aria-label="Course counts, including drafts" tabindex="0"><asp:GridView ID="gvSubjects" runat="server" AutoGenerateColumns="false" Caption="Course counts, including drafts" UseAccessibleHeader="true" EmptyDataText="No subjects yet."><Columns>
<asp:BoundField DataField="SubjectName" HeaderText="Subject" HtmlEncode="true" /><asp:BoundField DataField="CourseCount" HeaderText="Courses" />
</Columns></asp:GridView></div></section>
</div>
<section class="form-card"><h2>Inbox</h2><p><asp:Literal ID="litUnread" runat="server" Mode="Encode" /> unread messages</p><a href="Messages.aspx">Open messages</a></section><h2>Charts</h2><asp:Literal ID="litCharts" runat="server" /><script src="../Scripts/charts.js" defer></script></asp:Content>


