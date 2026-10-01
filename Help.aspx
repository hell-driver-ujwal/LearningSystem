<%@ Page Title="Help and FAQ" MetaDescription="Answers to common questions about Inkwell courses, progress, certificates, games and teaching." Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Help.aspx.cs" Inherits="LearningSystem.Help" %>
<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
<div class="page-header"><div><h1>Help and FAQ</h1><p class="intro">Find a quick answer below, or <a href="Contact.aspx">contact us</a> if you are still stuck.</p></div></div>
<div class="faq-tools">
    <div class="field"><label for="faq-filter">Search the help pages</label><input type="search" id="faq-filter" placeholder="For example: certificate, password, streak" autocomplete="off" /></div>
    <p id="faq-count" class="muted" role="status" style="margin:0 0 12px"></p>
</div>
<div class="split">
<div>
    <section class="faq-group" aria-labelledby="start-title">
        <h2 id="start-title">Getting started</h2>
        <details data-faq><summary>Can I look at courses without an account?</summary><p>Yes. Every published course outline is public, and lessons marked Free preview open without an account. Create a free learner account to enrol and track your progress.</p></details>
        <details data-faq><summary>How do I enrol in a course?</summary><p>Log in as a learner, open the course page and choose Enrol for free. Paid courses show their price and take you to a secure eSewa checkout first.</p></details>
        <details data-faq><summary>Which devices can I use?</summary><p>Inkwell works in any modern browser on phones, tablets and computers. Games and code labs need JavaScript switched on.</p></details>
    </section>
    <section class="faq-group" aria-labelledby="faq-title">
        <h2 id="faq-title">Frequently asked questions</h2>
        <asp:Literal ID="litFAQ" runat="server" />
    </section>
    <section class="faq-group" aria-labelledby="practice-title">
        <h2 id="practice-title">Lessons and practice</h2>
        <details data-faq><summary>What is a code lab?</summary><p>A code lab is a lesson with real HTML, CSS and JavaScript that you can edit and run. Your result appears beside the code. Choose Reset to return to the original example. Changes are not saved.</p></details>
        <details data-faq><summary>How are games scored?</summary><p>Most games score the percentage of items you got right. Memory scores fewer moves and a quicker finish higher. Flashcards record how many cards you said you knew. All scores are checked on our server when you submit.</p></details>
        <details data-faq><summary>What happens if I leave a course?</summary><p>Leaving removes the course from My courses but keeps your results and completed lessons. Enrol again at any time to continue where you stopped.</p></details>
        <details data-faq><summary>Why does a course say Currently unavailable?</summary><p>The lecturer has unpublished it, usually to update the content. Your saved results stay in My results.</p></details>
    </section>
    <section id="lecturers" class="faq-group" aria-labelledby="lecturers-title">
        <h2 id="lecturers-title">For lecturers</h2>
        <details data-faq><summary>How do I become a lecturer?</summary><p>Choose <a href="Account/Register.aspx?as=lecturer">Apply to teach</a> and describe the subject you would like to teach. An administrator reviews each application, usually within a few working days.</p></details>
        <details data-faq><summary>What can I put in a course?</summary><p>Topics hold lessons (readings, diagrams, PDFs, audio, video, YouTube links and code labs) and activities (quizzes, self-assessments, discussions, eight types of game and branching scenarios).</p></details>
        <details data-faq><summary>When can learners see my course?</summary><p>Only after you publish it. A course needs at least one topic with a published lesson or activity. Drafts are visible only to you and administrators, through Preview.</p></details>
    </section>
</div>
<aside>
    <section id="shortcuts" class="card" aria-labelledby="keys-title">
        <h2 id="keys-title">Keyboard shortcuts</h2>
        <ul class="includes">
            <li><kbd>Alt</kbd> + <kbd>H</kbd> Home</li>
            <li><kbd>Alt</kbd> + <kbd>C</kbd> Course catalogue</li>
            <li><kbd>Alt</kbd> + <kbd>D</kbd> Your dashboard (when logged in)</li>
            <li><kbd>Alt</kbd> + <kbd>Q</kbd> This help page</li>
        </ul>
        <p class="muted"><small>Shortcuts do nothing while you are typing in a field. Some browsers reserve these keys; the menu links always work.</small></p>
    </section>
    <section class="card" aria-labelledby="contact-help-title" style="margin-top:20px">
        <h2 id="contact-help-title">Still need help?</h2>
        <p>Send us a message and an administrator will reply by email, usually within two working days.</p>
        <div class="actions"><a class="button" href="Contact.aspx">Contact support</a></div>
    </section>
</aside>
</div>
</asp:Content>
