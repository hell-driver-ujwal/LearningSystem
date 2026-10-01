# Phase 5 implementation and verification

Completed 2026-09-30 under approved Q31 and the limited verification budget. Phase 6 has not started.

## Files created

Each new page includes its .aspx, .aspx.cs and .aspx.designer.cs files:
- Courses, CourseDetails, Preview, Help
- Learner/MyCourses, Learner/CourseHome, Member/Lesson
- Media.ashx and Media.ashx.cs
- Helpers/ProgressHelper.cs, Helpers/CourseHelper.cs, Helpers/MaterialHelper.cs
- docs/PHASE5-VERIFICATION.md

## Files changed

- Default, About and Learner/Dashboard page trios
- Helpers/AccessHelper.cs and Helpers/BreadcrumbHelper.cs
- Site.Master.cs, Styles/site.css, Web.config, LearningSystem.csproj
- Teacher/CourseBuilder.aspx: owner material-preview links
- Admin/Courses.aspx and Admin/Courses.aspx.cs: read-only material-preview links, including drafts
- docs/DECISIONS.md, docs/CONTRACTS.md, docs/QUESTIONS.md and docs/PROGRESS.md

The teacher/admin changes make the Phase 5 preview viewer discoverable. New application files are included in the Web Application project. No schema, package or activity player was added.

## Feature status

Completed: PUB-02 through PUB-09, MAT-07 through MAT-09, ENR-01 through ENR-05.

Partial: PUB-01 (real introduction media/poster and subject images missing); PUB-10 (real contact details missing); PRV-01/PRV-02 (materials complete, activity previews deferred). Cross-cutting SYS-03/SYS-13/SYS-19 now include Phase 5 access, breadcrumbs and transactional leave; later modules still need their portions.

All six material viewers, PDF download authorization, previous/next navigation, unavailable courses, confirmed leave and retained-data re-enrolment are implemented. Progress is calculated using the shared Q31 method, including published activities backed by existing attempts or surviving discussion contributions; Phase 6 submission functionality is not implemented.

## Build

Built LearningSystem.slnx with Visual Studio 18 Community MSBuild, Debug configuration. Fixed CS0108 by renaming the catalogue PreviousPage handler. The resulting build succeeded with **0 warnings and 0 errors**. Documentation-only updates after this result do not require another build.

## Smoke checks actually performed

IIS Express served the actual workspace on localhost:52181. Only the approved representative checks were performed:

1. Public Courses returned HTTP 200; published course IDs 1–4 appeared and draft course ID 5 did not.
2. Existing learner ID 8 enrolled in course ID 2, opened text material ID 4, marked it complete and saw progress change from **0% to 25%**.
3. A visitor opened an existing published free-preview text material. An ordinary lesson redirected to Login. Direct access to an existing upload path returned 404.
4. An owner teacher opened a draft material in preview mode. The banner appeared and Mark complete was absent. Before/after row counts were unchanged in Enrolment, MaterialCompletion, Attempt, QuizAnswer, SAResponse, DiscussionPost, Bookmark and Review.

The initial free-preview fixture lookup found no free-preview image, so the remaining visitor check used an existing text preview; the already passed learner flow was not repeated. No runtime claim is made for every media type or admin preview.

The learner smoke intentionally leaves two records in the existing database: Enrolment for learner 8/course 2 and MaterialCompletion for learner 8/material 4. No other test data was created. No database script/rebuild, separate test application, failure simulation, security changes or exhaustive regression was performed.

## Manual checks for the team

Use disposable demo content for changes; these broader checks were not run automatically.

1. Browse Home, About and Help. Search/filter the catalogue, move between pages, and open a course outline. Confirm only published content is public and timestamps say UTC.
2. Log in as a learner, enrol, study a lesson, mark complete, and use Previous/Next. Compare progress and done ticks across Dashboard, My Courses and Course Home.
3. Leave with confirmation and re-enrol. Confirm completion remains. Have the owner unpublish a disposable enrolled course: My Courses should say Currently unavailable and direct course/lesson URLs should return Not Found.
4. Review representative image alt/caption, PDF view/download, MP4, MP3 and YouTube playback. YouTube requires internet. Public free-preview PDF download should work; ordinary files must require enrolment and direct Uploads URLs must stay blocked.
5. Preview draft material as its owner and as admin using their course lists/builders. Confirm the banner, Exit preview and no completion action. Another teacher must be denied; learners must not see drafts even with preview=1.
6. When later activity phases exist, confirm a submitted attempt counts regardless of outcome and the last deleted discussion contribution removes that activity from completion. No activity functionality needs to be built for this Phase 5 review.

## Known gaps

The team still needs to supply introduction media/poster, subject images and real contact details. Approved labelled placeholders remain. Activity players/builders, certificates, optional bookmarks/reviews and consolidated results remain deferred. No new approval question is open for the implemented Phase 5 scope.
