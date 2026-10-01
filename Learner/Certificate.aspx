<%@ Page Title="Certificate of completion" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Certificate.aspx.cs" Inherits="LearningSystem.Learner.Certificate" %>
<asp:Content ID="HeadArea" ContentPlaceHolderID="HeadContent" runat="server"><link rel="stylesheet" href="../Styles/print.css" media="print" /></asp:Content>
<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
<div class="actions no-print" style="justify-content:space-between;margin-top:0"><p class="muted" style="margin:0">Use Print to save this certificate as a PDF or print it on landscape paper.</p><span class="actions" style="margin:0"><button type="button" onclick="window.print()">Print certificate</button><a href="MyCourses.aspx">Back to my courses</a></span></div>
<article class="certificate">
    <div class="logo"><svg class="logo-mark" viewBox="0 0 40 40" aria-hidden="true" focusable="false"><rect width="40" height="40" rx="9" fill="#1f3a5f"/><path d="M20 6.5c-4.6 6.2-9.2 11.4-9.2 16.6a9.2 9.2 0 0 0 18.4 0c0-5.2-4.6-10.4-9.2-16.6z" fill="#f6efe2"/><path d="M20 19.5v9" stroke="#1f3a5f" stroke-width="2.2" stroke-linecap="round"/><circle cx="20" cy="18" r="2.4" fill="#b0502a"/></svg><span class="site-name">Inkwell</span></div>
    <h1>Certificate of completion</h1>
    <p>This certifies that</p>
    <p class="cert-name"><asp:Literal ID="litLearner" runat="server" Mode="Encode" /></p>
    <p>has completed every published lesson and activity in the course</p>
    <p class="cert-course"><asp:Literal ID="litCourse" runat="server" Mode="Encode" /></p>
    <div class="cert-sign">
        <div><strong><asp:Literal ID="litTeacher" runat="server" Mode="Encode" /></strong><br />Course lecturer</div>
        <div><strong><asp:Literal ID="litDate" runat="server" Mode="Encode" /></strong><br />Date printed</div>
    </div>
    <p class="muted" style="margin-top:28px"><small>A record of course completion on Inkwell. This is not an accredited qualification.</small></p>
</article>
</asp:Content>
