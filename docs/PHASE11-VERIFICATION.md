# Phase 11 quality and visual review

Completed 30 September 2026. Scope: implemented core only. No schema, package, helper-contract or optional-feature changes.

## Changes

- Shared light content/dark navigation visual system, purple primary actions, readable typography, responsive hero/cards/forms, status badges, progress panels, previews and restrained borders/shadows.
- Separate account navigation, focusable skip-link destination, visible keyboard focus, text-labelled success/error messages and validator focus/alert semantics.
- Labelled, keyboard-focusable table overflow containers; shared GridView header sections. Added the missing SelfAssessment response empty state.
- Course cards include existing teacher/subject/description data and honest cover placeholders. Home retains the missing-media/subject-image notices.
- Learner result exits added to QuizResult, SelfAssessment, PlayGame and Scenario; Scenario preview exit text clarified. Existing retry/back/cancel routes retained.
- Security configuration violation fixed: project-local customErrors was Off and IIS httpErrors was Detailed. They now use On/Custom and existing friendly routes. Explicit UTF-8 file/request/response encoding fixes garbled punctuation observed during the browser check.

## Files created / changed

Created: docs/EVIDENCE.md, docs/PHASE11-VERIFICATION.md, docs/phase11-home.png.

Shared: Styles/site.css; Site.Master, Site.Master.cs, Site.Master.designer.cs; Helpers/CourseHelper.cs; Web.config; LearningSystem.csproj.

Public: Default.aspx and .aspx.cs; Courses.aspx and .aspx.cs; CourseDetails.aspx.

Learner: Dashboard.aspx, MyCourses.aspx, MyResults.aspx, CourseHome.aspx.

Member: Lesson.aspx; SelfAssessment.aspx, PlayGame.aspx, Scenario.aspx and QuizResult.aspx (each with code-behind and designer updates for the added result-navigation control).

Teacher markup: CourseBuilder.aspx, CourseLearners.aspx, Dashboard.aspx, GameBuilder.aspx, MyCourses.aspx, QuizBuilder.aspx, Results.aspx, SABuilder.aspx, ScenarioBuilder.aspx.

Admin markup: Activities.aspx, Courses.aspx, Dashboard.aspx, Subjects.aspx, TeacherApplications.aspx, Users.aspx.

Documentation: PROGRESS.md and DECISIONS.md updated. Existing server IDs and events retained; added controls have synchronized designer declarations.

## Source review

Reviewed 44 implemented pages for title/master/h1 and breadcrumb conventions; Contact is a redirect-only optional stub. Checked lists, labels, caption/header markup, postback delete confirmations, save validation guards, and terminal navigation. Reviewed shared ownership/enrolment/role/publication checks, encoding, parameter binding, protected media/upload validation, locks, transactional deletes, PRG and preview branches. Quiz rendering emits option IDs/text without correctness flags. Matching and Sort retain native button selection/placement. Progress remains in the existing shared helper.

This was a source consistency review and representative visual check, not an exhaustive security regression or formal WCAG certification. No new functional feature was added.

## Build and checks actually performed

- Visual Studio 18 MSBuild, LearningSystem.slnx, Debug, /t:Build /v:minimal /nologo: succeeded, exit 0; no warnings/errors reported. One main build. Subsequent changes were documentation/project evidence inclusion and configuration encoding, not compiled code.
- Public Home: real published course cards, teacher metadata and supported content rendered. Desktop 1280x900 and phone 390x844 screenshots reviewed; no page-wide horizontal overflow.
- CourseDetails (course 1): tablet 820x1000 screenshot reviewed; outline, metadata, enrol route and free-preview status rendered without page overflow.
- Existing demo teacher login and Dashboard: real counts and recent results rendered. Tablet 820x1000; accessible table region fit the page.
- Owned GameBuilder (game 4): phone 390x844 form and navigation reviewed; document width 375 within viewport 390.
- Matching teacher preview: used Enter to Start, select Foreign key and place it against References a key in another table. Status became '1 of 4 items placed'; visible focus ring and phone layout confirmed. No result submitted and no authored content changed.
- A transient error occurred immediately after the encoding configuration recycle; the friendly error page and subsequent preview request rendered successfully. Technical-error settings were restored to On/Custom. UTF-8 preview punctuation then rendered correctly.
- IIS Express was started once for these checks and stopped afterwards. No database rebuild, destructive tests, full regression or machine security changes.

## Remaining manual visual checks for the team

1. Open Courses, CourseHome and each material viewer at phone/tablet/desktop sizes; inspect long titles, missing covers and media controls with the team's real content.
2. Tab through learner/admin forms, invalid validation summaries and navigation. Confirm labels, focus and screen-reader announcements; check zoom at 200%.
3. Use Matching and Sort with mouse, touch and keyboard; confirm selection/placement instructions and focus. The representative runtime check covered Matching only.
4. Review the remaining builders, Admin lists and Learner/Teacher results with long rows; focus and horizontally scroll the labelled table region, then try paging/filter controls.
5. Follow back/cancel/preview exits and result-history links as each role; use disposable data for broader save/delete confirmation checks during the final audit.

## Known gaps and intentional deferrals

Real intro media/poster, subject images and contact details remain awaiting the team (PUB-01/PUB-10 partial). Demo content exists, but the team must review R11 content quality for its submission. Pages outside the representative sample still need manual visual inspection. No other blocking core issue was found in this pass.

O1–O14 remain deferred, including charts/canvas, reviews, bookmarks, certificates, optional FAQ/contact administration, theme and sounds. Phase 12 was not started. EVIDENCE.md supplies exact source references for the assignment Implementation section; phase11-home.png is the desktop visual record.