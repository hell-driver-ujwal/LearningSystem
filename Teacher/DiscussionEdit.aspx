<%@ Page Title="Discussion editor" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="DiscussionEdit.aspx.cs" Inherits="LearningSystem.Teacher.DiscussionEdit" %>
<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
<h1>Discussion editor</h1>
<asp:Label ID="lblLock" runat="server" Visible="false" Text="Attempts exist: quiz structure, order, time and attempt limits are locked. Title, description and publication remain editable." />
<section class="form-card"><h2>Settings</h2><asp:ValidationSummary ID="vsSettings" runat="server" ValidationGroup="Settings" />
<div class="field"><asp:Label ID="lblTitle" runat="server" AssociatedControlID="txtTitle" Text="Title" /><asp:TextBox ID="txtTitle" runat="server" TextMode="SingleLine" MaxLength="100" />
<asp:RegularExpressionValidator ID="revTitle" runat="server" ControlToValidate="txtTitle" ValidationGroup="Settings" ValidationExpression="^[\s\S]{5,100}$" ErrorMessage="Title must be 5–100 characters." />
<asp:RequiredFieldValidator ID="rfvTitle" runat="server" ControlToValidate="txtTitle" ValidationGroup="Settings" ErrorMessage="Enter Title." />
</div>
<div class="field"><asp:Label ID="lblDescription" runat="server" AssociatedControlID="txtDescription" Text="Description / prompt" /><asp:TextBox ID="txtDescription" runat="server" TextMode="MultiLine" MaxLength="1000" />
<asp:RegularExpressionValidator ID="revDescription" runat="server" ControlToValidate="txtDescription" ValidationGroup="Settings" ValidationExpression="^[\s\S]{10,1000}$" ErrorMessage="Description / prompt must be 10–1000 characters." />
<asp:RequiredFieldValidator ID="rfvDescription" runat="server" ControlToValidate="txtDescription" ValidationGroup="Settings" ErrorMessage="Enter Description / prompt." />
</div>
<div class="field"><asp:Label ID="lblOrder" runat="server" AssociatedControlID="txtOrder" Text="Activity order" /><asp:TextBox ID="txtOrder" runat="server" TextMode="Number" Text="1" />
<asp:RequiredFieldValidator ID="rfvOrder" runat="server" ControlToValidate="txtOrder" ValidationGroup="Settings" ErrorMessage="Enter Activity order." />
<asp:RangeValidator ID="rvOrder" runat="server" ControlToValidate="txtOrder" ValidationGroup="Settings" Type="Integer" MinimumValue="1" MaximumValue="2147483647" ErrorMessage="Activity order must be 1–2147483647." /></div>
<asp:Panel ID="pnlQuiz" runat="server">
<div class="field"><asp:Label ID="lblMinutes" runat="server" AssociatedControlID="txtMinutes" Text="Time limit minutes (0 = untimed)" /><asp:TextBox ID="txtMinutes" runat="server" TextMode="Number" Text="0" />
<asp:RequiredFieldValidator ID="rfvMinutes" runat="server" ControlToValidate="txtMinutes" ValidationGroup="Settings" ErrorMessage="Enter Time limit minutes (0 = untimed)." />
<asp:RangeValidator ID="rvMinutes" runat="server" ControlToValidate="txtMinutes" ValidationGroup="Settings" Type="Integer" MinimumValue="0" MaximumValue="180" ErrorMessage="Time limit minutes (0 = untimed) must be 0–180." /></div>
<div class="field"><asp:Label ID="lblAttempts" runat="server" AssociatedControlID="txtAttempts" Text="Maximum attempts (0 = unlimited)" /><asp:TextBox ID="txtAttempts" runat="server" TextMode="Number" Text="0" />
<asp:RequiredFieldValidator ID="rfvAttempts" runat="server" ControlToValidate="txtAttempts" ValidationGroup="Settings" ErrorMessage="Enter Maximum attempts (0 = unlimited)." />
<asp:RangeValidator ID="rvAttempts" runat="server" ControlToValidate="txtAttempts" ValidationGroup="Settings" Type="Integer" MinimumValue="0" MaximumValue="10" ErrorMessage="Maximum attempts (0 = unlimited) must be 0–10." /></div>
</asp:Panel><asp:Panel ID="pnlClosed" runat="server"><asp:CheckBox ID="chkClosed" runat="server" Text="Closed (read only for authors)" /></asp:Panel>
<div class="field"><asp:Label ID="lblStatus" runat="server" AssociatedControlID="ddlStatus" Text="Publication" /><asp:DropDownList ID="ddlStatus" runat="server"><asp:ListItem Text="Draft" /><asp:ListItem Text="Published" /></asp:DropDownList></div><div class="actions"><asp:Button ID="btnSave" runat="server" Text="Save settings" ValidationGroup="Settings" OnClick="SaveSettings" /><asp:Button ID="btnCancel" runat="server" Text="Cancel" CausesValidation="false" OnClick="Cancel" /><asp:HyperLink ID="lnkPreview" runat="server" Text="Preview" /><asp:Button ID="btnDelete" runat="server" Text="Delete activity" ValidationGroup="Action" OnClick="DeleteActivity" OnClientClick="return confirm('Delete this activity and all its content/posts? Attempts block deletion.');" /></div></section>
</asp:Content>
