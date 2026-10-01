# Phase 9 verification — 2026-09-30

Phase 9 is implemented. SIM-01–13 and the remaining Scenario portions of PRV-01/02 are complete in code. Q11 is resolved and recorded; its original historical question remains. Phase 10 was not started. Existing partial features outside Phase 9 are unchanged.

## Files created

- Teacher/ScenarioBuilder.aspx, .aspx.cs, .aspx.designer.cs: owned-course creation, settings/publication, step images/alt text, step/choice CRUD, start selection, content locks, confirmed deletion and owner-only outcome summary.
- Member/Scenario.aspx, .aspx.cs, .aspx.designer.cs: enrolled published play, session-authoritative current step, validated transitions, saved ending/feedback, restart and owner/admin draft preview.
- Helpers/ScenarioHelper.cs: shared Scenario authoring, image rendering, publication checks and contracted CheckStep/DeleteStep implementations.
- Helpers/ScenarioPlayHelper.cs: session run/token/revision, structural fingerprint, access checks and transactional ending attempts.
- docs/PHASE9-VERIFICATION.md: this report.

## Files changed

- Teacher/CourseBuilder.aspx: Scenario Add/Edit/Preview links.
- Helpers/CourseHelper.cs: enrolled learner Scenario outline link.
- Admin/Activities.aspx: authorized Scenario preview link (required integration with the existing admin module).
- Styles/site.css: responsive Scenario image rule.
- LearningSystem.csproj: all new page, designer, helper and report entries.
- docs/CONTRACTS.md, docs/DECISIONS.md, docs/QUESTIONS.md: Q11 resolution and Phase 9 conventions; historical question preserved.
- docs/PROGRESS.md: implementation status, actual build/smoke outcomes and stop condition.

## Build

Ran Visual Studio 18 Community MSBuild on LearningSystem.slnx, Debug, /t:Build. Exit code 0; LearningSystem.dll produced. No compiler errors or warnings reported. One implementation build; no rebuild for final documentation changes.

## Minimal runtime checks actually performed

IIS Express served the existing application on localhost:52181. A single temporary PowerShell HTTP smoke script used the real Web Forms, cookies, ViewState, event validation and postbacks. SQL was read-only for fixture discovery and assertions; application postbacks performed the authorized representative writes. No database script/rebuild, test application copy, security changes or broad test matrix.

1. **Successful build/publish/play:** existing owner created a disposable Draft Scenario in a published course through ScenarioBuilder. Added one non-ending, one Best ending with feedback, a connecting choice and the start step. Published successfully. An already-enrolled learner started and selected the choice, reaching the ending via PRG. Exactly one Attempt was added; EndingStepID matched the ending and ScorePercent/TimeTakenSeconds were NULL.
2. **Invalid publish:** Check & Publish on the empty Scenario showed the publication validation message and left Status=Draft.
3. **Invalid path/choice:** captured the learner's current choice form, restarted the run, then submitted that stale form once. The server rejected its outdated run/revision with the current-step message; it neither advanced the new run nor created an Attempt. A fresh current form then completed the happy path above. This was one targeted authorization/path check, not repeated replay/stress testing.
4. **No-write preview:** the owner started the same Scenario while still Draft and reached its ending in preview. The preview banner/result appeared and the Scenario Attempt count remained unchanged at zero.

Retained smoke data: ActivityID **9**, CourseID **1**, LearnerID **7**; two steps, one choice and one completed learner Attempt. The Scenario title begins `Phase 9 smoke scenario`. These records were left intact; no destructive cleanup was performed. The IIS Express process started for this phase was stopped after the checks.

## Manual checks for the team

Use a separate disposable Scenario for structural tests, because the smoke Scenario now has an Attempt and is intentionally locked.

1. **Multiple endings:** create one start with choices to Best, Acceptable and Poor endings, each with feedback. Publish and complete separate runs. Check that each result has the chosen ending/outcome; score and time stay NULL.
2. **Loop:** before any attempts, create A → B → A plus a route to an ending. Publication must allow the cycle. Play A → B → A and then choose the ending route; only the ending creates an Attempt.
3. **Invalid publication:** try no start, no ending, or a non-ending without choices. Each must stay Draft with a clear error. An ending requires a valid outcome/feedback and cannot retain outgoing choices. Forged foreign or self destinations must be rejected. Converting an ending to a non-ending clears its outcome/feedback.
4. **Referenced step deletion:** try deleting a destination with incoming choices. It must be blocked. Remove incoming choices first; if it is not the start and no attempts exist, deletion is allowed (and deletes its outgoing choices transactionally).
5. **Current StartStep:** deletion is blocked until another start is selected. Changing the start is allowed before attempts; after the first Attempt both start changes and all step deletion are blocked. Whole-Scenario deletion without attempts retains the approved Q29 behavior.
6. **Forged/skipped navigation:** append `stepId` or `nextStepId` to the play URL; access is denied. Attempt a choice from another step/scenario or a stale tab after restarting; no skipped ending or Attempt may be created. Do not alter ViewState validation settings to test this.
7. **Restart:** finish, refresh the saved result, then restart. Refresh/restart alone must not add an Attempt. Reaching an ending in the new run adds exactly one. If an ending is configured as the start, explicit Finish completes it; Start/Restart alone saves nothing.
8. **Content lock:** after a normal Attempt, try step/choice add, edit, delete, start selection and structural order changes, including a form opened before the Attempt. All must be blocked server-side. Title/description and valid publish/unpublish remain editable. Scenario deletion with attempts is blocked; use Unpublish.
9. **Teacher summary:** open the owner's builder after multiple completed runs. Counts grouped by ending step/outcome must match saved Attempts. A second teacher cannot open the builder/summary by changing the URL. Preview must not increase counts.
10. **Preview:** as owner and then admin, preview both Draft and Published Scenarios to an ending. Confirm the banner and feedback and unchanged Attempt count. Preview must not create enrolments, completions or other learner records. Try `preview=1` as a learner or unrelated teacher; access must be denied.
11. **Learner access:** signed-out users must log in; unenrolled learners must be denied; draft activity/course requests must return Not Found. Attempt result IDs must belong to the signed-in learner and requested Scenario, with current access still required.
12. **Optional step image UI:** upload an allowed image with required alt text, then replace/remove it before attempts. Check display and old unreferenced file cleanup. Missing alt text, wrong extension and oversized files must be rejected by server validation. No exact byte-boundary or failure-injection testing is required here.

## Known limits / remaining questions

No unresolved Phase 9 requirement. The four requested representative checks passed; multiple endings/loops, admin preview, image uploads, all content-lock/deletion combinations and broader authorization cases remain manual, as required by the verification budget. Preview was measured for Attempt creation, not a sweep of every learner table. Implementation has no learner-data write in its preview branch. Session idempotency protects the current browser session/run; no cross-session guarantee or database column was added. Step images are embedded only in the authorized page from validated database paths, leaving the Media.ashx contract and direct-upload block unchanged.
