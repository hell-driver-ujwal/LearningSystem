# Implementation evidence — core application through Phase 11

Paths below are relative to the LearningSystem project root. Line references identify the actual implementation on 30 September 2026. This is source evidence, not a claim that every branch has been runtime-tested. See PHASE11-VERIFICATION.md for the deliberately limited visual/runtime checks.

## HTML5 and multimedia

| Requirement/item | Exact file and line(s) | What the source demonstrates |
| --- | --- | --- |
| header | `Site.Master:15` | Shared site header with brand and navigation. |
| nav | `Site.Master:18–19` | Role-specific main navigation, with a separate account group. |
| main | `Site.Master:22` | One main landmark; focusable skip-link destination. |
| section | `Default.aspx:4` | Home hero is a semantic section. |
| article | `Helpers/CourseHelper.cs:40` | Each database-backed course card is an article. |
| footer | `Site.Master:27` | Shared footer with honest contact placeholders and navigation. |
| figure / figcaption / meaningful alt | `Helpers/MaterialHelper.cs:28` | Image material uses a figure, encoded alt text and an encoded title caption. |
| video | `Helpers/MaterialHelper.cs:30` | MP4 video with controls, metadata preload and fallback text; no autoplay. |
| audio | `Helpers/MaterialHelper.cs:31` | MP3 audio with controls and fallback text; no autoplay. |
| progress | `Helpers/CourseHelper.cs:30` | Native progress bar and visible percentage from the single shared method. |
| canvas (Phase 12 update) | `Helpers/ChartHelper.cs:27–29`; `Scripts/charts.js:4–26` | O1 canvas charts use plain JavaScript with an adjacent HTML data alternative. |
| details / summary | `Help.aspx:4` | Static FAQ uses native keyboard-operable disclosures. |
| Email input | `Account/Register.aspx:15` | Registration email control renders an HTML5 email input. |
| URL input | `Teacher/MaterialEdit.aspx:17` | YouTube material URL input. |
| Number input | `Teacher/MaterialEdit.aspx:19` | Material ordering uses a numeric input with server validation. |
| Password input | `Account/Register.aspx:21` | Masked password input. |
| Search input | `Courses.aspx:5` | Catalogue title/description search input. |

Home intro video/poster and subject images are awaiting real team assets under Q31 (PUB-01 partial). The lesson video/audio implementations above are real renderer evidence; they are not evidence of a supplied Home intro video. Game sounds are deferred to Phase 14 / optional feature O14.

## CSS and accessibility

| Requirement/item | Exact file and line(s) | What the source demonstrates |
| --- | --- | --- |
| External CSS | `Site.Master:8` | All pages load the shared local stylesheet. |
| Internal CSS | `Site.Master:9–10` | Assignment-labelled internal style example is retained. |
| Inline CSS | `Default.aspx:5–6` | Assignment-labelled inline font-weight example is retained. |
| Responsive visual system | `Styles/site.css:144–147` | Desktop course columns, tablet wrapping, phone single-column layouts and usable navigation. |
| Keyboard focus | `Styles/site.css:7` | Visible outlines on links, native controls, disclosure summaries and scroll regions. |
| Table keyboard overflow | `Teacher/Results.aspx:8` | Focusable labelled overflow region around the existing accessible GridView. |
| GridView caption / headers | `Site.Master.cs:110–111` | Shared accessible column headers and a real table header section. |
| Image alt text | `Teacher/MaterialEdit.aspx:16` | Image authoring includes an associated alt-text field; renderer encodes it. |
| Accessible feedback | `Site.Master.cs:85–86` | Error alert versus success status; textual Error/Success prefix does not rely on colour. |
| Validation focus / alert | `Site.Master.cs:104–106` | Validators focus the invalid control; summary announces errors. |
| Matching interaction | `Scripts/games.js:45–54` | Native-button select/place interaction, explicit keyboard instructions and pressed state. |
| Sort interaction | `Scripts/games.js:139–142` | Same select/place pattern and keyboard instructions; no drag-and-drop. |
| Game native buttons | `Scripts/games.js:23–28` | Buttons have type=button and click handlers, supporting keyboard, mouse and touch. |
| Live game feedback | `Scripts/games.js:9–10` | Live status announces selections and placements. |
| Reduced motion | `Styles/site.css:166` | Card animation respects reduced-motion preference. |

## Validation

| Requirement/item | Exact file and line(s) | What the source demonstrates |
| --- | --- | --- |
| RequiredFieldValidator | `Account/Register.aspx:10` | Required account name. |
| RegularExpressionValidator | `Account/Register.aspx:17` | Email format/length validator. |
| CompareValidator | `Account/Register.aspx:30` | Password confirmation matches the password field. |
| RangeValidator | `Teacher/MaterialEdit.aspx:21` | Integer ordering range checked server-side. |
| CustomValidator | `Teacher/MaterialEdit.aspx:24` | Material validation invokes ValidateMaterial on the server. |
| ValidationSummary | `Account/Register.aspx:6` | Shared summary presents form errors. |
| Page.IsValid | `Account/Register.aspx.cs:37` | Save handler exits before any INSERT on failed validation. |

## Parameterized SQL

| Requirement/item | Exact file and line(s) | What the source demonstrates |
| --- | --- | --- |
| INSERT + SqlParameter | `Account/Register.aspx.cs:41–49` | Registration uses named SQL placeholders and typed parameters, never concatenated field values. |
| SELECT with JOIN + SqlParameter | `Helpers/MaterialHelper.cs:14` | Joined material/course lookup restricts @id via SqlParameter. |
| UPDATE + SqlParameter | `Helpers/DiscussionHelper.cs:17` | Post editing is parameterized and scoped by post/activity/author. |
| DELETE parameter binding | `Helpers/DeleteHelper.cs:14–17` | The common @id parameter array used by delete commands. |
| DELETE statements | `Helpers/DeleteHelper.cs:78–82` | Children-first deletes use @id, not concatenated request values. |
| ADO.NET binding | `Helpers/DatabaseHelper.cs:47` | Parameters are attached to SqlCommand before execution. |

## System and security

| Requirement/item | Exact file and line(s) | What the source demonstrates |
| --- | --- | --- |
| SYS-19 transaction delete | `Helpers/DeleteHelper.cs:71–76` | Serializable delete transaction, with authorization and children-first operations before commit. |
| SYS-19 commit | `Helpers/DeleteHelper.cs:93` | Successful delete commits as one transaction; disposal rolls back failed work. |
| SYS-20 Global hook | `Global.asax.cs:9–12` | Global authentication hook invokes shared role attachment. |
| SYS-20 role principal | `Helpers/AuthenticationHelper.cs:51` | Ticket role becomes the request principal role. |
| Forms Authentication | `Helpers/AuthenticationHelper.cs:24–31` | Own Forms Authentication ticket stores role and is encrypted into the cookie. |
| Password hashing | `Helpers/PasswordHelper.cs:11` | Built-in PBKDF2 password derivation, rather than plaintext storage. |
| Role + active account check | `Helpers/AccessHelper.cs:63–77` | Shared protected-page guard checks authentication, current active status and allowed roles. |
| Ownership check | `Teacher/CourseLearners.aspx.cs:14` | Course URL must belong to the current teacher before displaying learner names. |
| Enrolment / publication | `Helpers/ActivityAccessHelper.cs:18–20` | Normal activities require Published content, then the current learner enrolment; preview has explicit owner/admin authorization. |
| Upload validation | `Helpers/UploadHelper.cs:9–18` | Server checks extension and byte limits per material type. |
| GUID filenames | `Helpers/UploadHelper.cs:32` | Saved uploads use a new GUID filename, not an arbitrary client path. |
| Protected media handler | `Media.ashx.cs:34–36` | Serving material files requires authorization based on database records. |
| Direct upload block | `Web.config:78` | Project-local request filtering blocks direct Uploads access. |
| Content lock | `Helpers/ScenarioHelper.cs:31` | Attempts block structural Scenario writes. |
| Post/Redirect/Get | `Member/Quiz.aspx.cs:78` | Successful saved quiz submission redirects to the result GET. |
| Encoded text | `Helpers/CourseHelper.cs:25` | Shared user-text HTML encoding; cards and outlines call it. |
| Quiz answers withheld | `Member/Quiz.aspx.cs:52–54` | Pre-submit renderer emits only option ID and encoded option text; IsCorrect is never rendered. |
| Quiz server marking | `Helpers/QuizHelper.cs:137` | Correctness is determined using server-side question/option records. |
| Preview has no attempt insert | `Helpers/SelfAssessmentHelper.cs:64–67` | Preview returns before the transactional Attempt/SAResponse INSERTs. |
| Scenario preview path | `Helpers/ScenarioPlayHelper.cs:92` | Validated endings insert an Attempt only outside preview. |
| Protected request cache | `Site.Master.cs:25–26` | Sensitive pages are not cached. |
| Request validation | `Web.config:18` | Request validation and event validation remain enabled. |
| Friendly errors fixed | `Web.config:19–22` | ASP.NET technical errors are replaced by the friendly error page. |
| Native-server friendly errors | `Web.config:82–85` | Project-local IIS errors use custom responses, not detailed technical pages. |
| Single progress implementation | `Helpers/ProgressHelper.cs:23–30` | Shared Q31 percentage, including zero items and AwayFromZero rounding. |
| Preview exit | `Member/Scenario.aspx.cs:21` | Scenario preview clearly exits back to the authorized course/activities destination. |
| Result dead-end exit | `Member/QuizResult.aspx:7` | Learners can reach My Results in addition to retry and back links. |

## Section 17 traceability review

The source examples above support R03/R04, R06, R09/R10, R12–R15, R19 and R22 directly. Role/access examples and registration validators support R01/R16–R18; master navigation and result/preview exits support R07/R08. R02 is represented by the activity security, preview, marking and game interaction examples. R05 uses the actual material renderers; missing Home media remains partial. R20 retains the existing Web Application folders/project includes. R21 retains the approved database and transactional deletion implementation; no schema review/rebuild was added to this phase.

R11 still requires the team's editorial judgement of real teaching content. Optional portions of these requirements (site map, charts/canvas, print certificate styling, theme, reviews/bookmarks, contact/FAQ management and CAPTCHA) are intentionally deferred to their documented phases, not marked as core failures. D06/D07 are team report diagrams, not application features created here; D08 can use the exact code references in this document.

| Requirement/item | Exact file and line(s) | What the source demonstrates |
| --- | --- | --- |
| Consistent Unicode rendering | `Web.config:10` | Explicit UTF-8 prevents machine-default encoding from corrupting markup punctuation. |

Phase 12 update: O1 canvas/charts and O4 SiteMap are now implemented. Q34 account security, CAPTCHA and HTTPS are recorded in CONTRACTS.md; see PHASE12-VERIFICATION.md. Other optional deferrals above describe the original Phase 11 review; Tier B/C remain deferred.

Phase 13 update: O5 reviews, O6 Contact/inbox, O7 bookmarks, O8 calculated certificates/print stylesheet, O9 FAQ management and O11 shortcuts are now implemented. Earlier deferral notes describe the Phase 11 snapshot. See PHASE13-VERIFICATION.md for current files, representative checks and manual limits; Tier C remains deferred.
