# Phase 8 implementation and verification

Implemented 2026-09-30 under approved Q33. Phase 9 has not started.

## Files created

- Teacher/GameBuilder.aspx, .aspx.cs and .aspx.designer.cs
- Member/PlayGame.aspx, .aspx.cs and .aspx.designer.cs
- Scripts/games.js
- Helpers/GameHelper.cs: strict JSON parsing, session runs, server timing, scoring and submission
- Helpers/GameContentHelper.cs: game settings/item/group operations, publish validation and owner-only results
- docs/PHASE8-VERIFICATION.md

## Files changed

- Teacher/CourseBuilder.aspx: Game Add, Edit and Preview actions
- Admin/Activities.aspx: authorized game preview links
- Helpers/CourseHelper.cs: published learner game links
- Styles/site.css: game controls, visible focus, mobile grids and reduced-motion support
- LearningSystem.csproj: includes all new application files and this report
- docs/CONTRACTS.md, docs/DECISIONS.md, docs/QUESTIONS.md and docs/PROGRESS.md

The learner/admin navigation changes make the requested game page accessible from existing entry points. No schema, packages, game sounds or Phase 9 functionality were added.

## Feature status

GAM-01–14 implemented: all four builders/players, Sort groups, publication and lock checks, result validation, saved attempts, best/history and owner-only teacher results. GAM-13/14 were explicitly requested in Phase 8 and are delivered here, although originally allocated to Phase 10.

PRV-01/02 now include material, Quiz, Discussion, SelfAssessment and Game; Scenario preview remains deferred. These are implementation statuses, not claims of runtime verification.

## Behavior and limits

- Builders recheck teacher ownership and attempt locks inside serializable transactions. Activity IDs, child IDs and group membership are checked again on mutation. Published edits must preserve validity or require unpublishing first.
- Matching requires at least 4 pairs; Memory 4–12; Scramble at least 3 words with hints; Sort 2–4 groups with at least 2 items each. Template changes are blocked while items or groups exist. Referenced Sort groups cannot be deleted until their items are moved/removed.
- Matching/Sort use native buttons for select/place with live status messages and no drag-and-drop. Memory counts the second flip as one move; Scramble uses labelled text inputs. Game JavaScript has one commented section per template. Phone CSS stacks matching/sort columns and shows two Memory cards per row.
- hfResult keeps the fixed JSON shape. Unknown/duplicate fields, invalid numeric types, duplicate or foreign IDs and mismatched template fields are rejected. Matching/Scramble/Sort scores are recomputed from current database content, with no client score accepted. Legitimate wrong answers lower the score; extra fields claiming a score are rejected.
- Memory uses database pair count and the Q33 formula with authoritative session elapsed whole seconds. The server checks positive integer moves >= pair count. As explicitly approved, the empty Memory answers array cannot prove every client card flip or independently verify reported moves.
- A learner game run needs published course/game plus enrolment. Missing/invalid session state and changed content definitions reject submission. Only a successful validated transaction creates an Attempt. Completed run tokens return the saved result rather than insert another row. Start time is preserved for an active run.
- Game attempts store two-decimal ScorePercent and server-measured TimeTakenSeconds, EndingStepID NULL. Learner submissions do not update Course.LastUpdated; successful authored changes do.
- Owner/admin preview includes drafts, uses the same scoring, shows a clear banner/result notice and creates no Attempt. Preview requires playable content to run; incomplete drafts explain which content minimum is missing. Transient feedback uses internal session key GamePreviewResult_{UserID}_{ActivityID} to select the completed preview run.
- Teacher results live within the owned GameBuilder and show learner names, dates, scores and time. Learner history/best and authorized saved results live on PlayGame. Attempts remain immutable.

## Build

One implementation build of LearningSystem.slnx, Debug, using Visual Studio 18 Community MSBuild succeeded: **0 warnings and 0 errors**. No compilation fixes were needed. No build was repeated for documentation-only changes.

## Verification actually performed

The first Phase 8 IIS Express launch was rejected before execution by automatic approval review with **blocked by policy**, without a more specific reason. As a result:

- Representative build/publish/play runtime flow: not run.
- hfResult tampering runtime check: not run.
- No-write preview runtime check: not run.
- Phone-sized browser check: not run.

No test records were created. No database rebuild, alternative test application/host, runtime retry, security-setting change, regression suite or full template matrix was attempted. Build success does not establish runtime behavior. Stopped at the required runtime limitation.

## Manual verification

Use the usual Visual Studio/IIS Express setup and disposable demo content for mutations.

1. **Build/publish all four templates:** CourseBuilder → Add Game → choose template → save Draft. Matching: add four distinct pairs. Memory: add four pairs. Scramble: add three 3–15-letter words with hints. Sort: create two groups and two items in each. Publish each, enrol a learner and open it through CourseHome. Save results only after completing the game.
2. **Matching mouse/touch/keyboard:** select a left item, then a right match. Repeat with touch and with Tab + Enter/Space. Selection/focus must be visible; status announces placement. Reassign a target and confirm its prior placement is freed. No dragging should be required.
3. **Sort mouse/touch/keyboard:** select an item then a group using mouse, touch and Tab + Enter/Space. Change a placement before submitting. The group list and item label must update.
4. **Memory:** flip a first card (no move yet), then a second (one move regardless of match). Mismatches flip back; matched cards stay exposed; submit only after all pairs are found. Check Q33 examples with controlled elapsed-time inputs during a dedicated test if desired: four pairs at (moves,seconds) (4,9)=100; (5,24)=93; (7,36)=82; (20,180)=2. Scores below zero clamp to zero. Submitted time cannot replace server time.
5. **Scramble:** type correct/incorrect words; verify trim/case-insensitive comparison. Non-letter or out-of-length nonempty answers are rejected. Wrong valid words lower the server score.
6. **Publish minimums:** attempt publication with insufficient pairs/words/groups/items. It must be blocked. Adding a 13th Memory pair or fifth Sort group must be rejected. Deleting content that would invalidate a published game requires unpublishing first.
7. **Template-change lock:** after adding items, attempt to change the template, including a crafted postback. Expect rejection. Empty groups must be deleted before changing away from Sort.
8. **Content lock after attempts:** once a learner submits, try item/group add/edit/delete and structural ordering/template changes, including crafted postbacks. All must be blocked; title/description/publication remain editable. Whole-game deletion must be blocked with Unpublish guidance.
9. **Forged hfResult:** capture a complete result POST and modify it without letting JavaScript overwrite the payload. Add a score field or use a foreign/duplicate ItemID/GroupID: expect rejection and no Attempt. Submit a valid complete set of wrong Matching/Sort assignments or wrong Scramble words: score must be recalculated below 100 regardless of claimed client success. Memory moves below database pair count must be rejected. Game answers are allowed in the page; recalculation validates submitted answers, not proof of human interaction.
10. **Best/history:** submit two fresh runs with different results; both should appear and best should equal the maximum score. Refresh the redirected result and repeat its completed run POST: no extra Attempt. Changing attemptId to another learner/activity must be denied.
11. **Teacher results:** open the game's builder as its owner; see only this game's learner attempts and no learner emails. A second teacher changing the game/topic URL must be denied.
12. **Preview saves nothing:** note Attempt count, preview a playable draft game as its owner, finish and submit. Result must state nothing was saved, no attemptId/history is created, and count remains unchanged. Repeat as admin from Activities. An ordinary learner cannot acquire preview access by adding preview=1.
13. **Unauthorized learner/course access:** logged-out users go to Login, non-enrolled learners are denied, drafts/unpublished course/game URLs return Not Found for learners, and unrelated teachers cannot preview/edit. Submission must recheck these rules even if access changed after Start.
14. **Phone-sized layout:** at about 390 × 844 pixels, check a representative game for readable text, no page-width overflow, tappable buttons, visible selection/focus and access to Submit/Cancel. Matching/Sort columns should stack; Memory should show two cards per row. No sound should play.

## Known gaps

All four requested runtime checks remain outstanding because runtime launch was policy-blocked. Memory's client-reported move limitation is the explicitly approved Q33 contract. Scenario, optional sound/mute and other later-phase work remain deferred. No new clarification is pending for this implementation.
