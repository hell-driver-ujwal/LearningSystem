# Phase 0 contracts — approved review decisions recorded; remaining proposals pending

Read in full: AGENTS.md and docs/BLUEPRINT.md. Approved review decisions Q01–Q07, Q16 and Q17 were recorded on 2026-09-28. **Phase 1 is not authorized by this update.** This is documentation, not application code or a migration. The 23-table scope is retained; Material.Status is the explicitly approved addition to blueprint Section 6. BLUEPRINT.md remains unchanged.

The blueprint is conceptual. **P** means a proposed technical choice requiring review, not a confirmed requirement. The decisions explicitly recorded here and in DECISIONS.md are approved; remaining helper signatures, query parameter names and choices not covered by those decisions remain proposals. QUESTIONS.md is the original question inventory and has not been edited in this update: use the approved decisions here for Q01–Q07, Q16 and Q17, and retain unanswered details as open. Approval of these decisions does not imply approval of every remaining proposal.

## SQL conventions — approved Q03, with remaining proposals identified

SQL Server dbo schema; quote [User]. Each single-column PK is INT IDENTITY(1,1) NOT NULL. Composite PK members are INT NOT NULL without identity. FK types are INT. All ON UPDATE actions are NO ACTION. NN=NOT NULL; N=NULL; a dash means no DEFAULT constraint. Nullable columns have no explicit default. Dates use DATETIME2(0); generated dates use SYSUTCDATETIME(). LastUpdated/EditedDate require explicit application updates. BIT columns accept 0/1.

Unicode text uses NVARCHAR. FilePath and YouTubeURL use NVARCHAR(500); ContactMessage.SenderEmail uses NVARCHAR(100), approved in Q02. The existing NVARCHAR(500) proposals for CoverImagePath and ImagePath are retained. Trim user input in C# before validation and storage; text lengths use LEN on the trimmed value. NVARCHAR(MAX) plus a length check supports 10,000-character lessons. Use standard SQL Server case-insensitive collation; Email and SubjectName uniqueness are case-insensitive. DECIMAL(5,2) is approved for percentage/average values; sensible nullable optional fields and fixed-enum CHECK constraints are approved. Timestamp defaults remain SYSUTCDATETIME(); GETUTCDATE() was also approved where appropriate. No exact collation identifier or unspecified game duplicate policy is invented.

Create all 23 tables in Phase 1, including later optional-feature tables and their listed columns. Optional features remain dormant until their assigned phases. Create and seed FAQ in Phase 1 for Help; Phase 5 may display it; FAQ management remains optional in Phase 13 (Q16). Mission text, contact information and final real course content can be supplied later and do not block Phase 1 (Q17). This describes the approved plan, not authorization to begin it.

The following tables specify every Section 6 column plus the approved Material.Status addition. The PK declaration under each table supplements its column row. CHECKs and UNIQUE constraints follow the tables. Foreign-key targets and delete actions are exhaustively listed later. No unlisted UNIQUE, CHECK or cascade is implied.

## Table: User

Primary key: (UserID).

| Column | SQL type | Null | Default |
| --- | --- | --- | --- |
| UserID | INT IDENTITY(1,1) | NN | identity |
| FullName | NVARCHAR(100) | NN | - |
| Email | NVARCHAR(100) | NN | - |
| PasswordHash | NVARCHAR(200) | NN | - |
| Role | NVARCHAR(7) | NN | - |
| Status | NVARCHAR(11) | NN | - |
| ApplicationReason | NVARCHAR(500) | N | - |
| CreatedDate | DATETIME2(0) | NN | SYSUTCDATETIME() |
| FailedLoginCount | INT | NN | 0 |
| LockedUntil | DATETIME2(0) | N | - |
| MustChangePassword | BIT | NN | 0 |

## Table: Subject

Primary key: (SubjectID).

| Column | SQL type | Null | Default |
| --- | --- | --- | --- |
| SubjectID | INT IDENTITY(1,1) | NN | identity |
| SubjectName | NVARCHAR(50) | NN | - |
| Description | NVARCHAR(300) | N | - |

## Table: Course

Primary key: (CourseID).

| Column | SQL type | Null | Default |
| --- | --- | --- | --- |
| CourseID | INT IDENTITY(1,1) | NN | identity |
| TeacherID | INT | NN | - |
| SubjectID | INT | NN | - |
| Title | NVARCHAR(100) | NN | - |
| Description | NVARCHAR(1000) | NN | - |
| CoverImagePath | NVARCHAR(500) | N | - |
| Status | NVARCHAR(9) | NN | 'Draft' |
| CreatedDate | DATETIME2(0) | NN | SYSUTCDATETIME() |
| LastUpdated | DATETIME2(0) | NN | SYSUTCDATETIME() |

## Table: Topic

Primary key: (TopicID).

| Column | SQL type | Null | Default |
| --- | --- | --- | --- |
| TopicID | INT IDENTITY(1,1) | NN | identity |
| CourseID | INT | NN | - |
| Title | NVARCHAR(100) | NN | - |
| SortOrder | INT | NN | - |

## Table: Material

Primary key: (MaterialID).

| Column | SQL type | Null | Default |
| --- | --- | --- | --- |
| MaterialID | INT IDENTITY(1,1) | NN | identity |
| TopicID | INT | NN | - |
| Title | NVARCHAR(100) | NN | - |
| MaterialType | NVARCHAR(7) | NN | - |
| Status | NVARCHAR(9) | NN | 'Draft' |
| TextContent | NVARCHAR(MAX) | N | - |
| FilePath | NVARCHAR(500) | N | - |
| YouTubeURL | NVARCHAR(500) | N | - |
| AltText | NVARCHAR(150) | N | - |
| IsPreview | BIT | NN | 0 |
| SortOrder | INT | NN | - |

## Table: MaterialCompletion

Primary key: (LearnerID, MaterialID).

| Column | SQL type | Null | Default |
| --- | --- | --- | --- |
| LearnerID | INT | NN | - |
| MaterialID | INT | NN | - |
| CompletedDate | DATETIME2(0) | NN | SYSUTCDATETIME() |

## Table: Enrolment

Primary key: (LearnerID, CourseID).

| Column | SQL type | Null | Default |
| --- | --- | --- | --- |
| LearnerID | INT | NN | - |
| CourseID | INT | NN | - |
| EnrolDate | DATETIME2(0) | NN | SYSUTCDATETIME() |

## Table: Activity

Primary key: (ActivityID).

| Column | SQL type | Null | Default |
| --- | --- | --- | --- |
| ActivityID | INT IDENTITY(1,1) | NN | identity |
| TopicID | INT | NN | - |
| ActivityType | NVARCHAR(14) | NN | - |
| Title | NVARCHAR(100) | NN | - |
| Description | NVARCHAR(1000) | N | - |
| Status | NVARCHAR(9) | NN | 'Draft' |
| SortOrder | INT | NN | - |
| CreatedDate | DATETIME2(0) | NN | SYSUTCDATETIME() |
| TimeLimitMinutes | INT | N | - |
| MaxAttempts | INT | N | - |
| GameTemplate | NVARCHAR(8) | N | - |
| IsClosed | BIT | N | - |
| StartStepID | INT | N | - |

## Table: QuizQuestion

Primary key: (QuestionID).

| Column | SQL type | Null | Default |
| --- | --- | --- | --- |
| QuestionID | INT IDENTITY(1,1) | NN | identity |
| ActivityID | INT | NN | - |
| QuestionText | NVARCHAR(500) | NN | - |
| Marks | INT | NN | - |
| SortOrder | INT | NN | - |

## Table: QuizOption

Primary key: (OptionID).

| Column | SQL type | Null | Default |
| --- | --- | --- | --- |
| OptionID | INT IDENTITY(1,1) | NN | identity |
| QuestionID | INT | NN | - |
| OptionText | NVARCHAR(200) | NN | - |
| IsCorrect | BIT | NN | 0 |

## Table: SAStatement

Primary key: (StatementID).

| Column | SQL type | Null | Default |
| --- | --- | --- | --- |
| StatementID | INT IDENTITY(1,1) | NN | identity |
| ActivityID | INT | NN | - |
| StatementText | NVARCHAR(200) | NN | - |
| SortOrder | INT | NN | - |

## Table: DiscussionPost

Primary key: (PostID).

| Column | SQL type | Null | Default |
| --- | --- | --- | --- |
| PostID | INT IDENTITY(1,1) | NN | identity |
| ActivityID | INT | NN | - |
| UserID | INT | NN | - |
| ParentPostID | INT | N | - |
| Content | NVARCHAR(2000) | NN | - |
| PostedDate | DATETIME2(0) | NN | SYSUTCDATETIME() |
| EditedDate | DATETIME2(0) | N | - |

## Table: GameGroup

Primary key: (GroupID).

| Column | SQL type | Null | Default |
| --- | --- | --- | --- |
| GroupID | INT IDENTITY(1,1) | NN | identity |
| ActivityID | INT | NN | - |
| GroupName | NVARCHAR(50) | NN | - |

## Table: GameItem

Primary key: (ItemID).

| Column | SQL type | Null | Default |
| --- | --- | --- | --- |
| ItemID | INT IDENTITY(1,1) | NN | identity |
| ActivityID | INT | NN | - |
| GroupID | INT | N | - |
| ItemText | NVARCHAR(100) | NN | - |
| MatchText | NVARCHAR(200) | N | - |

## Table: SimStep

Primary key: (StepID).

| Column | SQL type | Null | Default |
| --- | --- | --- | --- |
| StepID | INT IDENTITY(1,1) | NN | identity |
| ActivityID | INT | NN | - |
| StepText | NVARCHAR(1000) | NN | - |
| ImagePath | NVARCHAR(500) | N | - |
| ImageAlt | NVARCHAR(150) | N | - |
| IsEnding | BIT | NN | 0 |
| Outcome | NVARCHAR(10) | N | - |
| Feedback | NVARCHAR(500) | N | - |

## Table: SimChoice

Primary key: (ChoiceID).

| Column | SQL type | Null | Default |
| --- | --- | --- | --- |
| ChoiceID | INT IDENTITY(1,1) | NN | identity |
| FromStepID | INT | NN | - |
| NextStepID | INT | NN | - |
| ChoiceText | NVARCHAR(150) | NN | - |

## Table: Attempt

Primary key: (AttemptID).

| Column | SQL type | Null | Default |
| --- | --- | --- | --- |
| AttemptID | INT IDENTITY(1,1) | NN | identity |
| ActivityID | INT | NN | - |
| LearnerID | INT | NN | - |
| EndingStepID | INT | N | - |
| SubmittedAt | DATETIME2(0) | NN | SYSUTCDATETIME() |
| ScorePercent | DECIMAL(5,2) | N | - |
| TimeTakenSeconds | INT | N | - |

## Table: QuizAnswer

Primary key: (AttemptID, QuestionID).

| Column | SQL type | Null | Default |
| --- | --- | --- | --- |
| AttemptID | INT | NN | - |
| QuestionID | INT | NN | - |
| SelectedOptionID | INT | N | - |

## Table: SAResponse

Primary key: (AttemptID, StatementID).

| Column | SQL type | Null | Default |
| --- | --- | --- | --- |
| AttemptID | INT | NN | - |
| StatementID | INT | NN | - |
| Rating | INT | NN | - |

## Table: Review

Primary key: (ReviewID).

| Column | SQL type | Null | Default |
| --- | --- | --- | --- |
| ReviewID | INT IDENTITY(1,1) | NN | identity |
| CourseID | INT | NN | - |
| LearnerID | INT | NN | - |
| Rating | INT | NN | - |
| Comment | NVARCHAR(1000) | NN | - |
| PostedDate | DATETIME2(0) | NN | SYSUTCDATETIME() |
| EditedDate | DATETIME2(0) | N | - |

## Table: ContactMessage

Primary key: (MessageID).

| Column | SQL type | Null | Default |
| --- | --- | --- | --- |
| MessageID | INT IDENTITY(1,1) | NN | identity |
| UserID | INT | N | - |
| SenderName | NVARCHAR(100) | NN | - |
| SenderEmail | NVARCHAR(100) | NN | - |
| Subject | NVARCHAR(100) | NN | - |
| Message | NVARCHAR(2000) | NN | - |
| SentDate | DATETIME2(0) | NN | SYSUTCDATETIME() |
| IsRead | BIT | NN | 0 |

## Table: Bookmark

Primary key: (LearnerID, MaterialID).

| Column | SQL type | Null | Default |
| --- | --- | --- | --- |
| LearnerID | INT | NN | - |
| MaterialID | INT | NN | - |
| CreatedDate | DATETIME2(0) | NN | SYSUTCDATETIME() |

## Table: FAQ

Primary key: (FAQID).

| Column | SQL type | Null | Default |
| --- | --- | --- | --- |
| FAQID | INT IDENTITY(1,1) | NN | identity |
| Question | NVARCHAR(200) | NN | - |
| Answer | NVARCHAR(2000) | NN | - |
| Audience | NVARCHAR(7) | NN | - |
| SortOrder | INT | NN | - |

## CHECK, unique and cross-row rules

These are constraint predicates described in plain language; fixed-enum checks and explicitly approved decisions are confirmed, while other unapproved predicates remain proposals; `length` means LEN(column). A nullable bound always means `column IS NULL OR bound`; required conditional fields explicitly check IS NOT NULL so SQL UNKNOWN cannot bypass them. NVARCHAR lengths enforce maxima too. No trigger or extra table is introduced.

| Table | UNIQUE rules beyond PK | CHECK rules |
| --- | --- | --- |
| User | Email (case-insensitive) | FullName length 2–100; Role IN ('Learner','Teacher','Admin'); Status IN ('Active','Pending','Rejected','Deactivated'); ApplicationReason NULL or length 20–500; FailedLoginCount >=0 |
| Subject | SubjectName (case-insensitive) | SubjectName length 2–50 |
| Course | None | Title length 5–100; Description length 20–1000; Status IN ('Draft','Published') |
| Topic | None | Title length 3–100; SortOrder BETWEEN 1 AND 100 |
| Material | None | Status IN ('Draft','Published'); Title length 3–100; MaterialType IN ('Text','Image','PDF','Video','Audio','YouTube'); TextContent NULL or length 20–10000; AltText NULL or length 5–150; Text requires non-NULL TextContent; Image/PDF/Video/Audio requires nonempty FilePath; YouTube requires nonempty YouTubeURL; Image requires non-NULL AltText |
| MaterialCompletion | None | None |
| Enrolment | None | None |
| Activity | None | ActivityType IN ('Quiz','SelfAssessment','Discussion','Game','Scenario'); Status IN ('Draft','Published'); Title length 3–100, and at least 5 for Discussion; Description NULL or length <=1000; Discussion/Scenario require non-NULL Description length 10–1000; Quiz requires non-NULL TimeLimitMinutes 0–180 and MaxAttempts 0–10, both NULL otherwise; Game requires non-NULL GameTemplate IN ('Matching','Memory','Scramble','Sort'), NULL otherwise; Discussion requires non-NULL IsClosed, NULL otherwise; StartStepID must be NULL unless Scenario |
| QuizQuestion | None | QuestionText length 5–500; Marks BETWEEN 1 AND 10 |
| QuizOption | (QuestionID, OptionText), proposed rule using approved case-insensitive collation | OptionText length 1–200 |
| SAStatement | None | StatementText length 5–200 |
| DiscussionPost | None | Content length 2–2000; ParentPostID NULL or <> PostID |
| GameGroup | Unspecified; Q10 | GroupName length 1–50 |
| GameItem | Duplicate definition unresolved Q10; no invented index | ItemText length 1–100; MatchText NULL or length 1–200 |
| SimStep | None | StepText length 10–1000; ImageAlt NULL or length 5–150; ImagePath NULL or (nonempty AND ImageAlt non-NULL); Outcome NULL or IN ('Best','Acceptable','Poor'); Feedback NULL or length 10–500; IsEnding=0 OR (Outcome non-NULL AND Feedback non-NULL) |
| SimChoice | None | ChoiceText length 2–150; FromStepID <> NextStepID |
| Attempt | None; retries allowed | ScorePercent NULL or BETWEEN 0 AND 100; TimeTakenSeconds NULL or >=0 |
| QuizAnswer | None | None |
| SAResponse | None | Rating BETWEEN 1 AND 5 |
| Review | (LearnerID, CourseID) | Rating BETWEEN 1 AND 5; Comment length 10–1000 |
| ContactMessage | None | SenderName length 2–100; Subject length 3–100; Message length 10–2000 |
| Bookmark | None | None |
| FAQ | None | Question length 5–200; Answer length 10–2000; Audience IN ('All','Learner','Teacher'); SortOrder BETWEEN 1 AND 100 |

Server validation (not possible in ordinary cross-row SQL CHECKs): email format/unique comparison; FullName allowed characters; password length 8–50 with letter and number; teacher application reason required at registration; TeacherID must identify a teacher and LearnerID a learner. ApplicationReason is required only for a visitor applying as Teacher; admin-created teachers do not require it. Admin-created teachers are Active unless explicitly created Deactivated. Pending and Rejected are teacher-application states. TeacherApplications handles approval/rejection; Admin/UserEdit manages Active/Deactivated and must not bypass the application workflow for Pending/Rejected accounts (Q04). The optional lock uses LockedUntil, not a fifth Status value.

Quiz: 2–6 distinct options and exactly one correct per question; every answer question belongs to the attempt activity and selected option belongs to that question. Proposed unanswered representation is one QuizAnswer row with NULL SelectedOptionID. SA: all statements rated once and belong to the attempt activity. Discussion: parent must be a top-level post in the same activity, only one reply level; authorship/enrolment/owner/closed checks apply.

Activity children must match the activity type. Sort groups must belong to the same activity as their items. Approved game seed mapping (Q10, 2026-09-28): Matching/Memory ItemText = first side of the pair, MatchText = matching second side, GroupID = NULL. Scramble ItemText = correct word (letters only, 3–15 characters), MatchText = hint, GroupID = NULL. Sort ItemText = item being classified, GroupID = correct GameGroup, MatchText = NULL. Template becomes fixed once items exist. This approval resolves only the seed storage mapping; scoring/formulas, runtime handling, duplicate semantics and the other unanswered Q10 details remain open. Scenario start steps and choices must belong to the same Activity, enforced in server-side C# (Q06); attempt endings must belong to the same scenario and actually be endings. No attempt for Discussion. Attempt field population is approved in Q07: Quiz and Game require ScorePercent and TimeTakenSeconds, with EndingStepID NULL; SelfAssessment requires all three NULL; Scenario requires EndingStepID, ScorePercent NULL and TimeTakenSeconds NULL unless explicitly required later. ScorePercent remains DECIMAL(5,2). Self-assessment confidence is never converted to a percentage score. Cross-table activity-type rules are enforced in C#; existing column-level range checks remain. Score formulas, rounding and feedback rules not answered by Q07 remain open in Q08–Q11.

Material.Status is NVARCHAR(9) NOT NULL DEFAULT 'Draft', with allowed values Draft and Published (Q01). Only Published materials count toward learner progress and normal learner access; course visibility and enrolment checks still apply. Public free preview requires IsPreview=1, Material.Status=Published and Course.Status=Published. Owner teachers/admin may preview draft materials through authorized preview mode. Store only generated file paths, without original-filename database columns unless an existing functional requirement actually needs them (Q02); none are added by this update. Activity.Description uses NVARCHAR(1000) for discussion prompt, scenario introduction and optional Quiz/SelfAssessment/Game description. Discussion/Scenario require the existing 10–1000-character validation; Quiz/SelfAssessment/Game descriptions may be NULL (Q05). SortOrder has no invented CHECK outside Topic/FAQ (Q15). FailedLoginCount/LockedUntil belong to O2, MustChangePassword to O3, Review to O5, ContactMessage to O6, Bookmark to O7, FAQ management to O9.

## Foreign keys and deletion

Every FK below has ON UPDATE NO ACTION. No other cascades, SET NULL or SET DEFAULT actions exist. Explicit non-cascade exceptions in AGENTS.md rule 10 govern scenario steps/choices and discussion posts despite broad content-chain wording.

| Child column | Referenced column | ON DELETE |
| --- | --- | --- |
| Course.TeacherID | User.UserID | NO ACTION |
| Course.SubjectID | Subject.SubjectID | NO ACTION |
| Topic.CourseID | Course.CourseID | CASCADE |
| Material.TopicID | Topic.TopicID | CASCADE |
| MaterialCompletion.LearnerID | User.UserID | NO ACTION |
| MaterialCompletion.MaterialID | Material.MaterialID | NO ACTION |
| Enrolment.LearnerID | User.UserID | NO ACTION |
| Enrolment.CourseID | Course.CourseID | NO ACTION |
| Activity.TopicID | Topic.TopicID | CASCADE |
| Activity.StartStepID | SimStep.StepID | NO ACTION; approved nullable FK (Q06) |
| QuizQuestion.ActivityID | Activity.ActivityID | CASCADE |
| QuizOption.QuestionID | QuizQuestion.QuestionID | CASCADE |
| SAStatement.ActivityID | Activity.ActivityID | CASCADE |
| DiscussionPost.ActivityID | Activity.ActivityID | NO ACTION |
| DiscussionPost.UserID | User.UserID | NO ACTION |
| DiscussionPost.ParentPostID | DiscussionPost.PostID | NO ACTION |
| GameGroup.ActivityID | Activity.ActivityID | CASCADE |
| GameItem.ActivityID | Activity.ActivityID | CASCADE |
| GameItem.GroupID | GameGroup.GroupID | NO ACTION |
| SimStep.ActivityID | Activity.ActivityID | NO ACTION |
| SimChoice.FromStepID | SimStep.StepID | NO ACTION |
| SimChoice.NextStepID | SimStep.StepID | NO ACTION |
| Attempt.ActivityID | Activity.ActivityID | NO ACTION |
| Attempt.LearnerID | User.UserID | NO ACTION |
| Attempt.EndingStepID | SimStep.StepID | NO ACTION |
| QuizAnswer.AttemptID | Attempt.AttemptID | NO ACTION |
| QuizAnswer.QuestionID | QuizQuestion.QuestionID | NO ACTION |
| QuizAnswer.SelectedOptionID | QuizOption.OptionID | NO ACTION |
| SAResponse.AttemptID | Attempt.AttemptID | NO ACTION |
| SAResponse.StatementID | SAStatement.StatementID | NO ACTION |
| Review.CourseID | Course.CourseID | NO ACTION |
| Review.LearnerID | User.UserID | NO ACTION |
| ContactMessage.UserID | User.UserID | NO ACTION |
| Bookmark.LearnerID | User.UserID | NO ACTION |
| Bookmark.MaterialID | Material.MaterialID | NO ACTION |

GameItem.GroupID must not introduce a second cascade route from Activity through GameGroup. Standalone group deletion must explicitly handle items (Q10). Scenario steps and choices are explicitly deleted in C# per rule 10.

Delete gate: block subject used by course; teacher owning courses; admin account actions; scenario step with incoming choices; current start step until another start step is selected; any course/topic/activity with attempts. Offer Unpublish for attempted content. Activity questions/options/statements/items/groups/steps/choices are locked after any attempt; title/description remain editable.

All non-cascade deletes run children first in one SqlTransaction. For course/topic/activity deletion, first recheck attempts, collect validated upload paths, remove applicable completions/bookmarks/enrolments/reviews, discussion replies then posts, then handle the remaining content and parent. Approved Q29 (2026-09-29): whole Scenario/Topic/Course deletion may clear Activity.StartStepID after confirming there are no blocking attempts, then delete SimChoice, SimStep, Activity and parent rows. This is a narrow exception: standalone current-start-step deletion remains blocked until another start step is selected (Q06).

For user deletion remove QuizAnswer and SAResponse before Attempt and other dependent rows before User. Approved Q29: delete all replies to the user's top-level posts, including other authors' replies, before deleting the user's posts, inside the same transaction. Retain ContactMessage and all sender/history fields; set its UserID NULL in that transaction. Recheck authorization and child relationships within mutations.

Approved Q29 file policy: collect validated upload paths before database deletion, commit SQL first, then attempt physical file deletion. Do not roll back committed records when cleanup fails. Report that records were deleted but files need manual cleanup; log failed validated paths to App_Data/FileCleanup.log, without adding a database table. Only paths validated within the application's upload directories may enter that log. Replacement behavior outside deletion remains for its owning phase.

## Shared helper contracts (P)

PROJECT_TYPE = WEB APPLICATION is confirmed (Q17). The existing .csproj is an ASP.NET Web Application (.NET Framework); shared classes go in Helpers/. The primary audience remains pre-university/foundation students unless the team later decides otherwise. All methods below are public static, synchronous, plain C#, without repositories, DI or generic base classes. SqlConnection/SqlTransaction/SqlParameter are System.Data.SqlClient; DataTable is System.Data; HttpPostedFile/HttpContext are System.Web. Callers encode text at output and dispose caller-owned connections/transactions.

| Class | Public signature | Purpose |
| --- | --- | --- |
| DatabaseHelper | SqlConnection OpenConnection() | Open LearningSystemDb; caller disposes. |
| DatabaseHelper | DataTable ExecuteTable(string sql, SqlParameter[] parameters) | Return detached rows and dispose internal resources. |
| DatabaseHelper | object ExecuteScalar(string sql, SqlParameter[] parameters) | Read one value; caller handles DBNull. |
| DatabaseHelper | int ExecuteNonQuery(string sql, SqlParameter[] parameters) | Perform one parameterized write and return affected rows. |
| DatabaseHelper | DataTable ExecuteTable(SqlConnection connection, SqlTransaction transaction, string sql, SqlParameter[] parameters) | Read rows in caller-owned transaction. |
| DatabaseHelper | object ExecuteScalar(SqlConnection connection, SqlTransaction transaction, string sql, SqlParameter[] parameters) | Read scalar in caller-owned transaction. |
| DatabaseHelper | int ExecuteNonQuery(SqlConnection connection, SqlTransaction transaction, string sql, SqlParameter[] parameters) | Write in caller-owned transaction without committing it. |
| CurrentUserHelper | int? GetUserID() | Authenticated identity ID or null. |
| CurrentUserHelper | string GetRole() | Authenticated role or empty string. |
| CurrentUserHelper | string GetFullName() | Current display name, encoded by renderer. |
| CurrentUserHelper | bool IsAuthenticated() | Check valid authenticated identity. |
| CurrentUserHelper | bool IsActive() | Re-read database status on protected requests. |
| CurrentUserHelper | string GetDashboardUrl() | Resolve role dashboard or Home. |
| AuthenticationHelper | void SignIn(int userID) | Read role from database, populate fixed session keys and issue Forms ticket. |
| AuthenticationHelper | void SignOut() | End Forms cookie and session. |
| AuthenticationHelper | void AttachRole(HttpContext context) | Attach ticket role to request principal in Global.asax (SYS-20). |
| PasswordHelper | string HashPassword(string password) | Generate prescribed salted PBKDF2 string. |
| PasswordHelper | bool VerifyPassword(string password, string storedHash) | Parse and verify prescribed hash encoding. |
| AccessHelper | bool IsOwnerOfCourse(int userID, int courseID) | Check teacher owns course. |
| AccessHelper | bool IsOwnerOfTopic(int userID, int topicID) | Resolve topic to owned course. |
| AccessHelper | bool IsOwnerOfMaterial(int userID, int materialID) | Resolve material to owned course. |
| AccessHelper | bool IsOwnerOfActivity(int userID, int activityID) | Resolve activity to owned course. |
| AccessHelper | bool IsEnrolled(int learnerID, int courseID) | Check current learner enrolment. |
| AccessHelper | bool CanPreview(int userID, int activityID) | Authorize owner teacher/admin including drafts. |
| AccessHelper | bool CanPreviewMaterial(int userID, int materialID) | Authorize owner teacher/admin material preview. |
| AccessHelper | bool CanViewFreePreview(int materialID) | Require IsPreview=1 and both material and course Published (Q01). |
| AccessHelper | bool CanAccessActivity(int userID, int activityID, bool preview) | Check role, enrolment, visibility and explicit authorized preview. |
| AccessHelper | bool CanAccessMaterial(int userID, int materialID, bool preview) | Require Published material/course and learner enrolment, or authorized owner/admin preview including drafts. |
| AccessHelper | bool CanViewAttempt(int userID, int attemptID) | Allow own learner result, owning teacher or admin. |
| AccessHelper | bool CanWriteDiscussion(int userID, int activityID) | Require enrolled learner/owner teacher and open thread. |
| AccessHelper | bool CanEditPost(int userID, int postID) | Check author and discussion policy (Q14). |
| AccessHelper | bool CanDeletePost(int userID, int postID) | Check author, owning teacher or admin under Q14. |
| AccessHelper | void RequireRole(string[] allowedRoles) | Require authenticated active account and listed role. |
| MessageHelper | void SetSuccess(string message) | Queue success text for shared message area after redirect. |
| MessageHelper | void SetError(string message) | Queue error text for shared message area. |
| MessageHelper | PageMessage TakeMessage() | Consume next-page message once; null if none. |
| UploadHelper | ValidationResult Validate(HttpPostedFile file, string materialType, bool isCourseCover) | Check binary size limits; accept .jpg/.jpeg/.png and retain .gif only where previously allowed (not covers). |
| UploadHelper | string Save(HttpPostedFile file, string materialType, bool isCourseCover) | Revalidate, save GUID name in approved folder, return app-relative path. |
| UploadHelper | void Delete(string appRelativePath) | Delete only validated file paths within upload roots. |
| ProgressHelper | decimal CalculatePercent(int learnerID, int courseID) | Count only Published materials and published activities; remaining progress details are Q13. |
| BreadcrumbHelper | BreadcrumbItem[] ForCourse(int courseID) | Build authorized course trail with database title. |
| BreadcrumbHelper | BreadcrumbItem[] ForMaterial(int materialID) | Add topic and material labels. |
| BreadcrumbHelper | BreadcrumbItem[] ForActivity(int activityID) | Add topic and activity labels. |
| BreadcrumbHelper | BreadcrumbItem[] ForAttempt(int attemptID) | Resolve activity trail and result. |
| BreadcrumbHelper | void Render(System.Web.UI.WebControls.PlaceHolder target, BreadcrumbItem[] items) | Render encoded text and validated local links; current page unlinked. |
| PublishHelper | ValidationResult CheckCourse(int courseID) | Require a topic containing a Published material or Published activity (Q01). |
| PublishHelper | ValidationResult CheckActivity(int activityID) | Dispatch appropriate type checks. |
| PublishHelper | ValidationResult CheckQuiz(int activityID) | Require >=1 valid question, 2–6 distinct options and exactly 1 correct. |
| PublishHelper | ValidationResult CheckSelfAssessment(int activityID) | Require >=1 valid statement. |
| PublishHelper | ValidationResult CheckDiscussion(int activityID) | Validate title/prompt; publication workflow Q14. |
| PublishHelper | ValidationResult CheckGame(int activityID) | Matching >=4 pairs; Memory 4–12 pairs; Scramble >=3 words; Sort 2–4 groups with >=2 items each. |
| PublishHelper | ValidationResult CheckScenario(int activityID) | Valid start, >=1 ending, every non-ending has a choice, all destinations valid. |
| ContentLockHelper | bool HasAttempts(int activityID) | Check any learner attempt. |
| ContentLockHelper | ValidationResult CheckCanChangeContent(int activityID) | Block questions/options/statements/items/groups/steps/choices after attempts. |
| ContentLockHelper | ValidationResult CheckCanChangeSettings(int activityID) | Apply approved settings lock; title/description editable (Q08). |
| DeleteHelper | ValidationResult CheckSubject(int subjectID) | Block subject referenced by a course. |
| DeleteHelper | ValidationResult CheckUser(int userID) | Block admins and teachers with courses. |
| DeleteHelper | ValidationResult CheckCourse(int courseID) | Block attempts anywhere in course. |
| DeleteHelper | ValidationResult CheckTopic(int topicID) | Block attempts anywhere in topic. |
| DeleteHelper | ValidationResult CheckActivity(int activityID) | Block activity attempts. |
| DeleteHelper | ValidationResult CheckStep(int stepID) | Block content lock, incoming choices and current start step until another start is selected (Q06). |
| DeleteHelper | ValidationResult DeleteUser(int userID) | Authorize, recheck blocks and delete dependents transactionally. |
| DeleteHelper | ValidationResult DeleteCourse(int courseID) | Authorize, recheck attempts, remove non-cascade children and parent/files. |
| DeleteHelper | ValidationResult DeleteTopic(int topicID) | Apply same procedure to topic subtree. |
| DeleteHelper | ValidationResult DeleteActivity(int activityID) | Apply same procedure to activity subtree. |
| DeleteHelper | ValidationResult DeleteMaterial(int materialID) | Remove bookmarks/completions, material and file. |
| DeleteHelper | ValidationResult DeletePost(int postID) | Authorize and remove replies then post transactionally. |
| DeleteHelper | ValidationResult DeleteStep(int stepID) | Recheck step blocks; remove permitted children and image. |
| QuizHelper | DateTime Start(int activityID) | Set QuizStart_{ActivityID}; insert no Attempt. |
| QuizHelper | int Submit(int activityID, QuizSubmissionAnswer[] answers) | Check time/limits/IDs, mark and save transactionally; return AttemptID. |
| SelfAssessmentHelper | decimal CalculateAverage(int[] ratings) | Validate all ratings 1–5 and compute average. |
| SelfAssessmentHelper | string GetFeedback(decimal average) | Return fixed feedback from the unrounded average; Q09 resolved in the Phase 7 approval below. |
| GameHelper | GameResult ParseResult(string json) | Deserialize hfResult with JavaScriptSerializer and validate structure. |
| GameHelper | decimal CalculateScore(int activityID, GameResult result) | Recheck answers and compute approved formula (Q10). |
| SubmissionHelper | string CreateToken(int activityID) | Proposed session token for duplicate prevention (Q12). |
| SubmissionHelper | bool ConsumeToken(int activityID, string token) | Proposed one-use token validation; concurrency policy Q12. |

Supporting plain public property records (P): ValidationResult { bool IsValid; string Message; }; PageMessage { bool IsError; string Text; }; BreadcrumbItem { string Text; string Url; } with null Url for current page; QuizSubmissionAnswer { int QuestionID; int? SelectedOptionID; }. GameResult/GameAnswer properties are defined with JSON below. No additional public DTO methods. Names of message/token session keys need Q21.

SQL helper sql arguments come only from trusted fixed queries, never browser input; all values are SqlParameters, sort columns whitelisted. Access helpers use authoritative joins and authenticated identity; posted child IDs must belong to the authorized parent. Mutation helpers recheck authorization/locks in their transactions.

Preview has a banner and Exit preview, ignores attempt limits and writes nothing (no attempts, answers, ratings, posts, completions or bookmarks). Discussion moderation is a separate authorized action. Rule 2 routes ownership/enrolment failures to ~/AccessDenied.aspx; learners requesting drafts/unpublished content go to ~/NotFound.aspx. Blueprint enrolment redirect conflict is Q22.

Progress = distinct done published items / all published items *100. Material is done with a completion; quiz/SA/game/scenario with >=1 submitted attempt; discussion with >=1 post. Never count multiple attempts/posts as multiple items; never store percent. Only Material.Status=Published materials enter either count (Q01). Zero denominator, rounding and reply/deleted-post behavior remain Q13.

## Page URLs and query parameters (P)

Routes are from Sections 5 and 14.2; query names are proposed because the blueprint supplies only generic ?id=. All IDs are positive integers and checked on every request. `?` after a parameter name below means optional, not part of the name. Dash means no application parameters. Unlisted search/paging/form selection stays in postback controls. Deletes, publish, leave and moderation use confirmed postbacks, never query action links.

| URL | Parameters | Contract |
| --- | --- | --- |
| ~/Default.aspx | — | Home |
| ~/About.aspx | — | About |
| ~/Courses.aspx | subjectId?, q? | SubjectID filter; keyword <=50 characters |
| ~/CourseDetails.aspx | id | CourseID; visibility check |
| ~/Preview.aspx | id | MaterialID; eligible public preview only |
| ~/Help.aspx | — | Seeded FAQ; optional management later |
| ~/Contact.aspx | — | O6 |
| ~/SiteMap.aspx | — | O4 |
| ~/AccessDenied.aspx | — | Safe landing |
| ~/NotFound.aspx | — | Safe landing |
| ~/Error.aspx | — | Safe landing; never render exception details from a query |
| ~/Account/Register.aspx | — | Visitor only |
| ~/Account/Login.aspx | ReturnUrl? | Validated local permitted URL only |
| ~/Account/Logout.aspx | — | Clear authentication/session |
| ~/Member/Profile.aspx | — | Current user |
| ~/Member/ChangePassword.aspx | ReturnUrl? | Validated local permitted destination |
| ~/Member/Discussion.aspx | id, preview? | ActivityID; preview=1 prevents writes |
| ~/Member/Lesson.aspx | id, preview? | MaterialID; preview=1 requires owner/admin |
| ~/Member/Quiz.aspx | id, preview? | ActivityID; intro/play in server state |
| ~/Member/QuizResult.aspx | id | AttemptID, authorized saved result |
| ~/Member/SelfAssessment.aspx | id, preview?, attemptId? | ActivityID; optional saved AttemptID after PRG |
| ~/Member/PlayGame.aspx | id, preview?, attemptId? | ActivityID; optional saved AttemptID after PRG |
| ~/Member/Scenario.aspx | id, preview?, attemptId? | ActivityID; optional saved ending AttemptID after PRG |
| ~/Learner/Dashboard.aspx | — | Learner |
| ~/Learner/MyCourses.aspx | — | Own enrolments |
| ~/Learner/CourseHome.aspx | id | Enrolled CourseID |
| ~/Learner/MyResults.aspx | courseId?, activityId? | Filters within own results |
| ~/Learner/MyBookmarks.aspx | — | O7 |
| ~/Learner/Certificate.aspx | id | CourseID; own 100% progress, O8 |
| ~/Teacher/Dashboard.aspx | — | Teacher |
| ~/Teacher/MyCourses.aspx | — | Owned courses |
| ~/Teacher/CourseEdit.aspx | id? | Absent=create; present=owned CourseID |
| ~/Teacher/CourseBuilder.aspx | id | Owned CourseID |
| ~/Teacher/MaterialEdit.aspx | id OR topicId | Edit MaterialID OR create under owned TopicID; never both |
| ~/Teacher/QuizBuilder.aspx | id OR topicId | Edit Quiz ActivityID OR create under TopicID |
| ~/Teacher/SABuilder.aspx | id OR topicId | Edit SA ActivityID OR create under TopicID |
| ~/Teacher/DiscussionEdit.aspx | id OR topicId | Edit Discussion ActivityID OR create under TopicID |
| ~/Teacher/GameBuilder.aspx | id OR topicId | Edit Game ActivityID OR create under TopicID |
| ~/Teacher/ScenarioBuilder.aspx | id OR topicId | Edit Scenario ActivityID OR create under TopicID |
| ~/Teacher/CourseLearners.aspx | id | Owned CourseID; learner names only |
| ~/Teacher/Results.aspx | courseId?, activityId? | Owned filters; activity must belong to course if both supplied |
| ~/Admin/Dashboard.aspx | — | Admin |
| ~/Admin/Users.aspx | — | Filters/search in controls; admin actions disabled |
| ~/Admin/UserEdit.aspx | id? | Absent=create Learner/Teacher; present=UserID |
| ~/Admin/TeacherApplications.aspx | — | Pending applications |
| ~/Admin/Subjects.aspx | — | CRUD in controls |
| ~/Admin/Courses.aspx | — | Oversight |
| ~/Admin/Activities.aspx | — | Type filter in controls |
| ~/Admin/Messages.aspx | id? | O6; optional MessageID opened from inbox |
| ~/Admin/FAQ.aspx | — | O9; CRUD in controls |

Total: 50 .aspx pages. ~/Site.Master is the one master page, with no query parameters and no navigation URL. No extra editor or result pages are introduced. Child selections use validated postback IDs. attemptId must belong to id's activity and pass CanViewAttempt; disallow combining attemptId with preview. Preview flag alone grants nothing. Preview result rendering and PDF protection need Q23/Q24. No learner IDs are accepted for own-profile/result mutations.

## Fixed values — AGENTS.md section 3 plus approved review decisions

| Item | Exact values |
| --- | --- |
| User.Role | Learner, Teacher, Admin |
| User.Status | Active, Pending, Rejected, Deactivated |
| Course.Status, Activity.Status, Material.Status | Draft, Published; Material.Status defaults to Draft (Q01) |
| Activity.ActivityType | Quiz, SelfAssessment, Discussion, Game, Scenario |
| Activity.GameTemplate | Matching, Memory, Scramble, Sort |
| Material.MaterialType | Text, Image, PDF, Video, Audio, YouTube |
| SimStep.Outcome | Best, Acceptable, Poor |
| FAQ.Audience | All, Learner, Teacher |
| Session keys | UserID, Role, FullName; QuizStart_{ActivityID} |
| Password algorithm | PBKDF2 via Rfc2898DeriveBytes with SHA256; 100,000 iterations; random 16-byte salt; 32-byte hash |
| Password storage | PBKDF2$100000$<base64 salt>$<base64 hash> in User.PasswordHash NVARCHAR(200) |
| Demo password | Password123 for every demo account; generate matching algorithm hashes |
| Image limit | <=2 MB; .jpg/.jpeg/.png accepted; .gif retained for material/scenario images where already allowed; covers .jpg/.jpeg/.png only (Q02) |
| Other limits | PDF <=10 MB; MP4 <=25 MB; MP3 <=10 MB |
| web.config limits | maxRequestLength="30720" (KB); maxAllowedContentLength="31457280" (bytes) |
| Upload folders | ~/Uploads/Images, ~/Uploads/Documents, ~/Uploads/Video, ~/Uploads/Audio |
| Upload filename | New GUID + original extension |
| Connection string name | LearningSystemDb |

Exact connection string:

```text
Data Source=(LocalDB)\MSSQLLocalDB;AttachDbFilename=|DataDirectory|\LearningSystem.mdf;Integrated Security=True
```

Approved Q02: 1 MB = 1024*1024 bytes. Image limit = 2,097,152 bytes; PDF/MP3 limit = 10,485,760 bytes; MP4 limit = 26,214,400 bytes. Uploads/web.config blocks scripts. JSON serialization uses built-in System.Web.Script.Serialization.JavaScriptSerializer. No NuGet or external libraries.

Hidden field: `hfResult`. Exact property names:

```json
{
  "timeTakenSeconds": 83,
  "moves": 14,
  "answers": [ { "itemId": 12, "value": "..." } ]
}
```

- Matching: value = ItemID the learner matched it with.
- Scramble: value = typed word.
- Sort: value = GroupID learner placed item in.
- Memory: answers empty; score from moves and time; moves is Memory-only.
- Server recalculates Matching, Scramble and Sort; never trust a browser score. Game answers may be present in the page, unlike quiz IsCorrect. Matching/Sort use tap-to-select, tap-to-place.
- P DTOs: GameResult { int timeTakenSeconds; int? moves; GameAnswer[] answers; }; GameAnswer { int itemId; string value; }. IDs inside value proposed as decimal strings. Exact numeric/string handling, moves definition, score formulas and normalization are Q10.

## Approval gate

## Phase 3 implementation note — 2026-09-29

Q29 is approved as detailed in Foreign keys and deletion and DECISIONS.md. Implemented the seven core Admin pages using the listed URLs, plus ValidationResult, DeleteHelper.CheckSubject/CheckUser/CheckCourse/CheckActivity/DeleteUser/DeleteCourse/DeleteActivity and UploadHelper.Delete. Internal helpers support transaction-aware checks and validated upload paths without changing the public signatures. Mutation helpers currently authorize active Admin users; teacher-owned mutations and standalone topic/material/post/step operations remain for their owning phases. Upload validation/save/replacement is not implemented early. Existing seed image references are checked before physical cleanup so a shared image still used by surviving content remains available.

ADM-06 resets only PasswordHash with the existing PBKDF2 helper. MustChangePassword/lock/unlock behavior stays dormant until optional Tier A. Pending/Rejected accounts preserve their application status in UserEdit. Admin rows disable every action; SQL predicates and query-ID guards also block forged admin edits, resets, deactivations and deletion. Activities displays a disabled discussion link until Member/Discussion.aspx is implemented in Phase 6.

## Phase 2 implementation note — 2026-09-29

Implemented shared helpers: `DatabaseHelper`, `PasswordHelper`, `CurrentUserHelper`, `AuthenticationHelper`, `AccessHelper.RequireRole`, `MessageHelper` and `BreadcrumbHelper.Render`. These are the helpers fully specified and required by the Phase 2 account, layout and protected-dashboard pages.

Deferred by the approved Q28 scope rule: `UploadHelper` (needed by material/course upload phases), ownership/enrolment and content access methods in `AccessHelper` (needed by ID-based content pages), `ProgressHelper`, `PublishHelper`, `ContentLockHelper`, `DeleteHelper`, `QuizHelper`, `SelfAssessmentHelper`, `GameHelper` and `SubmissionHelper`. Their owning phases or unresolved questions define behavior that Phase 2 neither needs to compile nor should invent. No empty or fake implementations were added.

2026-09-28 Phase 1 update: the team explicitly requested creation and verification of the database script using the listed schema rules. Phase 1 is now authorized. The Q10 game seed mapping above is approved; game scoring/formulas/runtime questions remain open. Earlier statements that Phase 1 was not authorized describe the prior Phase 0 review, not the current task. No later phase or helper/API proposal is approved by this update.

Approved on 2026-09-28: Q01–Q07, Q16 and Q17 as recorded above and in DECISIONS.md. Other proposals and unanswered details remain pending; this update does not approve them or start Phase 1. QUESTIONS.md and PROGRESS.md remain unchanged as requested. Phase 1 has not begun. No application code, build or database execution is part of this update.


## Phase 4 approved Q30 — 2026-09-29

The team approved Q30 with the topic default changed to the next position. Topic.SortOrder remains 1–100; new topics default to the next position. Materials use positive INT SortOrder values and default to the next position within their topic (1 when empty). Ties are allowed. Sort topics by SortOrder, TopicID; materials by SortOrder, MaterialID; read-only activities by SortOrder, ActivityID, after materials. Add no ordering columns or constraints. If the next topic position exceeds 100, the teacher must select a valid 1–100 position; ties remain allowed.

Update Course.LastUpdated in the same successful transaction for course metadata/publication changes, topic writes/reordering, and material writes/reordering/publication/deletion/replacement. Reads, validation failures, failed writes and unsuccessful transactions must not change it.

For material files and course covers, validate/save the new GUID-named file first, then update the database reference transactionally. On SQL failure preserve the old file/reference and remove the new upload. After commit remove the old file only if unreferenced. Cleanup failures retain the committed database state and report/log validated paths using the existing Q29 App_Data/FileCleanup.log policy. No new tables or packages.

## Phase 4 implementation note — 2026-09-29

Implemented the four requested Teacher pages, their designers/project entries, Dashboard navigation, AccessHelper ownership checks, PublishHelper.CheckCourse, UploadHelper.Validate/Save, BreadcrumbHelper.ForCourse/ForMaterial and teacher-authorized DeleteHelper course/topic/material operations. Transaction-aware overloads and internal methods preserve the listed public signatures. SiteMaster accepts a page-supplied breadcrumb trail; later audience-specific trails remain deferred.

The three teacher editors use an internal one-use token held in signed ViewState and the current session (`TeacherEdit_` plus a random GUID, storing the current UserID). It is removed only after a successful commit; ASP.NET's exclusive session request handling serializes simultaneous saves. Replayed/expired forms are rejected with a reload message. This implements duplicate prevention for these editors only; unresolved activity-submission Q12 behavior is unchanged. No schema columns, packages, public helper signatures or activity builders were added.

The four-page request is complete. ENR-06/CourseLearners, learner lesson rendering/downloads, protected media delivery (Q24), material/activity preview viewers and dashboard statistics are not implemented in this phase. This follows the scope documented with Q30; those checklist items are not claimed complete.

## Phase 5 approved Q31 — 2026-09-29

ProgressHelper.CalculatePercent(int learnerID, int courseID) is now authorized for implementation. Count distinct done published materials/activities divided by all published materials/activities. Empty denominator returns 0. Round to two decimals with MidpointRounding.AwayFromZero. A MaterialCompletion completes a material; any submitted Attempt completes Quiz/SelfAssessment/Game/Scenario regardless of outcome/score; any surviving authored DiscussionPost, including replies, completes Discussion. Removing the last contribution removes its completion. Progress is never stored. Certificate rules stay deferred.

Leaving transactionally removes only Enrolment. Preserve attempts, completions, discussion posts/replies, bookmarks and reviews. Re-enrolment restores access and recalculates progress from retained records. Optional functionality remains dormant.

Approved route: ~/Media.ashx accepts materialId OR courseId, never both; optional preview=1 grants nothing by itself and requires active teacher-owner/admin; optional download=1 is allowed only for PDFs after authorization. Database records are the only file-path source. Block direct /Uploads URLs through project configuration. Published covers and published free-preview material files are public. Other materials require both material/course Published and active learner enrolment. Authorized owner/admin preview can read drafts without writes. Visitors can download free-preview PDFs. Return the correct file MIME type. No machine-wide security changes.

Draft About text only from blueprint facts. Missing contact email/address, local introduction video/poster and subject images remain clearly labelled placeholders; affected PUB-01/PUB-10 portions remain partial. Use course title for cover alt and material title for image caption. Six newest published courses use CreatedDate DESC, CourseID DESC; database timestamps display as UTC.

Help uses static FAQ for this phase as explicitly requested, superseding the earlier FAQ-table rendering plan. Material preview remains read-only for owner teachers and admins, with a banner and Exit preview. Activity builders/play/submissions remain deferred. Phase 5 verification is limited to one implementation build (fixing new errors/warnings) and the four requested representative smoke checks if runtime permits; stop on environment blocking. No database rebuild or isolated test copy.

## Phase 6 approved Q32 — 2026-09-30

Q32 approved with the team's amendments. Quiz scores use earned marks / available marks * 100, rounded to two decimals (AwayFromZero); each question gets a QuizAnswer, with NULL selection and zero marks when unanswered. Mark only on the server. Zero minutes means untimed. Reject after limit + 30 seconds, or invalid/missing required run/start state, without saving; allow restart when attempts remain. Store whole elapsed seconds.

One active quiz run per session/ActivityID preserves its original start on repeated Start. Session-only tokens identify runs; completed runs retain AttemptID and repeated submissions return that result without new rows. No cross-session/browser idempotency is promised and no schema column is added. Attempt limits are still checked transactionally. Use QuizStart_{ActivityID}, QuizRun_{ActivityID}, SubmissionToken_{ActivityID} and separate QuizPreview_{ActivityID} session state; bind runs to the current user. Consume a valid submission token only after commit. Failed writes do not consume it.

After attempts, lock quiz questions/options/marks/structural ordering, TimeLimitMinutes, MaxAttempts and topic/type; title/description and publication remain editable. Reject submissions if the structural definition changed after Start. Published structural edits must preserve publication validity or require unpublishing first. Owner/admin preview includes drafts, ignores attempt limits and creates no Attempt/QuizAnswer rows. Transient preview feedback stays on Member/Quiz, not the saved AttemptID result route.

Closed discussions block author post/reply/edit/delete actions. Owner/admin may still remove posts for moderation while closed. Preview never mutates. Draft discussions/course content are owner/admin read-only preview only. Ordinary discussion access/mutations require published course/discussion; enrolled learners and owning teachers may contribute, admin only moderates. Delete replies before a parent, including other authors' replies, in one transaction with explicit confirmation. Explicit Draft/Published settings use valid title/prompt as the publication requirement.

Activity and QuizQuestion SortOrder are positive integers, default next position, ties allowed; order by SortOrder then ActivityID/QuestionID. Quiz options use OptionID order. Add no ordering columns. Update Course.LastUpdated within successful authored-content transactions (quiz/discussion create/edit/settings/publish/unpublish/delete and quiz structure). Attempts, discussion contributions/edits/deletes/moderation, reads, preview and failed writes do not touch it. No Phase 7 functionality is authorized.

## Phase 7 — Q09 resolved, 2026-09-30

The team's Phase 7 instructions resolve Q09. SelfAssessmentHelper.CalculateAverage(int[] ratings) validates a nonempty set of integer ratings 1–5 and returns the unrounded decimal mean. SelfAssessmentHelper.GetFeedback(decimal average) returns the fixed feedback text. Classification uses the unrounded mean: below 2.50 = Needs Improvement; 2.50 to below 4.00 = Developing; 4.00 through 5.00 = Confident. Display averages to exactly two decimal places, using the existing AwayFromZero convention; never classify the rounded display value.

Fixed feedback:
- Needs Improvement: Review this topic and practise the key concepts before moving on.
- Developing: You have some confidence in this topic, but more practice would help strengthen your understanding.
- Confident: You feel confident with this topic. Continue practising to maintain and apply your understanding.

Retries are unlimited. A complete valid submission creates one Attempt plus one SAResponse for every statement, transactionally; ScorePercent, TimeTakenSeconds and EndingStepID remain NULL. No writes occur for incomplete/invalid submissions or preview. Reuse the existing form-token mechanism to reject duplicate POSTs; a fresh form permits a new attempt. Learner history and authorized saved results use Member/SelfAssessment.aspx?id=ActivityID&attemptId=AttemptID. Preview feedback stays on that page using temporary session state bound to the current user; no saved AttemptID. Definition checks reject stale forms whose statements changed while open.

SABuilder shows owner-only per-statement averages across all submitted learner attempts, not only the latest attempt. Member/SelfAssessment shows the learner's own past attempts for comparison. Titles/descriptions and publication stay editable after attempts; statements, topic/type and structural ordering lock. Publication needs at least one valid statement. Apply positive integer ordering with next-position defaults and ties allowed; SAStatement sorts by SortOrder then StatementID. No schema columns/constraints added. Authored changes touch Course.LastUpdated in the same transaction; submissions/preview do not. SA-09/SA-10 are explicitly delivered in Phase 7 by the current request, not deferred to Phase 10.


## Phase 8 — Q33 resolved, 2026-09-30

Approved Memory scoring: pairCount comes from the database's GameItem rows. One move is a completed two-card turn; count when the second card is flipped, matching or not. The first flip alone is not a move. Require a positive integer moves >= pairCount. optimalMoves=pairCount; extraMoves=max(0,moves-pairCount); movePenalty=extraMoves*5; timePenalty=floor(serverElapsedSeconds/10); score=clamp(100-movePenalty-timePenalty,0,100). Store ScorePercent to two decimals. Approved examples for four pairs: (moves,seconds) (4,9)=100, (5,24)=93, (7,36)=82, (20,180)=2.

Store start time in session when play begins. Server-measured whole elapsed seconds are authoritative for scoring and Attempt.TimeTakenSeconds, never submitted timeTakenSeconds. Missing/invalid run state is rejected. Preview calculates identically but inserts nothing. Memory answers stays empty. Its client-reported moves cannot be independently reconstructed from this fixed payload; validate moves as above, without claiming complete card-flip verification or adding columns/JSON fields.

Phase 8 implementation conventions: Matching/Scramble/Sort score is correct items / total database items *100, rounded to two decimals AwayFromZero, with no time bonus. Every database item must appear once; malformed/duplicate/foreign IDs are rejected. Scramble comparisons trim and ignore case. Matching value is the ItemID of the chosen right-side MatchText; Sort value is a GroupID, both decimal strings. Strict JSON has only contracted fields; Memory requires moves and an empty answers array; other templates omit moves. Game time is measured in the server session for every template. Session runs are bound to user/activity/preview and content definition; stale content or expired runs require restart. Completed runs reject duplicate saves by retaining their result. Internal session keys GameRun_{ActivityID} and GamePreview_{ActivityID} hold run tokens/start/feedback. No schema change.

Items/groups display in ID order in the editor; play shuffles cards/choices. Activity ordering uses the approved positive integer convention. Trim content; reject duplicate item text within the game, duplicate pair-side text and duplicate group names case-insensitively. Scramble word is 3–15 ASCII letters with a required hint. Group deletion is blocked while items reference it; empty groups must be removed before changing away from Sort. Published edits must preserve publish validity or require unpublishing first. Structure/template/order locks after attempts; titles/descriptions and publication remain editable. Teacher results are shown only in their owned GameBuilder; learner history/best and authorized result use PlayGame's existing attemptId route. GAM-13/14 are delivered in Phase 8 as explicitly requested. Sounds/mute remain optional O14.

## Phase 9 — Q11 resolved, 2026-09-30

The team's Phase 9 instructions resolve Q11. Ending steps require Outcome Best, Acceptable or Poor and Feedback (10–500 characters), and have no outgoing choices. Non-endings require at least one choice for publication; changing an ending to a non-ending clears Outcome and Feedback. CheckScenario validates a configured start belonging to the same Scenario, at least one valid ending, all non-ending choices, all destination memberships, and no direct self-links. Cycles/loops are allowed. Neither universal reachability nor automatic termination of every path is required.

Step/choice CRUD and start selection require teacher ownership and are locked once any Attempt exists. Activity structural order is also locked; Title, Description and valid publication changes remain available. Standalone step deletion is blocked for incoming choices and for the current StartStep until a different start is selected (Q06); outgoing choices are removed before the step in one transaction. Whole-content deletion retains the existing Q29 exception. Steps sort by StepID, choices by ChoiceID; no ordering columns or schema changes are added. Activity order remains a positive integer with ties and ActivityID tie-breaks.

Learners require enrolment and Published Course/Activity on every request and mutation. Owner/admin preview can read drafts and writes no Attempt or other learner records. A session run is bound to user, ActivityID and preview mode, holds the current StepID, and resolves each submitted ChoiceID against that current step and Scenario. NextStepID is read from the database only. A legitimate reached ending creates one Attempt with EndingStepID, ScorePercent NULL and TimeTakenSeconds NULL. Completed runs cannot save again. Restart returns to StartStepID without an Attempt, and completing the new run can create another Attempt. Successful transitions/results use PRG. Saved learner outcomes use Member/Scenario.aspx?id=ActivityID&attemptId=AttemptID, checking attempt ownership and current content access. Preview outcomes remain transient on the Scenario page.

Implementation conventions: one active session run per scenario/mode (ScenarioRun_{ActivityID} / ScenarioPreview_{ActivityID}), bound to the signed-in user. A run token and rotating step revision reject stale forms, including forms from a previous visit to the same step in a loop. Restart invalidates the earlier run. A structural definition fingerprint rejects runs changed while open. These are session-only, not cross-session idempotency guarantees. If the configured start is itself an ending, an explicit Finish button completes it; Start/Restart alone never inserts an Attempt.

The owner-only ScenarioBuilder summary counts saved learner Attempts grouped by ending StepID/outcome. Authored create/edit/publish/unpublish, step/choice CRUD, start changes and deletions update Course.LastUpdated transactionally. Learner play, outcome saves, preview, reads and rejected writes do not.

Step images use UploadHelper's GUID filenames, server image extension/2 MB checks, required 5–150-character alt text and existing reference-aware replacement/deletion cleanup policy. The authorized page embeds its database-selected image as a data image (outside ViewState); direct Uploads access remains blocked, and Media.ashx's approved query contract is unchanged. Database failures remove a newly saved upload and preserve the old reference; committed replacements remove only unreferenced old files, with validated cleanup failures logged under Q29.

## Phase 10 reporting conventions — 2026-09-30

MyResults and Teacher/Results use the contracted courseId/activityId filters and GridView paging (10 attempts per page, SubmittedAt DESC then AttemptID DESC). Learner filters cover only courses/activities with that learner's saved attempts, including retained/unavailable history. Detailed learner result links require current published/enrolled access. Discussion is not an Attempt result. Teacher filters and all result queries recheck ownership; supplied activity/course pairs must agree.

Results reuse the approved confidence display/classification and per-statement SelfAssessmentHelper.Summary, and ScenarioHelper.Summary for outcome counts. Only Quiz/Game summaries show saved percentage scores (attempt count, best/latest/average by learner and activity). SelfAssessment shows confidence out of 5; Scenario shows the reached ending/outcome. ResultsHelper is internal reporting support, not a new public helper contract or progress formula.

Teacher dashboard learner count means distinct currently enrolled learners across owned courses; course count includes drafts. Both dashboards show the five most recent submitted attempts. CourseLearners projects FullName only. Admin core counts remain users by role (including inactive), courses per subject (including draft), pending teacher applications and submitted attempts. Reporting does not write Course.LastUpdated or any learner/content data. Every course-progress display remains CourseHelper.Progress -> ProgressHelper.CalculatePercent under Q31; the formula is unchanged.

Optional review links (O5) and charts (O1) are explicitly deferred by the Phase 10 request. No optional message inbox/dashboard work is introduced.

## Phase 12 — Q34 approved, 2026-09-30

Use existing User.FailedLoginCount, LockedUntil and MustChangePassword; no schema changes. Login serializes the account row while checking/updating failures. Five failures create a 15-minute UTC lock; while locked report rounded-up remaining minutes without extending it. Expiry starts a fresh failure series; successful active login resets count/lock. Admin accounts have the same temporary expiry, never permanent lockout. Admin/Users unlock resets both fields only for non-admin users; existing admin-row protections remain.

Admin creation and password reset set MustChangePassword=1. Query the database flag on every authenticated application request before page/handler work (not just session). Redirect flagged users to ~/Member/ChangePassword.aspx. Exceptions: that page, ~/Account/Logout.aspx, ~/AccessDenied.aspx, ~/NotFound.aspx, ~/Error.aspx, required local Styles/Scripts/Images assets and WebResource.axd/ScriptResource.axd. Media.ashx is not exempt. Active status and correct current password are required; valid new password must differ; update PasswordHash and MustChangePassword=0 together under the old-hash predicate. Failed validation leaves the flag untouched. Forced-mode Cancel is Log out.

Session["RegisterCaptcha"] stores two operands 1–9 and their sum, never serialized to the browser. Initial/fresh Register GET generates a new challenge. Preserve it on unrelated validation errors. Wrong answer or missing/expired state rejects registration, generates a new question and clears the textbox. Successful registration consumes it. Lifetime is session lifetime; a fresh tab GET replaces the same-session challenge. Contact integration is deferred to Phase 13.

Web.config appSettings HttpsOrigin = https://localhost:44393/ is local-demo-only. HTTP redirect uses this configured origin plus request path/query, never an untrusted Host header. Forms Authentication requireSSL and httpCookies requireSSL secure authentication/session cookies. Use existing IIS Express certificate/binding only; blocked trust/binding means runtime verification limitation, not insecure fallback. Another deployment must explicitly configure its own HTTPS origin.

Internal AccountSecurityHelper/CaptchaHelper/ChartHelper implement these concerns without changing approved public helper signatures. Teacher chart input is the existing ownership-filtered result table; only Quiz/Game ScorePercent values are binned by activity into 0–<20, 20–<40, 40–<60, 60–<80, 80–100. Admin chart input reuses users-by-role/courses-by-subject tables. Plain canvas/local JavaScript plus HTML data alternatives. SiteMap.aspx lists public/account/current-role entry pages; ID-specific pages remain reached through authorized courses. No Phase 13 links/features introduced.

## Phase 13 — Q35 approved, 2026-09-30

Certificate.aspx?id=CourseID uses the logged-in learner only, current enrolment, Published course and ProgressHelper.CalculatePercent(learnerID,courseID)==100m, recalculated on every request. Display Printed on: [current UTC date], explicitly a print date, never a historical completion date. No certificate record/ID/serial/verification code or second progress formula.

Alt+H -> Home; Alt+C -> Courses; Alt+D -> current-role Dashboard, no visitor action; Alt+Q -> Help/FAQ. Ignore input/textarea/select/contenteditable focus, IME/composition, repeated keydown and Ctrl/Meta/Shift. Prevent default only when a recognized authorized destination is handled. Help documents mappings and browser/OS reservations. No activity submission/start/logout shortcuts.

Use ~/Learner/MyBookmarks.aspx only, replacing the earlier Bookmarks.aspx route. Keep material bookmarks and reviews after leaving under Q31; mutations require current publication/enrolment, with admin review moderation exempt from learner restrictions. Unavailable bookmarks remain listed without a live lesson link or mutation button. Never bookmark from preview. Unique Review(LearnerID,CourseID) and Bookmark composite key remain unchanged. Review rating integer 1–5, comment trimmed 10–1000; encoded public display and average (two decimals, no ratings message when empty). Admin moderation lives on existing Admin/Courses; teachers cannot moderate reviews. MyResults links eligible learners to CourseDetails#reviews.

Contact reuses CaptchaHelper with Session["ContactCaptcha"], independent of RegisterCaptcha, following the same Q34 lifecycle. Logged-in contact users are active-account checked and sender fields prefilled but revalidated; visitors store NULL UserID. One-use ContactSend token prevents duplicate message creation within a session. Admin/Messages.aspx?id=MessageID opens a message; explicit Mark as read postback redirects to the opened GET. Inbox/read/delete and unread counts are Admin-only; deletion is transactional. Message name/email/subject/body limits remain 2–100/valid email up to100/3–100/10–2000.

FAQ uses 1–100 SortOrder, ties allowed, deterministic SortOrder then FAQID within audience groups. Visitors get All, learners All+Learner, teachers All+Teacher, admin all. Existing useful static Help guidance remains. Admin CRUD uses the existing FAQ table and contract lengths, server audience whitelist and integer order checks. These interactions do not update Course.LastUpdated. No schema changes; Phase 14 remains deferred.
## Phase 15 — approved custom extension, 2026-09-30

This section extends, rather than rewrites, the original blueprint. See PHASE15-CUSTOM-SCOPE.md. Phase 14/O10/O14 are deferred, Phase 15 Custom Enhancements, Phase 16 Final Audit.

### Schema
Course adds IsPaid BIT NOT NULL DEFAULT 0 and PriceNPR DECIMAL(10,2) NOT NULL DEFAULT 0. CK_Course_Price enforces (IsPaid=0 AND PriceNPR=0) OR (IsPaid=1 AND PriceNPR>0). Existing courses default to free. Price input must fit DECIMAL(10,2), with at most two decimals; authored changes update LastUpdated, never remove enrolments.

Payment: PaymentID INT IDENTITY primary key; LearnerID INT NOT NULL FK User.UserID NO ACTION; CourseID INT NOT NULL FK Course.CourseID NO ACTION; Provider NVARCHAR(20) NOT NULL DEFAULT 'eSewa' CHECK exactly 'eSewa'; TransactionUUID NVARCHAR(64) NOT NULL UNIQUE; ProviderReference NVARCHAR(100) NULL; AmountNPR DECIMAL(10,2) NOT NULL CHECK >0; Status NVARCHAR(20) NOT NULL DEFAULT 'Pending' CHECK Pending/Complete/Failed/Canceled; CreatedDate DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(); VerifiedDate DATETIME2(0) NULL. No other schema additions. Preserve payment history: referenced users/courses cannot be deleted; deactivate/unpublish instead. Focused Phase15PaymentUpgrade.sql adds schema without rebuilding records.

### Routes and shared code
- Account/Login.aspx?ReturnUrl optional: portal selector. Account/StudentLogin.aspx, TeacherLogin.aspx, AdminLogin.aspx accept optional ReturnUrl, enforce Learner/Teacher/Admin respectively after password verification. Correct-password role mismatch does not increment failures. Existing account-status/lock/forced-change behavior remains shared.
- PortalLoginHelper.Login(Page,string email,string password,string role) and ReturnUrl(Page) reuse AccountSecurityHelper.CheckLogin (new role overload), AuthenticationHelper, current identity. Return URLs must be local ASPX paths allowed by folder-role rules; destination ownership checks still apply.
- Learner/Checkout.aspx?courseId=CourseID&paymentId=PaymentID (optional): active learner only; pending payment belongs to current learner and course. POST creates a price snapshot then redirects to the signed request page. No browser price accepted.
- Payment/EsewaSuccess.aspx?data=Base64Response and Payment/EsewaFailure.aspx?transaction_uuid=UUID: active learner only; payment belongs to current identity. Success validates signature, product, UUID, stored amount, COMPLETE and independently verifies provider status. Failure never enrols.
- Learner/MyPayments.aspx: current learner only. Admin/Payments.aspx: Admin-only, status filter, read-only, no manual Complete action.
- PaymentHelper.Enrol(int courseID): validates current active learner and published course; inserts only free or previously verified Complete purchase, using a serializable transaction and existing composite Enrolment key. Returns false if payment is required. Retained Complete purchases permit re-enrolment without paying again.
- PaymentHelper.CreatePending(int courseID), Find(string uuid), Find(int paymentID), Complete(string encodedResponse), CheckFailure(string uuid), History(string status,bool admin), RequestForm(DataRow payment). All ownership-sensitive methods derive learner identity from authentication. Completion validates the provider before a serializable transaction rereads the stored payment and creates the enrolment exactly once. Already Complete is trusted persisted verification, never downgraded. Reporting/payment operations do not touch LastUpdated.
- EsewaHelper.Sign(string message), VerifyResponse(string encoded), Status(DataRow payment), Settings(): built-in HMACSHA256/Base64/JavaScriptSerializer; constant-time signature comparison; exact response signed fields transaction_code,status,total_amount,transaction_uuid,product_code,signed_field_names. Require all mandatory values. Server status must match UUID/product/stored amount; no browser assertion grants access.
- Site.Master adds OutsideFormContent after its server form for the isolated eSewa POST form (no nested forms or Web Forms hidden fields sent to the provider).

### Sandbox configuration and outcomes
AppSettings: EsewaProductCode=EPAYTEST; EsewaSecretKey empty in tracked config; EsewaFormUrl=https://rc-epay.esewa.com.np/api/epay/main/v2/form; EsewaStatusUrl=https://rc.esewa.com.np/api/epay/transaction/status/; existing HttpsOrigin=https://localhost:44393/ supplies callback origin. Optional App_Data/PaymentSettings.config overrides locally and is ignored by Git. Reject non-sandbox endpoints/product and non-HTTPS callback origin. Never log secrets. Status requests have a bounded timeout and no automatic retries/redirects.

Request signature order total_amount,transaction_uuid,product_code. Amount/total use stored snapshot; tax/service/delivery are zero. UUID is GUID N format. Success requires signed COMPLETE plus server COMPLETE. Failure CANCELED maps Canceled, NOT_FOUND/FAILED maps Failed; pending/ambiguous/unavailable stays non-complete. Failure never creates enrolment or downgrades Complete. An already Complete purchase can restore missing enrolment after leaving; publication is rechecked in the ordinary enrolment path. Signed successful payment creates its enrolment atomically; if the course was meanwhile unpublished, existing content access still returns Not Found/unavailable.

## Phase 17 — Inkwell extensions, 2026-10-01

Approved by the team member who requested this phase (see DECISIONS.md). Earlier contracts stay valid except where listed here.

### Schema
- Activity.GameTemplate NVARCHAR(10); CHECK allows Matching, Memory, Scramble, Sort, Flashcards, FillBlank, TrueFalse, Sequence.
- Material.MaterialType CHECK adds Code; CK_Material_6 requires TextContent for Text and Code.
- New table PageView: PageViewID INT IDENTITY PK; PagePath NVARCHAR(200) NOT NULL (1 to 200); ViewerRole NVARCHAR(7) NOT NULL IN ('Visitor','Learner','Teacher','Admin'); ViewedAt DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(); index on ViewedAt. No foreign keys.
- Existing-database upgrade: `Database/Phase17AnalyticsUpgrade.sql` creates the same PageView definition and `IX_PageView_ViewedAt` without rebuilding/reseeding. It is transactional and safe to rerun when the contracted table/index already exist. No additional columns or reporting contracts are introduced.
- Added indexes IX_Payment_LearnerID and IX_Payment_CourseID.

### Game item mapping (new templates)
| Template | ItemText | MatchText | Answer value |
| --- | --- | --- | --- |
| Flashcards | Front (1 to 100) | Back (1 to 200) | known or learning |
| FillBlank | Missing word or phrase | Sentence with exactly one ___ | Typed text (compared ignoring case and repeated spaces) |
| TrueFalse | True or False | Statement | True, False or Skip |
| Sequence | Step | Position 1..n, no gaps | Position chosen by the learner |

Publish rules: Flashcards and TrueFalse at least 4 items; FillBlank and Sequence at least 3; maximum items Memory 12, Sequence 10, FillBlank 15, TrueFalse 20, others 30.

### New and changed shared code
| Class | Member | Purpose |
| --- | --- | --- |
| CurrentUserHelper | AuthorRoles, IsAuthor() | Teacher or Admin may author; ownership is still checked per course. |
| UiHelper | Icon, TypeMark, TypeLabel, RoleLabel, Money, Ago, Plural, SiteName, SiteOrigin, ContactEmail, ContactAddress | Shared presentation and site settings. |
| LessonFormatter | ToHtml(string) | Safe formatting of text lessons after HTML encoding. |
| EngagementHelper | ActiveDays, Streak, WeekStrip, CompletedItems, AverageBestScore, LastCourse | Calculated learner engagement; nothing stored. |
| AnalyticsHelper | RecordView, DailyViews, TopPages, ViewsByRole, TotalViews | First-party page analytics. |
| CourseHelper | Stats, CoverHtml, PriceHtml, RatingHtml, ItemLink, ItemLabel, NextItem | Course cards, outlines and continue learning. |
| GameHelper | Templates, TemplateName, MaxItems, IsBlankSentence, Position | New game templates. |
| RobotsHandler, SitemapHandler | ProcessRequest | /robots.txt and /sitemap.xml (registered in Web.config). |

### New routes
| URL | Parameters | Contract |
| --- | --- | --- |
| ~/Privacy.aspx | none | Public privacy policy |
| ~/Terms.aspx | none | Public terms of use |
| ~/Admin/Analytics.aspx | none (period chosen in a postback list of 7, 14 or 30 days) | Admin only |
| ~/robots.txt, ~/sitemap.xml | none | Generated |
| ~/Courses.aspx | subjectId?, q?, price? (free or paid), sort? (title or popular) | Unknown values fall back to the default |
| ~/Account/Register.aspx | as? (lecturer) | Pre-selects the lecturer application |
| ~/Media.ashx | captions=1 with materialId | Serves the .vtt captions beside an authorised Video material |

### Payment routes (replaces the Phase 15 eSewa sandbox routes)
| URL | Parameters | Contract |
| --- | --- | --- |
| ~/Learner/Checkout.aspx | courseId | Active learner; paid, published course; creates a Pending payment with the current price, then opens the demo screen |
| ~/Payment/EsewaDemo.aspx | paymentId | Payment must belong to the current learner and be Pending; mobile number then 4-digit code, checked on the server; 3 wrong codes set Failed; Cancel sets Canceled |
| ~/Payment/EsewaSuccess.aspx | paymentId | Receipt for the current learner's Complete, verified payment |

PaymentHelper public surface: Price, Enrol, CreatePending, Find(int), IsValidPhone, CodeMatches, MaskPhone, CompleteDemo, CloseDemo, History. EsewaHelper and Payment/EsewaFailure.aspx are removed.
