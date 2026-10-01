# Phase 3 Admin verification — 2026-09-29

Implemented Dashboard, Users, UserEdit, TeacherApplications, Subjects, Courses and Activities under Admin/, with code-behind and designers. Added Helpers/ValidationResult.cs, Helpers/DeleteHelper.cs and the deletion portion of Helpers/UploadHelper.cs. Updated LearningSystem.csproj, Styles/site.css, .gitignore and the decision/contract/question/progress documents. No new packages, schema changes or optional pages were introduced.

Completed CRS-01–04, CRS-13–14, ADM-02–11 and RES-04 counts. ADM-01 was already completed in Phase 2. SYS-19 is complete for Phase 3 operations but remains partly marked overall because later phases own standalone topic/material/post/step deletion and teacher access to deletion helpers.

## Executed checks

- Visual Studio 18 MSBuild built LearningSystem.slnx successfully with no warnings or errors introduced.
- Ran the unchanged Database/CreateDatabase.sql against a separate LocalDB instance and temporary App_Data folder. Seed checks and detach succeeded. The workspace's existing database and upload files were not changed by tests.
- Served a temporary application copy through IIS Express. All seven Admin pages returned 200, with one h1 and the master breadcrumb. Tests submitted actual Web Forms hidden fields/event validation and postbacks; no JavaScript was used to satisfy validation.
- Subject create, edit, delete, case-insensitive uniqueness, minimum length and referenced-subject blocking passed.
- Learner/teacher creation, teacher creation without a reason, fixed role, duplicate email, search, literal wildcard search, empty state, role filtering, user paging, activity filtering/paging, status changes and stale status-post replay passed.
- Password reset worked at login. Invalid reset passwords did not change the hash. Deactivation removed an existing learner session's protected access. All seven pages rejected learner access; invalid/admin user edit IDs were blocked. Two admin rows had disabled controls, and forged delete/deactivate posts preserved both accounts.
- Pending application approval/rejection and UserEdit preservation of application states passed.
- Teacher owning courses was blocked from deletion; teacher without courses could be deleted.
- Course/activity deletion with attempts was blocked; unpublish retained attempts. Standalone deletion of every activity type and whole-course deletion containing all five types passed, including GameItem/Group references and Scenario StartStepID/choices/steps.
- Learner deletion removed attempts, quiz answers, self-assessment responses, posts, other authors' replies to their top-level posts, completions, enrolments, bookmarks and reviews. Other reply authors remained. ContactMessage retained sender/history fields with UserID NULL.
- Test-only SQL triggers deliberately failed user/course deletion after child changes. The transaction restored the account/content graph, attempts and contact links; files remained intact. These triggers existed only in the temporary test database.
- A locked upload caused post-commit file deletion failure: records remained deleted, the page reported manual cleanup and App_Data/FileCleanup.log recorded the validated path. A path outside the allowed upload naming rules blocked before SQL deletion and was not logged.
- DBCC CHECKCONSTRAINTS WITH ALL_CONSTRAINTS returned no violations after the tests.

## Manual click-through for the team

Use a disposable demo database for deletion tests. The database rebuild script is destructive; do not run it against work you need to preserve. Log in as admin@example.test / Password123.

1. **Dashboard:** compare users by role, courses per subject, pending applications and attempts with database counts. Zero-course subjects should still appear. Follow the pending-applications link.
2. **Subjects:** create a temporary subject, edit its description/name and delete it. Try a duplicate name with different capitalization, a one-character name and an overlong description. Try deleting IT/another subject used by a course: it must remain with a clear blocked message.
3. **Users / UserEdit:** create an Active learner and a Deactivated teacher without an application reason. Edit name/email; role must remain fixed. Try an existing email. Set a temporary password using Reset password and confirm it works at login. Try a short password: it must fail. Ordinary edits must not require a password.
4. **Search / paging / status:** search by name/email, combine role/status filters, try no matches and use page 2 with more than ten users. Deactivate then activate the test learner. A learner already signed in must lose protected access after deactivation. Admin rows must have all actions disabled; opening UserEdit.aspx?id=1 directly must show Access Denied.
5. **Applications:** approve Ravi's pending application and verify Active login. In a rebuilt/disposable demo, reject it instead and verify rejected login. Open a Pending/Rejected account in UserEdit: its application state must remain unchanged when saving name/email.
6. **User deletion:** delete an unused teacher successfully; try deleting Asha while she owns courses and confirm blocking. Delete a seeded learner who has attempts/posts. Inspect QuizAnswer/SAResponse before Attempt, all account-dependent rows, and replies to their parent posts: none may be orphaned. Contact history must remain with UserID NULL. Do not delete real team accounts.
7. **Courses / Activities:** try deleting seeded content with attempts: it must remain and offer Unpublish. Unpublish it and confirm Draft status with attempts retained. Delete disposable unattempted content containing quiz, self-assessment, discussion replies, grouped game items and scenario steps/choices. The whole scenario's start pointer must not prevent deletion. Confirm uploaded files disappear only when no surviving record references them.
8. **Activity list / access:** filter each activity type, exercise paging when more than ten match, and confirm empty states. Discussion navigation remains disabled until its Phase 6 page exists. Logged-out users go to Login; learners/teachers must not access Admin pages.
9. **File failure (optional administrator test):** in a disposable copy, hold an uploaded image open exclusively, then delete its unattempted scenario/course. SQL deletion must succeed, the page must report manual cleanup and the validated path must appear in App_Data/FileCleanup.log. Release the lock and perform manual cleanup. The log must never contain an unvalidated path.

## Remaining scope

No Phase 3 behavioral questions remain. Phase 4 has not started. Standalone topic/material/post/step editing/deletion, teacher mutation authorization, uploads/replacements and the actual Discussion view belong to later phases. Optional Messages, FAQ management, charts, account unlocking and forced password changes remain deferred. Browser visual/keyboard review is still part of the team's manual checks and the Phase 11 accessibility audit.
