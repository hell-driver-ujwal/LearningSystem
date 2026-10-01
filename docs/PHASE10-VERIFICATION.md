# Phase 10 verification — 2026-09-30

Phase 10 is complete. No Phase 11 work, schema changes, packages, optional reviews or optional charts were introduced.

## Features

- ENR-04: all progress displays use the existing single ProgressHelper calculation; unchanged formula.
- ENR-05: real learner course/progress overview, shared type-appropriate recent results and shortcuts.
- ENR-06: owned-course enrolled learner names only.
- QZ-12/13: learner history with latest/best and owner-only quiz attempts/score summaries.
- RES-01: own saved Quiz/SelfAssessment/Game/Scenario attempts, course/activity filters, ten-row paging and authorized result links.
- RES-02: owner-only filters, attempts, per-learner/activity scored summaries; existing SelfAssessment per-statement and Scenario ending summaries reused.
- RES-03: real teacher counts and five recent own-course attempts.
- RES-04: existing Admin statistics verified; source already fulfilled the requested core scope.
- Only the optional MyResults review-link portion remains deferred to O5. O1 charts remain deferred. Existing SA/GAM/SIM history and summary semantics are preserved.

## Files created

- Learner/MyResults.aspx, .aspx.cs, .aspx.designer.cs.
- Teacher/Results.aspx, .aspx.cs, .aspx.designer.cs.
- Teacher/CourseLearners.aspx, .aspx.cs, .aspx.designer.cs.
- Helpers/ResultsHelper.cs: current-user scoped reporting, filter authorization, common result formatting and saved-score summaries.
- docs/PHASE10-VERIFICATION.md.

## Files changed

- Learner/Dashboard.aspx and .aspx.cs: shared result formatting, actual result links, MyResults shortcut and current empty state.
- Teacher/Dashboard.aspx, .aspx.cs, .aspx.designer.cs: real own-course counts and recent attempts.
- Teacher/MyCourses.aspx: results and enrolled-learner links.
- Teacher/CourseBuilder.aspx, .aspx.cs, .aspx.designer.cs: course results and learner-list links.
- LearningSystem.csproj: new pages, designers, reporting helper and report entries.
- docs/CONTRACTS.md, docs/DECISIONS.md, docs/PROGRESS.md: reporting conventions, explicit optional deferrals and completion evidence.

Admin/Dashboard was inspected and runtime-verified; its existing implementation already uses real Admin-only core queries, so it did not require modification. ProgressHelper and its formula were also left unchanged. No unrelated activity builders/players were changed.

## Build

Visual Studio 18 Community MSBuild, LearningSystem.slnx /t:Build /p:Configuration=Debug: exit 0, LearningSystem.dll produced, no reported compiler errors or warnings. One implementation build. No rebuild after documentation-only updates.

## Actual minimal checks

Used one IIS Express process serving the existing application on localhost:52181, HTTP Web Forms sessions and read-only parameterized SQL assertions. No new test fixture, database rebuild, duplicate application, security changes or broad matrix. The host was stopped after these checks.

1. **Hand-calculated progress:** existing LearnerID 7 / CourseID 1 had 5 completed published items among 6 published items. Read raw published material/activity IDs and retained completion/attempt/discussion records, counted each item once, and calculated 5 / 6 * 100 = **83.33%** with the approved rounding. CourseHome displayed **83.33%**. Source inspection confirmed that display directly invokes CourseHelper.Progress -> ProgressHelper.CalculatePercent; no separate test endpoint or replacement formula was introduced. Learner Dashboard, MyCourses and CourseHome are the course-progress display callers and all use that same path.
2. **Learner:** signed in with an existing demo account. Dashboard showed its real recent saved Scenario result. MyResults filtered by CourseID/ActivityID showed that learner's saved Scenario outcome.
3. **Teacher:** dashboard own-course and distinct enrolled-learner counts matched SQL, and recent attempts included the saved own-course result. Results loaded its existing Scenario outcome summary. CourseLearners displayed the five enrolled learner names without their email addresses. Changing course IDs in both Results and CourseLearners to another teacher's course redirected to AccessDenied.
4. **Admin:** displayed pending application and total Attempt counts matched SQL. Displayed counts for all three user roles and one representative subject's course count also matched SQL.

These reporting checks created no content, enrolment or Attempt records and performed no test writes to Course.LastUpdated. Ordinary login/session behavior was used. Tests did not manufacture large datasets for pagination.

## Manual steps for the team

1. **Progress across all types:** on a disposable published course, note the number of published materials/activities. Complete a material; submit Quiz, SelfAssessment, Game and Scenario attempts; create a Discussion post/reply. Check each published item contributes once on Dashboard, MyCourses and CourseHome, even after repeat attempts. Draft items do not contribute. Delete the last qualifying discussion contribution through the authorized UI and confirm that discussion no longer contributes.
2. **Zero items:** with an existing enrolled course whose content is all unpublished, expect 0% without a divide-by-zero error. Do not change the rule requiring a published item when initially publishing a course.
3. **Leave/re-enrol:** note progress, leave through MyCourses, then re-enrol when the course is published. Retained completions/attempts/contributions should restore calculated progress. Historical results stay visible in MyResults after leaving; detailed content links require current access.
4. **Learner isolation:** log in as two different learners and compare MyResults/recent dashboard rows. Try another learner's course/activity filter and saved result ID; no other learner's results may appear. Unpublished historical summaries remain visible to their author, without a link into unavailable content.
5. **Teacher isolation:** filter Results by an owned course/activity and inspect names, attempts and summaries. Change CourseID/ActivityID to another teacher's data or combine mismatched course/activity IDs, including a crafted filter postback. Expect Access Denied and no foreign rows.
6. **CourseLearners:** open from MyCourses or CourseBuilder. Expect only current enrollee names, no email column or email in rendered HTML. Tampering to an unowned course must be denied; an empty owned course has an empty-state message.
7. **Confidence:** filter a SelfAssessment. Learner attempts should show confidence with two decimals out of 5 and the approved level, never a percentage score. Teacher Results should show the existing per-statement class averages and rating counts. Quiz/Game score summaries exclude assessments.
8. **Scenario:** filter a completed Scenario. Confirm the reached ending/outcome appears, with no numeric score. Teacher counts by ending/outcome must agree with saved attempts. Preview runs must not appear.
9. **Dashboard counts:** compare teacher own-course count (drafts included) and distinct currently enrolled learner count with their courses. Compare Admin users by role (inactive included), courses by subject (drafts included), pending teachers and attempts with SQL. Learner dashboard should show actual enrolled courses and its five latest attempts.
10. **Filters and paging:** use a dataset already containing more than ten saved attempts. Select a course then an activity, move between result pages, clear filters, and test an empty selection. Expect ten attempts per page, newest SubmittedAt then AttemptID first, and summaries calculated across the full selected history. Do not create bulk fixtures merely for this check.
11. **Latest/best:** submit a later quiz/game attempt with a lower score. Latest should change; best should retain the earlier higher saved score. Teacher summaries group by learner and activity rather than mixing confidence/outcomes into percentages.
12. **Review deferral:** verify there are no optional course-review links or review forms on MyResults. Core authorized activity-result links should work.
13. **Chart deferral:** Results and Admin statistics use tables/counts, with no optional chart implementation.

## Limits and open questions

No unresolved Phase 10 requirement. The limited runtime check used existing Scenario results; confidence, quiz/game aggregates, all activity-progress combinations and multi-page datasets remain manual as requested. No exhaustive regression was run. Optional review links and charts remain deliberately deferred. All reporting is read-only; progress remains calculated, never stored.
