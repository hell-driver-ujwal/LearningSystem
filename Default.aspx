<%@ Page Title="Inkwell: short courses you learn by doing" MetaDescription="Short online courses in programming, cybersecurity, AI, maths, science, business and writing. Every topic ends with a quiz, game, code lab or scenario so you practise straight away." Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="LearningSystem._Default" %>
<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">

<section class="hero" aria-labelledby="hero-title">
    <div>
        <p class="eyebrow">Free and low-cost short courses</p>
        <h1 id="hero-title">Learn a topic, then practise it straight away.</h1>
        <p class="intro">Courses in programming, cybersecurity, AI, maths, science, business and writing. Each topic pairs short lessons with a quiz, a game, a code lab or a decision scenario, so you finish with something you can actually do.</p>
        <div class="actions">
            <a class="button large" href="Courses.aspx">Browse all courses <%= LearningSystem.Helpers.UiHelper.Icon("arrow-right") %></a>
            <asp:HyperLink ID="lnkRegister" runat="server" CssClass="button secondary large" NavigateUrl="~/Account/Register.aspx" Text="Create a free account" />
        </div>
        <ul class="facts" aria-label="Inkwell at a glance">
            <li><strong><asp:Literal ID="litCourseCount" runat="server" Mode="Encode" /></strong>published courses</li>
            <li><strong><asp:Literal ID="litLecturerCount" runat="server" Mode="Encode" /></strong>lecturers</li>
            <li><strong><asp:Literal ID="litActivityCount" runat="server" Mode="Encode" /></strong>practice activities</li>
        </ul>
    </div>
    <figure class="hero-media">
        <video controls preload="metadata" poster="<%: LearningSystem.Helpers.UiHelper.AssetUrl("~/Assets/video/inkwell-intro-poster.jpg") %>" width="1280" height="720">
            <source src="<%: LearningSystem.Helpers.UiHelper.AssetUrl("~/Assets/video/inkwell-intro.mp4") %>" type="video/mp4" />
            <track kind="captions" src="<%: LearningSystem.Helpers.UiHelper.AssetUrl("~/Assets/video/inkwell-intro.vtt") %>" srclang="en" label="English" />
            Your browser cannot play this video. The tour shows how to choose a course, study a lesson and practise with a game.
        </video>
        <figcaption>A short tour: finding a course, studying a lesson, practising and tracking your progress. Captions available.</figcaption>
    </figure>
</section>

<section id="subjects" class="section" aria-labelledby="subjects-title">
    <div class="section-head">
        <div><h2 id="subjects-title">Browse by subject</h2><p>Pick an area to see every course in it.</p></div>
        <a class="lead-link" href="Courses.aspx">See all courses <%= LearningSystem.Helpers.UiHelper.Icon("arrow-right") %></a>
    </div>
    <asp:Repeater ID="rptSubjects" runat="server"><HeaderTemplate><ul class="subject-list"></HeaderTemplate>
        <ItemTemplate><li><a class="subject-tile" href='Courses.aspx?subjectId=<%# Eval("SubjectID") %>'><img src='<%# SubjectImage(Eval("SubjectName")) %>' alt="" width="72" height="72" loading="lazy" /><span><strong><%#: Eval("SubjectName") %></strong><span><%#: CourseCount(Eval("CourseCount")) %></span></span></a></li></ItemTemplate>
        <FooterTemplate></ul></FooterTemplate></asp:Repeater>
    <asp:Label ID="lblNoSubjects" runat="server" Visible="false" CssClass="empty-state" Text="Subjects will appear here once the first courses are published." />
</section>

<section class="section" aria-labelledby="latest-title">
    <div class="section-head">
        <div><h2 id="latest-title">New on Inkwell</h2><p>The most recently published courses.</p></div>
        <a class="lead-link" href="Courses.aspx">View the full catalogue <%= LearningSystem.Helpers.UiHelper.Icon("arrow-right") %></a>
    </div>
    <asp:PlaceHolder ID="phCourses" runat="server" />
</section>

<section class="section" aria-labelledby="how-title">
    <div class="section-head"><div><h2 id="how-title">How learning works here</h2><p>Every course follows the same simple rhythm.</p></div></div>
    <ol class="steps">
        <li><h3>Look before you join</h3><p>Read the outline and open the free preview lessons without an account.</p></li>
        <li><h3>Read, watch or listen</h3><p>Short lessons with diagrams, PDFs, audio and video, written by your lecturer.</p></li>
        <li><h3>Practise straight away</h3><p>Each topic has a quiz, game, code lab or scenario that checks what you just learned.</p></li>
        <li><h3>Track and finish</h3><p>Your progress bar, results and learning streak update as you go. Reach 100 percent to print a certificate.</p></li>
    </ol>
</section>

<section class="section" aria-labelledby="practise-title">
    <div class="section-head"><div><h2 id="practise-title">Ways to practise</h2><p>Different kinds of activity suit different kinds of knowledge.</p></div></div>
    <div class="practice-grid">
        <article><%= LearningSystem.Helpers.UiHelper.TypeMark("Quiz") %><h3>Quizzes</h3><p>Timed or untimed questions, marked instantly with a full answer review.</p></article>
        <article><%= LearningSystem.Helpers.UiHelper.TypeMark("Game") %><h3>Eight game types</h3><p>Matching, memory, flashcards, word scramble, sorting, fill the blank, true or false and put in order.</p></article>
        <article><%= LearningSystem.Helpers.UiHelper.TypeMark("Code") %><h3>Code labs</h3><p>Edit real HTML, CSS and JavaScript and see the result beside your code.</p></article>
        <article><%= LearningSystem.Helpers.UiHelper.TypeMark("Scenario") %><h3>Decision scenarios</h3><p>Step through a realistic situation, such as a phishing message, and see where your choices lead.</p></article>
        <article><%= LearningSystem.Helpers.UiHelper.TypeMark("SelfAssessment") %><h3>Self-assessments</h3><p>Rate your confidence, get feedback and compare with your earlier ratings.</p></article>
        <article><%= LearningSystem.Helpers.UiHelper.TypeMark("Discussion") %><h3>Discussions</h3><p>Answer a prompt, reply to classmates and get comments from your lecturer.</p></article>
    </div>
</section>

<section class="cta-band" aria-labelledby="teach-title">
    <div>
        <h2 id="teach-title">Teach a course on Inkwell</h2>
        <p>Lecturers build courses with lessons, files, quizzes, games and scenarios, then follow each learner's results. Applications are reviewed by our team before your account opens.</p>
    </div>
    <div class="actions">
        <a class="button" href="Account/Register.aspx?as=lecturer">Apply to teach</a>
        <a class="button secondary" href="Help.aspx#lecturers">Lecturer FAQ</a>
    </div>
</section>

<section class="section" aria-labelledby="faq-title">
    <div class="section-head">
        <div><h2 id="faq-title">Common questions</h2><p>Quick answers before you sign up.</p></div>
        <a class="lead-link" href="Help.aspx">All help topics <%= LearningSystem.Helpers.UiHelper.Icon("arrow-right") %></a>
    </div>
    <asp:Repeater ID="rptFaq" runat="server"><ItemTemplate><details><summary><%#: Eval("Question") %></summary><p><%#: Eval("Answer") %></p></details></ItemTemplate></asp:Repeater>
    <%-- Inline CSS: this style attribute demonstrates the inline style type required by the assignment. --%>
    <p class="muted" style="margin-top: 18px; font-size: .95rem;">Still unsure? <a href="Contact.aspx">Send us a message</a> and we will reply within two working days.</p>
</section>
</asp:Content>
