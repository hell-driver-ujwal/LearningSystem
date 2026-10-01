<%@ Page Title="Choose your portal" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="LearningSystem.Account.Login" %>
<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
<h1>Welcome back</h1><p class="intro">Choose the portal for your account.</p>
<div class="course-grid">
<article class="form-card portal-student"><h2>Student Portal</h2><p>Learn, practise and track your progress.</p><asp:HyperLink ID="lnkStudent" runat="server" CssClass="button" Text="Student sign in" /></article>
<article class="form-card portal-teacher"><h2>Teacher Portal</h2><p>Build courses and support your learners.</p><asp:HyperLink ID="lnkTeacher" runat="server" CssClass="button" Text="Teacher sign in" /></article>
<article class="form-card portal-admin"><h2>Admin Portal</h2><p>Manage users, content and transactions.</p><asp:HyperLink ID="lnkAdmin" runat="server" CssClass="button" Text="Admin sign in" /></article>
</div><p><a href="Register.aspx">Create an account</a></p>
</asp:Content>