<%@ Page Title="Course certificate" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Certificate.aspx.cs" Inherits="LearningSystem.Learner.Certificate" %>
<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
<link rel="stylesheet" href="../Styles/print.css" media="print" />
<article class="certificate form-card"><h1>Certificate of course completion</h1><p>This certifies that</p><h2><asp:Literal ID="litLearner" runat="server" Mode="Encode" /></h2><p>has completed the currently published learning items in</p><h2><asp:Literal ID="litCourse" runat="server" Mode="Encode" /></h2><p>Teacher: <asp:Literal ID="litTeacher" runat="server" Mode="Encode" /></p><p>Printed on: <asp:Literal ID="litDate" runat="server" Mode="Encode" /></p><p>The date above is the print date, not a historical completion date.</p></article>
<div class="actions no-print"><button type="button" onclick="window.print()">Print certificate</button><a href="MyCourses.aspx">Back to my courses</a></div>
</asp:Content>
