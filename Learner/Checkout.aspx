<%@ Page Title="Checkout" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Checkout.aspx.cs" Inherits="LearningSystem.Learner.Checkout" %>
<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
<div class="page-header"><div><h1>Checkout</h1><p class="intro">This is a paid course. Pay once with eSewa and the course opens straight away, even if you leave and come back later.</p></div></div>
<div class="split">
    <section class="form-card wide" aria-labelledby="order-title">
        <h2 id="order-title">Order summary</h2>
        <div class="checkout-line"><asp:Image ID="imgCover" runat="server" CssClass="checkout-cover" /><div><strong><asp:Literal ID="litCourse" runat="server" Mode="Encode" /></strong><br /><span class="muted"><asp:Literal ID="litTeacher" runat="server" Mode="Encode" /></span></div></div>
        <table class="checkout-total"><caption class="visually-hidden">Price breakdown</caption><tbody>
            <tr><th scope="row">Course price</th><td><asp:Literal ID="litAmount" runat="server" Mode="Encode" /></td></tr>
            <tr><th scope="row">Service charge</th><td>NPR 0.00</td></tr>
            <tr class="total"><th scope="row">Total to pay</th><td><asp:Literal ID="litTotal" runat="server" Mode="Encode" /></td></tr>
        </tbody></table>
        <asp:ValidationSummary ID="vsForm" runat="server" />
        <div class="actions"><asp:Button ID="btnBegin" runat="server" Text="Pay with eSewa" OnClick="BeginPayment" CssClass="esewa-button large" />
        <asp:HyperLink ID="lnkCancel" runat="server" CssClass="button secondary" Text="Back to course" /></div>
        <p class="muted"><small>Demo payment: no real money is charged. You will confirm with your eSewa mobile number and a 4-digit code.</small></p>
    </section>
    <aside class="card" aria-labelledby="includes-title">
        <h2 id="includes-title">After you pay</h2>
        <ul class="includes">
            <li><%= LearningSystem.Helpers.UiHelper.Icon("check-circle") %>Every lesson and activity in this course</li>
            <li><%= LearningSystem.Helpers.UiHelper.Icon("chart") %>Your progress and results saved</li>
            <li><%= LearningSystem.Helpers.UiHelper.Icon("award") %>A certificate when you finish</li>
            <li><%= LearningSystem.Helpers.UiHelper.Icon("shield") %>Lasting access: leaving and rejoining is free</li>
        </ul>
    </aside>
</div>
</asp:Content>
