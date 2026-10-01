# Phase 4 courses and materials verification — 2026-09-29

## Delivered scope and files

Created Teacher/MyCourses.aspx, CourseEdit.aspx, CourseBuilder.aspx and MaterialEdit.aspx, each with code-behind and designer files. Created Helpers/PublishHelper.cs. Updated Helpers/AccessHelper.cs, BreadcrumbHelper.cs, CurrentUserHelper.cs, DeleteHelper.cs and UploadHelper.cs, Site.Master.cs, Teacher/Dashboard.aspx, Styles/site.css and LearningSystem.csproj. Recorded Q30 and implementation status in docs/DECISIONS.md, CONTRACTS.md, QUESTIONS.md and PROGRESS.md. This report is included in the project.

Completed CRS-05–12, MAT-01–06, MAT-10 and SYS-08 for the requested four pages. SYS-03, SYS-13 and SYS-19 remain partial across the whole application; their teacher ownership, breadcrumbs and course/topic/material deletion portions are implemented. All mutations use parameterized ADO.NET and ownership is rechecked inside transactions. CourseBuilder lists activities read-only after materials.

## Executed verification

- Built LearningSystem.slnx with Visual Studio 18 MSBuild: zero warnings and zero errors.
- Ran the unchanged Database/CreateDatabase.sql on the separate LearningSystemPhase4 LocalDB instance with a temporary application/database copy. Seed checks and detach succeeded. No rebuild, test mutation or file cleanup touched the workspace database/uploads.
- Served the isolated copy through IIS Express. Submitted real Web Forms viewstate/event-validation fields and multipart file uploads with JavaScript absent.
- Created draft courses; edited metadata and cover images. Empty courses and courses with only draft materials could not publish; a course with a published material could publish. Unpublish preserved attempts.
- Saved Text, Image, PDF, Video, Audio and YouTube materials. Verified publication and free-preview fields. Images required alt text; short text, spoofed YouTube hosts, wrong extensions and empty uploads were rejected. Course covers rejected GIF.
- Tested all four upload byte limits: exactly 2 MB for images, 10 MB for PDF/MP3 and 25 MB for MP4 passed; one byte over each limit failed on the server without changing LastUpdated. Upload checks enforce extension and size; they do not decode or transcode media. Byte-boundary fixtures verified upload handling, not playback (the viewer is outside Phase 4).
- Verified topic creation/edit/reorder, next-position defaults, allowed ties and ID tie-breaking. A topic after position 100 defaults to 101 and must be changed to an allowed 1–100 value; ties remain permitted. Materials use positive integer orders and default to the next position within the topic.
- All four pages rendered a single h1 and the shared breadcrumb. Activities displayed title, type and status read-only, with an empty message where none exist.
- A second active teacher was denied both GET access and a forged edit POST to another teacher's course. CourseBuilder, CourseEdit, MaterialEdit-by-ID and MaterialEdit-by-topic all denied foreign IDs. Invalid, missing and ambiguous IDs were rejected. Learners were denied teacher pages; anonymous requests redirected to Login.
- Replayed successful course/topic/material save forms were rejected without duplicate records. Validation failures left forms usable for correction.
- Reads and rejected writes preserved LastUpdated. Successful topic/material writes, replacement and material deletion updated it. Test-only failing SQL triggers verified rollback preserved timestamps and old file references while removing new replacement uploads.
- Successful material and course-cover replacements deleted the old unreferenced file. An exclusively locked old material file caused a post-commit cleanup warning and a validated-path entry in App_Data/FileCleanup.log; the new database reference remained committed.
- Teacher course/topic deletion was blocked by attempts. Material deletion removed bookmarks/completions before the material and deleted its file. Whole-topic deletion handled scenario start pointers, steps and cross-author discussion replies. An injected topic-delete failure restored the content graph. Whole-course deletion removed dependent enrolment/review rows, content and unreferenced files.
- DBCC CHECKCONSTRAINTS WITH ALL_CONSTRAINTS returned no violations after mutation tests.

## Manual click-through

Use disposable demo data for destructive checks. Demo passwords are Password123.

1. Log in as asha.teacher@example.test. Follow Dashboard → My courses → Create course. Enter a 5–100 character title, subject, 20–1000 character description and optional JPG/PNG cover. Save: the course must be Draft and open CourseBuilder. Edit its metadata and replace the cover; check the old unreferenced upload is gone.
2. Try publishing an empty course: it must be blocked with instructions. Add a topic and edit its title/order. Add another with the same order: both must remain, ordered by TopicID. Try orders 0 and 101: blocked. After a topic at 100, choose an allowed position for the next topic.
3. Add all six material types. Use plain text with paragraph breaks; image with meaningful alt text; PDF; MP4; MP3; and a youtube.com/watch?v= or youtu.be video link. Check that fields change with type, Cancel returns to CourseBuilder, default order advances, and materials are listed before read-only activities.
4. Try a short lesson, missing image alt text, empty file, .exe/.aspx file, image over 2 MB, PDF/MP3 over 10 MB and MP4 over 25 MB. Each must be rejected server-side. Use an unrelated or lookalike YouTube domain: blocked. Check Draft/Published and free-preview settings survive editing.
5. Keep all materials Draft and try publishing the course: blocked. Publish one material, then publish the course from My courses: allowed. Unpublish it and confirm existing results remain. Refresh after a save and verify no duplicate item appears.
6. Replace an uploaded material, then switch a disposable file material to Text. Check old files are removed when unreferenced. Delete another material via its confirmed button: its completion/bookmark records and unreferenced file must disappear.
7. Sign in as daniel.teacher@example.test. Paste Asha's CourseEdit and CourseBuilder URLs, and both MaterialEdit URL forms (id and topicId). All must show Access Denied and leave data unchanged. Try a nonnumeric ID or both MaterialEdit parameters: also denied.
8. On seeded attempted content, try deleting the course and its attempted topic: blocked, with Unpublish offered in the message. On a disposable course without attempts, delete a topic and then the course: all applicable content/dependents and unreferenced files must be removed. Cancel a confirmation and verify nothing changes.
9. Administrator/developer failure check: in an isolated copy, hold an old upload open exclusively while replacing it. The save must remain committed, report manual cleanup and log its validated path. Release the lock before manual cleanup. SQL failure testing should preserve the old reference/file and remove the new upload.
10. Check keyboard navigation, labels, error summary readability and narrow-screen tables in the browser. This human visual/accessibility review remains part of the Phase 11 global audit.

## Remaining scope

No open behavioral question blocks the four requested pages. ENR-06/CourseLearners remains unchecked because it was excluded from this approved four-page scope. Dashboard counts remain for Phase 10. Lesson rendering, downloads, protected media delivery (Q24), material/activity preview viewers and activity builders remain for their owning phases. No Phase 5 or optional feature was started. Existing public navigation keeps later-phase pages disabled.

## Final runtime recheck limitation

The final MSBuild run passed with zero warnings/errors after refining the CourseEdit and new-material breadcrumb trails. The subsequent HTTP recheck could not load the rebuilt LearningSystem.dll: Windows Code Integrity event 3077 and ASP.NET reported an Application Control/Enterprise signing-policy block (HRESULT 0x800711C7). The full functional tests above passed before this final breadcrumb-only refinement. The final refinement is compile-verified, not runtime-verified. A normal isolated IIS Express restart was also rejected by automatic approval review with the generic reason "blocked by policy"; no security policy was changed. The isolated test host was stopped and its customErrors setting restored to On. The workspace Web.config was never changed. Re-run the page smoke checks in an environment whose policy permits the team's locally built assembly.
