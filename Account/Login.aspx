<%@ Page Title="Log in" MetaDescription="Log in to Inkwell as a learner or a lecturer." Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="LearningSystem.Account.Login" %>
<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
<div class="page-header"><div><h1>Welcome back</h1><p class="intro">Choose how you use Inkwell. Each account type has its own sign-in page.</p></div></div>
<div class="portal-grid">
    <article class="portal-card"><%= LearningSystem.Helpers.UiHelper.TypeMark("Text") %><h2>I am a learner</h2><p>Continue your courses, games and quizzes, and see your progress.</p><asp:HyperLink ID="lnkStudent" runat="server" CssClass="button" Text="Learner log in" /></article>
    <article class="portal-card teacher"><%= LearningSystem.Helpers.UiHelper.TypeMark("Scenario") %><h2>I am a lecturer</h2><p>Build and update your courses and follow your learners' results.</p><asp:HyperLink ID="lnkTeacher" runat="server" CssClass="button" Text="Lecturer log in" /></article>
</div>
<p>New to Inkwell? <a href="Register.aspx">Create a free learner account</a> or <a href="Register.aspx?as=lecturer">apply to teach</a>.</p>
<p class="muted"><small>Platform staff: <asp:HyperLink ID="lnkAdmin" runat="server" Text="administrator log in" /></small></p>
</asp:Content>
