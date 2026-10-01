<%@ Page Title="Learn at your own pace" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="LearningSystem._Default" %>
<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">

<section class="hero" aria-label="Welcome"><div><p class="eyebrow">Learning System</p><h1>Learn at your own pace</h1><p class="intro">Explore courses across subjects, study lessons and practise through quizzes, self-assessments, discussions, games and branching scenarios.</p>
<%-- Inline CSS demonstration required by the assignment. --%>
<p style="font-weight:600">Choose a course, enrol for free and track your learning.</p>
<div class="actions"><a class="button" href="Courses.aspx">Browse courses</a><asp:HyperLink ID="lnkRegister" runat="server" CssClass="button secondary" NavigateUrl="~/Account/Register.aspx" Text="Create an account" /></div>
</div><aside class="hero-aside"><h2>Choose. Learn. Practise.</h2><p>Choose a course, enrol for free and track your learning.</p><p class="content-pending">Introduction video and poster: awaiting the team's local media files.</p></aside></section>
<section aria-labelledby="subjects-title"><h2 id="subjects-title">Explore subjects</h2><p class="content-pending">Subject images: awaiting team assets.</p><asp:Repeater ID="rptSubjects" runat="server"><HeaderTemplate><ul class="subject-list"></HeaderTemplate><ItemTemplate><li><a href='Courses.aspx?subjectId=<%# Eval("SubjectID") %>'><%#: Eval("SubjectName") %></a><span class="muted"><%#: Eval("CourseCount") %> published courses</span></li></ItemTemplate><FooterTemplate></ul></FooterTemplate></asp:Repeater><asp:Label ID="lblNoSubjects" runat="server" Visible="false" Text="No subjects are available yet." /></section>
<section aria-labelledby="latest-title"><h2 id="latest-title">Newest published courses</h2><asp:PlaceHolder ID="phCourses" runat="server" /></section>
<section aria-labelledby="practice-title"><h2 id="practice-title">Learn and practise</h2><div class="practice-grid"><article><h3>Lessons &amp; quizzes</h3><p>Read or watch lessons and check your knowledge with quizzes.</p></article><article><h3>Reflect &amp; discuss</h3><p>Reflect with self-assessments and exchange ideas in discussions.</p></article><article><h3>Games &amp; scenarios</h3><p>Practise with games and explore decisions in scenarios.</p></article></div></section>
</asp:Content>

