<%@ Page Title="Manage users" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Users.aspx.cs" Inherits="LearningSystem.Admin.Users" %>
<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
<h1>Manage users</h1>
<p><a href="UserEdit.aspx" class="button">Create learner or teacher</a></p>
<section class="filter-bar" aria-label="Filter users">
<asp:ValidationSummary ID="vsSearch" runat="server" ValidationGroup="Search" CssClass="validation-summary" />
<div class="field"><asp:Label ID="lblSearch" runat="server" AssociatedControlID="txtSearch" Text="Name or email" />
<asp:TextBox ID="txtSearch" runat="server" TextMode="Search" MaxLength="50" />
<asp:RegularExpressionValidator ID="revSearch" runat="server" ControlToValidate="txtSearch" ValidationGroup="Search" ValidationExpression="^[\s\S]{0,50}$" ErrorMessage="Search must be at most 50 characters." /></div>
<div class="field"><asp:Label ID="lblRole" runat="server" AssociatedControlID="ddlRole" Text="Role" />
<asp:DropDownList ID="ddlRole" runat="server"><asp:ListItem Value="">All roles</asp:ListItem><asp:ListItem>Learner</asp:ListItem><asp:ListItem>Teacher</asp:ListItem><asp:ListItem>Admin</asp:ListItem></asp:DropDownList></div>
<div class="field"><asp:Label ID="lblStatus" runat="server" AssociatedControlID="ddlStatus" Text="Status" />
<asp:DropDownList ID="ddlStatus" runat="server"><asp:ListItem Value="">All statuses</asp:ListItem><asp:ListItem>Active</asp:ListItem><asp:ListItem>Deactivated</asp:ListItem><asp:ListItem>Pending</asp:ListItem><asp:ListItem>Rejected</asp:ListItem></asp:DropDownList></div>
<asp:Button ID="btnSearch" runat="server" Text="Apply filters" ValidationGroup="Search" OnClick="btnSearch_Click" />
<asp:Button ID="btnCancel" runat="server" Text="Cancel" CausesValidation="false" OnClick="btnCancel_Click" CssClass="secondary" />
</section>
<p>Admin account actions are disabled. Review pending teachers on the <a href="TeacherApplications.aspx">applications page</a>.</p>
<div class="table-scroll" role="region" aria-label="Users" tabindex="0"><asp:GridView ID="gvUsers" runat="server" AutoGenerateColumns="false" DataKeyNames="UserID" Caption="Users" UseAccessibleHeader="true" EmptyDataText="No users match these filters." AllowPaging="true" PageSize="10" OnPageIndexChanging="gvUsers_PageIndexChanging" OnRowCommand="gvUsers_RowCommand">
<Columns>
<asp:BoundField DataField="FullName" HeaderText="Name" HtmlEncode="true" />
<asp:BoundField DataField="Email" HeaderText="Email" HtmlEncode="true" />
<asp:BoundField DataField="Role" HeaderText="Role" />
<asp:BoundField DataField="Status" HeaderText="Status" />
<asp:BoundField DataField="FailedLoginCount" HeaderText="Failed logins" /><asp:BoundField DataField="LockedUntil" HeaderText="Locked until (UTC)" DataFormatString="{0:yyyy-MM-dd HH:mm:ss}" />
<asp:TemplateField HeaderText="Actions"><ItemTemplate>
<asp:HyperLink ID="lnkEdit" runat="server" Text="Edit / reset password" NavigateUrl='<%# "~/Admin/UserEdit.aspx?id=" + Eval("UserID") %>' Enabled='<%# (string)Eval("Role") != "Admin" %>' />
<asp:Button ID="btnStatus" runat="server" Text='<%# (string)Eval("Status") == "Active" ? "Deactivate" : "Activate" %>' CommandName='<%# (string)Eval("Status") == "Active" ? "DeactivateUser" : "ActivateUser" %>' CommandArgument='<%# Eval("UserID") %>' ValidationGroup="Action" Enabled='<%# (string)Eval("Role") != "Admin" && ((string)Eval("Status") == "Active" || (string)Eval("Status") == "Deactivated") %>' />
<asp:Button ID="btnUnlock" runat="server" Text="Unlock" CommandName="UnlockUser" CommandArgument='<%# Eval("UserID") %>' ValidationGroup="Action" Enabled='<%# (string)Eval("Role") != "Admin" %>' />
<asp:Button ID="btnDeleteUser" runat="server" Text="Delete" CommandName="DeleteUser" CommandArgument='<%# Eval("UserID") %>' ValidationGroup="Action" Enabled='<%# (string)Eval("Role") != "Admin" %>' OnClientClick="return confirm('Delete this user and their learning records? Replies to their posts will also be deleted.');" />
</ItemTemplate></asp:TemplateField>
</Columns>
</asp:GridView></div>
</asp:Content>



