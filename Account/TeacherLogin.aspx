<%@ Page Title="Lecturer log in" MetaDescription="Log in to your Inkwell lecturer account." Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="TeacherLogin.aspx.cs" Inherits="LearningSystem.Account.TeacherLogin" %>
<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
<div class="auth-layout">
    <section class="auth-form" aria-labelledby="login-title">
        <nav class="portal-tabs" aria-label="Choose how to log in"><a href="StudentLogin.aspx">Learner</a><a class="teacher" href="TeacherLogin.aspx" aria-current="page">Lecturer</a><a class="admin" href="AdminLogin.aspx">Admin</a></nav>
        <h1 id="login-title">Lecturer log in</h1>
        <p class="muted">Build courses and follow your learners' progress.</p>
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
                <asp:Button ID="btnLogin" runat="server" Text="Log in" OnClick="btnLogin_Click" CssClass="large" />
                <asp:HyperLink ID="lnkCancel" runat="server" NavigateUrl="~/Default.aspx" CssClass="button secondary" Text="Cancel" />
            </div>
            <p>Not a lecturer yet? <asp:HyperLink ID="lnkRegister" runat="server" NavigateUrl="~/Account/Register.aspx?as=lecturer" Text="Apply to teach" /></p>
            <p><a href="Login.aspx">Choose another sign-in</a></p>
        </div>
    </section>
    <aside class="auth-aside teacher" aria-label="Teaching on Inkwell">
        <%= LearningSystem.Helpers.MascotHelper.Render("read") %>
        <h2>Everything for your course in one place</h2>
        <ul>
            <li><%= LearningSystem.Helpers.UiHelper.Icon("layers") %><span>Organise topics with lessons, PDFs, audio, video and code labs.</span></li>
            <li><%= LearningSystem.Helpers.UiHelper.Icon("puzzle") %><span>Add quizzes, eight kinds of game, scenarios and discussions.</span></li>
            <li><%= LearningSystem.Helpers.UiHelper.Icon("chart") %><span>See every attempt and class averages as soon as learners submit.</span></li>
        </ul>
    </aside>
</div>
</asp:Content>
