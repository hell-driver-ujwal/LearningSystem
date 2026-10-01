<%@ Page Title="Something went wrong" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Error.aspx.cs" Inherits="LearningSystem.Error" %>
<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
<h1>Something went wrong</h1>
<p class="intro">We could not complete your request. Please try again later.</p>
<div class="actions">
<asp:HyperLink ID="lnkHome" runat="server" NavigateUrl="~/Default.aspx" CssClass="button" Text="Home" />
<asp:HyperLink ID="lnkDashboard" runat="server" CssClass="button secondary" Text="My dashboard" />
</div>
<p>You can also use the Back button in your browser.</p>
</asp:Content>

