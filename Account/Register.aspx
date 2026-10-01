<%@ Page Title="Create an account" MetaDescription="Create a free Inkwell learner account, or apply to teach as a lecturer." Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Register.aspx.cs" Inherits="LearningSystem.Account.Register" %>
<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
<div class="auth-layout">
<section class="auth-form" aria-labelledby="register-title">
<h1 id="register-title">Create your account</h1>
<p class="muted">Learner accounts are free and open straight away. Lecturer applications are reviewed by our team first.</p>
<div class="form-card">
<asp:ValidationSummary ID="vsForm" runat="server" CssClass="validation-summary" HeaderText="Please check the following:" />
<div class="field">
<asp:Label ID="lblRole" runat="server" AssociatedControlID="ddlRole" Text="I want to" />
<asp:DropDownList ID="ddlRole" runat="server">
<asp:ListItem Value="">Choose an account type</asp:ListItem>
<asp:ListItem Value="Learner">Learn: free learner account</asp:ListItem>
<asp:ListItem Value="Teacher">Teach: lecturer application</asp:ListItem>
</asp:DropDownList>
<asp:RequiredFieldValidator ID="rfvRole" runat="server" ControlToValidate="ddlRole" ErrorMessage="Choose an account type." CssClass="validation" Display="Dynamic" />
</div>
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
<div class="form-grid">
<div class="field">
<asp:Label ID="lblPassword" runat="server" AssociatedControlID="txtPassword" Text="Password" />
<asp:TextBox ID="txtPassword" runat="server" TextMode="Password" MaxLength="50" autocomplete="new-password" aria-describedby="password-hint" data-password="true" />
<asp:RequiredFieldValidator ID="rfvPassword" runat="server" ControlToValidate="txtPassword" ErrorMessage="Enter a password." CssClass="validation" Display="Dynamic" />
<asp:RegularExpressionValidator ID="revPassword" runat="server" ControlToValidate="txtPassword" ValidationExpression="^(?=.*[A-Za-z])(?=.*[0-9]).{8,50}$" ErrorMessage="Password must be 8 to 50 characters with a letter and a number." CssClass="validation" Display="Dynamic" />
</div>
<div class="field">
<asp:Label ID="lblConfirm" runat="server" AssociatedControlID="txtConfirm" Text="Confirm password" />
<asp:TextBox ID="txtConfirm" runat="server" TextMode="Password" MaxLength="50" autocomplete="new-password" />
<asp:RequiredFieldValidator ID="rfvConfirm" runat="server" ControlToValidate="txtConfirm" ErrorMessage="Confirm your password." CssClass="validation" Display="Dynamic" />
<asp:CompareValidator ID="cvConfirm" runat="server" ControlToValidate="txtConfirm" ControlToCompare="txtPassword" ErrorMessage="The two passwords must match." CssClass="validation" Display="Dynamic" />
</div>
<span id="password-hint" class="hint full">At least 8 characters, including a letter and a number.</span>
</div>
<div class="field">
<asp:Label ID="lblReason" runat="server" AssociatedControlID="txtReason" Text="What would you like to teach? (lecturer applications only)" />
<asp:TextBox ID="txtReason" runat="server" TextMode="MultiLine" Rows="4" aria-describedby="reason-hint" />
<span class="hint" id="reason-hint">Lecturers: describe your subject and experience in 20 to 500 characters. Learners can leave this blank.</span>
<asp:CustomValidator ID="cvRegistration" runat="server" ValidateEmptyText="true" OnServerValidate="ValidateRegistration" ErrorMessage="Check your registration details." CssClass="validation" Display="Dynamic" />
</div>
<div class="field">
<asp:Label ID="lblCaptcha" runat="server" AssociatedControlID="txtCaptcha" />
<asp:TextBox ID="txtCaptcha" runat="server" TextMode="Number" autocomplete="off" style="max-width:160px" />
<span class="hint">This short sum helps us block automated sign-ups.</span>
<asp:RequiredFieldValidator ID="rfvCaptcha" runat="server" ControlToValidate="txtCaptcha" ErrorMessage="Answer the sum." Display="Dynamic" />
<asp:CompareValidator ID="cvCaptchaNumber" runat="server" ControlToValidate="txtCaptcha" Operator="DataTypeCheck" Type="Integer" ErrorMessage="Enter a whole number." Display="Dynamic" />
<asp:CustomValidator ID="cvCaptcha" runat="server" OnServerValidate="ValidateCaptcha" ValidateEmptyText="true" ErrorMessage="That answer was not correct, or the question expired. Answer the new sum." Display="Dynamic" />
</div>
<div class="field">
<asp:CheckBox ID="chkTerms" runat="server" Text="I agree to the Terms of use and have read the Privacy policy." />
<span class="hint">Read the <a href="../Terms.aspx" target="_blank" rel="noopener">Terms of use</a> and <a href="../Privacy.aspx" target="_blank" rel="noopener">Privacy policy</a> (each opens in a new tab).</span>
<asp:CustomValidator ID="cvTerms" runat="server" OnServerValidate="ValidateTerms" ErrorMessage="Please agree to the Terms of use to create an account." Display="Dynamic" />
</div>
<div class="actions">
<asp:Button ID="btnRegister" runat="server" Text="Create account" OnClick="btnRegister_Click" />
<asp:HyperLink ID="lnkCancel" runat="server" NavigateUrl="~/Default.aspx" CssClass="button secondary" Text="Cancel" />
</div>
<p>Already have an account? <a href="Login.aspx">Log in</a></p>
</div>
</section>
<aside class="auth-aside" aria-label="What you get">
<h2>A free learner account gives you</h2>
<ul>
<li><%= LearningSystem.Helpers.UiHelper.Icon("book") %><span>Every free course, with lessons, games, quizzes and code labs.</span></li>
<li><%= LearningSystem.Helpers.UiHelper.Icon("chart") %><span>A dashboard with your progress, results and learning streak.</span></li>
<li><%= LearningSystem.Helpers.UiHelper.Icon("bookmark") %><span>Bookmarks to come back to the lessons you need most.</span></li>
<li><%= LearningSystem.Helpers.UiHelper.Icon("award") %><span>A printable certificate for every course you complete.</span></li>
</ul>
</aside>
</div>
</asp:Content>
