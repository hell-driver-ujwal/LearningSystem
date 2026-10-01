<%@ Page Title="Course home" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="CourseHome.aspx.cs" Inherits="LearningSystem.Learner.CourseHome" %>
<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
<h1><asp:Literal ID="litTitle" runat="server" Mode="Encode" /></h1>
<section class="progress-panel" aria-label="Course progress"><asp:Literal ID="litProgress" runat="server" /></section><p><a href="MyCourses.aspx">Back to my courses</a></p><asp:PlaceHolder ID="phOutline" runat="server" />
<p><asp:HyperLink ID="lnkCertificate" runat="server" Text="Print certificate" Visible="false" /></p></asp:Content>

