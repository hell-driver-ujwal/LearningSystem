# AGENTS.md — Web-Based Learning System (ASP.NET Web Forms)

You are helping a 4-person student team build their university assignment (APU CT050-3-2-WAPP).\
Read this whole file before every task. It overrides your own preferences.\
PROJECT_TYPE = WEB APPLICATION

---

## 1. Source of truth

- `docs/BLUEPRINT.md` is the confirmed requirements document. Section numbers below refer to it.
- **Build only what the blueprint describes, or explicitly approved custom scope documented in `docs/PHASE15-CUSTOM-SCOPE.md` and `docs/DECISIONS.md`.** The blueprint remains authoritative for original assignment requirements. Do not add features, pages, tables, columns, libraries or "nice extras".
- If the blueprint is unclear or contradictory:
  - **Stop and ask only when the ambiguity affects** database schema, security/access control, persistent data, grading requirements, shared contracts used by multiple phases, or important user-visible behaviour.
  - For ordinary implementation details that do not affect those areas, choose the **simplest implementation consistent with the blueprint and existing approved contracts**, record the choice briefly if useful, and continue.
  - Do **not** create clarification questions for trivial internal implementation choices.
  - If clarification is genuinely required, write the question in `docs/QUESTIONS.md` and include it in your reply.
- Any change the team agrees to is appended to `docs/DECISIONS.md` (date, change, reason). Never edit the blueprint itself.
- `docs/CONTRACTS.md` (created in Phase 0, approved by the team) holds exact names: tables, columns, helper methods,\
  constants, URLs. **Once approved, use those names exactly.** Changing a contract needs the team's approval.

---

## 2. Fixed technology — do not change

| Area         | Must use                                                                                                                                                                                      | Must NOT use                                                                        |
| ------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------- |
| Framework    | ASP.NET **Web Forms** on **.NET Framework 4.8**, C# code-behind (`.aspx` + `.aspx.cs`)                                                                                                        | ASP.NET Core, MVC, Razor Pages, Blazor, .NET 6+                                     |
| Database     | SQL Server **LocalDB**, final catalog `LearningSystemFinal` / file `App_Data/LearningSystemFinal.mdf`, built from `Database/CreateDatabase.sql`; old `LearningSystem.mdf` is preserved as fallback                                                                                          | Other databases                                                                     |
| Data access  | ADO.NET: `SqlConnection`, `SqlCommand` **with parameters**, `SqlDataReader` / `SqlDataAdapter`. `SqlDataSource` + `GridView` only for simple admin lists that have no ownership rules         | Entity Framework, Dapper, any ORM                                                   |
| Login        | **Forms Authentication**, own login page, role stored in the ticket's UserData and attached in `Global.asax` (SYS-20)                                                                         | ASP.NET Identity, Membership/Role providers, OWIN                                   |
| Validation   | ASP.NET validator controls (RequiredField, RegularExpression, Compare, Range, Custom) + ValidationSummary + **`if (!Page.IsValid) return;` at the top of every save handler** + server checks | Client-only validation                                                              |
| Front end    | HTML5, own CSS in `Styles/`, plain JavaScript in `Scripts/`                                                                                                                                   | JS frameworks, CSS frameworks from a CDN, anything needing internet during the demo |
| JSON (games) | `System.Web.Script.Serialization.JavaScriptSerializer` (built in)                                                                                                                             | New NuGet packages                                                                  |

**No NuGet packages or external libraries without asking first.**

### Project type — the team fills this in before Phase 0

`PROJECT_TYPE = WEB APPLICATION`

- **WEB APPLICATION** (has a `.csproj`):
  - Every new file (`.aspx`, `.aspx.cs`, `.aspx.designer.cs`, `.cs`, `.css`, `.js`, images) **must be added to the `.csproj`**, or it will not build / not be published.
  - Every `.aspx` page needs a `.aspx.designer.cs` that declares **every** server control with `runat="server"` and an ID. Keep it in sync whenever you add, rename or remove a control.
  - Shared classes go in `Helpers/`.
- **WEB SITE** (no `.csproj`): shared classes go in `App_Code/`. No designer files; no project file edits.

---

## 3. Fixed values (use exactly these strings)

| Item                           | Values                                                                                                                                                                                         |
| ------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| User.Role                      | `Learner`, `Teacher`, `Admin`                                                                                                                                                                  |
| User.Status                    | `Active`, `Pending`, `Rejected`, `Deactivated`                                                                                                                                                 |
| Course.Status, Activity.Status, Material.Status | `Draft`, `Published`                                                                                                                                                                           |
| Activity.ActivityType          | `Quiz`, `SelfAssessment`, `Discussion`, `Game`, `Scenario`                                                                                                                                     |
| Activity.GameTemplate          | `Matching`, `Memory`, `Scramble`, `Sort`, `Flashcards`, `FillBlank`, `TrueFalse`, `Sequence`                                                                                                                                                       |
| Material.MaterialType          | `Text`, `Image`, `PDF`, `Video`, `Audio`, `YouTube`, `Code`                                                                                                                                            |
| SimStep.Outcome                | `Best`, `Acceptable`, `Poor`                                                                                                                                                                   |
| FAQ.Audience                   | `All`, `Learner`, `Teacher`                                                                                                                                                                    |
| Session keys                   | `UserID`, `Role`, `FullName`; quiz start time: `QuizStart_{ActivityID}`                                                                                                                        |
| Password hash                  | PBKDF2 via `Rfc2898DeriveBytes` with SHA256, 100,000 iterations, 16-byte random salt, 32-byte hash, stored as `PBKDF2$100000$<base64 salt>$<base64 hash>` in `User.PasswordHash NVARCHAR(200)` |
| Demo password                  | Every demo account uses `Password123` (hashes must be generated with the algorithm above and match the login code)                                                                             |
| Upload limits                  | Image ≤2 MB (JPG/PNG/GIF), PDF ≤10 MB, MP4 ≤25 MB, MP3 ≤10 MB. `web.config`: `maxRequestLength="30720"` (KB) and `maxAllowedContentLength="31457280"` (bytes)                                  |
| Upload folders                 | `~/Uploads/Images`, `~/Uploads/Documents`, `~/Uploads/Video`, `~/Uploads/Audio`; file name = new GUID + original extension                                                                     |
| Connection string name         | `LearningSystemDb` → `Data Source=(LocalDB)\MSSQLLocalDB;Initial Catalog=LearningSystemFinal;Integrated Security=True` |

The approved Phase 17 entries in `docs/DECISIONS.md` and `docs/CONTRACTS.md` extend the original MaterialType/GameTemplate lists above. Code Labs are Code materials, not an Activity type.

### Game result format (hidden field `hfResult`, JSON)

```
{ "timeTakenSeconds": 83,
  "moves": 14,                                  // Memory only
  "answers": [ { "itemId": 12, "value": "..." } ] }
```

- Matching: `value` = the ItemID the learner matched it with.
- Scramble: `value` = the word the learner typed.
- Sort: `value` = the GroupID the learner placed it in.
- Memory: `answers` empty; score from moves and time.
- **The server recalculates the score for Matching, Scramble and Sort.** Never trust a score sent by the browser.

---

## 4. Rules for every piece of code

### Security

1. **All SQL uses parameters.** Never build SQL by joining strings with user input, including search and sort.
2. Every page that takes an ID in the query string checks **ownership or enrolment** with the shared helpers. Failure → `~/AccessDenied.aspx`. Drafts/unpublished items requested by learners → `~/NotFound.aspx`.
3. Correct quiz answers (`IsCorrect`) are **never** sent to the browser before submission: not in HTML, hidden fields or scripts.
4. All user-entered text is **HTML-encoded** when displayed. Keep request validation on.
5. Uploads: check extension and size on the server, save with a GUID name, delete the file from disk when its record is deleted or replaced. `Uploads/` has its own `web.config` that stops scripts running.
6. After every successful save: **redirect** (Post/Redirect/Get). Show the result message on the next page.
7. Deletes only via buttons (postback), never via links, and always with a confirmation.
8. Custom error pages on; no technical error details shown to users.

### Database

9. Cascade delete **only** down the content chain: Course → Topic → Material / Activity → that activity's content tables.
10. All other deletes are done **in C# code, children first, inside one `SqlTransaction`** (SYS-19). This includes: users, attempts, quiz answers, self-assessment responses, discussion posts and replies, scenario steps and choices, completions, bookmarks, enrolments, reviews.
    - Deleting a course/topic/material/activity: first delete rows in non-cascading child tables (completions, bookmarks, enrolments, reviews, posts), then delete the parent.
11. **Blocked deletes** (show a clear message instead): subject used by a course; teacher who owns courses; scenario step that choices lead to; any course/topic/activity that has attempts (offer Unpublish instead).
12. **Content lock:** once an activity has any attempt, its questions/options/statements/items/groups/steps/choices cannot be added, edited or deleted. Title and description stay editable.
13. A quiz Attempt row is created **only on Submit**. Start time lives in the session.
14. Progress % is **calculated, never stored** (blueprint Section 18, rule 10). Use one shared method everywhere.

### Structure and style

15. Follow the folder structure (Section 14.2) and naming convention (Section 14.1) exactly.
16. Every page uses `Site.Master`, has a `<title>`, one `<h1>`, a breadcrumb (except Home), and uses the master page's message area.
17. Use HTML5 semantic elements (`header`, `nav`, `main`, `section`, `article`, `footer`, `figure`) and `TextMode` input types (Email, Url, Number, Password, Search).
18. CSS: styles live in `Styles/site.css` (external). Also include **at least one** internal `<style>` block and **at least one** inline `style=""`, each with a comment saying it is there to demonstrate that CSS type.
19. Accessibility: every image has alt text; headings in order; GridView tables have a Caption and header cells.
20. Every list shows an empty-state message; every form has a Cancel button.

### Readability — the team must explain every line in a presentation

21. Write simple, readable code a second-year student can explain: short methods, clear names, comments that explain **why**.
22. No advanced patterns: no dependency injection, repositories, generic base classes, reflection, async/await, or complex LINQ. Plain classes and methods.
23. Put reusable logic in the shared helpers from `docs/CONTRACTS.md`. Do not copy the same logic into several pages.

---

## 5. How to work on each task

### 5.0 Context-reading rule

Do **not** reread the entire project documentation unnecessarily.

For each phase:

1. Read `AGENTS.md`.
2. Read the phase prompt.
3. Read only the specific `docs/BLUEPRINT.md` sections named by that phase prompt.
4. Read only the relevant portions of `docs/CONTRACTS.md`, `docs/DECISIONS.md`, and `docs/PROGRESS.md`.
5. Consult `docs/QUESTIONS.md` only when the current phase reaches an unresolved requirement or an existing question directly affects implementation.
6. Do not reread unrelated Blueprint sections or historical questions merely for completeness.
7. Inspect only files relevant to the current phase, shared helpers it depends on, and files that genuinely need modification.

This rule exists to reduce unnecessary context usage and avoid mixing requirements from unrelated phases.

---

### 5.1 Default workflow — implementation first

1. **Read** the phase prompt, the blueprint sections it names, `docs/CONTRACTS.md` and `docs/PROGRESS.md`.
2. **Before writing code**, reply with a short plan: files you will create or change, feature IDs covered, and anything unclear. Then continue.
3. **Implement only the requested phase.** Do not expand the task into a full QA or regression exercise.
4. **Build once after the main implementation:**
   - On Windows, if MSBuild is available, build the solution and fix errors or warnings caused by your changes.
   - Rebuild only when needed after fixing a compile error or making a code change that affects compilation.
   - Do **not** repeatedly rebuild after documentation-only, comment-only, breadcrumb-text, CSS-only or similarly low-risk changes unless compilation is actually affected.
   - **If you cannot build or run, say so clearly. Never claim code compiles or works if you did not run it.**
5. **Run only minimal smoke checks by default:**
   - Check that the newly implemented page or feature starts.
   - Check one representative happy path.
   - Check one important blocked/validation path when it is central to the feature.
   - If those checks pass, **stop testing and report back**.
6. Run `Database/CreateDatabase.sql` with `sqlcmd` **only when the current phase changes the database script/schema, when the phase explicitly requires it, or when the user asks for it**. Do not rebuild or recreate the database for ordinary page/code changes.
7. **Finish with a concise report:**
   - Files created/changed
   - Feature IDs completed (update `docs/PROGRESS.md`: `[x]` done, `[~]` partly done with a short note)
   - Build result
   - Minimal smoke checks actually performed
   - **Manual test steps** the team should click through for broader verification, including important "should be blocked" cases
   - Known gaps or open questions
8. Stay inside the current phase. Do not start the next phase, and do not change files owned by other modules unless the phase says so (mention it if you must).
9. Never commit secrets or the `.mdf`/`.ldf` files. Keep `.gitignore` updated (`bin/`, `obj/`, `.vs/`, `packages/`, `*.mdf`, `*.ldf`, `*.user`).

### 5.2 Tests that require user approval

Do **not** run the following unless the phase explicitly requires them or the user explicitly approves them first:

- exhaustive regression suites or large test matrices
- repeated full test-suite runs after small changes
- testing every supported file/material type when representative smoke coverage is enough
- exact upload byte-boundary tests (for example limit, limit + 1 byte)
- SQL failure injection, forced transaction failures or rollback simulations
- file-locking or cleanup-failure simulations
- replay/stress testing of repeated POST requests
- broad destructive course/topic/material deletion matrices
- database integrity sweeps such as `DBCC CHECKCONSTRAINTS` after ordinary feature work
- repeated IIS Express start/stop/restart cycles solely for additional verification
- creating elaborate isolated application/database copies solely for exhaustive testing
- large amounts of disposable test data
- Windows security-policy changes, antivirus changes, Application Control changes, Code Integrity changes, registry changes, or machine-wide IIS/.NET configuration changes

If one of these tests would provide useful extra confidence, **do not run it automatically**. Briefly tell the user what you want to test and why, then wait for approval.

### 5.3 Local machine safety

This project is being developed on the user's personal computer. Prefer project-local actions and minimize changes to the machine.

- Do not disable or weaken Windows Security, antivirus, Smart App Control, Application Control, Code Integrity or similar protections.
- Do not change registry settings or machine-wide IIS/.NET configuration unless the user explicitly approves it.
- Do not rebuild, reset, detach, delete or heavily mutate the user's main LocalDB database merely for testing.
- Do not delete or replace real uploads merely for testing.
- If a test needs destructive data, prefer asking the user to perform the manual test with disposable demo data.
- If the environment blocks a runtime test but the project builds, record the limitation and stop rather than repeatedly retrying or changing system security.

### 5.4 Stop condition

Once all of the following are true:

- the requested scope is implemented,
- the solution builds successfully, and
- the minimal smoke checks pass (or a runtime/environment limitation is clearly documented),

**STOP.** Do not invent additional verification work. Leave broad regression, boundary, failure-injection and destructive testing for the dedicated final audit/testing phase or for an explicit user request.

---

## 6. Phase order (details in PHASE_PROMPTS.md)

0 Plan & contracts → 1 Database script → 2 Foundation & login → 3 Admin → 4 Courses & materials →\
5 Public site, enrolment & lessons → 6 Quiz & discussion → 7 Self-assessment → 8 Games → 9 Scenario →\
10 Results, progress & dashboards → 11 Polish & accessibility → 12 Optional Tier A → 13 Optional Tier B →\
14 Optional Tier C (DEFERRED; O10/O14 not completed) → 15 Custom Enhancements → 16 Final Audit

No optional feature (O1–O14) is started until Phases 0–11 are complete and tested.
