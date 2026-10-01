<%@ Page Title="Access Denied" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="AccessDenied.aspx.cs" Inherits="LearningSystem.AccessDenied" %>
<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
<h1>Access Denied</h1>
<p class="intro">You do not have permission to open this page.</p>
<div class="actions">
<asp:HyperLink ID="lnkHome" runat="server" NavigateUrl="~/Default.aspx" CssClass="button" Text="Home" />
<asp:HyperLink ID="lnkDashboard" runat="server" CssClass="button secondary" Text="My dashboard" />
</div>
<p>You can also use the Back button in your browser.</p>
</asp:Content>

