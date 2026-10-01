<%@ Page Title="Pay with eSewa" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="EsewaDemo.aspx.cs" Inherits="LearningSystem.Payment.EsewaDemo" %>
<asp:Content ID="HeadArea" ContentPlaceHolderID="HeadContent" runat="server"><meta name="robots" content="noindex" /></asp:Content>
<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
<div class="esewa-shell">
    <div class="esewa-head"><span class="esewa-logo">e<span>Sewa</span></span><span class="esewa-tag">Demo payment</span></div>
    <div class="esewa-merchant">
        <div><span class="muted">Paying</span><br /><strong>Inkwell Academy</strong></div>
        <div><span class="muted">For</span><br /><strong><asp:Literal ID="litCourse" runat="server" Mode="Encode" /></strong></div>
        <div class="esewa-amount"><span class="muted">Amount</span><br /><strong><asp:Literal ID="litAmount" runat="server" Mode="Encode" /></strong></div>
    </div>
    <h1 class="visually-hidden">Pay with eSewa</h1>
    <asp:Panel ID="pnlPhone" runat="server" CssClass="esewa-body" DefaultButton="btnSendCode">
        <h2>Log in to your eSewa account</h2>
        <asp:ValidationSummary ID="vsPhone" runat="server" ValidationGroup="Phone" />
        <div class="field">
            <asp:Label ID="lblPhone" runat="server" AssociatedControlID="txtPhone" Text="eSewa ID (mobile number)" />
            <asp:TextBox ID="txtPhone" runat="server" TextMode="Phone" MaxLength="10" inputmode="numeric" autocomplete="tel-national" placeholder="98XXXXXXXX" />
            <span class="hint">10 digits, starting with 97 or 98.</span>
            <asp:RequiredFieldValidator ID="rfvPhone" runat="server" ControlToValidate="txtPhone" ValidationGroup="Phone" ErrorMessage="Enter your eSewa mobile number." Display="Dynamic" />
            <asp:RegularExpressionValidator ID="revPhone" runat="server" ControlToValidate="txtPhone" ValidationGroup="Phone" ValidationExpression="^9[78][0-9]{8}$" ErrorMessage="Enter a 10-digit mobile number that starts with 97 or 98." Display="Dynamic" />
        </div>
        <div class="actions"><asp:Button ID="btnSendCode" runat="server" Text="Continue" ValidationGroup="Phone" OnClick="SendCode" CssClass="esewa-button" /><asp:Button ID="btnCancel" runat="server" Text="Cancel payment" CausesValidation="false" OnClick="CancelPayment" OnClientClick="return confirm('Cancel this payment? You will not be charged.');" /></div>
    </asp:Panel>
    <asp:Panel ID="pnlCode" runat="server" CssClass="esewa-body" Visible="false" DefaultButton="btnPay">
        <h2>Enter your verification code</h2>
        <p>We sent a 4-digit code to <strong><asp:Literal ID="litMasked" runat="server" Mode="Encode" /></strong>.</p>
        <asp:ValidationSummary ID="vsCode" runat="server" ValidationGroup="Code" />
        <div class="field">
            <asp:Label ID="lblCode" runat="server" AssociatedControlID="txtCode" Text="4-digit code" />
            <asp:TextBox ID="txtCode" runat="server" MaxLength="4" inputmode="numeric" autocomplete="one-time-code" CssClass="code-input" />
            <asp:RequiredFieldValidator ID="rfvCode" runat="server" ControlToValidate="txtCode" ValidationGroup="Code" ErrorMessage="Enter the 4-digit code." Display="Dynamic" />
            <asp:RegularExpressionValidator ID="revCode" runat="server" ControlToValidate="txtCode" ValidationGroup="Code" ValidationExpression="^[0-9]{4}$" ErrorMessage="The code must be exactly 4 digits." Display="Dynamic" />
        </div>
        <p class="muted"><small><asp:Literal ID="litAttempts" runat="server" Mode="Encode" /></small></p>
        <div class="actions"><asp:Button ID="btnPay" runat="server" ValidationGroup="Code" OnClick="Pay" CssClass="esewa-button" /><asp:Button ID="btnChange" runat="server" Text="Use a different number" CausesValidation="false" OnClick="ChangeNumber" CssClass="secondary" /></div>
    </asp:Panel>
    <p class="esewa-foot"><%= LearningSystem.Helpers.UiHelper.Icon("lock") %> This is a practice payment screen for the Inkwell demo. No real money moves and no eSewa account is contacted.</p>
</div>
</asp:Content>
