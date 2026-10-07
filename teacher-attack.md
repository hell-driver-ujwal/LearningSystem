# TEACHER ATTACK MODE: Inkwell Viva Question Bank

> **How to use:** Cover the answer, say yours **out loud**, then open the answer and compare.
> Each question has:
> - **Short** (10–20 s): say this first.
> - **Full** (30–60 s): when they want more.
> - **Follow-up →**: what the teacher will probably ask next, with its answer.
> - **⚠️ Trap**: what NOT to say.
>
> Labels: 🟢 confirmed in code · 🟡 inferred · 🔴 can't be proven, so be careful.
> Companion file: `WholeProject.md` (full explanations). Each section notes who should answer first.

### Scoring yourself
For every answer, check:
| Check | Ask yourself |
|---|---|
| **Accuracy** | Did I say anything technically wrong? |
| **Completeness** | Did I answer the actual question? |
| **Confidence** | Did I hesitate or ramble? |
| **Evidence** | Can I point to a file or show it in the app? |
| **Risk** | Did I make a claim that invites a hard follow-up? |

Get 4 or 5 right → move on. 3 or fewer → re-read the matching part of `WholeProject.md`.

---

## Contents
1. Round 1: Classmate (warm-up)
2. Round 2: Project and requirements (Rupesh first)
3. Round 3: Audience, use cases, design (Sunil / Aashish first)
4. Round 4: Front end and validation (Sunil first)
5. Round 5: Database (Ujwal first)
6. Round 6: Authentication and security (Ujwal first)
7. Round 7: Learning features: quizzes, games, scenarios, lessons (Aashish first)
8. Round 8: Payment and enrolment
9. Round 9: Admin and lecturer tools (Rupesh / Aashish first)
10. Round 10: Testing and errors (Sunil first)
11. Round 11: Challenge and "why didn't you" questions
12. Round 12: "What happens if…" questions
13. Round 13: Show me the code
14. Round 14: Personal and team questions
15. Round 15: Killer questions (strict examiner)
16. Rapid-fire round (one-liners)

---

# ROUND 1: CLASSMATE (WARM-UP)

<details><summary><b>Q1. What is Inkwell in one sentence?</b></summary>

**Short:** An online learning website where every topic ends with a practice activity that the server marks and saves to the learner's progress.

**Full:** Visitors browse courses and try free previews, learners enrol and study, then practise with quizzes, games, scenarios, self-assessments and discussions. Lecturers build their own courses, and an admin runs the platform.

**Follow-up →** *"What makes it different from YouTube or W3Schools?"* Those explain a topic but don't check whether you understood it. Inkwell ends every topic with marked practice and tracks progress.
</details>

<details><summary><b>Q2. Who are the users?</b></summary>

**Short:** Four: Visitor, Learner, Lecturer and Administrator.

**Full:** Visitors aren't logged in. Learners study. Lecturers (stored as `Teacher` in the code) build courses after admin approval. The admin manages everything. There's exactly one admin, created by the database script.

**⚠️ Trap:** Don't say "students and teachers only". You'll forget the visitor and the admin.
</details>

<details><summary><b>Q3. What did you build it with?</b></summary>

**Short:** ASP.NET Web Forms with C#, SQL Server LocalDB, and plain HTML5, CSS and JavaScript.

**Full:** .NET Framework 4.8, ADO.NET for database access with parameterised SQL, Forms Authentication for login, PBKDF2 for passwords. No CSS or JS frameworks, so it runs completely offline.
</details>

<details><summary><b>Q4. What are the five activity types?</b></summary>

**Short:** Quiz, Game, Scenario, Self-assessment and Discussion.

**Follow-up →** *"Are they all scored?"* Only quizzes and games get a percentage. Scenarios record which ending you reached (Best/Acceptable/Poor), self-assessments record confidence ratings 1–5, and discussions record posts.
</details>

<details><summary><b>Q5. Name the eight games.</b></summary>

**Short:** Matching, Memory, Scramble, Sort, Flashcards, Fill-in-the-blank, True/False and Sequence.
</details>

<details><summary><b>Q6. Is the payment real?</b></summary>

**Short:** No. It's an offline eSewa-style demo. No real money moves.

**Full:** You enter any Nepali mobile number starting with 97 or 98, and the "verification code" is its last 4 digits. The server then marks the payment complete and enrols you in one transaction.

**⚠️ Trap:** Never say "integrated with eSewa".
</details>

<details><summary><b>Q7. Does it run online?</b></summary>

**Short:** No. It runs locally on IIS Express at `https://localhost:44393` with a LocalDB database. Hosting is future work.
</details>

---

# ROUND 2: PROJECT AND REQUIREMENTS · *Rupesh first*

<details><summary><b>Q8. What problem does Inkwell solve?</b></summary>

**Short:** Free resources explain topics but don't check understanding, and lecturers can't easily build interactive websites.

**Full:** Our target learners are 17–21, mostly on phones, studying in short sessions. So every topic ends with a marked activity, progress is visible, and lecturers get form-based builders instead of code.

**Follow-up →** *"How do you know students have this problem?"* It came from our own experience as foundation students. We didn't run a formal survey, and that would be a good validation step.

**⚠️ Trap:** Don't claim "we surveyed students" or "it improves grades". There's no evidence.
</details>

<details><summary><b>Q9. What were your objectives?</b></summary>

**Short:** An open catalogue with previews, marked practice, lecturer self-service, admin control, security from the start, and usability on any screen.

**Follow-up →** *"Which objective was hardest?"* Marked practice on the server, because every activity type needed its own server-side checking and saving logic.
</details>

<details><summary><b>Q10. What's out of scope, and why?</b></summary>

**Short:** Live video and chat, email notifications, a mobile app, AI features, real payments and multiplayer games.

**Full:** They need things a local academic demo doesn't have: a mail server, a merchant account, public hosting, or real-time servers. Keeping scope tight let us finish the core properly.
</details>

<details><summary><b>Q11. Show me how you met each requirement in the brief.</b></summary>

**Short:** Slide 10 maps each one.

**Full (point while saying it):**
- **Interlinked pages:** header nav, sidebar, breadcrumbs, site map
- **HTML5:** header, nav, main, footer, video with captions, canvas charts
- **CSS:** `site.css`, the `<style>` block in `Site.Master`, inline styles on the home page
- **CRUD:** the admin Subjects page
- **Registration:** `Register.aspx`
- **Member modules:** the Learner, Member and Teacher folders
- **Admin module:** the Admin folder
- **Validation:** validator controls plus server checks
- **Navigation:** role menus, breadcrumbs, 404 and 403 pages
- **File organisation:** a folder per role and a Helpers folder
</details>

<details><summary><b>Q12. Who are M1 to M4 on your schedule?</b></summary>

**Short:** (Use your team's agreed answer.) The slide notes say M1 did public pages, accounts and admin; M2 courses, lessons and enrolment; M3 quiz, self-assessment and discussion; M4 games, scenarios and preview.

**⚠️ Trap:** It's a *planned* schedule. Don't claim you followed it week by week. Git history shows most commits on 1–2 October.
</details>

<details><summary><b>Q13. What development methodology did you use?</b></summary>

**Short:** An incremental, phase-by-phase approach. Requirements and design first, then feature modules on a shared database and helper contract, then integration and testing.

**⚠️ Trap:** Don't say "Scrum with sprints and stand-ups" unless you actually did that.
</details>

<details><summary><b>Q14. How many pages, tables and helper classes are there?</b></summary>

**Short:** 61 pages, 25 tables and 37 helper classes. 🟢 All three are verified in the code.
</details>

---

# ROUND 3: AUDIENCE, USE CASES, DESIGN · *Sunil / Aashish first*

<details><summary><b>Q15. What is WSDM?</b></summary>

**Short:** The Web Site Design Method by De Troyer and Leune (1998). You start from the people who use the site, not from the data.

**Full:** You define audience classes and each one's tasks, then design pages around those tasks. Ours: Visitor → Registered member → Learner, Lecturer, Administrator.

**Follow-up →** *"Why not start from the database?"* Different users need very different pages. Starting from users means nobody has to wade through tools meant for someone else. The database then supports their tasks.
</details>

<details><summary><b>Q16. How does your audience model show up in the code?</b></summary>

**Short:** As the `Role` column, a folder per role, a login portal per role, and a dashboard per role.

**Full:**
- `User.Role` is restricted by a CHECK constraint to Learner, Teacher or Admin.
- `Web.config` protects the `Learner/`, `Teacher/` and `Admin/` folders by role. `Member/` is for anyone logged in.
- Each role has its own login page and dashboard, and the sidebar is built per role in `Site.Master.cs`.
</details>

<details><summary><b>Q17. Why can't someone register as an admin?</b></summary>

**Short:** The registration code only accepts Learner or Teacher. The single admin account is created by the database script.

**Full:** `ValidateRegistration` in `Register.aspx.cs` rejects any other role. The script inserts `admin@inkwell.test` and checks there is exactly one admin, otherwise it throws an error.
</details>

<details><summary><b>Q18. In your use case diagram the admin inherits from the lecturer. What does that mean in practice?</b></summary>

**Short:** The admin can use the same course-builder pages.

**Full:** `Web.config` allows both Teacher and Admin into the `Teacher/` folder. But ownership still applies: you can only edit courses where `TeacherID` is your own ID. The admin authors 4 demo courses this way.

**Follow-up →** *"Can a lecturer edit another lecturer's course?"* No. `AccessHelper.Owns` checks ownership, and if it fails they get Access Denied.
</details>

<details><summary><b>Q19. What's the difference between include and extend in a use case diagram?</b></summary>

**Short:** Include is always part of the base use case. Extend is optional and only happens under a condition.

**Example:** Paid checkout *extends* "Enrol in a course", because it only happens for paid courses.
</details>

<details><summary><b>Q20. Why did you draw wireframes?</b></summary>

**Short:** To fix the layout before coding, so all four of us built pages that look and behave the same.

**Follow-up →** *"Low or high fidelity?"* Low: boxes and labels, quick to change. *"What tool?"* 🔴 Only answer if you know.
</details>

<details><summary><b>Q21. What navigation structure does the site use?</b></summary>

**Short:** Three kinds: hierarchical overall (Home → Course → Topic → Item), linear inside lessons and scenarios (previous and next), and networked across areas (dashboard shortcuts, links from results back to activities).
</details>

<details><summary><b>Q22. Name three Nielsen heuristics and show where you applied them.</b></summary>

**Short:**
- **Visibility of system status:** breadcrumbs, highlighted sidebar link, progress bars, save messages
- **Error prevention:** delete confirmations, content lock, a warning about unanswered quiz questions
- **Consistency:** the same master page and layout everywhere

**Bonus:** User control and freedom: a Cancel button on every form and Unpublish instead of delete.
</details>

---

# ROUND 4: FRONT END AND VALIDATION · *Sunil first*

<details><summary><b>Q23. Show me your three types of CSS.</b></summary>

**Short:**
- **External:** `Styles/site.css`
- **Internal:** a `<style>` block in `Site.Master`
- **Inline:** a commented `style=""` on `Default.aspx`

**Follow-up →** *"Which one wins if they conflict?"* Inline has the highest specificity, then IDs, classes and elements. Among equal rules, the one declared later wins. That's why we keep inline styles minimal: they're hard to override and can't be reused.
</details>

<details><summary><b>Q24. What are design tokens?</b></summary>

**Short:** CSS custom properties, such as `--primary: #5a3fc0`, defined once on `:root` and used everywhere with `var(--primary)`.

**Full:** Change one value and the whole site updates. It also makes a future dark theme easy.
</details>

<details><summary><b>Q25. How is the site responsive?</b></summary>

**Short:** Media queries. At 960 px and below, the sidebar turns into a horizontal scrolling row.

**Full:** We tested at 390, 820 and 1366 px (phone, tablet, laptop). There's also a print stylesheet for certificates.

**Follow-up →** *"Why not Bootstrap?"* So the site works offline and the design is entirely our own. The brief allowed templates; we chose not to use one.
</details>

<details><summary><b>Q26. Which HTML5 elements did you use, and why use semantic ones?</b></summary>

**Short:** header, nav, main and footer in the master page; video with a captions track; audio; canvas for charts; progress in the quiz; details; article and aside.

**Why:** Screen readers and search engines understand the structure. For example, `<nav aria-label="Breadcrumb">` is announced as navigation.
</details>

<details><summary><b>Q27. Why validate on both client and server?</b></summary>

**Short:** Client-side is for speed. Server-side is for security, because the browser can be bypassed.

**Full:** Someone can turn off JavaScript or send a request with a tool like Postman, so the client validators never run. Every save handler starts with `if (!Page.IsValid) return;`, which re-runs all validators on the server. The database is a third layer: CHECK and UNIQUE constraints reject bad data even if the code had a bug.

**⚠️ Trap:** Never say the browser validation alone is enough.
</details>

<details><summary><b>Q28. How many validators do you have?</b></summary>

**Short:** 161 in the final code: 76 RequiredField, 49 RegularExpression, 16 Range, 16 Custom and 4 Compare.

**Follow-up →** *"Your slide says 139."* That was an earlier count. The final code has 161. I should have updated the slide.
</details>

<details><summary><b>Q29. Explain your password regex.</b></summary>

**Regex:** `^(?=.*[A-Za-z])(?=.*[0-9]).{8,50}$`

**Short:**
- The first lookahead requires a letter somewhere.
- The second lookahead requires a digit somewhere.
- `.{8,50}` sets the total length to 8–50 characters.

**Follow-up →** *"What's a lookahead?"* It checks that a pattern exists without consuming characters, so several conditions can be tested from the same position.
</details>

<details><summary><b>Q30. What does a CustomValidator do that the others can't?</b></summary>

**Short:** It runs our own C# on the server, for checks only the server can do, such as whether the email is already registered or whether the CAPTCHA answer is correct.
</details>

<details><summary><b>Q31. How do you prevent XSS?</b></summary>

**Short:** User text is HTML-encoded when displayed, and ASP.NET request validation is switched on.

**Full:** We use `<%: %>` (encoded output), `Literal Mode="Encode"`, and `CourseHelper.Encode`. So `<script>` shows up as text instead of running. The code lab is different: it deliberately runs learner HTML, but inside a sandboxed iframe.
</details>

---

# ROUND 5: DATABASE · *Ujwal first*

<details><summary><b>Q32. Why a relational database?</b></summary>

**Short:** Our data is heavily connected, and we need joins, foreign keys and transactions.

**Full:** Subject → Course → Topic → Material/Activity, and learners have enrolments, attempts, payments and so on. Paying and enrolling must succeed or fail together, which needs a transaction.

**Follow-up →** *"Why not MongoDB?"* Document databases are weaker at multi-table joins and enforcing relationships. Our data model is relational by nature.
</details>

<details><summary><b>Q33. What is third normal form? Give an example from your database.</b></summary>

**Short:** Every non-key column depends on the key, the whole key, and nothing but the key.

**Example:** The subject name is stored once in `Subject`. `Course` only stores `SubjectID`, so changing a subject's name changes it everywhere.
</details>

<details><summary><b>Q34. Walk me through the ERD.</b></summary>

**Short:** Two halves: the content chain and the learning records.
- **Content:** Subject → Course → Topic → Material (lessons) and Activity. Each activity type has its own child tables: quiz questions and options, game items and groups, scenario steps and choices, self-assessment statements.
- **People:** a User owns Courses (as lecturer) and has Enrolments, Attempts, Reviews, Bookmarks and Payments (as learner). Quiz answers and self-assessment responses hang off the Attempt.
</details>

<details><summary><b>Q35. Which deletes cascade, and why not all of them?</b></summary>

**Short:** Only the content chain: 8 foreign keys from Course down to Topic, Material, Activity, quiz questions and options, self-assessment statements, game groups and game items.

**Full:** Everything else (attempts, posts, enrolments, scenario steps) is deleted in C# by `DeleteHelper`, children first, inside one transaction. That way learner history never disappears by accident, and we can block a delete, for example when an activity already has attempts.

**Follow-up →** *"Why aren't scenario steps cascaded?"* SQL Server doesn't allow cycles or multiple cascade paths. `Activity.StartStepID` points to `SimStep` and `SimStep` points back to `Activity`, and `GameItem` can be reached through two paths. So those are deleted in code.
</details>

<details><summary><b>Q36. What are composite keys, and where do you use them?</b></summary>

**Short:** A primary key made of two columns. We use them in Enrolment (LearnerID, CourseID), Bookmark, MaterialCompletion, QuizAnswer and SAResponse.

**Why:** The pair is the identity, so the database itself prevents duplicates. A learner can't enrol twice.
</details>

<details><summary><b>Q37. Give examples of CHECK constraints.</b></summary>

**Short:**
- `Role IN ('Learner','Teacher','Admin')`
- `Rating BETWEEN 1 AND 5`
- `ScorePercent BETWEEN 0 AND 100`
- The course price rule: free means price 0, paid means price greater than 0.

**Why:** It's the last line of defence. Even if the C# has a bug, invalid data can't get in.
</details>

<details><summary><b>Q38. Why is progress calculated rather than stored?</b></summary>

**Short:** It's derived data. A stored value would go stale whenever a lecturer adds or removes an item.

**Full:** `ProgressHelper.CalculatePercent` divides completed items by published items. The same query drives the progress bar, the ticks on the course page and certificate eligibility, so they never disagree.

**Follow-up →** *"Isn't that slow?"* At our scale it's one query per course. At large scale we'd cache it: a trade-off between freshness and speed.
</details>

<details><summary><b>Q39. What does your database script check at the end?</b></summary>

**Short:** It runs 12 checks and fails the whole build if any of them fail.

**Full:** Some are integrity rules:
- every quiz question has 2–6 options and exactly one correct option
- quiz answers belong to their own quiz
- scored activities have a score and unscored ones don't
- learners only post in courses they're enrolled in
- every paid enrolment has a completed payment

Others check that the demo data is complete: one admin, 19 courses, and all 8 game types present.
</details>

<details><summary><b>Q40. How many foreign keys and indexes are there?</b></summary>

**Short:** 37 foreign keys and 31 indexes. Indexes speed up common lookups; the trade-off is slightly slower writes.
</details>

---

# ROUND 6: AUTHENTICATION AND SECURITY · *Ujwal first*

<details><summary><b>Q41. Walk me through what happens when I log in.</b></summary>

**Short:** It checks for lockout, verifies the password hash, checks you're on your role's portal, checks your account is Active, then issues an encrypted login cookie containing your role.

**Full:** `AccountSecurityHelper.CheckLogin` runs in a transaction and locks the user's row. Five wrong passwords lock the account for 15 minutes. On success, `AuthenticationHelper.SignIn` stores your ID, role and name in the session and creates a Forms Authentication ticket valid for 30 minutes, in an HttpOnly, Secure, SameSite=Lax cookie.

**⚠️ Trap:** Slide 9 shows the order as "status, then portal". The code actually checks portal, then status.
</details>

<details><summary><b>Q42. How are passwords stored?</b></summary>

**Short:** Salted PBKDF2 with SHA-256 and 100,000 iterations.

**Full:** A random 16-byte salt plus a 32-byte hash, stored as `PBKDF2$100000$<salt>$<hash>`. The comparison checks every byte, so the response time doesn't leak how much of the hash matched.

**Follow-up →** *"Why not MD5 or plain SHA-256?"* They're fast, so attackers can try billions of guesses per second. 100,000 iterations makes each guess slow, and the salt makes identical passwords hash differently and defeats rainbow tables.
</details>

<details><summary><b>Q43. Authentication vs authorisation?</b></summary>

**Short:** Authentication is who you are (login). Authorisation is what you're allowed to do (role and ownership).
</details>

<details><summary><b>Q44. How is a page protected? Name the layers.</b></summary>

**Short:** Three layers:
1. `Web.config` folder rules
2. `RequireRole` at the top of the page, which also checks the account is still active
3. Ownership or enrolment checks for any ID in the URL

**Follow-up →** *"Why is the third layer needed?"* Folder rules only know your role, not whether course 5 is yours. Without the ownership check, changing `?id=` in the URL would let you edit someone else's course. That's called IDOR (insecure direct object reference).
</details>

<details><summary><b>Q45. Where is my role stored after login?</b></summary>

**Short:** In the encrypted login ticket's `UserData`. `Global.asax` attaches it to every request, and it's also copied to `Session["Role"]`.
</details>

<details><summary><b>Q46. What if I edit my cookie to say "Admin"?</b></summary>

**Short:** It won't work. The ticket is encrypted and validated with the server's machine key, so a tampered cookie fails to decrypt and is ignored.

**Extra:** `AttachRole` also only accepts the three known roles.
</details>

<details><summary><b>Q47. How do you prevent SQL injection?</b></summary>

**Short:** Every query uses parameters, through one class, `DatabaseHelper`.

**Full:** A value like `@email` is sent to SQL Server separately from the SQL text, so it's always treated as data, never as code. Typing `' OR 1=1 --` just searches for that literal text. ORDER BY can't be a parameter, so it's chosen from a fixed list in C#. LIKE wildcards in search are escaped.
</details>

<details><summary><b>Q48. How do you protect against CSRF?</b></summary>

**Short:** `ViewStateUserKey` is set to the session ID, so a form posted from another website fails validation.

**Extra:** Web Forms event validation is on, and cookies are `SameSite=Lax`.
</details>

<details><summary><b>Q49. What security headers do you send?</b></summary>

**Short:**
- `X-Frame-Options: SAMEORIGIN` stops clickjacking.
- `X-Content-Type-Options: nosniff` stops MIME sniffing.
- `Referrer-Policy` limits what's sent in the Referer header.

All HTTP requests are also redirected to HTTPS.
</details>

<details><summary><b>Q50. What security is missing?</b></summary>

**Short (be honest):**
- Email verification
- Email-based password reset
- Two-factor authentication
- IP rate limiting
- Checking actual file contents on upload
- A real payment gateway
- A production config: `debug="true"` is still on, and the demo accounts share one password

**Then:** It's a prototype, and those are the next steps for production.

**⚠️ Trap:** Never say "fully secure" or "unhackable".
</details>

<details><summary><b>Q51. How does someone reset a forgotten password without email?</b></summary>

**Short:** The admin sets a temporary password on `UserEdit`. That sets `MustChangePassword`, and `Global.asax` forces the user to the change-password page on their next request.
</details>

<details><summary><b>Q52. Is there an open-redirect risk with ReturnUrl after login?</b></summary>

**Short:** No. `PortalLoginHelper.ReturnUrl` only allows our own `.aspx` pages that the user's role can open. It rejects anything containing `:`, `\`, `//`, `..` or `%`, and anything else falls back to the dashboard.
</details>

---

# ROUND 7: LEARNING FEATURES · *Aashish first*

<details><summary><b>Q53. Walk me through a quiz attempt.</b></summary>

**Short:** Start saves the time in the session. The page shows questions without the correct answers. On submit, the server marks the answers and saves an Attempt plus one answer row per question. Then the result page shows a review.

**Full:**
- **Start:** `QuizHelper.Begin` checks access and the attempts remaining, then stores the start time, a one-time submit token and a fingerprint of the questions.
- **Submit:** `SubmitRun` runs in a SERIALIZABLE transaction. It checks the token, the time limit (with a 30-second grace period), that the quiz hasn't changed, and that every chosen option belongs to its question. Then it calculates marks earned ÷ total × 100 and saves.

**⚠️ Trap:** Nothing is saved until Submit. Don't say "answers are saved as you go".
</details>

<details><summary><b>Q54. How do you stop learners seeing correct quiz answers?</b></summary>

**Short:** The correct-answer flag (`IsCorrect`) never leaves the server. The page only gets option text and option IDs.

**Follow-up →** *"How does the timer work if JavaScript can be changed?"* `quiz.js` only displays the countdown and auto-submits. The server compares against its own stored start time, so a faked timer doesn't help.
</details>

<details><summary><b>Q55. How are games scored?</b></summary>

**Short:** The browser sends only the learner's answers as JSON. The server reloads the correct items from the database and recalculates the score.

**Full:** The hidden field `hfResult` holds `{timeTakenSeconds, moves, answers:[{itemId, value}]}`. Matching compares the chosen ID, Sort compares the group, Scramble and Fill-in-the-blank compare text, True/False and Sequence compare values. The time is measured by the server, not taken from the browser.
</details>

<details><summary><b>Q56. Can a learner cheat at games?</b></summary>

**Short:** They can't submit a fake score, but some answers are visible in the page source.

**Full:** Games give instant feedback, so item data like matching pairs and true/false answers is in the page. Fill-in-the-blank answers and Sequence positions are hidden. The Memory game's move count comes from the browser, and Flashcards are self-rated. Quizzes never expose answers.

**Follow-up →** *"How would you fix it?"* Check each move on the server via AJAX, at the cost of slower feedback.

**⚠️ Trap:** Don't say "the browser never sees any answers". That's only true for quizzes.
</details>

<details><summary><b>Q57. How do scenarios work?</b></summary>

**Short:** A branching story. Each step has choices that lead to other steps, until you reach an ending marked Best, Acceptable or Poor, with feedback.

**Full:** The current step lives in the session with a token and a revision number, so the back button or a double click can't replay an old step. Each choice must start from your current step. On reaching an ending, an Attempt is saved with `EndingStepID` and no score.
</details>

<details><summary><b>Q58. Why aren't self-assessments scored?</b></summary>

**Short:** Confidence isn't knowledge. Mixing ratings into scores would be misleading.

**Full:** Learners rate statements from 1 to 5. The average becomes a level: Needs Improvement (below 2.5), Developing (below 4), or Confident. The database script even fails if a self-assessment attempt has a score.
</details>

<details><summary><b>Q59. How does the code lab stay safe?</b></summary>

**Short:** Learner HTML runs inside an iframe with `sandbox="allow-scripts allow-modals"` and **no** `allow-same-origin`.

**Full:** The frame gets an isolated origin, so it can't read our cookies or the page around it. The code runs only in that learner's browser and never on our server.
</details>

<details><summary><b>Q60. What counts as "completed" for progress?</b></summary>

**Short:**
- **Lesson:** marked complete
- **Quiz, game, self-assessment, scenario:** has any attempt
- **Discussion:** the learner has posted

Only published items count.
</details>

<details><summary><b>Q61. How is the learning streak calculated?</b></summary>

**Short:** The number of consecutive days with any activity (a completion, attempt or post), counting back from today. If you haven't done anything yet today, yesterday still keeps the streak alive. It's calculated each time, never stored.
</details>

<details><summary><b>Q62. When can a learner get a certificate?</b></summary>

**Short:** Only at exactly 100% progress, while enrolled in a published course. Otherwise it's Access Denied.

**Follow-up →** *"What if a lecturer adds a lesson after I got 100%?"* Progress is recalculated, so you'd drop below 100% until you finish the new item.
</details>

<details><summary><b>Q63. How do lessons know which item comes next?</b></summary>

**Short:** The same `ProgressHelper.PublishedItems` query that builds the course outline, ordered by topic, then lessons before activities, then sort order.
</details>

---

# ROUND 8: PAYMENT AND ENROLMENT

<details><summary><b>Q64. Walk me through buying a paid course.</b></summary>

**Short:** Click Buy, then Checkout creates a Pending payment using the price from the database. On the demo eSewa screen you enter a phone number and code. The server marks the payment Complete and enrols you in one transaction.

**Full:**
- **Phone format:** must match `^9[78][0-9]{8}$`.
- **Code:** the last four digits of the phone.
- **Wrong code three times:** the payment becomes Failed. Cancel makes it Canceled.
- **On success:** `PaymentHelper.CompleteDemo` locks the course, then the payment, updates it, inserts the enrolment, and commits.
</details>

<details><summary><b>Q65. Why are payment and enrolment in one transaction?</b></summary>

**Short:** So you can never pay without getting access, or get access without paying. That's atomicity.

**Follow-up →** *"What does ACID stand for?"* Atomicity, Consistency, Isolation, Durability.
</details>

<details><summary><b>Q66. Can I change the price in the browser?</b></summary>

**Short:** No. The browser never sends a price. The server reads `PriceNPR` from the database when it creates the payment.
</details>

<details><summary><b>Q67. What stops a learner enrolling twice?</b></summary>

**Short:** Three things:
1. The composite primary key (LearnerID, CourseID)
2. `IF NOT EXISTS` before the insert
3. A SERIALIZABLE transaction, so two simultaneous clicks can't both insert
</details>

<details><summary><b>Q68. How would you integrate real eSewa?</b></summary>

**Short:** Send a signed payment request to eSewa, receive their callback, then verify the transaction status server-to-server before marking the payment Complete.

**Full:** Our flow (Pending → verify → Complete plus enrol in one transaction) stays the same; only the verify step changes. It needs public HTTPS hosting and a merchant account. `TransactionUUID` already exists as the unique reference.
</details>

<details><summary><b>Q69. Can a lecturer or admin enrol in a course?</b></summary>

**Short:** No. `PaymentHelper` requires the Learner role, and the course page tells them to use a learner account.
</details>

---

# ROUND 9: ADMIN AND LECTURER TOOLS · *Rupesh / Aashish first*

<details><summary><b>Q70. How is a lecturer approved?</b></summary>

**Short:** The admin opens Teacher Applications, which lists Pending lecturers, and clicks Approve (Status becomes Active) or Reject (Status becomes Rejected).

**Full:** The update includes `AND Status='Pending'`, so two admins or two browser tabs can't process the same application twice.
</details>

<details><summary><b>Q71. What can the admin do with users?</b></summary>

**Short:**
- Search and filter
- Activate or deactivate (not themselves, not other admins)
- Unlock locked accounts
- Edit details
- Set a temporary password
- Delete

**Follow-up →** *"Can the admin delete a lecturer who owns courses?"* No, it's blocked. Deleting a learner removes their records in the right order (answers, attempts, posts, completions, bookmarks, enrolments, reviews, then the user) in one transaction.
</details>

<details><summary><b>Q72. Show me full CRUD on one page.</b></summary>

**Short:** Admin → Subjects.
- **Read:** a list with a LEFT JOIN course count
- **Create and Update:** the same form; INSERT if there's no ID, UPDATE if there is
- **Delete:** a button with confirmation, run in a transaction, blocked if any course uses the subject

**Follow-up →** *"Why LEFT JOIN?"* So subjects with zero courses still appear, showing a count of 0.
</details>

<details><summary><b>Q73. What does analytics store?</b></summary>

**Short:** Only the page path, the viewer's role (or "Visitor") and the time. No user ID, IP address or cookie.

**Full:** It's written from `Site.Master` on page loads. About one in every 200 views deletes rows older than 12 months. If analytics fails, the error is swallowed so the page still works.

**Follow-up →** *"How do you count unique visitors?"* We don't. That's a deliberate privacy choice.
</details>

<details><summary><b>Q74. What is "preview" for lecturers?</b></summary>

**Short:** A lecturer can run any lesson or activity exactly as a learner would, but nothing is saved. Preview uses separate session keys and skips every database insert.
</details>

<details><summary><b>Q75. What's the content lock?</b></summary>

**Short:** Once an activity has any attempt, its questions, options, items and steps can't be changed. Only the title and description can.

**Why:** Changing a question after learners answered it would make their stored scores meaningless.

**Follow-up →** *"So how does a lecturer fix a mistake?"* Unpublish it and create a corrected copy, or edit the title and description.
</details>

<details><summary><b>Q76. When can a course be published?</b></summary>

**Short:** Only when at least one topic contains a published lesson or activity (`PublishHelper.CheckCourse`).
</details>

<details><summary><b>Q77. When can't a course be deleted?</b></summary>

**Short:** When it has attempts ("Unpublish instead") or payment history ("Payment history must be retained").
</details>

---

# ROUND 10: TESTING AND ERRORS · *Sunil first*

<details><summary><b>Q78. How did you test the system?</b></summary>

**Short:** At three levels: the build, database checks, and the running site across roles and screen sizes.

**Full:**
- The solution builds with no errors. 🟡 Rebuild to confirm.
- The database script runs 12 checks that fail the build if the data is wrong.
- The report records automated browser tests: 114 links and 23 end-to-end flows. 🔴 Those aren't in the submission.
- We tested manually as each role.

**⚠️ Trap:** Only describe tests you can name or show.
</details>

<details><summary><b>Q79. Show me your automated tests.</b></summary>

**Short (honest):** The browser test run is described in our report's testing section, but the scripts aren't part of the submitted code. I can show you the database checks and run the key flows live right now.

**⚠️ Trap:** Don't invent tool names like Selenium or Playwright unless you know which one was used.
</details>

<details><summary><b>Q80. Did you write unit tests?</b></summary>

**Short:** No, there's no unit test project. Unit tests for the scoring and progress helpers would be our next step.
</details>

<details><summary><b>Q81. What happens when a page doesn't exist?</b></summary>

**Short:** A custom 404 page. `Global.asax` uses `Server.TransferRequest`, so the address the user typed stays in the browser. 404s aren't written to the error log, because they're normal.
</details>

<details><summary><b>Q82. What happens if a learner opens an admin page?</b></summary>

**Short:** Access Denied.

**Full:** `Global.asax` checks the `Web.config` rules early with `CheckUrlAccessForPrincipal`. By default, ASP.NET would send a logged-in user back to the login page, which is confusing, so we show Access Denied instead. Users who aren't logged in are sent to Login.
</details>

<details><summary><b>Q83. What's the difference between 401 and 403?</b></summary>

**Short:** 401 means "who are you?": you're not logged in. 403 means "I know who you are, but no": wrong role or not the owner.
</details>

<details><summary><b>Q84. Why do some forbidden things show 404 instead of 403?</b></summary>

**Short:** For drafts and other people's media, we return Not Found so you can't even confirm they exist.
</details>

<details><summary><b>Q85. Where do error details go?</b></summary>

**Short:** `App_Data/ErrorLog.txt`, written by `Application_Error`. ASP.NET never serves the App_Data folder. Users only see a friendly error page.

**Why:** Stack traces would reveal file paths, framework versions and SQL to attackers.
</details>

<details><summary><b>Q86. What if the database is down?</b></summary>

**Short:** We catch `SqlException` and show "…is unavailable, please try again later", or the error page. Logged-in requests fail closed and redirect to Error.aspx.
</details>

<details><summary><b>Q87. Validation vs testing?</b></summary>

**Short:** Validation checks the user's input while the app runs. Testing checks that our code works correctly before release.
</details>

---

# ROUND 11: CHALLENGE AND "WHY DIDN'T YOU" QUESTIONS

<details><summary><b>Q88. Why Web Forms in 2026? It's outdated.</b></summary>

**Short:** It's the module's technology, and its built-in validators, master pages and Forms Authentication map directly onto the brief.

**Follow-up →** *"What would you use for a real product?"* ASP.NET Core MVC or Razor Pages: cross-platform, faster, actively maintained, and more control over the HTML.
</details>

<details><summary><b>Q89. Why not Entity Framework?</b></summary>

**Short:** We wanted every SQL query visible and explainable, which the brief's documentation asks for, and no extra packages.

**Trade-off:** More manual code, but full control and transparency.
</details>

<details><summary><b>Q90. Why not MySQL?</b></summary>

**Short:** SQL Server LocalDB comes with Visual Studio, integrates with .NET out of the box, and is the same engine as production SQL Server. MySQL would also work, but it needs separate setup and a connector.
</details>

<details><summary><b>Q91. Why not Bootstrap or React?</b></summary>

**Short:** Offline demo, a smaller site, and it shows we can write the CSS and JavaScript ourselves. React would also mean a separate API layer, which is overkill for server-rendered Web Forms.
</details>

<details><summary><b>Q92. Why didn't you use ASP.NET Identity?</b></summary>

**Short:** Forms Authentication was simpler to explain and enough for our needs. Identity would add email confirmation and 2FA, which is a good production upgrade.
</details>

<details><summary><b>Q93. Why separate login pages instead of one?</b></summary>

**Short:** Clearer for each audience, plus an extra check: an account can only sign in on its own role's portal, even with the right password.

**Follow-up →** *"Does a wrong-portal attempt count towards lockout?"* No. A correct password on the wrong portal isn't a failed password.
</details>

<details><summary><b>Q94. Why store every attempt instead of only the latest?</b></summary>

**Short:** History and fairness. Lecturers see every attempt, learners see their improvement, and the dashboard average uses each learner's best score per activity.
</details>

<details><summary><b>Q95. Why use SERIALIZABLE? Isn't it slow?</b></summary>

**Short:** It's the strictest isolation level. We only use it where correctness matters: payments, enrolment, submits and deletes. It prevents another request slipping in between our check and our write.

**Trade-off:** More locking, so less concurrency under heavy load.
</details>

---

# ROUND 12: "WHAT HAPPENS IF…"

<details><summary><b>Q96. …two tabs submit the same quiz at the same time?</b></summary>

**Short:** Only one is saved.

**Full:** A one-time submit token is used up by the first submit. The SERIALIZABLE transaction re-checks the attempts remaining, and ASP.NET processes requests for one session one at a time. The second submit gets an "expired / no attempts" message.
</details>

<details><summary><b>Q97. …someone enters a wrong password five times on my account?</b></summary>

**Short:** Your account is locked for 15 minutes. The admin can unlock it.

**Honest:** Yes, someone could lock another user out temporarily. It's a known trade-off of lockouts. A better fix is IP rate limiting or a CAPTCHA after failures.
</details>

<details><summary><b>Q98. …the lecturer edits a quiz while a learner is taking it?</b></summary>

**Short:** Usually the content lock stops it once attempts exist. If it's the very first attempt, the fingerprint taken at Start won't match at Submit, so nothing is saved and the learner restarts.
</details>

<details><summary><b>Q99. …the admin deactivates a learner who's in the middle of a lesson?</b></summary>

**Short:** On their next protected page, `RequireRole` → `IsActive` returns false, so they're signed out with "your account is no longer active".
</details>

<details><summary><b>Q100. …I change `?id=` in the URL to someone else's course or attempt?</b></summary>

**Short:** Access Denied, or Not Found for drafts. Every page that takes an ID checks ownership or enrolment with `AccessHelper`.
</details>

<details><summary><b>Q101. …I upload a 50 MB video?</b></summary>

**Short:** It's rejected. Videos are limited to 25 MB in `UploadHelper`, and requests over 30 MB are rejected by `Web.config` (`maxRequestLength` / `maxAllowedContentLength`).
</details>

<details><summary><b>Q102. …I rename a .exe to .png and upload it?</b></summary>

**Short (honest):** It's accepted as an image, because we only check the extension and size. But it gets a random GUID name, can never be executed (the Uploads `web.config` blocks handlers), can't be accessed directly, and is served as `image/png` with `nosniff`.

**Fix:** Check the file's magic bytes.
</details>

<details><summary><b>Q103. …the server restarts during a quiz?</b></summary>

**Short:** The in-progress quiz is lost because it lives in the session, but nothing half-saved exists, so the learner just restarts it. Scaling to multiple servers would need a shared session store.
</details>

<details><summary><b>Q104. …I refresh the page right after saving?</b></summary>

**Short:** Nothing is submitted again. After every successful save we redirect to a fresh page (Post/Redirect/Get).
</details>

<details><summary><b>Q105. …a lecturer deletes a lesson a learner already completed?</b></summary>

**Short:** `DeleteHelper` removes its completions and bookmarks first, then the lesson, in one transaction. Progress is recalculated automatically from what's left.
</details>

<details><summary><b>Q106. …10,000 users use it?</b></summary>

**Short:** It would struggle as it is.

**Full:** LocalDB is a development engine, sessions are in one server's memory, files are on local disk, every page view writes an analytics row, and SERIALIZABLE transactions would cause lock waits. To scale: full SQL Server, session state in SQL or Redis, files in blob storage, caching for catalogue and progress, and several web servers behind a load balancer. Data access is centralised in `DatabaseHelper`, so those changes stay contained.

**⚠️ Trap:** Never say "it's already scalable".
</details>

---

# ROUND 13: SHOW ME THE CODE

> Practise opening each file in under 10 seconds.

| Q | Open | Point at |
|---|---|---|
| **Q107.** Show me where SQL injection is stopped. | `Helpers/DatabaseHelper.cs` | `CreateCommand` → `command.Parameters.AddRange(parameters)` |
| **Q108.** Show me server-side validation. | `Account/Register.aspx.cs` | `btnRegister_Click` → `if (!Page.IsValid) return;` + `ValidateRegistration` |
| **Q109.** Show me password hashing. | `Helpers/PasswordHelper.cs` | `Rfc2898DeriveBytes(password, salt, 100000, SHA256)` |
| **Q110.** Show me how the admin folder is protected. | `Web.config` | `<location path="Admin"> <allow roles="Admin"/> <deny users="*"/>` |
| **Q111.** Show me an ownership check. | `Helpers/AccessHelper.cs` | `Owns(...)` → `c.TeacherID=@user` |
| **Q112.** Show me CRUD. | `Admin/Subjects.aspx.cs` | `BindSubjects`, `btnSave_Click`, `gvSubjects_RowCommand` |
| **Q113.** Show me a transaction. | `Helpers/PaymentHelper.cs` | `CompleteDemo` → `BeginTransaction(IsolationLevel.Serializable)` … `Commit()` |
| **Q114.** Show me where the role is attached. | `Global.asax.cs` + `AuthenticationHelper.AttachRole` | `Application_PostAuthenticateRequest` |
| **Q115.** Show me quiz marking. | `Helpers/QuizHelper.cs` | `SubmitRun` → the `earned` / `total` loop |
| **Q116.** Show me game scoring. | `Helpers/GameHelper.cs` | the `Score(...)` method |
| **Q117.** Show me the three CSS types. | `Styles/site.css` `:root` · `Site.Master` `<style>` · `Default.aspx` `style=""` | |
| **Q118.** Show me the error log. | `Global.asax.cs` | `Application_Error` → `App_Data/ErrorLog.txt` |
| **Q119.** Show me progress. | `Helpers/ProgressHelper.cs` | `PublishedItems` + `CalculatePercent` |
| **Q120.** Show me the content lock. | `Helpers/ContentLockHelper.cs` | `HasAttempts` |
| **Q121.** Show me the code lab sandbox. | `Helpers/MaterialHelper.cs` | `sandbox="allow-scripts allow-modals"` |
| **Q122.** Show me the database constraints. | `Database/CreateDatabase.sql` | `CK_User_2`, `CK_Course_Price`, the final `THROW` checks |

<details><summary><b>Q123. Explain this line: <code>if (!Page.IsValid) return;</code></b></summary>

`Page.IsValid` is false if any validator on the page failed, including server-only CustomValidators. If any failed, we stop the handler before touching the database, and the error messages are shown.
</details>

<details><summary><b>Q124. Explain <code>using (SqlConnection c = DatabaseHelper.OpenConnection())</code>.</b></summary>

`using` guarantees the connection is closed and disposed when the block ends, even if an exception is thrown. That prevents connection leaks, and the closed connection goes back to the pool for reuse.
</details>

<details><summary><b>Q125. Explain <code>WITH (UPDLOCK, ROWLOCK)</code> in the login query.</b></summary>

It locks that user's row for update until the transaction ends. Two simultaneous wrong-password attempts then can't both read "3 failures" and both write "4"; the second waits and sees the updated count.
</details>

<details><summary><b>Q126. Explain <code>Response.Redirect</code> after a save.</b></summary>

That's Post/Redirect/Get. After a successful POST we send the browser to a fresh GET page that shows the success message. Refreshing then doesn't resubmit the form.
</details>

<details><summary><b>Q127. Explain <code>IsPostBack</code>.</b></summary>

It's false on the first load of a page and true when a button posts the form back. We load data from the database only on the first load (`if (!IsPostBack) Bind…();`), so we don't overwrite what the user typed.
</details>

<details><summary><b>Q128. What's the fingerprint in QuizHelper?</b></summary>

A SHA-256 hash of the quiz settings and questions, taken at Start. It's compared again at Submit. If the lecturer changed anything in between, nothing is saved and the learner restarts. Every value is length-prefixed so different content can't produce the same string.
</details>

<details><summary><b>Q129. What's <code>RejectDuplicateKeys</code> in GameHelper?</b></summary>

The built-in JSON parser silently keeps the last value when a key appears twice, e.g. `{"value":"a","value":"b"}`. This scanner rejects such malformed results before parsing, so a forged JSON can't sneak a value through.
</details>

<details><summary><b>Q130. Isn't this string concatenation in DeleteHelper SQL injection?</b></summary>

No. The concatenated parts are fixed SQL fragments (subqueries) chosen by our own C# code, never user input. The user-supplied ID is still passed as the `@id` parameter. There's a comment in the code saying exactly this.
</details>

---

# ROUND 14: PERSONAL AND TEAM QUESTIONS

> Agree these as a team. Fill in the blanks with the **truth**.

<details><summary><b>Q131. What exactly did YOU work on?</b></summary>

**Template:** "My main area was ___. Specifically ___ and ___. The hardest part was ___, which we solved by ___. I learned ___."

**Ujwal (example):** "Integration and the database: the schema and constraints, DatabaseHelper, authentication layers, and final verification."
**Sunil (example):** "The visual design and front end: site.css design tokens, the sidebar and mobile layout, custom error pages, and the offline eSewa demo flow."
**Aashish (example):** "Course materials and interactive modules: games, quizzes, scenarios, the lesson pages and overall web design."
**Rupesh (example):** "Administration, reporting and documentation: the admin pages, scope and schedule, and mapping the brief."

**⚠️ Trap:** Don't claim a file you can't explain line by line.
</details>

<details><summary><b>Q132. Show me the part you implemented.</b></summary>

Have **one file** open and ready that you can explain completely:
- **Ujwal:** `DatabaseHelper.cs` / `CreateDatabase.sql`
- **Sunil:** `Styles/site.css` (`:root`, `@media`) / `PaymentHelper.CompleteDemo`
- **Aashish:** `GameHelper.Score` / `games.js` (the end that fills `hfResult`)
- **Rupesh:** `Admin/TeacherApplications.aspx.cs` / `Admin/Users.aspx.cs`
</details>

<details><summary><b>Q133. What was the hardest part of the project?</b></summary>

**Good team answer:** Keeping data consistent. Payment and enrolment had to be one transaction, quiz content had to lock after attempts, and deletes had to run in the right order without losing learner history.

**Personal options:** the mobile layout (Sunil), scoring eight different game types on the server (Aashish), the cascade and delete design (Ujwal), the admin approval and user management rules (Rupesh).
</details>

<details><summary><b>Q134. What did you learn?</b></summary>

**Short:**
1. Agree exact names (tables, helpers, pages) before coding.
2. Build security in from the start.
3. Mark on the server even though it's more work.
4. Test on real phone widths early.
</details>

<details><summary><b>Q135. How did four people avoid breaking each other's code?</b></summary>

**Short:** A shared "contract" of exact table, column, helper and page names agreed before coding, shared helpers instead of copy-pasted logic, and one master page for layout. 🟡 Git was used for the code (commits are from 1–2 Oct).
</details>

<details><summary><b>Q136. Did you use AI to build this?</b></summary>

**Honest answer (agree on the wording as a team):**
"Yes, we used an AI coding assistant for parts of the implementation, under rules we set ourselves: our own blueprint, fixed technology, parameterised SQL only, and simple readable code we could explain. We did the requirements, audience model, ERD and wireframes, and we reviewed and tested what was built. I'm happy to explain any part of the code."

**⚠️ Trap:** Don't deny it. The original repository contains an AI-assistant instruction file (`AGENTS.md`). Check your module's academic-integrity rules on declaring AI use.
</details>

<details><summary><b>Q137. If you started again, what would you do differently?</b></summary>

**Short:** Write unit tests for scoring and progress from the start, test on phones earlier, keep the slides' numbers in sync with the code, and plan for real hosting so the payment gateway could be integrated.
</details>

---

# ROUND 15: KILLER QUESTIONS (STRICT EXAMINER)

<details><summary><b>Q138. "Your slide says the server never trusts the browser. I just opened View Source on a Matching game and found the answers."</b></summary>

**Answer:** "You're right that game item data is in the page. Games need it for instant feedback. What the server never trusts is the **score**: it reloads the items and recalculates from the learner's answers. Quizzes don't send any answers at all. Memory's move count and Flashcards' self-ratings are the weakest points. The fix would be checking each move on the server, at the cost of slower feedback."

*Stay calm. Agree with the true part, then explain the design trade-off.*
</details>

<details><summary><b>Q139. "139 validators? I counted 161."</b></summary>

**Answer:** "161 is correct for the final code: 76 required, 49 regex, 16 range, 16 custom and 4 compare. The 139 was an earlier count, and we should have updated it."
</details>

<details><summary><b>Q140. "Your schedule says 14 weeks, but your commits are all from two days."</b></summary>

**Answer:** "The table is our planned schedule from the proposal. Much of the early work, like requirements, the audience model, ERD, wireframes and the report, wasn't code, and our final integration and redesign was pushed in a short burst at the end. That's when the commits happened."

**⚠️** Only say this if it's true for your team.
</details>

<details><summary><b>Q141. "Aashish and Rupesh have no commits. Did they contribute?"</b></summary>

**Answer:** (Agree as a team.) "Git only shows who pushed code. [Name] worked on [design, documentation, testing, content, diagrams…], which doesn't appear as commits. [Name], could you explain your part?"
</details>

<details><summary><b>Q142. "Show me the 114-link crawl and the 23 end-to-end tests."</b></summary>

**Answer:** "Those are recorded in the report's testing section, but the scripts aren't in the submission. What I can do right now is run the key flows live: registration validation, the wrong-role Access Denied page, the 404 page, a paid enrolment and a quiz submission."

**⚠️ Trap:** Don't invent tool names.
</details>

<details><summary><b>Q143. "Is this system secure?"</b></summary>

**Answer:** "It has the main defences for a prototype: hashed passwords, parameterised SQL, layered authorisation with ownership checks, output encoding, CSRF protection, HTTPS and safe uploads. It isn't production-hardened. It lacks email verification, rate limiting, file content checks and a production config. So I'd call it secure by design for a prototype, not fully secure."
</details>

<details><summary><b>Q144. "What's the weakest part of your system?"</b></summary>

**Pick one and give the fix:**
- "The payment is a demo. Fix: the real eSewa API with server-to-server verification."
- or "Game answers are visible client-side. Fix: per-move server checks."
- or "No unit tests. Fix: tests for GameHelper, QuizHelper and ProgressHelper."
</details>

<details><summary><b>Q145. "Explain what happens, end to end, when I click Submit on a quiz. Every layer."</b></summary>

**Answer:**
1. `quiz.js` may warn about unanswered questions.
2. The form posts back, and Web Forms checks ViewState (which also protects against CSRF).
3. `Global.asax` attaches the role, and the `Member/` folder rule requires a login.
4. `Quiz.aspx.cs` `SubmitQuiz` reads the `q_…` radio values.
5. `QuizHelper.SubmitRun` opens a SERIALIZABLE transaction and checks access, the one-time token, the time limit, the fingerprint, attempts remaining, and that each option belongs to its question.
6. It calculates the percentage on the server.
7. It inserts the Attempt and QuizAnswer rows through `DatabaseHelper` with parameters, then commits and uses up the token.
8. It redirects to `QuizResult.aspx`, which shows the score ring and answer review.
9. Progress and the streak update automatically, because they're calculated.
</details>

<details><summary><b>Q146. "Why is SimStep not cascade-deleted when everything else in the chain is?"</b></summary>

**Answer:** "SQL Server rejects cascade paths that form a cycle or reach the same table two ways. `Activity.StartStepID` points to `SimStep`, `SimStep.ActivityID` points back to `Activity`, and `SimChoice` has two foreign keys to `SimStep`. So DeleteHelper deletes choices, then steps, then the activity, in order inside one transaction."
</details>

<details><summary><b>Q147. "If I steal your database, what do I get?"</b></summary>

**Answer:** "Names, emails, course data and learning records, but no passwords. Only salted PBKDF2 hashes with 100,000 iterations, which are very slow to crack. There are no payment card details, because the payment is a demo that stores only a reference and a masked phone number."
</details>

<details><summary><b>Q148. "Why should we believe Inkwell actually helps students learn?"</b></summary>

**Answer:** "We don't claim proven learning outcomes. We haven't done a user study. What we can show is that the design follows the learners' stated needs: short lessons, immediate marked practice, visible progress and a mobile layout. A study with real students would be the next step."
</details>

<details><summary><b>Q149. "You use session state for quiz runs. What happens with two web servers?"</b></summary>

**Answer:** "In-process session state lives in one server's memory, so with two servers a learner's next request could land on a server that doesn't know their quiz. We'd need a shared session store (the SQL Server session provider or Redis) or sticky sessions."
</details>

<details><summary><b>Q150. "Run the application now."</b></summary>

**Be ready (marks depend on it):**
1. LocalDB is running.
2. The database is attached as `LearningSystemFinal`.
3. Open the `.slnx` and press F5.
4. Go to `https://localhost:44393`.
5. Log in with `ben.lee@inkwell.test` / `Password123`.

Practise this on the presenting laptop the day before (see `WholeProject.md` Part 6.5).
</details>

---

# RAPID-FIRE ROUND (answer in under 5 seconds each)

| # | Question | Answer |
|---|---|---|
| 1 | Framework? | ASP.NET Web Forms, .NET Framework 4.8 |
| 2 | Database? | SQL Server LocalDB, `LearningSystemFinal` |
| 3 | Number of tables? | 25 |
| 4 | Number of pages? | 61 |
| 5 | Helper classes? | 37 |
| 6 | Hash algorithm? | PBKDF2 with SHA-256, 100,000 iterations |
| 7 | Lockout? | 5 failures → 15 minutes |
| 8 | Ticket lifetime? | 30 minutes, sliding |
| 9 | Cookie flags? | HttpOnly, Secure, SameSite=Lax |
| 10 | Connection string name? | `LearningSystemDb` |
| 11 | Class for all SQL? | `DatabaseHelper` |
| 12 | Where are roles enforced per folder? | `Web.config` `<location>` |
| 13 | Where is the role attached? | `Global.asax` → `AuthenticationHelper.AttachRole` |
| 14 | CRUD example page? | `Admin/Subjects.aspx` |
| 15 | Progress method? | `ProgressHelper.CalculatePercent` |
| 16 | Game result field? | hidden field `hfResult` (JSON) |
| 17 | Image upload limit? | 2 MB |
| 18 | Video upload limit? | 25 MB |
| 19 | Upload file names? | GUIDs |
| 20 | Who serves uploads? | `Media.ashx` |
| 21 | Error log location? | `App_Data/ErrorLog.txt` |
| 22 | Cascading foreign keys? | 8 (the content chain) |
| 23 | Total foreign keys? | 37 |
| 24 | DB script checks? | 12 |
| 25 | Validator count? | 161 |
| 26 | Activity types? | 5 |
| 27 | Game templates? | 8 |
| 28 | Lesson types? | 7 (Text, Image, PDF, Video, Audio, YouTube, Code) |
| 29 | Scenario outcomes? | Best, Acceptable, Poor |
| 30 | Self-assessment scale? | 1 to 5 |
| 31 | Quiz grace period? | 30 seconds |
| 32 | Max quiz attempts range? | 0–10 (0 = unlimited) |
| 33 | Admin email? | `admin@inkwell.test` |
| 34 | Demo password? | `Password123` |
| 35 | eSewa demo code? | the last 4 digits of the phone |
| 36 | Phone pattern? | 10 digits starting with 97 or 98 |
| 37 | Wrong eSewa codes allowed? | 3, then the payment is Failed |
| 38 | Isolation level for payment? | SERIALIZABLE |
| 39 | Responsive breakpoint? | 960 px |
| 40 | Test widths? | 390, 820, 1366 px |
| 41 | Audience method? | WSDM (De Troyer & Leune, 1998) |
| 42 | UI principles? | Nielsen's 10 usability heuristics |
| 43 | Accessibility target? | WCAG 2.2 AA |
| 44 | The only NuGet package? | the Roslyn compiler (`DotNetCompilerPlatform`) |
| 45 | Site URL? | `https://localhost:44393` |
| 46 | CSRF defence? | `ViewStateUserKey` + SameSite cookie |
| 47 | Code lab sandbox? | `allow-scripts allow-modals`, no same-origin |
| 48 | Analytics stores? | page path, role, time |
| 49 | Certificate condition? | 100% progress |
| 50 | Save pattern? | Validate → check permission → transaction → commit → message → redirect |

---

## When you get stuck in the real viva
1. **Pause:** "Let me think for a second."
2. **Trace the flow out loud:** *UI → Global.asax → Web.config → Page → Helper → DatabaseHelper → SQL → Redirect.*
3. **Answer what you know**, and say plainly what you don't.
4. **Never bluff.** "I'm not certain about that detail, but in our project…"
5. **Hand over** if it's a teammate's area: "That was [name]'s part. [Name]?"

👉 For **live** questioning, one question at a time with grading and harder follow-ups, tell Claude: **"Teacher attack mode"**, optionally with a topic or name, e.g. *"Teacher attack mode, Aashish, games"*.
