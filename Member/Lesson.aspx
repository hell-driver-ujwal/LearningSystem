<%@ Page Title="Lesson" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Lesson.aspx.cs" Inherits="LearningSystem.Member.Lesson" %>
<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
<h1><asp:Literal ID="litTitle" runat="server" Mode="Encode" /></h1>
<asp:Panel ID="pnlPreview" runat="server" Visible="false" CssClass="preview-banner"><strong>Preview mode — read only.</strong> No enrolment, completion, attempt, result or other learner data is saved. <asp:HyperLink ID="lnkExit" runat="server" Text="Exit preview" /></asp:Panel>
<section class="learning-content" aria-label="Lesson content"><asp:PlaceHolder ID="phViewer" runat="server" /></section>
<p><asp:Literal ID="litCompleted" runat="server" Mode="Encode" /></p>
<div class="actions"><asp:Button ID="btnComplete" runat="server" Text="Mark complete" ValidationGroup="Complete" OnClick="MarkComplete" /><asp:Button ID="btnBookmark" runat="server" Text="Add bookmark" ValidationGroup="Bookmark" OnClick="SetBookmark" Visible="false" /><asp:HyperLink ID="lnkBack" runat="server" Text="Back to course" /></div>
<nav class="actions" aria-label="Lesson navigation"><asp:HyperLink ID="lnkPrevious" runat="server" Text="Previous lesson" Visible="false" /><asp:HyperLink ID="lnkNext" runat="server" Text="Next lesson" Visible="false" /></nav>
</asp:Content>

