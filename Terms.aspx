<%@ Page Title="Terms of use" MetaDescription="The rules for using Inkwell as a learner or lecturer, including accounts, course content, payments and acceptable use." Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Terms.aspx.cs" Inherits="LearningSystem.Terms" %>
<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
<article class="prose">
<h1>Terms of use</h1>
<p class="legal-meta">Effective from 1 October 2026. By creating an account or using Inkwell, you agree to these terms. Please also read our <a href="Privacy.aspx">Privacy policy</a>.</p>
<nav class="toc" aria-labelledby="toc-title"><h2 id="toc-title">On this page</h2><ol>
<li><a href="#accounts">Your account</a></li><li><a href="#learners">Learning on Inkwell</a></li><li><a href="#lecturers">Teaching on Inkwell</a></li><li><a href="#payments">Payments and refunds</a></li>
<li><a href="#conduct">Acceptable use</a></li><li><a href="#content">Course content and ownership</a></li><li><a href="#certificates">Certificates</a></li><li><a href="#availability">Availability and changes</a></li><li><a href="#ending">Suspending or closing accounts</a></li><li><a href="#law">Liability and governing law</a></li></ol></nav>

<h2 id="accounts">1. Your account</h2>
<ul>
<li>Give your real name and an email address you can access. One person, one account.</li>
<li>Keep your password private. You are responsible for activity on your account.</li>
<li>Learner accounts open straight away. Lecturer accounts open only after an administrator approves your application.</li>
</ul>

<h2 id="learners">2. Learning on Inkwell</h2>
<ul>
<li>Courses are for your own learning. Results, streaks and certificates reflect the work you submit.</li>
<li>Follow your school or college's rules on academic integrity, including any rules about AI tools. Inkwell activities are practice and are not an official qualification.</li>
<li>You may leave a course at any time. Your results are kept if you return.</li>
</ul>

<h2 id="lecturers">3. Teaching on Inkwell</h2>
<ul>
<li>You must have the right to publish everything you upload, including text, images, audio, video and PDFs.</li>
<li>Content must be accurate to the best of your knowledge and suitable for pre-university and foundation students.</li>
<li>To keep results fair, quiz questions and game items lock once a learner has submitted an attempt. You can still edit titles and descriptions, or unpublish the activity.</li>
<li>Courses with learner attempts or payments cannot be deleted. Unpublish them instead so learners keep their history.</li>
</ul>

<h2 id="payments">4. Payments and refunds</h2>
<ul>
<li>Prices are shown in Nepali rupees on the course page before you pay. Payments are processed by eSewa.</li>
<li>Access is granted only after eSewa confirms the payment. A completed payment gives lasting access to that course, even if you leave and rejoin.</li>
<li>If a course is not what you expected, contact us within 7 days of payment. We refund in full if you have completed less than a quarter of the course.</li>
</ul>

<h2 id="conduct">5. Acceptable use</h2>
<p>When you post, review or message, do not:</p>
<ul>
<li>harass, threaten or insult anyone, or share other people's personal information;</li>
<li>post spam, advertising, or content that is illegal or sexually explicit;</li>
<li>share quiz answers in discussions in a way that spoils the activity for others;</li>
<li>try to access accounts, pages or data that are not yours, or interfere with the site.</li>
</ul>
<p>Lecturers can remove posts in their own courses, and administrators can remove any post or review that breaks these rules.</p>

<h2 id="content">6. Course content and ownership</h2>
<p>Lecturers keep ownership of the material they create and give Inkwell permission to show it to enrolled learners and visitors viewing free previews. You may use course material for your own study, but you may not republish or sell it without the lecturer's permission. The Inkwell name, logo and site design belong to Inkwell Academy.</p>

<h2 id="certificates">7. Certificates</h2>
<p>A certificate shows that you completed every published lesson and activity in a course at the time it was printed. It is a record of participation, not an accredited qualification.</p>

<h2 id="availability">8. Availability and changes</h2>
<p>We work to keep Inkwell available, but we cannot promise it will always be free of interruptions. Lecturers may update or unpublish their courses. We may update these terms; the date at the top shows the latest version.</p>

<h2 id="ending">9. Suspending or closing accounts</h2>
<p>We may deactivate an account that breaks these terms. You can ask us to close your account at any time through the <a href="Contact.aspx">Contact page</a>.</p>

<h2 id="law">10. Liability and governing law</h2>
<p>Inkwell is provided for learning purposes. To the extent permitted by law, we are not responsible for indirect losses arising from use of the site. These terms are governed by the laws of Nepal.</p>
<p>Questions about these terms? Email <a href="mailto:<%: LearningSystem.Helpers.UiHelper.ContactEmail %>"><%: LearningSystem.Helpers.UiHelper.ContactEmail %></a>.</p>
</article>
</asp:Content>
