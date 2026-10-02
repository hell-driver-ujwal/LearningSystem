<%@ Page Title="Access denied" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="AccessDenied.aspx.cs" Inherits="LearningSystem.AccessDenied" %>
<asp:Content ID="HeadArea" ContentPlaceHolderID="HeadContent" runat="server"><meta name="robots" content="noindex" /></asp:Content>
<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
<div class="status-page">
    <div>
        <p class="status-code" aria-hidden="true">403</p>
        <h1>This page is not available to your account</h1>
        <p class="intro">You may need to log in with a different account, or enrol in the course first. If you think this is a mistake, contact us.</p>
        <div class="actions">
            <asp:HyperLink ID="lnkHome" runat="server" NavigateUrl="~/Default.aspx" CssClass="button" Text="Go to the home page" />
            <asp:HyperLink ID="lnkDashboard" runat="server" CssClass="button secondary" Text="My dashboard" />
        </div>
        <ul class="status-links">
            <li><a href="<%: ResolveUrl("~/Courses.aspx") %>">Browse all courses</a></li>
            <li><a href="<%: ResolveUrl("~/Help.aspx") %>">Help and FAQ</a></li>
            <li><a href="<%: ResolveUrl("~/Contact.aspx") %>">Contact us</a></li>
        </ul>
    </div>
    <%= LearningSystem.Helpers.MascotHelper.Render("lock") %>
</div>
</asp:Content>