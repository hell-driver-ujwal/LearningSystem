<%@ Page Title="About Inkwell" MetaDescription="Inkwell offers short courses for pre-university and foundation students, built around practice: quizzes, games, code labs and decision scenarios." Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="About.aspx.cs" Inherits="LearningSystem.About" %>
<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
<div class="about-grid">
    <div class="prose">
        <p class="eyebrow">About us</p>
        <h1>Learning that sticks comes from doing, not just reading</h1>
        <p class="intro">Inkwell is an online learning platform for pre-university and foundation students. Our lecturers write short, focused courses, and every topic ends with something you do: answer a quiz, play a game, edit some code or make decisions in a realistic scenario.</p>

        <h2>Our mission</h2>
        <p>To help students build real understanding in small, steady steps, with honest feedback at every stage and no barriers to getting started.</p>

        <h2>What we aim to do</h2>
        <ul>
            <li>Organise every subject into clear courses, topics and short lessons.</li>
            <li>Let learners study at their own pace and always see their progress.</li>
            <li>Give lecturers simple tools to build lessons and many kinds of practice.</li>
            <li>Keep most courses free, and make every course outline and preview lesson open to everyone.</li>
        </ul>

        <h2>How it works</h2>
        <ol>
            <li><strong>Browse:</strong> read any course outline and open the free preview lessons without an account.</li>
            <li><strong>Enrol:</strong> create a free learner account and join a course in one click. Paid courses use eSewa.</li>
            <li><strong>Learn and practise:</strong> lessons come as readings, diagrams, PDFs, audio, video and code labs, each followed by practice.</li>
            <li><strong>Track:</strong> your dashboard shows progress, results and your learning streak. Finish a course to print a certificate.</li>
        </ol>

        <h2>For lecturers</h2>
        <p>Qualified teachers can <a href="Account/Register.aspx?as=lecturer">apply to teach</a>. Once approved, you can build courses with the course builder, publish when you are ready, and see each learner's results.</p>
    </div>
    <aside>
        <section class="card" aria-labelledby="contact-title">
            <h2 id="contact-title">Contact us</h2>
            <ul class="contact-list">
                <li><%= LearningSystem.Helpers.UiHelper.Icon("mail") %><span><strong>Email</strong><br /><a href="mailto:<%: LearningSystem.Helpers.UiHelper.ContactEmail %>"><%: LearningSystem.Helpers.UiHelper.ContactEmail %></a></span></li>
                <li><%= LearningSystem.Helpers.UiHelper.Icon("pin") %><span><strong>Office</strong><br /><%: LearningSystem.Helpers.UiHelper.ContactAddress %></span></li>
                <li><%= LearningSystem.Helpers.UiHelper.Icon("clock") %><span><strong>Support hours</strong><br />Sunday to Friday, 10:00 to 17:00 (Nepal time)</span></li>
            </ul>
            <div class="actions"><a class="button" href="Contact.aspx">Send us a message</a></div>
        </section>
        <section class="card" aria-labelledby="facts-title" style="margin-top:20px">
            <h2 id="facts-title">Inkwell in numbers</h2>
            <asp:Literal ID="litFacts" runat="server" />
        </section>
    </aside>
</div>
<section class="section" aria-labelledby="team-title">
    <h2 id="team-title">Our lecturers</h2>
    <p class="muted">Every course is written and maintained by one of these lecturers or by the Inkwell learning team.</p>
    <asp:Repeater ID="rptLecturers" runat="server"><HeaderTemplate><ul class="team-list"></HeaderTemplate><ItemTemplate><li><span class="avatar" aria-hidden="true"><%#: LearningSystem.Helpers.UiHelper.Initial(Convert.ToString(Eval("FullName"))) %></span><span><strong><%#: Eval("FullName") %></strong><span><%#: Eval("Subjects") %></span></span></li></ItemTemplate><FooterTemplate></ul></FooterTemplate></asp:Repeater>
</section>
</asp:Content>
