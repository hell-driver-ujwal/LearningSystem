<%@ Page Title="Privacy policy" MetaDescription="What personal information Inkwell collects, why we collect it, how long we keep it and how to contact us about your data." Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Privacy.aspx.cs" Inherits="LearningSystem.Privacy" %>
<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
<article class="prose">
<h1>Privacy policy</h1>
<p class="legal-meta">Effective from 1 October 2026. This policy explains what we collect when you use Inkwell, why, and the choices you have.</p>
<nav class="toc" aria-labelledby="toc-title"><h2 id="toc-title">On this page</h2><ol>
<li><a href="#collect">Information we collect</a></li><li><a href="#use">How we use it</a></li><li><a href="#share">Who can see it</a></li><li><a href="#cookies">Cookies</a></li>
<li><a href="#analytics">Page analytics</a></li><li><a href="#keep">How long we keep it</a></li><li><a href="#rights">Your choices and rights</a></li><li><a href="#security">Security</a></li><li><a href="#contact">Contact</a></li></ol></nav>

<h2 id="collect">1. Information we collect</h2>
<h3>Information you give us</h3>
<ul>
<li><strong>Account details:</strong> your full name, email address and password. We never store your password itself, only a salted PBKDF2 hash that cannot be turned back into the password.</li>
<li><strong>Lecturer applications:</strong> the description of what you would like to teach.</li>
<li><strong>What you write:</strong> discussion posts and replies, course reviews and messages you send through the Contact page.</li>
</ul>
<h3>Information created while you learn</h3>
<ul>
<li>Courses you enrol in, lessons you mark complete and lessons you bookmark.</li>
<li>Quiz answers, game results, self-assessment ratings and scenario outcomes, with the date and time of each attempt.</li>
</ul>
<h3>Payments</h3>
<p>Paid courses are processed by eSewa. We record the course, the amount, the transaction reference and whether the payment succeeded. We never see or store your eSewa login, PIN or card details.</p>

<h2 id="use">2. How we use your information</h2>
<ul>
<li>To create and secure your account and let you log in.</li>
<li>To show your progress, results, certificates and learning streak.</li>
<li>To let lecturers see the results of learners in their own courses so they can improve their teaching.</li>
<li>To answer your messages and review lecturer applications.</li>
<li>To keep the platform safe, for example by locking an account for 15 minutes after five failed log-in attempts.</li>
</ul>
<p>We do not sell your information, and we do not use it for advertising.</p>

<h2 id="share">3. Who can see your information</h2>
<ul>
<li><strong>Other learners</strong> see your name next to discussion posts and course reviews you choose to write.</li>
<li><strong>Lecturers</strong> see the names and results of learners enrolled in their own courses. They cannot see your email address or your activity in other lecturers' courses.</li>
<li><strong>Administrators</strong> can see account details, messages and payment records in order to run the platform.</li>
<li><strong>eSewa</strong> receives the details needed to process a payment you start.</li>
</ul>

<h2 id="cookies">4. Cookies</h2>
<p>We use only the cookies needed for the site to work:</p>
<div class="table-scroll"><table><caption>Cookies used by Inkwell</caption><thead><tr><th scope="col">Cookie</th><th scope="col">Purpose</th><th scope="col">Duration</th></tr></thead><tbody>
<tr><td>.ASPXAUTH</td><td>Keeps you logged in</td><td>30 minutes of inactivity</td></tr>
<tr><td>ASP.NET_SessionId</td><td>Remembers in-progress quizzes, games and forms</td><td>Until you close the browser or 30 minutes of inactivity</td></tr></tbody></table></div>
<p>We do not use advertising or third-party tracking cookies.</p>

<h2 id="analytics">5. Page analytics</h2>
<p>To understand which pages are useful, we count page views. For each view we record only the page address, whether the visitor was logged out, a learner, a lecturer or an administrator, and the time. We do not record who you are, your IP address or your browser details, and no analytics cookie is set.</p>

<h2 id="keep">6. How long we keep information</h2>
<ul>
<li>Account and learning records are kept while your account exists, so your progress is there when you return.</li>
<li>If your account is deleted, your attempts, completions, bookmarks, reviews and posts are deleted with it. Replies other people wrote to your posts are also removed.</li>
<li>Payment records are kept for financial record-keeping even if you stop using the platform.</li>
<li>Page analytics are kept for up to 12 months.</li>
</ul>

<h2 id="rights">7. Your choices and rights</h2>
<ul>
<li>You can update your name and email address at any time on your profile page.</li>
<li>You can delete your own posts and reviews.</li>
<li>You can ask us for a copy of your information, or ask us to correct or delete your account, by contacting us.</li>
</ul>
<p>We aim to handle personal information in line with Nepal's Individual Privacy Act, 2075 (2018).</p>

<h2 id="security">8. Security</h2>
<p>All pages are served over HTTPS. Passwords are hashed with PBKDF2 and a unique salt. Uploaded files are served only through a checked download address, never directly, and every page that shows a course item checks that you are allowed to see it.</p>

<h2 id="contact">9. Contact</h2>
<p>For any privacy question, email <a href="mailto:<%: LearningSystem.Helpers.UiHelper.ContactEmail %>"><%: LearningSystem.Helpers.UiHelper.ContactEmail %></a> or use the <a href="Contact.aspx">Contact page</a>. If we change this policy, we will update the date at the top of this page.</p>
<p><a href="Terms.aspx">Read our Terms of use</a></p>
</article>
</asp:Content>
