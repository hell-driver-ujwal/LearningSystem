# Phase 16 — final audit (2026-10-01)

Audit only. No application, configuration, schema or BLUEPRINT changes were made. PASS means the cited source implements the stated requirement under approved decisions; it does **not** mean a fresh runtime test passed. PARTIAL includes a confirmed gap or an explicitly identified evidence limitation. Detailed source references are relative to the repository root.

## Verification boundary

- Full solution Debug build: **PASS, 0 warnings, 0 errors** (MSBuild Visual Studio18, /t:Build /p:Configuration=Debug /v:normal). ASPX runtime compilation is not proved by this C# build alone.
- Final runtime/metadata connection: **BLOCKED** before any test fixture or page flow. LocalDB reported SQL Network Interfaces error50: “Error occurred during LocalDB instance startup: SQL Server process failed to start.” No database writes, rebuild/reset/detach, security changes, external payment calls or retry loop. The single audit-owned IIS Express process was stopped.
- Therefore none of the requested Phase16 public/student/teacher/admin/payment flows, rendered accessibility/width checks or live-schema comparisons is claimed passed. Prior PHASE11/12/13/15-VERIFICATION reports were reviewed as historical evidence only. Phase15 reached sandbox login, not a real COMPLETE response. Its synthetic idempotency check is not a provider round trip.
- Static inspection covers shared helpers,58 pages/companions, configuration, scripts/styles, create/upgrade SQL and project inventory. This is a bounded source audit, not a formal proof or exhaustive attack test.

## Prioritized findings

| ID / priority | Requirement and affected evidence | Finding / recommended fix | Contract/schema change? |
|---|---|---|---|
| M01 MUST FIX — high/security | SYS-05, Blueprint13; `Web.config:24–27` | ASP.NET customErrors is **Off**. Uncaught errors can disclose stack traces, source paths and technical details. Phase11 report and progress claim this was fixed, but current configuration contradicts them. Restore On with existing friendly routes; verify one controlled error after approval. No code/config fix performed. | No. Existing requirement. |
| S01 SHOULD FIX — content/presentation | PUB-01/02/10, SYS-14, R05; `Default.aspx:8`; `About.aspx:7`; `Site.Master:31` | Real intro video/poster, subject images and email/address remain absent. Q31 approved honest placeholders, so these are disclosed partial content, not fabricated functionality or an unauthorized implementation omission. Team should supply approved assets/details. | No schema change; team content required. |
| S02 SHOULD FIX — documentation, corrected in this audit | `docs/PROGRESS.md:37`; EVIDENCE old security/line references | SYS-03/13/19 and review-link notes were stale; SYS-05 incorrectly complete; About/footer claims hid contact incompleteness. Updated progress and evidence from actual source; retained historical reports. | No. Documentation only. |
| S03 SHOULD FIX — accessibility | SYS-16/R22, custom checkout; `Site.Master:26–29`; `Learner/Checkout.aspx:12` | Checkout payment form is outside main. Landmark navigation can skip the essential Continue to eSewa action. Retain separate forms/no provider ViewState; wrap both form content areas in one main landmark or give payment section a clearly labelled region. Requires approved markup/designer review; not changed. | No schema; preserve approved separate-form contract. |
| S04 SHOULD FIX — report evidence | D06/D07/D08; `docs/BLUEPRINT.md:890–892` | Repository contains source/report guidance and screenshots, but no final use-case/flowchart/ERD/wireframe/navigation-diagram report set or finished code-explanation section. Team should attach its actual report artefacts. Their existence outside this workspace is unknown. | No. Report deliverable. |

**Counts: 1 MUST FIX; 4 SHOULD FIX (S02 documentation corrected; S01/S03/S04 remain).** LocalDB and external sandbox limits are verification blockers, not additional proven code defects. No demonstrated IDOR bypass found in the inspected paths.

## Feature-ID audit — original blueprint

All original IDs below are evaluated against the approved Q29–35 decisions and later custom login/payment extension. Original one-page login/free enrolment expectations were explicitly extended; they are not defects. Progress column records the pre-audit checkbox, with discrepancies explained below.

| Feature / requirement | Audit | Progress before audit | Actual implementation evidence and explanation |
|---|---|---|---|
| PUB-01 — Home page | PARTIAL | partial | `Default.aspx.cs:15–18` — Page_Load: published subject counts; six newest published course cards. Intro/poster/subject images awaiting team assets (S01). |
| PUB-02 — About page | PARTIAL | complete | `About.aspx:4–7` — Mission/objectives/how-it-works exist; actual contact details remain placeholders. |
| PUB-03 — Browse subjects | PASS | complete | `Default.aspx.cs:15–18` — Page_Load: published subject counts; six newest published course cards. |
| PUB-04 — Course catalogue | PASS | complete | `Courses.aspx.cs:40–46` — BindCourses: published-only title/description search, subject filter, parameterized paging. |
| PUB-05 — Search courses | PASS | complete | `Courses.aspx.cs:40–46` — BindCourses: published-only title/description search, subject filter, parameterized paging. |
| PUB-06 — Filter by subject | PASS | complete | `Courses.aspx.cs:40–46` — BindCourses: published-only title/description search, subject filter, parameterized paging. |
| PUB-07 — Course outline | PASS | complete | `CourseDetails.aspx.cs:17–34` — Page_Load: published course, teacher, subject, price, LastUpdated UTC and outline. |
| PUB-08 — Free preview | PASS | complete | `Preview.aspx.cs:15–22` — Page_Load: IsPreview plus both publication states; no mutation. |
| PUB-09 — Help / FAQ page | PASS | complete | `Help.aspx.cs:17–25` — Page_Load: audience-filtered FAQ, encoded details/summary; static guidance retained. |
| PUB-10 — Contact information | PARTIAL | partial | `About.aspx:4–7` — Mission/objectives/how-it-works exist; actual contact details remain placeholders. |
| AUTH-01 — Register as learner | PASS | complete | `Account/Register.aspx.cs:47–73` — Registration validation, hash, Active/Pending role status and success redirect. |
| AUTH-02 — Apply as teacher | PASS | complete | `Account/Register.aspx.cs:47–73` — Registration validation, hash, Active/Pending role status and success redirect. |
| AUTH-03 — Log in | PASS | complete | `Helpers/AccountSecurityHelper.cs:15–82` — CheckLogin: locked/non-active accounts blocked; password verified; approved role mismatch handling. |
| AUTH-04 — Block non-active accounts | PASS | complete | `Helpers/AccountSecurityHelper.cs:15–82` — CheckLogin: locked/non-active accounts blocked; password verified; approved role mismatch handling. |
| AUTH-05 — Log out | PASS | complete | `Account/Logout.aspx.cs:10–11` — SignOut ends ticket/session; redirects Home. |
| AUTH-06 — Role redirect | PASS | complete | `Helpers/PortalLoginHelper.cs:25–38` — ReturnUrl: forced change, role dashboard fallback and local folder-authorized return. |
| AUTH-07 — View profile | PASS | complete | `Member/Profile.aspx.cs:41–63` — Own authenticated UserID only; unique email validation, active-user update and PRG. |
| AUTH-08 — Edit profile | PASS | complete | `Member/Profile.aspx.cs:41–63` — Own authenticated UserID only; unique email validation, active-user update and PRG. |
| AUTH-09 — Change password | PASS | complete | `Member/ChangePassword.aspx.cs:20–45` — Correct current password, different validated new password; compare-and-update hash/flag atomically. |
| AUTH-10 — Page protection | PASS | complete | `Helpers/AccessHelper.cs:63–80` — RequireRole plus owner/enrolment/material guards; page-specific matrix below. |
| CRS-01 — Add subject | PASS | complete | `Admin/Subjects.aspx.cs:20–61` — Subject list and parameterized validated Save handler. |
| CRS-02 — List subjects | PASS | complete | `Admin/Subjects.aspx.cs:20–61` — Subject list and parameterized validated Save handler. |
| CRS-03 — Edit subject | PASS | complete | `Admin/Subjects.aspx.cs:20–61` — Subject list and parameterized validated Save handler. |
| CRS-04 — Delete subject | PASS | complete | `Admin/Subjects.aspx.cs:85–91` — Referenced-subject delete guard inside transaction. |
| CRS-05 — Create course | PASS | complete | `Teacher/CourseEdit.aspx.cs:59–120` — SaveCourse: teacher/owner/subject checks, draft insert or metadata update; replacement cleanup. |
| CRS-06 — My courses list | PASS | complete | `Teacher/MyCourses.aspx.cs:18–21` — Own teacher course list. |
| CRS-07 — Edit course | PASS | complete | `Teacher/CourseEdit.aspx.cs:59–120` — SaveCourse: teacher/owner/subject checks, draft insert or metadata update; replacement cleanup. |
| CRS-08 — Publish / unpublish | PASS | complete | `Teacher/MyCourses.aspx.cs:50–61` — Publication transaction invokes shared minimum-content check. |
| CRS-09 — Delete course | PASS | complete | `Helpers/DeleteHelper.cs:138–213` — DeleteContent: owner/admin, attempts/payment blocking, children-first transaction and post-commit files. |
| CRS-10 — Add topic | PASS | complete | `Teacher/CourseBuilder.aspx.cs:46–73` — Topic write/order requires owned course and matching topic; timestamp in transaction. |
| CRS-11 — Edit / reorder topic | PASS | complete | `Teacher/CourseBuilder.aspx.cs:46–73` — Topic write/order requires owned course and matching topic; timestamp in transaction. |
| CRS-12 — Delete topic | PASS | complete | `Helpers/DeleteHelper.cs:138–213` — DeleteContent: owner/admin, attempts/payment blocking, children-first transaction and post-commit files. |
| CRS-13 — View all courses | PASS | complete | `Admin/Courses.aspx.cs:40–71` — Admin Page_Load; all-course list; unpublish or shared guarded delete. |
| CRS-14 — Unpublish / delete any course | PASS | complete | `Admin/Courses.aspx.cs:40–71` — Admin Page_Load; all-course list; unpublish or shared guarded delete. |
| MAT-01 — Add text lesson | PASS | complete | `Teacher/MaterialEdit.aspx.cs:70–99` — Server type/text/file/YouTube/alt/publication validation; Save persists preview flag. |
| MAT-02 — Upload image / PDF | PASS | complete | `Teacher/MaterialEdit.aspx.cs:70–99` — Server type/text/file/YouTube/alt/publication validation; Save persists preview flag. |
| MAT-03 — Add video / audio | PASS | complete | `Teacher/MaterialEdit.aspx.cs:70–99` — Server type/text/file/YouTube/alt/publication validation; Save persists preview flag. |
| MAT-04 — Edit material | PASS | complete | `Teacher/MaterialEdit.aspx.cs:100–161` — Transactional owned material replacement with rollback-new-file cleanup and committed-old-file cleanup. |
| MAT-05 — Delete material | PASS | complete | `Helpers/DeleteHelper.cs:115–140` — Ownership; remove bookmarks/completions/material in transaction; unreferenced file cleanup. |
| MAT-06 — Mark as free preview | PASS | complete | `Teacher/MaterialEdit.aspx.cs:70–99` — Server type/text/file/YouTube/alt/publication validation; Save persists preview flag. |
| MAT-07 — View material | PASS | complete | `Helpers/MaterialHelper.cs:25–39` — Text/image/PDF/video/audio/YouTube renderers; protected PDF download. |
| MAT-08 — Download PDF | PASS | complete | `Helpers/MaterialHelper.cs:25–39` — Text/image/PDF/video/audio/YouTube renderers; protected PDF download. |
| MAT-09 — Mark complete | PASS | complete | `Member/Lesson.aspx.cs:51–76` — Rechecks learner/publication/enrolment; unique completion insert and redirect. |
| MAT-10 — Alt text on images | PASS | complete | `Teacher/MaterialEdit.aspx.cs:70–99` — Server type/text/file/YouTube/alt/publication validation; Save persists preview flag. |
| ENR-01 — Enrol | PASS | complete | `Helpers/PaymentHelper.cs:27–44` — Approved extension: free immediate enrolment; paid requires retained verified purchase. |
| ENR-02 — Leave course | PASS | complete | `Learner/MyCourses.aspx.cs:34–41` — Leave transaction removes only current learner Enrolment; retained learning data. |
| ENR-03 — My Courses | PASS | complete | `Learner/MyCourses.aspx:5` — Unavailable status shown, access actions conditional; retained result records. |
| ENR-04 — Progress % | PASS | complete | `Helpers/ProgressHelper.cs:23–31` — One shared published-item definition, empty=0, distinct completion, two-decimal AwayFromZero. |
| ENR-05 — Learner dashboard | PASS | complete | `Learner/Dashboard.aspx.cs:17–33` — Own enrolled cards call CourseHelper.Progress; five current-learner results. |
| ENR-06 — Enrolled learners list | PASS | complete | `Teacher/CourseLearners.aspx.cs:14–21` — Owner check; query projects FullName only, no email. |
| QZ-01 — Create quiz | PASS | complete | `Helpers/ActivityHelper.cs:35–82` — Activity settings/type/topic checks; structural locks; publish checks; timestamp transaction. |
| QZ-02 — Add question | PASS | complete | `Helpers/ActivityHelper.cs:70–106` — Owned quiz, no attempts; 2–6 distinct options, exactly one correct, marks/order; transactional write. |
| QZ-03 — Edit question | PASS | complete | `Helpers/ActivityHelper.cs:70–106` — Owned quiz, no attempts; 2–6 distinct options, exactly one correct, marks/order; transactional write. |
| QZ-04 — Delete question | PASS | complete | `Helpers/ActivityHelper.cs:70–106` — Owned quiz, no attempts; 2–6 distinct options, exactly one correct, marks/order; transactional write. |
| QZ-05 — Edit quiz settings | PASS | complete | `Helpers/ActivityHelper.cs:35–82` — Activity settings/type/topic checks; structural locks; publish checks; timestamp transaction. |
| QZ-06 — Publish / unpublish | PASS | complete | `Helpers/ActivityHelper.cs:35–82` — Activity settings/type/topic checks; structural locks; publish checks; timestamp transaction. |
| QZ-07 — Delete quiz | PASS | complete | `Helpers/DeleteHelper.cs:138–213` — DeleteContent: owner/admin, attempts/payment blocking, children-first transaction and post-commit files. |
| QZ-08 — Quiz intro | PASS | complete | `Member/Quiz.aspx.cs:27–32` — Intro question count/time/remaining attempts, Start disabled at limit. |
| QZ-09 — Take quiz | PASS | complete | `Member/Quiz.aspx.cs:43–63` — Renderer emits question, marks, option ID/text only; timer uses server start. |
| QZ-10 — Submit + auto-mark | PASS | complete | `Helpers/QuizHelper.cs:101–159` — Session token/time+30s/definition/limits, weighted marking, transactional Attempt/answers, preview branch. |
| QZ-11 — Result + review | PASS | complete | `Member/QuizResult.aspx.cs:15–27` — Own/owner/admin result authorization, published learner content, saved answer review. |
| QZ-12 — Attempt history | PASS | complete | `Helpers/ResultsHelper.cs:83–92` — Own learner history via Attempts plus latest/best/average scores; teacher scope separate. |
| QZ-13 — Quiz results | PASS | complete | `Teacher/Results.aspx.cs:39–58` — Owned filters; attempts/scores and type-appropriate SA/Scenario summaries. |
| SA-01 — Create self-assessment | PASS | complete | `Helpers/ActivityHelper.cs:35–82` — Activity settings/type/topic checks; structural locks; publish checks; timestamp transaction. |
| SA-02 — Add statement | PASS | complete | `Helpers/SelfAssessmentHelper.cs:71–94` — Owner/type/attempt lock, statement validation and publication integrity in transaction. |
| SA-03 — Edit statement | PASS | complete | `Helpers/SelfAssessmentHelper.cs:71–94` — Owner/type/attempt lock, statement validation and publication integrity in transaction. |
| SA-04 — Delete statement | PASS | complete | `Helpers/SelfAssessmentHelper.cs:71–94` — Owner/type/attempt lock, statement validation and publication integrity in transaction. |
| SA-05 — Settings / publish | PASS | complete | `Helpers/ActivityHelper.cs:35–82` — Activity settings/type/topic checks; structural locks; publish checks; timestamp transaction. |
| SA-06 — Delete self-assessment | PASS | complete | `Helpers/DeleteHelper.cs:138–213` — DeleteContent: owner/admin, attempts/payment blocking, children-first transaction and post-commit files. |
| SA-07 — Complete it | PASS | complete | `Helpers/SelfAssessmentHelper.cs:48–74` — Complete current statement set and integer1–5 validation; preview exits before NULL-score Attempt/response insert. |
| SA-08 — Feedback summary | PASS | complete | `Helpers/SelfAssessmentHelper.cs:23–37` — Raw-average thresholds and fixed feedback; separate two-decimal display. |
| SA-09 — Past self-assessments | PASS | complete | `Member/SelfAssessment.aspx.cs:105–117` — Current learner assessment history with averages, levels, timestamp and review. |
| SA-10 — Class summary | PASS | complete | `Helpers/SelfAssessmentHelper.cs:92–105` — Owned per-statement submitted response count/average across learner attempts. |
| DSC-01 — Create discussion | PASS | complete | `Helpers/ActivityHelper.cs:35–82` — Activity settings/type/topic checks; structural locks; publish checks; timestamp transaction. |
| DSC-02 — Edit discussion | PASS | complete | `Helpers/ActivityHelper.cs:35–82` — Activity settings/type/topic checks; structural locks; publish checks; timestamp transaction. |
| DSC-03 — Close / reopen | PASS | complete | `Helpers/ActivityHelper.cs:35–82` — Activity settings/type/topic checks; structural locks; publish checks; timestamp transaction. |
| DSC-04 — Delete discussion | PASS | complete | `Helpers/DeleteHelper.cs:138–213` — DeleteContent: owner/admin, attempts/payment blocking, children-first transaction and post-commit files. |
| DSC-05 — View thread | PASS | complete | `Member/Discussion.aspx.cs:28–33` — Joined author/thread rows, deterministic parent/reply ordering and empty state. |
| DSC-06 — Write post | PASS | complete | `Helpers/DiscussionHelper.cs:8–20` — Server permission check; same-activity top-level parent only; own update. |
| DSC-07 — Reply | PASS | complete | `Helpers/DiscussionHelper.cs:8–20` — Server permission check; same-activity top-level parent only; own update. |
| DSC-08 — Edit own post | PASS | complete | `Helpers/DiscussionHelper.cs:8–20` — Server permission check; same-activity top-level parent only; own update. |
| DSC-09 — Delete own post | PASS | complete | `Helpers/ActivityAccessHelper.cs:72–85` — DeletePost rechecks permission and transactionally deletes replies then parent; closed moderator policy. |
| DSC-10 — Remove post | PASS | complete | `Helpers/ActivityAccessHelper.cs:72–85` — DeletePost rechecks permission and transactionally deletes replies then parent; closed moderator policy. |
| DSC-11 — Remove any post | PASS | complete | `Helpers/ActivityAccessHelper.cs:72–85` — DeletePost rechecks permission and transactionally deletes replies then parent; closed moderator policy. |
| GAM-01 — Create game | PASS | complete | `Helpers/GameContentHelper.cs:29–57` — Valid template, owned topic, template/content locks, shared publish checks. |
| GAM-02 — Add content items | PASS | complete | `Helpers/GameContentHelper.cs:58–91` — Owned unlocked content; template-specific data, IDs, duplicates and publication minimums. |
| GAM-03 — Edit item | PASS | complete | `Helpers/GameContentHelper.cs:58–91` — Owned unlocked content; template-specific data, IDs, duplicates and publication minimums. |
| GAM-04 — Delete item | PASS | complete | `Helpers/GameContentHelper.cs:58–91` — Owned unlocked content; template-specific data, IDs, duplicates and publication minimums. |
| GAM-05 — Manage groups | PASS | complete | `Helpers/GameContentHelper.cs:85–113` — Sort-only owned/unlocked groups, max4, matching group IDs; referenced deletion blocked. |
| GAM-06 — Publish / unpublish | PASS | complete | `Helpers/GameContentHelper.cs:29–57` — Valid template, owned topic, template/content locks, shared publish checks. |
| GAM-07 — Delete game | PASS | complete | `Helpers/DeleteHelper.cs:138–213` — DeleteContent: owner/admin, attempts/payment blocking, children-first transaction and post-commit files. |
| GAM-08 — Play Matching | PASS | complete | `Scripts/games.js:46–57` — matching: plain JavaScript native accessible controls; no browser drag-and-drop. |
| GAM-09 — Play Memory | PASS | complete | `Scripts/games.js:82–93` — memory: plain JavaScript native accessible controls; no browser drag-and-drop. |
| GAM-10 — Play Word Scramble | PASS | complete | `Scripts/games.js:118–129` — scramble: plain JavaScript native accessible controls; no browser drag-and-drop. |
| GAM-11 — Play Sort into Groups | PASS | complete | `Scripts/games.js:140–151` — sort: plain JavaScript native accessible controls; no browser drag-and-drop. |
| GAM-12 — Save score | PASS | complete | `Helpers/GameHelper.cs:139–189` — DB-owned IDs; Matching/Scramble/Sort recalculation; approved Memory client moves plus server elapsed. |
| GAM-13 — Best score + history | PASS | complete | `Member/PlayGame.aspx.cs:88–95` — Current learner best score/history and UTC result review. |
| GAM-14 — Game results | PASS | complete | `Helpers/GameContentHelper.cs:110–121` — Owned Game results only, learner names and saved scores/time. |
| SIM-01 — Create scenario | PASS | complete | `Helpers/ScenarioHelper.cs:40–63` — Owned scenario metadata/settings with structural-order lock. |
| SIM-02 — Add step | PASS | complete | `Helpers/ScenarioHelper.cs:69–99` — Owned unlocked step, ending-only fields, validated image/alt replacement, timestamp. |
| SIM-03 — Edit step | PASS | complete | `Helpers/ScenarioHelper.cs:69–99` — Owned unlocked step, ending-only fields, validated image/alt replacement, timestamp. |
| SIM-04 — Delete step | PASS | complete | `Helpers/ScenarioHelper.cs:178–199` — Block attempts, current start and incoming choices; delete outgoing children transactionally. |
| SIM-05 — Add choice | PASS | complete | `Helpers/ScenarioHelper.cs:94–124` — Own scenario, locked structure, same-scenario source/target, no self-link/ending outgoing. |
| SIM-06 — Edit / delete choice | PASS | complete | `Helpers/ScenarioHelper.cs:94–124` — Own scenario, locked structure, same-scenario source/target, no self-link/ending outgoing. |
| SIM-07 — Set start step | PASS | complete | `Helpers/ScenarioHelper.cs:60–68` — Owner/attempt lock and start step membership in transaction. |
| SIM-08 — Check + publish | PASS | complete | `Helpers/ScenarioHelper.cs:146–172` — Start belongs, ending exists, non-ending choices, valid targets/outcome/feedback; cycles permitted. |
| SIM-09 — Delete scenario | PASS | complete | `Helpers/DeleteHelper.cs:138–213` — DeleteContent: owner/admin, attempts/payment blocking, children-first transaction and post-commit files. |
| SIM-10 — Play scenario | PASS | complete | `Helpers/ScenarioPlayHelper.cs:63–100` — Session current step/run/revision, database choice target, valid ending before one NULL-score Attempt. |
| SIM-11 — Save outcome | PASS | complete | `Helpers/ScenarioPlayHelper.cs:63–100` — Session current step/run/revision, database choice target, valid ending before one NULL-score Attempt. |
| SIM-12 — Outcome + restart | PASS | complete | `Member/Scenario.aspx.cs:74–84` — Own saved ending and feedback; restart starts new session run without insert. |
| SIM-13 — Outcome summary | PASS | complete | `Helpers/ScenarioHelper.cs:119–127` — Owner-only saved attempt counts by ending/outcome. |
| PRV-01 — Preview own content | PASS | complete | `Helpers/ActivityAccessHelper.cs:17–24` — Active current owner/admin preview accepts draft; normal learner requires publication/enrolment. |
| PRV-02 — Preview saves nothing | PASS | complete | `Helpers/SelfAssessmentHelper.cs:64–68` — Representative explicit no-write branch; all six page branches cross-referenced in access/security tables. |
| RES-01 — My Results | PASS | complete | `Helpers/ResultsHelper.cs:41–70` — LearnerID=current user; four Attempt types only, appropriate score/confidence/outcome summary; filters/paging in MyResults. |
| RES-02 — Results by activity | PASS | complete | `Teacher/Results.aspx.cs:39–58` — Owned filters; attempts/scores and type-appropriate SA/Scenario summaries. |
| RES-03 — Teacher dashboard | PASS | complete | `Teacher/Dashboard.aspx.cs:14–17` — Own course count, distinct enrolled learners, five owned recent attempts. |
| RES-04 — Admin statistics | PASS | complete | `Admin/Dashboard.aspx.cs:20–30` — Real role/subject/pending/attempt counts, Admin-only Page_Load. |
| ADM-01 — Admin login | PASS | complete | `Account/AdminLogin.aspx.cs:11` — Approved custom Admin portal reuses shared authentication, requires Admin role. |
| ADM-02 — List users | PASS | complete | `Admin/Users.aspx.cs:47–84` — Admin page; non-admin predicates for status/unlock; delete helper; filtered/paged users. |
| ADM-03 — Create user | PASS | complete | `Admin/UserEdit.aspx.cs:66–94` — Admin-only create Learner/Teacher with forced-change flag; edit cannot change role or Admin rows. |
| ADM-04 — Edit user | PASS | complete | `Admin/UserEdit.aspx.cs:66–94` — Admin-only create Learner/Teacher with forced-change flag; edit cannot change role or Admin rows. |
| ADM-05 — Activate / deactivate | PASS | complete | `Admin/Users.aspx.cs:47–84` — Admin page; non-admin predicates for status/unlock; delete helper; filtered/paged users. |
| ADM-06 — Reset password | PASS | complete | `Admin/UserEdit.aspx.cs:92–108` — Validated temporary password hash and MustChangePassword=1, excludes Admin. |
| ADM-07 — Delete user | PASS | complete | `Helpers/DeleteHelper.cs:71–105` — Admin only, block owned courses/payment history/Admin; children-first transaction; contact author NULL. |
| ADM-08 — Pending applications | PASS | complete | `Admin/TeacherApplications.aspx.cs:13–43` — Pending teacher reasons; Approve/Reject commands constrained by role/status with PRG. |
| ADM-09 — Approve teacher | PASS | complete | `Admin/TeacherApplications.aspx.cs:13–43` — Pending teacher reasons; Approve/Reject commands constrained by role/status with PRG. |
| ADM-10 — Reject teacher | PASS | complete | `Admin/TeacherApplications.aspx.cs:13–43` — Pending teacher reasons; Approve/Reject commands constrained by role/status with PRG. |
| ADM-11 — Manage any activity | PASS | complete | `Admin/Activities.aspx.cs:27–67` — Admin oversight unpublish/guarded delete; authored course timestamp update. |
| SYS-01 — Master layout | PASS | complete | `Site.Master.cs:30–87` — Shared role-specific navigation/account/footer; one master page and shared messages. |
| SYS-02 — Role-based nav bar | PASS | complete | `Site.Master.cs:30–87` — Shared role-specific navigation/account/footer; one master page and shared messages. |
| SYS-03 — Access checks | PASS | partial | `Helpers/AccessHelper.cs:63–80` — RequireRole plus owner/enrolment/material guards; page-specific matrix below. |
| SYS-04 — Access-denied page | PASS | complete | `AccessDenied.aspx:3–7` — Friendly denial page with ways out. |
| SYS-05 — Friendly error pages | PARTIAL | complete | `Web.config:24–27` — VIOLATION: customErrors Off exposes technical errors; friendly pages exist but are not enforced. |
| SYS-06 — Success / error messages | PASS | complete | `Site.Master.cs:86–94` — Encoded common success/error area with status/alert semantics. |
| SYS-07 — Empty-state messages | PASS | complete | `Teacher/CourseBuilder.aspx:33` — Representative empty material/activity tables; source inventory reviewed other list empty states. |
| SYS-08 — File upload handling | PASS | complete | `Helpers/UploadHelper.cs:9–41` — Server extension/size checks; Save GUID naming; validated path and cleanup. |
| SYS-09 — Database connection | PASS | complete | `Helpers/DatabaseHelper.cs:10–13` — Named Web.config connection; ADO.NET helper. |
| SYS-10 — Responsive CSS | PASS | complete | `Styles/site.css:144–147` — Responsive shared CSS; master internal and Home inline examples retained. |
| SYS-11 — Delete confirmation | PASS | complete | `Teacher/MyCourses.aspx:17` — Postback Delete/Leave controls confirm; postback scans reviewed all destructive controls. |
| SYS-12 — Demo data | PASS | complete | `Database/CreateDatabase.sql:547–560` — Seed subjects and courses; subsequent material/activity seeds supply teaching content. Script not executed by audit. |
| SYS-13 — Breadcrumb | PASS | partial | `Helpers/BreadcrumbHelper.cs:58–69` — Encoded breadcrumb renderer plus database-specific material/activity/course/attempt trails. |
| SYS-14 — Page necessities | PARTIAL | complete | `Site.Master:29–34` — Brand/title/footer exist; actual contact details absent (approved Q31 placeholder). |
| SYS-15 — Cancel button | PASS | complete | `Teacher/CourseEdit.aspx:28` — Representative cancel; page source review covers edit/create/play form exits. |
| SYS-16 — Accessibility | PARTIAL | complete | `Site.Master.cs:116–119` — Shared table headers, labels/alt/focus; checkout external form falls outside main (S03). Shared controls remain accessible in source; payment landmark gap S03, runtime visual checks blocked. |
| SYS-17 — Folder access rules | PASS | complete | `Web.config:29–61` — Role folder allow/deny rules for Learner/Teacher/Admin; Member requires authentication. |
| SYS-18 — Database build script | PASS | complete | `Database/CreateDatabase.sql:547–560` — Seed subjects and courses; subsequent material/activity seeds supply teaching content. Script not executed by audit. |
| SYS-19 — Deletes in code | PASS | partial | `Helpers/DeleteHelper.cs:74–77` — Transactional dependent deletes; standalone steps in ScenarioHelper.DeleteStep. |
| SYS-20 — Role setup | PASS | complete | `Global.asax.cs:21–25` — PostAuthenticate attaches ticket role before URL authorization. |
| CHT-01 — Teacher results chart (O1) | PASS | complete | `Helpers/ChartHelper.cs:31–54` — Groups existing owned Quiz/Game results into five score bins; no extra report query. |
| CHT-02 — Admin statistics charts (O1) | PASS | complete | `Admin/Dashboard.aspx.cs:22–28` — ChartHelper reuses real role and subject data; plain Scripts/charts.js. |
| LCK-01 — Count failed logins (O2) | PASS | complete | `Helpers/AccountSecurityHelper.cs:37–49` — Locked row failure count; five failures15min, expiry allowed, successful reset. |
| LCK-02 — Lock after 5 failures (O2) | PASS | complete | `Helpers/AccountSecurityHelper.cs:37–49` — Locked row failure count; five failures15min, expiry allowed, successful reset. |
| LCK-03 — Admin unlock (O2) | PASS | complete | `Admin/Users.aspx.cs:47–84` — Admin page; non-admin predicates for status/unlock; delete helper; filtered/paged users. |
| FPC-01 — Flag password change (O3) | PASS | complete | `Admin/UserEdit.aspx.cs:66–94` — Admin-only create Learner/Teacher with forced-change flag; edit cannot change role or Admin rows. |
| FPC-02 — Force change (O3) | PASS | complete | `Member/ChangePassword.aspx.cs:20–45` — Correct current password, different validated new password; compare-and-update hash/flag atomically. |
| MAP-01 — Site map page (O4) | PASS | complete | `SiteMap.aspx.cs:11–27` — Public plus own-role links only; IDs reached through authorized lists. |
| CAP-01 — CAPTCHA (O12) | PASS | complete | `Helpers/CaptchaHelper.cs:8–27` — Session arithmetic question; Register/Contact use independent lifecycle-controlled keys. |
| SSL-01 — HTTPS (O13) | PASS | complete | `Global.asax.cs:9–18` — Fixed configured HTTPS origin preserving path/query; secure cookies in Web.config. |
| REV-01 — Write review (O5) | PASS | complete | `Helpers/ReviewHelper.cs:23–37` — Current enrolled/published learner, integer1–5/comment length; unique upsert. |
| REV-02 — Edit own review (O5) | PASS | complete | `Helpers/ReviewHelper.cs:23–37` — Current enrolled/published learner, integer1–5/comment length; unique upsert. |
| REV-03 — Delete own review (O5) | PASS | complete | `Helpers/ReviewHelper.cs:37–51` — Author+course constrained delete or explicit Admin role; transaction; teacher denied. |
| REV-04 — Show reviews + average (O5) | PASS | complete | `CourseDetails.aspx.cs:47–64` — Encoded reviews and average; review editor only eligible enrolled learner. |
| REV-05 — Average on course cards (O5) | PASS | complete | `Helpers/CourseHelper.cs:44–46` — Course cards use shared review average. |
| REV-06 — Admin remove review (O5) | PASS | complete | `Helpers/ReviewHelper.cs:37–51` — Author+course constrained delete or explicit Admin role; transaction; teacher denied. |
| CON-01 — Send contact message (O6) | PASS | complete | `Contact.aspx.cs:37–49` — Server validated independent CAPTCHA, user identity, send token, parameterized insert and PRG. |
| CON-02 — Admin inbox (O6) | PASS | complete | `Admin/Messages.aspx.cs:12–45` — Admin inbox/read; explicit POST mark-read; confirmed transactional delete; paged list. |
| CON-03 — Read / mark read (O6) | PASS | complete | `Admin/Messages.aspx.cs:12–45` — Admin inbox/read; explicit POST mark-read; confirmed transactional delete; paged list. |
| CON-04 — Delete message (O6) | PASS | complete | `Admin/Messages.aspx.cs:12–45` — Admin inbox/read; explicit POST mark-read; confirmed transactional delete; paged list. |
| BMK-01 — Add bookmark (O7) | PASS | complete | `Helpers/BookmarkHelper.cs:12–26` — Current active enrolled learner, published material/course; idempotent own add/remove. |
| BMK-02 — Remove bookmark (O7) | PASS | complete | `Helpers/BookmarkHelper.cs:12–26` — Current active enrolled learner, published material/course; idempotent own add/remove. |
| BMK-03 — My Bookmarks page (O7) | PASS | complete | `Helpers/BookmarkHelper.cs:25–29` — Only current learner bookmarks; availability recalculated from publication and enrolment. |
| CER-01 — Certificate unlock (O8) | PASS | complete | `Learner/Certificate.aspx.cs:16–22` — Current learner, published/enrolled, shared100m, UTC print date; print.css presentation. |
| CER-02 — Printable certificate (O8) | PASS | complete | `Learner/Certificate.aspx.cs:16–22` — Current learner, published/enrolled, shared100m, UTC print date; print.css presentation. |
| FAQ-01 — Add FAQ (O9) | PASS | complete | `Admin/FAQ.aspx.cs:18–47` — Admin validation/audience/order/save token; confirmed transactional deletion; deterministic order. |
| FAQ-02 — Edit / reorder FAQ (O9) | PASS | complete | `Admin/FAQ.aspx.cs:18–47` — Admin validation/audience/order/save token; confirmed transactional deletion; deterministic order. |
| FAQ-03 — Delete FAQ (O9) | PASS | complete | `Admin/FAQ.aspx.cs:18–47` — Admin validation/audience/order/save token; confirmed transactional deletion; deterministic order. |
| FAQ-04 — Help reads FAQ (O9) | PASS | complete | `Help.aspx.cs:17–25` — Page_Load: audience-filtered FAQ, encoded details/summary; static guidance retained. |
| KEY-01 — Keyboard shortcuts (O11) | PASS | complete | `Scripts/shortcuts.js:4–16` — Alt H/C/D/Q, authorized destination, typing/composition/repeat/modifier exclusions. |
| DRK-01 — Theme toggle (O10) | INTENTIONALLY DEFERRED | unchecked | `docs/PHASE15-CUSTOM-SCOPE.md:9` — Phase14 skipped by explicit team decision; no implementation expected. INTENTIONALLY DEFERRED — Phase14 skipped by team decision. |
| DRK-02 — Remember theme (O10) | INTENTIONALLY DEFERRED | unchecked | `docs/PHASE15-CUSTOM-SCOPE.md:9` — Phase14 skipped by explicit team decision; no implementation expected. INTENTIONALLY DEFERRED — Phase14 skipped by team decision. |
| SND-01 — Game sounds (O14) | INTENTIONALLY DEFERRED | unchecked | `docs/PHASE15-CUSTOM-SCOPE.md:9` — Phase14 skipped by explicit team decision; no implementation expected. INTENTIONALLY DEFERRED — Phase14 skipped by team decision. |
| SND-02 — Mute switch (O14) | INTENTIONALLY DEFERRED | unchecked | `docs/PHASE15-CUSTOM-SCOPE.md:9` — Phase14 skipped by explicit team decision; no implementation expected. INTENTIONALLY DEFERRED — Phase14 skipped by team decision. |

## Blueprint Section 17 — each requirement
| Requirement | Status | Evidence / explanation |
|---|---|---|
| R01 | PARTIAL | `Default.aspx.cs:15–18` — Page_Load: published subject counts; six newest published course cards. Registered/visitor paths implemented; real public assets/contact still partial. |
| R02 | PASS | `Helpers/QuizHelper.cs:101–159` — Session token/time+30s/definition/limits, weighted marking, transactional Attempt/answers, preview branch. All five activity types and four game templates implemented; preview no-write paths inspected. |
| R03 | PASS | `Helpers/DatabaseHelper.cs:10–13` — Named Web.config connection; ADO.NET helper. ADO.NET named LocalDB connection and parameter binding exist; current runtime connection blocked. |
| R04 | PASS | `Helpers/GameHelper.cs:139–189` — DB-owned IDs; Matching/Scramble/Sort recalculation; approved Memory client moves plus server elapsed. Client interaction/validators plus authoritative server validation/marking. |
| R05 | PARTIAL | `Helpers/MaterialHelper.cs:25–39` — Text/image/PDF/video/audio/YouTube renderers; protected PDF download. All lesson multimedia renderers and scenario images; Home intro/poster absent under Q31. |
| R06 | PARTIAL | `Site.Master:29–34` — Brand/title/footer exist; actual contact details absent (approved Q31 placeholder). Shared visual system implemented; footer content and checkout landmark gaps. |
| R07 | PASS | `Site.Master.cs:30–87` — Shared role-specific navigation/account/footer; one master page and shared messages. Role navigation and terminal exits exist. |
| R08 | PASS | `SiteMap.aspx.cs:11–27` — Public plus own-role links only; IDs reached through authorized lists. Role-aware SiteMap/breadcrumbs and interlinked content pages. |
| R09 | PASS | `Admin/Dashboard.aspx.cs:22–28` — ChartHelper reuses real role and subject data; plain Scripts/charts.js. All required semantic/media elements now have actual source evidence, including canvas. |
| R10 | PASS | `Styles/site.css:144–147` — Responsive shared CSS; master internal and Home inline examples retained. External/internal/inline CSS and print CSS; O10 theme toggle deliberately deferred. |
| R11 | PARTIAL | `Database/CreateDatabase.sql:547–560` — Seed subjects and courses; subsequent material/activity seeds supply teaching content. Script not executed by audit. Three-subject teaching seed exists; team editorial sign-off and real public assets not established. |
| R12 | PASS | `Account/Register.aspx.cs:47–73` — Registration validation, hash, Active/Pending role status and success redirect. Representative parameterized INSERT plus all requested create screens. |
| R13 | PASS | `Helpers/ResultsHelper.cs:41–70` — LearnerID=current user; four Attempt types only, appropriate score/confidence/outcome summary; filters/paging in MyResults. Scoped joined SELECTs and display pages. |
| R14 | PASS | `Teacher/CourseEdit.aspx.cs:59–120` — SaveCourse: teacher/owner/subject checks, draft insert or metadata update; replacement cleanup. Validated ownership-scoped UPDATEs. |
| R15 | PASS | `Helpers/DeleteHelper.cs:74–77` — Transactional dependent deletes; standalone steps in ScenarioHelper.DeleteStep. Transaction deletes, locks, children-first cleanup and confirmations. |
| R16 | PASS | `Account/Register.aspx.cs:47–73` — Registration validation, hash, Active/Pending role status and success redirect. Learner registration/teacher application with CAPTCHA and validation. |
| R17 | PASS | `Learner/Dashboard.aspx.cs:17–33` — Own enrolled cards call CourseHelper.Progress; five current-learner results. Learner/teacher/member pages and implemented TierB integrations. |
| R18 | PASS | `Admin/UserEdit.aspx.cs:66–94` — Admin-only create Learner/Teacher with forced-change flag; edit cannot change role or Admin rows. Admin CRUD, oversight, applications, inbox/FAQ and statistics. |
| R19 | PASS | `Helpers/CaptchaHelper.cs:8–27` — Session arithmetic question; Register/Contact use independent lifecycle-controlled keys. ASP.NET validators and server guards; six validator types evidenced separately. |
| R20 | PASS | `Web.config:29–61` — Role folder allow/deny rules for Learner/Teacher/Admin; Member requires authentication. 58 page trios, .csproj includes and role folders; known naming observations below. |
| R21 | PASS | `Database/CreateDatabase.sql:547–560` — Seed subjects and courses; subsequent material/activity seeds supply teaching content. Script not executed by audit. Original23 tables plus separately approved Payment;145 columns/37 FKs/62 CHECK declarations; live state unverified. |
| R22 | PARTIAL | `Site.Master.cs:116–119` — Shared table headers, labels/alt/focus; checkout external form falls outside main (S03). Semantic labels/focus/headers and native buttons; checkout landmark issue and no fresh visual run. |
| D06 | MISSING | `Database/CreateDatabase.sql:547–560` — Seed subjects and courses; subsequent material/activity seeds supply teaching content. Script not executed by audit. Final use-case/flowchart report artefacts not present in workspace; Blueprint textual flows are not finished diagrams. |
| D07 | MISSING | `Database/CreateDatabase.sql:547–560` — Seed subjects and courses; subsequent material/activity seeds supply teaching content. Script not executed by audit. Final ERD/wireframe/navigation diagrams not present; screenshots/SQL do not substitute for all requested report diagrams. |
| D08 | PARTIAL | `Helpers/DeleteHelper.cs:74–77` — Transactional dependent deletes; standalone steps in ScenarioHelper.DeleteStep. EVIDENCE.md supplies exact code references; team still needs final presentation/report explanations. |

## Section 18 — all 17 rules
| Rule | Status | Evidence / explanation |
|---|---|---|
| 1 | PARTIAL | `Database/CreateDatabase.sql:547–560` — Seed subjects and courses; subsequent material/activity seeds supply teaching content. Script not executed by audit. LearningSystem.csproj declares Web Application/.NET4.8. Other three workstations cannot be established from one checkout. |
| 2 | PASS | `Helpers/QuizHelper.cs:101–159` — Session token/time+30s/definition/limits, weighted marking, transactional Attempt/answers, preview branch. Begin stores session only; SubmitRun inserts after validated final submission. |
| 3 | PASS | `Helpers/DeleteHelper.cs:138–213` — DeleteContent: owner/admin, attempts/payment blocking, children-first transaction and post-commit files. Any saved attempt blocks course/topic/activity delete; payment history adds approved retention block. |
| 4 | PASS | `Helpers/ActivityHelper.cs:70–106` — Owned quiz, no attempts; 2–6 distinct options, exactly one correct, marks/order; transactional write. SaveQuestion/SaveStatement/RequireGame/RequireOwned lock structural content; Title/Description editable. |
| 5 | PASS | `Teacher/MaterialEdit.aspx.cs:100–161` — Transactional owned material replacement with rollback-new-file cleanup and committed-old-file cleanup. Validated replacement saved first; transaction reference update; failed write cleans new file; committed cleanup retains referenced files/logs failure per Q29/Q30. |
| 6 | PASS | `Scripts/games.js:46–57` — matching: plain JavaScript native accessible controls; no browser drag-and-drop. Matching and Sort use native click buttons; Enter/Space/touch share same interaction. |
| 7 | PASS | `Helpers/ProgressHelper.cs:23–31` — One shared published-item definition, empty=0, distinct completion, two-decimal AwayFromZero. PublishedItems ORDER BY TopicOrder,TopicID,ItemKind,SortOrder,ItemID;0 materials before1 activities. |
| 8 | PASS | `Teacher/MyCourses.aspx.cs:50–61` — Publication transaction invokes shared minimum-content check. PublishHelper.CheckCourse EXISTS published material OR activity under a topic. |
| 9 | PASS | `Learner/MyCourses.aspx:5` — Unavailable status shown, access actions conditional; retained result records. Unavailable courses remain listed; MyResults queries retained attempts independent of current enrolment. |
| 10 | PASS | `Helpers/ProgressHelper.cs:23–31` — One shared published-item definition, empty=0, distinct completion, two-decimal AwayFromZero. EXISTS counts each published item once. All submitted activity attempts count regardless of outcome; surviving posts/replies count; no stored percentage. |
| 11 | PASS | `Helpers/QuizHelper.cs:101–159` — Session token/time+30s/definition/limits, weighted marking, transactional Attempt/answers, preview branch. PRG after writes; quiz/game run completion and SA/discussion/builder tokens prevent repeated session submissions; unique keys/idempotent operations elsewhere. No cross-session quiz idempotency promised. |
| 12 | PASS | `Admin/Users.aspx.cs:47–84` — Admin page; non-admin predicates for status/unlock; delete helper; filtered/paged users. Disabled Admin row controls plus server Role predicates; temporary Admin lock expires and is not permanent. |
| 13 | PASS | `Default.aspx.cs:15–18` — Page_Load: published subject counts; six newest published course cards. TOP(6) WHERE Published ORDER BY CreatedDate DESC,CourseID DESC. |
| 14 | PASS | `Teacher/CourseLearners.aspx.cs:14–21` — Owner check; query projects FullName only, no email. Teacher learner/result sources use FullName only. User email available only own profile/Admin, not teacher lists. |
| 15 | PASS | `Helpers/GameHelper.cs:139–189` — DB-owned IDs; Matching/Scramble/Sort recalculation; approved Memory client moves plus server elapsed. Client game data allowed; Matching/Scramble/Sort marked using database IDs. Memory client move count limitation expressly approved Q33. |
| 16 | PASS | `Courses.aspx.cs:40–46` — BindCourses: published-only title/description search, subject filter, parameterized paging. All catalogue/search predicates include Published. |
| 17 | PARTIAL | `Database/CreateDatabase.sql:547–560` — Seed subjects and courses; subsequent material/activity seeds supply teaching content. Script not executed by audit. Git checkout exists (fc3b612); .gitignore excludes build/DB/local settings; git ls-files found no MDF/LDF/bin/obj/local payment settings. Team-wide sharing/history practices cannot be proved. |

## Authorization matrix — page GET and operations
V=visitor; L=active learner; T=active teacher; A=active admin. Every protected page first passes folder authorization and SiteMaster.OnInit active-role check. Rows below add ID/publication checks and mutation rules. Wrong IDs/roles are denied server-side, not merely hidden. All outcomes are source-reviewed; runtime attempts were blocked. Read-only GETs have no content mutation unless explicitly noted for payment callbacks. QuizResult is an own historical result, not an unrestricted lesson; MyResults retains summaries after leaving.
| Page (58 total) | Allowed roles | GET/load evidence | POST/mutation review |
|---|---|---|---|
| About.aspx | V/L/T/A | `About.aspx.cs:2–2` Published listing or role-appropriate public data; Help/SiteMap active-account recheck. | No persistent writes; search/filter only. |
| AccessDenied.aspx | V/L/T/A | `AccessDenied.aspx.cs:9–13` Friendly terminal routes; forced-password exceptions. | No writes; Home/dashboard exits. M01 affects uncaught-error routing. |
| Account/AdminLogin.aspx | V | `Account/AdminLogin.aspx.cs:6–10` Authenticated callers redirect; credentials/status/portal-role checks shared. | Register role allowlist Learner/Teacher; password/status/hash/CAPTCHA. Login changes lock count/ticket only after checks. |
| Account/Login.aspx | V | `Account/Login.aspx.cs:7–11` Authenticated callers redirect; credentials/status/portal-role checks shared. | Register role allowlist Learner/Teacher; password/status/hash/CAPTCHA. Login changes lock count/ticket only after checks. |
| Account/Logout.aspx | V/L/T/A | `Account/Logout.aspx.cs:8–12` Logout clears caller only. | Own ticket/session cleared; Home redirect. |
| Account/Register.aspx | V | `Account/Register.aspx.cs:12–16` Authenticated callers redirect; credentials/status/portal-role checks shared. | Register role allowlist Learner/Teacher; password/status/hash/CAPTCHA. Login changes lock count/ticket only after checks. |
| Account/StudentLogin.aspx | V | `Account/StudentLogin.aspx.cs:6–10` Authenticated callers redirect; credentials/status/portal-role checks shared. | Register role allowlist Learner/Teacher; password/status/hash/CAPTCHA. Login changes lock count/ticket only after checks. |
| Account/TeacherLogin.aspx | V | `Account/TeacherLogin.aspx.cs:6–10` Authenticated callers redirect; credentials/status/portal-role checks shared. | Register role allowlist Learner/Teacher; password/status/hash/CAPTCHA. Login changes lock count/ticket only after checks. |
| Admin/Activities.aspx | A | `Admin/Activities.aspx.cs:13–17` Admin-only all-content oversight. | Parameterized IDs; subject-in-use/attempt/payment locks; unpublish allowed; shared DeleteHelper; ReviewHelper.Delete(admin=true) explicitly rechecks Admin. |
| Admin/Courses.aspx | A | `Admin/Courses.aspx.cs:13–17` Admin-only all-content oversight. | Parameterized IDs; subject-in-use/attempt/payment locks; unpublish allowed; shared DeleteHelper; ReviewHelper.Delete(admin=true) explicitly rechecks Admin. |
| Admin/Dashboard.aspx | A | `Admin/Dashboard.aspx.cs:13–17` RequireRole(Admin) every load; payments History(true) repeats guard. | Read/statistics/filter/paging only; no manual mark-paid operation. |
| Admin/FAQ.aspx | A | `Admin/FAQ.aspx.cs:11–15` Role guard each request, IDs parsed and existence read before display. | Mark-read POST; validated FAQ audience/order/text; confirmed transaction deletes; sender data only Admin. |
| Admin/Messages.aspx | A | `Admin/Messages.aspx.cs:12–16` Role guard each request, IDs parsed and existence read before display. | Mark-read POST; validated FAQ audience/order/text; confirmed transaction deletes; sender data only Admin. |
| Admin/Payments.aspx | A | `Admin/Payments.aspx.cs:9–13` RequireRole(Admin) every load; payments History(true) repeats guard. | Read/statistics/filter/paging only; no manual mark-paid operation. |
| Admin/Subjects.aspx | A | `Admin/Subjects.aspx.cs:13–17` Admin-only all-content oversight. | Parameterized IDs; subject-in-use/attempt/payment locks; unpublish allowed; shared DeleteHelper; ReviewHelper.Delete(admin=true) explicitly rechecks Admin. |
| Admin/TeacherApplications.aspx | A | `Admin/TeacherApplications.aspx.cs:13–17` Role guard on GET and postback before events; target IDs parameterized. | Admin targets protected; no role changes; pending-only approval/rejection; reset/flag, eligible unlock; DeleteUser checks Admin and dependencies transactionally. |
| Admin/UserEdit.aspx | A | `Admin/UserEdit.aspx.cs:15–19` Role guard on GET and postback before events; target IDs parameterized. | Admin targets protected; no role changes; pending-only approval/rejection; reset/flag, eligible unlock; DeleteUser checks Admin and dependencies transactionally. |
| Admin/Users.aspx | A | `Admin/Users.aspx.cs:13–17` Role guard on GET and postback before events; target IDs parameterized. | Admin targets protected; no role changes; pending-only approval/rejection; reset/flag, eligible unlock; DeleteUser checks Admin and dependencies transactionally. |
| Contact.aspx | V/L/T/A | `Contact.aspx.cs:12–16` Authenticated callers active; own identity-derived optional UserID. | Validated fields, separate CAPTCHA, one-use send token, parameterized INSERT, PRG. |
| CourseDetails.aspx | V/L/T/A | `CourseDetails.aspx.cs:12–16` Published course; learner editor requires enrolment. | Enrol→PaymentHelper.Enrol; review Save/Delete recheck current learner, Published/enrolled/own record; Admin moderation is separate. |
| Courses.aspx | V/L/T/A | `Courses.aspx.cs:13–17` Published listing or role-appropriate public data; Help/SiteMap active-account recheck. | No persistent writes; search/filter only. |
| Default.aspx | V/L/T/A | `Default.aspx.cs:10–14` Published listing or role-appropriate public data; Help/SiteMap active-account recheck. | No persistent writes; search/filter only. |
| Error.aspx | V/L/T/A | `Error.aspx.cs:9–13` Friendly terminal routes; forced-password exceptions. | No writes; Home/dashboard exits. M01 affects uncaught-error routing. |
| Help.aspx | V/L/T/A | `Help.aspx.cs:11–15` Published listing or role-appropriate public data; Help/SiteMap active-account recheck. | No persistent writes; search/filter only. |
| Learner/Certificate.aspx | L | `Learner/Certificate.aspx.cs:10–14` Current learner, Published course, enrolled, shared progress exactly100m. | No record or historical date invented; print only. |
| Learner/Checkout.aspx | L | `Learner/Checkout.aspx.cs:10–14` Published paid course; PaymentID must belong to learner AND course; existing enrolled redirect. | Enrol recovery or CreatePending validates DB price/state; one-use token; no posted amount. |
| Learner/CourseHome.aspx | L | `Learner/CourseHome.aspx.cs:10–14` Published course plus current enrolment. | Read; shared progress only. |
| Learner/Dashboard.aspx | L | `Learner/Dashboard.aspx.cs:12–16` Current learner parameter; result course/activity filter ownership; payments History(false). | Read/filter/paging only; no LastUpdated change. |
| Learner/MyBookmarks.aspx | L | `Learner/MyBookmarks.aspx.cs:10–14` Current learner rows; unavailable links hidden. | BookmarkHelper.Set rechecks active enrolment and both publication states; own remove only. |
| Learner/MyCourses.aspx | L | `Learner/MyCourses.aspx.cs:11–15` Only current learner Enrolment. | Leave deletes own Enrolment only, transaction; retained records unchanged. |
| Learner/MyPayments.aspx | L | `Learner/MyPayments.aspx.cs:9–13` Current learner parameter; result course/activity filter ownership; payments History(false). | Read/filter/paging only; no LastUpdated change. |
| Learner/MyResults.aspx | L | `Learner/MyResults.aspx.cs:12–16` Current learner parameter; result course/activity filter ownership; payments History(false). | Read/filter/paging only; no LastUpdated change. |
| Member/ChangePassword.aspx | L/T/A | `Member/ChangePassword.aspx.cs:10–14` Current authenticated UserID, no browser UserID authority. | Unique email; active own account UPDATE. Password current-hash compare; flag cleared only successful valid different password. |
| Member/Discussion.aspx | L enrolled/T-owner/A | `Member/Discussion.aspx.cs:16–20` Published normal discussion; draft only owner/admin preview. | Own edits/deletes; one reply level; closed author mutations denied, owner/admin removal retained; preview commands rejected. |
| Member/Lesson.aspx | L normal; T-owner/A preview | `Member/Lesson.aspx.cs:12–16` Material/course Published+enrolled normally; draft owner/admin preview; learner preview forbidden. | MarkComplete and bookmark recheck access/publication and reject preview; unique/idempotent own records. |
| Member/PlayGame.aspx | L normal; T-owner/A preview | `Member/PlayGame.aspx.cs:16–20` ActivityHelper.Require validates ID/type/publication and ActivityAccess; attemptId constrained to own learner/activity where accepted. | Helpers recheck access inside transaction; quiz/game run tokens, SA complete ratings, scenario session step+choice+revision. Preview branches never insert. |
| Member/Profile.aspx | L/T/A | `Member/Profile.aspx.cs:11–15` Current authenticated UserID, no browser UserID authority. | Unique email; active own account UPDATE. Password current-hash compare; flag cleared only successful valid different password. |
| Member/Quiz.aspx | L normal; T-owner/A preview | `Member/Quiz.aspx.cs:16–20` ActivityHelper.Require validates ID/type/publication and ActivityAccess; attemptId constrained to own learner/activity where accepted. | Helpers recheck access inside transaction; quiz/game run tokens, SA complete ratings, scenario session step+choice+revision. Preview branches never insert. |
| Member/QuizResult.aspx | L-own/T-owner/A | `Member/QuizResult.aspx.cs:11–15` CanViewAttempt authenticates saved AttemptID scope; type Quiz; learner unpublished content NotFound. | Read only, encoded review after saved submission. |
| Member/Scenario.aspx | L normal; T-owner/A preview | `Member/Scenario.aspx.cs:12–16` ActivityHelper.Require validates ID/type/publication and ActivityAccess; attemptId constrained to own learner/activity where accepted. | Helpers recheck access inside transaction; quiz/game run tokens, SA complete ratings, scenario session step+choice+revision. Preview branches never insert. |
| Member/SelfAssessment.aspx | L normal; T-owner/A preview | `Member/SelfAssessment.aspx.cs:27–31` ActivityHelper.Require validates ID/type/publication and ActivityAccess; attemptId constrained to own learner/activity where accepted. | Helpers recheck access inside transaction; quiz/game run tokens, SA complete ratings, scenario session step+choice+revision. Preview branches never insert. |
| NotFound.aspx | V/L/T/A | `NotFound.aspx.cs:9–13` Friendly terminal routes; forced-password exceptions. | No writes; Home/dashboard exits. M01 affects uncaught-error routing. |
| Payment/EsewaFailure.aspx | L | `Payment/EsewaFailure.aspx.cs:9–13` Current active learner; signed UUID/payment owner; failure Find UUID owner. | Success GET provider callback intentionally verifies HMAC+remote status before atomic completion. Failure verifies non-success only; never enrols. |
| Payment/EsewaSuccess.aspx | L | `Payment/EsewaSuccess.aspx.cs:9–13` Current active learner; signed UUID/payment owner; failure Find UUID owner. | Success GET provider callback intentionally verifies HMAC+remote status before atomic completion. Failure verifies non-success only; never enrols. |
| Preview.aspx | V/L/T/A | `Preview.aspx.cs:10–14` Published material AND course AND IsPreview. | No writes. |
| SiteMap.aspx | V/L/T/A | `SiteMap.aspx.cs:11–15` Published listing or role-appropriate public data; Help/SiteMap active-account recheck. | No persistent writes; search/filter only. |
| Teacher/CourseBuilder.aspx | T-owner | `Teacher/CourseBuilder.aspx.cs:13–17` CourseID owned on every Page_Load. | TopicID/MaterialID belong to course; helper transaction ownership; confirmed delete with locks/cleanup. |
| Teacher/CourseEdit.aspx | T-owner/new | `Teacher/CourseEdit.aspx.cs:13–17` Existing CourseID owned; new uses current teacher. | Save rechecks teacher active/owner/SubjectID; file and NPR server validation, transaction. |
| Teacher/CourseLearners.aspx | T-owner | `Teacher/CourseLearners.aspx.cs:9–13` Every supplied course/activity filter checks owner; learners query also TeacherID predicate. | Read only; filters/postbacks revalidated; names only. |
| Teacher/Dashboard.aspx | T | `Teacher/Dashboard.aspx.cs:9–13` Current teacher Course.TeacherID scope. | MyCourses publish/delete rechecks owner; minimum publication/attempt/payment deletion guards. |
| Teacher/DiscussionEdit.aspx | T-owner | `Teacher/DiscussionEdit.aspx.cs:13–17` ActivityID type/owner and owned TopicID on every request; mixed id/topicId rejected. | Child IDs checked against activity; helpers enforce content locks/settings/publication; delete via owner-checking transaction; summaries owned only. |
| Teacher/GameBuilder.aspx | T-owner | `Teacher/GameBuilder.aspx.cs:15–19` ActivityID type/owner and owned TopicID on every request; mixed id/topicId rejected. | Child IDs checked against activity; helpers enforce content locks/settings/publication; delete via owner-checking transaction; summaries owned only. |
| Teacher/MaterialEdit.aspx | T-owner | `Teacher/MaterialEdit.aspx.cs:15–19` MaterialID or TopicID owner; parent course derived from DB. | Recheck topic/material ownership and parent relationship in transaction, validate/save files and cleanup. |
| Teacher/MyCourses.aspx | T | `Teacher/MyCourses.aspx.cs:11–15` Current teacher Course.TeacherID scope. | MyCourses publish/delete rechecks owner; minimum publication/attempt/payment deletion guards. |
| Teacher/QuizBuilder.aspx | T-owner | `Teacher/QuizBuilder.aspx.cs:13–17` ActivityID type/owner and owned TopicID on every request; mixed id/topicId rejected. | Child IDs checked against activity; helpers enforce content locks/settings/publication; delete via owner-checking transaction; summaries owned only. |
| Teacher/Results.aspx | T-owner | `Teacher/Results.aspx.cs:12–16` Every supplied course/activity filter checks owner; learners query also TeacherID predicate. | Read only; filters/postbacks revalidated; names only. |
| Teacher/SABuilder.aspx | T-owner | `Teacher/SABuilder.aspx.cs:13–17` ActivityID type/owner and owned TopicID on every request; mixed id/topicId rejected. | Child IDs checked against activity; helpers enforce content locks/settings/publication; delete via owner-checking transaction; summaries owned only. |
| Teacher/ScenarioBuilder.aspx | T-owner | `Teacher/ScenarioBuilder.aspx.cs:15–19` ActivityID type/owner and owned TopicID on every request; mixed id/topicId rejected. | Child IDs checked against activity; helpers enforce content locks/settings/publication; delete via owner-checking transaction; summaries owned only. |

Media.ashx (additional handler): `Media.ashx.cs:14–25` — IDs are mutually exclusive; DB-only file path; GET/HEAD; material/free-preview/owner/admin check; cover public only Published; PDF-only download.. Forced-change check includes it; direct Uploads is a hidden segment. Scenario images are embedded only after the owning/player page authorizes: `Helpers/ScenarioHelper.cs:128–132`.

## Security consistency — specific source evidence
| Check | Status | Evidence / limit |
|---|---|---|
| SQL parameterization | PASS | `Helpers/DatabaseHelper.cs:47–49` — Central SqlCommand parameter binding. All reviewed SQL variations choose fixed C# fragments; browser values remain parameters. DataTable.Select int expressions are not SQL. |
| PBKDF2 / ticket / role | PASS | `Helpers/PasswordHelper.cs:11–13`; `Helpers/AuthenticationHelper.cs:24–32`; `Global.asax.cs:21–22` |
| Active status/lock/forced change | PASS | `Helpers/AccessHelper.cs:63–79`; `Helpers/AccountSecurityHelper.cs:29–35`; `Global.asax.cs:29–37`; `Member/ChangePassword.aspx.cs:33–38` |
| HTTPS/cookies | PASS | `Global.asax.cs:14–16`; `Web.config:19–23` — trusted configured origin, secure auth/session; certificate trust not rechecked. |
| CAPTCHA | PASS | `Account/Register.aspx.cs:37–46`; `Contact.aspx.cs:32–36` — missing/wrong renews, unrelated validation preserves, success consumes; independent keys. |
| Validation/encoding/CSRF-related state | PASS | `Contact.aspx.cs:37–45`; `Site.Master.cs:28`; `Web.config:23`; `Helpers/CourseHelper.cs:25` — Page.IsValid/server predicates, encoded literals/HTML, event validation and session-bound ViewState retained. |
| Uploads/media | PASS | `Helpers/UploadHelper.cs:9–29`; `Media.ashx.cs:34–37`; `Web.config:84–86` — contracted extension/size policy, not an unpromised malware scanner. |
| Quiz answer secrecy/timing/idempotency | PASS | `Member/Quiz.aspx.cs:52–54`; `Helpers/QuizHelper.cs:118–121`; `Helpers/QuizHelper.cs:111–116` — no correctness output before submit, server grace/limits and existing result reuse. |
| Game scoring/Memory limitations | PASS | `Helpers/GameHelper.cs:143–150`; `Helpers/GameHelper.cs:157–185` — raw client score field rejected; DB IDs and server elapsed; Q33 client moves cannot be independently reconstructed and are not claimed tamper-proof. |
| Scenario path validation | PASS | `Helpers/ScenarioPlayHelper.cs:63–72`; `Helpers/ScenarioPlayHelper.cs:82–86` — no supplied NextStep authority, session current-step/revision, same graph. |
| Locks/deletes/files | PASS | `Helpers/ActivityHelper.cs:78–81`; `Helpers/DeleteHelper.cs:138–147`; `Helpers/DeleteHelper.cs:203–214` — serializable dependency handling, ownership and reference-aware cleanup. |
| Read-only previews | PASS | `Member/Lesson.aspx.cs:54–55`; `Member/Discussion.aspx.cs:72–73`; `Helpers/QuizHelper.cs:142–149`; `Helpers/SelfAssessmentHelper.cs:64–66`; `Helpers/GameHelper.cs:198–203`; `Helpers/ScenarioPlayHelper.cs:92–93` |
| PRG/delete confirmations | PASS | `Member/Quiz.aspx.cs:78`; `Teacher/MyCourses.aspx:17` — insert/update/delete handlers redirect; Start/Edit-form postbacks are not stored learner submissions. |
| Custom technical errors | PARTIAL / M01 | `Web.config:24–27` — Off contradicts SYS-05; IIS Custom alone does not repair ASP.NET exception disclosure. |
| Secrets / version control | PASS (bounded inspection) | `Web.config:8`; `.gitignore:10` — tracked secret empty; no production credentials found in inspected source/config/docs. git ls-files excludes DB/build/local override. No exhaustive historical secret scan claimed. |

## Approved custom Phase15 — separate A–R audit
| Item | Status | Evidence / explanation |
|---|---|---|
| A — Student portal | PASS | `Account/StudentLogin.aspx.cs:11–14` Learner role, Student UI only. |
| B — Teacher portal | PASS | `Account/TeacherLogin.aspx.cs:11–14` Teacher role. |
| C — Admin portal | PASS | `Account/AdminLogin.aspx.cs:11–14` Admin role. |
| D — Shared authentication | PASS | `Helpers/PortalLoginHelper.cs:10–15` Same account/status/PBKDF2/ticket/lock/forced-change. |
| E — Wrong-role rejection | PASS | `Helpers/AccountSecurityHelper.cs:46–51` Correct-password role mismatch rejected without failure increment. |
| F — Free/paid | PASS | `Teacher/CourseEdit.aspx.cs:43–48` Free0, paid>0 server validation and schema constraint; existing enrolments retained. |
| G — NPR pricing | PASS | `Helpers/PaymentHelper.cs:17–22` Invariant NPR display; DECIMAL(10,2) storage. |
| H — Sandbox initiation | PASS | `Helpers/PaymentHelper.cs:49–54` Active Published paid/current learner, DB amount snapshot, UUID and Pending before signed form. |
| I — Response validation | PASS | `Helpers/EsewaHelper.cs:49–54` Mandatory signed fields, HMAC, product/status/amount/UUID; local source reviewed, not live provider success. |
| J — Server provider verification | PARTIAL | `Helpers/EsewaHelper.cs:82–87` Bounded HTTPS server query, matching product/UUID/amount, COMPLETE required by caller. Real COMPLETE round trip remains unverified. |
| K — Verified-payment enrolment | PARTIAL | `Helpers/PaymentHelper.cs:78–83` Atomic locked reread/update/enrolment and idempotent Complete branch. Pending→Complete external integration unverified. |
| L — Free-course enrolment | PASS | `Helpers/PaymentHelper.cs:27–32` Free course bypasses purchase requirement only, not role/publication checks. |
| M — Paid bypass blocked | PASS | `Helpers/PaymentHelper.cs:38–43` Only Complete+VerifiedDate allows direct paid enrolment; one shared insertion path. |
| N — Re-enrol retained purchase | PASS | `Helpers/PaymentHelper.cs:43–48` IF NOT EXISTS unique enrolment, retained Complete queried in Enrol; leave removes only enrolment. |
| O — Learner payments | PASS | `Learner/MyPayments.aspx.cs:10–15` History(false) scopes to current learner; filter/paging, empty table. |
| P — Admin payments | PASS | `Admin/Payments.aspx.cs:9–14` Admin guard/History(true); read-only; no mark-paid/refund buttons. |
| Q — Payment security | PASS | `Helpers/PaymentHelper.cs:82–87` Owner+snapshot checks, response HMAC and remote COMPLETE; failure never enrols; sandbox configuration allowlist. PASS is source behavior, not remote certification. |
| R — Schema/upgrade/docs | PASS | `Database/Phase15PaymentUpgrade.sql:5–10` Idempotent additions, no destructive rebuild; setup/scope/decision documented; no audit execution. |
Protocol comparison used the official [eSewa ePay V2 guide](https://developer.esewa.com.np/pages/Epay), accessed2026-10-01: mandatory signing order, Base64/HMAC response verification and server status check align with the implementation. This source lookup did not initiate a payment. No production test or secret was used.

## Database / schema audit
Static CreateDatabase.sql declares **24 tables,145 columns,37 foreign keys,62 CHECK constraints**. Original23-table contract remains intact; custom extension adds Course.IsPaid/PriceNPR and ten-column Payment. All dbo table names referenced by C# exist in the script. Column/type/nullability/defaults and SQL assumptions were compared with the original per-table contracts and Phase15 addendum; no missing code-referenced table/column was identified. No claim about the current live schema is possible because connection failed.
| Table group | Evidence | Static result |
|---|---|---|
| User/Subject/Course/Topic | `Database/CreateDatabase.sql:60`; `Database/CreateDatabase.sql:92` | Roles/status/lengths; User optional failure/lock/flag columns; pricing XOR constraint; Teacher/Subject NO ACTION; Topic cascade. |
| Material/MaterialCompletion/Enrolment | `Database/CreateDatabase.sql:141`; `Database/CreateDatabase.sql:174` | Typed required content/alt; composite keys prevent duplicate completion/enrolment; learning FKs NO ACTION. |
| Activity/QuizQuestion/QuizOption/SAStatement | `Database/CreateDatabase.sql:182`; `Database/CreateDatabase.sql:221` | Enums and conditional nullable subtype fields, unique option text; only content-chain cascades; ordering enforced in application as approved. |
| DiscussionPost/GameGroup/GameItem/SimStep/SimChoice | `Database/CreateDatabase.sql:242`; `Database/CreateDatabase.sql:296` | Post/step relationships NO ACTION; group/item cascade only activity content chain. Same-scenario and game group membership validated in C#, not invented SQL constraints. |
| Attempt/QuizAnswer/SAResponse | `Database/CreateDatabase.sql:307`; `Database/CreateDatabase.sql:329` | Attempt scores nullable0–100; time nullable/nonnegative; response integer1–5; child composite keys. Cross-table question/option/activity membership validated in helper transactions. |
| Review/ContactMessage/Bookmark/FAQ | `Database/CreateDatabase.sql:338`; `Database/CreateDatabase.sql:377` | One review per learner/course; bookmark composite key; approved text/rating/audience/order; nullable Contact.UserID; no undeclared optional schema. |
| Payment custom | `Database/CreateDatabase.sql:112–129`; `Database/Phase15PaymentUpgrade.sql:14–31` | UUID UNIQUE, positive NPR, provider/status CHECKs, two NO ACTION FKs; upgrade keeps records. Code blocks referenced user/course deletion. |

Original build script is explicitly destructive; it was not run. Upgrade was not run. No DBCC, resets or forced failure tests. Current metadata remains a manual confirmation, not a discovered schema defect.

## Organization, quality and navigation
- Inventory:58 ASPX pages; each has code-behind/designer, title, Site.Master and exactly one h1 in source. All application .aspx/.cs/.css/.js files are included in .csproj. CourseBuilder.gvActivities is intentionally a Repeater-template control accessed with FindControl, not a missing page-level designer field. No orphan application page detected.
- Helpers/Styles/Scripts/Uploads/Database/docs follow structure. MyBookmarks and additional payment/portal routes are explicitly approved. Scripts/quiz.js implements the timer instead of the blueprint illustrative quiz-timer.js filename; all live references agree. This naming discrepancy does not break navigation. Old template Bootstrap/jQuery/modernizr files remain local/included but the active Site.Master does not load them; not a new dependency or evidence of framework use. Do not remove them during this audit.
- Source review of Home/catalogue/course outline, Lesson/activity pages, representative builders, Results/Admin tables, portals/checkout and certificate retains shared light/dark-nav visual system, breakpoints, associated labels, encoded alt, captions/headers, focus styles, native game buttons and live feedback. 58-page structural scan is not a rendered WCAG or pixel audit. No fresh responsive/keyboard screenshot was captured because runtime was blocked.
- Terminal exits: AccessDenied/NotFound/Error link Home/dashboard; Login uses authorized ReturnUrl/dashboard; registration redirects with message; Logout Home; QuizResult retry/course/results; SA/Game histories back/results; Scenario ending restart/back/results; Certificate Back; builder save/delete redirects; preview exits owner builder/Admin oversight. Checkout has Back and signed form Cancel, but S03 landmark gap remains.
- Deleted image replacement is a confirmed save operation; standalone Delete buttons use confirmations. No URL-triggered ordinary content delete found. Logout is the existing approved own-session GET; provider return is the separately approved verified callback GET.

## Documentation reconciliation / unresolved decisions
Original QUESTIONS inventory is retained as history. Q09/Q11 and Q29–35 resolve the active scoring, graph, deletion, preview, progress, CAPTCHA/HTTPS, certificate and shortcut rules. Q22 follows explicit AGENTS AccessDenied rather than the earlier blueprint redirect wording. Q25 uses Admin oversight lists/read-only preview, not unauthorized Teacher/Learner pages. Real team content/public assets and external verification remain open work, not an excuse to invent data. No new contract/schema decision was made. O10/O14-only questions remain irrelevant while TierC is deferred.
PROGRESS was stale for SYS-03/13/19 and the MyResults review action; implementation exists. SYS-05 was falsely complete; now partial. PUB-02/SYS-14 now acknowledge shared contact placeholders; SYS-16 acknowledges checkout landmark. EVIDENCE references were refreshed and its prior false friendly-error claim corrected. Historical verification reports were not rewritten to imply current tests passed.

## Completion and remaining verification
- Original148 core IDs:142 source PASS,6 PARTIAL (PUB-01/02/10,SYS-05/14/16). No completely missing core page/module identified. This is not final runtime acceptance.
- TierA:10 feature IDs source PASS (O1/O2/O3/O4/O12/O13). TierB:20 IDs source PASS (O5/O6/O7/O8/O9/O11). Both await the final runtime checklist under the current environment limitation.
- TierC:4 IDs **INTENTIONALLY DEFERRED — Phase14 skipped by team decision**. O10 Dark Mode/O14 Game Sounds are not accidental core gaps.
- CustomPhase15:16 source PASS items,2 PARTIAL integration-verification items (J/K); sandbox round trip remains manual; no manual Admin payment bypass found.
- Build succeeded0 warnings/0 errors; runtime and live database checks blocked before any fixture. No application code fixed. Team must review M01/S03 before authorizing application changes; supply S01/S04 content/report artefacts.
- Run TEST_CHECKLIST.md after LocalDB is available through the team’s normal setup. Include role login/status/forced-change, enrolment/progress, all activities, reporting/ownership, TierA/B, paid gate/signing/provider completion/repeat return, and representative phone/tablet/desktop keyboard checks. Do not substitute historical screenshots for final acceptance.
