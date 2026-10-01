<%@ Page Title="Create or edit user" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="UserEdit.aspx.cs" Inherits="LearningSystem.Admin.UserEdit" %>
<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
<div class="page-header"><div><h1>Learner or lecturer account</h1><p class="intro">New accounts and password resets use a temporary password that must be changed at the next log in.</p></div></div>
<section class="form-card" aria-label="User details">
<asp:ValidationSummary ID="vsSave" runat="server" ValidationGroup="Save" CssClass="validation-summary" />
<asp:ValidationSummary ID="vsReset" runat="server" ValidationGroup="Reset" CssClass="validation-summary" />
<p><asp:Literal ID="litMode" runat="server" Mode="Encode" /></p>
<div class="field"><asp:Label ID="lblFullName" runat="server" AssociatedControlID="txtFullName" Text="Full name" />
<asp:TextBox ID="txtFullName" runat="server" MaxLength="100" />
<asp:RequiredFieldValidator ID="rfvFullName" runat="server" ControlToValidate="txtFullName" ValidationGroup="Save" ErrorMessage="Enter a full name." Display="Dynamic" />
<asp:RegularExpressionValidator ID="revFullName" runat="server" ControlToValidate="txtFullName" ValidationGroup="Save" ValidationExpression="^[A-Za-z '\-]{2,100}$" ErrorMessage="Name must be 2 to 100 letters, spaces, apostrophes or hyphens." Display="Dynamic" /></div>
<div class="field"><asp:Label ID="lblEmail" runat="server" AssociatedControlID="txtEmail" Text="Email" />
<asp:TextBox ID="txtEmail" runat="server" TextMode="Email" MaxLength="100" />
<asp:RequiredFieldValidator ID="rfvEmail" runat="server" ControlToValidate="txtEmail" ValidationGroup="Save" ErrorMessage="Enter an email." Display="Dynamic" />
<asp:RegularExpressionValidator ID="revEmail" runat="server" ControlToValidate="txtEmail" ValidationGroup="Save" ValidationExpression="^(?=.{1,100}$)[^\s@]+@[^\s@.]+(?:\.[^\s@.]+)+$" ErrorMessage="Enter a valid email of up to 100 characters." Display="Dynamic" /></div>
<div class="field"><asp:Label ID="lblRole" runat="server" AssociatedControlID="ddlRole" Text="Role (fixed after creation)" />
<asp:DropDownList ID="ddlRole" runat="server"><asp:ListItem Value="">Choose role</asp:ListItem><asp:ListItem>Learner</asp:ListItem><asp:ListItem Value="Teacher">Lecturer</asp:ListItem></asp:DropDownList>
<asp:RequiredFieldValidator ID="rfvRole" runat="server" ControlToValidate="ddlRole" ValidationGroup="Save" ErrorMessage="Choose Learner or Lecturer." Display="Dynamic" /></div>
<div class="field"><asp:Label ID="lblStatus" runat="server" AssociatedControlID="ddlStatus" Text="Status" />
<asp:DropDownList ID="ddlStatus" runat="server"><asp:ListItem>Active</asp:ListItem><asp:ListItem>Deactivated</asp:ListItem></asp:DropDownList>
<asp:RequiredFieldValidator ID="rfvStatus" runat="server" ControlToValidate="ddlStatus" ValidationGroup="Save" ErrorMessage="Choose a status." Display="Dynamic" />
<asp:Literal ID="litApplication" runat="server" Mode="Encode" /></div>
<asp:CustomValidator ID="cvUser" runat="server" ValidationGroup="Save" OnServerValidate="ValidateUser" ErrorMessage="Check user details." Display="Dynamic" />
<div class="field"><asp:Label ID="lblPassword" runat="server" AssociatedControlID="txtPassword" Text="Temporary password (create or reset only)" />
<asp:TextBox ID="txtPassword" runat="server" TextMode="Password" MaxLength="50" autocomplete="new-password" />
<asp:RequiredFieldValidator ID="rfvPassword" runat="server" ControlToValidate="txtPassword" ValidationGroup="Save" ErrorMessage="Enter a temporary password." Display="Dynamic" />
<asp:RegularExpressionValidator ID="revPassword" runat="server" ControlToValidate="txtPassword" ValidationGroup="Save" ValidationExpression="^(?=.*[A-Za-z])(?=.*[0-9]).{8,50}$" ErrorMessage="Password must be 8 to 50 characters with a letter and a number." Display="Dynamic" /></div>
<div class="actions">
<asp:Button ID="btnSave" runat="server" Text="Save user" ValidationGroup="Save" OnClick="btnSave_Click" />
<asp:Button ID="btnReset" runat="server" Text="Reset password" ValidationGroup="Reset" OnClick="btnReset_Click" OnClientClick="return confirm('Replace this user password with the temporary password entered?');" />
<asp:Button ID="btnCancel" runat="server" Text="Cancel" CausesValidation="false" OnClick="btnCancel_Click" CssClass="secondary" />
</div>
</section>
</asp:Content>

