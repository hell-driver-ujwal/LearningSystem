<%@ Page Title="Payment successful" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="EsewaSuccess.aspx.cs" Inherits="LearningSystem.Payment.EsewaSuccess" %>
<asp:Content ID="HeadArea" ContentPlaceHolderID="HeadContent" runat="server"><meta name="robots" content="noindex" /></asp:Content>
<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
<div class="esewa-shell">
    <div class="esewa-head"><span class="esewa-logo">e<span>Sewa</span></span><span class="esewa-tag">Receipt</span></div>
    <div class="esewa-body receipt">
        <span class="receipt-check" aria-hidden="true"><%= LearningSystem.Helpers.UiHelper.Icon("check") %></span>
        <h1>Payment successful</h1>
        <p class="muted">Your payment is verified and you are enrolled.</p>
        <table class="checkout-total"><caption class="visually-hidden">Payment receipt</caption><tbody>
            <tr><th scope="row">Course</th><td><asp:Literal ID="litCourse" runat="server" Mode="Encode" /></td></tr>
            <tr><th scope="row">Amount paid</th><td><asp:Literal ID="litAmount" runat="server" Mode="Encode" /></td></tr>
            <tr><th scope="row">Transaction reference</th><td><asp:Literal ID="litReference" runat="server" Mode="Encode" /></td></tr>
            <tr><th scope="row">Paid on</th><td><asp:Literal ID="litDate" runat="server" Mode="Encode" /></td></tr>
        </tbody></table>
        <div class="actions"><asp:HyperLink ID="lnkCourse" runat="server" Text="Start the course" CssClass="button large" /><a href="../Learner/MyPayments.aspx">My payments</a></div>
    </div>
</div>
</asp:Content>
