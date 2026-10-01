# Presentation/demo data — 1 October 2026

> Historical fallback dataset: these IDs/accounts describe the preserved LearningSystem.mdf database. Web.config now selects the clean LearningSystemFinal dataset from the current final CreateDatabase.sql. Use docs/DEMO_CREDENTIALS.md for its accounts and docs/PHASE17-FINAL-DATABASE.md for its verification. Do not rerun this additive seed automatically; its tool reads the current Web.config target.

Data only: no application functionality or schema changes. Existing accounts, courses, uploads and learning records were preserved. Four additional courses are marked `PRESENTATION-DEMO-V1` in their descriptions. IDs below describe the current database; the repeatable tool resolves identifiers rather than assuming these IDs.

## Sign-in accounts

All listed fictional demo accounts use **Password123**. Sign in at `https://localhost:44393/Account/Login.aspx` and select the appropriate portal. Student is presentation terminology for the Learner database role.

| Role | Name | Email | Demo use |
|---|---|---|---|
| Admin | Demo Administrator | admin@example.test | Dashboard, analytics, payments and management |
| Teacher | Asha Sharma | asha.teacher@example.test | Web course |
| Teacher | Ravi Thapa | ravi.pending@example.test | Database course; account is currently Active despite its historical email |
| Teacher | Maya Rai | maya.teacher@example.test | Digital safety course |
| Teacher | Daniel Tan | daniel.teacher@example.test | Business course |
| Learner | Ben Lee | ben.learner@example.test | Beginner; pending business checkout |
| Learner | Chandra Gurung | chandra.learner@example.test | Midway progress; database game, discussion and canceled payment |
| Learner | Anita Karki | anita.learner@example.test | Advanced progress; quiz, assessment and matching results |
| Learner | Dina Wong | dina.learner@example.test | Certificate, assessment comparison, paid access and scenario outcomes |

These nine accounts were reused; none were created or reset. Other accounts remain intact.

## Courses

| ID | Course | Teacher | Price | Topics | Materials | Activities |
|---|---|---|---|---:|---:|---:|
| 10 | Web Development Fundamentals: Build Accessible Pages | Asha | Free | 10 | 13 | 4 |
| 11 | Introduction to Databases: Design a Student Club System | Ravi | Free | 10 | 12 | 4 |
| 12 | Digital Safety and Cyber Awareness: Make Safer Decisions | Maya | NPR 499.00 | 10 | 12 | 4 |
| 13 | Entrepreneurship and Business Basics: Plan a Small Venture | Daniel | NPR 999.00 | 10 | 12 | 4 |

All four are Published after checks using PublishHelper. Total: **40 topics, 49 materials, 16 activities**. Materials comprise 40 educational text lessons, four images, four existing PDF handouts and one official freeCodeCamp YouTube tutorial. Each course has free previews in topic 1. No broken placeholder video/audio files were added. YouTube playback requires internet access.

## Activity locations

| Type | Course/topic | Activity ID |
|---|---|---:|
| Matching | Web, topic 4 | 15 |
| Scramble | Databases, topic 4 | 19 |
| Memory | Digital safety, topic 4 | 23 |
| Sort | Business, topic 4 | 27 |
| Scenario | Digital safety, topic 6: The urgent scholarship message | 24 |

Each course has a four-question weighted quiz in topic 2 (eight-minute limit, maximum three attempts), and a discussion in topic 7. Web, Databases and Business have four-statement self-assessments in topic 10. Scenario 24 has six steps, three outcomes (Best/Acceptable/Poor), and a legitimate return-to-start choice. Dina has a saved run for each ending. Web discussion includes two top-level contributions and one learner reply.

## Learner profiles

The Web course contains 17 published items: 13 materials and four activities. Progress is calculated by the existing shared helper, never stored.

| Learner | Web completed items | Web progress | Additional presentation enrolment |
|---|---:|---:|---|
| Ben | 2 materials | 11.76% | None |
| Chandra | 6 materials + quiz + discussion | 47.06% | Databases |
| Anita | 11 materials + quiz + assessment + game | 82.35% | Databases |
| Dina | 13 materials + all four activities | 100% | Digital safety |

Existing enrolments in older courses remain. Dina's Web certificate is at `Learner/Certificate.aspx?id=10`; its date is the current UTC print date. Dina has two Web quiz results and assessment averages 3.00 (Developing) then 4.50 (Confident). Seeded games were submitted immediately through server helpers, so their elapsed time may be **0 seconds**; these are automated fixtures, not claims of human play speed. For natural gameplay timing, play a new run during the demonstration. All fixture timestamps reflect actual seeding time rather than invented historical dates.

Three Web reviews and four bookmarks are included. The presentation courses contain 17 submitted attempts after adding the three scenario outcomes. Existing attempts remain intact.

## Payment state — offline test only

The current application uses its approved **offline eSewa demo**, not an actual external eSewa round trip. No real money, SMS or provider verification was used. Complete records below are synthetic local test purchases processed through the existing PaymentHelper.CompleteDemo flow, not externally verified financial transactions.

| Payment ID | Learner/course | Status | Amount |
|---|---|---|---:|
| 7 | Ben / Business | Pending | NPR 999.00 |
| 8 | Chandra / Business | Canceled | NPR 999.00 |
| 9 | Dina / Digital safety | Complete (offline demo) | NPR 499.00 |

Use Ben's existing pending record at `Payment/EsewaDemo.aspx?paymentId=7` to demonstrate checkout. A fictional test mobile such as `9841234567` uses demo code **4567**, its last four digits. No code is sent by SMS. Completing this changes Ben's payment/enrolment data. Cancel instead if preserving the prepared state is preferred. Starting Buy again can legitimately create another Pending transaction. Never describe this as a real sandbox-provider verification. Paid-course direct enrolment still uses the existing guard; Dina's local verified demo purchase permits retained-purchase re-enrolment.

## Repeatable seeding

Run from the project directory in PowerShell:

```powershell
.\Database\SeedPresentationDemo.ps1
```

Requires installed Visual Studio Roslyn compiler, existing upgraded database, application helpers and listed local assets. Optional `-CompilerPath` and `-ConnectionString` select the existing compiler/database. Do not share a connection string containing credentials. If normal LocalDB startup is blocked but IIS Express has already opened the instance, a developer may supply its current observed named-pipe connection to the SAME database; do not rebuild/reset it.

`SeedPresentationDemo.sql` adds complete course bundles inside a transaction only if their marked titles/owners do not exist. `SeedPresentationHistory.cs` uses existing submission, payment, publication, bookmark, review and progress helpers in a standalone temporary console tool. Its explicit fictional-account context is a data-fixture context, not a browser authentication test. Existing passwords/statuses are not changed. Existing completions, attempts, reviews, payments and bookmarks are reused; additional required fixture records are inserted only when absent. Rerunning republishes the marked fixture courses/activities after validating them; do not rerun if intentionally demonstrating them unpublished. No reset/delete operation is provided. All application source files remain unchanged.

Do **not** run CreateDatabase.sql for this task. No schema upgrade is needed. Keep MDF/LDF files out of Git; repeatability is provided by these tools and local assets.

## Recommended presentation order

1. Visitor: Courses → Web details → free preview. Show Free and NPR pricing.
2. Ben: dashboard (11.76%) → an unfinished lesson → bookmark → optional pending test checkout.
3. Chandra: Web progress (47.06%) → discussion/reply → Databases Scramble/results.
4. Anita: advanced Web progress (82.35%) → quiz/assessment history.
5. Dina: Web 100% → certificate/print preview → assessment confidence comparison → Digital safety Memory and Scenario outcomes.
6. Teachers: own MyCourses → CourseBuilder → material/activities → results and learner names. Use a disposable new activity for CRUD; existing attempted activities deliberately lock structural editing.
7. Daniel: Business Sort game through read-only teacher preview, or enrol/purchase with a learner for normal play.
8. Admin: dashboard/statistics → payments; point out local test statuses.

## Verification actually performed

- SQL inventory confirmed four Published courses, ten topics each, ownership, prices and activity locations.
- Existing PublishHelper validated all new authored activity types and course publication.
- Actual shared submission helpers produced quiz/assessment/game/scenario records; shared progress returned the four percentages above.
- Repeatable PowerShell entry point compiled and ran successfully against the existing database; progress remained unchanged on re-run.
- Browser checks and final build results are recorded in PROGRESS.md.

Manual checks still recommended: play all four templates with mouse/touch/keyboard; explore scenario loop and all endings; practise teacher CRUD with disposable content; verify another teacher is denied; compare each learner's results; print Dina's certificate; test Ben's offline checkout and paid bypass denial. These broader tests were not run as part of this data task.

Runtime/build results: Debug solution build succeeded with no warnings/errors emitted. Browser verified all four new catalogue covers, Web course outline/reviews, Dina dashboard/results/certificate, Asha dashboard/recent attempts and Admin dashboard/payment history. Scoped queries confirmed seven new-course enrolments, 17 attempts, one reply and no duplicate marked-course/enrolment groups. Existing unrelated course How to code in C has a cover that did not load; preserved unchanged for separate investigation.
