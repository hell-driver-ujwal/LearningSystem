<%@ Page Title="Lesson" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Lesson.aspx.cs" Inherits="LearningSystem.Member.Lesson" %>
<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
<asp:Panel ID="pnlPreview" runat="server" Visible="false" CssClass="preview-banner"><span><strong>Preview mode.</strong> You are seeing this lesson as a learner would. Nothing is saved. <asp:HyperLink ID="lnkExit" runat="server" Text="Exit preview" /></span></asp:Panel>
<div class="lesson-layout">
    <asp:PlaceHolder ID="phSidebar" runat="server" />
    <article>
        <div class="activity-header"><asp:Literal ID="litTypeMark" runat="server" /><div><p class="eyebrow"><asp:Literal ID="litType" runat="server" Mode="Encode" /></p><h1><asp:Literal ID="litTitle" runat="server" Mode="Encode" /></h1></div></div>
        <section class="learning-content" aria-label="Lesson content"><asp:PlaceHolder ID="phViewer" runat="server" /></section>
        <div class="lesson-footer">
            <p style="margin:0"><asp:Literal ID="litCompleted" runat="server" Mode="Encode" /></p>
            <div class="actions"><asp:Button ID="btnComplete" runat="server" Text="Mark as complete" ValidationGroup="Complete" OnClick="MarkComplete" /><asp:Button ID="btnBookmark" runat="server" Text="Add bookmark" ValidationGroup="Bookmark" OnClick="SetBookmark" Visible="false" CssClass="secondary" /><asp:HyperLink ID="lnkBack" runat="server" Text="Course outline" /></div>
        </div>
        <nav class="lesson-pager" aria-label="Lesson navigation">
            <asp:HyperLink ID="lnkPrevious" runat="server" Visible="false" />
            <asp:HyperLink ID="lnkNext" runat="server" Visible="false" CssClass="next" />
        </nav>
    </article>
</div>
</asp:Content>
