# Final manual testing and presentation checklist

Phase 16 — 1 October 2026. These instructions are **not recorded passes**. Final runtime testing was blocked by LocalDB startup. Record account, IDs, date, expected/actual result and evidence when the team performs each check.

## Preparation

1. Start the existing application normally at `https://localhost:44393/`. Stop if LocalDB or certificate setup fails; do not rebuild the database or weaken security.
2. Use active demo Learner, Teacher and Admin accounts, plus a second learner/teacher in separate browser profiles. Seed password is `Password123` only where unchanged. Record actual IDs.
3. Use disposable content for CRUD. Preserve real uploads/history. Prepare a published free course, paid sandbox course and owned draft course. Use safe SELECT counts before/after checks claiming no writes.
4. Demo sequence: visitor catalogue → Student learning/results → Teacher course CRUD/preview → Admin management → sandbox pricing/history. Never present an unverified payment as successful.

## A. Visitor

- [ ] Home → Courses → About → Help → Contact → Site Map → Home. Check breadcrumbs, titles, clear exits and honest missing-content placeholders.
- [ ] Courses: enter search, choose subject, apply, change page, clear filters, try no matches. Only published courses appear; an empty state is shown.
- [ ] Open CourseDetails: teacher, subject, UTC update, Free/NPR price, outline and reviews. Open free-preview material and PDF download. **Blocked:** change materialId to normal/draft content or request `/Uploads/...` directly.
- [ ] Account/Login → select each Student/Teacher/Admin portal. Protected URLs must not reveal data while signed out.
- [ ] Register disposable learner/teacher: wrong CAPTCHA rejects and renews challenge; unrelated field validation preserves challenge; valid submission consumes it. Teacher remains pending until approval.
- [ ] Contact: valid sender/subject/message and CAPTCHA → submit → refresh success. Exactly one message. Wrong CAPTCHA saves nothing. Register and Contact challenges remain independent in separate tabs.

## B. Student

### Access, enrolment and progress

1. Student Portal → login → Dashboard. Check own courses/results. A flagged account must change password first.
2. Published free CourseDetails → Enrol → Continue Course. No Payment required; revisit without duplicate enrolment.
3. Paid course → Buy/Enrol → Checkout. Check database NPR amount and “eSewa Sandbox — Test Payment”. Cancel grants nothing. **Blocked:** direct enrol postback without a verified Complete payment.
4. If sandbox is available, follow PHASE15-PAYMENT-SETUP.md with official test credentials. Confirm Pending payment/unique UUID/stored amount, signed return, server COMPLETE verification, then Complete and exactly one Enrolment. Reopen the successful return once: no duplicate. Do not manually mark paid.
5. If configuration/network/certificate blocks sandbox, stop and record the step. Failed/canceled/unsigned/unverifiable returns grant no access.
6. CourseHome → lesson → Mark complete → return. Materials precede activities; done tick/progress updates. Previous/Next/Back work. Repeating completion does not duplicate it.
7. Hand-count distinct completed published materials plus activities over published items. Complete Quiz, SA, Game, Scenario and a Discussion contribution: each activity counts once. Replies count; deleting the last surviving contribution removes Discussion completion. Draft items do not count. Compare rounded percentage with the shared helper.
8. For a published enrolled course with all its items subsequently unpublished, progress is 0%. Unpublished courses remain “Currently unavailable”; normal lessons are inaccessible.

### Activities

- [ ] Quiz → Start → answer → Submit → result. Unanswered questions count wrong; weighted server score; one answer row per question. Refresh result saves no extra Attempt. Pre-submit source/network contains no correct-answer flag.
- [ ] Timed disposable Quiz: submit after limit plus 30 seconds → no save. Missing run session → restart required. Repeated Start preserves time; exhausted MaxAttempts blocks. Do not stress/replay repeatedly.
- [ ] SA: omit a statement → rejected; complete integer 1–5 ratings → average/confidence, ScorePercent NULL. Repeat and compare history. Controlled averages below/at 2.50 and 4.00 classify using unrounded average. Crafted 0, 6 or non-integer saves nothing.
- [ ] Discussion: create/edit post, reply once, delete own reply/post with confirmation. No nested replies. Closed discussion blocks learner create/reply/edit/delete; teacher/Admin can moderate. **Blocked:** another learner's PostID in a postback.
- [ ] Matching: select item then target using mouse, touch, Tab/Enter/Space; finish and submit. No drag-and-drop required.
- [ ] Memory: first flip does not count a move; second flip does. Complete pairs; compare Q33 server-time/move score. Fewer moves than pairs rejected. Client move count remains a documented limitation.
- [ ] Scramble: type answers and submit; compare server word validation, including supported trim/case handling.
- [ ] Sort: select item then group using mouse/touch/keyboard. Server validates group placement.
- [ ] Game tampering: edit hfResult for one disposable run. Wrong valid answers earn lower recalculated score; foreign ItemID/GroupID or malformed JSON is rejected. Check best score/history after valid play.
- [ ] Scenario: choose valid branch → ending/Outcome/Feedback/one NULL-score Attempt. Restart → different ending can save another run. Follow a loop to an earlier step. Refresh ending saves nothing extra. Foreign/stale ChoiceID or skipped NextStepID cannot navigate/save.
- [ ] MyResults: course/type filters and paging; only own results. Quiz links authorized, SA confidence not score, Scenario ending/outcome, no Discussion Attempt. **Blocked:** another learner's AttemptID.

### Tier B and retained records

- [ ] Lesson bookmark on → MyBookmarks → open → remove. No duplicates. Unpublished/unenrolled retained bookmark cannot bypass access.
- [ ] CourseDetails/MyResults → create review 1–5/comment → edit → delete with confirmation. One per learner/course; averages update. Another learner and teacher cannot remove it. Leaving blocks mutation until access restored.
- [ ] Certificate direct URL below 100%/without enrolment/unpublished course → blocked. At shared 100%, print preview shows current learner/course/teacher and “Printed on” UTC date, no completion date/serial; navigation hidden. Another courseId cannot grant an unauthorized certificate.
- [ ] MyPayments shows only own NPR/status/reference/UTC dates or empty state.
- [ ] Leave with confirmation → retained learning/results/posts/reviews/bookmarks remain → re-enrol restores progress. Previously verified paid purchase restores enrolment without second charge. Existing enrolment survives price change.
- [ ] Logout → protected pages/media no longer disclose learner content.

## C. Teacher — complete CRUD demonstration

1. Teacher Portal → Dashboard: own counts/recent attempts only.
2. MyCourses → create disposable draft with subject/title/description → save → edit. Free stores zero; Paid needs positive NPR. Invalid price rejects; successful authored changes update LastUpdated.
3. CourseBuilder → add two topics → edit/reorder; ties use ID. Add unused third topic → delete with confirmation. Cancel an edit without saving.
4. Add Text, Image with alt, PDF, MP4, MP3 and YouTube materials. Edit/order/preview. Missing alt, wrong extension and clearly oversized upload reject server-side. Replace/delete only disposable files; old unreferenced file removed after commit. No boundary/file-lock tests.
5. Publish an item then course. Empty-course publication rejects. Unpublish prevents public/learner access while retaining history.
6. QuizBuilder → add/edit/delete disposable questions/options; set marks/correct options/time/limit → publish/preview. After learner attempt, structure/options/time/limit lock, Title/Description remain editable. Preview creates no Attempt/answers.
7. SABuilder → add/edit/delete statements before attempts → publish/preview → inspect per-statement class averages. After attempt, structure locks; confidence is not a score.
8. DiscussionEdit → create/edit/publish → close/reopen. Moderate disposable post with replies; replies deleted first. Preview saves no posts; closed moderation works.
9. GameBuilder → build each template; add/edit/delete items and Sort groups. Insufficient items/groups fail publication under displayed contract rules. Template locks after items; content locks after attempts. Preview no Attempt; inspect game results/history.
10. ScenarioBuilder → steps, optional image/alt, two endings/outcomes/feedback, choices/start. Loop allowed. Invalid start, missing choice, ending outgoing choice or missing feedback prevents publication. Incoming-reference/current-start deletion blocked. Before attempts choose another start to delete otherwise unreferenced old start; after attempts start and structure lock. Ending→non-ending clears outcome/feedback. Inspect outcome counts.
11. Results → owned course/activity → type-appropriate summaries/filters/paging. CourseLearners names only. Second teacher's course/activity IDs on GET/postback → Access Denied, no write.
12. Preview owned draft materials/all activity kinds; safe before/after counts show zero learner-data writes. Exit to builder. Admin repeats representative draft preview from oversight.
13. Delete unused disposable draft course with confirmation. Course/topic/activity with attempts blocks deletion; use Unpublish. Do not delete real history.

## D. Admin — complete CRUD demonstration

1. Admin Portal → Dashboard: compare users by role, subjects/course counts, pending applications and attempts with safe SELECT counts; charts match accessible table data.
2. Users → create disposable non-Admin → edit/status → password reset. Initial/reset password forces change, including already logged-in session on next protected/Media request. Wrong current/same new password does not clear flag; valid different password does.
3. Five wrong logins on disposable non-Admin → 15-minute lock/message → Admin unlock → successful login resets failures. Do not lock all Admin access or alter machine time.
4. Teacher Applications → approve one pending disposable teacher/reject another. Pending/Rejected/Deactivated login blocked. Admin user rows' management actions disabled.
5. Subjects → create → rename → delete unused subject. Used subject deletion blocked.
6. Courses/Activities oversight → filter/view/unpublish/preview. Preview no writes; attempted-content deletion blocked. Admin does not need access to Teacher-only builders.
7. Remove disposable course review with confirmation; teacher lacks this permission. Moderate discussion post while closed.
8. Messages → unread count → open Visitor message → mark read → count updates → delete with confirmation. Non-Admin cannot see sender data.
9. FAQ → add All/Learner/Teacher examples → edit/order 1–100 → inspect role audience → delete disposable rows. Ties use FAQID; Help retains static guidance and details/summary.
10. Payments → status filter → learner/course/NPR/UUID/reference/dates. No manual Mark paid/refund/status-edit controls. Teacher/Learner direct access denied.
11. Delete unused disposable user with confirmation. Teacher owning courses blocked. Preserve real retained records.

## E. Security and visual acceptance

- [ ] Correct password in wrong portal rejects without authentication or failed-password count. Wrong password uses shared lockout. ReturnUrl cannot leave site or bypass role authorization.
- [ ] Tamper CourseID/ActivityID/MaterialID/AttemptID/UserID/PostID/StepID/ChoiceID and payment UUID/ID where accepted. Foreign/malformed identifiers fail on GET and mutation, using current valid form state; hiding buttons is not evidence.
- [ ] Learner draft content → Not Found; authorized owner/Admin preview works without writes. Visitors cannot open normal lessons.
- [ ] Check upload/rating/review/CAPTCHA validation, quiz limits/timer, forged game/scenario and paid gate above. Rejected operations save nothing; displayed user text is encoded.
- [ ] Known M01: customErrors is Off. After separately approved repair, verify unexpected errors show friendly pages without technical details. Do not expose sensitive failures during a public demo.
- [ ] Inspect Home/Courses, CourseHome, one builder, results table and PlayGame at 390px/820px/1280px. No full-page horizontal scrolling; table overflow contained. Inspect portals/Checkout for shared styling.
- [ ] Keyboard focus, labels, alt, heading order, captions/headers and announcements. Matching/Sort usable without pointer. Check Checkout main landmark (known S03).
- [ ] Alt+H/C/Q → Home/Courses/Help; Alt+D → authenticated role dashboard. Typing fields/contenteditable, IME, repeats and Ctrl/Meta/Shift combinations ignored. Document browser-reserved combinations rather than overriding security.
- [ ] Error pages, registration success, activity results/endings, certificate and preview have exits.
- [ ] Record remaining real assets/contact/report diagrams. O10/O14: **INTENTIONALLY DEFERRED — Phase 14 skipped by team decision**.

Use PHASE16-AUDIT.md for findings and source evidence. The team must separately record execution results; do not mark unperformed checks PASS.

## Phase 17 checks (Inkwell redesign)

Run the database script first, then sign in with the accounts in Database/README.md (password Password123).

| # | Steps | Expected |
| --- | --- | --- |
| 1 | As a visitor, open Home | Hero, intro video with captions, 8 subjects with images, 6 newest courses, real counts, FAQ preview |
| 2 | Courses: search "python"; choose Price "Free only"; Sort "Title A to Z" | Matching courses only; URL keeps the filters; Clear filters resets |
| 3 | Open a course; choose a lesson marked Free preview | Preview opens without logging in; other lessons are not links |
| 4 | Register: leave the Terms box unticked | Blocked with "Please agree to the Terms of use"; ticking it creates the account |
| 5 | Register with ?as=lecturer, then log in as that account | Lecturer application is pre-selected; log in is refused until approved |
| 6 | Learner anita.karki: Dashboard | Streak, week strip, counts, continue learning, course progress, recent results |
| 7 | Open "Code lab: your first page", change the h1 text, choose Run code, then Reset | Result updates beside the code; Reset restores the original |
| 8 | Play each game type (Matching, Memory, Word scramble, Sort, Flashcards, Fill in the blank, True or false, Put in order) and submit | Score ring and saved result; progress updates |
| 9 | Take a quiz leaving one question blank | Warning before submitting; result page shows the answer review |
| 10 | Admin: My courses, open "Time Management for Students", add a game of type Fill in the blank with a sentence that has no ___ | Rejected with "exactly one blank" message |
| 11 | Admin: Analytics after browsing a few pages | Views per day, by visitor type and top pages |
| 12 | Visit /robots.txt and /sitemap.xml | Robots blocks private folders; sitemap lists public pages and every published course |
| 13 | Visit /DoesNotExist.aspx | Custom 404 page with links, HTTP status 404 |
| 14 | Learner opens Learner/Certificate.aspx?id=16 and chooses Print | Landscape certificate only, without menus |
| 15 | Resize to a phone width | Menu button, stacked layout, no sideways scrolling except the workspace tab bar |
