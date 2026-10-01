<%@ Page Title="Student Portal" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="StudentLogin.aspx.cs" Inherits="LearningSystem.Account.StudentLogin" %>
<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
<h1>Student Portal</h1>
<p class="intro">Your next lesson starts here.</p>
<section class="form-card portal-student" aria-label="Login">
<asp:ValidationSummary ID="vsForm" runat="server" CssClass="validation-summary" HeaderText="Please check the following:" />
<div class="field">
<asp:Label ID="lblEmail" runat="server" AssociatedControlID="txtEmail" Text="Email address" />
<asp:TextBox ID="txtEmail" runat="server" TextMode="Email" MaxLength="100" autocomplete="username" />
<asp:RequiredFieldValidator ID="rfvEmail" runat="server" ControlToValidate="txtEmail" ErrorMessage="Enter your email address." CssClass="validation" Display="Dynamic" />
</div>
<div class="field">
<asp:Label ID="lblPassword" runat="server" AssociatedControlID="txtPassword" Text="Password" />
<asp:TextBox ID="txtPassword" runat="server" TextMode="Password" autocomplete="current-password" />
<asp:RequiredFieldValidator ID="rfvPassword" runat="server" ControlToValidate="txtPassword" ErrorMessage="Enter your password." CssClass="validation" Display="Dynamic" />
</div>
<div class="actions">
<asp:Button ID="btnLogin" runat="server" Text="Log in" OnClick="btnLogin_Click" />
<asp:HyperLink ID="lnkCancel" runat="server" NavigateUrl="~/Default.aspx" CssClass="button secondary" Text="Cancel" />
</div>
<p>New here? <asp:HyperLink ID="lnkRegister" runat="server" NavigateUrl="~/Account/Register.aspx" Text="Create an account" />
</p>
<p><a href="Login.aspx">Choose another portal</a></p></section>
</asp:Content>

