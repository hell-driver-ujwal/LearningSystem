<%@ Page Title="Material editor" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="MaterialEdit.aspx.cs" Inherits="LearningSystem.Teacher.MaterialEdit" %>
<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
<h1>Material editor</h1>
<p><asp:Literal ID="litTopic" runat="server" Mode="Encode" /></p>
<section class="form-card" aria-label="Material details">
<asp:ValidationSummary ID="vsForm" runat="server" ValidationGroup="Save" CssClass="validation-summary" />
<div class="field"><asp:Label ID="lblTitle" runat="server" AssociatedControlID="txtTitle" Text="Title" /><asp:TextBox ID="txtTitle" runat="server" MaxLength="100" />
<asp:RequiredFieldValidator ID="rfvTitle" runat="server" ControlToValidate="txtTitle" ValidationGroup="Save" ErrorMessage="Enter a title." />
<asp:RegularExpressionValidator ID="revTitle" runat="server" ControlToValidate="txtTitle" ValidationGroup="Save" ValidationExpression="^[\s\S]{3,100}$" ErrorMessage="Material title must be 3–100 characters." /></div>
<div class="field"><asp:Label ID="lblType" runat="server" AssociatedControlID="ddlType" Text="Material type (choose before uploading a file)" />
<asp:DropDownList ID="ddlType" runat="server" AutoPostBack="true"><asp:ListItem>Text</asp:ListItem><asp:ListItem>Image</asp:ListItem><asp:ListItem>PDF</asp:ListItem><asp:ListItem>Video</asp:ListItem><asp:ListItem>Audio</asp:ListItem><asp:ListItem>YouTube</asp:ListItem></asp:DropDownList></div>
<asp:Panel ID="pnlText" runat="server" CssClass="field"><asp:Label ID="lblText" runat="server" AssociatedControlID="txtText" Text="Lesson text (20–10,000 characters; plain text only)" /><asp:TextBox ID="txtText" runat="server" TextMode="MultiLine" Rows="12" MaxLength="10000" /></asp:Panel>
<asp:Panel ID="pnlFile" runat="server" CssClass="field"><asp:Label ID="lblFile" runat="server" AssociatedControlID="fuFile" Text="File (upload to add or replace)" /><asp:FileUpload ID="fuFile" runat="server" />
<p>Images: JPG/PNG/GIF up to 2 MB. PDF/MP3 up to 10 MB. MP4 up to 25 MB.</p>
<asp:Literal ID="litFile" runat="server" Mode="Encode" /></asp:Panel>
<asp:Panel ID="pnlAlt" runat="server" CssClass="field"><asp:Label ID="lblAlt" runat="server" AssociatedControlID="txtAlt" Text="Image alt text (5–150 characters)" /><asp:TextBox ID="txtAlt" runat="server" MaxLength="150" /></asp:Panel>
<asp:Panel ID="pnlYouTube" runat="server" CssClass="field"><asp:Label ID="lblYouTube" runat="server" AssociatedControlID="txtYouTube" Text="YouTube URL (youtube.com/watch or youtu.be)" /><asp:TextBox ID="txtYouTube" runat="server" TextMode="Url" MaxLength="500" />
<asp:RegularExpressionValidator ID="revYouTube" runat="server" ControlToValidate="txtYouTube" ValidationGroup="Save" ValidationExpression="^https?://(www\.)?(youtube\.com/watch\?[^\s]+|youtu\.be/[^\s]+)$" ErrorMessage="Use a youtube.com/watch or youtu.be URL." /></asp:Panel>
<div class="field"><asp:Label ID="lblOrder" runat="server" AssociatedControlID="txtOrder" Text="Order (positive integer; ties allowed)" /><asp:TextBox ID="txtOrder" runat="server" TextMode="Number" />
<asp:RequiredFieldValidator ID="rfvOrder" runat="server" ControlToValidate="txtOrder" ValidationGroup="Save" ErrorMessage="Enter an order." />
<asp:RangeValidator ID="rvOrder" runat="server" ControlToValidate="txtOrder" ValidationGroup="Save" Type="Integer" MinimumValue="1" MaximumValue="2147483647" ErrorMessage="Order must be a positive integer no greater than 2147483647." /></div>
<div class="field"><asp:Label ID="lblStatus" runat="server" AssociatedControlID="ddlStatus" Text="Status" /><asp:DropDownList ID="ddlStatus" runat="server"><asp:ListItem>Draft</asp:ListItem><asp:ListItem>Published</asp:ListItem></asp:DropDownList></div>
<div class="field"><asp:CheckBox ID="chkPreview" runat="server" Text="Allow free preview when this material and its course are published" /></div>
<asp:CustomValidator ID="cvMaterial" runat="server" ValidationGroup="Save" OnServerValidate="ValidateMaterial" />
<div class="actions"><asp:Button ID="btnSave" runat="server" Text="Save material" ValidationGroup="Save" OnClick="SaveMaterial" /><asp:Button ID="btnCancel" runat="server" Text="Cancel" CausesValidation="false" OnClick="Cancel" CssClass="secondary" /></div>
</section>
</asp:Content>
