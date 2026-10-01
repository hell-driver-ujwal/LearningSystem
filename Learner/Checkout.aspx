<%@ Page Title="Course checkout" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Checkout.aspx.cs" Inherits="LearningSystem.Learner.Checkout" %>
<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
<h1>Course checkout</h1>
<p class="sandbox-notice">eSewa Sandbox — Test Payment. No real money is used.</p>
<section class="form-card"><h2><asp:Literal ID="litCourse" runat="server" Mode="Encode" /></h2>
<p class="course-price"><asp:Literal ID="litAmount" runat="server" Mode="Encode" /></p>
<p><asp:Literal ID="litStatus" runat="server" Mode="Encode" /></p>
<asp:ValidationSummary ID="vsForm" runat="server" />
<div class="actions"><asp:Button ID="btnBegin" runat="server" Text="Begin test payment / Restore purchase" OnClick="BeginPayment" />
<asp:HyperLink ID="lnkCancel" runat="server" CssClass="button secondary" Text="Back to course" /></div></section>
</asp:Content>
<asp:Content ID="PaymentContent" ContentPlaceHolderID="OutsideFormContent" runat="server"><asp:Literal ID="litPaymentForm" runat="server" /></asp:Content>