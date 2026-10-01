<%@ Page Title="Course details" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="CourseEdit.aspx.cs" Inherits="LearningSystem.Teacher.CourseEdit" %>
<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
<div class="page-header"><div><h1>Course details</h1><p class="intro">Courses are saved as drafts. Add topics in the course builder, then publish from My courses.</p></div></div>
<section class="form-card" aria-label="Course details">
<asp:ValidationSummary ID="vsForm" runat="server" ValidationGroup="Save" CssClass="validation-summary" />
<div class="field"><asp:Label ID="lblTitle" runat="server" AssociatedControlID="txtTitle" Text="Title" />
<asp:TextBox ID="txtTitle" runat="server" MaxLength="100" />
<asp:RequiredFieldValidator ID="rfvTitle" runat="server" ControlToValidate="txtTitle" ValidationGroup="Save" ErrorMessage="Enter a title." />
<asp:RegularExpressionValidator ID="revTitle" runat="server" ControlToValidate="txtTitle" ValidationGroup="Save" ValidationExpression="^[\s\S]{5,100}$" ErrorMessage="Title must be 5 to 100 characters." /></div>
<div class="field"><asp:Label ID="lblSubject" runat="server" AssociatedControlID="ddlSubject" Text="Subject" />
<asp:DropDownList ID="ddlSubject" runat="server" />
<asp:RequiredFieldValidator ID="rfvSubject" runat="server" ControlToValidate="ddlSubject" ValidationGroup="Save" ErrorMessage="Choose a subject. Ask an administrator to add one if the list is empty." /></div>
<div class="field"><asp:Label ID="lblDescription" runat="server" AssociatedControlID="txtDescription" Text="Description" />
<asp:TextBox ID="txtDescription" runat="server" TextMode="MultiLine" Rows="6" MaxLength="1000" />
<asp:RequiredFieldValidator ID="rfvDescription" runat="server" ControlToValidate="txtDescription" ValidationGroup="Save" ErrorMessage="Enter a description." />
<asp:RegularExpressionValidator ID="revDescription" runat="server" ControlToValidate="txtDescription" ValidationGroup="Save" ValidationExpression="^[\s\S]{20,1000}$" ErrorMessage="Description must be 20 to 1000 characters." /></div>
<div class="field"><asp:Label ID="lblPricing" runat="server" AssociatedControlID="ddlPricing" Text="Course access" />
<asp:DropDownList ID="ddlPricing" runat="server" AutoPostBack="true" CausesValidation="false"><asp:ListItem Value="Free">Free</asp:ListItem><asp:ListItem Value="Paid">Paid</asp:ListItem></asp:DropDownList></div>
<div class="field"><asp:Label ID="lblPrice" runat="server" AssociatedControlID="txtPrice" Text="Price (NPR)" />
<asp:TextBox ID="txtPrice" runat="server" TextMode="Number" step="0.01" min="0.01" max="99999999.99" />
<asp:CustomValidator ID="cvPrice" runat="server" ValidationGroup="Save" OnServerValidate="ValidatePrice" ErrorMessage="Choose Free or enter a paid price from NPR 0.01 to 99,999,999.99 with at most two decimal places." /></div>
<div class="field"><asp:Label ID="lblCover" runat="server" AssociatedControlID="fuCover" Text="Cover image (optional JPG/PNG, up to 2 MB)" />
<asp:FileUpload ID="fuCover" runat="server" />
<asp:Literal ID="litCover" runat="server" Mode="Encode" />
<p>A new upload replaces the existing cover.</p></div>
<asp:CustomValidator ID="cvCourse" runat="server" ValidationGroup="Save" OnServerValidate="ValidateCourse" />
<div class="actions"><asp:Button ID="btnSave" runat="server" Text="Save course" ValidationGroup="Save" OnClick="SaveCourse" />
<asp:Button ID="btnCancel" runat="server" Text="Cancel" CausesValidation="false" OnClick="Cancel" CssClass="secondary" /></div>
</section>
</asp:Content>
