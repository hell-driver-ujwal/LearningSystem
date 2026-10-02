<%@ Page Title="Something went wrong" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Error.aspx.cs" Inherits="LearningSystem.Error" %>
<asp:Content ID="HeadArea" ContentPlaceHolderID="HeadContent" runat="server"><meta name="robots" content="noindex" /></asp:Content>
<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
<div class="status-page">
    <div>
        <p class="status-code" aria-hidden="true">500</p>
        <h1>Sorry, something went wrong on our side</h1>
        <p class="intro">Nothing you did caused this. Please try again in a moment. If it keeps happening, let us know what you were doing and we will look into it.</p>
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
    <svg class="status-art" viewBox="0 0 200 220" width="260" aria-hidden="true" focusable="false"><path d="M100 10c-26 35-52 64-52 94a52 52 0 0 0 104 0c0-30-26-59-52-94z" fill="#ece6fd" stroke="#5a3fc0" stroke-width="4"/><circle cx="100" cy="112" r="30" fill="#fff" stroke="#b8336a" stroke-width="4"/><use href="#i-help" x="82" y="94" width="36" height="36" stroke="#5a3fc0" fill="none" stroke-width="2"/><path d="M40 200h120" stroke="#cfc7e3" stroke-width="4" stroke-linecap="round"/></svg>
</div>
</asp:Content>