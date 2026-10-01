<%@ Page Title="Teacher applications" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="TeacherApplications.aspx.cs" Inherits="LearningSystem.Admin.TeacherApplications" %>
<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
<h1>Teacher applications</h1>
<p>Approve or reject pending teacher applications. Only approval allows a teacher to log in.</p>
<div class="table-scroll" role="region" aria-label="Pending teacher applications" tabindex="0"><asp:GridView ID="gvApplications" runat="server" AutoGenerateColumns="false" DataKeyNames="UserID" Caption="Pending teacher applications" UseAccessibleHeader="true" EmptyDataText="There are no pending teacher applications." OnRowCommand="gvApplications_RowCommand">
<Columns>
<asp:BoundField DataField="FullName" HeaderText="Name" HtmlEncode="true" />
<asp:BoundField DataField="Email" HeaderText="Email" HtmlEncode="true" />
<asp:BoundField DataField="ApplicationReason" HeaderText="Application reason" HtmlEncode="true" />
<asp:BoundField DataField="CreatedDate" HeaderText="Applied (UTC)" DataFormatString="{0:dd MMM yyyy}" />
<asp:TemplateField HeaderText="Decision"><ItemTemplate>
<asp:Button ID="btnApprove" runat="server" Text="Approve" CommandName="Approve" CommandArgument='<%# Eval("UserID") %>' ValidationGroup="Action" />
<asp:Button ID="btnReject" runat="server" Text="Reject" CommandName="Reject" CommandArgument='<%# Eval("UserID") %>' ValidationGroup="Action" OnClientClick="return confirm('Reject this teacher application?');" />
</ItemTemplate></asp:TemplateField>
</Columns>
</asp:GridView></div>
<asp:Button ID="btnCancel" runat="server" Text="Cancel" CausesValidation="false" OnClick="btnCancel_Click" CssClass="secondary" />
</asp:Content>



