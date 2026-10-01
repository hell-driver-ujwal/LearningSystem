# Implementation evidence — refreshed Phase 16

Paths are project-relative; line numbers checked against current source on 1 October 2026. Source evidence is not a runtime pass. Build succeeded with 0 warnings/errors; final runtime blocked by LocalDB startup. See PHASE16-AUDIT.md for findings and authorization/contract qualifications.

## Original assignment HTML/CSS/validation/SQL

| Item | Exact source | Demonstrates |
| --- | --- | --- |
| header | `Site.Master:15` | Actual semantic element emitted by the page/shared renderer. |
| nav | `Site.Master:18` | Actual semantic element emitted by the page/shared renderer. |
| main | `Site.Master:22` | Actual semantic element emitted by the page/shared renderer. |
| section | `Default.aspx:4` | Actual semantic element emitted by the page/shared renderer. |
| article | `Helpers/CourseHelper.cs:40` | Actual semantic element emitted by the page/shared renderer. |
| footer | `Site.Master:29` | Actual semantic element emitted by the page/shared renderer. |
| figure / figcaption | `Helpers/MaterialHelper.cs:28` | Actual semantic element emitted by the page/shared renderer. |
| video | `Helpers/MaterialHelper.cs:30` | Actual semantic element emitted by the page/shared renderer. |
| audio | `Helpers/MaterialHelper.cs:31` | Actual semantic element emitted by the page/shared renderer. |
| progress | `Helpers/CourseHelper.cs:30` | Actual semantic element emitted by the page/shared renderer. |
| canvas | `Helpers/ChartHelper.cs:27` | Actual semantic element emitted by the page/shared renderer. |
| details / summary | `Help.aspx.cs:22` | Actual semantic element emitted by the page/shared renderer. |
| Email input | `Account/Register.aspx:15` | Web Forms HTML5 input type; server validation remains required. |
| Url input | `Teacher/MaterialEdit.aspx:17` | Web Forms HTML5 input type; server validation remains required. |
| Number input | `Teacher/MaterialEdit.aspx:19` | Web Forms HTML5 input type; server validation remains required. |
| Password input | `Account/Register.aspx:21` | Web Forms HTML5 input type; server validation remains required. |
| Search input | `Courses.aspx:5` | Web Forms HTML5 input type; server validation remains required. |
| External CSS | `Site.Master:8` | Shared local visual system. |
| Internal CSS | `Site.Master:10` | Assignment demonstration; comment immediately above. |
| Inline CSS | `Default.aspx:6` | Assignment demonstration retained. |
| RequiredFieldValidator | `Account/Register.aspx:10` | Real server validation control. |
| RegularExpressionValidator | `Account/Register.aspx:11` | Real server validation control. |
| CompareValidator | `Account/Register.aspx:30` | Real server validation control. |
| RangeValidator | `Teacher/MaterialEdit.aspx:21` | Real server validation control. |
| CustomValidator | `Teacher/MaterialEdit.aspx:24` | Real server validation control. |
| ValidationSummary | `Account/Register.aspx:6` | Real server validation control. |
| Page.IsValid | `Account/Register.aspx.cs:49` | Reject before registration INSERT. |
| INSERT / SqlParameter | `Account/Register.aspx.cs:53–61` | Parameterized registration. |
| SELECT JOIN / SqlParameter | `Helpers/MaterialHelper.cs:14` | Database material/course lookup with @id. |
| UPDATE | `Helpers/DiscussionHelper.cs:17` | Scoped update with parameters. |
| DELETE | `Helpers/DeleteHelper.cs:81` | Parameterized deletion; see SYS-19 transaction evidence. |
| ADO.NET binding | `Helpers/DatabaseHelper.cs:47` | Parameters attached to SqlCommand. |

## Original system/security evidence

| Requirement | Source and explanation |
| --- | --- |
| SYS-19 | `Helpers/DeleteHelper.cs:74–77` — Transactional dependent deletes; standalone steps in ScenarioHelper.DeleteStep. |
| SYS-20 | `Global.asax.cs:21–25` — PostAuthenticate attaches ticket role before URL authorization. |
| AUTH-03 | `Helpers/AccountSecurityHelper.cs:15–82` — CheckLogin: locked/non-active accounts blocked; password verified; approved role mismatch handling. |
| SYS-03 | `Helpers/AccessHelper.cs:63–80` — RequireRole plus owner/enrolment/material guards; page-specific matrix below. |
| MAT-10 | `Teacher/MaterialEdit.aspx.cs:70–99` — Server type/text/file/YouTube/alt/publication validation; Save persists preview flag. |
| PRV-01 | `Helpers/ActivityAccessHelper.cs:17–24` — Active current owner/admin preview accepts draft; normal learner requires publication/enrolment. |
| PRV-02 | `Helpers/SelfAssessmentHelper.cs:64–68` — Representative explicit no-write branch; all six page branches cross-referenced in access/security tables. |
| QZ-10 | `Helpers/QuizHelper.cs:101–159` — Session token/time+30s/definition/limits, weighted marking, transactional Attempt/answers, preview branch. |
| QZ-11 | `Member/QuizResult.aspx.cs:15–27` — Own/owner/admin result authorization, published learner content, saved answer review. |
| GAM-06 | `Helpers/GameContentHelper.cs:29–57` — Valid template, owned topic, template/content locks, shared publish checks. |
| SIM-11 | `Helpers/ScenarioPlayHelper.cs:63–100` — Session current step/run/revision, database choice target, valid ending before one NULL-score Attempt. |
| ENR-06 | `Teacher/CourseLearners.aspx.cs:14–21` — Owner check; query projects FullName only, no email. |
| SYS-16 | `Site.Master.cs:116–119` — Shared table headers, labels/alt/focus; checkout external form falls outside main (S03). |
| SYS-11 | `Teacher/MyCourses.aspx:17` — Postback Delete/Leave controls confirm; postback scans reviewed all destructive controls. |
| Forms Authentication | `Helpers/AuthenticationHelper.cs:24–27` |
| Upload validation | `Helpers/UploadHelper.cs:9–12` |
| GUID upload name | `Helpers/UploadHelper.cs:32–35` |
| Protected media | `Media.ashx.cs:34–37` |
| Content lock | `Helpers/ActivityHelper.cs:50–53` |
| Post/Redirect/Get | `Member/Quiz.aspx.cs:78–81` |
| HTML encoding | `Helpers/CourseHelper.cs:25–28` |
| Quiz answer secrecy | `Member/Quiz.aspx.cs:52–55` |
| No-save preview | `Helpers/SelfAssessmentHelper.cs:64–67` |

**Contrary evidence / M01:** `Web.config:24–27` has mode Off. Friendly ASP.NET error protection must not be claimed complete. Checkout landmark gap S03 remains. Home real media/subject images and contact details await team assets (Q31); material video/audio evidence is not supplied Home media.

## Implemented optional assignment features (Tier A and B)

| Feature | Current evidence |
| --- | --- |
| FAQ-04 | `Help.aspx.cs:17–25` — Page_Load: audience-filtered FAQ, encoded details/summary; static guidance retained. |
| LCK-03 | `Admin/Users.aspx.cs:47–84` — Admin page; non-admin predicates for status/unlock; delete helper; filtered/paged users. |
| CHT-01 | `Helpers/ChartHelper.cs:31–54` — Groups existing owned Quiz/Game results into five score bins; no extra report query. |
| CHT-02 | `Admin/Dashboard.aspx.cs:22–28` — ChartHelper reuses real role and subject data; plain Scripts/charts.js. |
| LCK-01 | `Helpers/AccountSecurityHelper.cs:37–49` — Locked row failure count; five failures15min, expiry allowed, successful reset. |
| LCK-02 | `Helpers/AccountSecurityHelper.cs:37–49` — Locked row failure count; five failures15min, expiry allowed, successful reset. |
| MAP-01 | `SiteMap.aspx.cs:11–27` — Public plus own-role links only; IDs reached through authorized lists. |
| CAP-01 | `Helpers/CaptchaHelper.cs:8–27` — Session arithmetic question; Register/Contact use independent lifecycle-controlled keys. |
| SSL-01 | `Global.asax.cs:9–18` — Fixed configured HTTPS origin preserving path/query; secure cookies in Web.config. |
| REV-01 | `Helpers/ReviewHelper.cs:23–37` — Current enrolled/published learner, integer1–5/comment length; unique upsert. |
| REV-02 | `Helpers/ReviewHelper.cs:23–37` — Current enrolled/published learner, integer1–5/comment length; unique upsert. |
| REV-03 | `Helpers/ReviewHelper.cs:37–51` — Author+course constrained delete or explicit Admin role; transaction; teacher denied. |
| REV-06 | `Helpers/ReviewHelper.cs:37–51` — Author+course constrained delete or explicit Admin role; transaction; teacher denied. |
| REV-04 | `CourseDetails.aspx.cs:47–64` — Encoded reviews and average; review editor only eligible enrolled learner. |
| REV-05 | `Helpers/CourseHelper.cs:44–46` — Course cards use shared review average. |
| CON-01 | `Contact.aspx.cs:37–49` — Server validated independent CAPTCHA, user identity, send token, parameterized insert and PRG. |
| CON-02 | `Admin/Messages.aspx.cs:12–45` — Admin inbox/read; explicit POST mark-read; confirmed transactional delete; paged list. |
| CON-03 | `Admin/Messages.aspx.cs:12–45` — Admin inbox/read; explicit POST mark-read; confirmed transactional delete; paged list. |
| CON-04 | `Admin/Messages.aspx.cs:12–45` — Admin inbox/read; explicit POST mark-read; confirmed transactional delete; paged list. |
| FAQ-01 | `Admin/FAQ.aspx.cs:18–47` — Admin validation/audience/order/save token; confirmed transactional deletion; deterministic order. |
| FAQ-02 | `Admin/FAQ.aspx.cs:18–47` — Admin validation/audience/order/save token; confirmed transactional deletion; deterministic order. |
| FAQ-03 | `Admin/FAQ.aspx.cs:18–47` — Admin validation/audience/order/save token; confirmed transactional deletion; deterministic order. |
| KEY-01 | `Scripts/shortcuts.js:4–16` — Alt H/C/D/Q, authorized destination, typing/composition/repeat/modifier exclusions. |

O10 Dark Mode and O14 Game Sounds: **INTENTIONALLY DEFERRED — Phase 14 skipped by team decision**. Canvas, printable certificates and managed FAQ now exist; old Phase 11 deferral notes are superseded.

## Custom Phase 15 (outside original blueprint)

See PHASE16-AUDIT.md custom A–R matrix for exact portal/shared-auth, pricing, signed request/response, server verification, atomic enrolment, retained purchase and reporting evidence. This approved extension is not evidence that payments were an original assignment requirement. Real first-time sandbox COMPLETE remains unverified.

## Report use

Section 17 R01–R22 and D06–D08 are individually mapped in PHASE16-AUDIT.md. Team report diagrams/wireframes and editorial judgement of learning content remain separate deliverables; code citations do not replace them. TEST_CHECKLIST.md contains unperformed manual acceptance steps.

| ADM-06 | `Admin/UserEdit.aspx.cs:92–108` — Validated temporary password hash and MustChangePassword=1, excludes Admin. |

| BMK-01 | `Helpers/BookmarkHelper.cs:12–26` — Current active enrolled learner, published material/course; idempotent own add/remove. |

| BMK-02 | `Helpers/BookmarkHelper.cs:12–26` — Current active enrolled learner, published material/course; idempotent own add/remove. |

| BMK-03 | `Helpers/BookmarkHelper.cs:25–29` — Only current learner bookmarks; availability recalculated from publication and enrolment. |

| CER-01 | `Learner/Certificate.aspx.cs:16–22` — Current learner, published/enrolled, shared100m, UTC print date; print.css presentation. |

| CER-02 | `Learner/Certificate.aspx.cs:16–22` — Current learner, published/enrolled, shared100m, UTC print date; print.css presentation. |
