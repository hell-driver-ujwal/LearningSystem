# Phase 6 implementation and verification

Completed implementation on 2026-09-30 under approved Q32. Phase 7 has not started.

## Files created

Each page includes .aspx, .aspx.cs and .aspx.designer.cs:
- Teacher/QuizBuilder
- Teacher/DiscussionEdit
- Member/Quiz
- Member/QuizResult
- Member/Discussion

Shared support: Helpers/ActivityHelper.cs, Helpers/ActivityAccessHelper.cs, Helpers/ContentLockHelper.cs, Helpers/DiscussionHelper.cs, Helpers/QuizHelper.cs (also contains the contracted QuizSubmissionAnswer and SubmissionHelper), Scripts/quiz.js and this report.

## Files changed

- Teacher/CourseBuilder.aspx and .aspx.cs: Quiz/Discussion Add, Edit, Preview and ordinary discussion moderation links
- Admin/Activities.aspx and .aspx.cs: preview links, discussion access, transactional unpublish timestamp updates
- Helpers/AccessHelper.cs, Helpers/PublishHelper.cs, Helpers/DeleteHelper.cs: partial class extensions; activity deletion updates the owning course timestamp
- Helpers/BreadcrumbHelper.cs: activity and saved-attempt trails
- Helpers/CourseHelper.cs: learner Quiz/Discussion links; other activity players remain deferred
- Styles/site.css and LearningSystem.csproj
- docs/CONTRACTS.md, docs/DECISIONS.md, docs/QUESTIONS.md and docs/PROGRESS.md

The admin and learner navigation changes connect the requested Phase 6 pages to existing entry points. No database schema, NuGet package or Phase 7 feature was added.

## Features implemented

QZ-01–11: quiz settings, question/option editing, publication validation, attempt-based content/settings locks, blocked deletion, intro, timer, server-marked submission and authorized saved-result review.

DSC-01–11: discussion settings/publication/closure, thread/reply rendering, author editing/deletion, owner/admin moderation, one-level replies, transactional parent/reply deletion and access rechecks inside mutations.

PRV-01/02: quiz/discussion portions implemented in addition to existing material preview. Remaining activity types stay deferred. Owner/admin preview includes drafts, ignores learner quiz attempt limits, displays a banner and exit link, and writes no learner records. Preview quiz feedback stays on Member/Quiz in transient session state.

## Q32 behavior

- Start saves only session state. Repeated Start preserves the active run's time/token. Attempt and QuizAnswer rows are created only by successful final submission in one transaction.
- Correct-option flags remain server-side before submission. Weighted marks, unanswered NULL selections and two-decimal AwayFromZero rounding determine results.
- Server checks time plus 30 seconds, run/user/token, published access/enrolment, submitted question/option relationships, definition fingerprint and remaining attempts. Timed-out/missing/changed runs save nothing.
- Completed runs retain their AttemptID; repeat submissions return that result. No cross-session/browser idempotency is claimed. The attempt limit is checked transactionally.
- Saved submissions use Post/Redirect/Get. Quiz preview uses separate session state and redirects back to Member/Quiz for feedback (the internal QuizPreviewResult_{ActivityID} session key selects the completed preview run).
- Closed discussions disallow author mutations while retaining authorized moderation outside preview. Draft course/discussion content is preview-only for owner/admin.
- Authored activity changes touch Course.LastUpdated transactionally. Learner attempts and discussion contributions/moderation do not.

## Build result

Visual Studio 18 Community MSBuild built LearningSystem.slnx, Debug configuration successfully: **0 warnings and 0 errors**. The implementation build passed; a build after the final compiled validation/timestamp changes also passed. No build was repeated for these documentation-only updates.

## Runtime limitation and checks actually performed

The first runtime launch command attempted to start project-local IIS Express for the actual workspace on localhost:52181. Automatic approval review rejected the command before execution with **blocked by policy**, without a more specific explanation. Therefore:

- No Phase 6 runtime smoke check was executed.
- No quiz attempt, answer, discussion post or other test database record was created.
- No database rebuild, isolated test application, alternate host, security-setting change or retry was attempted.
- Runtime verification remains outstanding; build success alone does not establish runtime success.

Stopped as instructed for an environment/runtime block. The four requested checks should be performed manually below.

## Manual verification

Use Visual Studio/IIS Express as normally configured and disposable demo content where changes are needed.

### Four representative smoke checks

1. **Quiz success:** as owner, create a Draft quiz under a topic, save at least one question with 2–6 distinct choices and one correct answer, then publish. As an enrolled learner, Start, select answers and Submit. Confirm redirect to QuizResult, weighted score, unanswered questions marked wrong, and one Attempt with one QuizAnswer per question. The result must not expose another learner's attempt by changing its ID.
2. **Quiz security:** while playing, use browser developer tools to change one radio value to an option belonging to another question/quiz. Submit. Expect rejection with no Attempt/QuizAnswer rows. Inspect the pre-submit HTML: it must not label correct options or include IsCorrect flags.
3. **Discussion success:** open a published discussion as an enrolled learner, post, reply to a top-level post and edit your contribution. Confirm encoded text and UTC dates; replies cannot themselves be replied to. Confirm learner course progress recognizes a surviving contribution.
4. **Discussion authorization:** log in as a second enrolled learner. Editing/deleting the first learner's contribution must be unavailable. Submit a crafted postback targeting that other PostID; it must be denied with the original content unchanged. The server rechecks authorship even if a control is forged.

### Required broader manual cases (not run automatically)

- **Timer expiry:** use a short timed disposable quiz. At zero the browser submits automatically. Separately disable JavaScript, wait beyond the configured limit plus 30 seconds, then Submit: nothing is saved and restart is required. Lost/expired run state must also save nothing.
- **Attempt limit:** use a quiz with MaxAttempts=1 and complete it. Start becomes unavailable; a crafted Start/Submit must not add another attempt. MaxAttempts=0 is unlimited.
- **Refresh/repeated submission:** refresh the redirected result and resubmit the original completed play POST in the same session. Confirm the same AttemptID and unchanged Attempt/QuizAnswer counts. Repeated Start before submission must not reset the timer.
- **Structural lock:** after one attempt, try question/option add/edit/delete and changing time, attempt limit or structural order, including a forged POST. All must be blocked. Title/Description and publication remain editable. Before any attempt, change a quiz definition while a learner has it open: their old submission must be rejected.
- **Author isolation:** attempt to edit/delete another learner's post through a crafted URL/postback as described above. Also verify non-enrolled learners and non-owner teachers cannot access the discussion.
- **Preview saves nothing:** as owner and then admin, preview a draft quiz, answer and submit. Feedback must remain on Member/Quiz; Attempt/QuizAnswer and all other learner-data counts stay unchanged. Preview a draft discussion; posting/reply/edit/removal must be disabled and forged mutation requests denied. Use ordinary published discussion access for moderation.
- **Closed discussion:** close a disposable discussion. Authors cannot post/reply/edit/delete; owning teacher/admin can still remove posts outside preview. Confirm removal warns that all replies, including other authors' replies, will be removed. Deleting the last qualifying learner contribution removes its calculated completion.
- **Navigation:** CourseBuilder provides Quiz/Discussion Add/Edit/Preview; CourseHome opens published learner activities; Admin/Activities provides previews and discussion moderation. Draft/unpublished learner URLs return Not Found. Check breadcrumbs, Cancel and preview Exit.

## Known gaps and deferred work

Runtime checks are outstanding because the launch was policy-blocked. Q32 has no remaining implementation question. QZ-12/QZ-13 history/consolidated teacher results remain in Phase 10; other activity builders/players and their previews remain in their assigned phases. No claim of full runtime or edge-case verification is made.
