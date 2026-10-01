<%@ Page Title="Analytics" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Analytics.aspx.cs" Inherits="LearningSystem.Admin.Analytics" %>
<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
<div class="page-header">
    <div><h1>Analytics</h1><p class="intro">Page views recorded on this site. No names, IP addresses or cookies are stored, only the page, the viewer's role and the time.</p></div>
    <div class="field" style="margin:0"><asp:Label ID="lblRange" runat="server" AssociatedControlID="ddlRange" Text="Period" /><asp:DropDownList ID="ddlRange" runat="server" AutoPostBack="true" OnSelectedIndexChanged="RangeChanged"><asp:ListItem Value="7">Last 7 days</asp:ListItem><asp:ListItem Value="14" Selected="True">Last 14 days</asp:ListItem><asp:ListItem Value="30">Last 30 days</asp:ListItem></asp:DropDownList></div>
</div>
<div class="stat-grid">
    <section class="stat-card"><span class="label"><%= LearningSystem.Helpers.UiHelper.Icon("eye") %>Page views</span><p class="value"><asp:Literal ID="litTotal" runat="server" Mode="Encode" /></p><span class="note"><asp:Literal ID="litPeriod" runat="server" Mode="Encode" /></span></section>
    <section class="stat-card"><span class="label"><%= LearningSystem.Helpers.UiHelper.Icon("calendar") %>Today</span><p class="value"><asp:Literal ID="litToday" runat="server" Mode="Encode" /></p><span class="note">Views since midnight (UTC)</span></section>
    <section class="stat-card"><span class="label"><%= LearningSystem.Helpers.UiHelper.Icon("chart") %>Daily average</span><p class="value"><asp:Literal ID="litAverage" runat="server" Mode="Encode" /></p><span class="note">Across the selected period</span></section>
    <section class="stat-card"><span class="label"><%= LearningSystem.Helpers.UiHelper.Icon("users") %>Signed-in share</span><p class="value"><asp:Literal ID="litSignedIn" runat="server" Mode="Encode" /></p><span class="note">Views by logged-in learners, lecturers and staff</span></section>
</div>
<div class="two-col">
    <section class="chart-card" aria-labelledby="daily-title"><h2 id="daily-title">Views per day</h2><asp:Literal ID="litDaily" runat="server" /></section>
    <section class="chart-card" aria-labelledby="role-title"><h2 id="role-title">Views by visitor type</h2><asp:Literal ID="litRoles" runat="server" /></section>
</div>
<h2>Most viewed pages</h2>
<div class="table-scroll" role="region" aria-label="Most viewed pages" tabindex="0"><asp:GridView ID="gvPages" runat="server" AutoGenerateColumns="false" Caption="Most viewed pages in the selected period" UseAccessibleHeader="true" EmptyDataText="No page views recorded in this period yet."><Columns><asp:BoundField DataField="PagePath" HeaderText="Page" HtmlEncode="true" /><asp:BoundField DataField="Views" HeaderText="Views" /></Columns></asp:GridView></div>
<p class="muted"><small>Records older than 12 months are removed automatically, as described in the <a href="../Privacy.aspx#analytics">Privacy policy</a>.</small></p>
</asp:Content>
