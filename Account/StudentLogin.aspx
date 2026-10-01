<%@ Page Title="Learner log in" MetaDescription="Log in to your Inkwell learner account." Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="StudentLogin.aspx.cs" Inherits="LearningSystem.Account.StudentLogin" %>
<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
<div class="auth-layout">
    <section class="auth-form" aria-labelledby="login-title">
        <h1 id="login-title">Learner log in</h1>
        <p class="muted">Pick up where you left off.</p>
        <div class="form-card">
            <asp:ValidationSummary ID="vsForm" runat="server" CssClass="validation-summary" HeaderText="Please check the following:" />
            <div class="field">
                <asp:Label ID="lblEmail" runat="server" AssociatedControlID="txtEmail" Text="Email address" />
                <asp:TextBox ID="txtEmail" runat="server" TextMode="Email" MaxLength="100" autocomplete="username" />
                <asp:RequiredFieldValidator ID="rfvEmail" runat="server" ControlToValidate="txtEmail" ErrorMessage="Enter your email address." CssClass="validation" Display="Dynamic" />
            </div>
            <div class="field">
                <asp:Label ID="lblPassword" runat="server" AssociatedControlID="txtPassword" Text="Password" />
                <asp:TextBox ID="txtPassword" runat="server" TextMode="Password" autocomplete="current-password" data-password="true" />
                <asp:RequiredFieldValidator ID="rfvPassword" runat="server" ControlToValidate="txtPassword" ErrorMessage="Enter your password." CssClass="validation" Display="Dynamic" />
            </div>
            <div class="actions">
                <asp:Button ID="btnLogin" runat="server" Text="Log in" OnClick="btnLogin_Click" />
                <asp:HyperLink ID="lnkCancel" runat="server" NavigateUrl="~/Default.aspx" CssClass="button secondary" Text="Cancel" />
            </div>
            <p>New here? <asp:HyperLink ID="lnkRegister" runat="server" NavigateUrl="~/Account/Register.aspx" Text="Create a free account" /></p>
            <p class="muted"><small>Forgotten your password? <a href="../Contact.aspx">Contact us</a> and an administrator will set a temporary one.</small></p>
            <p><a href="Login.aspx">Lecturer or staff? Choose another sign-in</a></p>
        </div>
    </section>
    <aside class="auth-aside" aria-label="Why learn with Inkwell">
        <h2>Learn a little every day</h2>
        <ul>
            <li><%= LearningSystem.Helpers.UiHelper.Icon("flame") %><span>Your learning streak grows each day you finish a lesson or activity.</span></li>
            <li><%= LearningSystem.Helpers.UiHelper.Icon("chart") %><span>Every quiz and game result is saved so you can see how you are improving.</span></li>
            <li><%= LearningSystem.Helpers.UiHelper.Icon("award") %><span>Finish every item in a course to print your certificate.</span></li>
        </ul>
    </aside>
</div>
</asp:Content>
