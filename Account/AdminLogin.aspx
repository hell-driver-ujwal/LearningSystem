<%@ Page Title="Administrator log in" MetaDescription="Inkwell staff sign-in." Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="AdminLogin.aspx.cs" Inherits="LearningSystem.Account.AdminLogin" %>
<asp:Content ID="HeadArea" ContentPlaceHolderID="HeadContent" runat="server"><meta name="robots" content="noindex" /></asp:Content>
<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
<div class="auth-layout">
    <section class="auth-form" aria-labelledby="login-title">
        <h1 id="login-title">Administrator log in</h1>
        <p class="muted">For Inkwell platform staff only.</p>
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
            <p class="muted"><small>Five failed attempts lock an account for 15 minutes.</small></p>
            <p><asp:HyperLink ID="lnkRegister" runat="server" NavigateUrl="~/Account/Login.aspx" Text="Learner or lecturer? Choose another sign-in" /></p>
        </div>
    </section>
    <aside class="auth-aside admin" aria-label="Administrator tools">
        <h2>Platform administration</h2>
        <ul>
            <li><%= LearningSystem.Helpers.UiHelper.Icon("users") %><span>Approve lecturer applications and manage accounts.</span></li>
            <li><%= LearningSystem.Helpers.UiHelper.Icon("layers") %><span>Oversee every course and author your own.</span></li>
            <li><%= LearningSystem.Helpers.UiHelper.Icon("chart") %><span>Review messages, payments and page analytics.</span></li>
        </ul>
    </aside>
</div>
</asp:Content>
