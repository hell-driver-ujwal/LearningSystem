<%@ Page Title="Course home" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="CourseHome.aspx.cs" Inherits="LearningSystem.Learner.CourseHome" %>
<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
<div class="page-header">
    <div><p class="chip"><asp:Literal ID="litSubject" runat="server" Mode="Encode" /></p><h1><asp:Literal ID="litTitle" runat="server" Mode="Encode" /></h1><p class="muted"><asp:Literal ID="litTeacher" runat="server" Mode="Encode" /></p></div>
    <asp:HyperLink ID="lnkDetails" runat="server" CssClass="button secondary" Text="Course page and reviews" />
</div>
<section class="progress-panel" aria-label="Course progress">
    <div style="flex:1;min-width:240px"><strong>Your progress</strong><br /><asp:Literal ID="litProgress" runat="server" /></div>
    <asp:HyperLink ID="lnkNext" runat="server" CssClass="button" />
    <asp:HyperLink ID="lnkCertificate" runat="server" Text="Print certificate" Visible="false" CssClass="button accent" />
</section>
<h2>Course content</h2>
<asp:PlaceHolder ID="phOutline" runat="server" />
<p><a href="MyCourses.aspx"><%= LearningSystem.Helpers.UiHelper.Icon("arrow-left") %> Back to my courses</a></p>
</asp:Content>
