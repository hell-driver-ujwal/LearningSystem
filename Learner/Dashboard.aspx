<%@ Page Title="Learner dashboard" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="LearningSystem.Learner.Dashboard" %>
<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
<h1>Learner dashboard</h1>
<div class="actions"><a href="MyCourses.aspx">My courses</a><a href="MyResults.aspx">My results</a><a href="../Courses.aspx">Browse courses</a><a href="../Member/Profile.aspx">My profile</a><a href="../Help.aspx">Help</a></div>
<section><h2>Your courses</h2><asp:PlaceHolder ID="phCourses" runat="server" /></section>
<section><h2>Recent results</h2><div class="table-scroll" role="region" aria-label="Five most recent submitted attempts" tabindex="0"><asp:GridView ID="gvResults" runat="server" AutoGenerateColumns="false" Caption="Five most recent submitted attempts" UseAccessibleHeader="true" EmptyDataText="No submitted attempts yet."><Columns><asp:BoundField DataField="CourseTitle" HeaderText="Course" HtmlEncode="true" /><asp:BoundField DataField="Title" HeaderText="Activity" HtmlEncode="true" /><asp:BoundField DataField="ActivityType" HeaderText="Type" /><asp:BoundField DataField="Summary" HeaderText="Result" HtmlEncode="true" /><asp:BoundField DataField="SubmittedAt" HeaderText="Submitted (UTC)" DataFormatString="{0:yyyy-MM-dd HH:mm}" /><asp:TemplateField HeaderText="Details"><ItemTemplate><asp:HyperLink ID="lnkResult" runat="server" Text='<%# Eval("LinkText") %>' NavigateUrl='<%# Eval("ResultUrl") %>' Visible='<%# !String.IsNullOrEmpty((string)Eval("ResultUrl")) %>' /></ItemTemplate></asp:TemplateField></Columns></asp:GridView></div></section>
</asp:Content>


