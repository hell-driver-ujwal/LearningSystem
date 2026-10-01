<%@ Page Title="Page not found" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="NotFound.aspx.cs" Inherits="LearningSystem.NotFound" %>
<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
<h1>Page not found</h1>
<p class="intro">This page is unavailable or does not exist.</p>
<div class="actions">
<asp:HyperLink ID="lnkHome" runat="server" NavigateUrl="~/Default.aspx" CssClass="button" Text="Home" />
<asp:HyperLink ID="lnkDashboard" runat="server" CssClass="button secondary" Text="My dashboard" />
</div>
<p>You can also use the Back button in your browser.</p>
</asp:Content>

