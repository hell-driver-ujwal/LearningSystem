**INKWELL: Whole-Project Understanding, Presentation and Viva Guide**  
***Team:*** * Ujwal Chhetri (NPI000365) · Sunil Kandel (NPI000360) · Aashish Raj Nakarmi (NPI000317) · Rupesh G.C. (NPI000349)*  
 *  
 * ***Module:*** * CT050-3-2-WAPP Web Applications · Instructor: Mr. Prem Shrestha*  
 *  
 * ***Built from:*** * * *Submission/LearningSystem* * (the code), * *Inkwell_Presentation(...).pptx* * (all 25 slides and their speaker notes), the final report * *.docx* *, the assignment brief and the marking scheme.*  
***Labels used throughout:***  
 *  
 🟢 * ***CONFIRMED*** *: seen directly in the code, database script or files.*  
 *  
 🟡 * ***INFERRED*** *: strongly suggested, but not proven.*  
 *  
 🔴 * ***UNKNOWN*** *: cannot be proven from the files. * ***Verify before you claim it.***  
![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAnEAAAACCAYAAAA3pIp+AAAABmJLR0QA/wD/AP+gvaeTAAAACXBIWXMAAA7EAAAOxAGVKw4bAAAANUlEQVR4nO3OMQ2AUBBAsUfyRTCh9VRgEBGsWGAjJK2CbjNzVGcAAPzFtapV7V9PAAB47X4AEWgEMAY9+pUAAAAASUVORK5CYII=)  
**How to use this file**  
This file covers the **whole project and every slide**, so any of the four of you can answer any question. It's meant to be learned in layers, not read in one sitting.  
| | |  
|-|-|  
| **Time you have** | **Read** |   
| **First pass (3 to 4 hours)** | Parts 1–8: what it is, how it works, the flows |   
| **Second pass (2 hours)** | Part 10: all 25 slides, with what to say and the hidden knowledge |   
| **Defence prep (2 hours)** | Parts 11–18: teacher's eye, question trees, danger zones, claims, contradictions, testing, security, limits |   
| **Night before** | Part 19 (who did what), Part 21 (emergency answers), Part 22 (mock viva) |   
| **30 minutes before** | Part 24 only |   
| **Live practice** | Come back to Claude and say **"Teacher attack mode"**, or name a topic or person, e.g. *"Teacher attack mode, database"* |   
   
**Improvements I added to your prompt**  
1. **Part 0, Presenter map.** Who presents what, and who answers which kind of question.  
2. **Part 6.5, Demo run plan.** The marking scheme (Presentation, 15%) says *"Able to execute the application"* in every passing band, so there's a step-by-step run and demo script.  
3. **"Did you use AI?"** (Part 21). An honest, safe answer.  
4. **"Fix before presenting" list** (Part 15). Small slide inaccuracies that are easy attack points.  
5. **Per-member viva prep** (Part 19). Each person gets their own likely questions.  
![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAnEAAAACCAYAAAA3pIp+AAAABmJLR0QA/wD/AP+gvaeTAAAACXBIWXMAAA7EAAAOxAGVKw4bAAAANUlEQVR4nO3OQQmAABRAsSdYxZ4/mJjEsxE8W8GbCFuCLTOzVXsAAPzFuVZ3dXw9AQDgtesBxPEF3bv7x0IAAAAASUVORK5CYII=)  
**PART 0: PRESENTER MAP AND WHO ANSWERS WHAT**  
**Slide ownership (from the speaker notes)**  
| | | |  
|-|-|-|  
| **Slides** | **Topic** | **Presenter (per notes)** |   
| 1 | Title / opening | Ujwal |   
| 2 – 6 | Agenda, problem, objectives, scope, schedule | Rupesh |   
| 7 – 8 | WSDM audience model, use cases | Sunil |   
| 9 | Flowcharts | Aashish |   
| 10 | Brief checklist | Rupesh (Sunil adds detail if asked) |   
| 11 – 12 | Database / ERD | Ujwal |   
| 13 – 15 | Wireframes, navigation, technology and files | Aashish |   
| 16 | Front end: CSS, HTML5, validation | Sunil |   
| 17 – 18 | Database connectivity / CRUD, authentication | Ujwal |   
| 19 | Server never trusts the browser | Aashish |   
| 20 | Testing, errors, small screens | Sunil |   
| 21 – 22 | Visitors, learners | Aashish |   
| 23 | Lecturers (Aashish) and administrators (Rupesh) | Aashish + Rupesh |   
| 24 – 25 | Summary, lessons, future, Q&A | Ujwal |   
   
⚠️ **Mismatch:** Slide 2 (agenda) says *Sunil: slides 7 to 10*, but the speaker notes give slide 9 to **Aashish** and slide 10 to  **Rupesh**. Agree on one version before presenting.  
**Who answers which questions (slide 25 notes)**  
| | | |  
|-|-|-|  
| **Question area** | **First responder** | **Backup** |   
| Database, integration, authentication, SQL | **Ujwal** | Sunil |   
| Requirements, design, front end, CSS, validation, testing, responsive | **Sunil** | Aashish |   
| Course materials, games, quizzes, scenarios, navigation, user screens | **Aashish** | Ujwal |   
| Scope, schedule, admin pages, reporting, documentation | **Rupesh** | Sunil |   
   
**Everyone** must be able to explain these five things, because any teacher can ask anyone:  
1. The one-sentence pitch.  
2. What happens when you press a button (the request flow).  
3. How SQL injection is prevented.  
4. Server-side plus client-side validation.  
5. Where CRUD is shown.  
![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAnEAAAACCAYAAAA3pIp+AAAABmJLR0QA/wD/AP+gvaeTAAAACXBIWXMAAA7EAAAOxAGVKw4bAAAANklEQVR4nO3OQQmAABRAsSfYxZo/jkUsYQLPJrCCNxG2BFtmZquOAAD4i3Ot7mr/egIAwGvXA4rDBc72meO5AAAAAElFTkSuQmCC)  
**PART 1: PROJECT IN ONE PAGE**  
**Level 1: one sentence (everyone memorises this)**  
***"Inkwell is an online learning website where every topic ends with a practice activity that the server marks and saves to the learner's progress."***  
**Level 2: 30 seconds**  
*"Inkwell is a learning platform built with ASP.NET Web Forms, C# and SQL Server. Visitors can browse courses and try free preview lessons. Learners enrol, study lessons, and practise with quizzes, eight kinds of games,* * branching scenarios, self-assessments and discussions. The server marks everything, so nobody can fake a score. Lecturers build their own courses with form-based builders, and the admin manages users, lecturer approvals, subjects, payments and analytics."*  
**Level 3: 2 minutes**  
- **Problem:** Free resources explain a topic but never check that you understood it. Our audience (17–21-year-old foundation students) studies in short bursts on phones. Lecturers know their subject but can't build websites.  
- **Solution:** Every topic ends with an activity. The server marks it and records it. Lecturers get no-code builders.  
- **Users:** Visitor, Learner, Lecturer (stored as Teacher in code), Administrator.  
- **Main features:**  
  - Search, filter and sort the catalogue  
  - Free preview lessons  
  - Free or paid enrolment, with paid courses going through an *offline demo* eSewa screen  
  - Lessons in 7 formats: text, image, PDF, video, audio, YouTube, and code lab  
  - 5 activity types (quiz, game, scenario, self-assessment, discussion) and 8 game templates  
  - Progress, learning streak and certificate  
  - Reviews and bookmarks  
  - Lecturer builders with preview and content lock  
  - Admin management: users, approvals, subjects, FAQs, messages, payments, analytics  
- **Tech:** ASP.NET Web Forms on .NET Framework 4.8, C#, ADO.NET (parameterised SQL), SQL Server LocalDB (25 tables), HTML5, one CSS file, plain JavaScript. No frameworks, no CDN, works offline.  
**Level 4: 5-minute technical view**  
***Browser → IIS Express → Global.asax (who are you?*** ***) → Web.config folder rules (may you enter?) → the .aspx page with its C# code-behind → a Helper class (the logic) → DatabaseHelper (the only place that talks to SQL) → SQL Server → the code-behind redirects → a fresh page shows a success or error message.***  
Details are in Parts 3–8.  
![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAnEAAAACCAYAAAA3pIp+AAAABmJLR0QA/wD/AP+gvaeTAAAACXBIWXMAAA7EAAAOxAGVKw4bAAAANElEQVR4nO3OQQmAABRAsSdYxKY/jbnMIJ7FCt5E2BJsmZmt2gMA4C+Otbqr8+sJAACvXQ85TgYRMv3/cwAAAABJRU5ErkJggg==)  
**PART 2: WHAT WE ACTUALLY BUILT (THE REALITY IN THE CODE)**  
**Numbers checked against the code**  
| | |  
|-|-|  
| **Claim** | **Reality in ** **Submission/LearningSystem** |   
| 61 pages | 🟢 Exactly 61 .aspx files |   
| 37 helper classes | 🟢 Exactly 37 .cs files in Helpers/ |   
| 25 tables | 🟢 25 CREATE TABLE. The script itself throws an error unless there are exactly 25 |   
| 37 foreign keys, 8 of them cascading | 🟢 counted in CreateDatabase.sql |   
| 31 indexes | 🟢 counted |   
| 8 game templates | 🟢 Matching, Memory, Scramble, Sort, Flashcards, FillBlank, TrueFalse, Sequence |   
| 139 validators (slides) | ⚠️ **161 in the code**: 76 RequiredField, 49 RegularExpression, 16 Range, 16 Custom, 4 Compare |   
| 12 integrity checks | 🟢 12 THROW statements at the end of the DB script (some check demo data, see Slide 20) |   
| No frameworks | 🟢 5 small JS files, 1 main CSS file (859 lines) + print.css |   
| Only NuGet package | 🟢 Microsoft.CodeDom.Providers.DotNetCompilerPlatform (the Roslyn compiler) |   
| Demo data | 🟢 12 users (1 admin, 6 active lecturers, 1 pending lecturer, 4 learners), 8 subjects, 19 courses (1 draft), 3 paid courses |   
   
**Folder map (only what matters)**  
Submission/LearningSystem/  
 ├── Web.config              ← connection string, login settings, FOLDER ACCESS RULES, custom errors, upload limits, security headers  
├── Global.asax(.cs)        ← code that runs on EVERY request: HTTPS, role, access denied, error log  
├── Site.Master(.cs)        ← shared layout: header, nav, role sidebar, breadcrumb, message box, footer, internal CSS  
 ├── Default / Courses / CourseDetails / Preview / About / Help / Contact / SiteMap / Privacy / Terms .aspx  ← public  
 ├── NotFound / AccessDenied / Error .aspx   ← friendly 404 / 403 / 500  
 ├── Media.ashx(.cs)         ← serves uploaded files ONLY after a permission check  
 ├── Account/                ← Register, Login (chooser), StudentLogin, TeacherLogin, AdminLogin, Logout  
├── Learner/                ← Dashboard, MyCourses, CourseHome, MyResults, MyBookmarks, MyPayments, Certificate, Checkout  
 ├── Member/                 ← any signed-in user: Lesson, Quiz, QuizResult, PlayGame, Scenario, SelfAssessment, Discussion, Profile, ChangePassword  
├── Teacher/                ← Dashboard, MyCourses, CourseEdit, CourseBuilder, MaterialEdit, QuizBuilder, GameBuilder, SABuilder, ScenarioBuilder, DiscussionEdit, Results, CourseLearners  
├── Admin/                  ← Dashboard, Users, UserEdit, TeacherApplications, Subjects, Courses, Activities, Messages, FAQ, Payments, Analytics  
├── Payment/                ← EsewaDemo, EsewaSuccess  
 ├── Helpers/                ← 37 shared C# classes (the real "brain")  
 ├── Scripts/                ← site.js (menu, code lab), quiz.js (timer), games.js (8 games), charts.js (canvas), shortcuts.js  
├── Styles/                 ← site.css (design tokens, layout, responsive), print.css (certificate)  
 ├── Fonts/, Assets/         ← local fonts, images, the home video with a .vtt captions file  
 ├── Uploads/                ← Images/, Documents/, Video/, Audio/ + its own web.config that blocks scripts  
├── App_Data/               ← LearningSystemFinal.mdf (the database), ErrorLog.txt (private)  
 └── Database/               ← CreateDatabase.sql (schema + demo data + checks), CreateFinalDatabase.ps1, seed scripts  
   
**Features the PPT doesn't mention (good to bring up when asked about security or "anything extra?")**  
- 🟢 **Math CAPTCHA** on Register and Contact (CaptchaHelper: "What is 4 + 7?")  
- 🟢 **Terms checkbox** on Register  
- 🟢 **Admin password reset** → sets MustChangePassword = 1 → Global.asax forces the user to ChangePassword.aspx  
- 🟢 **Admin unlock** of locked accounts (Admin/Users.aspx)  
- 🟢 **Open-redirect protection** on ReturnUrl after login  
- 🟢 **CSRF protection**: Page.ViewStateUserKey = Session.SessionID (Site.Master.cs)  
- 🟢 **HTTPS redirect** on every request  
- 🟢 **Security headers**: X-Frame-Options, X-Content-Type-Options: nosniff, Referrer-Policy  
- 🟢 **SEO**: generated robots.txt and sitemap.xml (SeoHandlers.cs)  
- 🟢 **Video seeking** via HTTP Range requests in Media.ashx  
- 🟢 **Keyboard shortcuts**: Alt+H (home), Alt+C (courses), Alt+D (dashboard), Alt+Q (help)  
- 🟢 **Catalogue paging** with OFFSET … FETCH, and search that treats % and _ as literal text  
- 🟢 **Double-submit protection** (one-time session tokens on edit/submit forms)  
![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAnEAAAACCAYAAAA3pIp+AAAABmJLR0QA/wD/AP+gvaeTAAAACXBIWXMAAA7EAAAOxAGVKw4bAAAANElEQVR4nO3OQQmAUBBAwSfIb+HdmNvAkgaxgjcRZhLMNjNHdQUAwF/ce7Wq8+sJAACvrQctewNKtdojwQAAAABJRU5ErkJggg==)  
**PART 3: PROJECT ARCHITECTURE**  
**The big picture**  
                 BROWSER  (HTML5 + Styles/site.css + Scripts/*.js)  
                          │  GET a page  /  POST the form back (a "postback")  
                          ▼  
    ┌──────────────── IIS Express  https://localhost:44393 ───────────────────────┐  
    │ Global.asax.cs  (runs on EVERY request)                                     │  
    │   Application_BeginRequest      → not HTTPS? redirect to HTTPS              │  
    │   Application_PostAuthenticate  → read role from login ticket, attach it;   │  
    │                                   must-change-password? → ChangePassword;   │  
    │                                   wrong folder for role? → AccessDenied     │  
    │   Application_Error             → write details to App_Data/ErrorLog.txt,   │  
    │                                   show NotFound.aspx or Error.aspx          │  
    │                                                                             │  
    │ Web.config <location> rules:  Learner/ → Learner   Teacher/ → Teacher,Admin │  
    │                               Admin/ → Admin       Payment/ → Learner       │  
    │                               Member/ → any logged-in user                  │  
    │                                                                             │  
    │ Site.Master (layout)  ─┬─ Page.aspx       (HTML + server controls + validators)  
    │                        └─ Page.aspx.cs    (Page_Load, button click handlers)│  
    │                                 │                                           │  
    │                                 ▼                                           │  
    │                     Helpers/*.cs   (AccessHelper, QuizHelper, GameHelper,   │  
    │                                     PaymentHelper, ProgressHelper, ...)     │  
    │                                 │                                           │  
    │                                 ▼                                           │  
    │                     DatabaseHelper.cs  (the ONLY place that opens a         │  
    │                                         SqlConnection; always parameters)   │  
    └─────────────────────────────────┬───────────────────────────────────────────┘  
                                      │ ADO.NET  SqlCommand + SqlParameter  
                                      ▼  
                 SQL Server LocalDB, database "LearningSystemFinal"  
                 25 tables · 37 foreign keys · CHECK / UNIQUE constraints · 31 indexes  
   
**It is a 3-layer design (say this if asked about "architecture")**  
| | | |  
|-|-|-|  
| **Layer** | **In Inkwell** | **Job** |   
| **Presentation** | .aspx pages, Site.Master, site.css, Scripts/ | What the user sees and clicks |   
| **Logic** | Code-behind .aspx.cs + Helpers/ | Rules: who may do what, scoring, progress, payments |   
| **Data** | DatabaseHelper + SQL Server | Storing and retrieving data, enforcing constraints |   
   
🟡 It isn't a formal MVC or n-tier architecture with separate projects, but the logic is clearly separated into the shared helpers.  
**Memory anchors**  
- **Request:***Global (who?) → Web.config (allowed?) → Page (what?) → Helper (rules) → DatabaseHelper (SQL) → Redirect (result)*  
- **Save pattern:***Validate → Check permission → Transaction → Commit → Message → Redirect*  
**Key terms (technical term → simple meaning → how Inkwell uses it)**  
| | | |  
|-|-|-|  
| **Term** | **Simple meaning** | **In Inkwell** |   
| **ASP.NET Web Forms** | Microsoft framework where each page is an .aspx markup file plus a C# file | Every page, e.g. Account/Register.aspx + Register.aspx.cs |   
| **Code-behind** | The C# file that handles a page's events | btnRegister_Click runs when Register is pressed |   
| **Postback** | The page's form submits back to the same page on the server | Save on Admin/Subjects.aspx posts back to itself |   
| **IsPostBack** | false on first load, true after a button posts back | if (!IsPostBack) BindSubjects(); loads data only once |   
| **ViewState** | A hidden field where Web Forms remembers control values between postbacks | Automatic. ViewStateUserKey ties it to your session to stop CSRF |   
| **Server control** | A tag like <asp:TextBox runat="server">, rendered as HTML and readable from C# | txtEmail, ddlRole, btnSave, gvSubjects (GridView) |   
| **.designer.cs** | Auto-generated declarations of a page's controls | Lets C# write txtEmail.Text |   
| **Master page** | A shared template every page plugs into | Site.Master with ContentPlaceHolder ID="MainContent" |   
| **ADO.NET** | .NET's basic database classes | SqlConnection, SqlCommand, SqlParameter, SqlDataAdapter |   
| **Parameterised SQL** | Input is sent separately from the SQL text, so it can never change the query | WHERE Email=@email + new SqlParameter("@email", …) |   
| **Forms Authentication** | ASP.NET's cookie-based login | Encrypted ticket with UserData = role |   
| **Session** | Per-user memory on the server | Session["UserID"], quiz start time Session["QuizStart_{id}"] |   
| **Transaction** | Several SQL statements that all succeed or all fail | Payment + enrolment, deletes, quiz submit |   
| **Isolation level SERIALIZABLE** | The strictest locking: transactions behave as if they ran one at a time | Enrol, payment, quiz/game submit, deletes |   
| **HTTP handler (** **.ashx** **)** | A lightweight endpoint that returns data, not a page | Media.ashx streams files after a permission check |   
| **Post/Redirect/Get (PRG)** | After a successful save, redirect so refresh doesn't resubmit | MessageHelper.SetSuccess(...) then Response.Redirect(...) |   
| **HTML encoding** | Turning < into &lt; so user text can't become code | <%: %>, Literal Mode="Encode", CourseHelper.Encode |   
   
![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAnEAAAACCAYAAAA3pIp+AAAABmJLR0QA/wD/AP+gvaeTAAAACXBIWXMAAA7EAAAOxAGVKw4bAAAANUlEQVR4nO3OsQ1AABRAwSdRaPXGMOCv7WkPK+hEcjfBLTNzVFcAAPzFvVZbdX49AQDgtf0BSpoDXv5TGXgAAAAASUVORK5CYII=)  
**PART 4: TECHNOLOGY STACK (WHAT, WHY, HOW, ALTERNATIVE, TRADE-OFF)**  
**ASP.NET Web Forms (.NET Framework 4.8)**  
- **What:** A server-side framework. Each page is an .aspx file with a C# code-behind.  
- **Why:** The site needs server processing, a database, logins and forms.  
- **Why this one:** 🟡 It's the module's technology. It gives us validator controls, master pages, GridView and Forms Authentication built in, which map directly onto the brief (validation, navigation, CRUD, member/admin login).  
- **How:** IIS Express runs the pages. Button clicks cause postbacks to code-behind handlers.  
- **Alternatives:** ASP.NET Core MVC or Razor Pages, PHP + MySQL, Node.js + Express.  
- **Trade-off:** + fast form building, built-in validation and auth. − legacy (no new features), Windows-only, heavy ViewState, and the event model hides HTTP details.  
- **Teacher question:** "Why not ASP.NET Core?" → *"Module requirement, and Web Forms' built-in validators and Forms Auth fit the brief. For a real product today we'd choose Core: cross-platform, faster, actively maintained."*  
**C#**  
- **Where:** code-behind and Helpers/.  
- **Why:** The language of ASP.NET. It's strongly typed, so many mistakes are caught at build time.  
- **Teacher question:** "Where's your business logic?" → *"In the Helpers folder, so pages stay thin and the same rule (e.g. progress) is used everywhere."*  
**ADO.NET, with no ORM**  
- **What:** Writing SQL directly with SqlCommand and SqlParameter.  
- **Why this:** The brief asks for SQL queries in the documentation, and we wanted every query visible and explainable. It's also simple, with no extra packages.  
- **Alternative:** Entity Framework (an ORM that maps tables to C# classes).  
- **Trade-off:** + full control, transparent SQL, easy to explain. − more code, manual mapping of results, and safety relies on discipline (always using parameters).  
**SQL Server LocalDB**  
- **What:** A lightweight SQL Server that runs on demand on a developer's machine. It ships with Visual Studio.  
- **Why this:** It's the real SQL Server engine (same T-SQL), needs no server installation, and works offline.  
- **Alternatives:** MySQL, PostgreSQL, SQLite, MongoDB.  
- **Trade-off:** + professional relational engine, transactions, constraints. − development-only and single machine, not meant for hosting.  
- **Why relational:** The data is highly connected (Subject → Course → Topic → Material/Activity; users ↔ enrolments, attempts). It needs joins, foreign keys and transactions.  
**HTML5 + CSS + plain JavaScript**  
- **Why:** The brief requires HTML5 and CSS. No framework means a small site that runs  **without internet** during the demo, and it shows we can write it ourselves.  
- **Alternatives:** Bootstrap, Tailwind, React.  
- **Trade-off:** + light, fully custom, offline. − more hand-written CSS, and no component library.  
**Forms Authentication + PBKDF2**  
- **Why:** Built into Web Forms. The role is carried in the ticket and folder rules use it.  
- **Alternative:** ASP.NET Identity (has features like email confirmation and 2FA).  
- **Trade-off:** + simple and transparent. − we had to write lockout, hashing and approval logic ourselves.  
**JavaScriptSerializer (built-in JSON)**  
- **Where:**GameHelper.ParseResult reads the game's JSON result.  
- **Why:** It's built into .NET 4.8, so no NuGet package is needed.  
- **Trade-off:** It's lenient (accepts duplicate keys), so we added RejectDuplicateKeys.  
**Quick table**  
| | | |  
|-|-|-|  
| **Tech** | **Where** | **Role** |   
| ASP.NET Web Forms 4.8 | everywhere | page framework |   
| C# | .aspx.cs, Helpers/ | logic |   
| ADO.NET | DatabaseHelper | DB access |   
| SQL Server LocalDB | App_Data/ | storage |   
| Forms Auth | AuthenticationHelper, Web.config | login cookie with role |   
| PBKDF2 (Rfc2898DeriveBytes) | PasswordHelper | password hashing |   
| HTML5 | .aspx, Site.Master | structure, media |   
| CSS3 (custom properties, media queries) | Styles/site.css | design, responsive |   
| JavaScript | Scripts/ | games, quiz timer, charts, code lab, menu |   
| <canvas> | charts.js | lecturer and admin charts |   
| IIS Express | Visual Studio | local web server |   
   
![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAnEAAAACCAYAAAA3pIp+AAAABmJLR0QA/wD/AP+gvaeTAAAACXBIWXMAAA7EAAAOxAGVKw4bAAAANElEQVR4nO3OQQmAABRAsad4EjtY9fewnUms4E2ELcGWmTmrKwAA/uLeqrU6vp4AAPDa/gDzWAM6QQXRdAAAAABJRU5ErkJggg==)  
**PART 5: IMPORTANT FEATURES (DEEP EXPLANATION)**  
**Feature map**  
| | | | | | |  
|-|-|-|-|-|-|  
| **Feature** | **User goal** | **Front end** | **Back end** | **Database** | **Key logic** |   
| Register | Create an account | Account/Register.aspx | Register.aspx.cs, PasswordHelper, CaptchaHelper | User | Learner → Active; Teacher → Pending |   
| Login ×3 portals | Sign in | StudentLogin/TeacherLogin/AdminLogin.aspx | PortalLoginHelper, AccountSecurityHelper, AuthenticationHelper | User | lock → hash → portal → status → ticket |   
| Catalogue | Find courses | Courses.aspx | code-behind | Course, Subject, User | Only Published; filter, search, sort, page |   
| Course details | Judge a course | CourseDetails.aspx | CourseHelper, ReviewHelper | Course, Topic, Review | Enrol card, reviews (enrolled learners only) |   
| Free preview | Try before joining | Preview.aspx | AccessHelper.CanViewFreePreview | Material.IsPreview | Published material + published course + preview flag |   
| Enrol / pay | Join | CourseDetails → Learner/Checkout → Payment/EsewaDemo → EsewaSuccess | PaymentHelper | Enrolment, Payment | Serializable transactions; price from the DB |   
| Course home | See the outline and progress | Learner/CourseHome.aspx | ProgressHelper.PublishedItems | many | Ticks and progress from one query |   
| Lesson | Study | Member/Lesson.aspx | MaterialHelper, LessonFormatter | Material, MaterialCompletion | Mark complete; prev/next |   
| Code lab | Experiment | Member/Lesson.aspx | MaterialHelper | Material (type Code) | Runs in a sandboxed <iframe srcdoc> |   
| Quiz | Test knowledge | Member/Quiz.aspx, QuizResult.aspx, quiz.js | QuizHelper | Attempt, QuizAnswer | Answers never sent; server marks; timer |   
| Games ×8 | Practise | Member/PlayGame.aspx, games.js | GameHelper | GameItem, GameGroup, Attempt | JSON answers → server re-scores |   
| Scenario | Practise decisions | Member/Scenario.aspx | ScenarioHelper, ScenarioPlayHelper | SimStep, SimChoice, Attempt.EndingStepID | Branching; ending outcome; no % |   
| Self-assessment | Reflect on confidence | Member/SelfAssessment.aspx | SelfAssessmentHelper | SAStatement, SAResponse | Ratings 1–5 → level text; no % |   
| Discussion | Discuss | Member/Discussion.aspx | DiscussionHelper, ActivityAccessHelper | DiscussionPost | One reply level; can be closed |   
| Progress / streak | Motivation | Dashboards | ProgressHelper, EngagementHelper | calculated | Never stored |   
| Certificate | Proof | Learner/Certificate.aspx + print.css | ProgressHelper | none | Only at exactly 100% |   
| Reviews, bookmarks | Feedback, saving | CourseDetails, Learner/MyBookmarks | ReviewHelper, BookmarkHelper | Review, Bookmark | One review per learner per course |   
| Course builder | Author a course | Teacher/* | AccessHelper.Owns, PublishHelper, ContentLockHelper, UploadHelper | content chain | Ownership; content lock; publish rules |   
| Lecturer results | Follow learners | Teacher/Results.aspx, CourseLearners.aspx | ResultsHelper, ChartHelper | Attempt | Canvas charts |   
| Admin | Run the platform | Admin/* | DeleteHelper, AnalyticsHelper, … | all | Approvals, CRUD, blocked deletes |   
| Contact | Message the admin | Contact.aspx | code-behind + CAPTCHA | ContactMessage | Admin reads in Admin/Messages |   
| Analytics | See usage | Admin/Analytics.aspx | AnalyticsHelper | PageView | Path + role + time only |   
   
**5.1 Activity types (know the differences)**  
| | | | |  
|-|-|-|-|  
| **Type** | **Scored?** | **What's stored** | **Why** |   
| **Quiz** | ✅ % from marks | Attempt.ScorePercent + QuizAnswer per question | Objective test |   
| **Game** | ✅ % | Attempt.ScorePercent (+ time) | Practice with instant feedback |   
| **Scenario** | ❌ | Attempt.EndingStepID → outcome Best / Acceptable / Poor | Judgement is about the path, not a percentage |   
| **Self-assessment** | ❌ (average 1–5 → "Needs Improvement / Developing / Confident") | SAResponse.Rating per statement | Confidence isn't knowledge, so it's never mixed into scores |   
| **Discussion** | ❌ | DiscussionPost | Participation |   
   
🟢 The database script **enforces** this (THROW 51010): quizzes and games must have a score; self-assessments and scenarios must  **not** have one.  
**5.2 The 8 game templates (how each is scored on the server, **GameHelper.Score **)**  
| | | |  
|-|-|-|  
| **Template** | **Browser sends ** **value** ** =** | **Server scores by** |   
| Matching | ItemID of the chosen match | correct if it equals the item's own ID; each target used once |   
| Sort | GroupID it was placed in | correct if it equals the item's GroupID |   
| Scramble | the typed word | case-insensitive compare to ItemText (3–15 letters) |   
| FillBlank | the typed answer | normalised compare (trim, collapse spaces, lowercase). The answer is **not** sent to the browser |   
| TrueFalse | "True"/"False"/"Skip" | compare to ItemText |   
| Sequence | position number | compare to the stored position. Positions are **not** sent; steps are shown alphabetically |   
| Memory | no answers, just moves | 100 − 5 × (moves − pairs) − seconds/10 (moves from the browser, seconds from the server) |   
| Flashcards | "known"/"learning" | % rated known (self-rating) |   
   
**5.3 Course and content lifecycle**  
Lecturer creates course (Status = Draft)  
   → adds Topics → adds Materials (lessons) and Activities (each Draft or Published)  
   → previews each item (preview=1: nothing saved)  
   → Publish course: PublishHelper.CheckCourse needs ≥1 topic with a published item  
   → learners enrol and attempt  
   → once an activity has an Attempt: its questions/items/steps are LOCKED (ContentLockHelper)  
   → a course/topic/activity with attempts cannot be deleted: "Unpublish instead"  
   → a course with payment history cannot be deleted: "Payment history must be retained"  
   
**5.4 User account lifecycle**  
Register as Learner  → Active  
 Register as Teacher  → Pending → (admin) Approve → Active  
                                → (admin) Reject  → Rejected (can't log in)  
 Active ⇄ Deactivated   (admin, Users page; the admin can't deactivate themselves)  
 5 wrong passwords      → LockedUntil = now + 15 min  (admin can Unlock)  
 Admin resets password  → MustChangePassword = 1 → forced to ChangePassword on next request  
 Admin account          → only created by the database script (exactly one)  
   
![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAnEAAAACCAYAAAA3pIp+AAAABmJLR0QA/wD/AP+gvaeTAAAACXBIWXMAAA7EAAAOxAGVKw4bAAAANElEQVR4nO3OQQmAABRAsaeILbwZ9Fewo0Gs4E2ELcGWmTmqKwAA/uLeqr06v54AAPDa+gAthwNEfGhnhAAAAABJRU5ErkJggg==)  
**PART 6: FOLLOW-THE-BUTTON FLOWS**  
*For each flow: * ***UI → handler → validation → permission → database → response → what you see.*** * These are the most important exercises in this file.*  
**6.1 Visitor clicks ** **Register**  
1  UI           Account/Register.aspx: txtFullName, txtEmail, txtPassword, txtConfirm, ddlRole, txtReason, txtCaptcha, chkTerms  
 2  Browser      Validators' JavaScript runs first:  
                   RequiredField (empty?), RegularExpression (password ^(?=.*[A-Za-z])(?=.*[0-9]).{8,50}$),  
                   CompareValidator (passwords match) → errors shown instantly, form NOT sent  
 3  Postback     Form posts to the same page  
 4  Server       ALL validators run again + CustomValidators:  
                   ValidateRegistration: role must be Learner/Teacher; Teacher reason 20–500 chars;  
                                         SELECT COUNT(*) FROM [User] WHERE Email=@email must be 0  
                   ValidateTerms: checkbox ticked  
                   ValidateCaptcha: CaptchaHelper.Check (answer kept in Session; a new question on failure)  
 5  Handler      btnRegister_Click → if (!Page.IsValid) return;  
 6  Hash         PasswordHelper.HashPassword → "PBKDF2$100000$<salt>$<hash>"  
 7  Database     INSERT INTO dbo.[User] (FullName, Email, PasswordHash, Role, Status, ApplicationReason)  
                 VALUES (@name, @email, @hash, @role, @status, @reason)       ← all parameters  
 8  Race guard   Same email submitted twice at once → UNIQUE(Email) fails → SqlException 2601/2627 → friendly message  
 9  Response     MessageHelper.SetSuccess → Response.Redirect (Post/Redirect/Get)  
 10 Visible      Learner → StudentLogin with "Your account is ready".  
                 Teacher → Home with "application sent… log in once approved"  
   
**6.2 User clicks ** **Log in** ** (e.g. the Learner portal)**  
1  UI           Account/StudentLogin.aspx → btnLogin_Click → if (!Page.IsValid) return;  
 2  Helper       PortalLoginHelper.Login(page, email, password, "Learner")  
 3  Checks       AccountSecurityHelper.CheckLogin, in ONE transaction:  
                   a) SELECT … FROM [User] WITH (UPDLOCK,ROWLOCK) WHERE Email=@email   (locks the row)  
                   b) No user?            → "The email or password is incorrect."     (generic)  
                   c) LockedUntil > now?  → "Account temporarily locked. Try again in N minute(s)."  
                   d) Wrong password?     → FailedLoginCount+1; at 5 → LockedUntil = now+15 min  
                   e) Wrong portal?       → "This account cannot use this portal" (NOT counted as a failure)  
                   f) Not Active?         → Pending / Rejected / Deactivated message  
                   g) OK                  → FailedLoginCount=0, LockedUntil=NULL, commit  
 4  Sign in      AuthenticationHelper.SignIn: Session.Clear(); Session[UserID, Role, FullName];  
                 FormsAuthenticationTicket(UserID, 30 min, UserData=role) → Encrypt → cookie  
                 (HttpOnly, Secure, SameSite=Lax)  
 5  Redirect     PortalLoginHelper.ReturnUrl: MustChangePassword? → ChangePassword.  
                 Else a SAFE ReturnUrl (own .aspx, allowed for the role) or the role's dashboard  
 6  Afterwards   Every request: Global.asax → AttachRole → Web.config folder rules use the role  
   
⚠️ Slide 9 lists the order *validation, lock-out, hash, status, portal*. The **code** does lock-out → hash →  **portal → status**. Describe the code's order.  
**6.3 Visitor ** **searches the catalogue**  
Courses.aspx: ddlSubject, ddlPrice (free/paid), txtSearch, ddlSort, Search button  
 → SearchCourses → redirects to Courses.aspx?subject=…&q=…&sort=… (so the URL can be bookmarked)  
 → BindCourses:  
    WHERE c.Status='Published' AND (@subject=0 OR c.SubjectID=@subject) AND (@paid=-1 OR c.IsPaid=@paid) AND (… LIKE @search)  
    search wildcards % and _ are escaped, so they're treated as literal text  
    ORDER BY chosen from a FIXED list in C# (title / popular / newest), never from the request  
    OFFSET @skip ROWS FETCH NEXT … (paging)  
 → cards rendered, with an empty-state message if nothing matches  
   
**6.4 Learner clicks ** **Enrol for free** ** / ** **Buy with eSewa**  
1  UI           CourseDetails.aspx → btnEnrol ("Enrol for free" or "Buy with eSewa").  
                 Lecturers and admins don't see it: "Lecturer and administrator accounts cannot enrol"  
 2  Handler      Enrol() → PaymentHelper.Enrol(courseID)  
 3  Transaction  SERIALIZABLE:  
                   learner Active and not forced to change password  
                   SELECT course WITH (UPDLOCK,HOLDLOCK) → must be Published, else NotFound  
                   Paid and no verified payment → return false  
                  else IF NOT EXISTS … INSERT Enrolment → commit  
 4a Free         → Learner/CourseHome.aspx "You are enrolled"  
 4b Paid         → Learner/Checkout.aspx → PaymentHelper.CreatePending:  
                   INSERT Payment (Status 'Pending', AmountNPR = price FROM THE DATABASE, unique TransactionUUID)  
                 → Payment/EsewaDemo.aspx: phone ^9[78][0-9]{8}$, code = last 4 digits of the phone  
                 → PaymentHelper.CompleteDemo, ONE transaction:  
                      lock Course → lock Payment → UPDATE Payment SET Status='Complete', VerifiedDate, ProviderReference  
                      → INSERT Enrolment → COMMIT  
                   3 wrong codes → 'Failed'; Cancel → 'Canceled'  
 5  Visible      Receipt on EsewaSuccess, and the course is open  
   
**6.5 Learner opens a ** **lesson** ** and clicks ** **Mark complete**  
Member/Lesson.aspx?id=… → Page_Load:  
    material missing or Draft → NotFound  
    AccessHelper.CanAccessMaterial: enrolled + Active learner + published material + published course? else AccessDenied  
    LessonFormatter / MaterialHelper renders by type:  
       Text → encoded paragraphs · Image → <img alt> · PDF → link via Media.ashx?download=1  
       Video → <video> + <track> captions (Media.ashx) · Audio → <audio> · YouTube → embed  
       Code → <textarea> + Run/Reset + <iframe sandbox="allow-scripts allow-modals">  
    Previous/Next links from ProgressHelper.PublishedItems (same order as CourseHome)  
 MarkComplete → learner only → INSERT MaterialCompletion (PK LearnerID+MaterialID stops duplicates) → redirect  
 → progress % and streak update automatically (both are calculated)  
   
**6.6 Learner ** **starts and submits a quiz**  
1  Open    Member/Quiz.aspx?id=… → QuizHelper.Begin:  
              access (enrolled, or owner in preview) · quiz valid · attempts left (MaxAttempts, 0 = unlimited)  
              Session["QuizStart_{id}"] = now · one-time SubmissionToken · SHA-256 fingerprint of the questions  
 2  Render  radio buttons name="q_{QuestionID}" value="{OptionID}" · IsCorrect is NEVER in the HTML  
 3  Browser quiz.js: "3 of 10 answered", progress bar, countdown, auto-submit at 0, warns about unanswered  
 4  Submit  SubmitQuiz → QuizHelper.SubmitRun (SERIALIZABLE):  
              token matches? · within time limit + 30 s grace? · fingerprint unchanged? · attempts left?  
              each submitted option belongs to its question, no duplicates  
              score = earned marks / total marks × 100 (server)  
              INSERT Attempt + INSERT QuizAnswer per question (unanswered = NULL) → COMMIT → consume token  
 5  Result  Redirect → QuizResult.aspx?id={AttemptID} → score ring + full answer review  
   
**No Attempt row exists until Submit.** Closing the tab saves nothing.  
**6.7 Learner ** **finishes a game**  
1  PlayGame.aspx → GameHelper.Begin: server records the start time + fingerprint.  
    GameHelper.ClientData → JSON items (FillBlank answers blanked, Sequence positions hidden)  
 2  games.js draws the template and gives instant feedback  
 3  Finish → hidden field hfResult = {"timeTakenSeconds":83,"moves":14,"answers":[{"itemId":12,"value":"…"}]}  
    NO SCORE is ever sent  
 4  Submit → GameHelper.ParseResult (strict fields, rejects duplicate keys, max lengths)  
    → GameHelper.Submit: reload items from the DB → Score() → time = server's Elapsed(run) → INSERT Attempt → commit  
   
**6.8 Learner ** **plays a branching scenario**  
Scenario.aspx → ScenarioHelper.Begin: run stored in Session (StartStepID, a token, a revision, a fingerprint)  
 Each choice → ScenarioHelper.Move:  
    token and revision must match (stops the back button / double-click replaying an old step)  
    the choice must start FROM the current step  
    next step = SimChoice.NextStepID  
    if the next step IsEnding → needs a valid Outcome (Best/Acceptable/Poor) + feedback  
        → INSERT Attempt (EndingStepID, ScorePercent NULL) → commit  
 Only after the commit is the session's current step updated  
   
**6.9 Learner ** **submits a self-assessment**  
SelfAssessment.aspx: rate each statement 1–5  
 → SelfAssessmentHelper.Submit (SERIALIZABLE): access check · statements unchanged · every statement rated exactly once · 1–5  
 → average → Level: <2.5 "Needs Improvement", <4 "Developing", else "Confident" + feedback text  
 → INSERT Attempt (ScorePercent NULL) + INSERT SAResponse per statement → commit  
   
**6.10 Learner ** **posts in a discussion**  
Discussion.aspx → DiscussionHelper.Save → text 2–2000 chars  
 → ActivityAccessHelper.DiscussionPermission: closed discussion = no writing; enrolled learners and the course owner can write;  
    the admin and the course owner can moderate (delete)  
 → a reply's parent must be a top-level post in the same discussion (one reply level)  
 → INSERT DiscussionPost (ParentPostID NULL = top level) → commit → redirect  
   
**6.11 Lecturer ** **builds and publishes a course**  
Teacher/CourseEdit.aspx → create course (Draft) → Teacher/CourseBuilder.aspx?id=…  
    every action: AccessHelper.RequireOwner (TeacherID = me, or Admin) else AccessDenied  
    add Topic → add Material (MaterialEdit: UploadHelper.Save) or an Activity (Quiz/Game/SA/Scenario/Discussion builders)  
    Preview link (?preview=1): runs the activity exactly as a learner would, but saves NOTHING  
    edit-tokens stop a double click from creating two copies  
 Publish → PublishHelper.CheckCourse: at least one topic has a published lesson/activity, else an error  
 Edit a quiz with attempts → ContentLockHelper: "Content is locked after attempts. Title and description remain editable."  
   
**6.12 Admin ** **approves a lecturer**  
Admin/TeacherApplications.aspx → gvApplications lists Role='Teacher' AND Status='Pending'  
 Approve → UPDATE [User] SET Status='Active'   WHERE UserID=@id AND Role='Teacher' AND Status='Pending'  
 Reject  → UPDATE [User] SET Status='Rejected' WHERE … (same guard)  
 The "AND Status='Pending'" guard means two admins/tabs can't double-process it  
 → SetSuccess → Redirect. The admin dashboard badge count goes down  
   
**6.13 Admin ** **Subjects CRUD** ** (the slide 17 example)**  
READ    Page_Load → RequireRole(Admin) → BindSubjects:  
         SELECT s.…, COUNT(c.CourseID) AS CourseCount FROM Subject s LEFT JOIN Course c … GROUP BY … → gvSubjects  
 EDIT    row Edit → RowCommand "EditSubject" → fill txtName/txtDescription, hfSubjectID = id, button "Save changes"  
 SAVE    btnSave_Click → if (!Page.IsValid) return; → id==0 ? INSERT : UPDATE (parameters)  
         CustomValidator: name unique · DB UNIQUE(SubjectName) as the backstop → SetSuccess → Redirect  
 DELETE  RowCommand "DeleteSubject" (button + confirm, never a link) → SERIALIZABLE transaction  
         → DeleteHelper.CheckSubject: blocked if any course uses it → DELETE → commit  
   
**6.14 Admin ** **manages a user**  
Admin/Users.aspx: search/filter → Activate / Deactivate (never yourself, never another admin) · Unlock (FailedLoginCount=0) · Delete  
 Delete → DeleteHelper.DeleteUser, ONE transaction, children first:  
    QuizAnswer → SAResponse → Attempt → replies → posts → MaterialCompletion → Bookmark → Enrolment → Review → User  
    blocked if a lecturer still owns courses  
 UserEdit.aspx → change details · set a temporary password → MustChangePassword=1  
   
**6.15 Learner opens the ** **certificate**  
Learner/Certificate.aspx?courseId=… → course Published? · enrolled? · ProgressHelper.CalculatePercent == 100?  
    else AccessDenied → prints with Styles/print.css  
   
**6.16 Any user hits a ** **wrong URL / wrong role / error**  
/xyz.aspx (missing)        → 404 → NotFound.aspx (Server.TransferRequest keeps the typed URL; not logged)  
 Learner opens /Admin/…     → Global.asax CheckUrlAccessForPrincipal fails → AccessDenied.aspx  
 Logged out opens /Learner/ → Forms Auth → Account/Login.aspx?ReturnUrl=…  
 Exception in code          → Application_Error → App_Data/ErrorLog.txt (time, URL, stack) → Error.aspx  
 Database down              → SqlException caught → "…unavailable, try again later" or Error.aspx  
   
![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAnEAAAACCAYAAAA3pIp+AAAABmJLR0QA/wD/AP+gvaeTAAAACXBIWXMAAA7EAAAOxAGVKw4bAAAANUlEQVR4nO3OMQ2AABAAsSNhwgJmkPYLLpnRgQU2QtIq6DIze3UGAMBf3Gu1VcfHEQAA3rseaHkEMn1wK7sAAAAASUVORK5CYII=)  
**PART 6.5: DEMO RUN PLAN (THE MARKING SCHEME REQUIRES IT)**  
The marking scheme's Presentation bands 7–8, 9–11 and 12–15 all say **"Able to execute the application."** Practise this on the  **exact laptop** you'll present from.  
**Setup (the day before)**  
1. sqllocaldb info MSSQLLocalDB. If it's missing: sqllocaldb create MSSQLLocalDB -s  
2. **Attach the database.** This is the most common failure. Web.config uses Initial Catalog=LearningSystemFinal, which  **does not** auto-attach the .mdf. Run this in the project folder:  
3. sqlcmd -S "(LocalDB)\MSSQLLocalDB" -E -Q "CREATE DATABASE [LearningSystemFinal] ON (FILENAME='%CD%\App_Data\LearningSystemFinal.mdf'), (FILENAME='%CD%\App_Data\LearningSystemFinal_log.ldf') FOR ATTACH;"  
   
4.   
 If that fails, use README Option C (Database\CreateFinalDatabase.ps1).  
5. Open LearningSystem.slnx → Rebuild → F5 → https://localhost:44393/ → trust the dev certificate.  
6. Log in once with every role.  
**Demo accounts (password **Password123 ** for all)**  
| | | |  
|-|-|-|  
| **Role** | **Email** | **Use it to show** |   
| Admin | admin@inkwell.test | Dashboard badges, approve Ravi, Subjects CRUD, Users, Payments, Analytics |   
| Lecturer | asha.sharma@inkwell.test | Course builder, quiz builder lock, preview, Results charts |   
| Learner | anita.karki@inkwell.test | Dashboard, streak, results, certificate |   
| Learner | ben.lee@inkwell.test | Buying a paid course (owns none) |   
| Pending lecturer | ravi.thapa@inkwell.test | "Application still being reviewed" |   
   
eSewa demo: ID 9841234567, code 4567. Paid courses: JavaScript Basics NPR 499, Personal Finance NPR 299, Statistics NPR 399.  
**6-minute demo script (one person drives, one narrates)**  
1. **Visitor:** Home → Courses → filter subject → course details → free preview.  
2. **Validation:** Register with an empty form → summary and field errors.  
3. **Portal check:** Ben on the *Lecturer* login → "cannot use this portal".  
4. **Learner:** Ben → buy a paid course → eSewa demo → enrolled → open a lesson → Mark complete → take the quiz → answer review → play a game.  
5. **Security:** As Ben, type /Admin/Dashboard.aspx → Access denied. Type /abc.aspx → custom 404.  
6. **Lecturer:** Asha → Course builder → open a quiz that has attempts → locked message → preview an item.  
7. **Admin:** approve Ravi → Subjects: add, edit, try to delete an in-use subject (blocked) → Analytics chart.  
⚠️ Don't fail logins five times on an account you'll need; it locks for 15 minutes. The admin can unlock it on Users.  
![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAnEAAAACCAYAAAA3pIp+AAAABmJLR0QA/wD/AP+gvaeTAAAACXBIWXMAAA7EAAAOxAGVKw4bAAAANklEQVR4nO3OQQmAABRAsScYxpg/h5VMYARvRrCCNxG2BFtmZquOAAD4i3Ot7mr/egIAwGvXA224BcUMk6pDAAAAAElFTkSuQmCC)  
**PART 7: FOLLOW-THE-DATA FLOWS**  
**7.1 A password**  
| | |  
|-|-|  
| **Step** | **Where** |   
| Created | txtPassword on Register / ChangePassword |   
| Validated | Browser + server regex (8–50 chars, a letter and a digit), Compare with the confirmation |   
| Transformed | 16-byte random salt + PBKDF2-SHA256 with 100,000 rounds → 32-byte hash |   
| Stored | User.PasswordHash = PBKDF2$100000$<salt>$<hash> (NVARCHAR 200) |   
| Retrieved | AccountSecurityHelper.CheckLogin |   
| Compared | VerifyPassword recomputes with the stored salt; constant-time byte comparison |   
| Displayed | Never |   
| Invalid | Validator message / generic login error / lockout after 5 |   
   
**7.2 A user's status**  
Register → Active or Pending → TeacherApplications → Active / Rejected → Users → Active ⇄ Deactivated. It's checked at login (CheckLogin) **and** on protected pages (CurrentUserHelper.IsActive in RequireRole). A user deactivated mid-session is signed out on their next protected page.  
**7.3 A course**  
Created Draft (CourseEdit) → content added → PublishHelper.CheckCourse → Published → visible in Courses.aspx (only Status='Published') → enrolments → can be unpublished. It can't be deleted once it has attempts or payments. Drafts requested by learners → NotFound.  
**7.4 A quiz score**  
| | |  
|-|-|  
| **Step** | **Where** |   
| Created | Server, QuizHelper.SubmitRun. Never in the browser |   
| Input | Selected OptionIDs from q_{QuestionID} radio buttons |   
| Validated | Options belong to the question; token, time and fingerprint OK; attempts left |   
| Stored | Attempt.ScorePercent (CHECK 0–100), Attempt.TimeTakenSeconds, QuizAnswer rows |   
| Read | QuizResult, Learner/MyResults, Teacher/Results (charts), the dashboard average (EngagementHelper.AverageBestScore = average of the best score per quiz/game) |   
| Invalid | Exception → message → transaction not committed → nothing saved |   
   
**7.5 Course progress %**  
- **Never stored.**ProgressHelper.CalculatePercent = done items ÷ published items × 100.  
- **Done** means:  
  - a lesson has a MaterialCompletion row  
  - a quiz, game, self-assessment or scenario has any Attempt  
  - a discussion has a post by the learner  
- The same query (PublishedItems) drives the progress bar, the CourseHome ticks and certificate eligibility, so they can never disagree.  
**7.6 Learning streak**  
EngagementHelper.ActiveDays = the distinct dates of completions, attempts and posts. Streak counts back consecutive days from today (yesterday still counts if nothing is done today yet). It's calculated, never stored.  
**7.7 An uploaded file**  
| | |  
|-|-|  
| **Step** | **Where** |   
| Created | File input on Teacher/MaterialEdit / course cover / scenario step |   
| Validated | UploadHelper.Validate: **extension + size** (Image JPG/PNG/GIF ≤ 2 MB, PDF ≤ 10 MB, MP3 ≤ 10 MB, MP4 ≤ 25 MB). maxRequestLength 30 MB in Web.config |   
| Renamed | ~/Uploads/{Images|Documents|Video|Audio}/{new GUID}.{ext} |   
| Stored | Disk + path in Material.FilePath / Course.CoverImagePath / SimStep.ImagePath |   
| Served | Only via Media.ashx?materialId=… after access checks. The Uploads folder is a hidden segment and its own web.config blocks script execution |   
| Deleted | DeleteHelper: DB rows in a transaction, then the file (path re-validated, can't escape the Uploads folder) |   
   
**7.8 A payment**  
Pending (DB price, unique TransactionUUID) → Complete + VerifiedDate + ProviderReference (e.g. ESW-261007-AB12CD34 (98XXXXXX67), phone masked) **plus an Enrolment, in one transaction**. Failed/Canceled payments stay as history. The admin sees all of them in Admin/Payments, the learner sees their own in Learner/MyPayments.  
**7.9 A page view (analytics)**  
Site.Master.cs → on a first GET → AnalyticsHelper.RecordView(path, role) → INSERT PageView(PagePath, ViewerRole). No user ID, IP or cookie. Roughly 1 in 200 views deletes rows older than 12 months. If it fails, the error is swallowed so a page never breaks. Admin/Analytics shows daily views, top pages and views by role on <canvas> charts.  
![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAnEAAAACCAYAAAA3pIp+AAAABmJLR0QA/wD/AP+gvaeTAAAACXBIWXMAAA7EAAAOxAGVKw4bAAAANUlEQVR4nO3OMQ2AABAAsSNhwgJmkPYLLpnRgQU2QtIq6DIze3UGAMBf3Gu1VcfHEQAA3rseaHkEMn1wK7sAAAAASUVORK5CYII=)  
**PART 8: CRITICAL CODE (THE 20% THAT EXPLAINS 80%)**  
| | | | | |  
|-|-|-|-|-|  
| **#** | **File** | **Purpose** | **In → Out** | **Called by** |   
| 1 | Web.config | Connection string, Forms Auth, **folder rules**, custom errors, limits, headers | config | ASP.NET |   
| 2 | Global.asax.cs | HTTPS, attach role, forced password change, wrong-role → AccessDenied, error log | request → continue/redirect | ASP.NET, every request |   
| 3 | Site.Master(.cs) | Layout, per-role nav, breadcrumb, messages, analytics, ViewStateUserKey | none | every page |   
| 4 | DatabaseHelper.cs | The only DB entry point; parameters always | SQL + params → DataTable/scalar/count | everything |   
| 5 | AccountSecurityHelper.cs | Login checks, lockout | email+pwd → UserID/0 + message | PortalLoginHelper |   
| 6 | AuthenticationHelper.cs | SignIn, SignOut, AttachRole | UserID → cookie, session | login pages, Global.asax |   
| 7 | PasswordHelper.cs | Hash, verify | password ↔ hash | register, login, admin reset |   
| 8 | AccessHelper.cs | RequireRole, IsEnrolled, Owns, CanAccessMaterial | user + id → bool/redirect | almost all protected pages |   
| 9 | QuizHelper.cs | Begin, submit, mark, review | answers → Attempt | Member/Quiz |   
| 10 | GameHelper.cs | Parse JSON, score 8 templates | JSON → score + Attempt | Member/PlayGame |   
| 11 | ProgressHelper.cs | The one definition of "done" | learner+course → % | dashboards, CourseHome, Certificate |   
| 12 | PaymentHelper.cs | Enrol, pending payment, demo verify | course → enrolment/payment | CourseDetails, Checkout, EsewaDemo |   
| 13 | DeleteHelper.cs | Safe ordered deletes, blocked deletes | id → ValidationResult | Admin/Teacher pages |   
| 14 | UploadHelper.cs + Media.ashx.cs | Safe uploads and serving | file ↔ GUID path | builders, lessons |   
| 15 | Database/CreateDatabase.sql | Schema, constraints, seed data, final checks | none | run once |   
   
**Explain them verbally (say these out loud until they sound natural)**  
**DatabaseHelper:**  
*"Every database call goes through one class. It reads the * *LearningSystemDb* * connection string from Web.config, opens a SqlConnection, adds the parameters to a SqlCommand, and* * runs it. There are two versions of each method: one opens its own connection, and one reuses a connection and transaction, so several statements can be committed together. Because input always goes in as parameters, SQL injection can't happen through it."*  
INPUT  SQL with @placeholders + SqlParameter[]  →  PROCESS open, command, add params, execute  →  OUTPUT DataTable | scalar | rows changed  
   
**Global.asax:**  
*"These are application-wide events. BeginRequest forces HTTPS. PostAuthenticateRequest takes the role from the login ticket and attaches it to the user, so Web.config's folder rules work. If the admin has r* *eset your password, it forces you to the change-password page. If you're logged in but in the wrong folder, it sends you to Access Denied instead of looping back to login. Application_Error writes the real error to a private log and shows a friendly page."*  
**AccessHelper:**  
*"Folder rules only know your role. AccessHelper answers the finer question: is this * *specific* * course yours, or are you enrolled in it? For example, * *Owns* * joins Course to User and checks * *TeacherID = me* *. Without that, a lecturer could change the ID in the URL and edit someone else's course."*  
**ProgressHelper:**  
*"One SQL query lists every published lesson and activity in the course with a Done flag. The percentage is done divided by total. Every page uses this same method, so the numbers always agree, and nothing goes stale because nothing is stored."*  
**PaymentHelper.CompleteDemo:**  
*"It checks the demo code, then opens * *one serializable transaction. It locks the course, then the payment row, marks the payment Complete with a verified date and reference, inserts the enrolment, and commits. If anything fails, both changes roll back, so you can't pay without being enrolled."*  
![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAnEAAAACCAYAAAA3pIp+AAAABmJLR0QA/wD/AP+gvaeTAAAACXBIWXMAAA7EAAAOxAGVKw4bAAAANklEQVR4nO3OQQmAABRAsScYxpg/h5VMYARvRrCCNxG2BFtmZquOAAD4i3Ot7mr/egIAwGvXA224BcUMk6pDAAAAAElFTkSuQmCC)  
**PART 9: DEVELOPMENT STORY**  
| | | |  
|-|-|-|  
| **Activity** | **Evidence** | **Label** |   
| Problem + objectives | Report §1.1–1.2 | 🟢 documented |   
| Proposal (title, mission, audience, scope) | Report Appendix A | 🟢 documented |   
| WSDM audience model + task model | Report §2.1, Tables 3–4, Figure 1 | 🟢 documented |   
| Use cases, flowcharts | Figures 2–5, Table 5 | 🟢 documented |   
| ERD, wireframes, navigation | Figures 6–12 | 🟢 documented |   
| Shared naming "contract" before coding | Report §6.2; consistent names across all helpers | 🟡 inferred |   
| Built in phases with verification steps | Code comments, structure; the original repo had phase docs | 🟡 inferred |   
| Admin can author courses (added later) | Consistent "AuthorRoles" design; git message | 🟡 |   
| UI redesign late in the project (pastel sidebar shell) | git message (Sunil) | 🟡 (seen in the main repo) |   
| 14-week schedule, M1–M4 split | Report Table 2 only | 🔴 plan, not proven history |   
| Automated browser tests (114 links, 23 flows) | Report §4.8 only; no scripts in Submission | 🔴 |   
| 0 build errors/warnings | Report only | 🟡 rebuild to confirm |   
| DB integrity checks | CreateDatabase.sql end | 🟢 |   
   
⚠️ **Honest note.** Before you told me to use only Submission, I briefly saw the git history of the main LearningSystem folder. It has  **16 commits on 1–2 October 2026**, by  **Ujwal Chhetri** (4, including the first bulk *"Add project files"*) and **Sunil Kandel** (12). It has none from Aashish or Rupesh. That folder also contains an AGENTS.md file of rules for an AI coding assistant.  
   
 **Implications:**  
- Call the schedule the **planned** schedule.  
- Don't claim weekly commits.  
- Prepare the "What did you do?" and "Did you use AI?" answers (Parts 19 and 21).  
- Git history only shows who committed, not who designed or wrote documentation. Aashish's and Rupesh's work may simply not be in git.  
![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAnEAAAACCAYAAAA3pIp+AAAABmJLR0QA/wD/AP+gvaeTAAAACXBIWXMAAA7EAAAOxAGVKw4bAAAANUlEQVR4nO3OQQmAABRAsSd4NIGRTPXNaQBrWMGbCFuCLTOzV2cAAPzFvVZbdXw9AQDgtesBhZQEOYZGgUEAAAAASUVORK5CYII=)  
**PART 10: SLIDE-BY-SLIDE (ALL 25 SLIDES)**  
*Template for each slide: * ***Says*** * → * ***Say this*** * → * ***Not explained on the slide*** * → * ***Technical knowledge*** * → * ***Questions (answer + follow-up)*** * → * ***Demonstrate*** * → * ***Anchor***  
![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAnEAAAACCAYAAAA3pIp+AAAABmJLR0QA/wD/AP+gvaeTAAAACXBIWXMAAA7EAAAOxAGVKw4bAAAANklEQVR4nO3OQQmAABRAsSfYxZo/kSGMYQLPJrCCNxG2BFtmZquOAAD4i3Ot7mr/egIAwGvXA4qrBdGuSdJuAAAAAElFTkSuQmCC)  
**Slide 1: Inkwell (title) · Ujwal**  
- **Says:** Inkwell, *"A web-based learning system where every topic ends with practice that the server marks"*, the team, the instructor, two screenshots (home page and learner dashboard).  
- **Say this:** "Good morning. We're presenting Inkwell, a web-based learning system. The idea in one line: visitors find courses, learners study and practise, lecturers build content, and the admin runs the platform, and every topic ends with practice that the server marks. The screenshots are the real running application."  
- **Not explained:** what "the server marks" means. That's the key promise; slides 9 and 19 back it up.  
- **Questions:**  
  - *"Why the name Inkwell?"* → 🔴 not documented. Say  *"It's a learning and writing metaphor; we wanted a friendly, memorable brand"* only if your team agrees.  
  - *"Is it hosted online?"* →  *"No, it runs locally on IIS Express with LocalDB. Hosting is future work."*  
- **Anchor:***Find → Study → Practise → Marked*  
![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAnEAAAACCAYAAAA3pIp+AAAABmJLR0QA/wD/AP+gvaeTAAAACXBIWXMAAA7EAAAOxAGVKw4bAAAALUlEQVR4nO3OQQ0AIAwEsAMlSJ0UrOFkGngRklZBR1WtJDsAAPzizNcDAADuNcKwAyU+nb+5AAAAAElFTkSuQmCC)  
**Slide 2: What we will cover (agenda) · Rupesh**  
- **Says:** 6 sections matching the 6 report chapters, with presenters.  
- **Say this:** "We follow the same six chapters as the report, so you can match the slides to the document."  
- **Not explained:** the workload split, which comes from the proposal (Appendix C).  
- ⚠️ Fix the slide 7–10 presenter mismatch (Part 0).  
- **Question:***"Why that split?"* →  *"It follows our proposal's workload allocation: Ujwal integration and database, Sunil design and front end, Aashish materials and interactive modules, Rupesh admin and documentation."*  
![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAnEAAAACCAYAAAA3pIp+AAAABmJLR0QA/wD/AP+gvaeTAAAACXBIWXMAAA7EAAAOxAGVKw4bAAAANUlEQVR4nO3OMQ2AABAAsSNhwgJe0PYTKpnRgQU2QtIq6DIze3UGAMBf3Gu1VcfXEwAAXrseaIEEMYtKmi4AAAAASUVORK5CYII=)  
**Slide 3: The problem Inkwell solves · Rupesh**  
- **Says:** Free resources explain but don't test; students learn in short sessions on phones; lecturers aren't web experts. Answer: practice after every topic. Stats: 61 pages, 25 tables, 8 game templates, 37 helpers.  
- **Say this:** "We noticed that free resources explain a topic but never check whether you understood it. Our learners are 17 to 21, mostly on phones, studying between classes. Lecturers know their subjects but not web tools. So Inkwell puts an activity at the end of every topic, the server marks it, and it goes into your progress."  
- **Not explained:** how the problem shapes the design.  
  - Phone users → responsive layout, sidebar becomes a row at ≤ 960 px.  
  - Short sessions → short lessons, a "continue learning" card, streaks.  
  - Lecturers → form builders, preview, content lock.  
- **Technical knowledge:** All four numbers are 🟢 correct (Part 2).  
- **Questions:**  
  - *"How do you know students have this problem? Did you survey them?"* → 🔴 There's no survey evidence.  *"It came from our own experience as foundation students. We didn't run a formal survey; that would be a good validation step."*  
  - *"How does Inkwell prove learners understood?"* →  *"It doesn't prove learning in general. It gives marked practice and feedback per topic. We avoided claiming improved exam results."* (The proposal says this explicitly.)  
- **Anchor:***Explain-only → Practise-and-mark*  
![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAnEAAAACCAYAAAA3pIp+AAAABmJLR0QA/wD/AP+gvaeTAAAACXBIWXMAAA7EAAAOxAGVKw4bAAAANUlEQVR4nO3OMQ2AABAAsSNBCUrfDqrYGVDAgAU2QtIq6DIzW7UHAMBfHGt1V+fXEwAAXrseHCQGBEuErVgAAAAASUVORK5CYII=)  
**Slide 4: Six objectives · Rupesh**  
- **Says:** Open catalogue · marked practice (≥ 5 activity types) · lecturer self-service · admin control · security from the start · usable on any screen (WCAG 2.2 AA).  
- **Say this:** "Four functional objectives: a public catalogue with previews, five kinds of marked activity, lecturers managing their own content, and full admin control. Two quality objectives: security built in, and accessibility on any screen."  
- **Not explained → evidence for each:**  
   
 | Objective | Evidence |  
   
 |---|---|  
   
 | Catalogue | Courses.aspx filter/search/sort/paging; Preview.aspx |  
   
 | Marked practice | QuizHelper, GameHelper (scored). Note: scenarios and self-assessments are **recorded but not scored** |  
   
 | Lecturer self-service | Teacher/ builders, preview, publish, delete |  
   
 | Admin control | Admin/ 11 pages |  
   
 | Security | PBKDF2, parameters, folder rules, ownership (Part 17) |  
   
 | Any screen | @media rules; 🟡 WCAG AA is claimed, with contrast notes in CSS comments, but no audit report in the submission |  
- **Questions:**  
  - *"'Results are stored and marked on the server' for all five types?"* →  *"All five are stored. Quizzes and games get a score. Scenarios record which ending you reached, self-assessments record confidence ratings, and discussions record posts. Those three aren't percentages on purpose."*  
  - *"What is WCAG 2.2 AA?"* →  *"Web Content Accessibility Guidelines, level AA. For example, normal text needs at least a 4.5:1 contrast ratio. We checked our text colours and used visible 3 px focus outlines."* Follow-up  *"Which tool?"* → 🔴 if unknown:  *"I didn't run that check personally."*  
- **Anchor:***Find · Practise · Build · Manage · Secure · Accessible*  
![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAnEAAAACCAYAAAA3pIp+AAAABmJLR0QA/wD/AP+gvaeTAAAACXBIWXMAAA7EAAAOxAGVKw4bAAAAMUlEQVR4nO3WAQkAIBAEsBPMYs4PZhMDWMAA5njYUmxU1UqyAwBAF2cmeZE4AIBO7gentgXapSWpbgAAAABJRU5ErkJggg==)  
**Slide 5: Scope · Rupesh**  
- **Says:** In scope (public pages, registration and 3 portals with lockout, course/topic/lesson management with 7 media types, 5 activity types, results/progress/streak/certificates/reviews/bookmarks, admin tools). Out of scope: live classes and chat, email, native app, AI tutor, real payments, multiplayer.  
- **Say this:** "This shows we controlled the scope. Most importantly, payment is an offline eSewa-style demo. No real money moves."  
- **Not explained:**  
  - "Three portals" = StudentLogin, TeacherLogin, AdminLogin. Login.aspx is only a chooser.  
  - "Lock after five failed log-ins" = **15 minutes**, not permanent.  
  - Why no email: no mail server in a local demo, so admin password reset gives a temporary password and forces a change.  
- **Questions:**  
  - *"Why not real payments?"* →  *"Real eSewa needs a merchant account, a public HTTPS callback URL and internet. Our demo runs offline. The flow (pending → verify → complete + enrol in one transaction) mirrors a real gateway, so integrating it later mainly replaces the verify step."*  
  - *"How do users reset a forgotten password without email?"* →  *"The admin sets a temporary password on UserEdit, and the user must change it at their next login (MustChangePassword)."*  
  - *"Why no real-time chat?"* →  *"It needs WebSockets/SignalR and a server push model. Discussions are asynchronous posts, which fit short study sessions."*  
- **Anchor:***Build the core well; defer the risky extras*  
![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAnEAAAACCAYAAAA3pIp+AAAABmJLR0QA/wD/AP+gvaeTAAAACXBIWXMAAA7EAAAOxAGVKw4bAAAANUlEQVR4nO3OMQ2AABAAsSNhwgJWEPcbJpnRgQU2QtIq6DIze3UGAMBf3Gu1VcfXEwAAXrseaIkEMIPgIvAAAAAASUVORK5CYII=)  
**Slide 6: 14-week schedule · Rupesh**  
- **Says:** A Gantt-style table. Weeks 1–7 shared (requirements, proposal, ERD, wireframes, DB script). Weeks 7–10, M1–M4 each own a module. Weeks 10–14 shared (results, payments, testing, report).  
- **Say this:** "This is our planned schedule from the report. The proposal was due in Week 7. Then each member took a module, and the last weeks were joint integration and testing."  
- **Not explained / risk:** 🔴 The report doesn't say who M1–M4 are, and git history doesn't show a 14-week timeline (Part 9).  **Always call it the *****planned***** schedule.**  
- **Questions:**  
  - *"Did you stick to it?"* →  *"Broadly for the phases. The final integration and redesign work was concentrated near the end, which is when most of our commits happened."* (Honest, and consistent with git.)  
  - *"Who is M1?"* → Agree as a team; the slide notes say M1 public/accounts/admin, M2 courses/lessons/enrolment, M3 quiz/SA/discussion, M4 games/scenarios/preview.  
  - *"What methodology did you use?"* → 🟡  *"An incremental, phase-by-phase approach: requirements and design first, then building feature modules on a shared database and helper contract, then integration and testing."* Don't say "Agile/Scrum with sprints" unless you really did it.  
- **Anchor:***Plan together → Build apart → Integrate together*  
![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAnEAAAACCAYAAAA3pIp+AAAABmJLR0QA/wD/AP+gvaeTAAAACXBIWXMAAA7EAAAOxAGVKw4bAAAANUlEQVR4nO3OMQ2AABAAsSNBCkLfE07YGfHAiAU2QtIq6DIzW7UHAMBfnGt1V8fXEwAAXrse4eQF6VhvmPsAAAAASUVORK5CYII=)  
**Slide 7: Audience modelling with WSDM · Sunil**  
- **Says:** WSDM starts from people, not data (De Troyer & Leune, 1998). Visitor → Registered member → Learner / Lecturer / Administrator, with characteristics and needs.  
- **Say this:** "We modelled our users with WSDM, the Web Site Design Method. Its idea is to start from *who* uses the site and what they need, not from the database. Everyone starts as a Visitor. Signing in makes you a Registered member, which splits into Learner, Lecturer and Administrator. Learners are young phone users studying in short bursts, so they need short lessons and instant feedback. Lecturers know their subject but not web tools, so they need simple builders and must be approved first. The admin account only comes from the database script, so nobody can register as an admin."  
- **Not explained → how it appears in the code** 🟢  
  - Classes → User.Role CHECK ('Learner','Teacher','Admin'). "Lecturer" on the slides = Teacher in the code.  
  - Visitor = not logged in. Web.config<deny users="?"/> on Member/.  
  - One folder per class (Learner/, Teacher/, Admin/), one portal per class, one dashboard per class (CurrentUserHelper.GetDashboardUrl), sidebar built per role in Site.Master.cs.  
  - Admin can't register: ValidateRegistration only allows Learner/Teacher. The script inserts exactly one admin (admin@inkwell.test) and checks it (THROW 51002).  
  - Lecturer approval: insert with Status='Pending'; CheckLogin refuses with *"still being reviewed"*; the admin approves on TeacherApplications.  
  - Task model (Table 4) → the page list. E.g. Learner tasks (enrol, study, practise, progress, certificate) → Dashboard, CourseHome, Lesson, activity pages, MyResults, Certificate.  
- **Questions:**  
   
 | Q | Answer | Follow-up |  
   
 |---|---|---|  
   
 | Why WSDM instead of starting from the ERD? | Different users need very different pages. Starting from users means nobody wades through tools meant for others. | "Then how did you get to the ERD?" → From the tasks we listed the information each needs, which became entities. |  
   
 | Audience class vs role? | A class is a design concept (a group with the same needs). In the code it becomes User.Role in the login ticket. | |  
   
 | Is Visitor in the database? | No. Only in analytics, where anonymous views are labelled "Visitor". | |  
   
 | Can someone be both a learner and a lecturer? | One account has one role (CHECK). They'd need a second account; emails are UNIQUE. | |  
   
 | What does WSDM stand for and who made it? | Web Site Design Method, De Troyer & Leune, 1998. | Its phases: mission statement → audience modelling → conceptual design → implementation design. |  
- **Demonstrate:** log in as ravi.thapa@inkwell.test → pending message.  
- **Anchor:***People → Needs → Tasks → Pages → Roles in code*  
![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAnEAAAACCAYAAAA3pIp+AAAABmJLR0QA/wD/AP+gvaeTAAAACXBIWXMAAA7EAAAOxAGVKw4bAAAANUlEQVR4nO3OQQmAABRAsSfYxKK/kJXEkyE8WcGbCFuCLTOzVXsAAPzFsVZ3dX4cAQDgvesB/vEF9H9odtUAAAAASUVORK5CYII=)  
**Slide 8: Use cases · Sunil**  
- **Says:** Figure 2, 4 actors. The Learner inherits Visitor; the Admin inherits the Lecturer's course building. Key use cases: Enrol, Attempt a quiz, Build a course, Approve a lecturer.  
- **Say this:** "Four actors: Visitor, Learner, Lecturer and Admin. A Learner can do everything a Visitor can, and the Admin inherits the Lecturer's course-building, so the admin uses the same builder screens. Enrol is the interesting one: free courses enrol straight away, while paid courses go through checkout and our demo eSewa screen, and the payment and enrolment are saved together."  
- **Not explained → how inheritance is real** 🟢  
  - Admin ⊇ Lecturer: <location path="Teacher"><allow roles="Teacher,Admin"/>; CurrentUserHelper.AuthorRoles; the admin authors 4 demo courses.  
  - Ownership still applies: AccessHelper.Owns → c.TeacherID=@user. A lecturer edits only their own courses. The admin can delete any content (DeleteHelper.IsAdmin).  
  - "Attempts remain" → Activity.MaxAttempts (0–10, 0 = unlimited), checked at Begin **and** Submit.  
  - "Start time in session" → Session["QuizStart_{id}"].  
  - "Saved together" → PaymentHelper.CompleteDemo, one transaction.  
- **Questions:**  
   
 | Q | Answer | Follow-up |  
   
 |---|---|---|  
   
 | Include vs extend? | Include = always part of another use case. Extend = optional under a condition. | Paid checkout *extends* Enrol. |  
   
 | What stops double enrolment? | Composite PK (LearnerID, CourseID) + IF NOT EXISTS in a serializable transaction. | |  
   
 | Why one transaction for payment + enrolment? | So you never pay without access or get access without paying. That's atomicity. | ACID = Atomicity, Consistency, Isolation, Durability. |  
   
 | Can lecturers enrol? | No: RequireRole(Learner) in PaymentHelper and a message on CourseDetails. | |  
   
 | What if the quiz time runs out? | quiz.js auto-submits; the server rejects anything later than the limit + 30 s. | The server trusts its own clock. |  
- **Anchor:***Actor → Inherits → Precondition → Flow → Saved*  
![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAnEAAAACCAYAAAA3pIp+AAAABmJLR0QA/wD/AP+gvaeTAAAACXBIWXMAAA7EAAAOxAGVKw4bAAAANklEQVR4nO3OMQ2AABAAsSPBCj7fFRYQwYwEZiywEZJWQZeZ2ao9AAD+4lyruzq+ngAA8Nr1AMTJBeJDClAyAAAAAElFTkSuQmCC)  
**Slide 9: Three processes carry the most rules · Aashish (per notes)**  
- **Says:** Log-in and role check; Enrolment and demo payment; Quiz attempt and marking ("The browser never receives the correct answers").  
- **Say this:** "Three processes have the most rules, so we drew flowcharts. Log-in runs a chain of checks before a ticket is issued, and a wrong password always gets a generic error. Enrolment: free is immediate, and paid is recorded only after the server verifies the payment. Quiz: nothing is saved until submit, the server marks each answer, and the correct answers never reach the browser."  
- **Not explained:**  
  - The **code's login order**: lockout → hash → portal → status (Part 6.2). A wrong-portal attempt with the right password is  **not** counted as a failure.  
  - **Why a generic error:** "Email not found" vs "wrong password" would let attackers discover which emails are registered (user enumeration).  
  - **Quiz:**IsCorrect is only used server-side. QuizHelper.Questions "stays on the server"; the renderer outputs only option text and IDs.  
- **Questions:**  
  - *"Why check the lockout before the password?"* →  *"So a locked account can't keep guessing, even with the right password."*  
  - *"How does the server know which answer is correct?"* →  *"* *QuizOption.IsCorrect* * in the database. The script guarantees exactly one correct option per question (THROW 51007)."*  
  - *"Is the same true for games?"* → ⚠️  *"No. Games need item data in the browser to give instant feedback, so some answers are visible in the page. But the score is still recalculated on the server."* (Part 13.)  
- **Demonstrate:** a quiz → View Source → no correct markers.  
- **Anchor:***Login = Lock, Hash, Portal, Status · Pay = Verify then Enrol · Quiz = Submit then Mark*  
![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAnEAAAACCAYAAAA3pIp+AAAABmJLR0QA/wD/AP+gvaeTAAAACXBIWXMAAA7EAAAOxAGVKw4bAAAANUlEQVR4nO3OQQ2AQBAAsSHhiQI0IWp9ngBsYIEfIWkVdJuZs5oAAPiLe6+O6vp6AgDAa+sBhYwEOqBD7p8AAAAASUVORK5CYII=)  
**Slide 10: Every item in the brief is met · Rupesh (Sunil backup)**  
- **Says:** Table 6, mapping each brief requirement to where it's met. 10/10, 61 pages, 139 validators.  
- **Say this:** "Each row is a requirement from the brief and where Inkwell meets it."  
- **Where to point for each row** 🟢:  
   
 | Brief requirement | Show |  
   
 |---|---|  
   
 | Interlinked pages | Header nav, role sidebar, breadcrumb, footer, SiteMap.aspx, lesson prev/next |  
   
 | HTML5 elements | Site.Master header/nav/main/footer; <video> + <track> on Home; <audio>; <progress> (quiz); <details>; <canvas> charts; <article>/<aside>; typed inputs Email/Number/Search/Url/Password |  
   
 | External/internal/inline CSS | Styles/site.css / <style> in Site.Master / style="…" on Default.aspx |  
   
 | Good-quality content | 19 courses across 8 subjects in the seed data |  
   
 | CRUD | Subjects page (Part 6.13); also courses, topics, lessons, activities, users, FAQs, reviews, posts, bookmarks |  
   
 | Registration page | Account/Register.aspx |  
   
 | Member module | Learner/, Member/, Teacher/ (requires login) |  
   
 | Admin module | Admin/ (11 pages) |  
   
 | Form validation | 161 validator controls + server checks |  
   
 | Navigation | Role menus, breadcrumbs, search, keyboard shortcuts, 404/403 |  
   
 | File organisation | One folder per role, Helpers/, PascalCase pages, control prefixes txt/ddl/btn/gv |  
- ⚠️ **"139 validators"** → the code has  **161**. Fix the slide, or say "over 130".  
- **Questions:**  
  - *"Count says 10 of 10, but the brief has 11 items?"* →  *"We grouped registration, member and admin modules into one row; the report lists them separately."*  
  - *"Did you use a template?"* → 🟢  *"No CSS framework or template. Our own design tokens in site.css."* (The brief allows templates, so either answer is fine.)  
- **Anchor:***Pages · HTML5 · CSS×3 · CRUD · Register · Member · Admin · Validate · Navigate · Organise*  
![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAnEAAAACCAYAAAA3pIp+AAAABmJLR0QA/wD/AP+gvaeTAAAACXBIWXMAAA7EAAAOxAGVKw4bAAAANUlEQVR4nO3OMQ2AABAAsSNhZscVjnidKEAGFtgISaugy8zs1RkAAH9xr9VWHV9PAAB47XoAor8EPg1yCpUAAAAASUVORK5CYII=)  
**Slide 11: Database design, content chain · Ujwal**  
- **Says:** 25 tables in 3NF. Chain Subject → Course → Topic → Material / Activity. Each activity type has its own tables. Pricing on Course. Cascade deletes only follow this chain.  
- **Say this:** "Read Figure 6 left to right: a Subject has many Courses, a Course has many Topics, and a Topic holds Materials (the lessons) and Activities. Each activity type has its own content tables: questions and options for quizzes, items and groups for games, steps and choices for scenarios. Each course is free or paid. Cascade deletes only follow this chain."  
- **Not explained → technical knowledge** 🟢  
  - **The 8 cascading FKs:** Course→Topic, Topic→Material, Topic→Activity, Activity→QuizQuestion, QuizQuestion→QuizOption, Activity→SAStatement, Activity→GameGroup, Activity→GameItem.  
  - **Not cascading:**Subject→Course (so deleting a subject is blocked), SimStep/SimChoice, and GameItem→GameGroup.  **Why?** SQL Server refuses "multiple cascade paths" and cycles: Activity.StartStepID → SimStep and SimStep.ActivityID → Activity form a cycle, and GameItem can be reached from Activity both directly and through GameGroup. So those are deleted in C# (DeleteHelper) in the right order.  
  - **One Activity table with a type column** (ActivityType) plus type-specific child tables. CHECK constraints keep the type-specific columns consistent: e.g. only Quiz has TimeLimitMinutes/MaxAttempts, only Game has GameTemplate, only Discussion has IsClosed, only Scenario has StartStepID.  
  - **Pricing:**CK_Course_Price ((IsPaid=0 AND PriceNPR=0) OR (IsPaid=1 AND PriceNPR>0)).  
  - **Material** has one row per lesson with MaterialType and matching CHECKs (Text/Code need TextContent; Image/PDF/Video/Audio need FilePath; Image needs AltText; YouTube needs a URL).  
- **Questions:**  
   
 | Q | Answer | Follow-up |  
   
 |---|---|---|  
   
 | What's 3NF? | Every non-key column depends on the key, the whole key and nothing but the key. | Example: SubjectName lives only in Subject, not repeated per course. |  
   
 | Why one Activity table, not five? | Shared fields (title, topic, order, status) and one place to attach Attempts. Type-specific data goes in child tables. | Trade-off: some nullable type-specific columns, controlled by CHECKs. |  
   
 | Why not cascade everything? | SQL Server disallows cycles and multiple cascade paths, and we don't want learner history disappearing silently. | |  
   
 | What's a foreign key? | A column that must match a primary key in another table. Prevents orphan rows. | 37 FKs in our script. |  
   
 | Indexes? | 31, e.g. IX_Payment_CourseID, IX_PageView_ViewedAt. They speed up common lookups. | Trade-off: slightly slower writes. |  
- **Anchor:***Subject → Course → Topic → (Material | Activity → its content)*  
![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAnEAAAACCAYAAAA3pIp+AAAABmJLR0QA/wD/AP+gvaeTAAAACXBIWXMAAA7EAAAOxAGVKw4bAAAANUlEQVR4nO3OMQ2AABAAsSNhZscVjnidKEAGFtgISaugy8zs1RkAAH9xr9VWHV9PAAB47XoAor8EPg1yCpUAAAAASUVORK5CYII=)  
**Slide 12: Users, learning records and design choices · Ujwal**  
- **Says:** Figure 7. Answers hang off the attempt. Composite keys, safe cascade deletes in C#, CHECK constraints, progress calculated.  
- **Say this:** "A user can own courses as a lecturer, or have enrolments, attempts, reviews, bookmarks and payments as a learner. Each attempt belongs to one activity and one learner, and quiz and self-assessment answers hang off the attempt, so history survives retakes. Four decisions: composite keys stop duplicates, deletes outside the content chain are done in C# inside a transaction, CHECK constraints allow only valid values, and progress is calculated, never stored."  
- **Not explained** 🟢  
  - Composite PKs: Enrolment(LearnerID,CourseID), Bookmark(LearnerID,MaterialID), MaterialCompletion(LearnerID,MaterialID), QuizAnswer(AttemptID,QuestionID), SAResponse(AttemptID,StatementID). Plus UNIQUE(LearnerID,CourseID) on Review (one review per course).  
  - Discussion replies: ParentPostID → DiscussionPost (self-reference); CHECK (ParentPostID <> PostID).  
  - Attempt shape rules (THROW 51010): Scenario attempts need EndingStepID; Quiz/Game need ScorePercent; SA/Scenario must NOT have a score.  
  - Delete order example (DeleteHelper.DeleteUser): QuizAnswer → SAResponse → Attempt → replies → posts → completions → bookmarks → enrolments → reviews → user, all in one transaction.  
  - User also stores FailedLoginCount, LockedUntil, MustChangePassword, ApplicationReason (20–500 chars, CHECK).  
  - Payment: Provider='eSewa' CHECK, Status IN (Pending, Complete, Failed, Canceled), unique TransactionUUID.  
- **Questions:**  
   
 | Q | Answer |  
   
 |---|---|  
   
 | Why keep every attempt instead of overwriting? | History and fairness: lecturers see all attempts, and the dashboard uses the *best* score per activity. |  
   
 | Composite key vs surrogate ID? | The pair itself is the identity (a learner + a course), so the PK prevents duplicates without extra code. |  
   
 | Why delete in C# rather than cascade? | Deleting learner records is a big decision. Doing it explicitly, children first, in one transaction, means nothing disappears by accident, and we can block it (e.g. attempts exist → "Unpublish instead"). |  
   
 | What's a CHECK constraint? | A rule the database enforces on every insert/update, e.g. Rating BETWEEN 1 AND 5. It's the last guard, even if the C# has a bug. |  
   
 | Isn't calculating progress slow? | One query per course; fine at our scale. At scale we'd cache it. |  
- **Anchor:***Composite keys · C# deletes in transactions · CHECKs · Calculated progress*  
![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAnEAAAACCAYAAAA3pIp+AAAABmJLR0QA/wD/AP+gvaeTAAAACXBIWXMAAA7EAAAOxAGVKw4bAAAANklEQVR4nO3OMQ2AABAAsSNBACMC0cD8NpGACyywEZJWQZeZ2aszAAD+4l6rrTq+ngAA8Nr1AL+yBEpU09MiAAAAAElFTkSuQmCC)  
**Slide 13: Wireframes · Aashish**  
- **Says:** 4 low-fidelity wireframes: Home, Dashboard, Lesson page, Lecturer form.  
- **Say this:** "Before coding, we drew wireframes to fix the layout, so the four of us built pages that look and behave the same. Public pages use a top navigation bar; signed-in users get a left sidebar. On lessons, the sidebar shrinks to icons to give content more width."  
- **Not explained → how it's built** 🟢: Site.Master has  **both** a header nav and a workspace sidebar (<nav class="workspace-nav">), shown by role. The responsive rule @media (max-width: 960px) turns the sidebar into a horizontal scrolling row. The lesson page's outline is generated from ProgressHelper.PublishedItems.  
- **Questions:**  
  - *"Low vs high fidelity?"* →  *"Low fidelity = boxes and labels for layout and flow; high fidelity = real colours, fonts and images. Low-fi is fast to change, so it's ideal before coding."*  
  - *"What tool?"* → 🔴 not documented. Don't guess.  
  - *"Do the final screens match?"* →  *"Closely, as the user guide screenshots show. The visual style was refined later with the pastel redesign."*  
- **Anchor:***Top bar for public · Sidebar for members · Icons on lessons · Same layout everywhere*  
![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAnEAAAACCAYAAAA3pIp+AAAABmJLR0QA/wD/AP+gvaeTAAAACXBIWXMAAA7EAAAOxAGVKw4bAAAANUlEQVR4nO3OMQ2AABAAsSNBCUrfDqrYGVDAgAU2QtIq6DIzW7UHAMBfHGt1V+fXEwAAXrseHCQGBEuErVgAAAAASUVORK5CYII=)  
**Slide 14: Navigation and interface principles · Aashish**  
- **Says:** Hierarchical overall, linear inside lessons and scenarios, networked across areas. Nielsen's heuristics. WCAG AA, 3 px focus, tested at 390/820/1366 px.  
- **Say this:** "Overall the site is hierarchical: Home, Course, Topic, Item. Inside lessons and scenarios it's linear, with previous and next. Across areas it's networked, with dashboard shortcuts and links from results back to activities. The interface follows Nielsen's heuristics: you always see where you are, every save is confirmed, every delete asks first, and the layout never changes."  
- **Not explained → evidence for each heuristic** 🟢:  
   
 | Heuristic | In Inkwell |  
   
 |---|---|  
   
 | Visibility of system status | Breadcrumb (BreadcrumbHelper), aria-current="page" sidebar highlight, progress bars, quiz "3 of 10 answered", success/error message box (aria-live="polite") |  
   
 | Error prevention | Delete confirmations, content lock, blocked deletes, unanswered-question warning |  
   
 | Consistency | One master page, same layout everywhere |  
   
 | User control and freedom | Cancel button on every form, Reset in the code lab, Unpublish instead of delete |  
   
 | Help users recover from errors | Plain-language validator messages, friendly 404/403 |  
   
 | Recognition rather than recall | Icons + labels in the sidebar, keyboard-shortcut help |  
- **Questions:**  
  - *"Name three of Nielsen's heuristics and show them."* → use the table.  
  - *"What is a breadcrumb for?"* →  *"Shows your position in the hierarchy and lets you jump back up."*  
  - *"Why 3 px focus outlines?"* →  *"So keyboard users can see which element is focused. That's a WCAG requirement."*  
  - *"Why 390, 820, 1366?"* →  *"Typical phone, tablet and laptop widths."*  
- **Anchor:***Hierarchical · Linear · Networked + "Where am I? Did it save? Are you sure?"*  
![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAnEAAAACCAYAAAA3pIp+AAAABmJLR0QA/wD/AP+gvaeTAAAACXBIWXMAAA7EAAAOxAGVKw4bAAAANUlEQVR4nO3OMQ2AABAAsSPBCj7fFjsymJHAjAU2QtIq6DIzW7UHAMBfnGt1V8fXEwAAXrsexNkF4H1/HJoAAAAASUVORK5CYII=)  
**Slide 15: Technology and file organisation · Aashish**  
- **Says:** Web Forms on .NET 4.8 with Site.Master; C# + ADO.NET with helpers; SQL Server LocalDB built by CreateDatabase.sql; HTML5/CSS/JS, no framework; one folder per role. Naming: PascalCase, prefixes txt/ddl/btn/gv.  
- **Say this:** "Our stack is ASP.NET Web Forms, C#, ADO.NET, SQL Server LocalDB, and plain HTML5, CSS and JavaScript. There's one folder per role, so access rules can be applied to whole folders, and a Helpers folder holds the 37 shared classes."  
- **Not explained:**  
  - **Why folder-per-role matters for security:**Web.config<location path="Admin"> protects the whole folder in one rule. Any new admin page is automatically protected.  
  - **Naming prefixes:**txt TextBox, ddl DropDownList, btn Button, gv GridView, hf HiddenField, lbl Label, rfv/rev/cv validators.  
  - Small correction: the final DB LearningSystemFinal is attached from App_Data or built by CreateFinalDatabase.ps1, which wraps CreateDatabase.sql.  
  - Uploads/ files are served only through Media.ashx, never directly.  
- **Questions:** see Part 4 (why Web Forms, why ADO.NET, why LocalDB, why no framework).  
- **Anchor:***Web Forms · C# · ADO.NET · LocalDB · plain front end · folder per role*  
![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAnEAAAACCAYAAAA3pIp+AAAABmJLR0QA/wD/AP+gvaeTAAAACXBIWXMAAA7EAAAOxAGVKw4bAAAANElEQVR4nO3OQQmAUBBAwSfIb+HdmNvAkgaxgjcRZhLMNjNHdQUAwF/ce7Wq8+sJAACvrQctewNKtdojwQAAAABJRU5ErkJggg==)  
**Slide 16: Front end: CSS, HTML5 and validation · Sunil**  
- **Says:** 3 CSS types; semantic HTML5; two-layer validation; 139 validators; code snippets; Figure 13; registration rules.  
- **Say this:** "We used all three CSS types. The external Styles/site.css holds the whole design, with design tokens like --ink and --primary as CSS variables, so changing one value restyles the site. Site.Master has a small internal style block, and pages have commented inline styles. The master page gives every page a semantic frame: header, nav, main, footer. Lessons use native video with captions, plus progress, details and canvas. Validation has two layers: validators check in the browser for speed, and every save handler starts with if (!Page.IsValid) return;, which re-runs them on the server, because the browser can be bypassed."  
- **Not explained** 🟢:  
  - **Cascade/specificity:** inline > IDs > classes > elements; later rules win ties. That's why inline is kept minimal.  
  - **Design tokens** = CSS custom properties :root { --primary: #5a3fc0; }, used with var(--primary).  
  - **Responsive** via @media (max-width: 960px). A print stylesheet for certificates. Local fonts. Cache-busting asset URLs (UiHelper.AssetUrl).  
  - **Validator breakdown:** 76 RequiredField, 49 RegularExpression, 16 Range, 16 Custom, 4 Compare =  **161**. 39 ValidationSummary controls.  
  - **Regex**^(?=.*[A-Za-z])(?=.*[0-9]).{8,50}$: lookahead "contains a letter", lookahead "contains a digit", total length 8–50.  
  - **Three layers really:** browser → server → database (CHECK/UNIQUE).  
  - **CustomValidator** for things only the server knows (email uniqueness, CAPTCHA).  
  - **XSS:** output is encoded (<%: %>, Mode="Encode"), and validateRequest="true".  
- **Questions:**  
   
 | Q | Answer | Follow-up |  
   
 |---|---|---|  
   
 | Why both client and server validation? | Client = speed, server = security. | JS can be disabled or requests forged; Page.IsValid re-checks. |  
   
 | Show server validation. | Register.aspx.cs → btnRegister_Click → first line. | ValidateRegistration checks the DB. |  
   
 | Internal vs inline? | <style> block vs style="" attribute. | Inline is highest specificity and not reusable. |  
   
 | What's a lookahead? | Checks a pattern exists without consuming characters. | |  
   
 | Why semantic tags over divs? | Screen readers and search engines understand the structure. | nav aria-label="Breadcrumb". |  
   
 | Two people register the same email at once? | UNIQUE constraint rejects the second; caught as SqlException 2601/2627. | |  
- **Demonstrate:** empty Register → Figure 13 live.  
- **Anchor:***CSS: Out-In-Line · HTML5: Header-Nav-Main-Footer + Media · Validation: Browser fast → Server safe → DB last*  
![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAnEAAAACCAYAAAA3pIp+AAAABmJLR0QA/wD/AP+gvaeTAAAACXBIWXMAAA7EAAAOxAGVKw4bAAAANUlEQVR4nO3OQQmAABRAsSd40A5GMORPYEt7WMGbCFuCLTNzVFcAAPzFvVZbdX49AQDgtf0BSrIDUgOg4eAAAAAASUVORK5CYII=)  
**Slide 17: Database connectivity and CRUD · Ujwal**  
- **Says:** One helper opens every connection; SQL always uses parameters (blocks SQL injection, OWASP); the Subjects page shows all 4 operations; delete in a transaction, blocked while in use; 12 integrity checks.  
- **Say this:** "All SQL goes through DatabaseHelper. It reads the connection string from Web.config and always takes parameters, so user input is never joined into SQL text. That blocks SQL injection. Our CRUD example is the admin Subjects page: reading joins subjects with how many courses use each; create and update share one form; delete runs in a serializable transaction and is blocked if any course still uses the subject."  
- **Not explained** 🟢:  
  - Connection string: Data Source=(LocalDB)\MSSQLLocalDB;Initial Catalog=LearningSystemFinal;Integrated Security=True (Windows login, so no password in the file).  
  - **using** ** blocks** close connections automatically, even on errors, which prevents connection leaks. Connection pooling reuses them.  
  - **LEFT JOIN** (not INNER) so subjects with zero courses still appear, with CourseCount 0.  
  - **Why SERIALIZABLE for delete:** between "check no course uses it" and "delete", another admin could add a course with that subject. Serializable locks the range so that can't happen.  
  - **Fixed SQL fragments:**AccessHelper.Owns and DeleteHelper concatenate *fixed* strings chosen by C# (never user input). The ID is still a parameter.  
  - Sort in Courses.aspx: ORDER BY is chosen from a fixed list, because column names can't be parameters.  
  - **SqlException numbers** 2601/2627 = unique/PK violation → a friendly duplicate message.  
- **Questions:** see Part 12 Tree B (SQL injection) and Tree G (concurrency).  
  - *"What does ExecuteScalar vs ExecuteNonQuery vs ExecuteTable return?"* →  *"First column of the first row / number of rows affected / a full DataTable."*  
  - *"Why not SqlDataSource controls?"* →  *"Writing SQL in C# gives us parameters, transactions and permission checks in one place."*  
- **Demonstrate:** Subjects page CRUD + blocked delete.  
- **Anchor:***One helper · Always parameters · Read with LEFT JOIN · Save = INSERT or UPDATE · Delete = check + transaction*  
![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAnEAAAACCAYAAAA3pIp+AAAABmJLR0QA/wD/AP+gvaeTAAAACXBIWXMAAA7EAAAOxAGVKw4bAAAANUlEQVR4nO3OYQ1AABSAwY8JoIGqr4Z6Eoiggn9mu0twy8wc1RkAAH9xbdVa7V9PAAB47X4A9C4EIsmYmgsAAAAASUVORK5CYII=)  
**Slide 18: Authentication and authorisation in layers · Ujwal**  
- **Says:** 5 steps: hash (PBKDF2, SHA-256, 100k) → ticket (encrypted, role, 30 min) → Global.asax attaches the role → Web.config folder rules → ownership checks. Also: lock after 5, separate portals, Access denied page, HttpOnly cookie.  
- **Say this:** "Security is layered. Passwords are stored as salted PBKDF2 hashes. After login, Forms Authentication issues an encrypted ticket carrying the role, valid for 30 minutes, in an HttpOnly cookie. Global.asax attaches the role to every request, Web.config folder rules allow or deny whole areas, and pages that take an ID check ownership or enrolment. Hiding a link isn't security; these layers close the gaps."  
- **Not explained** 🟢:  
  - **Salt:** random bytes per user, so identical passwords produce different hashes and precomputed rainbow tables don't work.  
  - **Why slow hashing:** 100,000 iterations makes each guess expensive for an attacker who steals the DB.  
  - **Constant-time comparison** in VerifyPassword: compares every byte, so response timing doesn't leak how much matched.  
  - **Ticket vs session:** the ticket (cookie) proves identity and role, while the session holds server-side data. SignIn clears the session first (prevents session fixation leftovers).  
  - **Cookie flags:** HttpOnly (JS can't read it, which limits XSS theft), Secure (HTTPS only), SameSite=Lax (limits CSRF).  
  - slidingExpiration="true": 30 minutes of *inactivity*.  
  - **IDOR** = changing ?id=5 to access someone else's data. Stopped by AccessHelper checks.  
  - IsActive() on every RequireRole: a deactivated user is signed out at their next protected page.  
  - Lockout: 5 → **15 minutes**; UPDLOCK prevents parallel attempts losing count.  
  - Forced password change after an admin reset (MustChangePassword, Global.asax).  
- **Questions:** see Part 12 Tree C.  
  - *"Authentication vs authorisation?"* →  *"Who you are vs what you may do."*  
  - *"What if someone edits the cookie to say Admin?"* →  *"The ticket is encrypted and signed with the machine key. A modified cookie fails decryption and is ignored."*  
  - *"Why separate login portals?"* →  *"Clearer for users and an extra check: a learner account can't sign in through the admin page, even with the right password."*  
- **Anchor:***Hash → Ticket → Role → Folder → Owner*  
![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAnEAAAACCAYAAAA3pIp+AAAABmJLR0QA/wD/AP+gvaeTAAAACXBIWXMAAA7EAAAOxAGVKw4bAAAAM0lEQVR4nO3OMQ0AIAwAwdIgBKl1gjacsGCAiZDcTT9+q6oRETMAAPjF6ify6QYAADdyA9Y0AypN+bdfAAAAAElFTkSuQmCC)  
**Slide 19: The server never trusts the browser · Aashish**  
- **Says:** Scores recalculated on the server; uploads type/size checked with GUID names; payment + enrolment in one transaction; fixed history (content lock). Also ProgressHelper, PRG, private error log.  
- **Say this:** "Anything from the browser can be changed, so the server does the important work. A game posts only the learner's answers; the server reloads the correct items and recalculates. Uploads are checked on the server and renamed with GUIDs. Payment and enrolment happen in one transaction. And once an activity has attempts, its questions lock, so old scores stay meaningful."  
- **Not explained** 🟢:  
  - **GUID names:** prevent overwriting, guessing other files' URLs, and dangerous original filenames.  
  - **Upload limits:** Image 2 MB (JPG/PNG/GIF), PDF 10 MB, MP3 10 MB, MP4 25 MB.  
  - ⚠️ The check is **extension + size**, not file contents.  
  - **PRG:** after a POST, redirect → GET, so refresh doesn't resubmit.  
  - **Price from the DB:** the browser never sends a price.  
  - **Time from the server:** game and quiz time is measured from the server-side start.  
  - ⚠️ **Exceptions to "never trusts":** game item data is in the page (for instant feedback); Memory's move count comes from the browser; Flashcards are self-rated (Part 13).  
- **Questions:**  
  - *"Can I see game answers in the page source?"* →  *"For some games, yes, because they give instant feedback. What we never trust is the score: the server recalculates it from the database. Quizzes never send answers."*  
  - *"Can I upload a .exe renamed to .png?"* →  *"It'd be accepted as an 'image' because we check the extension, but it's stored with a GUID name, never executed (the Uploads web.config blocks handlers), and served as image/png with * *nosniff* *. Checking magic bytes would be the improvement."*  
  - *"Why lock content after attempts?"* →  *"Changing a question after learners answered would make their stored scores meaningless."*  
- **Anchor:***Scores, Uploads, Payments, History: the server decides*  
![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAnEAAAACCAYAAAA3pIp+AAAABmJLR0QA/wD/AP+gvaeTAAAACXBIWXMAAA7EAAAOxAGVKw4bAAAANUlEQVR4nO3OQQmAABRAsSeYxKS/kJkED6bwYAVvImwJtszMVu0BAPAXx1rd1fn1BACA164HHDwF+DpPyKwAAAAASUVORK5CYII=)  
**Slide 20: Testing, errors and small screens · Sunil**  
- **Says:** 0 build errors/warnings · 12 integrity checks · 114 links crawled · 23 E2E flows · phone/tablet/desktop with no JS errors · custom 404, 403, phone screenshots.  
- **Say this:** "We tested at three levels. The build compiles with no errors or warnings. The database script ends with twelve checks that stop the build if the data is wrong, for example every quiz question must have exactly one correct option, and every paid enrolment needs a completed payment. And we tested the running site across every role and screen size. We also planned for failure: a missing page shows our 404, a wrong role shows Access Denied, and technical details go to a private log."  
- **What is proven:**  
   
 | Claim | Status | Show |  
   
 |---|---|---|  
   
 | 0 errors/warnings | 🟡 | Rebuild tonight → Error List 0/0 |  
   
 | 12 checks | 🟢 | End of CreateDatabase.sql. Several check **demo-data coverage** (1 admin, 19 courses, all 8 game types); the true integrity ones are quiz options, answers belong to their quiz, attempt shape, posts only by enrolled learners, paid enrolment has payment |  
   
 | 114 links / 23 flows | 🔴 | Not in the submission. Know who ran them and with what tool, or don't elaborate |  
   
 | Phone/tablet/desktop | 🟡 | Live: DevTools device toolbar at 390 px |  
   
 | 404 / 403 / private log | 🟢 | Web.config customErrors + httpErrors; Global.asax |  
- **Not explained:**  
  - 401 vs 403 (Global.asax converts "logged in but 401" into Access Denied).  
  - Drafts and others' media return **404, not 403**, so you can't even confirm they exist.  
  - 404s aren't logged.  
  - DB down → friendly message (fail closed).  
- **Manual tests you can run tonight and honestly claim:** Part 16.  
- **Questions:**  
  - *"Unit tests?"* →  *"No unit test project. We relied on DB checks, browser tests and manual role testing. Unit tests for the scoring and progress helpers would be next."*  
  - *"Which tool for the browser tests?"* → 🔴 If unknown:  *"I didn't run that suite myself, so I won't guess. What I tested personally was…"*  
  - *"What's the difference between validation and testing?"* →  *"Validation checks user input at runtime; testing checks our code works before release."*  
- **Anchor:***Build → Data → Browser → Fail-safe*  
![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAnEAAAACCAYAAAA3pIp+AAAABmJLR0QA/wD/AP+gvaeTAAAACXBIWXMAAA7EAAAOxAGVKw4bAAAANUlEQVR4nO3OMQ2AUBBAsUeCE4yeIiT9CRVMWGAjJK2CbjNzVGcAAPzF2qu7Wl9PAAB47XoA/vcF8exqpY4AAAAASUVORK5CYII=)  
**Slide 21: Visitors · Aashish**  
- **Says:** Home (search, subjects, newest, captioned tour video), catalogue (filter subject/keyword/price, sort), course details (outline, practise list, lecturer, enrol card, free previews), one registration form, separate portals.  
- **Say this:** "A visitor lands on the home page, searches or browses by subject, filters the catalogue, opens a course to see the outline and lecturer, and can try free preview lessons without registering. Joining takes one form."  
- **Not explained** 🟢:  
  - Search escapes %/_; ORDER BY comes from a fixed list; paging with OFFSET/FETCH.  
  - Previews require Material.IsPreview=1 + published + course published.  
  - The video has a <track kind="captions">.vtt file (accessibility).  
  - Contact has a CAPTCHA.  
  - sitemap.xml is generated for search engines.  
- **Questions:**  
  - *"Can a visitor see a draft course?"* →  *"No. Every public query filters * *Status='Published'* *; direct URLs to drafts return NotFound."*  
  - *"How is search protected from injection?"* →  *"The keyword is a parameter with LIKE; the sort column is chosen from a fixed list."*  
- **Demonstrate:** Home → Courses → filter → details → preview.  
- **Anchor:***Discover → Judge → Try → Join*  
![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAnEAAAACCAYAAAA3pIp+AAAABmJLR0QA/wD/AP+gvaeTAAAACXBIWXMAAA7EAAAOxAGVKw4bAAAANUlEQVR4nO3OMQ2AABAAsSNhZscZXlheJwqQgQU2QtIq6DIze3UGAMBf3Gu1VcfXEwAAXrseop8EQrmJduIAAAAASUVORK5CYII=)  
**Slide 22: Learners · Aashish**  
- **Says:** Enrol → Study (outline beside content, code labs in an isolated frame) → Practise (timed quizzes, 8 games, scenarios, self-assessments, discussions) → Track (streak, items, average, My results) → Finish (printable certificate).  
- **Say this:** "This is the heart of Inkwell. The dashboard shows streak, items completed and average score, with a continue-learning card. Lessons sit beside the outline. Code labs let you edit HTML and run it in an isolated frame. You practise with quizzes, games, scenarios, self-assessments and discussions, and when every item is done, a printable certificate unlocks."  
- **Not explained** 🟢:  
  - **Code lab:**<iframe sandbox="allow-scripts allow-modals"> + srcdoc. No allow-same-origin, so learner code runs in a unique origin and  **can't read Inkwell cookies or the page**.  
  - **Streak:** consecutive days with a completion, attempt or post; calculated.  
  - **Average score:** average of the  **best** score per quiz/game.  
  - **Certificate:** only if CalculatePercent == 100.  
  - Self-assessment ratings are never turned into a score.  
  - Bookmarks (Bookmark PK) and reviews (one per course, enrolled only).  
- **Questions:**  
  - *"Is the code lab dangerous? Could a learner run malicious JS?"* →  *"It runs only in their own browser, inside a sandboxed frame without same-origin access, so it can't touch our cookies or page. Nothing they type is executed on our server."*  
  - *"What counts as 'done' for progress?"* → Part 7.5.  
  - *"What happens if a lecturer adds a lesson after I got 100%?"* →  *"Progress is recalculated, so you'd drop below 100% until you complete it. That's the honest result of calculated progress."*  
- **Anchor:***Enrol → Study → Practise → Track → Finish*  
![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAnEAAAACCAYAAAA3pIp+AAAABmJLR0QA/wD/AP+gvaeTAAAACXBIWXMAAA7EAAAOxAGVKw4bAAAANUlEQVR4nO3OYQ1AABSAwY8JoIGqr4Z6Eoiggn9mu0twy8wc1RkAAH9xbdVa7V9PAAB47X4A9C4EIsmYmgsAAAAASUVORK5CYII=)  
**Slide 23: Lecturers (Aashish) and administrators (Rupesh)**  
- **Says:** Lecturers: builder (topics → lessons/activities), preview with nothing saved, quiz content locks after attempts, results with charts. Admins: dashboard counts and badges, approve/reject, manage users/subjects/FAQs/messages/payments, analytics with no personal data.  
- **Say this (lecturer half):** "Lecturers manage everything from the course builder. Each topic has buttons to add a lesson or one of the five activity types, every item can be previewed exactly as a learner sees it without saving anything, and once learners attempt a quiz, its content locks."  
- **Say this (admin half):** "The admin dashboard shows live counts and badges for waiting work, like pending applications and unread messages. From the sidebar the admin manages users, subjects, FAQs, messages and payments. Analytics come from recorded page views, storing only the page, the viewer's role and the time."  
- **Not explained** 🟢:  
  - Preview uses separate session keys (QuizPreview_, GamePreview_) and skips every INSERT.  
  - Ownership checks on every builder action; edit tokens stop double-creates.  
  - Publish rule (≥ 1 published item).  
  - Admin user actions: activate/deactivate (not self, not other admins), unlock, delete (ordered transaction; blocked if the lecturer owns courses), temporary password → forced change.  
  - Approve/Reject UPDATE … WHERE Status='Pending' (safe against double processing).  
  - Charts drawn on <canvas> by Scripts/charts.js.  
  - Analytics cleanup of rows older than 12 months.  
- **Questions:**  
  - *"Can a lecturer see another lecturer's results?"* →  *"No. Results pages check ownership through AccessHelper."*  
  - *"Can the admin delete a lecturer who has courses?"* →  *"No, it's blocked. Their courses must be reassigned or removed first."*  
  - *"Analytics without cookies, so how do you count unique visitors?"* →  *"We don't. We count page views by role only. That's a privacy choice."*  
  - *"Is that GDPR-compliant?"* →  *"We store no personal data in analytics, which is privacy-friendly, but we haven't done a formal compliance review."*  
- **Anchor:***Lecturer: Build → Preview → Publish → Lock → Results · Admin: Approve → Manage → Monitor*  
![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAnEAAAACCAYAAAA3pIp+AAAABmJLR0QA/wD/AP+gvaeTAAAACXBIWXMAAA7EAAAOxAGVKw4bAAAANElEQVR4nO3OQQmAABRAsSdYxKY/jbnMIJ7FCt5E2BJsmZmt2gMA4C+Otbqr8+sJAACvXQ85TgYRMv3/cwAAAABJRU5ErkJggg==)  
**Slide 24: Summary and lessons learned · Ujwal**  
- **Says:** Meets every brief requirement. Beyond the minimum: 8 games, code labs, scenarios, certificates, analytics, demo payment. Honest limits. 4 lessons.  
- **Say this:** "Inkwell meets every requirement in the brief, and goes beyond it with eight game types, code labs, branching scenarios, certificates, analytics and a demo payment flow. We're honest about the limits: payment is an offline demo. Our four lessons: agree exact names before coding; build security in from the start; mark on the server even though it's more work; and test on real phone widths early."  
- **Not explained:** "Progress is calculated, never stored" is listed under limits, but it's really a design  **choice**. Present it as one.  
- **Questions:**  
  - *"What was the hardest part?"* → each person should have their own answer (Part 19). Good team answer:  *"Keeping data consistent: transactions for payment, content locks, and safe deletes."*  
  - *"What would you do differently?"* →  *"Write unit tests for scoring early, and set up real hosting to test the payment gateway."*  
- **Anchor:***Met · Beyond · Honest · Learned*  
![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAnEAAAACCAYAAAA3pIp+AAAABmJLR0QA/wD/AP+gvaeTAAAACXBIWXMAAA7EAAAOxAGVKw4bAAAANUlEQVR4nO3OQQ2AQBAAsSHhiQI0IWp9ngBsYIEfIWkVdJuZs5oAAPiLe6+O6vp6AgDAa+sBhYwEOqBD7p8AAAAASUVORK5CYII=)  
**Slide 25: What comes next + Q&A · Ujwal, all**  
- **Says:** Notifications, real payments, badges and recommendations, dark theme and sounds. Thanks.  
- **Not explained → how each would be built:**  
   
 | Future item | How |  
   
 |---|---|  
   
 | Email / in-app notifications | SMTP via System.Net.Mail or a mail API; a Notification table for in-app |  
   
 | Real eSewa | eSewa's epay API: signed request, then verify the transaction status on the server before marking Complete. Needs public hosting with HTTPS |  
   
 | Badges / recommendations | A rules table on attempts and completions; recommend courses in the same subject or by popular enrolments |  
   
 | Dark theme | Already easy: redefine the CSS custom properties under prefers-color-scheme: dark |  
- **Anchor:***Notify · Pay for real · Reward · Theme*  
![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAnEAAAACCAYAAAA3pIp+AAAABmJLR0QA/wD/AP+gvaeTAAAACXBIWXMAAA7EAAAOxAGVKw4bAAAANUlEQVR4nO3OQQmAABRAsSfYxKK/kJXEkyE8WcGbCFuCLTOzVXsAAPzFsVZ3dX4cAQDgvesB/vEF9H9odtUAAAAASUVORK5CYII=)  
**PART 11: TEACHER'S EYE**  
**Where a teacher gets curious or suspicious:**  
1. **Size:** 61 pages, 37 helpers, 25 tables, 8 games by four students → expect *"show me / explain this function"*. Prepare DatabaseHelper.cs, Register.aspx.cs, Admin/Subjects.aspx.cs, PasswordHelper.cs. They're short and readable.  
2. **"Server never trusts the browser"** → *"Then why can I see game answers in View Source?"*  
3. **"139 validators"** → *"Did you count?"* (161)  
4. **"Locks after 5"** → *"Forever? Can I lock someone else out?"*  
5. **"Secure"** → *"Real payment? Hosted? Email verification?"* (No, no, no.)  
6. **"114 links / 23 flows"** → *"Show me the tests."*  
7. **"What did YOU do?"** → for every member.  
8. **Dense code** (QuizHelper, GameHelper.RejectDuplicateKeys, Media.ashx ranges) → *"Explain this line."*  
9. **AI** → *"Did you write this yourselves?"*  
| | |  
|-|-|  
| **Question type** | **Inkwell example** |   
| Likely | "How does a lecturer get approved?" |   
| Hidden | "Where is the role stored after login?" → encrypted ticket UserData, attached in Global.asax |   
| Challenge | "Why Web Forms in 2026?" |   
| Follow-up | "You said parameterised. Show me." |   
| Why didn't you | "...store progress?" "...use Entity Framework?" "...use Bootstrap?" "...integrate real eSewa?" "...write unit tests?" |   
| What happens if | "...two learners pay at once?" "...a lecturer deletes a completed lesson?" "...the DB goes down?" "...I change ?id= in the URL?" |   
| How do you know | "...hashing works?" → demo accounts log in with Password123 against stored PBKDF2 hashes |   
| Show me where | "...SQL injection is stopped" → DatabaseHelper.CreateCommand; "...admin folder is protected" → Web.config <location path="Admin"> |   
| What did YOU do | Part 19 |   
   
![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAnEAAAACCAYAAAA3pIp+AAAABmJLR0QA/wD/AP+gvaeTAAAACXBIWXMAAA7EAAAOxAGVKw4bAAAANklEQVR4nO3OQQmAABRAsSfYxZo/kC1sYQLPJrCCNxG2BFtmZquOAAD4i3Ot7mr/egIAwGvXA4qzBdC53Vr8AAAAAElFTkSuQmCC)  
**PART 12: VIVA QUESTION TREES**  
**Tree A: Validation**  
T: How do you validate forms?  
 S: ASP.NET validator controls check in the browser, and the same validators run again on the server.  
  └ T: Why both?  
    S: Browser for speed. Server for security, because the browser can be bypassed.  
     └ T: Show me the server check.  
       S: Every save handler starts with "if (!Page.IsValid) return;", e.g. btnRegister_Click.  
        └ T: What can a CustomValidator do that others can't?  
          S: Run our own C#, like checking the database for a duplicate email.  
           └ T: Two people register the same email at the same instant?  
             S: Both may pass the check, but UNIQUE(Email) rejects the second insert. We catch SqlException 2601/2627 and show "already registered".  
   
**Tree B: SQL injection**  
T: How do you prevent SQL injection?  
 S: All SQL uses parameters through DatabaseHelper.  
  └ T: What's a parameter?  
    S: A placeholder like @email whose value is sent separately, so it's always data, never code.  
     └ T: Give an attack it stops.  
       S: Typing  ' OR 1=1 --  as the email. With string joining it changes the WHERE clause; with @email SQL Server just looks for that literal text.  
        └ T: Is there ANY string concatenation in your SQL?  
          S: Yes, but only fixed fragments chosen in C#: a JOIN in AccessHelper.Owns, subqueries in DeleteHelper, and ORDER BY in Courses from a fixed list. Never user input. Values are still parameters.  
           └ T: Why can't ORDER BY be a parameter?  
             S: Parameters can only hold values, not column names or keywords, so we pick the ORDER BY from a whitelist.  
   
**Tree C: Authentication and authorisation**  
T: How does login work?  
 S: The password is checked against a PBKDF2 hash. If it's correct, Forms Authentication issues an encrypted cookie containing the role.  
  └ T: Why not MD5 or plain SHA-256?  
    S: They're fast, so attackers try billions per second. PBKDF2 with 100,000 rounds and a random salt makes each guess slow and defeats rainbow tables.  
     └ T: Authentication vs authorisation?  
       S: Who you are vs what you may do.  
        └ T: How is authorisation enforced?  
          S: Web.config folder rules, RequireRole at the top of pages, and ownership/enrolment checks for any ID in the URL.  
           └ T: Why the third layer?  
             S: Folder rules know you're a Teacher, not whether course 5 is YOURS. Without AccessHelper.Owns, changing ?id= would let you edit another lecturer's course. That's IDOR.  
              └ T: What if I edit the cookie to say Admin?  
                S: The ticket is encrypted and validated with the machine key. A tampered cookie fails to decrypt and is ignored.  
   
**Tree D: Database design**  
T: Why a relational database?  
 S: Our data is connected: subject → course → topic → lessons/activities; learners → enrolments, attempts.  
  └ T: Why not MongoDB?  
    S: We need joins, foreign keys and multi-row transactions (payment + enrolment). Relational databases do these natively.  
     └ T: What is 3NF? Give an example.  
       S: Every non-key column depends only on the key. SubjectName is stored once in Subject, not in every Course row.  
        └ T: Is anything denormalised?  
          S: No. We deliberately avoid it. Progress is calculated rather than stored, so it can't go stale.  
           └ T: Isn't that slow?  
             S: At our scale it's one query. At scale we'd cache it: a trade-off between freshness and speed.  
   
**Tree E: Why Web Forms?**  
T: Why ASP.NET Web Forms? It's old.  
 S: It's the module's technology and gives validators, master pages, GridView and Forms Auth built in, matching the brief.  
  └ T: What would you use for a real product?  
    S: ASP.NET Core MVC or Razor Pages: cross-platform, faster, actively maintained, more control of the HTML.  
     └ T: A downside you actually hit?  
       S: ViewState and the postback model hide HTTP. We had to use Post/Redirect/Get and one-time tokens to stop double submits.  
   
**Tree F: Server-side scoring**  
T: Why mark on the server?  
 S: The browser can be changed with DevTools. If it sent the score, anyone could send 100%.  
  └ T: What does a game send?  
    S: Only answers as JSON in the hidden field hfResult: item ID and value. The server reloads the correct items and recalculates.  
     └ T: Can I still cheat?  
       S: Quizzes: no, answers never leave the server. Games: item data is in the page for instant feedback, so a determined student could read it, and Memory's move count comes from the browser. Time is measured by the server.  
        └ T: How would you fix it?  
          S: Check each move on the server via AJAX instead of in JavaScript, at the cost of more requests and slower feedback.  
   
**Tree G: Transactions and concurrency**  
T: Two requests enrol the same learner at once?  
 S: Enrolment runs in a SERIALIZABLE transaction with IF NOT EXISTS, and the composite PK (LearnerID, CourseID) makes duplicates impossible.  
  └ T: What's SERIALIZABLE?  
    S: The strictest isolation level: transactions behave as if one after another, so nobody can slip in a matching row between our check and our insert.  
     └ T: Downside?  
       S: More locking means less concurrency. We use it only where correctness matters: payments, enrolment, submits, deletes.  
        └ T: What about two parallel wrong-password attempts?  
          S: The login SELECT uses UPDLOCK, so the second waits and sees the updated failure count. No lost updates.  
   
**Tree H: Payment**  
T: How does payment work?  
 S: It's an offline eSewa-style demo. A Pending payment is created with the price from the database, the learner enters a phone number and code, and the server marks it Complete and enrols them in one transaction.  
  └ T: So anyone can get a course free?  
    S: In the demo, yes. The code is the last 4 digits of the phone; that's the demo rule. A real gateway would verify with eSewa's server.  
     └ T: How would you integrate the real one?  
       S: Send a signed payment request to eSewa, receive the callback, then verify the transaction status server-to-server before marking it Complete. The rest of our flow (pending → complete + enrol in one transaction) stays the same.  
        └ T: Why store a TransactionUUID?  
          S: A unique reference per payment attempt. It's what a gateway uses to match its records to ours, and UNIQUE stops duplicates.  
   
**Tree I: Uploads**  
T: How are uploads secured?  
 S: Type and size are checked on the server, files get new GUID names, and they're only served through Media.ashx after a permission check.  
  └ T: Why GUID names?  
    S: No overwriting, no guessing other files' URLs, no dangerous original filenames.  
     └ T: Can I upload a script?  
       S: Only the allowed extensions are accepted, the Uploads folder blocks script execution, and direct URLs are hidden.  
        └ T: Do you check the actual file content?  
          S: No, only the extension and size. Checking the file's magic bytes would be the next improvement.  
   
**Tree J: Scalability**  
T: What happens with 10,000 users?  
 S: It would struggle as it is: LocalDB is a dev engine, sessions are in one server's memory, files are on local disk, and every page view writes an analytics row.  
  └ T: What breaks first?  
    S: Probably the database: LocalDB limits, plus lock waits from SERIALIZABLE transactions on popular courses.  
     └ T: How would you scale?  
       S: Full SQL Server, session state in SQL or Redis, files in blob storage, caching of catalogue and progress, several web servers behind a load balancer. Because data access is centralised in DatabaseHelper, those changes stay contained.  
   
**Tree K: WSDM and requirements**  
T: How did you gather requirements?  
 S: We modelled audiences with WSDM, wrote a task model per audience, and checked every brief requirement against the design.  
  └ T: Did you interview users?  
    S: No formal interviews or surveys. The audience profile came from our own experience as foundation students.  
     └ T: Then how do you know it meets their needs?  
       S: We can't claim that formally. The design follows their stated needs (short lessons, instant feedback, mobile layout). User testing with real students would be the next step.  
   
![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAnEAAAACCAYAAAA3pIp+AAAABmJLR0QA/wD/AP+gvaeTAAAACXBIWXMAAA7EAAAOxAGVKw4bAAAANUlEQVR4nO3OMQ2AABAAsSNhwgJe0PYTKpnRgQU2QtIq6DIze3UGAMBf3Gu1VcfXEwAAXrseaIEEMYtKmi4AAAAASUVORK5CYII=)  
**PART 13: DANGER ZONES**  
| | | | | | | |  
|-|-|-|-|-|-|-|  
| **#** | **Where** | **What it is** | **Simple explanation** | **Likely question** | **Safe answer** | **Deeper** |   
| 1 | QuizHelper.Fingerprint, GameHelper.Definition, ScenarioPlayHelper.Definition, SelfAssessmentHelper.Definition | SHA-256 of the content at start | "A checksum of the questions" | "Why hash?" | "To detect if the content changed between start and submit; then nothing is saved" | Length-prefixes each value so different content can't produce the same string |   
| 2 | GameHelper.RejectDuplicateKeys | JSON key scanner | Rejects {"value":"a","value":"b"} | "What's this loop?" | "The built-in parser silently keeps the last duplicate; we reject malformed results" | A stack of HashSets per { |   
| 3 | AccountSecurityHelperWITH (UPDLOCK,ROWLOCK) | Lock hint | Parallel attempts can't lose a failure count | "What's UPDLOCK?" | "Reserves the row for update until the transaction ends" | Prevents lost updates |   
| 4 | Lockout | 5 → 15 min | Temporary | "Can I lock someone out?" | "Yes, for 15 minutes; the admin can unlock. A known trade-off" | Better: rate limiting by IP, CAPTCHA after failures |   
| 5 | GameHelper.ClientData | Item JSON in the page | Matching pairs, TrueFalse answers, flashcard backs visible | "Can I see answers?" | "For games, yes (instant feedback). FillBlank and Sequence answers hidden. Quizzes never" | The score is still recalculated |   
| 6 | Memory and Flashcards scoring | moves from the browser / self-rating | Not fully verified | "Isn't that trusting the browser?" | "Partly. Time is server-measured; flashcards are self-rating like self-assessment" | Don't say "every game is cheat-proof" |   
| 7 | Media.ashxSendFile | HTTP Range | Video seeking | "What's 206 / 416?" | "Partial Content / Range Not Satisfiable" | TransmitFile streams without loading the whole file |   
| 8 | PortalLoginHelper.ReturnUrl | Redirect validation | Stops ?ReturnUrl=https://evil.com | "Open redirect?" | "Only our own .aspx pages that the role may open" | Rejects :, \, //, .., % |   
| 9 | Site.Master.csViewStateUserKey | CSRF | Forged forms fail | "CSRF?" | "ViewState is tied to the session, so a form posted from another site fails validation" | + SameSite=Lax, EventValidation |   
| 10 | CurrentUserHelper.CreateEditToken, SubmissionHelper | One-time tokens | Double-click saves once | "Why tokens?" | "Prevents duplicate creates and double submits" | Removed after commit |   
| 11 | Global.asaxCheckUrlAccessForPrincipal + Application_EndRequest | Early folder check | Access Denied instead of a login loop | "Why?" | "By default ASP.NET sends logged-in users with the wrong role back to Login" |   |   
| 12 | UploadHelper.GetValidatedPath | Path checks, reparse points | Can't delete or serve files outside Uploads | "Path traversal?" | "Paths must match ~/Uploads/{folder}/{GUID}.{ext} exactly" | Also refuses symbolic links |   
| 13 | CourseHelper.Encode, <%: %> | HTML encoding | XSS defence | "XSS?" | "User text is encoded on output; request validation is on" |   |   
| 14 | Web.configdebug="true" | Debug compile | Fine locally | "Production-ready?" | "No. We'd set debug=false, use real SQL Server, and change demo passwords" |   |   
| 15 | AccessHelper.Owns string building | Fixed SQL fragments | Not injection | "You concatenate SQL!" | "Only fixed fragments chosen by C#; IDs are parameters" | Comment in the code says so |   
| 16 | DeleteHelper ordering | Children first | FKs would otherwise block | "Why that order?" | "A child row references its parent, so the children must go first" | All in one SERIALIZABLE transaction |   
| 17 | AnalyticsHelperRandom.Next(200)==0 cleanup | Probabilistic cleanup | About 1 in 200 views deletes old rows | "Why random?" | "Avoids needing a scheduled job" | Trade-off: not exact timing |   
   
**Web Forms syntax to recognise**  
<%: x %> = encoded output · <%= x %> = raw output · runat="server" = a server control · .designer.cs = auto-generated declarations · IsPostBack · Page.IsValid · CommandName / CommandArgument on GridView buttons → RowCommand.  
![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAnEAAAACCAYAAAA3pIp+AAAABmJLR0QA/wD/AP+gvaeTAAAACXBIWXMAAA7EAAAOxAGVKw4bAAAANElEQVR4nO3OQQmAABRAsaeILbwZ9Fewo0Gs4E2ELcGWmTmqKwAA/uLeqr06v54AAPDa+gAthwNEfGhnhAAAAABJRU5ErkJggg==)  
**PART 14: CLAIM VS EVIDENCE**  
| | | | |  
|-|-|-|-|  
| **Presentation claim** | **Evidence** | **Confidence** | **Teacher may ask** |   
| 61 interlinked pages | 61 .aspx | 🟢 | "How linked?" |   
| 25 tables in 3NF | 25 tables | 🟢 / 🟡 (3NF is a design argument) | "Prove 3NF for one table" |   
| 37 helper classes | 37 files | 🟢 |   |   
| 8 game templates | CHECK + games.js | 🟢 |   |   
| 139 validators | **161** | ⚠️ undercount | "Count them" |   
| PBKDF2, SHA-256, 100k, salted | PasswordHelper | 🟢 |   |   
| Ticket 30 min, HttpOnly | AuthenticationHelper | 🟢 (+ Secure, SameSite) |   |   
| Lock after 5 | AccountSecurityHelper | 🟢, **15 min** | "Permanent?" |   
| Parameterised SQL everywhere | DatabaseHelper + pages | 🟢 | "Any concatenation?" |   
| Folder rules | Web.config | 🟢 |   |   
| Ownership checks | AccessHelper | 🟢 |   |   
| Server marks scores | Quiz 🟢, 6 game templates 🟢 | 🟡 for Memory/Flashcards |   |   
| Browser never gets correct answers | Quizzes | 🟢 quizzes / ⚠️ not games |   |   
| Payment + enrolment one transaction | PaymentHelper.CompleteDemo | 🟢 |   |   
| Upload type/size, GUID | UploadHelper | 🟢 (extension only) | "Content check?" |   
| Content locks after attempts | ContentLockHelper (used 12× in Teacher/) | 🟢 |   |   
| Progress calculated | ProgressHelper | 🟢 |   |   
| PRG | redirects after saves | 🟢 |   |   
| Private error log | Global.asax → App_Data/ErrorLog.txt | 🟢 |   |   
| Analytics without personal data | PageView columns | 🟢 |   |   
| 12 integrity checks | 12 THROWs | 🟢 (some are seed checks) |   |   
| Code lab isolated | sandbox without allow-same-origin | 🟢 |   |   
| WCAG 2.2 AA | CSS comments, focus styles | 🟡 | "Which tool?" |   
| 0 build errors/warnings | report | 🟡 rebuild |   |   
| 114 links / 23 E2E flows | report | 🔴 | "Show me" |   
| 14-week schedule | report | 🔴 plan |   |   
| Wireframes before coding | report figures | 🟡 | "What tool?" |   
   
![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAnEAAAACCAYAAAA3pIp+AAAABmJLR0QA/wD/AP+gvaeTAAAACXBIWXMAAA7EAAAOxAGVKw4bAAAANUlEQVR4nO3OMQ2AABAAsSNhwgJOUPcjIpnRgQU2QtIq6DIze3UGAMBf3Gu1VcfXEwAAXrseaJEEL8XMiYMAAAAASUVORK5CYII=)  
**PART 15: CONTRADICTIONS AND FIXES**  
| | | | | | |  
|-|-|-|-|-|-|  
| **#** | **Says** | **Actually** | **Severity** | **Fix before?** | **If asked** |   
| 1 | Slide 2: Sunil presents 7–10 | Notes: 9 = Aashish, 10 = Rupesh | **Medium** | **Yes** |   |   
| 2 | Slides 10/16: 139 validators | 161 | Low–Med | Yes ("160+" / "over 130") | "Earlier count; the final code has 161" |   
| 3 | Slide 9: login order …status → portal | Code: …portal → status | Low | Optional | Describe the code order |   
| 4 | Slides 5/18: "locks after five" | 15-minute lock | Low | Add "for 15 minutes" |   |   
| 5 | Slides 9/19: never trusts / never receives answers | True for quizzes and scores; game data is visible; Memory moves from the browser; Flashcards self-rated | **Medium** | Say "**scores** are always recalculated" | Part 13 |   
| 6 | Slide 20: 114 links / 23 flows | No test artefacts in the submission | **Medium** | Know who ran them |   |   
| 7 | Slide 6: 14-week schedule | Git shows 2 days of commits by 2 people | Medium | Say "planned" |   |   
| 8 | Slide 15: DB built by CreateDatabase.sql | LearningSystemFinal via CreateFinalDatabase.ps1 or attach | Low | No |   |   
| 9 | Slide 4: "results stored and marked" for 5 types | Scenarios/SA/discussions are recorded, not scored | Low | Optional wording |   |   
| 10 | Slide 24: progress calculated listed as a "limit" | It's a design choice | Very low | Optional |   |   
| 11 | Report cover page placeholders ([enter intake code], [member 1 full name], [TP number], [day month] 2026) |   | **High if not yet submitted** | Fill in |   |   
| 12 | Report Appendix B: "prototype layouts in Figure 13", "schedule in Figure 1" | Figure 13 = validation; Figure 1 = WSDM | Low | Fix if possible |   |   
| 13 | Slides say "Lecturer" | Code role is Teacher | Very low | No | "User-facing name vs role value" |   
   
![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAnEAAAACCAYAAAA3pIp+AAAABmJLR0QA/wD/AP+gvaeTAAAACXBIWXMAAA7EAAAOxAGVKw4bAAAANElEQVR4nO3OQQmAUBBAwSf8GGLWDWFDY3ixgjcRZhLMNjNHdQYAwF9cq1rV/vUEAIDX7gcRXAQ2s/16gwAAAABJRU5ErkJggg==)  
**PART 16: TESTING**  
**What exists**  
- 🟢 **DB self-checks:** 12 THROWs at the end of CreateDatabase.sql. If any fails, the transaction rolls back and the DB isn't created.  
- 🟢 **Constraint protection:** CHECK, UNIQUE, PK, FK (37 FKs) on every table.  
- 🟡 **Build:** rebuild and confirm.  
- 🔴 **Automated browser tests:** claimed in the report, not in the submission.  
- ❌ **Unit tests:** none.  
**Manual test table (run tonight, then you can honestly say you did)**  
| | | | | |  
|-|-|-|-|-|  
| **#** | **Area** | **Test** | **Input** | **Expected** |   
| 1 | Validation | Empty registration | Submit blank | ValidationSummary + field errors |   
| 2 | Validation | Weak password | abcdefgh | "8 to 50 characters with a letter and a number" |   
| 3 | Validation | Mismatched confirm | different passwords | "The two passwords must match." |   
| 4 | DB | Duplicate email | anita.karki@inkwell.test | "already registered" |   
| 5 | Auth | Wrong portal | Learner on the Lecturer login | "cannot use this portal" |   
| 6 | Auth | Pending lecturer | ravi.thapa@… | "still being reviewed" |   
| 7 | Auth | Lockout | 5 wrong passwords (test account) | "locked… 15 minutes"; admin Unlock works |   
| 8 | Authz | Wrong-role URL | Learner → /Admin/Dashboard.aspx | Access denied |   
| 9 | Authz | Logged out | /Learner/Dashboard.aspx | Login page |   
| 10 | Authz | IDOR | Lecturer opens another's CourseBuilder.aspx?id= | Access denied |   
| 11 | Errors | Missing page | /xyz.aspx | Custom 404 |   
| 12 | Payment | Wrong code ×3 | Ben, code 0000 | Payment Failed, not enrolled |   
| 13 | Payment | Correct code | Ben, 9841234567 / 4567 | Receipt, enrolled |   
| 14 | Quiz | Submit | answer and submit | Score ring + review; appears in My results |   
| 15 | Quiz | Source | View Source | No correct-answer markers |   
| 16 | CRUD | Subjects | add, edit, delete unused | Success messages |   
| 17 | CRUD | Delete in-use subject | "Programming" | Blocked |   
| 18 | Lock | Edit a quiz with attempts | Lecturer | "Content is locked after attempts" |   
| 19 | Preview | Lecturer previews a quiz | submit | Result shown, **no** Attempt saved |   
| 20 | Responsive | 390 px | DevTools | Sidebar becomes a row, no horizontal scroll |   
| 21 | Certificate | Anita's completed course | open certificate | Printable certificate |   
| 22 | PRG | Refresh after save | F5 | No duplicate, no resubmit prompt |   
   
![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAnEAAAACCAYAAAA3pIp+AAAABmJLR0QA/wD/AP+gvaeTAAAACXBIWXMAAA7EAAAOxAGVKw4bAAAANUlEQVR4nO3OQQmAABRAsSd40A5GMORPYEt7WMGbCFuCLTNzVFcAAPzFvVZbdX49AQDgtf0BSrIDUgOg4eAAAAAASUVORK5CYII=)  
**PART 17: SECURITY (WHAT ACTUALLY EXISTS)**  
| | | |  
|-|-|-|  
| **Area** | **Status** | **Where** |   
| Password hashing | 🟢 PBKDF2-SHA256 100k, 16-byte salt, constant-time compare | PasswordHelper |   
| Lockout | 🟢 5 → 15 min, UPDLOCK, admin unlock | AccountSecurityHelper, Admin/Users |   
| Generic login error | 🟢 | same |   
| Portal role check | 🟢 | PortalLoginHelper |   
| Ticket | 🟢 encrypted, role in UserData, HttpOnly, Secure, SameSite=Lax, 30-min sliding | AuthenticationHelper, Web.config |   
| HTTPS | 🟢 redirect + requireSSL | Global.asax, Web.config |   
| Folder authorisation | 🟢 | Web.config <location> |   
| Ownership / enrolment (IDOR) | 🟢 | AccessHelper |   
| Deactivated-mid-session | 🟢 signed out | RequireRole → IsActive |   
| Forced password change | 🟢 | MustChangePassword, Global.asax |   
| SQL injection | 🟢 | DatabaseHelper, whitelisted ORDER BY, escaped LIKE |   
| XSS | 🟢 | encoding + validateRequest |   
| CSRF | 🟢 | ViewStateUserKey, EventValidation, SameSite |   
| Clickjacking | 🟢 | X-Frame-Options: SAMEORIGIN |   
| MIME sniffing | 🟢 | nosniff |   
| Uploads | 🟢 ext + size, GUID, no execution, hidden folder, permission-checked handler, path validation | UploadHelper, Media.ashx, Uploads/web.config |   
| Error leakage | 🟢 | custom errors + private log |   
| Bots | 🟢 math CAPTCHA (Register, Contact) | CaptchaHelper |   
| Open redirect | 🟢 | ReturnUrl validation |   
| Code lab | 🟢 sandboxed iframe | MaterialHelper, site.js |   
| Secrets | 🟢 Windows auth to LocalDB, so no DB password in the config | Web.config |   
| **Missing** | ❌ email verification, email password reset, 2FA, IP rate limiting, file magic-byte checks, a real payment gateway, a production config (debug="true"), shared demo passwords |   |   
   
**Never say:** "fully secure", "unhackable".  
   
 **Say:** "We applied the main OWASP defences for a prototype: hashing, parameterised SQL, layered authorisation, output encoding and CSRF protection. For production we'd add email verification, rate limiting and hosting hardening."  
![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAnEAAAACCAYAAAA3pIp+AAAABmJLR0QA/wD/AP+gvaeTAAAACXBIWXMAAA7EAAAOxAGVKw4bAAAANUlEQVR4nO3OQQmAABRAsSd4NIGRTPXNaQBrWMGbCFuCLTOzV2cAAPzFvVZbdXw9AQDgtesBhZQEOYZGgUEAAAAASUVORK5CYII=)  
**PART 18: LIMITATIONS, PERFORMANCE AND SCALABILITY**  
| | | |  
|-|-|-|  
| **Limitation** | **Why** | **Professional phrasing** |   
| Fake payment | No merchant account; must run offline | "It simulates the full flow, including the transaction. The real API replaces only the verify step." |   
| LocalDB | Dev engine | "For hosting we'd use SQL Server/Azure SQL; only the connection string changes." |   
| InProc session for quiz/game/scenario runs | Web Forms default | "A restart loses an in-progress attempt. Nothing half-saved; just restart. Multiple servers would need a shared session store." |   
| No email | No mail server | "Future work." |   
| Game data visible | Instant feedback | "Scores are still recalculated server-side." |   
| Extension-only upload checks | Simplicity | "Magic-byte checks next." |   
| Web Forms is legacy | Module | "Core MVC for a modern rebuild." |   
| No unit tests | Time | "Scoring and progress helpers first." |   
| Analytics insert on every GET | Simplicity | "Batch or sample at scale." |   
| Progress calculated per request | Correctness | "Cache at scale." |   
| Real-world learning effect unproven | No user study | "We don't claim improved results; user testing is next." |   
   
**Bottlenecks to name if asked:**  
- LocalDB.  
- SERIALIZABLE lock waits on popular courses.  
- ProgressHelper UNION queries per course on dashboards with many courses.  
- An analytics write per page view.  
- Large ViewState on GridView pages.  
- Video served from local disk through ASP.NET.  
**"What if 10,000 users?"** → Part 12 Tree J.  
![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAnEAAAACCAYAAAA3pIp+AAAABmJLR0QA/wD/AP+gvaeTAAAACXBIWXMAAA7EAAAOxAGVKw4bAAAANElEQVR4nO3OQQmAUBBAwSd8bOHVnBvBkAaxgjcRZhLMNjNHdQUAwF/cq9qr8+sJAACvrQctgQNH4A++9QAAAABJRU5ErkJggg==)  
**PART 19: TEAM CONTRIBUTIONS (EVIDENCE ONLY)**  
| | | | | |  
|-|-|-|-|-|  
| **Member** | **Proposed responsibility (report App. C)** | **Presents** | **Git evidence (main repo)** | **Must be able to explain** |   
| **Ujwal Chhetri** | Integration, DB contracts, final verification | 1, 11, 12, 17, 18, 24, 25 | 🟢 4 commits incl. *"Add project files"*,  *"evidence, phase 16 audit, progress, test checklists"* | ERD, constraints, DatabaseHelper, transactions, auth layers, Subjects CRUD |   
| **Sunil Kandel** | Shared visual design, navigation, responsive review | 7, 8, 16, 20 | 🟢 12 commits, e.g. *"pastel UI redesign with sidebar app shell"*,  *"offline eSewa demo payment"*,  *"redesign every page"*,  *"custom 404 and error pages through TransferRequest"*,  *"mobile layout and error-page fixes"*,  *"let the admin author courses"*,  *"catalogue, new game types, code labs and design system"* | WSDM, use cases, CSS/design tokens, validation, responsive, error pages, eSewa demo |   
| **Aashish Raj Nakarmi** | Course materials, interactive modules, overall web design | 9, 13–15, 19, 21–23 | 🔴 none in git | Flowcharts, wireframes, navigation, games, quizzes, scenarios, code lab, user screens |   
| **Rupesh G.C.** | Administration, reporting, documentation | 2–6, 10, 23 (admin) | 🔴 none in git | Scope, schedule, objectives, admin pages, analytics, brief mapping |   
   
⚠️ The report itself says this allocation is *"a proposal for coordination, not a verified historical contribution log."* Git only shows who committed code. Design, documentation and testing work can be real without commits. **Agree tonight on what each person will say.**  
**Per-member viva prep**  
**Ujwal:**  
- "Walk me through the ERD." "Why these cascades?" "Show me DatabaseHelper."  
- "Why SERIALIZABLE?" "How is the role attached to a request?" "What does the integrity script check?"  
- *Read:*CreateDatabase.sql (tables + the end checks), DatabaseHelper.cs, AuthenticationHelper.cs, Global.asax.cs, Admin/Subjects.aspx.cs.  
**Sunil:**  
- "Why WSDM?" "Explain your regex." "Why two-layer validation?" "How is the site responsive?"  
- "How did you test?" "Show me your CSS tokens." "Explain the eSewa demo transaction."  
- *Read:*Styles/site.css (:root, @media), Account/Register.aspx(.cs), Web.config customErrors, Global.asax.csApplication_Error, PaymentHelper.cs.  
**Aashish:**  
- "How are games scored?" "Can I cheat a game?" "How does the code lab stay safe?"  
- "What's in a scenario's database?" "How does the lesson know what's next?" "Why lock quiz content?"  
- *Read:*GameHelper.cs (Score), Scripts/games.js (the bottom hfResult part), QuizHelper.cs (Begin/SubmitRun), ScenarioPlayHelper.cs (Move), MaterialHelper.cs (code lab), Member/Lesson.aspx.cs.  
**Rupesh:**  
- "What's out of scope and why?" "Who is M1–M4?" "How does lecturer approval work?"  
- "What does analytics store?" "Can the admin delete a lecturer with courses?" "How does the admin reset a password without email?"  
- *Read:*Admin/TeacherApplications.aspx.cs, Admin/Users.aspx.cs, Admin/UserEdit.aspx.cs, AnalyticsHelper.cs, DeleteHelper.DeleteUser.  
**Template for "What exactly did YOU do?"**  
*"My main area was * ***[area]*** *. Specifically I worked on * ***[2–3 concrete files/features]*** *. The hardest part was * ***[one real difficulty]*** *, which we solved by * ***[solution]*** *. I learned * ***[one lesson]*** *."*  
Example (Sunil, adjust to the truth):  
*"My main area was the visual design and front end: the design system in site.css with CSS variables, the sidebar layout a* *nd its mobile version, and the custom error pages. I also worked on the offline eSewa demo flow. The hardest part was the mobile layout. The sidebar had to become a horizontal row on phones, and we only caught the problems by testing at real phone widths."*  
![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAnEAAAACCAYAAAA3pIp+AAAABmJLR0QA/wD/AP+gvaeTAAAACXBIWXMAAA7EAAAOxAGVKw4bAAAANElEQVR4nO3OUQmAABBAsSeILQSjXgcrmkOs4J8IW4ItM7NXZwAA/MW1Vlt1fBwBAOC9+wEukwQ+V/SggAAAAABJRU5ErkJggg==)  
**PART 20: PRESENTATION SPEAKING GUIDE**  
- Each slide has **one idea**. Say it first, then support it.  
- Use **What → Why → Example from our code**.  
- Point at figures: *"On the left you can see…"*  
- Don't read bullets. Glance, then talk.  
- Use the hand-over line at the end (it's in the speaker notes).  
- Sound like a student explaining your own work, not like a brochure. Say *"we used"*, not  *"leverages a robust architecture"*.  
**Opening lines for every slide**  
| | |  
|-|-|  
| **Slide** | **Opener** |   
| 1 | "We built Inkwell, a learning site where every topic ends with practice the server marks." |   
| 2 | "We'll follow the same six chapters as our report." |   
| 3 | "We started from a problem we'd felt ourselves as foundation students." |   
| 4 | "Six objectives guided everything we built." |   
| 5 | "Just as important as what we built is what we chose not to build." |   
| 6 | "Here's how we planned the fourteen weeks." |   
| 7 | "Before designing pages, we asked: who will actually use this?" |   
| 8 | "Once we knew our users, we listed what each can do." |   
| 9 | "Three processes carry most of the rules, so we drew them as flowcharts." |   
| 10 | "Here's every requirement in the brief, and where to find it." |   
| 11 | "The database follows the way content is organised: subject, course, topic, item." |   
| 12 | "The other half of the database is about people and what they've done." |   
| 13 | "Before coding, we fixed the layout with wireframes." |   
| 14 | "We wanted users to always know where they are and what just happened." |   
| 15 | "Here's what we built it with, and how the files are organised." |   
| 16 | "This slide is about what the user actually sees and types into." |   
| 17 | "Every bit of data goes through one helper class." |   
| 18 | "Security is built in layers, not added at the end." |   
| 19 | "Anything from the browser can be changed, so the server makes the decisions." |   
| 20 | "Building it is one thing. We also had to check it works, and fails safely." |   
| 21 | "Let's walk through it as a visitor first." |   
| 22 | "This is the heart of Inkwell: the learner's journey." |   
| 23 | "Behind the scenes, lecturers build and the admin runs the platform." |   
| 24 | "To sum up, and what we learned." |   
| 25 | "Here's where we'd take it next. Thank you, and we're happy to take questions." |   
   
![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAnEAAAACCAYAAAA3pIp+AAAABmJLR0QA/wD/AP+gvaeTAAAACXBIWXMAAA7EAAAOxAGVKw4bAAAAM0lEQVR4nO3OUQmAABBAsaeI2MKqV8RyJrGCfyJsCbbMzFldAQDwF/dWrdXx9QQAgNf2B/NkAzRb7P0YAAAAAElFTkSuQmCC)  
**PART 21: EMERGENCY ANSWERS**  
| | |  
|-|-|  
| **Situation** | **Say** |   
| Don't know | "I'm not certain about that detail and I don't want to give you a wrong answer. At a high level, in our project…" |   
| Not your part | "That was mainly [name]'s area. [Name], could you take that? My understanding is…" |   
| Out of scope | "That's outside our current scope; it's in future work. If we built it, we'd…" |   
| Library internals | "I don't know that library's internal implementation, but in our project we use it for…" |   
| Forgot a term | Describe it plainly: "the file that runs before every request" (Global.asax) |   
| Made a mistake | "Sorry, let me correct that: it's actually…" |   
| Challenged | "Fair point. We chose X because…, and the trade-off is… For production we'd consider Y." |   
| Teacher interrupts | Stop. Listen fully. Answer that exact question. |   
| Mind goes blank | "Let me think for a second." Then trace the request flow out loud. |   
   
**"Did you use AI to build this?"**  
Be honest. The original repo contains an AI-agent instruction file, so denial is far riskier than the truth.  
*"Yes, we used an AI coding assistant for parts of the implementation, under rules we set ourselves: our * *own blueprint, fixed technology, parameterised SQL only, and simple readable code we could explain. We did the requirements, audience model, ERD and wireframes, and we reviewed and tested what was built. I'm happy to walk you through any part of the code."*  
*(Agree on the exact wording as a team, and check what your module's academic-integrity policy says about declaring AI use.)*  
**Recovery cues ("If you forget, think of this")**  
| | |  
|-|-|  
| **Topic** | **Cue** |   
| Any request | *UI asks → Global checks → Page handles → Helper decides → DB stores → Redirect shows* |   
| Login | *Lock? → Hash? → Portal? → Status? → Ticket* |   
| Authorisation | *Folder → Role → Owner* |   
| Security list | *Hash, Parameter, Folder, Owner, Encode, Token* |   
| Validation | *Browser fast · Server safe · DB last* |   
| Database | *Subject → Course → Topic → Item; Keys · Checks · Transactions · Calculated progress* |   
| Scoring | *Browser sends answers, server decides the score* |   
| Payment | *Pending → Verify → Complete + Enrol (one transaction)* |   
| Testing | *Build → Data → Browser → Fail-safe* |   
| Progress | *Done ÷ Published, calculated never stored* |   
| Scale | *DB, Session, Files, Cache, Servers* |   
   
![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAnEAAAACCAYAAAA3pIp+AAAABmJLR0QA/wD/AP+gvaeTAAAACXBIWXMAAA7EAAAOxAGVKw4bAAAANElEQVR4nO3OQQmAABRAsad4EjtY9fewnUms4E2ELcGWmTmrKwAA/uLeqrU6vp4AAPDa/gDzWAM6QQXRdAAAAABJRU5ErkJggg==)  
**PART 22: MOCK VIVA (SELF-TEST)**  
Answer out loud **before** opening each answer.  
**Level 1: Classmate**  
1. What is Inkwell in one sentence?  
A learning website where every topic ends with a practice activity that the server marks and saves to progress.  
2. Who are the users?  
Visitor, Learner, Lecturer (Teacher in code), Administrator.  
3. What technologies did you use?  
ASP.NET Web Forms (.NET 4.8), C#, ADO.NET, SQL Server LocalDB, HTML5, CSS, plain JavaScript.  
4. What are the 5 activity types?  
Quiz, Game, Scenario, Self-assessment, Discussion.  
5. Name the 8 games.  
Matching, Memory, Scramble, Sort, Flashcards, FillBlank, TrueFalse, Sequence.  
6. Three CSS types and where?  
External site.css · internal <style> in Site.Master · inline style="" on Default.aspx.  
7. How do you become a lecturer?  
Register as a lecturer with a 20–500 character reason → Pending → admin approves → Active.  
8. Is the payment real?  
No, it's an offline eSewa-style demo. Code = last 4 digits of the phone.  
**Level 2: Normal teacher**  
9. Why validate on the server too?  
The browser can be bypassed. Page.IsValid re-runs the validators; DB constraints are the last guard.  
10. How do you stop SQL injection?  
All SQL uses SqlParameters through DatabaseHelper; ORDER BY comes from a whitelist; LIKE wildcards escaped.  
11. How are passwords stored?  
PBKDF2-SHA256, 100,000 iterations, 16-byte random salt, stored as PBKDF2$100000$salt$hash.  
12. Where is the role stored after login?  
In the encrypted Forms Auth ticket's UserData, attached each request in Global.asax; also in Session["Role"].  
13. Where is CRUD demonstrated?  
Admin/Subjects.aspx: list (LEFT JOIN count), add/edit in one form, delete blocked if in use, in a transaction.  
14. 401 vs 403 in your site?  
401 not logged in → login page; logged in with the wrong role → AccessDenied.aspx.  
15. Why is progress not stored?  
Derived data would go stale when lecturers add/remove items; ProgressHelper calculates done ÷ published.  
16. What does "content lock" mean?  
Once an activity has an attempt, its questions/items/steps can't change (title and description still can), so old scores stay meaningful.  
17. Name 5 HTML5 elements and where.  
header/nav/main/footer (Site.Master), video+track (home), audio (lessons), canvas (charts), progress (quiz), details (help/FAQ).  
18. What's the difference between a scenario and a quiz in the database?  
Quiz attempts store ScorePercent + QuizAnswer rows; scenario attempts store EndingStepID (outcome Best/Acceptable/Poor) and no score.  
19. What does WSDM stand for and what's its main idea?  
Web Site Design Method (De Troyer & Leune, 1998): start from the audiences and their tasks, not from data.  
20. Why are there separate login portals?  
Clarity, plus an extra check: an account can only sign in on its own role's portal.  
**Level 3: Strict examiner**  
21. "The server never trusts the browser", but I see matching pairs in the page source. Explain.  
Games include item data for instant feedback; quizzes don't. What's never trusted is the score: it's recalculated from the DB. Memory moves are browser-reported; Flashcards are self-rated. Fix: server-side per-move checks.  
22. Two tabs submit the same quiz simultaneously. What happens?  
A one-time SubmissionToken is consumed on the first submit; SERIALIZABLE transaction re-checks MaxAttempts; Web Forms serialises requests per session. The second fails, and no duplicate is saved.  
23. You say 139 validators; I count 161. Which is right?  
161 is the final code (76/49/16/16/4). The report figure was from an earlier count.  
24. Can I lock another user out?  
Yes, for 15 minutes. A known trade-off. Fix: IP rate limiting, CAPTCHA after failures, progressive delays.  
25. Show me the 114-link crawl.  
(Honest) It's described in the report's testing section; the scripts aren't in the submitted code. What I can show live is… [Part 16 tests].  
26. Why do you concatenate SQL in DeleteHelper if you always use parameters?  
Only fixed fragments chosen in C# (subqueries); the user-supplied ID is still @id. No user input is ever concatenated.  
27. Why aren't SimStep and GameItem→GameGroup cascade deletes?  
SQL Server forbids cycles and multiple cascade paths (Activity.StartStepID ↔ SimStep; GameItem reachable via Activity and GameGroup). So DeleteHelper removes them in order inside a transaction.  
28. If I edit my auth cookie to say "Admin", what happens?  
The ticket is encrypted and validated; tampering makes decryption fail and the cookie is ignored. Plus AttachRole only accepts the 3 known roles.  
29. A lecturer deactivates… no: the admin deactivates a learner who is mid-lesson. What happens?  
Their next protected page calls RequireRole → IsActive → false → SignOut → login with "no longer active".  
30. What's the weakest part of your system?  
Honest options: the demo payment, extension-only upload checks, game data visible client-side, no unit tests, LocalDB/InProc session for scale. Pick one and give the fix.  
31. How does the code lab not become an XSS hole?  
Learner HTML is placed in iframe srcdoc with sandbox="allow-scripts allow-modals" and no allow-same-origin, so it runs in an opaque origin, can't read our cookies or DOM, and is never executed on the server.  
32. Did you use AI?  
(Agreed honest team answer, Part 21.)  
👉 For live practice tell Claude: **"Teacher attack mode"**, or a focus like  **"Teacher attack mode, Aashish, games"**. You'll get one question at a time, graded on accuracy, completeness, confidence, evidence and risk, with follow-ups that get harder.  
![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAnEAAAACCAYAAAA3pIp+AAAABmJLR0QA/wD/AP+gvaeTAAAACXBIWXMAAA7EAAAOxAGVKw4bAAAANUlEQVR4nO3OMQ2AABAAsSPBCUZfE2bYmFDBhAU2QtIq6DIzW7UHAMBfnGt1V8fXEwAAXrseCOMF7pSSVXMAAAAASUVORK5CYII=)  
**PART 23: FINAL CHEAT SHEET**  
**One sentence:** A web learning system where every topic ends with server-marked practice.  
   
 **Problem:** Resources explain but don't test; lecturers can't code.  
   
 **Solution:** A marked activity after every topic, plus no-code course builders.  
   
 **Users (WSDM):** Visitor → Learner / Lecturer (Teacher) / Admin.  
   
 **Features:**  
- Catalogue and previews  
- Free or paid enrolment (demo eSewa)  
- 7 lesson types, including code lab  
- 5 activity types and 8 games  
- Progress, streak, certificate  
- Reviews and bookmarks  
- Lecturer builders with preview and lock  
- Admin users, approvals, subjects, FAQs, messages, payments, analytics  
**Stack:** Web Forms 4.8 · C# · ADO.NET · SQL Server LocalDB · HTML5/CSS/JS · Forms Auth · PBKDF2.  
   
 **Architecture:** Browser → Global.asax → Web.config rules → Page + code-behind → Helpers → DatabaseHelper → SQL → Redirect.  
   
 **Database:**  
- 25 tables · 37 FKs (8 cascade down the content chain) · composite PKs · CHECKs · 31 indexes · 12 script checks  
- Progress and streak are calculated, never stored  
**Key files:** Web.config · Global.asax.cs · Site.Master · DatabaseHelper · AccountSecurityHelper · AuthenticationHelper · PasswordHelper · AccessHelper · QuizHelper · GameHelper · ProgressHelper · PaymentHelper · DeleteHelper · UploadHelper/Media.ashx · CreateDatabase.sql.  
   
 **Critical flows:** Register · Login · Enrol/Pay · Lesson complete · Quiz · Game · Subjects CRUD · Approve lecturer.  
   
 **Security:**  
- PBKDF2 · lockout 5 → 15 min · portal check  
- Encrypted HttpOnly/Secure/SameSite ticket · HTTPS  
- Folder rules + ownership checks  
- Parameters · encoding · ViewStateUserKey · CAPTCHA  
- Upload checks + Media.ashx · custom errors + private log  
**Testing:** Build · DB checks · (report) browser crawl and end-to-end flows · manual role tests · 404/403.  
   
 **Limits:** demo payment · LocalDB · InProc session · no email · game data visible · extension-only upload check · no unit tests.  
   
 **Future:** notifications · real eSewa · badges/recommendations · dark theme/sounds.  
**20 most likely questions (one-line answers)**  
1. **Why Web Forms?** Module tech; built-in validators, master pages, Forms Auth.  
2. **Why relational SQL Server?** Connected data, joins, FKs, transactions.  
3. **SQL injection?** Parameters via DatabaseHelper.  
4. **Passwords?** Salted PBKDF2-SHA256, 100k rounds.  
5. **Authentication vs authorisation?** Who you are vs what you may do.  
6. **How is a page protected?** Folder rule + RequireRole + ownership check.  
7. **Client vs server validation?** Speed vs security (+ DB constraints).  
8. **CRUD?** Admin/Subjects.aspx.  
9. **Site.Master?** Shared layout, role nav, breadcrumb, messages, internal CSS.  
10. **3 CSS types?** site.css / <style> in the master / inline on Default.  
11. **Quiz cheating?** Answers never sent; server marks; server time.  
12. **Game results?** JSON answers in hfResult; server re-scores.  
13. **WSDM?** Audiences → tasks → pages.  
14. **Paid enrolment?** Pending → verify → Complete + Enrol, one transaction.  
15. **Wrong-role URL?** Access denied.  
16. **Errors?** Friendly page; details in App_Data/ErrorLog.txt.  
17. **Progress?** Calculated, never stored.  
18. **Testing?** Build, DB checks, browser tests, manual role tests.  
19. **Limitations?** Demo payment, LocalDB, no email, legacy framework.  
20. **What did you do?** Your agreed answer (Part 19).  
**10 dangerous questions**  
1. "Show me the automated tests."  
2. "I can see game answers in the source."  
3. "139 or 161?"  
4. "Can I lock someone out?"  
5. "Did you use AI?"  
6. "Who is M1–M4?"  
7. "Is payment real?"  
8. "Explain QuizHelper's fingerprint."  
9. "Do you check file contents?"  
10. "10,000 users?"  
→ Answers in Parts 12, 13, 15, 18 and 21.  
**DO NOT SAY**  
- ❌ "Fully secure" / "unhackable"  
- ❌ "Real eSewa payments" / "deployed" / "hosted online"  
- ❌ "Every game is cheat-proof" / "the browser never sees any answers" (quizzes only)  
- ❌ "Permanently locks the account"  
- ❌ "Scalable to thousands of users"  
- ❌ "Real-time" anything (no chat or websockets)  
- ❌ "AI tutor" / "AI-generated questions"  
- ❌ "We followed the 14-week schedule exactly" / "we committed weekly"  
- ❌ "We ran 114 tests" (unless you personally did and can name the tool)  
- ❌ "We wrote unit tests"  
- ❌ "Email notifications" / "email password reset"  
- ❌ "Students learn better with Inkwell" (no study was done)  
- ❌ "We surveyed students" (no evidence)  
![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAnEAAAACCAYAAAA3pIp+AAAABmJLR0QA/wD/AP+gvaeTAAAACXBIWXMAAA7EAAAOxAGVKw4bAAAANElEQVR4nO3OQQmAABRAsad4FCtY9ecwnkms4E2ELcGWmTmrKwAA/uLeqrU6vp4AAPDa/gDzUgM9+S8z3AAAAABJRU5ErkJggg==)  
**PART 24: LAST 30 MINUTES BEFORE PRESENTATION**  
| | |  
|-|-|  
| **Minutes** | **Do** |   
| **0–5** | Say Level 1 and Level 2 (Part 1) out loud. Check Part 0: who presents what. |   
| **5–10** | Architecture anchor (Part 3) + Login (6.2) + Enrol/Pay (6.4) + Quiz (6.6). |   
| **10–15** | Your own slides in Part 10: read the "Say this" lines once. |   
| **15–20** | Part 12 trees B (SQL injection), C (auth) and F (scoring). Everyone gets these. |   
| **20–25** | Part 23: the 20 likely questions + the DO NOT SAY list. |   
| **25–30** | Part 13 #4–6 + Part 21 emergency lines. **Open the app and log in once** (Part 6.5). |   
   
**Calm-down rules**  
- **Speaking too fast:** finish a sentence, breathe. Silence feels longer to you than to them.  
- **Interrupted:** stop, listen, answer *that* question.  
- **Unexpected question:** "Let me think for a second." Trace *UI → Global → Page → Helper → DB → Redirect*.  
- **Don't know:** say so, then say what you *do* know. Never bluff.  
- **Challenged:** "Good point. We chose X because…, the trade-off is…"  
- **Mistake:** "Sorry, let me correct that." Calmly. Teachers respect it.  
- **A teammate is stuck:** "If I can add to that…" Rescue them gently with the relevant anchor.  
![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAnEAAAACCAYAAAA3pIp+AAAABmJLR0QA/wD/AP+gvaeTAAAACXBIWXMAAA7EAAAOxAGVKw4bAAAANklEQVR4nO3OQQmAABRAsSfYxZo/kC1sYQLPJrCCNxG2BFtmZquOAAD4i3Ot7mr/egIAwGvXA4qzBdC53Vr8AAAAAElFTkSuQmCC)  
*Prepared from * *Submission/LearningSystem* *, the 25-slide PPTX with speaker notes, the final report, the assignment brief and the marking scheme. Anything marked 🔴 must be confirmed with your team before you rely on it.*  
