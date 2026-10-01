# Phase 7 implementation and verification

Implemented 2026-09-30. Phase 8 has not started.

## Files created

- Teacher/SABuilder.aspx, .aspx.cs and .aspx.designer.cs
- Member/SelfAssessment.aspx, .aspx.cs and .aspx.designer.cs
- Helpers/SelfAssessmentHelper.cs
- docs/PHASE7-VERIFICATION.md

## Files changed

- Helpers/ActivityHelper.cs: self-assessment publication validation and structural ordering lock
- Helpers/CourseHelper.cs: learner links to published self-assessments
- Teacher/CourseBuilder.aspx: Self-Assessment Add, Edit and Preview actions
- Admin/Activities.aspx: authorized self-assessment preview link
- LearningSystem.csproj: includes new application files and this report
- docs/CONTRACTS.md, docs/DECISIONS.md, docs/QUESTIONS.md and docs/PROGRESS.md

Learner/admin navigation changes connect the requested pages to existing entry points. No schema, packages, new result page or Phase 8 functionality was added.

## Implemented features

SA-01–10 implemented. SA-09 personal history and SA-10 class summary were explicitly requested for Phase 7 and are delivered here rather than waiting for Phase 10.

- Owner-only builder: activity metadata/order/publication, statement add/edit/delete/order and per-statement class confidence averages across all submitted attempts.
- At least one valid statement is required to publish. Attempts lock statements and structural ordering. Title/description/publication remain editable. Whole-activity deletion uses the existing attempt block.
- Every statement requires an integer rating 1–5. ASP.NET required/range/custom validation is backed by transactional checks of every statement ID and rating. Changed statement definitions reject stale open forms.
- Successful learner submission creates one Attempt and all SAResponse rows in one transaction, followed by PRG. ScorePercent, TimeTakenSeconds and EndingStepID remain NULL. The existing session form-token mechanism rejects replay of a saved form; a fresh form allows an unlimited new attempt.
- Personal history shows dated confidence averages and levels; each authorized attempt can show its individual statement ratings. Results stay on Member/SelfAssessment with the contracted attemptId parameter.
- Q09 fixed feedback uses the unrounded decimal average. Display uses exactly two decimal places. Confidence is never presented as a quiz/game score.
- Owner/admin preview includes draft content, displays an explicit no-save banner, and shows feedback using temporary session state. It creates no Attempt or SAResponse. Preview never displays a saved learner history.
- Existing activity access helpers enforce current role, publication, ownership and enrolment. Submission rechecks access within the transaction. Teacher class-summary queries recheck course ownership.
- Course.LastUpdated changes only for successful authored-content mutations; learner submissions and preview do not change it. Shared calculated progress already recognizes submitted SelfAssessment attempts.

PRV-01/02 now include materials, Quiz, Discussion and SelfAssessment; Game/Scenario preview remains deferred.

## Q09 resolution

Exact team-supplied labels/text and thresholds are recorded in CONTRACTS.md and DECISIONS.md. Original Q09 remains in QUESTIONS.md with an appended resolution. Classification is below 2.50, 2.50 to below 4.00, or 4.00 through 5.00; the rounded display value never determines the classification.

## Build and verification

One implementation build of LearningSystem.slnx, Debug, using Visual Studio 18 Community MSBuild succeeded with **0 warnings and 0 errors**. No compilation fixes were needed. Documentation-only updates do not require another build.

The first Phase 7 IIS Express launch was rejected before execution by automatic approval review with **blocked by policy**, without a more specific reason. Therefore none of the three requested runtime smoke checks ran. No test Attempt/SAResponse rows or other test data were created. No database rebuild, alternate host, runtime retry, isolated application or security-setting change was attempted.

Runtime verification remains outstanding. Build success alone does not establish runtime behavior. Stopped as instructed rather than expanding verification.

## Manual checks

Use the normal Visual Studio/IIS Express setup and disposable demo content for edits.

1. **Successful complete submission:** create a Draft SelfAssessment in CourseBuilder, add statements and publish. As an enrolled learner, rate every statement and submit. Expect redirect back with attemptId, average/feedback, saved ratings and one new history entry. Verify one Attempt plus one SAResponse per statement, with ScorePercent/TimeTakenSeconds/EndingStepID NULL; course progress should reflect completion and Course.LastUpdated should not change.
2. **Every statement required:** leave one rating blank and submit, including with client JavaScript disabled. Expect validation and no new Attempt/SAResponse rows.
3. **Invalid ratings server-side:** alter a posted rating to 0, 6 or a non-integer, or remove a rating input. Expect rejection without new rows. Change a posted StatementID to a different assessment's statement: it must also be rejected.
4. **Feedback boundaries:** verify unrounded average values below/at 2.50 and below/at 4.00. 2.49 is Needs Improvement; 2.50 and 3.99 are Developing; 4.00 is Confident. When an unrounded value below a threshold rounds to that threshold for display, its level must remain in the lower band. Verify the exact supplied feedback text and two-decimal display.
5. **Repeat/history comparison:** submit a fresh form with different ratings. Both attempts must remain visible with their own dates, averages and statement ratings. Refreshing the result does not submit another attempt; replaying a previously saved form is rejected.
6. **Statement lock:** after a submitted attempt, try adding/editing/deleting a statement and changing structural order, including crafted postbacks. Expect denial and unchanged content. Title/description and publication can still change. Before attempts, edit statements while a learner form is open: the stale submission must save nothing.
7. **Teacher class summary:** open SABuilder as the owning teacher. Compare each statement's displayed average and response count against all submitted learner attempts, including repeats. Unrated statements show No ratings yet. A second teacher changing the activity ID must be denied.
8. **Teacher/admin preview (third requested smoke check):** note Attempt/SAResponse counts, preview a draft assessment as its owner and submit all ratings; repeat as admin through Activities. Expect the preview banner and feedback saying nothing was saved, no attemptId/history, and unchanged database counts. Normal learner attempts must not be created in preview.
9. **Unauthorized access:** an unenrolled learner must be denied; a learner requesting a draft assessment/course must receive Not Found. An unrelated teacher cannot preview or edit it. Change attemptId to another learner's attempt or an attempt from another activity: access must be denied. Forging preview=1 as a learner must not grant access.

## Known gaps

The only Phase 7 verification gap is the blocked runtime launch: all three representative checks and broader manual cases remain unexecuted. Q09 is resolved; no new clarification is pending. Existing Phase 6 runtime limitations remain unchanged. Phase 8 and other deferred activity functionality have not started.
