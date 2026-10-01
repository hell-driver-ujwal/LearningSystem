# Phase 17 final database verification — 2026-10-01

## Outcome

The separate clean `LearningSystemFinal` database was created and verified against the current final `Database/CreateDatabase.sql`. The original database was inspected read-only and preserved. Web.config now targets the final catalog. The solution builds with 0 warnings and 0 errors. **Application runtime verification remains BLOCKED; do not describe the application as successfully running against the final database yet.**

## Old and new identities

Both use the existing `(LocalDB)\MSSQLLocalDB` instance. The observed running server was `DESKTOP-68QHNL4\LOCALDB#AA1578EA`; its existing named pipe was used for SQL inspection/creation without restarting or resetting LocalDB.

Old configured connection:

```text
Data Source=(LocalDB)\MSSQLLocalDB;AttachDbFilename=|DataDirectory|\LearningSystem.mdf;Integrated Security=True
```

Old actual DB_NAME(): `C:\USERS\UJWAL CHHETRI\SOURCE\REPOS\LEARNINGSYSTEM\APP_DATA\LEARNINGSYSTEM.MDF`.
Old physical files: `C:\Users\Ujwal Chhetri\source\repos\LearningSystem\App_Data\LearningSystem.mdf` and `LearningSystem_log.ldf` in the same directory. No DROP, DETACH, rebuild, migration, or data writes were executed against this database.

New DB_NAME(): `LearningSystemFinal`.
New files: `C:\Users\Ujwal Chhetri\source\repos\LearningSystem\App_Data\LearningSystemFinal.mdf` and `LearningSystemFinal_log.ldf` in the same directory. The new catalog remains attached.

Current `Web.config`, connection name `LearningSystemDb`:

```text
Data Source=(LocalDB)\MSSQLLocalDB;Initial Catalog=LearningSystemFinal;Integrated Security=True
```

`Helpers/DatabaseHelper.cs:10` reads exactly this named connection. No active Debug/Release connection transform overrides it. No absolute machine-specific path is committed in the application connection string. MDF/LDF files remain git-ignored.

## Read-only schema comparison

| Item | Old live database | Clean final database |
| --- | --- | --- |
| Application tables | 25 | 25 |
| Missing final tables/columns in old | None in the column comparison | All current script definitions present |
| Course.IsPaid / PriceNPR | BIT NOT NULL / DECIMAL(10,2) NOT NULL, price check present | Same |
| Material.MaterialType | NVARCHAR(7), six original values; Code rejected | NVARCHAR(7), original six plus Code |
| CK_Material_3 | No Code | Includes Code |
| CK_Material_6 | Non-null TextContent required for Text | Required for Text and Code |
| Activity.GameTemplate | NVARCHAR(8), four original values | NVARCHAR(10), all eight values |
| CK_Activity_7 | Matching, Memory, Scramble, Sort | Adds Flashcards, FillBlank, TrueFalse, Sequence |
| Payment columns / UUID unique / FKs / checks | Present and matching | Present and matching |
| IX_Payment_LearnerID / IX_Payment_CourseID | Both missing | Both present on the named columns |
| PageView | Present from previous Analytics repair | Present from current final script |
| IX_PageView_ViewedAt | Present on ViewedAt | Present on ViewedAt |
| Code Labs | 0 | 5 Published |
| Subjects / courses | 3 / 10; older dataset | 8 / 19; 18 Published, 1 Draft |

All compared column types/lengths/precision/scale/nullability match except GameTemplate width. All compared CHECK definitions match except the three listed above. The missing final indexes are exactly the two Payment indexes above. This is an older development schema with later pricing/Analytics repairs, not a complete Phase 17 database.

Payment has PaymentID INT identity primary key; LearnerID/CourseID INT NOT NULL; Provider NVARCHAR(20) NOT NULL; TransactionUUID NVARCHAR(64) NOT NULL; ProviderReference NVARCHAR(100) NULL; AmountNPR DECIMAL(10,2) NOT NULL; Status NVARCHAR(20) NOT NULL; CreatedDate DATETIME2(0) NOT NULL; VerifiedDate DATETIME2(0) NULL. UQ_Payment_TransactionUUID is unique on TransactionUUID. FK_Payment_User and FK_Payment_Course both use NO ACTION. Checks require Provider=eSewa, AmountNPR>0 and Status in Pending/Complete/Failed/Canceled.

PageView has PageViewID INT identity primary key, PagePath NVARCHAR(200) NOT NULL, ViewerRole NVARCHAR(7) NOT NULL and ViewedAt DATETIME2(0) NOT NULL. Its existing path/role checks and ViewedAt index match the script.

## Safe creation and integrity

The original CreateDatabase.sql contains hard-coded destructive lifecycle statements targeting LearningSystem and its original files. It was **not** executed as-is against the old database.

`Database/CreateFinalDatabase.ps1` copied the complete current schema/seed/integrity section without changing its SQL. It substituted only a safe, create-only database lifecycle for LearningSystemFinal and new files, and omitted the old database drop/detach operations. It refuses existing final files/catalogs and unexpected lifecycle statements inside the copied section. Source CreateDatabase.sql was not edited.

Source SHA256: `718DF410B36BF797BA6CD34B32797E5E84B6E5520FBD74BB23701443C0BC348D`.

sqlcmd exited 0. Script output: `Seed checks passed. Users: 12. Courses: 19. Materials: 72. Activities: 73. Attempts: 38.` The seed transaction committed after its checks. Final read-only queries confirmed 25 tables, 24 enrolments, 2 payments, the pricing fields and all requested constraints/indexes. No extra destructive tests or database rebuilds were performed.

Account mix: 1 Active Admin, 6 Active Teachers, 1 Pending Teacher, 4 Active Learners. Credentials belong only in `docs/DEMO_CREDENTIALS.md`; old development accounts are not migrated into this clean dataset.

Subjects: Programming; Cybersecurity; Artificial Intelligence; Mathematics and Data; Business; Science; English and Communication; Study Skills. Sixteen courses are Free; three are Paid, NPR 299–499.

## Material counts and Code Labs

| MaterialType | Old count | Final count |
| --- | ---: | ---: |
| Audio | 0 | 4 |
| Code | 0 | 5 |
| Image | 8 | 10 |
| PDF | 5 | 6 |
| Text | 51 | 43 |
| Video | 0 | 4 |
| YouTube | 1 | 0 |

The current final seed does not include a YouTube row; support remains in source/schema. Code is a MaterialType, never an ActivityType.

| MaterialID | Course | Topic | Code Lab title |
| --- | --- | --- | --- |
| 3 | HTML and CSS: Build Your First Web Page | How a web page is built | Code lab: your first page |
| 6 | HTML and CSS: Build Your First Web Page | Styling with CSS | Code lab: style a profile card |
| 10 | JavaScript Basics for the Browser | Values, variables and decisions | Code lab: grade calculator |
| 12 | JavaScript Basics for the Browser | Loops and functions | Code lab: times table generator |
| 14 | JavaScript Basics for the Browser | Responding to the user | Code lab: click counter |

All five are Published and have non-null TextContent (394, 588, 515, 517 and 542 characters respectively), within the approved 20–10,000 range.

Source evidence: Teacher/MaterialEdit.aspx:11 provides the Code option; Teacher/MaterialEdit.aspx.cs:63–76 displays/validates Code starter content; :130 stores Text and Code in the parameterized TextContent field. Helpers/MaterialHelper.cs:28–35 renders an encoded editor, Run code and Reset buttons, and sandboxed result iframe. Scripts/site.js:42–51 assigns editor content to iframe.srcdoc and restores the original starter content on Reset. These rows are compatible with the existing implementation. **UI/Run/Reset runtime pass has not been demonstrated in this task.**

## Game counts

| GameTemplate | Old count | Final count |
| --- | ---: | ---: |
| Matching | 3 | 6 |
| Memory | 3 | 2 |
| Scramble | 2 | 2 |
| Sort | 2 | 9 |
| Flashcards | 0 | 4 |
| FillBlank | 0 | 4 |
| TrueFalse | 0 | 6 |
| Sequence | 0 | 6 |

All eight final templates are represented and satisfy the script's published-template seed check. No game functionality was changed.

## Build and runtime limitation

MSBuild built LearningSystem.slnx, Debug, successfully: **0 warnings, 0 errors**.

Existing IIS Express was not running at verification time. One launch used the existing project-local applicationhost.config, existing site LearningSystem, and existing HTTPS binding 44393. Its log confirmed registration and one Home GET response with HTTP 200. The browser first reported localhost connection refused, then its navigation/control timed out. This does not establish successful Home content rendering.

A direct ADO.NET Open using the exact new Web.config connection string failed with SQL Network Interfaces error 50: `Local Database Runtime error occurred. Error occurred during LocalDB instance startup: SQL Server process failed to start.` The already-running LocalDB named pipe still permitted safe queries to LearningSystemFinal. Consequently, the portable application connection is configured for the correct final catalog but its normal named-instance startup/resolution is blocked in this environment. PageView remained empty; no Analytics runtime pass is claimed.

No SQL reset/detach/restart, alternate test host, certificate install, firewall/security change or machine-wide configuration change was attempted. Do not interpret the verified schema or successful build as proof of working application flows.

| Requested runtime check | Result |
| --- | --- |
| Home | BLOCKED: browser content not verified; server log alone shows one HTTP 200 |
| Courses catalogue | NOT RUN due to established environment limitation |
| Student / Lecturer / Admin login | NOT RUN |
| Text lesson / Code lesson editor, buttons and output | Source/database verified; runtime NOT RUN |
| Run changes iframe output / Reset restores starter | Source verified; runtime NOT RUN |
| Course outline includes Code Labs | NOT RUN |
| Original game / Phase 17 game | Seed/schema verified; runtime NOT RUN |
| Admin Analytics / PageView | Schema/index verified; runtime NOT RUN |
| Free / paid course display | Data/price constraint verified; runtime NOT RUN |

## Remaining manual checks

After starting the project through the team's normal Visual Studio/IIS Express setup and resolving the existing LocalDB startup problem without weakening security:

1. Open Home and Courses. Expect 18 public courses, 8 subject categories, and Free/NPR prices. Open the paid JavaScript course (NPR 499).
2. Use each portal with its corresponding account from DEMO_CREDENTIALS.md. Expect the correct role dashboard; log out between accounts. The old admin@example.test account belongs to the preserved old database, not this clean seed.
3. As Anita, open HTML and CSS from My Courses. Open the first Text material, then Code lab: your first page (MaterialID 3). Verify editor, Run code, Reset and result iframe are present.
4. Replace a heading in the editor and press Run code. Confirm the iframe heading changes. Press Reset; confirm both starter code and output return to their original state. Confirm the outline includes both Code Labs.
5. As owning lecturer Asha, preview the Matching game (ActivityID 2) and FillBlank game (ActivityID 4) from CourseBuilder. Complete one representative play of each; preview must save no Attempt.
6. As Admin, visit Analytics after several public/role page visits. Confirm recorded PageView data and charts load.
7. Confirm paid/free course pages show their expected prices, existing paid enrolments open normally, and an unpurchased paid course offers checkout rather than direct access. Do not perform real-money testing; Phase 17 uses the approved offline eSewa-style demo.

## Documentation and fallback

AGENTS.md's six-material/four-game list was stale. Corrected only the approved Phase 17 value lists, associated explanation and approved final database target. Phase 17 DECISIONS/CONTRACTS supersede those older lists for this extension. BLUEPRINT.md is unchanged.

To select the old fallback deliberately, stop/log out of the app and restore the old connection string above in Web.config; do not run CreateDatabase.sql. The old custom presentation fixtures remain only in the old database. Do not automatically run SeedPresentationDemo.ps1 now: it reads Web.config and would add records to the new final catalog.

Files created in this task: Database/CreateFinalDatabase.ps1; docs/PHASE17-FINAL-DATABASE.md. Files changed: Web.config; LearningSystem.csproj (tool/report entries); AGENTS.md; Database/README.md; docs/CONTRACTS.md; docs/DECISIONS.md; docs/PROGRESS.md; docs/DEMO-DATA.md (old-fixture clarification). No C#/.aspx/JavaScript/CSS application logic was changed. No original schema/seed SQL was changed. Existing unrelated modifications were preserved.