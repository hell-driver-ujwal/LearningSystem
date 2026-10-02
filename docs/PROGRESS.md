# Phase 0 implementation checklist

Every Section 4 feature is listed once under its delivery phase from AGENTS.md section 6. All items are unchecked: Phase 0 is documentation only, not implementation completion. This allocation is a planning proposal; cross-cutting work starts earlier and is verified across later modules.

Phase 1 prepares schema/demo data; SYS-12 remains unchecked until real content covers 3+ subjects. Phase 2 builds SYS-20 before protected pages. Phase 3 starts transactional deletion and admin oversight; ADM-11/SYS-19 must be extended and verified as activities arrive in Phases 6–9. Phase 4 starts material preview, Phases 6–9 add each activity preview; PRV-01/02 are delivered fully in Phase 9. Histories/class summaries may first appear with their activity module; consolidated results are delivered in Phase 10. Every phase uses empty states, cancel buttons, accessibility and confirmed deletes; Phase 11 completes the global audit of these features. FAQ core rendering in Phase 5 depends on resolving Q16; optional admin management remains Phase 13.

No optional feature starts until Phases 0–11 are complete and tested. Tier B follows Tier A; Tier C follows Tier B.

## Phase 0 — Plan & contracts

Planning deliverables only: CONTRACTS.md, PROGRESS.md, QUESTIONS.md, DECISIONS.md. Await team contract review; no Section 4 feature is claimed complete.

## Phase 1 — Database script

2026-09-28: Q10 seed mapping approved and recorded. Created Database/CreateDatabase.sql (23 tables, contract constraints, FK indexes, rebuild/detach lifecycle and seed checks), Database/GenerateDemoHashes.ps1, Database/README.md, four local educational PNG assets and static-only Uploads/web.config; included files in LearningSystem.csproj. Required .gitignore is present. Solution build passed with no reported warnings/errors. ScriptDom syntax validation, static seed/reference/cascade checks, all 12 password hashes and image checks passed. Two sqlcmd execution attempts each failed with exit code 1 before SQL execution because MSSQLLocalDB could not start; its master database startup log reports a fatal termination. The initial runtime blocker was resolved on 2026-09-29: the default instance was backed up and recreated without an explicit version argument, then passed a stop/start test. Two script rebuilds and detach operations succeeded; Framework attachment and DBCC CHECKCONSTRAINTS passed. See Database/README.md for commands, demo accounts and manual allowed/blocked checks. No later phase was started.

- [x] SYS-12 — Demo seed loaded successfully across IT, Business and Science; local assets and all 12 password hashes verified.
- [x] SYS-18 — Two rebuilds completed with exit code 0 and successful detach. Framework AttachDbFilename connection and DBCC CHECKCONSTRAINTS passed on 2026-09-29.

## Phase 2 — Foundation & login

2026-09-29: Phase 2 implemented under the approved Q28 scope. The account/layout foundation, Forms Authentication, role attachment, folder rules, status re-check, registration/login/profile/password pages, friendly pages, dashboards, CSS and the fully specified helpers needed by this phase are complete. Later-phase helpers whose behavior remains unresolved or which are not needed to run Phase 2 are deliberately deferred; see the Phase 2 implementation note in CONTRACTS.md. Solution build and LocalDB seed verification passed. Automated HTTP/manual-equivalent checks passed for active-role redirects, non-active messages, wrong-role denial, return URLs, duplicate email rejection without JavaScript, logout, registration, profile editing, password changes and status re-check.

- [x] AUTH-01 — Register as learner
- [x] AUTH-02 — Apply as teacher
- [x] AUTH-03 — Log in
- [x] AUTH-04 — Block non-active accounts
- [x] AUTH-05 — Log out
- [x] AUTH-06 — Role redirect
- [x] AUTH-07 — View profile
- [x] AUTH-08 — Edit profile
- [x] AUTH-09 — Change password
- [x] AUTH-10 — Page protection
- [x] ADM-01 — Admin login
- [x] SYS-01 — Master layout
- [x] SYS-02 — Role-based nav bar
- [x] SYS-03 — Access checks implemented through custom Phase 15; Phase 16 source audit found no demonstrated ownership/enrolment bypass. Final runtime blocked.
- [x] SYS-04 — Access-denied page
- [x] SYS-05 — Fixed 2026-10-01 (Phase 17): customErrors="On" with ResponseRewrite; technical details go only to App_Data/ErrorLog.txt (git-ignored).
- [x] SYS-06 — Success / error messages
- [x] SYS-09 — Database connection
- [x] SYS-13 — Breadcrumbs implemented across current pages; source audited in Phase 16.
- [x] SYS-17 — Folder access rules
- [x] SYS-20 — Role setup

## Phase 3 — Admin

2026-09-29: Q29 approved and recorded in DECISIONS.md/CONTRACTS.md. All seven Phase 3 Admin pages are implemented, with designers and project entries. Shared deletion code rechecks blocks inside serializable SQL transactions; cross-author replies are removed, contact history is retained, whole-scenario start pointers are cleared only during whole-content deletion, and validated file cleanup runs after commit with failure logging. Solution build passed. The unmodified database script passed against an isolated LocalDB test instance; HTTP form tests exercised real ASP.NET validation, role protection, CRUD, filters/paging, password reset/login, attempted-content unpublish/delete rules, all five activity deletion types, injected rollback failures and locked-file cleanup/logging. DBCC CHECKCONSTRAINTS returned no violations. Existing workspace database and uploads were preserved. See PHASE3-VERIFICATION.md for manual checks and remaining cross-phase scope. Phase 4 has not started.

- [x] CRS-01 — Add subject
- [x] CRS-02 — List subjects
- [x] CRS-03 — Edit subject
- [x] CRS-04 — Delete subject
- [x] CRS-13 — View all courses
- [x] CRS-14 — Unpublish / delete any course
- [x] ADM-02 — List users
- [x] ADM-03 — Create user
- [x] ADM-04 — Edit user
- [x] ADM-05 — Activate / deactivate
- [x] ADM-06 — Reset password
- [x] ADM-07 — Delete user
- [x] ADM-08 — Pending applications
- [x] ADM-09 — Approve teacher
- [x] ADM-10 — Reject teacher
- [x] ADM-11 — Manage any activity (all types; discussion/preview navigation enabled in Phase 6)
- [x] SYS-19 — Transactional children-first deletion implemented including scenario steps and Tier B; Phase 16 source audited.

## Phase 4 — Courses & materials

2026-09-29: Q30 approved, with the new topic default changed to the next position. Implemented the four requested Teacher pages and required shared ownership, publication, ordering, upload/replacement, breadcrumb and deletion support. Dashboard remains a placeholder with a My Courses link. MSBuild passed without warnings/errors. The unchanged database script passed on an isolated LocalDB instance. Live IIS Express form tests passed for all six material types, publication gates, second-teacher GET/POST denial, size boundaries, extension/empty-file rejection, alt text, ordering, duplicate-save rejection, timestamps, rollback and file cleanup. DBCC CHECKCONSTRAINTS found no violations. Workspace database/uploads were preserved. See PHASE4-VERIFICATION.md for files, checks and manual steps. Phase 5 has not started; ENR-06 and viewers remain deferred from this four-page scope. Final breadcrumb-only refinement compiled successfully, but its HTTP recheck was blocked by Windows Application Control on the rebuilt DLL; the preceding full functional tests passed. See the final runtime limitation in PHASE4-VERIFICATION.md.

- [x] CRS-05 — Create course
- [x] CRS-06 — My courses list
- [x] CRS-07 — Edit course
- [x] CRS-08 — Publish / unpublish
- [x] CRS-09 — Delete course
- [x] CRS-10 — Add topic
- [x] CRS-11 — Edit / reorder topic
- [x] CRS-12 — Delete topic
- [x] MAT-01 — Add text lesson
- [x] MAT-02 — Upload image / PDF
- [x] MAT-03 — Add video / audio
- [x] MAT-04 — Edit material
- [x] MAT-05 — Delete material
- [x] MAT-06 — Mark as free preview
- [x] MAT-10 — Alt text on images
- [x] ENR-06 — Enrolled learners list delivered in Phase 10; owner-only CourseLearners shows names only.
- [x] SYS-08 — File upload handling

## Phase 5 — Public site, enrolment & lessons

2026-09-30: Q31 approved and recorded in DECISIONS.md/CONTRACTS.md, with the original question retained. Implemented public pages, published catalogue/search/filter/paging, enrolment and leave, learner dashboard/MyCourses/CourseHome, all six material viewers, completion, shared calculated progress, read-only owner/admin material previews and protected Media.ashx delivery. Build passed with 0 warnings and 0 errors after fixing one handler-name warning. The four approved smoke checks passed on the workspace application: published catalogue, learner enrol/lesson/complete (0% to 25%), visitor free preview/access protection, and teacher draft preview with unchanged learner-data counts. No database rebuild, test application copy or security-setting change. The smoke flow retained Enrolment (LearnerID 8, CourseID 2) and MaterialCompletion (LearnerID 8, MaterialID 4). See PHASE5-VERIFICATION.md for files, checks, manual steps and content gaps. Phase 6 has not started; verification stopped at the approved budget.

- [x] PUB-01 — Home page with captioned intro video, poster, subject images and newest courses (Phase 17).
- [x] PUB-02 — About page with mission, objectives, how it works, lecturers and contact details (Phase 17).
- [x] PUB-03 — Browse subjects
- [x] PUB-04 — Course catalogue
- [x] PUB-05 — Search courses
- [x] PUB-06 — Filter by subject
- [x] PUB-07 — Course outline
- [x] PUB-08 — Free preview
- [x] PUB-09 — Help / FAQ page
- [x] PUB-10 — Contact email and address on About, Contact and the footer, configured in Web.config appSettings (Phase 17).
- [x] MAT-07 — View material
- [x] MAT-08 — Download PDF
- [x] MAT-09 — Mark complete
- [x] ENR-01 — Enrol
- [x] ENR-02 — Leave course
- [x] ENR-03 — My Courses

## Phase 6 — Quiz & discussion

2026-09-30: Q32 approved with team amendments and recorded in DECISIONS.md/CONTRACTS.md; original question retained. Implemented Teacher/QuizBuilder, Teacher/DiscussionEdit, Member/Quiz, Member/QuizResult and Member/Discussion, contracted shared support, builder Add/Edit/Preview links and learner/admin navigation. Build succeeded with 0 warnings and 0 errors. The first IIS Express launch command was rejected by automatic approval review (blocked by policy), so no runtime smoke checks ran and no test data was created. Stopped without host retries, database rebuilds or security changes. Feature checkboxes below indicate implemented scope, not runtime verification. See PHASE6-VERIFICATION.md for files, the limitation and all requested manual tests. Phase 7 has not started.

- [x] QZ-01 — Create quiz
- [x] QZ-02 — Add question
- [x] QZ-03 — Edit question
- [x] QZ-04 — Delete question
- [x] QZ-05 — Edit quiz settings
- [x] QZ-06 — Publish / unpublish
- [x] QZ-07 — Delete quiz
- [x] QZ-08 — Quiz intro
- [x] QZ-09 — Take quiz
- [x] QZ-10 — Submit + auto-mark
- [x] QZ-11 — Result + review
- [x] DSC-01 — Create discussion
- [x] DSC-02 — Edit discussion
- [x] DSC-03 — Close / reopen
- [x] DSC-04 — Delete discussion
- [x] DSC-05 — View thread
- [x] DSC-06 — Write post
- [x] DSC-07 — Reply
- [x] DSC-08 — Edit own post
- [x] DSC-09 — Delete own post
- [x] DSC-10 — Remove post
- [x] DSC-11 — Remove any post

## Phase 7 — Self-assessment

2026-09-30: Implemented SABuilder, Member/SelfAssessment, shared validation/submission/feedback support, personal history, owner-only class summary and builder/learner/admin navigation. Q09 resolved by the explicit Phase 7 instructions and recorded in CONTRACTS.md/DECISIONS.md; historical question retained with resolution. Build succeeded with 0 warnings and 0 errors. The first IIS Express launch was rejected before execution by automatic approval review (blocked by policy); no runtime smoke checks ran and no test data was created. Stopped without runtime retries or security changes. SA-01–10 checkboxes indicate implemented scope, not runtime verification. See PHASE7-VERIFICATION.md for files, limitations and requested manual tests. Phase 8 has not started.

- [x] SA-01 — Create self-assessment
- [x] SA-02 — Add statement
- [x] SA-03 — Edit statement
- [x] SA-04 — Delete statement
- [x] SA-05 — Settings / publish
- [x] SA-06 — Delete self-assessment
- [x] SA-07 — Complete it
- [x] SA-08 — Feedback summary

## Phase 8 — Games

2026-09-30: Q33 approved and recorded in CONTRACTS.md/DECISIONS.md; original question retained with resolution. Implemented GameBuilder, PlayGame, games.js, game helpers, all four templates, strict server result validation, Q33 Memory scoring/server timing, best/history and owner-only game results, with CourseBuilder/learner/admin navigation. Build succeeded with 0 warnings and 0 errors. Automatic approval review rejected the first IIS Express launch (blocked by policy) before execution: no runtime or phone-sized checks ran and no test data was created. Stopped without retries, alternate hosts or security changes. GAM checkboxes indicate implementation, not runtime verification. See PHASE8-VERIFICATION.md for files, limitations and manual steps. Phase 9 implementation and verification are recorded below.

- [x] GAM-01 — Create game
- [x] GAM-02 — Add content items
- [x] GAM-03 — Edit item
- [x] GAM-04 — Delete item
- [x] GAM-05 — Manage groups
- [x] GAM-06 — Publish / unpublish
- [x] GAM-07 — Delete game
- [x] GAM-08 — Play Matching
- [x] GAM-09 — Play Memory
- [x] GAM-10 — Play Word Scramble
- [x] GAM-11 — Play Sort into Groups
- [x] GAM-12 — Save score

## Phase 9 — Scenario

2026-09-30: Phase 9 implemented and Q11 resolved in CONTRACTS.md/DECISIONS.md, with the original question retained. Added ScenarioBuilder/Scenario, shared publication/deletion/path helpers, owner-only outcome summary, protected step images and teacher/learner/admin navigation. Solution build succeeded with no reported warnings or errors. IIS Express ran successfully this phase. The four requested representative checks passed: build/publish/play to an ending, invalid publication rejection, stale choice/path rejection after restart, and owner draft preview with zero Attempt writes. Normal completion saved one Attempt with the reached EndingStepID and NULL score/time. Retained minimal smoke data: Scenario ActivityID 9, CourseID 1, LearnerID 7, two steps, one choice and one completed Attempt. Test host stopped. No database rebuild, large regression or Phase 10 work. See PHASE9-VERIFICATION.md for changed files and remaining manual checks.

- [x] SIM-01 — Create scenario
- [x] SIM-02 — Add step
- [x] SIM-03 — Edit step
- [x] SIM-04 — Delete step
- [x] SIM-05 — Add choice
- [x] SIM-06 — Edit / delete choice
- [x] SIM-07 — Set start step
- [x] SIM-08 — Check + publish
- [x] SIM-09 — Delete scenario
- [x] SIM-10 — Play scenario
- [x] SIM-11 — Save outcome
- [x] SIM-12 — Outcome + restart
- [x] PRV-01 — Owner/admin preview implemented for materials and all activity types through Phase 9; owner draft Scenario path smoke-tested. Other Phase 6–8 runtime limitations remain documented.
- [x] PRV-02 — No-write preview implemented across materials and activities; Scenario draft preview reached an ending with no Attempt created. Broader teacher/admin combinations remain manual.

## Phase 10 — Results, progress & dashboards

2026-09-30: Implemented MyResults, Teacher Results and CourseLearners; integrated Learner dashboard and replaced Teacher dashboard placeholder with live owned-course counts/results. Verified existing Admin core statistics without changing their working implementation. Added reporting/navigation/project entries. Progress source review confirmed all displays use CourseHelper.Progress -> ProgressHelper.CalculatePercent, with no duplicated formula. Build succeeded with no reported warnings/errors. Four representative checks passed: hand progress 5/6 = 83.33% for LearnerID 7/CourseID 1, real learner history/dashboard, teacher reports/names-only list/dashboard plus foreign-course denial, and Admin counts against direct SQL. Reporting checks made no content/attempt/enrolment test writes. Test host stopped. See PHASE10-VERIFICATION.md. Phase 11 not started.

- [x] ENR-04 — Shared calculated progress delivered in Phase 5 under Q31; later activity submissions will automatically count.
- [x] ENR-05 — Learner dashboard delivered in Phase 5, including enrolled-course progress and recent existing results.
- [x] QZ-12 — Own attempt history with latest/best quiz scores in MyResults (Phase 10).
- [x] QZ-13 — Owner-only teacher quiz attempts and saved-score summaries (Phase 10).
- [x] SA-09 — Past self-assessments (delivered in Phase 7 by explicit request; runtime checking blocked)
- [x] SA-10 — Class summary (delivered in Phase 7 by explicit request; runtime checking blocked)
- [x] GAM-13 — Best score + history (delivered in Phase 8 by explicit request; runtime checking blocked)
- [x] GAM-14 — Game results (owner-only GameBuilder results delivered in Phase 8; runtime checking blocked)
- [x] SIM-13 — Owner-only outcome summary delivered in Phase 9 by explicit request; broader summary checks remain manual.
- [x] RES-01 — Own Quiz/SelfAssessment/Game/Scenario attempts, type-specific results, filters and paging.
- [x] MyResults review-link portion — implemented with O5 in Phase 13; confirmed by Phase 16 source review.
- [x] RES-02 — Owned course/activity filters, attempts, score summaries and reused confidence/outcome summaries.
- [x] RES-03 — Own course count, distinct currently enrolled learner count, recent owned attempts and shortcuts.
- [x] RES-04 — Existing real core counts verified again in Phase 10 against SQL; optional charts remain CHT-02.

## Phase 11 — Polish & accessibility

2026-09-30: Core visual/accessibility/navigation and security-consistency pass complete. Shared responsive styles, accessible table overflow/headers, validation/messages, cards/forms and result exits refined. Restored friendly technical-error protection and explicit UTF-8 rendering. Build passed without reported warnings/errors; representative Home, CourseDetails, teacher dashboard/builder and keyboard Matching preview checks passed. See PHASE11-VERIFICATION.md for exact scope, files and remaining manual checks; EVIDENCE.md for line-level implementation references. PUB-01/PUB-10 real assets/contact remain partial; all optional features remain deferred. Phase 12 not started.

- [x] SYS-07 — Empty-state messages
- [x] SYS-10 — Responsive CSS
- [x] SYS-11 — Delete confirmation
- [x] SYS-14 — Footer shows contact details, last updated, About, Help, Contact, Site map, Privacy and Terms links (Phase 17).
- [x] SYS-15 — Cancel button
- [x] SYS-16 — Accessibility: main landmark now wraps both forms (S03 fixed), skip link, visible focus, labelled fields, alt text, captions, reduced motion (Phase 17).

## Phase 12 — Optional Tier A

2026-09-30: Q34 approved and recorded. Tier A implemented using existing account columns, canvas/plain JavaScript, role-specific SiteMap, Register CAPTCHA and secure local-demo HTTPS. Build passed without reported warnings/errors. Representative account-lock/forced-change HTTP flows, admin chart browser rendering, visitor SiteMap/CAPTCHA rendering and HTTPS redirect/secure cookies passed. Temporary fixture removed; no schema/rebuild/machine security changes. See PHASE12-VERIFICATION.md for files, exact checks and manual follow-ups. Phase 13 not started.

- [x] CHT-01 — Teacher results chart (O1)
- [x] CHT-02 — Admin statistics charts (O1)
- [x] LCK-01 — Count failed logins (O2)
- [x] LCK-02 — Lock after 5 failures (O2)
- [x] LCK-03 — Admin unlock (O2)
- [x] FPC-01 — Flag password change (O3)
- [x] FPC-02 — Force change (O3)
- [x] MAP-01 — Site map page (O4)
- [x] CAP-01 — CAPTCHA (O12)
- [x] SSL-01 — HTTPS (O13)

## Phase 13 — Optional Tier B

2026-09-30: Q35 approved and recorded. Tier B reviews, Contact/Admin inbox, material bookmarks, calculated printable certificates, managed FAQ and shortcuts implemented and integrated. Build passed without reported warnings/errors. Representative review create/edit, bookmark add/remove, certificate denial, Contact/inbox/read, FAQ creation/display and keyboard navigation/typing-guard checks passed; login and existing Quiz/Game preview pages loaded. Synthetic test rows removed; no schema/rebuild/machine-security changes. See PHASE13-VERIFICATION.md for files, exact coverage and remaining manual checks. Phase 14 not started.

- [x] REV-01 — Write review (O5)
- [x] REV-02 — Edit own review (O5)
- [x] REV-03 — Delete own review (O5)
- [x] REV-04 — Show reviews + average (O5)
- [x] REV-05 — Average on course cards (O5)
- [x] REV-06 — Admin remove review (O5)
- [x] CON-01 — Send contact message (O6)
- [x] CON-02 — Admin inbox (O6)
- [x] CON-03 — Read / mark read (O6)
- [x] CON-04 — Delete message (O6)
- [x] BMK-01 — Add bookmark (O7)
- [x] BMK-02 — Remove bookmark (O7)
- [x] BMK-03 — My Bookmarks page (O7)
- [x] CER-01 — Certificate unlock (O8)
- [x] CER-02 — Printable certificate (O8)
- [x] FAQ-01 — Add FAQ (O9)
- [x] FAQ-02 — Edit / reorder FAQ (O9)
- [x] FAQ-03 — Delete FAQ (O9)
- [x] FAQ-04 — Help reads FAQ (O9)
- [x] KEY-01 — Keyboard shortcuts (O11)

## Phase 14 — Optional Tier C — DEFERRED, not completed

- [ ] DRK-01 — Theme toggle (O10)
- [ ] DRK-02 — Remember theme (O10)
- [ ] SND-01 — Game sounds (O14)
- [ ] SND-02 — Mute switch (O14)

## Phase 15 — Custom Enhancements

- [x] Custom scope/approval/contracts and AGENTS source rule documented; BLUEPRINT unchanged. Phase 14/O10/O14 DEFERRED; Final Audit moved to Phase 16.
- [x] A — Three role-specific portals share authentication, role validation, lockout and forced-password behavior; Login remains the selector.
- [x] B/F/G — Free/paid NPR course editing, server-enforced payment gate, retained verified purchases, pricing and navigation integration.
- [x] C/H/I — Payment schema and non-destructive upgrade; own learner history and read-only Admin transactions.
- [~] D/E — Sandbox request signing, response HMAC plus server-status verification and atomic idempotent enrolment implemented and built. Local signing, malformed rejection and synthetic completed-purchase idempotency passed. Actual eSewa COMPLETE round trip remains manual: sandbox login reCAPTCHA/quota warning prevented completion.
- [x] Debug solution build passed; representative portal/free enrol/paid gate/history/quiz/game checks passed. Upgrade executed without rebuilding existing data. See PHASE15-VERIFICATION.md for precise coverage, file inventory and remaining manual steps; PHASE15-PAYMENT-SETUP.md for configuration.

## Phase 16 — Final Audit

2026-10-01: Audit documentation complete; no application/configuration/schema changes. Reviewed all 182 original feature IDs, Section 17, all 17 Section 18 rules, page/operation authorization, database script and custom Phase 15 separately. Full solution build succeeded with 0 warnings/0 errors. Final runtime/live-database checks were blocked by LocalDB process startup before fixtures or HTTP tests; no retries or security changes. Findings: 1 MUST FIX and 4 SHOULD FIX (documentation S02 corrected here; application fixes await approval). See PHASE16-AUDIT.md, refreshed EVIDENCE.md and click-by-click TEST_CHECKLIST.md. Source status is not runtime acceptance. Tier C remains intentionally deferred; stopped after Phase 16.

## Section 18 — all 17 gap-check rules

Phase 16 marks below reflect source verification, not new runtime passes. Rules 1/17 remain partial because this checkout cannot prove every team member's workstation/Git practice. Detailed evidence and approved decision qualifications are in PHASE16-AUDIT.md.

- [~] Rule 1 — All four members use the same Visual Studio project type (a .csproj file means ASP.NET Web Application).
- [x] Rule 2 — A quiz attempt is created only on Submit; the start time is kept in the session.
- [x] Rule 3 — Courses, topics and activities with attempts cannot be deleted; unpublish instead.
- [x] Rule 4 — Once an activity has attempts, its content is locked (title and description stay editable).
- [x] Rule 5 — Deleting records with files also deletes the files from disk.
- [x] Rule 6 — Matching and Sort use tap-to-select, tap-to-place (no browser drag-and-drop).
- [x] Rule 7 — Inside a topic: materials first, then activities, each in its own order.
- [x] Rule 8 — A course can be published only with ≥1 topic holding ≥1 published item.
- [x] Rule 9 — Unpublished courses show as Currently unavailable in My Courses; results stay.
- [x] Rule 10 — Progress = items done ÷ published items. Material done = marked complete; quiz/self-assessment/game/scenario done = ≥1 submitted attempt; discussion done = ≥1 post.
- [x] Rule 11 — Redirect after every save; server rejects duplicate submissions.
- [x] Rule 12 — Admin accounts appear in Users with all actions disabled.
- [x] Rule 13 — Home shows the 6 newest published courses.
- [x] Rule 14 — Teachers see learner names only; only the admin sees emails.
- [x] Rule 15 — Game answers may be in the page (needed to play); the server re-checks scores.
- [x] Rule 16 — Search and catalogue show published items only.
- [~] Rule 17 — Code shared through Git; build folders and the .mdf file excluded; the SQL script is the shared database.

## Review and manual verification

Before Phase 1, compare all 23 table definitions with Section 6 and lengths with Section 9.1; resolve the questions and approve the contracts. During implementation, test allowed and blocked paths per feature: wrong role/ID, non-enrolment, draft visibility, content lock after attempts, duplicate submission, blocked deletion and no writes during preview. In Phase 16 check all feature IDs and Section 18 rules against the working application; do not mark completion from documentation alone.

2026-09-29 additional live verification: all 133 columns and 35 foreign keys match CONTRACTS.md. Duplicate email/enrolment, rating 6, and referenced subject/teacher/step/course deletes were rejected correctly. Draft course cascade passed; all test changes were rolled back and the database was detached.












## Phase 17 — Inkwell redesign and extensions (2026-10-01)

2026-10-01 follow-up: Reproduced Analytics/dashboard SQL errors with the live `admin@example.test` account. Existing database lacked PageView despite its presence in CreateDatabase.sql. Applied the transactional, non-destructive Phase17AnalyticsUpgrade.sql; table count increased 24 to 25. Before/after existing counts unchanged: User 16, Course 6, Material 16, Activity 11, Attempt 18, Payment 4, Enrolment 17. Browser checks passed: Analytics empty state, dashboard statistics/tables/charts restored, then Analytics showed two real visits (one Analytics and one Dashboard), 100% signed-in Admin share. Views begin now; no historical analytics were fabricated. Current Admin email differs from the rebuilt seed documented in DEMO_CREDENTIALS.md; existing account was preserved. No unrelated Phase 17 schema/data changes applied.

Requested by the team member on branch `sunil/dev`; decisions recorded in DECISIONS.md. Built with MSBuild (0 errors, 0 warnings), database script run twice successfully, automated HTTP smoke test (all roles, 114 crawled links) and 23 browser end-to-end flows passed.

Analytics repair build: full solution Debug MSBuild succeeded, exit code 0, no warnings or errors reported. Only the focused browser checks above were performed for this repair; prior Phase 17 test claims remain historical.

- [x] Unused template packages removed (Bootstrap, jQuery, Modernizr, FriendlyUrls, bundling, mobile master).
- [x] Admin can author courses using the lecturer course builder (ownership = Teacher or Admin who owns the course).
- [x] New demo catalogue: 8 subjects including Programming, Cybersecurity and Artificial Intelligence; 19 courses (14 lecturer, 4 admin, 1 draft); 6 lecturers, 1 pending applicant, 4 learners, 1 admin.
- [x] Four new game templates: Flashcards, Fill in the blank, True or false speed round, Put in order (server-scored).
- [x] Code lab material type (virtual lab): learners edit and run HTML, CSS and JavaScript in a sandboxed frame.
- [x] Formatted text lessons (headings, lists, code blocks, tips) rendered safely after HTML encoding.
- [x] Generated media: course covers, subject images, diagrams, PDF handouts, narrated audio, captioned videos.
- [x] New design system and redesign of every page; bundled Source Serif 4 and Source Sans 3; SVG icon set; favicon set and web manifest.
- [x] Learner engagement: learning streak, weekly activity, continue learning, suggested courses, course outline sidebar, next/previous across lessons and activities.
- [x] Privacy policy and Terms of use pages; registration requires accepting the terms.
- [x] robots.txt and sitemap.xml generated from the database; canonical and Open Graph tags.
- [x] First-party analytics (PageView table: page, role and time only) with an admin Analytics page.
- [x] customErrors On with private error log; security headers; video captions served through Media.ashx.- [x] Demo eSewa payment screen (mobile number + 4-digit code, verified on the server) replaces the internet sandbox; paid courses open only after a verified payment.

## 2026-10-01 — Presentation/demo dataset (data-only task)

- [x] Reused four active fictional teachers, four learners and existing Admin; preserved other records and credentials.
- [x] Added four Published courses, 40 topics, 49 materials and 16 activities: four quizzes, three self-assessments, four discussions, four original-template games and one six-step branching/looping scenario.
- [x] Added seven presentation enrolments and 17 submitted attempts through existing helpers, plus completions, posts/reply, reviews/bookmarks and three explicitly offline-test payment states. Shared Web progress: Ben 11.76%, Chandra 47.06%, Anita 82.35%, Dina 100%.
- [x] Added Database/SeedPresentationDemo.sql, SeedPresentationDemo.ps1 and standalone SeedPresentationHistory.cs (None project entry), manifest, four local GUID covers, docs/DEMO-DATA.md and docs/DEMO-ASSET-SOURCES.md. No application-code/schema changes or destructive rebuild.
- [x] Build: LearningSystem.slnx Debug succeeded, exit 0; no warnings/errors emitted. Built once after project/assets changes.
- [x] Representative checks: publication helpers passed; repeat seed preserved percentages; scoped queries found no duplicate presentation-course/enrolment groups. Browser: all four new catalogue covers loaded; Web CourseDetails outline/reviews/cover; Dina login/dashboard/results/certificate; Asha login/dashboard/recent attempts; Admin login/dashboard/payment history. Admin shows nine published courses and 35 total attempts, including preserved data.
- [~] Existing unrelated course How to code in C cover did not load. Preserved unchanged for team review; all new covers loaded.
- [~] No external eSewa verification: current application uses its existing offline demo. Seeded game times may be zero seconds; play fresh runs for human timing. Broader gameplay/CRUD/access checks remain manual per DEMO-DATA.md.
- O10/O14 remain deferred. No optional features or application audit fixes started.

## 2026-10-01 — Phase 17 final database verification

- [x] Read-only inspection identified the old target as the attached `App_Data/LearningSystem.mdf` catalog on `(LocalDB)\\MSSQLLocalDB`; it had 25 tables but lacked Code support, the four new game-template values, and both Payment learner/course indexes.
- [x] Created separate `LearningSystemFinal` from the current `Database/CreateDatabase.sql` schema/seed section using the create-only `Database/CreateFinalDatabase.ps1` wrapper. The original MDF/LDF and catalog were preserved and never rebuilt, detached or overwritten.
- [x] Final database checks passed: 25 tables, 12 users, 19 courses, 72 materials, 73 activities, PageView, Payment constraints/indexes, five published Code Labs, all eight game templates, and the Course pricing checks.
- [x] Switched `Web.config` `LearningSystemDb` to `Initial Catalog=LearningSystemFinal`; corrected the Phase 17 Code/game fixed-value documentation in AGENTS.md and recorded the comparison/connection details in `docs/PHASE17-FINAL-DATABASE.md`.
- [x] Full Debug MSBuild succeeded with 0 warnings and 0 errors.
- [~] Browser runtime checks blocked by the environment: IIS Express registered the existing bindings and logged one HTTP 200 Home request, but browser navigation refused/timed out and a normal LocalDB startup returned error 50. No security settings, certificates, SQL instance configuration or old database files were changed. Manual UI checks remain documented in `docs/PHASE17-FINAL-DATABASE.md`.

## 2026-10-02 - Pastel UI redesign (visual only)

- [x] Shared design tokens and pastel restyle of every component in `Styles/site.css` (existing class names kept).
- [x] Sidebar app shell for signed-in users (slim icon rail on `Member/` lesson and activity pages, pill row on phones); public pages keep the top bar.
- [x] Dashboard hero banners, pastel stat cards and call-to-action strips (Learner, Lecturer, Admin); pastel chart bars.
- [x] Build: MSBuild Debug, 0 errors, 0 warnings.
- [x] Checks run: no horizontal overflow on 20 representative pages at 1366, 820 and 390px for visitor, learner, lecturer and admin; code lab Run and Reset; lesson next link; lecturer topic validator and Cancel postback; game preview start postback; admin role filter postback; skip link, focus outline and keyboard access to sidebar links; no JavaScript errors.
- [~] Long builder/editor forms, certificate printing and every remaining page were not individually reviewed; see docs/UI-REDESIGN-NOTES.md.

## 2026-10-02 - Dark game-style redesign (branch sunil/advanced)

- [x] Dark high-contrast theme, Nunito font, role accents, chunky buttons, motion with reduced-motion support.
- [x] Inky mascot with 12 poses across dashboards, activities, log-in and error pages.
- [x] Game layer computed from real records: XP, levels, streak, daily goal, 12 badges, level-up celebration.
- [x] Learning path course home; Complete and continue lessons; one-question-at-a-time quiz; all eight games reworked; sound effects (O14).
- [x] Home tour video rebuilt in the dark design.
- [x] Build 0 errors, 0 warnings; 65 automated browser checks passed (games end to end, layout at three widths, new flows); no JavaScript errors.
- [~] Every page restyled through the shared stylesheet; lesser-used admin and builder forms were spot-checked rather than reviewed one by one.

- [x] 2026-10-02 follow-up: flat dark restyle (no gradients, system font) and 38 extra games across 16 courses; fresh database builds with all checks passed (77 games).
