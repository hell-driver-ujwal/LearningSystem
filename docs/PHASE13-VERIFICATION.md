# Phase 13 — Optional Tier B verification

Completed 30 September 2026. Q35 resolved in CONTRACTS.md, DECISIONS.md and QUESTIONS.md. No schema changes; Phase 14 not started.

## Delivered

- REV-01–06: enrolled active learners create/update one review per course; integer rating 1–5, trimmed comment 10–1000; own deletion with confirmation; Admin removal on existing Admin/Courses (including unpublished courses), no teacher moderation. Encoded public reviews and average on CourseDetails and Home/catalogue cards; eligible MyResults review links.
- CON-01–04: visitor/authenticated Contact with validated prefill, independent ContactCaptcha under Q34 lifecycle, one-use session send token, PRG; Admin-only paged inbox, open/read, explicit Mark as read, confirmed transactional deletion; unread nav/dashboard counts. Removed original template contact addresses rather than presenting them as real team details.
- BMK-01–03: idempotent desired-state bookmark button on Lesson; authorized enrolled learners only, no preview writes. MyBookmarks lists only own retained materials; unavailable entries have no live lesson/mutation action. Composite key prevents duplicates.
- CER-01–02: logged-in learner only, current Published/enrolled course and shared CalculatePercent == 100m on every request. No stored certificate/progress. Printed on: UTC date, learner/course/teacher, print CSS, back link; certificate links from MyCourses/CourseHome.
- FAQ-01–04: Admin add/edit/reorder/delete, server validation and confirmed transactional deletion. FAQ uses existing table/order range with ID tie-break; Help groups permitted audience FAQs using encoded details/summary and retains static guidance.
- KEY-01: approved Alt+H/C/D/Q destinations, server-supplied role dashboard, ignores editable focus/composition/repeat/modifiers; only handled shortcuts prevent default. Help documents browser/OS reservations.

## Files created

- Helpers/ReviewHelper.cs, Helpers/BookmarkHelper.cs
- Admin/Messages.aspx, Admin/FAQ.aspx, Learner/MyBookmarks.aspx, Learner/Certificate.aspx, each with code-behind and designer
- Styles/print.css, Scripts/shortcuts.js
- docs/PHASE13-VERIFICATION.md, docs/phase13-help.png

## Files changed

- Contact.aspx/.aspx.cs/.aspx.designer.cs; Help.aspx/.aspx.cs/.aspx.designer.cs
- CourseDetails.aspx/.aspx.cs/.aspx.designer.cs
- Admin/Courses.aspx/.aspx.cs/.aspx.designer.cs; Admin/Dashboard.aspx/.aspx.cs/.aspx.designer.cs
- Member/Lesson.aspx/.aspx.cs/.aspx.designer.cs
- Learner/MyCourses.aspx/.aspx.cs/.aspx.designer.cs; Learner/CourseHome.aspx/.aspx.cs/.aspx.designer.cs
- Learner/MyResults.aspx/.aspx.designer.cs
- Helpers/CourseHelper.cs, Helpers/CaptchaHelper.cs
- Site.Master, Site.Master.cs, SiteMap.aspx.cs, Styles/site.css, LearningSystem.csproj
- docs/CONTRACTS.md, DECISIONS.md, QUESTIONS.md, PROGRESS.md, EVIDENCE.md

Existing public helper contracts and database schema preserved. CaptchaHelper internal methods accept an optional key, keeping Register's existing default. MyBookmarks replaces the old contract route; no duplicate Bookmarks page. Designers synchronized, new files included in project.

## Build

Visual Studio 18 MSBuild, LearningSystem.slnx /t:Build /p:Configuration=Debug /v:minimal /nologo: success, exit 0, no warnings/errors reported. One build after implementation. Documentation/screenshot project inclusion followed, with no compiled code change.

## Representative runtime checks actually performed

HTTPS used with the existing project-local IIS Express setup; one server start/stop. No database rebuild, alternate database/test app, certificate/trust changes or full regression.

1. A unique temporary active learner enrolled in existing published course 1: review form appeared; create rating 4 saved one owned row; edit to 5 updated that row with EditedDate, without duplication.
2. Same learner: Lesson Add bookmark saved one row; MyBookmarks showed Open lesson; Remove bookmark removed it.
3. Same learner with incomplete progress: Certificate redirected to AccessDenied and returned the expected denial page/status. The HTTP harness stopped on that non-success status; this was expected access control, not an application error. Remaining checks resumed without rerunning the review/bookmark cases.
4. One visitor Contact form with arithmetic response submitted a unique message with NULL UserID. Demo Admin opened it in Messages and marked it read; database IsRead changed as expected.
5. Demo Admin created one All-audience FAQ; visitor Help showed it. Temporary FAQ/contact message and learner-related fixture rows were removed transactionally after their checks; existing content was preserved.
6. Browser: Alt+C from Help navigated to Courses; Alt+Q while focused on the search input did nothing; Alt+Q on a link navigated to Help. Screenshot confirms managed FAQ, shortcut guidance and Contact navigation.
7. Representative core integration: successful learner/admin login; existing Quiz and Game preview pages loaded with their preview banners and new shared navigation. No new quiz/game submissions or broad activity replay was needed for these layout integrations.

## Manual follow-ups recommended

- Reviews: try another learner's ID through a crafted postback; teacher removal must fail, Admin removal succeeds with confirmation. Check non-enrolled and draft-course denial, invalid rating/comment, duplicate submissions and averages after edit/delete.
- Contact: verify prefill as each role, wrong/missing/expired CAPTCHA, unrelated validation preservation and separate Register/Contact tabs. Open/mark/delete in Admin and check unread counts. Non-admin direct inbox access must fail. Check inbox paging with real messages.
- Bookmarks: verify duplicate Add does not duplicate, preview creates nothing, leave/re-enrol retains rows, unpublished material/course remains unavailable and unauthorized posted material IDs fail.
- Certificate: use an actually completed enrolled learner/course; confirm the shared 100% condition, correct names and explicitly labelled current UTC print date. Inspect print preview in the team's browser; navigation/actions should be hidden. Try below100, zero items, another course, unenrolled and unpublished requests. No certificate record should be created.
- FAQs: edit/reorder/delete with disposable entries; test bounds, audience and role-specific Help groups, empty state and tied SortOrder. Confirm static guidance remains.
- Shortcuts: check Home/current-role dashboard and visitor no-op, all editable focus types, IME/repeats/modifiers in the team's browsers. Reserved browser/OS shortcuts may remain unavailable by design.
- Broad learner quiz/game submissions, all roles/widths and destructive/failure matrices remain for the dedicated final audit, not this phase.

## Limitations / partial items

All requested Tier B feature IDs are implemented. No known blocking Tier B issue. Positive certificate/print-preview, full moderation negative matrix and full FAQ editing matrix were not runtime-tested under this limited budget; manual steps above cover them. Prior missing real introductory media/subject images/contact details remain outstanding team content. Phase 14 stays deferred.