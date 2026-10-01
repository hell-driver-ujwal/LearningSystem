<%@ Page Title="Site map" MetaDescription="Every main page on Inkwell in one list." Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="SiteMap.aspx.cs" Inherits="LearningSystem.SiteMapPage" %>
<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
<div class="page-header"><div><h1>Site map</h1><p class="intro">The main pages of Inkwell. Open a course to reach its lessons and activities.</p></div></div>
<div class="cards"><asp:Literal ID="litLinks" runat="server" /></div>
</asp:Content>