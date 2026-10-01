<%@ Page Title="Manage subjects" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Subjects.aspx.cs" Inherits="LearningSystem.Admin.Subjects" %>
<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
<h1>Manage subjects</h1>
<p>Add and maintain the subjects used by courses.</p>
<section class="form-card" aria-label="Subject details">
<asp:ValidationSummary ID="vsForm" runat="server" ValidationGroup="Subject" CssClass="validation-summary" />
<asp:HiddenField ID="hfSubjectID" runat="server" />
<div class="field">
<asp:Label ID="lblName" runat="server" AssociatedControlID="txtName" Text="Subject name" />
<asp:TextBox ID="txtName" runat="server" MaxLength="50" />
<asp:RequiredFieldValidator ID="rfvName" runat="server" ControlToValidate="txtName" ValidationGroup="Subject" ErrorMessage="Enter a subject name." Display="Dynamic" />
<asp:RegularExpressionValidator ID="revName" runat="server" ControlToValidate="txtName" ValidationGroup="Subject" ValidationExpression="^[\s\S]{2,50}$" ErrorMessage="Use 2–50 characters for the name." Display="Dynamic" />
</div>
<div class="field">
<asp:Label ID="lblDescription" runat="server" AssociatedControlID="txtDescription" Text="Description (optional)" />
<asp:TextBox ID="txtDescription" runat="server" TextMode="MultiLine" Rows="3" MaxLength="300" />
<asp:RegularExpressionValidator ID="revDescription" runat="server" ControlToValidate="txtDescription" ValidationGroup="Subject" ValidationExpression="^[\s\S]{0,300}$" ErrorMessage="Description must be at most 300 characters." Display="Dynamic" />
</div>
<asp:CustomValidator ID="cvSubject" runat="server" ValidationGroup="Subject" OnServerValidate="ValidateSubject" ErrorMessage="That subject name already exists." Display="Dynamic" />
<div class="actions">
<asp:Button ID="btnSave" runat="server" Text="Save subject" ValidationGroup="Subject" OnClick="btnSave_Click" />
<asp:Button ID="btnCancel" runat="server" Text="Cancel" CausesValidation="false" OnClick="btnCancel_Click" CssClass="secondary" />
</div>
</section>
<div class="table-scroll" role="region" aria-label="Subjects" tabindex="0"><asp:GridView ID="gvSubjects" runat="server" AutoGenerateColumns="false" DataKeyNames="SubjectID" Caption="Subjects" UseAccessibleHeader="true" EmptyDataText="No subjects yet. Add the first subject above." OnRowCommand="gvSubjects_RowCommand">
<Columns>
<asp:BoundField DataField="SubjectName" HeaderText="Name" HtmlEncode="true" />
<asp:BoundField DataField="Description" HeaderText="Description" HtmlEncode="true" />
<asp:BoundField DataField="CourseCount" HeaderText="Courses" />
<asp:TemplateField HeaderText="Actions"><ItemTemplate>
<asp:Button ID="btnEditSubject" runat="server" Text="Edit" CommandName="EditSubject" CommandArgument='<%# Eval("SubjectID") %>' ValidationGroup="Action" />
<asp:Button ID="btnDeleteSubject" runat="server" Text="Delete" CommandName="DeleteSubject" CommandArgument='<%# Eval("SubjectID") %>' ValidationGroup="Action" OnClientClick="return confirm('Delete this subject? Subjects used by courses cannot be deleted.');" />
</ItemTemplate></asp:TemplateField>
</Columns>
</asp:GridView></div>
</asp:Content>



