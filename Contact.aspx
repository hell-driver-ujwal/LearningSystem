<%@ Page Title="Contact us" MetaDescription="Send a message to the Inkwell team about courses, your account or teaching." Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Contact.aspx.cs" Inherits="LearningSystem.Contact" %>
<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
<div class="page-header"><div><h1>Contact us</h1><p class="intro">Questions about a course, your account or teaching on Inkwell? Send us a message and we will reply by email.</p></div></div>
<div class="split">
<section class="form-card wide" aria-labelledby="message-title"><h2 id="message-title">Your message</h2><asp:ValidationSummary ID="vsForm" runat="server" />
<div class="form-grid">
<div class="field"><asp:Label ID="lblName" runat="server" AssociatedControlID="txtName" Text="Your name" /><asp:TextBox ID="txtName" runat="server" TextMode="SingleLine" MaxLength="100" autocomplete="name" /><asp:RequiredFieldValidator ID="rfvName" runat="server" ControlToValidate="txtName" ErrorMessage="Enter your name." Display="Dynamic" /><asp:RegularExpressionValidator ID="revName" runat="server" ControlToValidate="txtName" ValidationExpression="^[\s\S]{2,100}$" ErrorMessage="Name must be 2 to 100 characters." Display="Dynamic" /></div>
<div class="field"><asp:Label ID="lblEmail" runat="server" AssociatedControlID="txtEmail" Text="Email address" /><asp:TextBox ID="txtEmail" runat="server" TextMode="Email" MaxLength="100" autocomplete="email" /><asp:RequiredFieldValidator ID="rfvEmail" runat="server" ControlToValidate="txtEmail" ErrorMessage="Enter your email address." Display="Dynamic" /><asp:RegularExpressionValidator ID="revEmail" runat="server" ControlToValidate="txtEmail" ValidationExpression="^[\s\S]{3,100}$" ErrorMessage="Email address must be 3 to 100 characters." Display="Dynamic" /></div>
</div>
<div class="field"><asp:Label ID="lblSubject" runat="server" AssociatedControlID="txtSubject" Text="Subject" /><asp:TextBox ID="txtSubject" runat="server" TextMode="SingleLine" MaxLength="100" placeholder="For example: Question about the Python course" /><asp:RequiredFieldValidator ID="rfvSubject" runat="server" ControlToValidate="txtSubject" ErrorMessage="Enter a subject." Display="Dynamic" /><asp:RegularExpressionValidator ID="revSubject" runat="server" ControlToValidate="txtSubject" ValidationExpression="^[\s\S]{3,100}$" ErrorMessage="Subject must be 3 to 100 characters." Display="Dynamic" /></div>
<div class="field"><asp:Label ID="lblMessage" runat="server" AssociatedControlID="txtMessage" Text="Message" /><asp:TextBox ID="txtMessage" runat="server" TextMode="MultiLine" MaxLength="2000" Rows="7" /><span class="hint">10 to 2000 characters. Please do not include passwords or payment details.</span><asp:RequiredFieldValidator ID="rfvMessage" runat="server" ControlToValidate="txtMessage" ErrorMessage="Enter your message." Display="Dynamic" /><asp:RegularExpressionValidator ID="revMessage" runat="server" ControlToValidate="txtMessage" ValidationExpression="^[\s\S]{10,2000}$" ErrorMessage="Message must be 10 to 2000 characters." Display="Dynamic" /></div>
<div class="field"><asp:Label ID="lblCaptcha" runat="server" AssociatedControlID="txtCaptcha" /><asp:TextBox ID="txtCaptcha" runat="server" TextMode="Number" autocomplete="off" style="max-width:160px" /><span class="hint">This short sum helps us block automated messages.</span><asp:RequiredFieldValidator ID="rfvCaptcha" runat="server" ControlToValidate="txtCaptcha" ErrorMessage="Answer the sum." Display="Dynamic" /><asp:CompareValidator ID="cvNumber" runat="server" ControlToValidate="txtCaptcha" Operator="DataTypeCheck" Type="Integer" ErrorMessage="Enter a whole number." Display="Dynamic" /><asp:CustomValidator ID="cvCaptcha" runat="server" ValidateEmptyText="true" OnServerValidate="ValidateCaptcha" ErrorMessage="That answer was not correct, or the question expired. Answer the new sum." Display="Dynamic" /></div>
<asp:CustomValidator ID="cvForm" runat="server" ValidateEmptyText="true" OnServerValidate="ValidateContact" ErrorMessage="Check the message fields and the email format." Display="Dynamic" />
<div class="actions"><asp:Button ID="btnSend" runat="server" Text="Send message" OnClick="Send" /><a class="button secondary" href="Default.aspx">Cancel</a></div>
<p class="muted"><small>We use your details only to reply to you. See our <a href="Privacy.aspx">Privacy policy</a>.</small></p>
</section>
<aside>
    <section class="card" aria-labelledby="other-title">
        <h2 id="other-title">Other ways to reach us</h2>
        <ul class="contact-list">
            <li><%= LearningSystem.Helpers.UiHelper.Icon("mail") %><span><strong>Email</strong><br /><a href="mailto:<%: LearningSystem.Helpers.UiHelper.ContactEmail %>"><%: LearningSystem.Helpers.UiHelper.ContactEmail %></a></span></li>
            <li><%= LearningSystem.Helpers.UiHelper.Icon("pin") %><span><strong>Office</strong><br /><%: LearningSystem.Helpers.UiHelper.ContactAddress %></span></li>
            <li><%= LearningSystem.Helpers.UiHelper.Icon("clock") %><span><strong>Replies</strong><br />Usually within two working days</span></li>
        </ul>
    </section>
    <section class="card" aria-labelledby="quick-title" style="margin-top:20px">
        <h2 id="quick-title">Quick answers</h2>
        <ul><li><a href="Help.aspx#faq-title">Course progress and certificates</a></li><li><a href="Help.aspx#lecturers">Becoming a lecturer</a></li><li><a href="Help.aspx#shortcuts">Keyboard shortcuts</a></li></ul>
    </section>
</aside>
</div>
</asp:Content>
