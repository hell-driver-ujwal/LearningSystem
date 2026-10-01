<%@ Page Title="My profile" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Profile.aspx.cs" Inherits="LearningSystem.Member.Profile" %>
<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
<div class="page-header"><div><h1>My profile</h1></div></div>
<p class="intro">
<asp:Literal ID="litDetails" runat="server" Mode="Encode" />
</p>
<section class="form-card" aria-label="Profile">
<asp:ValidationSummary ID="vsForm" runat="server" CssClass="validation-summary" HeaderText="Please check the following:" />
<div class="field">
<asp:Label ID="lblFullName" runat="server" AssociatedControlID="txtFullName" Text="Full name" />
<asp:TextBox ID="txtFullName" runat="server" MaxLength="100" autocomplete="name" />
<asp:RequiredFieldValidator ID="rfvFullName" runat="server" ControlToValidate="txtFullName" ErrorMessage="Enter your full name." CssClass="validation" Display="Dynamic" />
<asp:RegularExpressionValidator ID="revFullName" runat="server" ControlToValidate="txtFullName" ValidationExpression="^[A-Za-z '\-]{2,100}$" ErrorMessage="Name must be 2 to 100 letters, spaces, apostrophes or hyphens." CssClass="validation" Display="Dynamic" />
</div>
<div class="field">
<asp:Label ID="lblEmail" runat="server" AssociatedControlID="txtEmail" Text="Email address" />
<asp:TextBox ID="txtEmail" runat="server" TextMode="Email" MaxLength="100" autocomplete="email" />
<asp:RequiredFieldValidator ID="rfvEmail" runat="server" ControlToValidate="txtEmail" ErrorMessage="Enter your email address." CssClass="validation" Display="Dynamic" />
<asp:RegularExpressionValidator ID="revEmail" runat="server" ControlToValidate="txtEmail" ValidationExpression="^(?=.{1,100}$)[^\s@]+@[^\s@.]+(?:\.[^\s@.]+)+$" ErrorMessage="Enter a valid email address of up to 100 characters." CssClass="validation" Display="Dynamic" />
</div>
<asp:CustomValidator ID="cvEmail" runat="server" ControlToValidate="txtEmail" OnServerValidate="ValidateEmail" ErrorMessage="That email address is already registered." CssClass="validation" Display="Dynamic" />
<div class="actions">
<asp:Button ID="btnSave" runat="server" Text="Save profile" OnClick="btnSave_Click" />
<asp:HyperLink ID="lnkCancel" runat="server" NavigateUrl="~/Default.aspx" CssClass="button secondary" Text="Cancel" />
</div>
<p>
<asp:HyperLink ID="lnkPassword" runat="server" NavigateUrl="~/Member/ChangePassword.aspx" Text="Change password" />
</p>
</section>
</asp:Content>

