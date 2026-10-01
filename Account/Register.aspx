<%@ Page Title="Create an account" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Register.aspx.cs" Inherits="LearningSystem.Account.Register" %>
<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
<h1>Create an account</h1>
<p class="intro">Join as a learner, or apply to teach. Teacher applications need administrator approval.</p>
<section class="form-card" aria-label="Registration">
<asp:ValidationSummary ID="vsForm" runat="server" CssClass="validation-summary" HeaderText="Please check the following:" />
<div class="field">
<asp:Label ID="lblFullName" runat="server" AssociatedControlID="txtFullName" Text="Full name" />
<asp:TextBox ID="txtFullName" runat="server" MaxLength="100" autocomplete="name" />
<asp:RequiredFieldValidator ID="rfvFullName" runat="server" ControlToValidate="txtFullName" ErrorMessage="Enter your full name." CssClass="validation" Display="Dynamic" />
<asp:RegularExpressionValidator ID="revFullName" runat="server" ControlToValidate="txtFullName" ValidationExpression="^[A-Za-z '\-]{2,100}$" ErrorMessage="Name must be 2–100 letters, spaces, apostrophes or hyphens." CssClass="validation" Display="Dynamic" />
</div>
<div class="field">
<asp:Label ID="lblEmail" runat="server" AssociatedControlID="txtEmail" Text="Email address" />
<asp:TextBox ID="txtEmail" runat="server" TextMode="Email" MaxLength="100" autocomplete="email" />
<asp:RequiredFieldValidator ID="rfvEmail" runat="server" ControlToValidate="txtEmail" ErrorMessage="Enter your email address." CssClass="validation" Display="Dynamic" />
<asp:RegularExpressionValidator ID="revEmail" runat="server" ControlToValidate="txtEmail" ValidationExpression="^(?=.{1,100}$)[^\s@]+@[^\s@.]+(?:\.[^\s@.]+)+$" ErrorMessage="Enter a valid email address of up to 100 characters." CssClass="validation" Display="Dynamic" />
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
<div class="field">
<asp:Label ID="lblRole" runat="server" AssociatedControlID="ddlRole" Text="Account type" />
<asp:DropDownList ID="ddlRole" runat="server">
<asp:ListItem Value="">Choose account type</asp:ListItem>
<asp:ListItem Value="Learner">Learner</asp:ListItem>
<asp:ListItem Value="Teacher">Teacher application</asp:ListItem>
</asp:DropDownList>
<asp:RequiredFieldValidator ID="rfvRole" runat="server" ControlToValidate="ddlRole" ErrorMessage="Choose an account type." CssClass="validation" Display="Dynamic" />
</div>
<div class="field">
<asp:Label ID="lblReason" runat="server" AssociatedControlID="txtReason" Text="Application reason (teachers only)" />
<asp:TextBox ID="txtReason" runat="server" TextMode="MultiLine" Rows="5" aria-describedby="reason-hint" />
<span class="hint" id="reason-hint">Teachers: describe why you want to teach in 20–500 characters. Learners can leave this blank.</span>
<asp:CustomValidator ID="cvRegistration" runat="server" ValidateEmptyText="true" OnServerValidate="ValidateRegistration" ErrorMessage="Check your registration details." CssClass="validation" Display="Dynamic" />
</div>
<div class="field">
<asp:Label ID="lblCaptcha" runat="server" AssociatedControlID="txtCaptcha" />
<asp:TextBox ID="txtCaptcha" runat="server" TextMode="Number" autocomplete="off" />
<asp:RequiredFieldValidator ID="rfvCaptcha" runat="server" ControlToValidate="txtCaptcha" ErrorMessage="Answer the arithmetic question." Display="Dynamic" />
<asp:CompareValidator ID="cvCaptchaNumber" runat="server" ControlToValidate="txtCaptcha" Operator="DataTypeCheck" Type="Integer" ErrorMessage="Enter a whole number." Display="Dynamic" />
<asp:CustomValidator ID="cvCaptcha" runat="server" OnServerValidate="ValidateCaptcha" ValidateEmptyText="true" ErrorMessage="CAPTCHA incorrect or expired. Answer the new question." Display="Dynamic" />
</div>
<div class="actions">
<asp:Button ID="btnRegister" runat="server" Text="Register" OnClick="btnRegister_Click" />
<asp:HyperLink ID="lnkCancel" runat="server" NavigateUrl="~/Default.aspx" CssClass="button secondary" Text="Cancel" />
</div>
</section>
</asp:Content>

