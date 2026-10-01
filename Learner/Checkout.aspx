<%@ Page Title="Course checkout" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Checkout.aspx.cs" Inherits="LearningSystem.Learner.Checkout" %>
<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
<div class="page-header"><div><h1>Checkout</h1><p class="intro">Pay securely with eSewa. Your course opens as soon as eSewa confirms the payment.</p></div></div>
<p class="sandbox-notice">eSewa sandbox test mode. No real money is charged.</p>
<section class="form-card"><h2><asp:Literal ID="litCourse" runat="server" Mode="Encode" /></h2>
<p class="course-price"><asp:Literal ID="litAmount" runat="server" Mode="Encode" /></p>
<p><asp:Literal ID="litStatus" runat="server" Mode="Encode" /></p>
<asp:ValidationSummary ID="vsForm" runat="server" />
<div class="actions"><asp:Button ID="btnBegin" runat="server" Text="Begin test payment / Restore purchase" OnClick="BeginPayment" />
<asp:HyperLink ID="lnkCancel" runat="server" CssClass="button secondary" Text="Back to course" /></div></section>
</asp:Content>
<asp:Content ID="PaymentContent" ContentPlaceHolderID="OutsideFormContent" runat="server"><asp:Literal ID="litPaymentForm" runat="server" /></asp:Content>