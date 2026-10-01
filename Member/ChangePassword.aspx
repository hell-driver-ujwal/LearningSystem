<%@ Page Title="Change password" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ChangePassword.aspx.cs" Inherits="LearningSystem.Member.ChangePassword" %>
<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
<h1>Change password</h1>
<p class="intro">Choose a new password that differs from your current password.</p>
<section class="form-card" aria-label="Change password">
<asp:ValidationSummary ID="vsForm" runat="server" CssClass="validation-summary" HeaderText="Please check the following:" />
<div class="field">
<asp:Label ID="lblCurrent" runat="server" AssociatedControlID="txtCurrent" Text="Current password" />
<asp:TextBox ID="txtCurrent" runat="server" TextMode="Password" autocomplete="current-password" />
<asp:RequiredFieldValidator ID="rfvCurrent" runat="server" ControlToValidate="txtCurrent" ErrorMessage="Enter your current password." CssClass="validation" Display="Dynamic" />
</div>
<div class="field">
<asp:Label ID="lblPassword" runat="server" AssociatedControlID="txtPassword" Text="New password" />
<asp:TextBox ID="txtPassword" runat="server" TextMode="Password" MaxLength="50" autocomplete="new-password" aria-describedby="password-hint" />
<span id="password-hint" class="hint">8–50 characters, including at least one letter and one number.</span>
<asp:RequiredFieldValidator ID="rfvPassword" runat="server" ControlToValidate="txtPassword" ErrorMessage="Enter a new password." CssClass="validation" Display="Dynamic" />
<asp:RegularExpressionValidator ID="revPassword" runat="server" ControlToValidate="txtPassword" ValidationExpression="^(?=.*[A-Za-z])(?=.*[0-9]).{8,50}$" ErrorMessage="Password must be 8–50 characters with a letter and a number." CssClass="validation" Display="Dynamic" />
</div>
<div class="field">
<asp:Label ID="lblConfirm" runat="server" AssociatedControlID="txtConfirm" Text="Confirm new password" />
<asp:TextBox ID="txtConfirm" runat="server" TextMode="Password" MaxLength="50" autocomplete="new-password" />
<asp:RequiredFieldValidator ID="rfvConfirm" runat="server" ControlToValidate="txtConfirm" ErrorMessage="Confirm your new password." CssClass="validation" Display="Dynamic" />
<asp:CompareValidator ID="cvConfirm" runat="server" ControlToValidate="txtConfirm" ControlToCompare="txtPassword" ErrorMessage="The new passwords must match." CssClass="validation" Display="Dynamic" />
</div>
<div class="actions">
<asp:Button ID="btnSave" runat="server" Text="Change password" OnClick="btnSave_Click" />
<asp:HyperLink ID="lnkCancel" runat="server" NavigateUrl="~/Member/Profile.aspx" CssClass="button secondary" Text="Cancel" />
</div>
</section>
</asp:Content>

