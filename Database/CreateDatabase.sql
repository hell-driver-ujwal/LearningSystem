-- Inkwell learning platform: destructive local demo rebuild. Run with sqlcmd -b and -v DataPath="...\App_Data".
-- DataPath is a trusted local administrator setting, not web input. See README.md.
:on error exit
USE [master];
GO
SET NOCOUNT ON;
SET XACT_ABORT ON;

DECLARE @DataPath nvarchar(4000) = N'$(DataPath)';
IF RIGHT(@DataPath, 1) NOT IN (N'\', N'/') SET @DataPath += N'\';
DECLARE @Mdf nvarchar(4000) = @DataPath + N'LearningSystem.mdf';
DECLARE @Ldf nvarchar(4000) = @DataPath + N'LearningSystem_log.ldf';
DECLARE @Sql nvarchar(max);
DECLARE @AttachedName sysname;

-- The app may attach the file under its full path rather than LearningSystem.
SELECT @AttachedName = DB_NAME(database_id)
FROM sys.master_files WHERE physical_name = @Mdf AND file_id = 1;
IF @AttachedName IS NOT NULL AND @AttachedName <> N'LearningSystem'
BEGIN
    SET @Sql = N'ALTER DATABASE ' + QUOTENAME(@AttachedName)
        + N' SET SINGLE_USER WITH ROLLBACK IMMEDIATE; DROP DATABASE ' + QUOTENAME(@AttachedName) + N';';
    EXEC sys.sp_executesql @Sql;
END;
IF DB_ID(N'LearningSystem') IS NOT NULL
BEGIN
    ALTER DATABASE [LearningSystem] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE [LearningSystem];
END;

-- A previous successful run detached the files. Attach then drop so SQL Server
-- removes its own database files; no shell deletion or xp_cmdshell is needed.
DECLARE @FileExists int;
EXEC master.dbo.xp_fileexist @Mdf, @FileExists OUTPUT;
IF @FileExists = 1
BEGIN
    SET @Sql = N'CREATE DATABASE [LearningSystem] ON (FILENAME = N'''
        + REPLACE(@Mdf, N'''', N'''''') + N'''), (FILENAME = N'''
        + REPLACE(@Ldf, N'''', N'''''') + N''') FOR ATTACH;';
    EXEC sys.sp_executesql @Sql;
    ALTER DATABASE [LearningSystem] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE [LearningSystem];
END;

SET @Sql = N'CREATE DATABASE [LearningSystem] ON PRIMARY
(NAME = N''LearningSystem'', FILENAME = N''' + REPLACE(@Mdf, N'''', N'''''') + N''')
LOG ON (NAME = N''LearningSystem_log'', FILENAME = N''' + REPLACE(@Ldf, N'''', N'''''') + N''');';
EXEC sys.sp_executesql @Sql;
GO
USE [LearningSystem];
GO
SET NOCOUNT ON;
SET XACT_ABORT ON;
-- Inherit the standard case-insensitive LocalDB collation. Do not silently
-- choose a different collation on a machine configured case-sensitive.
IF CONVERT(int, COLLATIONPROPERTY(CONVERT(sysname, DATABASEPROPERTYEX(DB_NAME(), 'Collation')), 'ComparisonStyle')) & 1 = 0
    THROW 51000, 'A case-insensitive SQL Server collation is required.', 1;
BEGIN TRANSACTION;

CREATE TABLE dbo.[User]
(
    [UserID] INT IDENTITY(1,1) NOT NULL,
    [FullName] NVARCHAR(100) NOT NULL,
    [Email] NVARCHAR(100) NOT NULL,
    [PasswordHash] NVARCHAR(200) NOT NULL,
    [Role] NVARCHAR(7) NOT NULL,
    [Status] NVARCHAR(11) NOT NULL,
    [ApplicationReason] NVARCHAR(500) NULL,
    [CreatedDate] DATETIME2(0) NOT NULL CONSTRAINT [DF_User_CreatedDate] DEFAULT (SYSUTCDATETIME()),
    [FailedLoginCount] INT NOT NULL CONSTRAINT [DF_User_FailedLoginCount] DEFAULT (0),
    [LockedUntil] DATETIME2(0) NULL,
    [MustChangePassword] BIT NOT NULL CONSTRAINT [DF_User_MustChangePassword] DEFAULT (0),
    CONSTRAINT [PK_User] PRIMARY KEY ([UserID]),
    CONSTRAINT [UQ_User_Email] UNIQUE ([Email]),
    CONSTRAINT [CK_User_1] CHECK (LEN(FullName) BETWEEN 2 AND 100),
    CONSTRAINT [CK_User_2] CHECK (Role IN ('Learner','Teacher','Admin')),
    CONSTRAINT [CK_User_3] CHECK (Status IN ('Active','Pending','Rejected','Deactivated')),
    CONSTRAINT [CK_User_4] CHECK (ApplicationReason IS NULL OR LEN(ApplicationReason) BETWEEN 20 AND 500),
    CONSTRAINT [CK_User_5] CHECK (FailedLoginCount >= 0)
);

CREATE TABLE dbo.[Subject]
(
    [SubjectID] INT IDENTITY(1,1) NOT NULL,
    [SubjectName] NVARCHAR(50) NOT NULL,
    [Description] NVARCHAR(300) NULL,
    CONSTRAINT [PK_Subject] PRIMARY KEY ([SubjectID]),
    CONSTRAINT [UQ_Subject_SubjectName] UNIQUE ([SubjectName]),
    CONSTRAINT [CK_Subject_1] CHECK (LEN(SubjectName) BETWEEN 2 AND 50)
);

CREATE TABLE dbo.[Course]
(
    [CourseID] INT IDENTITY(1,1) NOT NULL,
    [TeacherID] INT NOT NULL,
    [SubjectID] INT NOT NULL,
    [Title] NVARCHAR(100) NOT NULL,
    [Description] NVARCHAR(1000) NOT NULL,
    [CoverImagePath] NVARCHAR(500) NULL,
    [Status] NVARCHAR(9) NOT NULL CONSTRAINT [DF_Course_Status] DEFAULT ('Draft'),
    [CreatedDate] DATETIME2(0) NOT NULL CONSTRAINT [DF_Course_CreatedDate] DEFAULT (SYSUTCDATETIME()),
    [LastUpdated] DATETIME2(0) NOT NULL CONSTRAINT [DF_Course_LastUpdated] DEFAULT (SYSUTCDATETIME()),
    IsPaid BIT NOT NULL CONSTRAINT DF_Course_IsPaid DEFAULT (0),
    PriceNPR DECIMAL(10,2) NOT NULL CONSTRAINT DF_Course_PriceNPR DEFAULT (0),
    CONSTRAINT CK_Course_Price CHECK ((IsPaid=0 AND PriceNPR=0) OR (IsPaid=1 AND PriceNPR>0)),
    CONSTRAINT [PK_Course] PRIMARY KEY ([CourseID]),
    CONSTRAINT [CK_Course_1] CHECK (LEN(Title) BETWEEN 5 AND 100),
    CONSTRAINT [CK_Course_2] CHECK (LEN(Description) BETWEEN 20 AND 1000),
    CONSTRAINT [CK_Course_3] CHECK (Status IN ('Draft','Published'))
);

CREATE TABLE dbo.Payment (
 PaymentID INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Payment PRIMARY KEY,
 LearnerID INT NOT NULL,
 CourseID INT NOT NULL,
 Provider NVARCHAR(20) NOT NULL CONSTRAINT DF_Payment_Provider DEFAULT ('eSewa'),
 TransactionUUID NVARCHAR(64) NOT NULL CONSTRAINT UQ_Payment_TransactionUUID UNIQUE,
 ProviderReference NVARCHAR(100) NULL,
 AmountNPR DECIMAL(10,2) NOT NULL,
 Status NVARCHAR(20) NOT NULL CONSTRAINT DF_Payment_Status DEFAULT ('Pending'),
 CreatedDate DATETIME2(0) NOT NULL CONSTRAINT DF_Payment_CreatedDate DEFAULT (SYSUTCDATETIME()),
 VerifiedDate DATETIME2(0) NULL,
 CONSTRAINT FK_Payment_User FOREIGN KEY (LearnerID) REFERENCES dbo.[User](UserID) ON DELETE NO ACTION,
 CONSTRAINT FK_Payment_Course FOREIGN KEY (CourseID) REFERENCES dbo.Course(CourseID) ON DELETE NO ACTION,
 CONSTRAINT CK_Payment_Provider CHECK (Provider='eSewa'),
 CONSTRAINT CK_Payment_Amount CHECK (AmountNPR>0),
 CONSTRAINT CK_Payment_Status CHECK (Status IN ('Pending','Complete','Failed','Canceled'))
);

CREATE TABLE dbo.[Topic]
(
    [TopicID] INT IDENTITY(1,1) NOT NULL,
    [CourseID] INT NOT NULL,
    [Title] NVARCHAR(100) NOT NULL,
    [SortOrder] INT NOT NULL,
    CONSTRAINT [PK_Topic] PRIMARY KEY ([TopicID]),
    CONSTRAINT [CK_Topic_1] CHECK (LEN(Title) BETWEEN 3 AND 100),
    CONSTRAINT [CK_Topic_2] CHECK (SortOrder BETWEEN 1 AND 100)
);

CREATE TABLE dbo.[Material]
(
    [MaterialID] INT IDENTITY(1,1) NOT NULL,
    [TopicID] INT NOT NULL,
    [Title] NVARCHAR(100) NOT NULL,
    [MaterialType] NVARCHAR(7) NOT NULL,
    [Status] NVARCHAR(9) NOT NULL CONSTRAINT [DF_Material_Status] DEFAULT ('Draft'),
    [TextContent] NVARCHAR(MAX) NULL,
    [FilePath] NVARCHAR(500) NULL,
    [YouTubeURL] NVARCHAR(500) NULL,
    [AltText] NVARCHAR(150) NULL,
    [IsPreview] BIT NOT NULL CONSTRAINT [DF_Material_IsPreview] DEFAULT (0),
    [SortOrder] INT NOT NULL,
    CONSTRAINT [PK_Material] PRIMARY KEY ([MaterialID]),
    CONSTRAINT [CK_Material_1] CHECK (Status IN ('Draft','Published')),
    CONSTRAINT [CK_Material_2] CHECK (LEN(Title) BETWEEN 3 AND 100),
    CONSTRAINT [CK_Material_3] CHECK (MaterialType IN ('Text','Image','PDF','Video','Audio','YouTube','Code')),
    CONSTRAINT [CK_Material_4] CHECK (TextContent IS NULL OR LEN(TextContent) BETWEEN 20 AND 10000),
    CONSTRAINT [CK_Material_5] CHECK (AltText IS NULL OR LEN(AltText) BETWEEN 5 AND 150),
    CONSTRAINT [CK_Material_6] CHECK (MaterialType NOT IN ('Text','Code') OR TextContent IS NOT NULL),
    CONSTRAINT [CK_Material_7] CHECK (MaterialType NOT IN ('Image','PDF','Video','Audio') OR (FilePath IS NOT NULL AND LEN(FilePath) > 0)),
    CONSTRAINT [CK_Material_8] CHECK (MaterialType <> 'YouTube' OR (YouTubeURL IS NOT NULL AND LEN(YouTubeURL) > 0)),
    CONSTRAINT [CK_Material_9] CHECK (MaterialType <> 'Image' OR AltText IS NOT NULL)
);

CREATE TABLE dbo.[MaterialCompletion]
(
    [LearnerID] INT NOT NULL,
    [MaterialID] INT NOT NULL,
    [CompletedDate] DATETIME2(0) NOT NULL CONSTRAINT [DF_MaterialCompletion_CompletedDate] DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT [PK_MaterialCompletion] PRIMARY KEY ([LearnerID], [MaterialID])
);

CREATE TABLE dbo.[Enrolment]
(
    [LearnerID] INT NOT NULL,
    [CourseID] INT NOT NULL,
    [EnrolDate] DATETIME2(0) NOT NULL CONSTRAINT [DF_Enrolment_EnrolDate] DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT [PK_Enrolment] PRIMARY KEY ([LearnerID], [CourseID])
);

CREATE TABLE dbo.[Activity]
(
    [ActivityID] INT IDENTITY(1,1) NOT NULL,
    [TopicID] INT NOT NULL,
    [ActivityType] NVARCHAR(14) NOT NULL,
    [Title] NVARCHAR(100) NOT NULL,
    [Description] NVARCHAR(1000) NULL,
    [Status] NVARCHAR(9) NOT NULL CONSTRAINT [DF_Activity_Status] DEFAULT ('Draft'),
    [SortOrder] INT NOT NULL,
    [CreatedDate] DATETIME2(0) NOT NULL CONSTRAINT [DF_Activity_CreatedDate] DEFAULT (SYSUTCDATETIME()),
    [TimeLimitMinutes] INT NULL,
    [MaxAttempts] INT NULL,
    [GameTemplate] NVARCHAR(10) NULL,
    [IsClosed] BIT NULL,
    [StartStepID] INT NULL,
    CONSTRAINT [PK_Activity] PRIMARY KEY ([ActivityID]),
    CONSTRAINT [CK_Activity_1] CHECK (ActivityType IN ('Quiz','SelfAssessment','Discussion','Game','Scenario')),
    CONSTRAINT [CK_Activity_2] CHECK (Status IN ('Draft','Published')),
    CONSTRAINT [CK_Activity_3] CHECK (LEN(Title) BETWEEN 3 AND 100 AND (ActivityType <> 'Discussion' OR LEN(Title) >= 5)),
    CONSTRAINT [CK_Activity_4] CHECK (Description IS NULL OR LEN(Description) <= 1000),
    CONSTRAINT [CK_Activity_5] CHECK (ActivityType NOT IN ('Discussion','Scenario') OR (Description IS NOT NULL AND LEN(Description) BETWEEN 10 AND 1000)),
    CONSTRAINT [CK_Activity_6] CHECK ((ActivityType = 'Quiz' AND TimeLimitMinutes IS NOT NULL AND TimeLimitMinutes BETWEEN 0 AND 180 AND MaxAttempts IS NOT NULL AND MaxAttempts BETWEEN 0 AND 10) OR (ActivityType <> 'Quiz' AND TimeLimitMinutes IS NULL AND MaxAttempts IS NULL)),
    CONSTRAINT [CK_Activity_7] CHECK ((ActivityType = 'Game' AND GameTemplate IS NOT NULL AND GameTemplate IN ('Matching','Memory','Scramble','Sort','Flashcards','FillBlank','TrueFalse','Sequence')) OR (ActivityType <> 'Game' AND GameTemplate IS NULL)),
    CONSTRAINT [CK_Activity_8] CHECK ((ActivityType = 'Discussion' AND IsClosed IS NOT NULL) OR (ActivityType <> 'Discussion' AND IsClosed IS NULL)),
    CONSTRAINT [CK_Activity_9] CHECK (ActivityType = 'Scenario' OR StartStepID IS NULL)
);

CREATE TABLE dbo.[QuizQuestion]
(
    [QuestionID] INT IDENTITY(1,1) NOT NULL,
    [ActivityID] INT NOT NULL,
    [QuestionText] NVARCHAR(500) NOT NULL,
    [Marks] INT NOT NULL,
    [SortOrder] INT NOT NULL,
    CONSTRAINT [PK_QuizQuestion] PRIMARY KEY ([QuestionID]),
    CONSTRAINT [CK_QuizQuestion_1] CHECK (LEN(QuestionText) BETWEEN 5 AND 500),
    CONSTRAINT [CK_QuizQuestion_2] CHECK (Marks BETWEEN 1 AND 10)
);

CREATE TABLE dbo.[QuizOption]
(
    [OptionID] INT IDENTITY(1,1) NOT NULL,
    [QuestionID] INT NOT NULL,
    [OptionText] NVARCHAR(200) NOT NULL,
    [IsCorrect] BIT NOT NULL CONSTRAINT [DF_QuizOption_IsCorrect] DEFAULT (0),
    CONSTRAINT [PK_QuizOption] PRIMARY KEY ([OptionID]),
    CONSTRAINT [UQ_QuizOption_QuestionID_OptionText] UNIQUE ([QuestionID], [OptionText]),
    CONSTRAINT [CK_QuizOption_1] CHECK (LEN(OptionText) BETWEEN 1 AND 200)
);

CREATE TABLE dbo.[SAStatement]
(
    [StatementID] INT IDENTITY(1,1) NOT NULL,
    [ActivityID] INT NOT NULL,
    [StatementText] NVARCHAR(200) NOT NULL,
    [SortOrder] INT NOT NULL,
    CONSTRAINT [PK_SAStatement] PRIMARY KEY ([StatementID]),
    CONSTRAINT [CK_SAStatement_1] CHECK (LEN(StatementText) BETWEEN 5 AND 200)
);

CREATE TABLE dbo.[DiscussionPost]
(
    [PostID] INT IDENTITY(1,1) NOT NULL,
    [ActivityID] INT NOT NULL,
    [UserID] INT NOT NULL,
    [ParentPostID] INT NULL,
    [Content] NVARCHAR(2000) NOT NULL,
    [PostedDate] DATETIME2(0) NOT NULL CONSTRAINT [DF_DiscussionPost_PostedDate] DEFAULT (SYSUTCDATETIME()),
    [EditedDate] DATETIME2(0) NULL,
    CONSTRAINT [PK_DiscussionPost] PRIMARY KEY ([PostID]),
    CONSTRAINT [CK_DiscussionPost_1] CHECK (LEN(Content) BETWEEN 2 AND 2000),
    CONSTRAINT [CK_DiscussionPost_2] CHECK (ParentPostID IS NULL OR ParentPostID <> PostID)
);

CREATE TABLE dbo.[GameGroup]
(
    [GroupID] INT IDENTITY(1,1) NOT NULL,
    [ActivityID] INT NOT NULL,
    [GroupName] NVARCHAR(50) NOT NULL,
    CONSTRAINT [PK_GameGroup] PRIMARY KEY ([GroupID]),
    CONSTRAINT [CK_GameGroup_1] CHECK (LEN(GroupName) BETWEEN 1 AND 50)
);

CREATE TABLE dbo.[GameItem]
(
    [ItemID] INT IDENTITY(1,1) NOT NULL,
    [ActivityID] INT NOT NULL,
    [GroupID] INT NULL,
    [ItemText] NVARCHAR(100) NOT NULL,
    [MatchText] NVARCHAR(200) NULL,
    CONSTRAINT [PK_GameItem] PRIMARY KEY ([ItemID]),
    CONSTRAINT [CK_GameItem_1] CHECK (LEN(ItemText) BETWEEN 1 AND 100),
    CONSTRAINT [CK_GameItem_2] CHECK (MatchText IS NULL OR LEN(MatchText) BETWEEN 1 AND 200)
);

CREATE TABLE dbo.[SimStep]
(
    [StepID] INT IDENTITY(1,1) NOT NULL,
    [ActivityID] INT NOT NULL,
    [StepText] NVARCHAR(1000) NOT NULL,
    [ImagePath] NVARCHAR(500) NULL,
    [ImageAlt] NVARCHAR(150) NULL,
    [IsEnding] BIT NOT NULL CONSTRAINT [DF_SimStep_IsEnding] DEFAULT (0),
    [Outcome] NVARCHAR(10) NULL,
    [Feedback] NVARCHAR(500) NULL,
    CONSTRAINT [PK_SimStep] PRIMARY KEY ([StepID]),
    CONSTRAINT [CK_SimStep_1] CHECK (LEN(StepText) BETWEEN 10 AND 1000),
    CONSTRAINT [CK_SimStep_2] CHECK (ImageAlt IS NULL OR LEN(ImageAlt) BETWEEN 5 AND 150),
    CONSTRAINT [CK_SimStep_3] CHECK (ImagePath IS NULL OR (LEN(ImagePath) > 0 AND ImageAlt IS NOT NULL)),
    CONSTRAINT [CK_SimStep_4] CHECK (Outcome IS NULL OR Outcome IN ('Best','Acceptable','Poor')),
    CONSTRAINT [CK_SimStep_5] CHECK (Feedback IS NULL OR LEN(Feedback) BETWEEN 10 AND 500),
    CONSTRAINT [CK_SimStep_6] CHECK (IsEnding = 0 OR (Outcome IS NOT NULL AND Feedback IS NOT NULL))
);

CREATE TABLE dbo.[SimChoice]
(
    [ChoiceID] INT IDENTITY(1,1) NOT NULL,
    [FromStepID] INT NOT NULL,
    [NextStepID] INT NOT NULL,
    [ChoiceText] NVARCHAR(150) NOT NULL,
    CONSTRAINT [PK_SimChoice] PRIMARY KEY ([ChoiceID]),
    CONSTRAINT [CK_SimChoice_1] CHECK (LEN(ChoiceText) BETWEEN 2 AND 150),
    CONSTRAINT [CK_SimChoice_2] CHECK (FromStepID <> NextStepID)
);

CREATE TABLE dbo.[Attempt]
(
    [AttemptID] INT IDENTITY(1,1) NOT NULL,
    [ActivityID] INT NOT NULL,
    [LearnerID] INT NOT NULL,
    [EndingStepID] INT NULL,
    [SubmittedAt] DATETIME2(0) NOT NULL CONSTRAINT [DF_Attempt_SubmittedAt] DEFAULT (SYSUTCDATETIME()),
    [ScorePercent] DECIMAL(5,2) NULL,
    [TimeTakenSeconds] INT NULL,
    CONSTRAINT [PK_Attempt] PRIMARY KEY ([AttemptID]),
    CONSTRAINT [CK_Attempt_1] CHECK (ScorePercent IS NULL OR ScorePercent BETWEEN 0 AND 100),
    CONSTRAINT [CK_Attempt_2] CHECK (TimeTakenSeconds IS NULL OR TimeTakenSeconds >= 0)
);

CREATE TABLE dbo.[QuizAnswer]
(
    [AttemptID] INT NOT NULL,
    [QuestionID] INT NOT NULL,
    [SelectedOptionID] INT NULL,
    CONSTRAINT [PK_QuizAnswer] PRIMARY KEY ([AttemptID], [QuestionID])
);

CREATE TABLE dbo.[SAResponse]
(
    [AttemptID] INT NOT NULL,
    [StatementID] INT NOT NULL,
    [Rating] INT NOT NULL,
    CONSTRAINT [PK_SAResponse] PRIMARY KEY ([AttemptID], [StatementID]),
    CONSTRAINT [CK_SAResponse_1] CHECK (Rating BETWEEN 1 AND 5)
);

CREATE TABLE dbo.[Review]
(
    [ReviewID] INT IDENTITY(1,1) NOT NULL,
    [CourseID] INT NOT NULL,
    [LearnerID] INT NOT NULL,
    [Rating] INT NOT NULL,
    [Comment] NVARCHAR(1000) NOT NULL,
    [PostedDate] DATETIME2(0) NOT NULL CONSTRAINT [DF_Review_PostedDate] DEFAULT (SYSUTCDATETIME()),
    [EditedDate] DATETIME2(0) NULL,
    CONSTRAINT [PK_Review] PRIMARY KEY ([ReviewID]),
    CONSTRAINT [UQ_Review_LearnerID_CourseID] UNIQUE ([LearnerID], [CourseID]),
    CONSTRAINT [CK_Review_1] CHECK (Rating BETWEEN 1 AND 5),
    CONSTRAINT [CK_Review_2] CHECK (LEN(Comment) BETWEEN 10 AND 1000)
);

CREATE TABLE dbo.[ContactMessage]
(
    [MessageID] INT IDENTITY(1,1) NOT NULL,
    [UserID] INT NULL,
    [SenderName] NVARCHAR(100) NOT NULL,
    [SenderEmail] NVARCHAR(100) NOT NULL,
    [Subject] NVARCHAR(100) NOT NULL,
    [Message] NVARCHAR(2000) NOT NULL,
    [SentDate] DATETIME2(0) NOT NULL CONSTRAINT [DF_ContactMessage_SentDate] DEFAULT (SYSUTCDATETIME()),
    [IsRead] BIT NOT NULL CONSTRAINT [DF_ContactMessage_IsRead] DEFAULT (0),
    CONSTRAINT [PK_ContactMessage] PRIMARY KEY ([MessageID]),
    CONSTRAINT [CK_ContactMessage_1] CHECK (LEN(SenderName) BETWEEN 2 AND 100),
    CONSTRAINT [CK_ContactMessage_2] CHECK (LEN(Subject) BETWEEN 3 AND 100),
    CONSTRAINT [CK_ContactMessage_3] CHECK (LEN(Message) BETWEEN 10 AND 2000)
);

CREATE TABLE dbo.[Bookmark]
(
    [LearnerID] INT NOT NULL,
    [MaterialID] INT NOT NULL,
    [CreatedDate] DATETIME2(0) NOT NULL CONSTRAINT [DF_Bookmark_CreatedDate] DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT [PK_Bookmark] PRIMARY KEY ([LearnerID], [MaterialID])
);

-- Privacy-friendly page analytics: no user ID, IP address or cookie is stored.
CREATE TABLE dbo.[PageView]
(
    [PageViewID] INT IDENTITY(1,1) NOT NULL,
    [PagePath] NVARCHAR(200) NOT NULL,
    [ViewerRole] NVARCHAR(7) NOT NULL,
    [ViewedAt] DATETIME2(0) NOT NULL CONSTRAINT [DF_PageView_ViewedAt] DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT [PK_PageView] PRIMARY KEY ([PageViewID]),
    CONSTRAINT [CK_PageView_1] CHECK (LEN(PagePath) BETWEEN 1 AND 200),
    CONSTRAINT [CK_PageView_2] CHECK (ViewerRole IN ('Visitor','Learner','Teacher','Admin'))
);

CREATE TABLE dbo.[FAQ]
(
    [FAQID] INT IDENTITY(1,1) NOT NULL,
    [Question] NVARCHAR(200) NOT NULL,
    [Answer] NVARCHAR(2000) NOT NULL,
    [Audience] NVARCHAR(7) NOT NULL,
    [SortOrder] INT NOT NULL,
    CONSTRAINT [PK_FAQ] PRIMARY KEY ([FAQID]),
    CONSTRAINT [CK_FAQ_1] CHECK (LEN(Question) BETWEEN 5 AND 200),
    CONSTRAINT [CK_FAQ_2] CHECK (LEN(Answer) BETWEEN 10 AND 2000),
    CONSTRAINT [CK_FAQ_3] CHECK (Audience IN ('All','Learner','Teacher')),
    CONSTRAINT [CK_FAQ_4] CHECK (SortOrder BETWEEN 1 AND 100)
);

-- Add references after all tables exist, including the Activity/SimStep cycle.
ALTER TABLE dbo.[Course] ADD CONSTRAINT [FK_Course_TeacherID]
    FOREIGN KEY ([TeacherID]) REFERENCES dbo.[User] ([UserID])
    ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE dbo.[Course] ADD CONSTRAINT [FK_Course_SubjectID]
    FOREIGN KEY ([SubjectID]) REFERENCES dbo.[Subject] ([SubjectID])
    ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE dbo.[Topic] ADD CONSTRAINT [FK_Topic_CourseID]
    FOREIGN KEY ([CourseID]) REFERENCES dbo.[Course] ([CourseID])
    ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE dbo.[Material] ADD CONSTRAINT [FK_Material_TopicID]
    FOREIGN KEY ([TopicID]) REFERENCES dbo.[Topic] ([TopicID])
    ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE dbo.[MaterialCompletion] ADD CONSTRAINT [FK_MaterialCompletion_LearnerID]
    FOREIGN KEY ([LearnerID]) REFERENCES dbo.[User] ([UserID])
    ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE dbo.[MaterialCompletion] ADD CONSTRAINT [FK_MaterialCompletion_MaterialID]
    FOREIGN KEY ([MaterialID]) REFERENCES dbo.[Material] ([MaterialID])
    ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE dbo.[Enrolment] ADD CONSTRAINT [FK_Enrolment_LearnerID]
    FOREIGN KEY ([LearnerID]) REFERENCES dbo.[User] ([UserID])
    ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE dbo.[Enrolment] ADD CONSTRAINT [FK_Enrolment_CourseID]
    FOREIGN KEY ([CourseID]) REFERENCES dbo.[Course] ([CourseID])
    ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE dbo.[Activity] ADD CONSTRAINT [FK_Activity_TopicID]
    FOREIGN KEY ([TopicID]) REFERENCES dbo.[Topic] ([TopicID])
    ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE dbo.[Activity] ADD CONSTRAINT [FK_Activity_StartStepID]
    FOREIGN KEY ([StartStepID]) REFERENCES dbo.[SimStep] ([StepID])
    ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE dbo.[QuizQuestion] ADD CONSTRAINT [FK_QuizQuestion_ActivityID]
    FOREIGN KEY ([ActivityID]) REFERENCES dbo.[Activity] ([ActivityID])
    ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE dbo.[QuizOption] ADD CONSTRAINT [FK_QuizOption_QuestionID]
    FOREIGN KEY ([QuestionID]) REFERENCES dbo.[QuizQuestion] ([QuestionID])
    ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE dbo.[SAStatement] ADD CONSTRAINT [FK_SAStatement_ActivityID]
    FOREIGN KEY ([ActivityID]) REFERENCES dbo.[Activity] ([ActivityID])
    ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE dbo.[DiscussionPost] ADD CONSTRAINT [FK_DiscussionPost_ActivityID]
    FOREIGN KEY ([ActivityID]) REFERENCES dbo.[Activity] ([ActivityID])
    ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE dbo.[DiscussionPost] ADD CONSTRAINT [FK_DiscussionPost_UserID]
    FOREIGN KEY ([UserID]) REFERENCES dbo.[User] ([UserID])
    ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE dbo.[DiscussionPost] ADD CONSTRAINT [FK_DiscussionPost_ParentPostID]
    FOREIGN KEY ([ParentPostID]) REFERENCES dbo.[DiscussionPost] ([PostID])
    ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE dbo.[GameGroup] ADD CONSTRAINT [FK_GameGroup_ActivityID]
    FOREIGN KEY ([ActivityID]) REFERENCES dbo.[Activity] ([ActivityID])
    ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE dbo.[GameItem] ADD CONSTRAINT [FK_GameItem_ActivityID]
    FOREIGN KEY ([ActivityID]) REFERENCES dbo.[Activity] ([ActivityID])
    ON DELETE CASCADE ON UPDATE NO ACTION;
ALTER TABLE dbo.[GameItem] ADD CONSTRAINT [FK_GameItem_GroupID]
    FOREIGN KEY ([GroupID]) REFERENCES dbo.[GameGroup] ([GroupID])
    ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE dbo.[SimStep] ADD CONSTRAINT [FK_SimStep_ActivityID]
    FOREIGN KEY ([ActivityID]) REFERENCES dbo.[Activity] ([ActivityID])
    ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE dbo.[SimChoice] ADD CONSTRAINT [FK_SimChoice_FromStepID]
    FOREIGN KEY ([FromStepID]) REFERENCES dbo.[SimStep] ([StepID])
    ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE dbo.[SimChoice] ADD CONSTRAINT [FK_SimChoice_NextStepID]
    FOREIGN KEY ([NextStepID]) REFERENCES dbo.[SimStep] ([StepID])
    ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE dbo.[Attempt] ADD CONSTRAINT [FK_Attempt_ActivityID]
    FOREIGN KEY ([ActivityID]) REFERENCES dbo.[Activity] ([ActivityID])
    ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE dbo.[Attempt] ADD CONSTRAINT [FK_Attempt_LearnerID]
    FOREIGN KEY ([LearnerID]) REFERENCES dbo.[User] ([UserID])
    ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE dbo.[Attempt] ADD CONSTRAINT [FK_Attempt_EndingStepID]
    FOREIGN KEY ([EndingStepID]) REFERENCES dbo.[SimStep] ([StepID])
    ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE dbo.[QuizAnswer] ADD CONSTRAINT [FK_QuizAnswer_AttemptID]
    FOREIGN KEY ([AttemptID]) REFERENCES dbo.[Attempt] ([AttemptID])
    ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE dbo.[QuizAnswer] ADD CONSTRAINT [FK_QuizAnswer_QuestionID]
    FOREIGN KEY ([QuestionID]) REFERENCES dbo.[QuizQuestion] ([QuestionID])
    ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE dbo.[QuizAnswer] ADD CONSTRAINT [FK_QuizAnswer_SelectedOptionID]
    FOREIGN KEY ([SelectedOptionID]) REFERENCES dbo.[QuizOption] ([OptionID])
    ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE dbo.[SAResponse] ADD CONSTRAINT [FK_SAResponse_AttemptID]
    FOREIGN KEY ([AttemptID]) REFERENCES dbo.[Attempt] ([AttemptID])
    ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE dbo.[SAResponse] ADD CONSTRAINT [FK_SAResponse_StatementID]
    FOREIGN KEY ([StatementID]) REFERENCES dbo.[SAStatement] ([StatementID])
    ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE dbo.[Review] ADD CONSTRAINT [FK_Review_CourseID]
    FOREIGN KEY ([CourseID]) REFERENCES dbo.[Course] ([CourseID])
    ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE dbo.[Review] ADD CONSTRAINT [FK_Review_LearnerID]
    FOREIGN KEY ([LearnerID]) REFERENCES dbo.[User] ([UserID])
    ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE dbo.[ContactMessage] ADD CONSTRAINT [FK_ContactMessage_UserID]
    FOREIGN KEY ([UserID]) REFERENCES dbo.[User] ([UserID])
    ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE dbo.[Bookmark] ADD CONSTRAINT [FK_Bookmark_LearnerID]
    FOREIGN KEY ([LearnerID]) REFERENCES dbo.[User] ([UserID])
    ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE dbo.[Bookmark] ADD CONSTRAINT [FK_Bookmark_MaterialID]
    FOREIGN KEY ([MaterialID]) REFERENCES dbo.[Material] ([MaterialID])
    ON DELETE NO ACTION ON UPDATE NO ACTION;

-- A PK/unique index already covers an FK when that column is its first key.
CREATE INDEX [IX_Course_TeacherID] ON dbo.[Course] ([TeacherID]);
CREATE INDEX [IX_Course_SubjectID] ON dbo.[Course] ([SubjectID]);
CREATE INDEX [IX_Topic_CourseID] ON dbo.[Topic] ([CourseID]);
CREATE INDEX [IX_Material_TopicID] ON dbo.[Material] ([TopicID]);
CREATE INDEX [IX_MaterialCompletion_MaterialID] ON dbo.[MaterialCompletion] ([MaterialID]);
CREATE INDEX [IX_Enrolment_CourseID] ON dbo.[Enrolment] ([CourseID]);
CREATE INDEX [IX_Activity_TopicID] ON dbo.[Activity] ([TopicID]);
CREATE INDEX [IX_Activity_StartStepID] ON dbo.[Activity] ([StartStepID]);
CREATE INDEX [IX_QuizQuestion_ActivityID] ON dbo.[QuizQuestion] ([ActivityID]);
CREATE INDEX [IX_SAStatement_ActivityID] ON dbo.[SAStatement] ([ActivityID]);
CREATE INDEX [IX_DiscussionPost_ActivityID] ON dbo.[DiscussionPost] ([ActivityID]);
CREATE INDEX [IX_DiscussionPost_UserID] ON dbo.[DiscussionPost] ([UserID]);
CREATE INDEX [IX_DiscussionPost_ParentPostID] ON dbo.[DiscussionPost] ([ParentPostID]);
CREATE INDEX [IX_GameGroup_ActivityID] ON dbo.[GameGroup] ([ActivityID]);
CREATE INDEX [IX_GameItem_ActivityID] ON dbo.[GameItem] ([ActivityID]);
CREATE INDEX [IX_GameItem_GroupID] ON dbo.[GameItem] ([GroupID]);
CREATE INDEX [IX_SimStep_ActivityID] ON dbo.[SimStep] ([ActivityID]);
CREATE INDEX [IX_SimChoice_FromStepID] ON dbo.[SimChoice] ([FromStepID]);
CREATE INDEX [IX_SimChoice_NextStepID] ON dbo.[SimChoice] ([NextStepID]);
CREATE INDEX [IX_Attempt_ActivityID] ON dbo.[Attempt] ([ActivityID]);
CREATE INDEX [IX_Attempt_LearnerID] ON dbo.[Attempt] ([LearnerID]);
CREATE INDEX [IX_Attempt_EndingStepID] ON dbo.[Attempt] ([EndingStepID]);
CREATE INDEX [IX_QuizAnswer_QuestionID] ON dbo.[QuizAnswer] ([QuestionID]);
CREATE INDEX [IX_QuizAnswer_SelectedOptionID] ON dbo.[QuizAnswer] ([SelectedOptionID]);
CREATE INDEX [IX_SAResponse_StatementID] ON dbo.[SAResponse] ([StatementID]);
CREATE INDEX [IX_Review_CourseID] ON dbo.[Review] ([CourseID]);
CREATE INDEX [IX_ContactMessage_UserID] ON dbo.[ContactMessage] ([UserID]);
CREATE INDEX [IX_Bookmark_MaterialID] ON dbo.[Bookmark] ([MaterialID]);
CREATE INDEX [IX_Payment_LearnerID] ON dbo.[Payment] ([LearnerID]);
CREATE INDEX [IX_Payment_CourseID] ON dbo.[Payment] ([CourseID]);
CREATE INDEX [IX_PageView_ViewedAt] ON dbo.[PageView] ([ViewedAt]);

-- Demo records: fixed IDs make relationships easy to explain and inspect.
-- Demo accounts. Every password is Password123 (PBKDF2, see GenerateDemoHashes.ps1).
SET IDENTITY_INSERT dbo.[User] ON;
INSERT dbo.[User] ([UserID], [FullName], [Email], [PasswordHash], [Role], [Status], [ApplicationReason], [CreatedDate]) VALUES
    (1, N'Sanjana Shrestha', N'admin@inkwell.test', N'PBKDF2$100000$8OMc8FxrkNPn1Eiz920SZw==$vCIo3/fmd6Qf6mOqLlBHQ9IrcSL7rzBr62BMr9/tfiQ=', N'Admin', N'Active', NULL, DATEADD(minute, 600, DATEADD(day, -75, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (2, N'Asha Sharma', N'asha.sharma@inkwell.test', N'PBKDF2$100000$LL2IDtYvDfpb+CSq3OWWpw==$qggjA9fC/PXw4f5+JbOCmEDP+o78A15v8DnfsacJvzY=', N'Teacher', N'Active', NULL, DATEADD(minute, 600, DATEADD(day, -75, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (3, N'Daniel Tan', N'daniel.tan@inkwell.test', N'PBKDF2$100000$MKBj4G0mKoXjHiSuVvEQdA==$gBGRfNvwn3G7egnAPThTfwKBUcC7dbyM3ygJxZmysBs=', N'Teacher', N'Active', NULL, DATEADD(minute, 600, DATEADD(day, -75, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (4, N'Maya Rai', N'maya.rai@inkwell.test', N'PBKDF2$100000$4YGUcpxPZisOM4w4MxzeUA==$fREhJ7qVJCsiyQJHAOhYpWPpfvBY1TCT0o0Y/Wxs8vk=', N'Teacher', N'Active', NULL, DATEADD(minute, 600, DATEADD(day, -75, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (5, N'Rohan Karki', N'rohan.karki@inkwell.test', N'PBKDF2$100000$2Jek24PvTkjp+7bIrvZi0w==$9YH4P5rpt/OHXoryX3k8bsPwAQSJaIjj7FCD2Rm3rck=', N'Teacher', N'Active', NULL, DATEADD(minute, 600, DATEADD(day, -75, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (6, N'Elena Costa', N'elena.costa@inkwell.test', N'PBKDF2$100000$fpkBAFPuZYJgFucUYdLrkA==$OuqXGtHWAyp98HomarqiYdGUNbRctt9EQy3v4eUoZXs=', N'Teacher', N'Active', NULL, DATEADD(minute, 600, DATEADD(day, -75, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (7, N'Bikash Thapa', N'bikash.thapa@inkwell.test', N'PBKDF2$100000$1y0MzwcB3UlPkQmYlmVdow==$zcZyBUIRyC6KE+bBl0B2rZa+pmcqku7ZrPVx7K4flkI=', N'Teacher', N'Active', NULL, DATEADD(minute, 600, DATEADD(day, -75, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (8, N'Ravi Thapa', N'ravi.thapa@inkwell.test', N'PBKDF2$100000$gbN2fG+EF20YOktwyQJumA==$jbGocP3wpgK7QNO6UP1BdmmaRzYI5f7YosjdGbrXwFQ=', N'Teacher', N'Pending', N'I teach A-level mathematics at a Kathmandu college and would like to publish a short course on probability with worked examples and practice games.', DATEADD(minute, 600, DATEADD(day, -75, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (9, N'Anita Karki', N'anita.karki@inkwell.test', N'PBKDF2$100000$IKO0CO1XrwY7w2ov591x6w==$9uCMWluIjLFqQA/y1Ah8R0tX0oBIVxaXjoPOz4lKotU=', N'Learner', N'Active', NULL, DATEADD(minute, 600, DATEADD(day, -41, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (10, N'Ben Lee', N'ben.lee@inkwell.test', N'PBKDF2$100000$2ss+HkAtIcunAzIdVE1CUg==$vcGoeBIdShzaM7vn9samEetMe8o3Hfy9eOgaI4jW4Fc=', N'Learner', N'Active', NULL, DATEADD(minute, 600, DATEADD(day, -40, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (11, N'Chandra Gurung', N'chandra.gurung@inkwell.test', N'PBKDF2$100000$uounlUkBAayZEjAY5AiHmQ==$W0yC3gEYX4wwFmHoI9rtMpZKG740xymeNk+97ScvqNs=', N'Learner', N'Active', NULL, DATEADD(minute, 600, DATEADD(day, -39, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (12, N'Dina Wong', N'dina.wong@inkwell.test', N'PBKDF2$100000$BRmgr0Uxbw7pCiz+1LpwHA==$J731SC9DoX+zRto+uPXKo8Q109Owjhkx37gUYE0V1qM=', N'Learner', N'Active', NULL, DATEADD(minute, 600, DATEADD(day, -38, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0)))));
SET IDENTITY_INSERT dbo.[User] OFF;

SET IDENTITY_INSERT dbo.[Subject] ON;
INSERT dbo.[Subject] ([SubjectID], [SubjectName], [Description]) VALUES
    (1, N'Programming', N'Write code for the web and beyond with HTML, CSS, JavaScript and Python.'),
    (2, N'Cybersecurity', N'Protect accounts, networks and data, and learn how attackers think.'),
    (3, N'Artificial Intelligence', N'How machines learn from data, and how to use AI tools well and responsibly.'),
    (4, N'Mathematics and Data', N'Algebra and statistics with worked examples and plenty of practice.'),
    (5, N'Business', N'Starting a venture, managing money and making evidence-based decisions.'),
    (6, N'Science', N'Biology and chemistry learned through observation and investigation.'),
    (7, N'English and Communication', N'Clear writing, confident speaking and careful reading.'),
    (8, N'Study Skills', N'Plan your time, revise well and learn effectively online.');
SET IDENTITY_INSERT dbo.[Subject] OFF;

-- Courses: 14 by lecturers and 4 by the admin (TeacherID 1). Course 8 is a draft.
SET IDENTITY_INSERT dbo.[Course] ON;
INSERT dbo.[Course] ([CourseID], [TeacherID], [SubjectID], [Title], [Description], [CoverImagePath], [Status], [IsPaid], [PriceNPR], [CreatedDate], [LastUpdated]) VALUES
    (1, 2, 1, N'HTML and CSS: Build Your First Web Page', N'Write real HTML and CSS from the first lesson. You will structure a page with headings, lists, links and images, then style it with colours, fonts and the box model. Every topic ends with a code lab you can edit and run in the browser, followed by a short check.', N'~/Uploads/Images/f3130ade-494e-5492-8b51-11ad4def76ff.jpg', N'Published', 0, 0.00, DATEADD(minute, 600, DATEADD(day, -46, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0)))), DATEADD(minute, 600, DATEADD(day, -15, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (2, 2, 1, N'JavaScript Basics for the Browser', N'Make web pages respond to people. Learn variables, decisions, loops and functions, then use them to change a page when a button is clicked. Short code labs let you run every example yourself.', N'~/Uploads/Images/1fe110f0-a203-51f9-8d1e-6323bab43ebe.jpg', N'Published', 1, 499.00, DATEADD(minute, 600, DATEADD(day, -33, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0)))), DATEADD(minute, 600, DATEADD(day, -11, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (3, 2, 2, N'Digital Safety Essentials', N'Protect your accounts, spot scams and make careful choices online. You will practise recognising phishing messages, building strong passwords and responding to a suspicious message in an interactive scenario.', N'~/Uploads/Images/36003b97-f67a-5a56-9ed5-6dbb9c4c5328.jpg', N'Published', 0, 0.00, DATEADD(minute, 600, DATEADD(day, -58, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0)))), DATEADD(minute, 600, DATEADD(day, -19, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (4, 3, 5, N'Starting a Small Business', N'Turn an idea into a small, testable business. Find a real customer need, work out your costs and calculate the sales you need to break even, using a campus food stall as a running example.', N'~/Uploads/Images/4a199c77-cdc9-5847-b51d-c5390bf45212.jpg', N'Published', 0, 0.00, DATEADD(minute, 600, DATEADD(day, -52, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0)))), DATEADD(minute, 600, DATEADD(day, -17, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (5, 3, 5, N'Personal Finance for Students', N'Take control of your money while you study. Build a monthly budget, compare saving and borrowing, understand interest and avoid common money traps. Includes a printable budget worksheet.', N'~/Uploads/Images/eea71a25-e697-5729-a3ac-a61511063f0a.jpg', N'Published', 1, 299.00, DATEADD(minute, 600, DATEADD(day, -27, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0)))), DATEADD(minute, 600, DATEADD(day, -9, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (6, 4, 6, N'Cells and Scientific Enquiry', N'Explore the structures inside plant and animal cells and what each one does, then plan a fair investigation with controlled variables and repeated measurements.', N'~/Uploads/Images/cc1ed8ea-12cb-5a3e-9739-446a95b10d45.jpg', N'Published', 0, 0.00, DATEADD(minute, 600, DATEADD(day, -49, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0)))), DATEADD(minute, 600, DATEADD(day, -16, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (7, 4, 6, N'Chemistry of Everyday Reactions', N'Find the chemistry in your kitchen and city. Learn the signs of a chemical reaction, balance simple equations, and compare acids and bases using indicators.', N'~/Uploads/Images/44f6f0f0-183c-5beb-81bc-4038295f10c1.jpg', N'Published', 0, 0.00, DATEADD(minute, 600, DATEADD(day, -17, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0)))), DATEADD(minute, 600, DATEADD(day, -5, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (8, 4, 6, N'Introduction to Ecosystems', N'A draft course exploring food chains, producers, consumers and decomposers. Lessons and activities are still being prepared.', N'~/Uploads/Images/6ccb6a0d-0cc4-534a-9d4b-b6a9bd215708.jpg', N'Draft', 0, 0.00, DATEADD(minute, 600, DATEADD(day, -4, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0)))), DATEADD(minute, 600, DATEADD(day, -1, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (9, 5, 4, N'Algebra Foundations', N'Build the algebra skills every later topic depends on: using letters for numbers, simplifying expressions, and solving linear equations with clear, checkable steps.', N'~/Uploads/Images/5e946721-9e96-552e-b9e7-94e43420f6cf.jpg', N'Published', 0, 0.00, DATEADD(minute, 600, DATEADD(day, -40, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0)))), DATEADD(minute, 600, DATEADD(day, -13, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (10, 5, 4, N'Statistics You Can Use', N'Make sense of data in news, research and everyday decisions. Calculate averages and spread, read charts critically, and spot misleading graphs.', N'~/Uploads/Images/d4fef8f2-46e0-5b28-8b5b-5d4906a23a1b.jpg', N'Published', 1, 399.00, DATEADD(minute, 600, DATEADD(day, -24, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0)))), DATEADD(minute, 600, DATEADD(day, -8, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (11, 6, 7, N'Academic Writing Essentials', N'Write clear, well-organised essays and reports. Plan with a thesis, build paragraphs with evidence, and reference sources properly using APA 7th edition.', N'~/Uploads/Images/969b5db5-9cf1-5683-9cb1-753b52629fee.jpg', N'Published', 0, 0.00, DATEADD(minute, 600, DATEADD(day, -37, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0)))), DATEADD(minute, 600, DATEADD(day, -12, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (12, 6, 7, N'Presenting with Confidence', N'Plan, structure and deliver short presentations that people remember. Practise openings, slide design and handling questions, with listening exercises on voice and pace.', N'~/Uploads/Images/d938f4d9-c18a-5cd0-8a99-057227791a2c.jpg', N'Published', 0, 0.00, DATEADD(minute, 600, DATEADD(day, -15, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0)))), DATEADD(minute, 600, DATEADD(day, -5, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (13, 7, 1, N'Python Programming from Zero', N'Start programming with Python, the language used in data science, automation and teaching. Learn to store data, make decisions, repeat tasks and organise code into functions, with a short exercise after every idea.', N'~/Uploads/Images/570f6e2e-4223-5a0f-9507-9a73760d5130.jpg', N'Published', 0, 0.00, DATEADD(minute, 600, DATEADD(day, -21, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0)))), DATEADD(minute, 600, DATEADD(day, -7, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (14, 7, 3, N'AI Foundations: How Machines Learn', N'Understand what artificial intelligence is and is not. Learn how a model learns patterns from examples, why the quality of training data matters, and where AI makes mistakes. No programming is required.', N'~/Uploads/Images/de4899ee-9918-5d9b-9caa-2f02fa696198.jpg', N'Published', 0, 0.00, DATEADD(minute, 600, DATEADD(day, -12, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0)))), DATEADD(minute, 600, DATEADD(day, -4, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (15, 7, 2, N'Network Security Basics', N'Learn how data travels across a network and how it is protected. Cover IP addresses, ports, firewalls, encryption and safe Wi-Fi habits, then apply them in a public Wi-Fi scenario.', N'~/Uploads/Images/0a0ffd5b-8171-5886-b894-e5e27fadf87a.jpg', N'Published', 0, 0.00, DATEADD(minute, 600, DATEADD(day, -8, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0)))), DATEADD(minute, 600, DATEADD(day, -2, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (16, 1, 8, N'How to Learn Online Effectively', N'Get the most from online courses. Set up a study routine, use active learning techniques instead of rereading, and track your progress so you finish what you start.', N'~/Uploads/Images/e7fc4d7f-4012-5769-9ac9-64cac2ab3011.jpg', N'Published', 0, 0.00, DATEADD(minute, 600, DATEADD(day, -60, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0)))), DATEADD(minute, 600, DATEADD(day, -20, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (17, 1, 8, N'Exam Revision Strategies', N'Plan revision weeks ahead, practise under exam conditions and manage stress on the day. Includes a printable revision planner.', N'~/Uploads/Images/716194fa-688d-5ac3-bef9-5e85ee71437a.jpg', N'Published', 0, 0.00, DATEADD(minute, 600, DATEADD(day, -44, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0)))), DATEADD(minute, 600, DATEADD(day, -14, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (18, 1, 8, N'Time Management for Students', N'Balance classes, assignments, work and rest. Learn to prioritise with the urgent and important matrix, beat procrastination and use the Pomodoro technique.', N'~/Uploads/Images/601e7fb6-428d-5823-b737-639d17897990.jpg', N'Published', 0, 0.00, DATEADD(minute, 600, DATEADD(day, -35, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0)))), DATEADD(minute, 600, DATEADD(day, -11, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (19, 1, 3, N'Using AI Tools Responsibly', N'Use AI chatbots and writing tools to support your learning without breaking academic rules. Write effective prompts, check AI output for errors, and understand when using AI counts as misconduct.', N'~/Uploads/Images/36c32c46-fbd5-5ef0-9f88-3892f97844a7.jpg', N'Published', 0, 0.00, DATEADD(minute, 600, DATEADD(day, -6, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0)))), DATEADD(minute, 600, DATEADD(day, -2, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0)))));
SET IDENTITY_INSERT dbo.[Course] OFF;

-- Sandbox payments for the two paid courses that demo learners joined.
INSERT dbo.[Payment] ([LearnerID], [CourseID], [TransactionUUID], [ProviderReference], [AmountNPR], [Status], [CreatedDate], [VerifiedDate]) VALUES
    (9, 2, N'aa901729e7f25aaeabb4eab13cf20526', N'SANDBOX-01001', 499.00, N'Complete', DATEADD(minute, 540, DATEADD(day, -12, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0)))), DATEADD(minute, 542, DATEADD(day, -12, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (12, 10, N'4806df8e7a9a5b4ca395587869c29cff', N'SANDBOX-01002', 399.00, N'Complete', DATEADD(minute, 540, DATEADD(day, -8, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0)))), DATEADD(minute, 542, DATEADD(day, -8, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0)))));

SET IDENTITY_INSERT dbo.[Topic] ON;
INSERT dbo.[Topic] ([TopicID], [CourseID], [Title], [SortOrder]) VALUES
    (1, 1, N'How a web page is built', 1),
    (2, 1, N'Styling with CSS', 2),
    (3, 1, N'Publishing a page that works for everyone', 3),
    (4, 2, N'Values, variables and decisions', 1),
    (5, 2, N'Loops and functions', 2),
    (6, 2, N'Responding to the user', 3),
    (7, 3, N'Protecting your accounts', 1),
    (8, 3, N'Recognising suspicious messages', 2),
    (9, 3, N'Your digital footprint', 3),
    (10, 4, N'Customers and value', 1),
    (11, 4, N'Costs and break-even', 2),
    (12, 5, N'Budgeting that works', 1),
    (13, 5, N'Saving, borrowing and interest', 2),
    (14, 6, N'Inside a cell', 1),
    (15, 6, N'Planning a fair test', 2),
    (16, 7, N'Signs of a chemical reaction', 1),
    (17, 7, N'Balancing equations', 2),
    (18, 7, N'Acids and bases', 3),
    (19, 8, N'Food chains', 1),
    (20, 9, N'Expressions', 1),
    (21, 9, N'Solving linear equations', 2),
    (22, 10, N'Averages and spread', 1),
    (23, 10, N'Reading charts critically', 2),
    (24, 11, N'Planning and paragraphs', 1),
    (25, 11, N'Sources and referencing', 2),
    (26, 12, N'Structure and slides', 1),
    (27, 12, N'Voice, nerves and questions', 2),
    (28, 13, N'First steps in Python', 1),
    (29, 13, N'Decisions and loops', 2),
    (30, 13, N'Functions and lists', 3),
    (31, 14, N'What counts as AI', 1),
    (32, 14, N'How a model learns', 2),
    (33, 14, N'Limits and fairness', 3),
    (34, 15, N'How data travels', 1),
    (35, 15, N'Keeping networks safe', 2),
    (36, 16, N'Active learning', 1),
    (37, 16, N'Building a routine', 2),
    (38, 17, N'Planning revision', 1),
    (39, 17, N'Practising and the exam day', 2),
    (40, 18, N'Priorities', 1),
    (41, 18, N'Beating procrastination', 2),
    (42, 19, N'Writing good prompts', 1),
    (43, 19, N'Checking and integrity', 2);
SET IDENTITY_INSERT dbo.[Topic] OFF;

-- Lesson materials. Text lessons use the simple formatting described in Helpers/LessonFormatter.cs.
SET IDENTITY_INSERT dbo.[Material] ON;
INSERT dbo.[Material] ([MaterialID], [TopicID], [Title], [MaterialType], [Status], [TextContent], [FilePath], [AltText], [IsPreview], [SortOrder]) VALUES
    (1, 1, N'What HTML does', N'Text', N'Published', N'HTML (HyperText Markup Language) describes the **structure** of a web page. It tells the browser which text is a heading, which is a paragraph and where an image or link belongs. It does not decide colours or layout; that is the job of CSS.

## Elements and tags
An element usually has an opening tag, some content and a closing tag:

```
<p>This is a paragraph.</p>
```

- `<p>` is the opening tag and `</p>` is the closing tag.
- The text between them is the content.
- Some elements, such as `<img>`, have no closing tag.

## Attributes
Attributes add extra information inside the opening tag. A link needs an `href` attribute that says where it goes, and an image needs `src` (the file) and `alt` (a text description for screen readers and slow connections).

```
<a href="https://www.w3.org">Visit the W3C</a>
<img src="cat.jpg" alt="A grey cat sleeping on a chair">
```

> Always write meaningful alt text. It is the only way a blind visitor knows what the picture shows.', NULL, NULL, 1, 1),
    (2, 1, N'Anatomy of an HTML element', N'Image', N'Published', NULL, N'~/Uploads/Images/8ef3649a-ccaa-56c2-a43f-bf4310d4665a.png', N'Diagram of the element <a href="page.html">Read more</a> with labels for the opening tag, attribute name, attribute value, content and closing tag.', 1, 2),
    (3, 1, N'Code lab: your first page', N'Code', N'Published', N'<!DOCTYPE html>
<html lang="en">
<head>
  <title>My first page</title>
</head>
<body>
  <h1>Hello, I am learning HTML</h1>
  <p>Change this paragraph to say something about yourself.</p>
  <h2>Three things I like</h2>
  <ul>
    <li>Football</li>
    <li>Momo</li>
    <li>Music</li>
  </ul>
  <!-- Task: add a link to your favourite website below this line. -->
</body>
</html>', NULL, NULL, 0, 3),
    (4, 2, N'Selectors, properties and values', N'Text', N'Published', N'CSS (Cascading Style Sheets) controls how HTML looks. A CSS rule has a **selector** that picks elements and a block of **declarations** that style them.

```
h1 {
  color: #1f3a5f;
  font-size: 2rem;
}
```

- `h1` is the selector: it styles every main heading.
- `color` and `font-size` are properties.
- `#1f3a5f` and `2rem` are values.

## Three ways to add CSS
1. **External** stylesheet: a separate .css file linked in the head. Best for whole websites.
2. **Internal** style block: a `<style>` element inside the page head.
3. **Inline** style: a `style` attribute on one element. Use sparingly.

## Classes
Give elements a class to style a group of them:

```
<p class="note">Remember to save your work.</p>
.note { background: #fff4d6; padding: 8px; }
```

> When two rules conflict, the more specific selector wins. An id beats a class, and a class beats a tag name.', NULL, NULL, 0, 1),
    (5, 2, N'The CSS box model', N'Image', N'Published', NULL, N'~/Uploads/Images/c098aa08-4345-5375-8499-eea47425b8a1.png', N'Nested boxes showing content in the centre, surrounded by padding, then a border, then margin on the outside.', 0, 2),
    (6, 2, N'Code lab: style a profile card', N'Code', N'Published', N'<!DOCTYPE html>
<html lang="en">
<head>
<style>
  body { font-family: Georgia, serif; background: #f4f1ea; padding: 24px; }
  .card {
    background: white;
    border: 1px solid #ddd;
    border-radius: 8px;
    padding: 20px;
    max-width: 320px;
  }
  .card h2 { color: #1f3a5f; margin-top: 0; }
  /* Task: give .role a grey colour and a smaller font size. */
</style>
</head>
<body>
  <div class="card">
    <h2>Anita Karki</h2>
    <p class="role">Foundation student, Computing</p>
    <p>I am building my first website this term.</p>
  </div>
</body>
</html>', NULL, NULL, 0, 3),
    (7, 3, N'Accessible and responsive pages', N'Text', N'Published', N'A good page works for every visitor, on every screen.

## Accessibility checklist
- Use headings in order: one h1, then h2, then h3.
- Give every image useful alt text.
- Make link text describe the destination. "Download the timetable" is better than "click here".
- Keep enough contrast between text and background.
- Label every form field with a `<label>` element.

## Responsive design
Phones, tablets and laptops have different widths. Add this line to the head so phones do not zoom out:

```
<meta name="viewport" content="width=device-width, initial-scale=1">
```

Then use a media query to change the layout on small screens:

```
@media (max-width: 600px) {
  .columns { display: block; }
}
```

> Test your page by making the browser window narrow. If you have to scroll sideways, something is too wide.', NULL, NULL, 0, 1),
    (8, 3, N'HTML and CSS quick reference sheet', N'PDF', N'Published', NULL, N'~/Uploads/Documents/3ff3c1df-fc5a-51c9-847d-3a8e45a1cd4e.pdf', NULL, 0, 2),
    (9, 4, N'Storing values in variables', N'Text', N'Published', N'JavaScript is the programming language of the browser. A **variable** is a named box that stores a value.

```
let name = "Dina";
let age = 17;
const school = "Inkwell College";
```

- Use `let` for values that may change and `const` for values that stay the same.
- Text values are called **strings** and go inside quotes.
- Numbers are written without quotes.

## Making decisions
An `if` statement runs code only when a condition is true:

```
if (age >= 18) {
  console.log("You can vote.");
} else {
  console.log("Not yet.");
}
```

> A single = stores a value. Three === compares two values. Mixing them up is the most common beginner mistake.', NULL, NULL, 1, 1),
    (10, 4, N'Code lab: grade calculator', N'Code', N'Published', N'<!DOCTYPE html>
<html lang="en">
<body style="font-family: sans-serif; padding: 20px;">
<h1>Grade calculator</h1>
<p id="output"></p>
<script>
  let mark = 72;   // Task: try 45, 58 and 91
  let grade;
  if (mark >= 80) {
    grade = "A";
  } else if (mark >= 65) {
    grade = "B";
  } else if (mark >= 50) {
    grade = "C";
  } else {
    grade = "Not yet passed";
  }
  document.getElementById("output").textContent = "A mark of " + mark + " gives grade: " + grade;
</script>
</body>
</html>', NULL, NULL, 0, 2),
    (11, 5, N'Repeating work with loops', N'Text', N'Published', N'A **loop** repeats code so you do not have to write it many times.

```
for (let i = 1; i <= 5; i++) {
  console.log("Lap " + i);
}
```

The three parts in the brackets are: where to start, when to keep going, and how to move to the next step.

## Functions
A **function** is a named block of code you can reuse. It can take inputs (parameters) and give back a result with `return`.

```
function area(width, height) {
  return width * height;
}
let room = area(4, 3);   // room is 12
```

- Name functions with a verb: `calculateTotal`, `showMessage`.
- Keep each function focused on one job.', NULL, NULL, 0, 1),
    (12, 5, N'Code lab: times table generator', N'Code', N'Published', N'<!DOCTYPE html>
<html lang="en">
<body style="font-family: sans-serif; padding: 20px;">
<h1>Times table</h1>
<ul id="table"></ul>
<script>
  function buildTable(number) {
    const list = document.getElementById("table");
    for (let i = 1; i <= 10; i++) {
      const item = document.createElement("li");
      item.textContent = number + " x " + i + " = " + (number * i);
      list.appendChild(item);
    }
  }
  buildTable(7);   // Task: change 7 to any number you like
</script>
</body>
</html>', NULL, NULL, 0, 2),
    (13, 6, N'Events and the DOM', N'Text', N'Published', N'The **DOM** (Document Object Model) is the browser''s live map of the page. JavaScript can find an element and change it.

```
const button = document.getElementById("greet");
button.addEventListener("click", function () {
  document.getElementById("message").textContent = "Hello!";
});
```

- `getElementById` finds one element.
- `addEventListener` waits for an event such as a click.
- `textContent` safely changes the text shown.

> Use textContent instead of innerHTML when showing text typed by a user. It cannot accidentally run code.', NULL, NULL, 0, 1),
    (14, 6, N'Code lab: click counter', N'Code', N'Published', N'<!DOCTYPE html>
<html lang="en">
<body style="font-family: sans-serif; padding: 20px;">
<h1>Click counter</h1>
<button id="add" style="font-size: 18px; padding: 8px 16px;">Add one</button>
<p>You have clicked <strong id="count">0</strong> times.</p>
<script>
  let count = 0;
  document.getElementById("add").addEventListener("click", function () {
    count = count + 1;
    document.getElementById("count").textContent = count;
    // Task: show "Well done!" in an alert when count reaches 10.
  });
</script>
</body>
</html>', NULL, NULL, 0, 2),
    (15, 7, N'Passwords and two-step verification', N'Text', N'Published', N'Most accounts are broken into because of weak or reused passwords, not clever hacking.

## A strong password is
- **Long**: at least 12 characters. A short sentence works well, such as "Momo tastes better on Fridays".
- **Unique**: never reuse it on another site. If one site leaks, the rest stay safe.
- **Private**: no genuine company will ever ask for it by message or phone.

## Two-step verification
Turn on two-step verification (also called 2FA) for email and social accounts. After your password, the site asks for a code from your phone. A thief with only your password cannot get in.

> Keep the backup codes the site gives you somewhere safe and offline. They let you in if you lose your phone.', NULL, NULL, 1, 1),
    (16, 7, N'Listen: five habits that keep accounts safe', N'Audio', N'Published', NULL, N'~/Uploads/Audio/b09e480f-f9da-55da-82a8-50210ca74073.mp3', NULL, 0, 2),
    (17, 8, N'The signs of a phishing message', N'Text', N'Published', N'Phishing messages pretend to come from a bank, college, delivery company or friend. They try to make you act before you think.

## Common warning signs
1. **Urgency**: "Your account closes today."
2. **A mismatched sender**: the name says your bank, but the address ends in something strange.
3. **A link that does not match**: hover over it (or press and hold on a phone) to see the real address.
4. **Requests for passwords, OTP codes or payment.**
5. **Unexpected attachments**, especially files ending in .zip or .exe.

## What to do instead
Do not reply or click. Open the official website or app yourself, or phone the organisation using a number you already trust. Then report the message.', NULL, NULL, 0, 1),
    (18, 8, N'Spot the red flags in this message', N'Image', N'Published', NULL, N'~/Uploads/Images/9dff8a97-2d5f-5216-ac78-3631850ce80b.png', N'A fake bank SMS with four red flags circled: urgent deadline, unknown sender number, shortened link, and a request for an OTP code.', 0, 2),
    (19, 9, N'What you share stays online', N'Text', N'Published', N'Everything you post, like or share becomes part of your **digital footprint**. Colleges and employers sometimes search for applicants online.

## Think before you post
- Would you be comfortable if a teacher or future employer saw it?
- Does it reveal your location, school or daily routine?
- Does it include other people who did not agree to be shared?

## Check your privacy settings
Review who can see your posts, your friends list and your phone number. Turn off location tagging on photos unless you need it.', NULL, NULL, 0, 1),
    (20, 10, N'Start with a customer problem', N'Text', N'Published', N'Most new businesses fail because nobody needs what they sell. Start with a **customer problem**, not a product.

## Talk to customers first
Ask potential customers about what they do today, not what they might buy:
- "When did you last buy lunch on campus? What happened?"
- "What is the most annoying part of it?"
- "What have you tried instead?"

## Write a value proposition
Complete this sentence: **For** (customer) **who** (problem), **our** (product) **helps by** (benefit).

For students who have only 20 minutes between classes, our pre-order lunch stall helps by having a hot meal ready at a fixed time.

> Compliments are not evidence. Pre-orders, repeat visits and money paid are.', NULL, NULL, 1, 1),
    (21, 11, N'Fixed costs, variable costs and break-even', N'Text', N'Published', N'## Two kinds of cost
- **Fixed costs** stay the same however much you sell: stall rent, a licence, a monthly phone plan.
- **Variable costs** rise with every unit: ingredients, packaging, delivery.

## Contribution
Each sale contributes towards fixed costs:

**Contribution per unit = selling price - variable cost per unit**

## Break-even point
**Break-even units = fixed costs / contribution per unit**

## Worked example
A sandwich sells for NPR 150 and costs NPR 90 in ingredients and packaging. Contribution is NPR 60. Monthly stall rent is NPR 6,000, so break-even is 6,000 / 60 = **100 sandwiches** a month. Every sandwich after the hundredth adds NPR 60 profit.', NULL, NULL, 0, 1),
    (22, 11, N'Break-even chart for the sandwich stall', N'Image', N'Published', NULL, N'~/Uploads/Images/35850e79-14b8-51df-a665-5ded21493007.png', N'Line chart with units sold on the horizontal axis; the total cost line and revenue line cross at 100 sandwiches, marking the break-even point.', 0, 2),
    (23, 12, N'The 50/30/20 starting point', N'Text', N'Published', N'A budget is a plan for your money before you spend it.

## A simple starting rule
- **50 percent** on needs: rent, food, transport, phone.
- **30 percent** on wants: eating out, entertainment, new clothes.
- **20 percent** on saving or paying back debt.

Students often need to adjust these numbers. The point is to decide in advance.

## Track for one month
Write down every expense for 30 days, even small ones like tea and recharge cards. Most people are surprised where their money goes.', NULL, NULL, 1, 1),
    (24, 12, N'Monthly budget worksheet', N'PDF', N'Published', NULL, N'~/Uploads/Documents/47bd851f-4cc1-5dd4-9b0c-cc48bb2d4dd4.pdf', NULL, 0, 2),
    (25, 13, N'How interest grows and costs', N'Text', N'Published', N'**Interest** is the price of money over time.

## Saving
A bank pays you interest for keeping money with it. With compound interest, you earn interest on earlier interest as well.

NPR 10,000 at 8 percent a year becomes NPR 10,800 after one year and NPR 11,664 after two.

## Borrowing
When you borrow, you pay interest. Buy-now-pay-later offers and credit cards can charge very high rates if you miss a payment.

> Before borrowing, ask: what is the total amount I will repay, and what happens if I am late?', NULL, NULL, 0, 1),
    (26, 14, N'Cell structures and their jobs', N'Text', N'Published', N'All living things are made of cells. Most cells share a few key parts.

## In animal and plant cells
- **Nucleus**: contains genetic material (DNA) and controls the cell''s activities.
- **Cell membrane**: a thin barrier that controls what enters and leaves.
- **Cytoplasm**: jelly-like fluid where many chemical reactions happen.
- **Mitochondria**: release energy from food through respiration.

## Only in plant cells
- **Cell wall**: made of cellulose; supports the cell and keeps its shape.
- **Chloroplasts**: absorb light energy for photosynthesis.
- **Permanent vacuole**: filled with cell sap; keeps the cell firm.

> A cell''s shape is linked to its job. Root hair cells are long and thin to absorb water; red blood cells have no nucleus, leaving more room to carry oxygen.', NULL, NULL, 1, 1),
    (27, 14, N'Plant cell and animal cell compared', N'Image', N'Published', NULL, N'~/Uploads/Images/37545d6e-d700-5f7e-b72f-e603ad70f65d.png', N'Labelled plant and animal cells side by side. Only the plant cell has a cell wall, chloroplasts and a large vacuole.', 0, 2),
    (28, 14, N'Listen: a two-minute tour of a plant cell', N'Audio', N'Published', NULL, N'~/Uploads/Audio/ff1b56a7-2b01-5327-a5fc-79513da8f90e.mp3', NULL, 0, 3),
    (29, 15, N'Variables and fair testing', N'Text', N'Published', N'A fair test changes **one** thing at a time.

## Three kinds of variable
- **Independent variable**: the one you deliberately change.
- **Dependent variable**: the one you measure.
- **Control variables**: everything you keep the same.

## Example: does light affect seedling growth?
- Independent: light level (dark, dim, bright).
- Dependent: height after 10 days, in millimetres.
- Controls: seed type, water volume, soil, temperature, pot size.

Grow several seedlings at each light level and calculate a mean. Repeats reduce the effect of one unusual plant.', NULL, NULL, 0, 1),
    (30, 15, N'Laboratory safety checklist', N'PDF', N'Published', NULL, N'~/Uploads/Documents/33e02f90-57a2-5318-8694-02942772fab0.pdf', NULL, 0, 2),
    (31, 16, N'Physical and chemical changes', N'Text', N'Published', N'In a **physical change**, no new substance forms: ice melting or sugar dissolving. You can usually reverse it.

In a **chemical change**, new substances form. Signs include:
- a colour change (iron rusting),
- gas bubbles (baking soda with vinegar),
- a temperature change (a burning match),
- a solid forming in a liquid (a precipitate),
- a new smell (bread baking).

> One sign alone is not proof. Boiling water makes bubbles, but it is still water.', NULL, NULL, 1, 1),
    (32, 17, N'Atoms are never lost', N'Text', N'Published', N'In a chemical reaction, atoms are rearranged, never created or destroyed. A **balanced equation** has the same number of each atom on both sides.

## Example: hydrogen burning in oxygen
Unbalanced: H2 + O2 -> H2O

The right side has only one oxygen atom. Put a 2 in front of water, then a 2 in front of hydrogen:

**2H2 + O2 -> 2H2O**

Now there are 4 hydrogen and 2 oxygen atoms on each side.

## Rules
1. Change only the big numbers in front (coefficients).
2. Never change the small numbers inside a formula.
3. Check every element at the end.', NULL, NULL, 0, 1),
    (33, 17, N'Video: balancing an equation step by step', N'Video', N'Published', NULL, N'~/Uploads/Video/93fed5ca-8bc9-549c-b695-15c1942745fd.mp4', NULL, 0, 2),
    (34, 18, N'The pH scale', N'Text', N'Published', N'The **pH scale** runs from 0 to 14.
- Below 7: **acidic** (lemon juice about 2, vinegar about 3).
- Exactly 7: **neutral** (pure water).
- Above 7: **alkaline** or basic (soap about 10, bleach about 12).

## Indicators
An indicator changes colour depending on pH. Universal indicator turns red in strong acid, green when neutral and purple in strong alkali. Red cabbage juice works as a home-made indicator.

## Neutralisation
Acid + base -> salt + water. Indigestion tablets neutralise extra stomach acid.', NULL, NULL, 0, 1),
    (35, 19, N'Producers and consumers', N'Text', N'Draft', N'Plants are **producers**: they make their own food using light energy. **Consumers** get energy by eating other living things.

Arrows in a food chain show the direction energy flows, from the food to the animal that eats it:

grass -> grasshopper -> frog -> snake', NULL, NULL, 0, 1),
    (36, 20, N'Letters stand for numbers', N'Text', N'Published', N'In algebra a letter stands for a number we do not know yet, or one that can change.

## Vocabulary
- **Term**: a single number, letter, or product such as 3x.
- **Expression**: terms joined by + or -, such as 3x + 5.
- **Coefficient**: the number in front of a letter. In 3x, the coefficient is 3.

## Collecting like terms
Only terms with the same letter part can be added:

4x + 2y + 3x - y = **7x + y**

## Expanding brackets
Multiply everything inside by the term outside:

3(x + 4) = **3x + 12**', NULL, NULL, 1, 1),
    (37, 21, N'Do the same to both sides', N'Text', N'Published', N'An equation is a balance. Whatever you do to one side, do to the other.

## Example
Solve 3x + 5 = 20

1. Subtract 5 from both sides: 3x = 15
2. Divide both sides by 3: x = 5
3. **Check**: 3(5) + 5 = 20. Correct.

## With letters on both sides
Solve 5x - 2 = 2x + 10
1. Subtract 2x: 3x - 2 = 10
2. Add 2: 3x = 12
3. Divide by 3: x = 4

> Always substitute your answer back in. It takes ten seconds and catches most mistakes.', NULL, NULL, 0, 1),
    (38, 21, N'Video: solving two-step equations', N'Video', N'Published', NULL, N'~/Uploads/Video/e4fd6d0b-3409-58d6-9e1c-546ce57e908f.mp4', NULL, 0, 2),
    (39, 22, N'Mean, median, mode and range', N'Text', N'Published', N'Data: test marks 4, 7, 7, 8, 9, 13

- **Mean**: add them and divide by how many. 48 / 6 = **8**
- **Median**: the middle value when sorted. Middle of 7 and 8 = **7.5**
- **Mode**: the most common value = **7**
- **Range**: largest minus smallest = 13 - 4 = **9**

## Which average to use?
- Use the **median** when there are extreme values. One very large salary makes the mean misleading.
- Use the **mode** for categories, such as the most popular shoe size.
- Use the **mean** when values are spread evenly with no outliers.', NULL, NULL, 1, 1),
    (40, 22, N'Mean, median and mode on a number line', N'Image', N'Published', NULL, N'~/Uploads/Images/9dff5344-fd20-55e8-9672-8ae5c9661ee4.png', N'Dot plot of the marks 4, 7, 7, 8, 9 and 13 with arrows marking the mode at 7, the median at 7.5 and the mean at 8.', 0, 2),
    (41, 23, N'How graphs can mislead', N'Text', N'Published', N'A chart can be accurate and still mislead.

## Watch for
1. **A cut-off vertical axis**: starting at 90 instead of 0 makes a small difference look huge.
2. **Missing labels or units**: a chart without units cannot be checked.
3. **Cherry-picked time ranges**: choosing only the months that support a claim.
4. **3D effects and pictures** that distort size.
5. **Correlation presented as cause**: ice-cream sales and drowning both rise in summer, but one does not cause the other.', NULL, NULL, 0, 1),
    (42, 23, N'Statistics formula sheet', N'PDF', N'Published', NULL, N'~/Uploads/Documents/b7b0d129-28c6-5e81-b141-bf32f4939329.pdf', NULL, 0, 2),
    (43, 24, N'Thesis statements and PEEL paragraphs', N'Text', N'Published', N'## The thesis statement
Your thesis is the one-sentence answer to the essay question. Everything else supports it.

Weak: "Social media has advantages and disadvantages."
Strong: "Social media helps students collaborate, but without clear limits it reduces the time spent on deep study."

## PEEL paragraphs
- **Point**: one clear claim.
- **Evidence**: a fact, quotation or statistic that supports it.
- **Explain**: show how the evidence proves the point.
- **Link**: connect back to the thesis or on to the next paragraph.

> One paragraph, one idea. If you change idea, start a new paragraph.', NULL, NULL, 1, 1),
    (44, 24, N'A PEEL paragraph, colour coded', N'Image', N'Published', NULL, N'~/Uploads/Images/4077d171-e263-5e0a-aacd-6fb40c190b80.png', N'A sample paragraph with its point, evidence, explanation and link sentences highlighted in four different colours and labelled.', 0, 2),
    (45, 25, N'APA 7th edition basics', N'Text', N'Published', N'Referencing shows where ideas came from and lets readers check them.

## In-text citations
- Paraphrase: (Sharma, 2022)
- Direct quotation: (Sharma, 2022, p. 14)
- Two authors: (Tan & Rai, 2021)

## Reference list entry for a book
Sharma, A. (2022). *Learning on the web*. Inkwell Press.

## Reference list entry for a web page
Rai, M. (2023, March 4). *How cells divide*. Science Notes. https://example.org/cells

> Keep a running list of sources while you research. Rebuilding it the night before a deadline is painful.', NULL, NULL, 0, 1),
    (46, 25, N'Essay planning template', N'PDF', N'Published', NULL, N'~/Uploads/Documents/8621a9f5-a094-5dfe-9ebd-8bd1d10cecc5.pdf', NULL, 0, 2),
    (47, 26, N'A simple structure for any talk', N'Text', N'Published', N'## Tell them, tell them, tell them
1. **Opening**: a question, a surprising fact or a short story. Then say what you will cover.
2. **Body**: three main points is enough for a ten-minute talk.
3. **Close**: summarise the points and end with one clear message or action.

## Slides support you, they do not replace you
- One idea per slide.
- Six words or fewer in a heading.
- Large text: at least 24 point.
- Use a picture or chart instead of a paragraph.

> If the audience is reading your slides, they are not listening to you.', NULL, NULL, 1, 1),
    (48, 27, N'Delivering with confidence', N'Text', N'Published', N'## Voice
- **Pace**: aim for about 130 words a minute. Pause after important points.
- **Volume**: speak to the back of the room.
- **Emphasis**: stress the key word in each sentence.

## Managing nerves
Nervousness is normal. Rehearse out loud at least three times, arrive early to test the equipment, and take two slow breaths before you start.

## Handling questions
Listen to the whole question, repeat it briefly so everyone hears it, answer in under a minute, and admit if you do not know: "Good question. I will check and send you the answer."', NULL, NULL, 0, 1),
    (49, 27, N'Listen: the same sentence at three speeds', N'Audio', N'Published', NULL, N'~/Uploads/Audio/51728f0d-63f0-524a-9da9-22c216fa506a.mp3', NULL, 0, 2),
    (50, 28, N'Printing, variables and input', N'Text', N'Published', N'Python reads almost like English, which makes it a popular first language.

```
print("Namaste!")
name = input("What is your name? ")
print("Nice to meet you, " + name)
```

- `print` shows output.
- `input` waits for the user to type something and returns it as text.
- A **variable** such as `name` stores a value. Python works out its type for you.

## Numbers from input
`input` always gives text. Convert it before doing maths:

```
age = int(input("Age: "))
print(age + 1)
```

> Indentation (spaces at the start of a line) matters in Python. It shows which lines belong together.', NULL, NULL, 1, 1),
    (51, 28, N'Video: writing and running your first program', N'Video', N'Published', NULL, N'~/Uploads/Video/d6622506-b8cc-58a0-9c23-6ba00314264d.mp4', NULL, 0, 2),
    (52, 29, N'if, elif and for', N'Text', N'Published', N'## Making decisions

```
temperature = 31
if temperature > 30:
    print("Stay in the shade")
elif temperature > 20:
    print("Pleasant day")
else:
    print("Take a jacket")
```

## Repeating with for
`range(5)` produces 0, 1, 2, 3, 4:

```
for number in range(1, 6):
    print(number * number)
```

This prints the squares 1, 4, 9, 16 and 25.', NULL, NULL, 0, 1),
    (53, 30, N'Reusable functions and lists of data', N'Text', N'Published', N'## Functions

```
def average(values):
    return sum(values) / len(values)

marks = [72, 65, 88, 91]
print(average(marks))   # 79.0
```

## Lists
A **list** holds several values in order. Lists start counting at 0.

- `marks[0]` is 72, the first item.
- `marks.append(54)` adds a value to the end.
- `len(marks)` tells you how many items there are.', NULL, NULL, 0, 1),
    (54, 31, N'From rules to learning', N'Text', N'Published', N'**Artificial intelligence** is a broad name for computer systems that perform tasks we usually link with human thinking, such as recognising speech or recommending a film.

## Two ways to build a smart program
1. **Rules written by people.** A programmer writes every step: "if the message contains the word lottery, mark it as spam". This works until spammers change their words.
2. **Machine learning.** The program is shown thousands of labelled examples (spam and not spam) and finds the patterns itself. It can then judge messages it has never seen.

## Narrow, not general
Every AI system you use today is **narrow**: it is good at one kind of task. A chess engine cannot translate Nepali, and a translation model cannot drive a car.

> When someone says "the AI decided", remember that people chose its data, its goal and where to use it. Responsibility stays with people.', NULL, NULL, 1, 1),
    (55, 32, N'Training, testing and accuracy', N'Text', N'Published', N'Imagine teaching a model to tell ripe mangoes from unripe ones using photos.

## The workflow
1. **Collect** photos of mangoes.
2. **Label** each photo as ripe or unripe.
3. **Split** the photos: most for training, some kept aside for testing.
4. **Train**: the model adjusts itself until its guesses on the training photos match the labels.
5. **Test** on the photos it has never seen. This shows how well it will work in real life.

## Why testing on new data matters
A model can memorise its training photos and still fail on new ones. This is called **overfitting**, like a student who memorises past papers without understanding the topic.

## Accuracy is not the whole story
If 95 out of 100 mangoes are ripe, a lazy model that always says "ripe" scores 95 percent accuracy and is still useless for finding unripe fruit.', NULL, NULL, 0, 1),
    (56, 32, N'The machine learning workflow', N'Image', N'Published', NULL, N'~/Uploads/Images/12dfb2fd-da4f-54e3-a8e7-698b54afdfd5.png', N'Five boxes connected by arrows: collect data, label, split into training and test sets, train the model, test on unseen data.', 0, 2),
    (57, 33, N'When AI gets it wrong', N'Text', N'Published', N'AI systems learn from data collected by people, so they can repeat human mistakes.

## Sources of error
- **Unrepresentative data**: a face-recognition model trained mostly on one group of people works worse for others.
- **Out-of-date data**: a model trained on last year''s prices does not know about this year''s inflation.
- **Confident errors**: chatbots can produce fluent text that is simply false. This is often called a "hallucination".

## Questions to ask about any AI system
- What data was it trained on, and who is missing from it?
- What happens to a person when it is wrong?
- Can a human review or overturn its decision?', NULL, NULL, 0, 1),
    (58, 34, N'Packets, IP addresses and ports', N'Text', N'Published', N'When you open a website, your device and a server swap thousands of small pieces of data called **packets**.

## Addresses
- An **IP address** identifies a device on a network, much like a house address.
- A **port** number identifies a service on that device. Web pages usually use port 443 (HTTPS); email and other services use different ports.

## The journey of a request
1. Your browser asks a DNS server for the IP address of the website name.
2. Your request is split into packets and sent through your router.
3. Routers across the internet pass the packets towards the server.
4. The server sends packets back, and your browser puts the page together.', NULL, NULL, 1, 1),
    (59, 34, N'A request travelling across the internet', N'Image', N'Published', NULL, N'~/Uploads/Images/7561f0b7-cb6e-513e-8206-92861a183ee1.png', N'Diagram showing a laptop, home router, internet routers, and a web server, with packets moving along arrows in both directions.', 0, 2),
    (60, 35, N'Firewalls, encryption and HTTPS', N'Text', N'Published', N'## Firewalls
A **firewall** checks traffic against rules and blocks what is not allowed, like a guard at a gate. Your router and your laptop both have one.

## Encryption
Encryption scrambles data so only someone with the right key can read it. **HTTPS** encrypts the traffic between your browser and a website, so others on the same Wi-Fi cannot read your passwords.

## Safe Wi-Fi habits
- Prefer your mobile data to unknown public Wi-Fi for banking.
- Check for HTTPS before entering any password.
- Change the default password on a home router.
- Turn off automatic connection to open networks.

> A padlock icon means the connection is encrypted. It does not prove the website is honest.', NULL, NULL, 0, 1),
    (61, 36, N'Why rereading is not enough', N'Text', N'Published', N'Rereading notes feels productive, but it mostly builds familiarity, not memory.

## Techniques that work
- **Retrieval practice**: close the book and write what you remember, then check. Quizzes and flashcards do this for you.
- **Spaced practice**: review a topic after one day, then three days, then a week.
- **Interleaving**: mix different types of problem in one session instead of doing twenty of the same kind.
- **Explaining**: teach the idea to a friend, or out loud to yourself.

> Every game and quiz on this platform is a retrieval practice tool. Use them before you feel ready.', NULL, NULL, 1, 1),
    (62, 36, N'Video: a tour of your learning dashboard', N'Video', N'Published', NULL, N'~/Uploads/Video/04e13c6b-2ec7-5db6-bfca-d79f9e855b5c.mp4', NULL, 1, 2),
    (63, 37, N'Plan, do, review', N'Text', N'Published', N'## Plan
At the start of each week, choose which lessons you will study and when. Put them in your calendar as fixed appointments.

## Do
Study in focused blocks of 25 to 45 minutes. Put your phone in another room.

## Review
At the end of the week, look at your progress bar and results. Which topics need another look?

## Keep a streak
Small daily progress beats long weekend sessions. Your dashboard shows your current learning streak.', NULL, NULL, 0, 1),
    (64, 38, N'Make a revision timetable', N'Text', N'Published', N'1. **List every topic** for each exam. Use the course outline.
2. **Rate each topic** red (weak), amber (unsure) or green (strong).
3. **Count the days** until each exam.
4. **Schedule red topics first and more often**, with green topics as quick reviews.
5. **Leave one free day a week** for catching up.

> Start revision at least four weeks before an exam. Cramming the night before is the least effective strategy.', NULL, NULL, 1, 1),
    (65, 38, N'Four-week revision planner', N'PDF', N'Published', NULL, N'~/Uploads/Documents/e28a1c83-920c-5aa0-8c4f-d05bc0cf807e.pdf', NULL, 0, 2),
    (66, 39, N'Past papers and exam day', N'Text', N'Published', N'## Use past papers properly
- Do them under timed conditions, without notes.
- Mark them honestly using the mark scheme.
- Keep a list of every mistake and revise those topics.

## The day before
Light review only, pack your bag, and sleep at least seven hours.

## In the exam
Read every question first, start with one you can answer well, and keep an eye on the clock: marks available tell you roughly how many minutes to spend.', NULL, NULL, 0, 1),
    (67, 40, N'Urgent versus important', N'Text', N'Published', N'The **Eisenhower matrix** sorts tasks into four boxes:

1. **Urgent and important**: do it now. An assignment due tomorrow.
2. **Important, not urgent**: schedule it. Revision for next month''s exam.
3. **Urgent, not important**: keep it short or hand it on. Most notifications.
4. **Neither**: drop it. Endless scrolling.

> Most progress happens in box 2. If you never schedule it, it eventually becomes box 1.', NULL, NULL, 1, 1),
    (68, 40, N'The urgent and important matrix', N'Image', N'Published', NULL, N'~/Uploads/Images/14277d15-a3d4-56e0-9eb7-60f126d0309c.png', N'A two-by-two grid labelled do now, schedule, delegate or limit, and drop, with student examples in each box.', 0, 2),
    (69, 41, N'The Pomodoro technique', N'Text', N'Published', N'1. Choose one task.
2. Set a timer for 25 minutes and work only on that task.
3. Take a 5-minute break away from the screen.
4. After four rounds, take a longer break of 15 to 30 minutes.

## Why it works
A short, fixed block feels easier to start than a whole evening of work. Starting is usually the hardest part.', NULL, NULL, 0, 1),
    (70, 41, N'Listen: getting started when you do not feel like it', N'Audio', N'Published', NULL, N'~/Uploads/Audio/765ffc2b-47b7-5fe1-9da0-0a7d6b1d0ad5.mp3', NULL, 0, 2),
    (71, 42, N'Prompts that get useful answers', N'Text', N'Published', N'A **prompt** is the instruction you give an AI tool. Vague prompts give vague answers.

## A useful prompt includes
- **Role or context**: "I am a first-year student studying statistics."
- **Task**: "Explain the difference between mean and median."
- **Format**: "Use one example with five numbers and no more than 100 words."
- **Constraints**: "Do not give me the answer to my homework; ask me questions instead."

## Use AI as a tutor, not a ghost-writer
Good: "Quiz me on photosynthesis with five questions, one at a time."
Risky: "Write my 1,500-word essay on photosynthesis."', NULL, NULL, 1, 1),
    (72, 43, N'Check everything, credit honestly', N'Text', N'Published', N'AI tools can be confidently wrong. They sometimes invent statistics, quotations and even academic references that do not exist.

## A checking routine
1. Ask where a fact comes from, then find that source yourself.
2. Compare the answer with your course materials.
3. Test any code it writes before trusting it.
4. Never paste private or personal information into a public AI tool.

## Academic integrity
Your college decides what AI use is allowed. If you are unsure, ask your lecturer **before** you use it, and state how you used it in your submission.', NULL, NULL, 0, 1);
SET IDENTITY_INSERT dbo.[Material] OFF;

SET IDENTITY_INSERT dbo.[Activity] ON;
INSERT dbo.[Activity] ([ActivityID], [TopicID], [ActivityType], [Title], [Description], [Status], [SortOrder], [TimeLimitMinutes], [MaxAttempts], [GameTemplate], [IsClosed]) VALUES
    (1, 1, N'Quiz', N'Check: HTML building blocks', N'Five quick questions on elements, tags and attributes.', N'Published', 1, 5, 3, NULL, NULL),
    (2, 1, N'Game', N'Match the HTML tag to its job', N'Pair each tag with what it does on the page.', N'Published', 2, NULL, NULL, N'Matching', NULL),
    (3, 2, N'Game', N'Sort the CSS properties', N'Decide whether each property mainly changes text or the box around an element.', N'Published', 1, NULL, NULL, N'Sort', NULL),
    (4, 2, N'Game', N'Complete the CSS rule', N'Type the missing word in each sentence.', N'Published', 2, NULL, NULL, N'FillBlank', NULL),
    (5, 3, N'SelfAssessment', N'How confident are you with HTML and CSS?', N'Rate yourself honestly. You can repeat this after more practice.', N'Published', 1, NULL, NULL, NULL, NULL),
    (6, 3, N'Discussion', N'Share your first web page idea', N'What will your first real web page be about? Describe who it is for and list three sections it will have. Reply to one classmate with a suggestion.', N'Published', 2, NULL, NULL, NULL, 0),
    (7, 4, N'Game', N'JavaScript true or false', N'Answer quickly. You have a few seconds for each statement.', N'Published', 1, NULL, NULL, N'TrueFalse', NULL),
    (8, 5, N'Game', N'Order the steps of a function call', N'Put these steps in the order the browser follows them.', N'Published', 1, NULL, NULL, N'Sequence', NULL),
    (9, 5, N'Quiz', N'Check: loops and functions', N'Test your understanding of for loops and functions.', N'Published', 2, 10, 3, NULL, NULL),
    (10, 6, N'Discussion', N'Debugging stories', N'Describe a bug you met in your code this week, what caused it, and how you found it. Reading other people''s bugs is one of the fastest ways to improve.', N'Published', 1, NULL, NULL, NULL, 0),
    (11, 7, N'Game', N'Security vocabulary memory', N'Find each term and its meaning.', N'Published', 1, NULL, NULL, N'Memory', NULL),
    (12, 8, N'Game', N'Safe or suspicious?', N'Sort each situation into the right group.', N'Published', 1, NULL, NULL, N'Sort', NULL),
    (13, 8, N'Scenario', N'An urgent account message', N'You receive a message saying your college account will be closed today unless you sign in through a link. Decide how to respond, one step at a time.', N'Published', 2, NULL, NULL, NULL, NULL),
    (14, 9, N'Quiz', N'Check: staying safe online', N'A short check on passwords, phishing and privacy.', N'Published', 1, 8, 0, NULL, NULL),
    (15, 10, N'Discussion', N'Test a business idea', N'Describe one customer problem you have noticed on your campus or in your neighbourhood. Suggest one question you could ask real customers to test whether your solution is useful.', N'Published', 1, NULL, NULL, NULL, 0),
    (16, 10, N'Game', N'Business vocabulary flashcards', N'Flip each card and rate how well you knew it.', N'Published', 2, NULL, NULL, N'Flashcards', NULL),
    (17, 11, N'Game', N'Sort the stall''s costs', N'Decide whether each cost is fixed or variable.', N'Published', 1, NULL, NULL, N'Sort', NULL),
    (18, 11, N'Quiz', N'Check: break-even calculations', N'Work these out with pen and paper first.', N'Published', 2, 15, 3, NULL, NULL),
    (19, 12, N'Game', N'Needs or wants?', N'Sort each expense.', N'Published', 1, NULL, NULL, N'Sort', NULL),
    (20, 13, N'Game', N'Money facts', N'True or false? Be quick.', N'Published', 1, NULL, NULL, N'TrueFalse', NULL),
    (21, 13, N'Quiz', N'Check: interest and budgeting', N'Apply the ideas from this topic.', N'Published', 2, 10, 0, NULL, NULL),
    (22, 13, N'SelfAssessment', N'My money habits', N'Rate how true each statement is for you today.', N'Published', 3, NULL, NULL, NULL, NULL),
    (23, 14, N'Game', N'Cell structure memory', N'Match each structure with its job.', N'Published', 1, NULL, NULL, N'Memory', NULL),
    (24, 14, N'Game', N'Unscramble the cell words', N'Use the hint to rebuild each scientific word.', N'Published', 2, NULL, NULL, N'Scramble', NULL),
    (25, 15, N'SelfAssessment', N'Planning an investigation', N'Rate your confidence in planning a fair scientific test.', N'Published', 1, NULL, NULL, NULL, NULL),
    (26, 15, N'Quiz', N'Check: cells and fair tests', N'Five questions covering both topics.', N'Published', 2, 10, 3, NULL, NULL),
    (27, 16, N'Game', N'Physical or chemical change?', N'Sort each everyday change.', N'Published', 1, NULL, NULL, N'Sort', NULL),
    (28, 17, N'Game', N'Steps to balance an equation', N'Put these steps in order.', N'Published', 1, NULL, NULL, N'Sequence', NULL),
    (29, 18, N'Game', N'Complete the chemistry sentences', N'Type the missing word.', N'Published', 1, NULL, NULL, N'FillBlank', NULL),
    (30, 18, N'Quiz', N'Check: everyday chemistry', N'Questions on reactions, equations and pH.', N'Published', 2, 12, 3, NULL, NULL),
    (31, 20, N'Game', N'Match the algebra word', N'Pair each word with its example.', N'Published', 1, NULL, NULL, N'Matching', NULL),
    (32, 20, N'Game', N'Simplify and fill the blank', N'Type the simplified answer exactly as shown in the pattern.', N'Published', 2, NULL, NULL, N'FillBlank', NULL),
    (33, 21, N'Game', N'Order the solving steps', N'Put the steps for solving 4x + 3 = 19 in order.', N'Published', 1, NULL, NULL, N'Sequence', NULL),
    (34, 21, N'Quiz', N'Check: algebra foundations', N'Solve each one on paper first.', N'Published', 2, 15, 3, NULL, NULL),
    (35, 21, N'SelfAssessment', N'Algebra confidence', N'How sure are you about each skill?', N'Published', 3, NULL, NULL, NULL, NULL),
    (36, 22, N'Game', N'Averages true or false', N'Decide fast.', N'Published', 1, NULL, NULL, N'TrueFalse', NULL),
    (37, 23, N'Game', N'Statistics flashcards', N'Test your recall of key terms.', N'Published', 1, NULL, NULL, N'Flashcards', NULL),
    (38, 23, N'Quiz', N'Check: statistics', N'Calculate and interpret.', N'Published', 2, 15, 0, NULL, NULL),
    (39, 23, N'Discussion', N'Find a misleading chart', N'Find a chart in a news article or advert. Describe what it claims and identify one way it could mislead. Please do not post links to unsafe sites.', N'Published', 3, NULL, NULL, NULL, 0),
    (40, 24, N'Game', N'Build a PEEL paragraph', N'Put the sentences in the PEEL order.', N'Published', 1, NULL, NULL, N'Sequence', NULL),
    (41, 25, N'Game', N'Match the citation to its use', N'Pair each citation format with the right situation.', N'Published', 1, NULL, NULL, N'Matching', NULL),
    (42, 25, N'Quiz', N'Check: academic writing', N'Questions on structure and referencing.', N'Published', 2, 10, 3, NULL, NULL),
    (43, 25, N'Discussion', N'Peer feedback on thesis statements', N'Post a draft thesis statement for an essay you are writing. Reply to one classmate with one specific suggestion to make theirs clearer.', N'Published', 3, NULL, NULL, NULL, 0),
    (44, 26, N'Game', N'Good slide or bad slide?', N'Sort each slide choice.', N'Published', 1, NULL, NULL, N'Sort', NULL),
    (45, 27, N'Game', N'Presentation phrases', N'Useful phrases for each part of a talk.', N'Published', 1, NULL, NULL, N'Flashcards', NULL),
    (46, 27, N'SelfAssessment', N'Presentation readiness', N'Rate yourself before your next talk.', N'Published', 2, NULL, NULL, NULL, NULL),
    (47, 28, N'Game', N'Unscramble the Python keywords', N'Use the hint to rebuild each word.', N'Published', 1, NULL, NULL, N'Scramble', NULL),
    (48, 29, N'Game', N'Complete the Python code', N'Type the single missing word.', N'Published', 1, NULL, NULL, N'FillBlank', NULL),
    (49, 29, N'Quiz', N'Check: Python decisions and loops', N'Predict what each snippet does.', N'Published', 2, 10, 3, NULL, NULL),
    (50, 30, N'Game', N'Python vocabulary flashcards', N'Read the term, try to recall its meaning, then flip the card.', N'Published', 1, NULL, NULL, N'Flashcards', NULL),
    (51, 30, N'SelfAssessment', N'Python confidence check', N'How confident are you with each skill?', N'Published', 2, NULL, NULL, NULL, NULL),
    (52, 31, N'Game', N'Match the AI term', N'Pair each term with its plain-language meaning.', N'Published', 1, NULL, NULL, N'Matching', NULL),
    (53, 32, N'Game', N'Put the training workflow in order', N'Arrange the steps from first to last.', N'Published', 1, NULL, NULL, N'Sequence', NULL),
    (54, 32, N'Quiz', N'Check: how models learn', N'Questions on training, testing and accuracy.', N'Published', 2, 10, 3, NULL, NULL),
    (55, 33, N'Game', N'AI myths and facts', N'Decide quickly whether each statement is true or false.', N'Published', 1, NULL, NULL, N'TrueFalse', NULL),
    (56, 33, N'Discussion', N'Where should a human stay in charge?', N'Name one decision (for example exam marking, loan approval or medical diagnosis) where you think a human must always review an AI''s suggestion. Explain why in two or three sentences.', N'Published', 2, NULL, NULL, NULL, 0),
    (57, 34, N'Game', N'Match the network term', N'Pair each term with its meaning.', N'Published', 1, NULL, NULL, N'Matching', NULL),
    (58, 35, N'Game', N'Threat or defence?', N'Sort each item into the right group.', N'Published', 1, NULL, NULL, N'Sort', NULL),
    (59, 35, N'Scenario', N'Working from a cafe', N'You need to submit an assignment and pay a course fee while sitting in a busy cafe. Choose how you connect.', N'Published', 2, NULL, NULL, NULL, NULL),
    (60, 35, N'Quiz', N'Check: network security', N'Six questions on how networks are protected.', N'Published', 3, 10, 3, NULL, NULL),
    (61, 36, N'Game', N'Match the study technique', N'Pair each technique with a description.', N'Published', 1, NULL, NULL, N'Matching', NULL),
    (62, 37, N'SelfAssessment', N'My online learning habits', N'How true is each statement for you?', N'Published', 1, NULL, NULL, NULL, NULL),
    (63, 37, N'Quiz', N'Check: learning online', N'Four questions on effective study.', N'Published', 2, 5, 0, NULL, NULL),
    (64, 38, N'Game', N'Order the revision plan', N'Put the planning steps in a sensible order.', N'Published', 1, NULL, NULL, N'Sequence', NULL),
    (65, 39, N'Game', N'Revision myths', N'True or false?', N'Published', 1, NULL, NULL, N'TrueFalse', NULL),
    (66, 39, N'Discussion', N'Revision tips that worked for you', N'Share one revision technique that actually helped you in a past exam, and when you would not use it.', N'Published', 2, NULL, NULL, NULL, 0),
    (67, 40, N'Game', N'Sort the student''s tasks', N'Place each task in the right box.', N'Published', 1, NULL, NULL, N'Sort', NULL),
    (68, 41, N'Quiz', N'Check: time management', N'Apply the ideas to real situations.', N'Published', 1, 8, 0, NULL, NULL),
    (69, 41, N'SelfAssessment', N'Time management check', N'Rate yourself.', N'Published', 2, NULL, NULL, NULL, NULL),
    (70, 42, N'Game', N'Helpful or risky use of AI?', N'Sort each way of using an AI tool.', N'Published', 1, NULL, NULL, N'Sort', NULL),
    (71, 43, N'Game', N'AI integrity true or false', N'Decide quickly.', N'Published', 1, NULL, NULL, N'TrueFalse', NULL),
    (72, 43, N'Scenario', N'The night before the deadline', N'It is 10 PM and your 1,000-word reflective essay is due at 9 AM. Choose how to use an AI chatbot.', N'Published', 2, NULL, NULL, NULL, NULL),
    (73, 43, N'Quiz', N'Check: responsible AI use', N'Questions on prompts, checking and integrity.', N'Published', 3, 8, 3, NULL, NULL);
SET IDENTITY_INSERT dbo.[Activity] OFF;

SET IDENTITY_INSERT dbo.[QuizQuestion] ON;
INSERT dbo.[QuizQuestion] ([QuestionID], [ActivityID], [QuestionText], [Marks], [SortOrder]) VALUES
    (1, 1, N'Which part of a web page does HTML describe?', 1, 1),
    (2, 1, N'Which tag closes a paragraph?', 1, 2),
    (3, 1, N'Which attribute tells a link where to go?', 1, 3),
    (4, 1, N'Why should every image have alt text?', 2, 4),
    (5, 1, N'Which element creates the largest default heading?', 1, 5),
    (6, 9, N'How many times does for (let i = 0; i < 3; i++) run its body?', 1, 1),
    (7, 9, N'What does the return keyword do?', 1, 2),
    (8, 9, N'Which name best follows the advice for function names?', 1, 3),
    (9, 9, N'What is the value of area(2, 5) if area returns width * height?', 2, 4),
    (10, 14, N'Which password is strongest?', 1, 1),
    (11, 14, N'A message asks for the OTP code just sent to your phone. What should you do?', 2, 2),
    (12, 14, N'Why should you avoid reusing passwords?', 1, 3),
    (13, 14, N'What does two-step verification add?', 1, 4),
    (14, 14, N'Which detail is safest to leave out of a public post?', 1, 5),
    (15, 18, N'A drink sells for NPR 80 and costs NPR 50 to make. What is the contribution per drink?', 1, 1),
    (16, 18, N'Fixed costs are NPR 3,000 a month and contribution is NPR 30 per unit. What is break-even?', 2, 2),
    (17, 18, N'Which cost is variable?', 1, 3),
    (18, 18, N'At the break-even point, profit is', 1, 4),
    (19, 18, N'Rent rises while price and variable cost stay the same. What happens to break-even?', 2, 5),
    (20, 21, N'Under the 50/30/20 rule, how much of NPR 20,000 goes to saving?', 2, 1),
    (21, 21, N'NPR 5,000 earns 10 percent simple interest for one year. What is the interest?', 1, 2),
    (22, 21, N'Which question matters most before borrowing?', 1, 3),
    (23, 21, N'What is the main purpose of a budget?', 1, 4),
    (24, 26, N'Which structure is found in plant cells but not animal cells?', 1, 1),
    (25, 26, N'Where does photosynthesis take place?', 1, 2),
    (26, 26, N'In a fair test, the variable you measure is the', 1, 3),
    (27, 26, N'Why grow several seedlings at each light level?', 2, 4),
    (28, 26, N'What releases energy from food in a cell?', 1, 5),
    (29, 30, N'Which is a sign of a chemical change?', 1, 1),
    (30, 30, N'What is the pH of pure water?', 1, 2),
    (31, 30, N'When balancing equations you may change', 1, 3),
    (32, 30, N'Acid + base gives', 2, 4),
    (33, 30, N'Soap with pH 10 is', 1, 5),
    (34, 34, N'Simplify 6y + 2y - 3y', 1, 1),
    (35, 34, N'Expand 4(x - 2)', 1, 2),
    (36, 34, N'Solve x + 7 = 12', 1, 3),
    (37, 34, N'Solve 2x - 3 = 11', 2, 4),
    (38, 34, N'Solve 5x - 2 = 2x + 10', 2, 5),
    (39, 38, N'Find the mean of 10, 20, 30', 1, 1),
    (40, 38, N'Find the median of 2, 9, 4, 7, 5', 2, 2),
    (41, 38, N'Which average suits house prices with a few mansions?', 1, 3),
    (42, 38, N'A bar chart''s axis starts at 95. What is the risk?', 2, 4),
    (43, 38, N'Two variables rise together. This proves that', 1, 5),
    (44, 42, N'What does a thesis statement do?', 1, 1),
    (45, 42, N'In PEEL, the E after Point stands for', 1, 2),
    (46, 42, N'Which in-text citation shows a direct quotation?', 2, 3),
    (47, 42, N'When should you start your reference list?', 1, 4),
    (48, 49, N'What does range(1, 4) produce?', 1, 1),
    (49, 49, N'Which keyword tests another condition after if?', 1, 2),
    (50, 49, N'What type does input() return?', 1, 3),
    (51, 49, N'If temperature is 25, which message prints in the lesson example?', 2, 4),
    (52, 54, N'Why is some data kept aside for testing?', 2, 1),
    (53, 54, N'What is overfitting?', 1, 2),
    (54, 54, N'In supervised learning, what is a label?', 1, 3),
    (55, 54, N'A model always predicts the most common answer. Why can high accuracy still mislead?', 2, 4),
    (56, 60, N'What does a firewall do?', 1, 1),
    (57, 60, N'What does HTTPS protect?', 1, 2),
    (58, 60, N'Which port does HTTPS usually use?', 1, 3),
    (59, 60, N'What does DNS do?', 1, 4),
    (60, 60, N'What is the safest choice for online banking in a cafe?', 2, 5),
    (61, 63, N'Which technique is retrieval practice?', 1, 1),
    (62, 63, N'What is spaced practice?', 1, 2),
    (63, 63, N'A good focused study block lasts about', 1, 3),
    (64, 63, N'Why mix problem types in one session?', 2, 4),
    (65, 68, N'Revision for next month''s exam belongs in which box?', 2, 1),
    (66, 68, N'How long is one standard Pomodoro?', 1, 2),
    (67, 68, N'What usually happens to important tasks you never schedule?', 1, 3),
    (68, 68, N'Why does a short timed block help?', 1, 4),
    (69, 73, N'Which prompt is most useful for learning?', 2, 1),
    (70, 73, N'What should you do with a reference an AI gives you?', 1, 2),
    (71, 73, N'Who decides what AI use is allowed in your assessments?', 1, 3),
    (72, 73, N'Which information should never be pasted into a public chatbot?', 1, 4);
SET IDENTITY_INSERT dbo.[QuizQuestion] OFF;

SET IDENTITY_INSERT dbo.[QuizOption] ON;
INSERT dbo.[QuizOption] ([OptionID], [QuestionID], [OptionText], [IsCorrect]) VALUES
    (1, 1, N'Its structure and meaning', 1),
    (2, 1, N'The speed of the server', 0),
    (3, 1, N'The database it uses', 0),
    (4, 1, N'Its colours and fonts', 0),
    (5, 2, N'<p/>', 0),
    (6, 2, N'<close p>', 0),
    (7, 2, N'</p>', 1),
    (8, 2, N'<\p>', 0),
    (9, 3, N'link', 0),
    (10, 3, N'href', 1),
    (11, 3, N'alt', 0),
    (12, 3, N'src', 0),
    (13, 4, N'Browsers refuse to show images without it', 0),
    (14, 4, N'So the image appears larger', 0),
    (15, 4, N'So screen readers and slow connections can describe it', 1),
    (16, 4, N'So the image loads faster', 0),
    (17, 5, N'<head>', 0),
    (18, 5, N'<h1>', 1),
    (19, 5, N'<h6>', 0),
    (20, 5, N'<header>', 0),
    (21, 6, N'It never stops', 0),
    (22, 6, N'2', 0),
    (23, 6, N'3', 1),
    (24, 6, N'4', 0),
    (25, 7, N'Deletes a variable', 0),
    (26, 7, N'Sends a value back from a function', 1),
    (27, 7, N'Restarts the loop', 0),
    (28, 7, N'Prints to the screen', 0),
    (29, 8, N'x', 0),
    (30, 8, N'Function1', 0),
    (31, 8, N'calculateTotal', 1),
    (32, 8, N'stuff', 0),
    (33, 9, N'10', 1),
    (34, 9, N'2', 0),
    (35, 9, N'25', 0),
    (36, 9, N'7', 0),
    (37, 10, N'password123', 0),
    (38, 10, N'Momo tastes better on Fridays', 1),
    (39, 10, N'Anita2007', 0),
    (40, 10, N'qwerty', 0),
    (41, 11, N'Forward it to a friend to check', 0),
    (42, 11, N'Never share it; contact the company yourself', 1),
    (43, 11, N'Send it if the message looks official', 0),
    (44, 11, N'Reply asking who they are', 0),
    (45, 12, N'A leak on one site would unlock others', 1),
    (46, 12, N'It makes typing slower', 0),
    (47, 12, N'Sites do not allow it', 0),
    (48, 12, N'It uses more storage', 0),
    (49, 13, N'Faster logins', 0),
    (50, 13, N'A longer username', 0),
    (51, 13, N'Automatic backups', 0),
    (52, 13, N'A second check, such as a code on your phone', 1),
    (53, 14, N'A book you enjoyed', 0),
    (54, 14, N'Your favourite film', 0),
    (55, 14, N'Your daily route to college', 1),
    (56, 14, N'A photo of a sunset', 0),
    (57, 15, N'NPR 30', 1),
    (58, 15, N'NPR 80', 0),
    (59, 15, N'NPR 50', 0),
    (60, 15, N'NPR 130', 0),
    (61, 16, N'30 units', 0),
    (62, 16, N'3,030 units', 0),
    (63, 16, N'90 units', 0),
    (64, 16, N'100 units', 1),
    (65, 17, N'Monthly rent', 0),
    (66, 17, N'Insurance', 0),
    (67, 17, N'A yearly licence', 0),
    (68, 17, N'Ingredients', 1),
    (69, 18, N'Zero', 1),
    (70, 18, N'Equal to revenue', 0),
    (71, 18, N'Equal to fixed costs', 0),
    (72, 18, N'Negative', 0),
    (73, 19, N'It rises', 1),
    (74, 19, N'It stays the same', 0),
    (75, 19, N'It becomes zero', 0),
    (76, 19, N'It falls', 0),
    (77, 20, N'NPR 2,000', 0),
    (78, 20, N'NPR 10,000', 0),
    (79, 20, N'NPR 4,000', 1),
    (80, 20, N'NPR 6,000', 0),
    (81, 21, N'NPR 1,000', 0),
    (82, 21, N'NPR 5,500', 0),
    (83, 21, N'NPR 500', 1),
    (84, 21, N'NPR 50', 0),
    (85, 22, N'Does a friend have one?', 0),
    (86, 22, N'What colour is the card?', 0),
    (87, 22, N'Is the shop busy?', 0),
    (88, 22, N'What is the total I will repay?', 1),
    (89, 23, N'Avoiding all spending', 0),
    (90, 23, N'Planning spending before it happens', 1),
    (91, 23, N'Getting a loan', 0),
    (92, 23, N'Proving you are rich', 0),
    (93, 24, N'Cytoplasm', 0),
    (94, 24, N'Cell wall', 1),
    (95, 24, N'Nucleus', 0),
    (96, 24, N'Cell membrane', 0),
    (97, 25, N'Chloroplasts', 1),
    (98, 25, N'Nucleus', 0),
    (99, 25, N'Membrane', 0),
    (100, 25, N'Mitochondria', 0),
    (101, 26, N'Dependent variable', 1),
    (102, 26, N'Independent variable', 0),
    (103, 26, N'Control variable', 0),
    (104, 26, N'Random variable', 0),
    (105, 27, N'To make the test faster', 0),
    (106, 27, N'To reduce the effect of one unusual plant', 1),
    (107, 27, N'To use up the seeds', 0),
    (108, 27, N'Because one seedling is not allowed', 0),
    (109, 28, N'Mitochondria', 1),
    (110, 28, N'Chloroplast', 0),
    (111, 28, N'Cell wall', 0),
    (112, 28, N'Vacuole', 0),
    (113, 29, N'Sugar dissolves', 0),
    (114, 29, N'Ice melts', 0),
    (115, 29, N'A new substance forms', 1),
    (116, 29, N'Paper is cut', 0),
    (117, 30, N'1', 0),
    (118, 30, N'14', 0),
    (119, 30, N'7', 1),
    (120, 30, N'0', 0),
    (121, 31, N'The element symbols', 0),
    (122, 31, N'The coefficients in front of formulas', 1),
    (123, 31, N'The small numbers inside formulas', 0),
    (124, 31, N'Nothing at all', 0),
    (125, 32, N'Only gas', 0),
    (126, 32, N'A stronger acid', 0),
    (127, 32, N'Pure oxygen', 0),
    (128, 32, N'Salt and water', 1),
    (129, 33, N'Alkaline', 1),
    (130, 33, N'Acidic', 0),
    (131, 33, N'Neutral', 0),
    (132, 33, N'Impossible', 0),
    (133, 34, N'5', 0),
    (134, 34, N'8y', 0),
    (135, 34, N'5y', 1),
    (136, 34, N'11y', 0),
    (137, 35, N'4x + 8', 0),
    (138, 35, N'4x - 8', 1),
    (139, 35, N'4x - 2', 0),
    (140, 35, N'x - 8', 0),
    (141, 36, N'5', 1),
    (142, 36, N'12', 0),
    (143, 36, N'7', 0),
    (144, 36, N'19', 0),
    (145, 37, N'8', 0),
    (146, 37, N'14', 0),
    (147, 37, N'7', 1),
    (148, 37, N'4', 0),
    (149, 38, N'2', 0),
    (150, 38, N'6', 0),
    (151, 38, N'4', 1),
    (152, 38, N'12', 0),
    (153, 39, N'10', 0),
    (154, 39, N'20', 1),
    (155, 39, N'60', 0),
    (156, 39, N'30', 0),
    (157, 40, N'5', 1),
    (158, 40, N'9', 0),
    (159, 40, N'4', 0),
    (160, 40, N'7', 0),
    (161, 41, N'Mean', 0),
    (162, 41, N'Total', 0),
    (163, 41, N'Range', 0),
    (164, 41, N'Median', 1),
    (165, 42, N'Totals change', 0),
    (166, 42, N'Nothing at all', 0),
    (167, 42, N'Small differences look exaggerated', 1),
    (168, 42, N'Bars become hidden', 0),
    (169, 43, N'One causes the other', 0),
    (170, 43, N'The data is wrong', 0),
    (171, 43, N'Both are outliers', 0),
    (172, 43, N'Nothing on its own; it shows correlation only', 1),
    (173, 44, N'States the essay''s main argument', 1),
    (174, 44, N'Gives the title page', 0),
    (175, 44, N'Ends the essay', 0),
    (176, 44, N'Lists every source', 0),
    (177, 45, N'Evidence', 1),
    (178, 45, N'Essay', 0),
    (179, 45, N'Example only', 0),
    (180, 45, N'Ending', 0),
    (181, 46, N'[Sharma]', 0),
    (182, 46, N'(Sharma, 2022)', 0),
    (183, 46, N'Sharma 2022', 0),
    (184, 46, N'(Sharma, 2022, p. 14)', 1),
    (185, 47, N'While you research', 1),
    (186, 47, N'The night before the deadline', 0),
    (187, 47, N'After submitting', 0),
    (188, 47, N'Only if asked', 0),
    (189, 48, N'1, 2, 3', 1),
    (190, 48, N'1, 2, 3, 4', 0),
    (191, 48, N'4', 0),
    (192, 48, N'0, 1, 2, 3', 0),
    (193, 49, N'else if', 0),
    (194, 49, N'elif', 1),
    (195, 49, N'then', 0),
    (196, 49, N'elseif', 0),
    (197, 50, N'Nothing', 0),
    (198, 50, N'Always a whole number', 0),
    (199, 50, N'Text (a string)', 1),
    (200, 50, N'A list', 0);
INSERT dbo.[QuizOption] ([OptionID], [QuestionID], [OptionText], [IsCorrect]) VALUES
    (201, 51, N'Take a jacket', 0),
    (202, 51, N'Pleasant day', 1),
    (203, 51, N'Nothing prints', 0),
    (204, 51, N'Stay in the shade', 0),
    (205, 52, N'To check how the model performs on examples it has not seen', 1),
    (206, 52, N'To make training faster', 0),
    (207, 52, N'Because the model cannot use all the data', 0),
    (208, 52, N'To store a backup copy', 0),
    (209, 53, N'Memorising training data but failing on new data', 1),
    (210, 53, N'Giving every example the same label', 0),
    (211, 53, N'Training for too few seconds', 0),
    (212, 53, N'Using too little memory', 0),
    (213, 54, N'The name of the programmer', 0),
    (214, 54, N'The correct answer attached to an example', 1),
    (215, 54, N'The colour of a chart', 0),
    (216, 54, N'The file size of the data', 0),
    (217, 55, N'It may never find the rare cases that matter', 1),
    (218, 55, N'Common answers are not allowed', 0),
    (219, 55, N'It makes the model slower', 0),
    (220, 55, N'Accuracy is always wrong', 0),
    (221, 56, N'Stores passwords', 0),
    (222, 56, N'Charges your laptop', 0),
    (223, 56, N'Blocks traffic that breaks its rules', 1),
    (224, 56, N'Speeds up the internet', 0),
    (225, 57, N'The website''s honesty', 0),
    (226, 57, N'Your phone battery', 0),
    (227, 57, N'Data travelling between your browser and the website', 1),
    (228, 57, N'Your files on the hard drive', 0),
    (229, 58, N'443', 1),
    (230, 58, N'8', 0),
    (231, 58, N'21', 0),
    (232, 58, N'80', 0),
    (233, 59, N'Prints documents', 0),
    (234, 59, N'Blocks malware', 0),
    (235, 59, N'Turns a website name into an IP address', 1),
    (236, 59, N'Encrypts packets', 0),
    (237, 60, N'Any open network', 0),
    (238, 60, N'Your own mobile data', 1),
    (239, 60, N'The network with the strongest signal', 0),
    (240, 60, N'A network named FREE_WIFI', 0),
    (241, 61, N'Rereading notes', 0),
    (242, 61, N'Copying the slides', 0),
    (243, 61, N'Writing what you remember before checking', 1),
    (244, 61, N'Highlighting the textbook', 0),
    (245, 62, N'Taking long breaks from learning', 0),
    (246, 62, N'Reviewing after increasing gaps', 1),
    (247, 62, N'Studying in a large room', 0),
    (248, 62, N'Studying everything in one night', 0),
    (249, 63, N'As long as possible', 0),
    (250, 63, N'5 minutes', 0),
    (251, 63, N'25 to 45 minutes', 1),
    (252, 63, N'4 hours without a break', 0),
    (253, 64, N'It is faster to mark', 0),
    (254, 64, N'It helps you learn to choose the right method', 1),
    (255, 64, N'Teachers prefer it', 0),
    (256, 64, N'It avoids using a calculator', 0),
    (257, 65, N'Urgent, not important', 0),
    (258, 65, N'Neither', 0),
    (259, 65, N'Important, not urgent', 1),
    (260, 65, N'Urgent and important', 0),
    (261, 66, N'25 minutes', 1),
    (262, 66, N'45 seconds', 0),
    (263, 66, N'5 minutes', 0),
    (264, 66, N'2 hours', 0),
    (265, 67, N'They become unimportant', 0),
    (266, 67, N'Someone else does them', 0),
    (267, 67, N'They become urgent', 1),
    (268, 67, N'They disappear', 0),
    (269, 68, N'It replaces breaks', 0),
    (270, 68, N'It removes deadlines', 0),
    (271, 68, N'It makes starting easier', 1),
    (272, 68, N'It makes tasks shorter', 0),
    (273, 69, N'Write my essay', 0),
    (274, 69, N'Do my homework', 0),
    (275, 69, N'Say something about plants', 0),
    (276, 69, N'Quiz me on photosynthesis one question at a time', 1),
    (277, 70, N'Ignore all references', 0),
    (278, 70, N'Ask the AI if it is real', 0),
    (279, 70, N'Find and read the source yourself', 1),
    (280, 70, N'Copy it straight into your work', 0),
    (281, 71, N'The AI company', 0),
    (282, 71, N'Your college and lecturer', 1),
    (283, 71, N'Your friends', 0),
    (284, 71, N'Nobody', 0),
    (285, 72, N'A general science question', 0),
    (286, 72, N'Other people''s personal data', 1),
    (287, 72, N'A definition you want explained', 0),
    (288, 72, N'A request for a study plan', 0);
SET IDENTITY_INSERT dbo.[QuizOption] OFF;

SET IDENTITY_INSERT dbo.[SAStatement] ON;
INSERT dbo.[SAStatement] ([StatementID], [ActivityID], [StatementText], [SortOrder]) VALUES
    (1, 5, N'I can write a page with headings, paragraphs and lists.', 1),
    (2, 5, N'I can add links and images with suitable alt text.', 2),
    (3, 5, N'I can style elements using classes.', 3),
    (4, 5, N'I can explain padding, border and margin.', 4),
    (5, 5, N'I can make a layout change on small screens with a media query.', 5),
    (6, 22, N'I know roughly how much I spend each month.', 1),
    (7, 22, N'I set aside some money for saving.', 2),
    (8, 22, N'I understand the cost of borrowing before I agree to it.', 3),
    (9, 22, N'I can tell the difference between needs and wants when shopping.', 4),
    (10, 25, N'I can identify the independent variable in an investigation.', 1),
    (11, 25, N'I can choose a measurable dependent variable and state its units.', 2),
    (12, 25, N'I can explain which variables must be kept the same.', 3),
    (13, 25, N'I can explain why repeated measurements improve reliability.', 4),
    (14, 35, N'I can collect like terms in an expression.', 1),
    (15, 35, N'I can expand a single bracket.', 2),
    (16, 35, N'I can solve a two-step equation.', 3),
    (17, 35, N'I can check my answer by substituting it back.', 4),
    (18, 46, N'I can open a talk in a way that gets attention.', 1),
    (19, 46, N'I can keep slides simple and readable.', 2),
    (20, 46, N'I can control my pace and pause for effect.', 3),
    (21, 46, N'I can answer questions calmly, even when unsure.', 4),
    (22, 51, N'I can use print and input to talk to the user.', 1),
    (23, 51, N'I can write if, elif and else blocks with correct indentation.', 2),
    (24, 51, N'I can use a for loop with range.', 3),
    (25, 51, N'I can write a function that returns a value.', 4),
    (26, 62, N'I have a regular time for studying each week.', 1),
    (27, 62, N'I test myself instead of only rereading.', 2),
    (28, 62, N'I study without my phone distracting me.', 3),
    (29, 62, N'I review my results and revisit weak topics.', 4),
    (30, 69, N'I know which of my tasks are important but not urgent.', 1),
    (31, 69, N'I schedule study time before deadlines become urgent.', 2),
    (32, 69, N'I can start a task even when I do not feel motivated.', 3);
SET IDENTITY_INSERT dbo.[SAStatement] OFF;

SET IDENTITY_INSERT dbo.[GameGroup] ON;
INSERT dbo.[GameGroup] ([GroupID], [ActivityID], [GroupName]) VALUES
    (1, 3, N'Text'),
    (2, 3, N'Box'),
    (3, 12, N'Safe'),
    (4, 12, N'Suspicious'),
    (5, 17, N'Fixed costs'),
    (6, 17, N'Variable costs'),
    (7, 19, N'Needs'),
    (8, 19, N'Wants'),
    (9, 27, N'Physical'),
    (10, 27, N'Chemical'),
    (11, 44, N'Good practice'),
    (12, 44, N'Avoid'),
    (13, 58, N'Threat'),
    (14, 58, N'Defence'),
    (15, 67, N'Do now'),
    (16, 67, N'Schedule'),
    (17, 67, N'Limit'),
    (18, 67, N'Drop'),
    (19, 70, N'Helpful'),
    (20, 70, N'Risky');
SET IDENTITY_INSERT dbo.[GameGroup] OFF;

SET IDENTITY_INSERT dbo.[GameItem] ON;
INSERT dbo.[GameItem] ([ItemID], [ActivityID], [GroupID], [ItemText], [MatchText]) VALUES
    (1, 2, NULL, N'<h1>', N'Main heading of the page'),
    (2, 2, NULL, N'<p>', N'A paragraph of text'),
    (3, 2, NULL, N'<a>', N'A link to another page'),
    (4, 2, NULL, N'<img>', N'An image with alt text'),
    (5, 2, NULL, N'<ul>', N'A bulleted list'),
    (6, 2, NULL, N'<li>', N'One item inside a list'),
    (7, 3, 1, N'color', NULL),
    (8, 3, 1, N'font-size', NULL),
    (9, 3, 1, N'text-align', NULL),
    (10, 3, 1, N'font-weight', NULL),
    (11, 3, 2, N'padding', NULL),
    (12, 3, 2, N'margin', NULL),
    (13, 3, 2, N'border', NULL),
    (14, 3, 2, N'width', NULL),
    (15, 4, NULL, N'selector', N'In the rule h1 { color: red; } the part h1 is called the ___.'),
    (16, 4, NULL, N'padding', N'The space between an element''s content and its border is called ___.'),
    (17, 4, NULL, N'class', N'To style several paragraphs the same way, give them the same ___ attribute.'),
    (18, 4, NULL, N'external', N'A separate .css file linked from the page head is an ___ stylesheet.'),
    (19, 7, NULL, N'True', N'let and const both create variables.'),
    (20, 7, NULL, N'False', N'A single = sign compares two values.'),
    (21, 7, NULL, N'True', N'Text values called strings are written inside quotes.'),
    (22, 7, NULL, N'False', N'JavaScript can only run on a web server, never in the browser.'),
    (23, 7, NULL, N'True', N'An else block runs when the if condition is false.'),
    (24, 7, NULL, N'False', N'const values can be changed later in the program.'),
    (25, 8, NULL, N'The function is defined with its name and parameters', N'1'),
    (26, 8, NULL, N'The program calls the function with arguments', N'2'),
    (27, 8, NULL, N'The arguments are copied into the parameters', N'3'),
    (28, 8, NULL, N'The code inside the function body runs', N'4'),
    (29, 8, NULL, N'The return value is sent back to the caller', N'5'),
    (30, 11, NULL, N'Phishing', N'A fake message that tricks you into sharing details'),
    (31, 11, NULL, N'2FA', N'A second check after your password'),
    (32, 11, NULL, N'Malware', N'Software designed to cause harm'),
    (33, 11, NULL, N'Password manager', N'An app that stores unique passwords'),
    (34, 11, NULL, N'Software update', N'A fix that closes security holes'),
    (35, 11, NULL, N'Backup', N'A spare copy of your files'),
    (36, 12, 4, N'An SMS asks for your OTP to stop a delivery', NULL),
    (37, 12, 4, N'A friend''s new account asks you to send money urgently', NULL),
    (38, 12, 4, N'A link to esewa-verify-account.xyz', NULL),
    (39, 12, 3, N'You open your bank app yourself to check a payment', NULL),
    (40, 12, 3, N'Your college emails a timetable you were expecting', NULL),
    (41, 12, 3, N'A software update offered inside your phone settings', NULL),
    (42, 16, NULL, N'Value proposition', N'A clear statement of who you help and how'),
    (43, 16, NULL, N'Customer segment', N'A group of customers with similar needs'),
    (44, 16, NULL, N'Revenue', N'Money received from sales'),
    (45, 16, NULL, N'Profit', N'Revenue left after all costs are paid'),
    (46, 16, NULL, N'Prototype', N'A simple early version used for testing'),
    (47, 17, 5, N'Monthly stall rent', NULL),
    (48, 17, 5, N'Annual trading licence', NULL),
    (49, 17, 5, N'Insurance premium', NULL),
    (50, 17, 6, N'Bread for each sandwich', NULL),
    (51, 17, 6, N'Packaging for each sale', NULL),
    (52, 17, 6, N'Fillings and sauces', NULL),
    (53, 19, 7, N'Hostel rent', NULL),
    (54, 19, 7, N'Bus fare to college', NULL),
    (55, 19, 7, N'Rice and vegetables', NULL),
    (56, 19, 8, N'Concert ticket', NULL),
    (57, 19, 8, N'New headphones', NULL),
    (58, 19, 8, N'Weekend restaurant meal', NULL),
    (59, 20, NULL, N'True', N'Compound interest pays interest on earlier interest.'),
    (60, 20, NULL, N'False', N'A budget is only useful for people with high incomes.'),
    (61, 20, NULL, N'True', N'Missing a loan payment can add extra charges.'),
    (62, 20, NULL, N'False', N'Wants should always take 50 percent of income.'),
    (63, 20, NULL, N'True', N'Tracking small daily spending can reveal big monthly totals.'),
    (64, 23, NULL, N'Nucleus', N'Contains genetic material'),
    (65, 23, NULL, N'Cell membrane', N'Controls what enters and leaves'),
    (66, 23, NULL, N'Cell wall', N'Supports a plant cell'),
    (67, 23, NULL, N'Chloroplast', N'Absorbs light for photosynthesis'),
    (68, 23, NULL, N'Mitochondria', N'Releases energy in respiration'),
    (69, 23, NULL, N'Vacuole', N'Stores cell sap'),
    (70, 24, NULL, N'nucleus', N'Holds the cell''s DNA'),
    (71, 24, NULL, N'membrane', N'Boundary controlling movement into a cell'),
    (72, 24, NULL, N'cytoplasm', N'Jelly where reactions happen'),
    (73, 24, NULL, N'vacuole', N'Space filled with cell sap'),
    (74, 27, 9, N'Ice melting in a glass', NULL),
    (75, 27, 9, N'Salt dissolving in water', NULL),
    (76, 27, 9, N'Chopping vegetables', NULL),
    (77, 27, 10, N'Iron gate rusting', NULL),
    (78, 27, 10, N'Cooking an egg', NULL),
    (79, 27, 10, N'Burning cooking gas', NULL),
    (80, 28, NULL, N'Write the word equation', N'1'),
    (81, 28, NULL, N'Write the formulas of each substance', N'2'),
    (82, 28, NULL, N'Count the atoms of each element on both sides', N'3'),
    (83, 28, NULL, N'Add coefficients to balance one element at a time', N'4'),
    (84, 28, NULL, N'Check every element is balanced', N'5'),
    (85, 29, NULL, N'neutral', N'A substance with a pH of exactly 7 is ___.'),
    (86, 29, NULL, N'indicator', N'A substance that changes colour with pH is called an ___.'),
    (87, 29, NULL, N'salt', N'Acid plus base gives a ___ and water.'),
    (88, 29, NULL, N'coefficient', N'The big number written in front of a formula is a ___.'),
    (89, 31, NULL, N'Term', N'5x'),
    (90, 31, NULL, N'Expression', N'2a + 7'),
    (91, 31, NULL, N'Equation', N'3x + 1 = 10'),
    (92, 31, NULL, N'Coefficient', N'The 4 in 4y'),
    (93, 31, NULL, N'Constant', N'The 9 in x + 9'),
    (94, 32, NULL, N'7x', N'3x + 4x simplifies to ___.'),
    (95, 32, NULL, N'5a', N'8a - 3a simplifies to ___.'),
    (96, 32, NULL, N'2x + 6', N'2(x + 3) expands to ___.'),
    (97, 32, NULL, N'12', N'If x = 4, then 3x equals ___.'),
    (98, 33, NULL, N'Write the equation 4x + 3 = 19', N'1'),
    (99, 33, NULL, N'Subtract 3 from both sides to get 4x = 16', N'2'),
    (100, 33, NULL, N'Divide both sides by 4 to get x = 4', N'3'),
    (101, 33, NULL, N'Check: 4 times 4 plus 3 equals 19', N'4'),
    (102, 36, NULL, N'True', N'The median of 3, 5, 9 is 5.'),
    (103, 36, NULL, N'False', N'The mode is always the largest value.'),
    (104, 36, NULL, N'True', N'One extreme value can pull the mean a long way.'),
    (105, 36, NULL, N'False', N'The range of 2, 6, 10 is 6.'),
    (106, 36, NULL, N'True', N'The mean of 2, 4, 6 is 4.'),
    (107, 37, NULL, N'Outlier', N'A value far from the rest of the data'),
    (108, 37, NULL, N'Correlation', N'A relationship where two variables change together'),
    (109, 37, NULL, N'Sample', N'A smaller group chosen from a population'),
    (110, 37, NULL, N'Bias', N'A systematic error that skews results'),
    (111, 37, NULL, N'Range', N'Largest value minus smallest value'),
    (112, 40, NULL, N'Point: Group projects build communication skills.', N'1'),
    (113, 40, NULL, N'Evidence: In a 2023 survey, 68 percent of employers valued teamwork experience.', N'2'),
    (114, 40, NULL, N'Explain: Working in groups gives students practice in agreeing roles and deadlines.', N'3'),
    (115, 40, NULL, N'Link: These skills support the wider argument that coursework prepares students for work.', N'4'),
    (116, 41, NULL, N'(Sharma, 2022)', N'Paraphrasing one author'),
    (117, 41, NULL, N'(Sharma, 2022, p. 14)', N'Quoting directly from a page'),
    (118, 41, NULL, N'(Tan & Rai, 2021)', N'Citing two authors'),
    (119, 41, NULL, N'Reference list', N'Full details of every source at the end'),
    (120, 44, 11, N'One clear idea per slide', NULL),
    (121, 44, 11, N'A chart with a clear title', NULL),
    (122, 44, 11, N'Text large enough to read from the back', NULL),
    (123, 44, 12, N'Paragraphs copied from the report', NULL),
    (124, 44, 12, N'Five fonts on one slide', NULL),
    (125, 44, 12, N'Reading every word aloud', NULL),
    (126, 45, NULL, N'Opening a talk', N'Today I will show you three ways to...'),
    (127, 45, NULL, N'Moving on', N'That brings me to my second point.'),
    (128, 45, NULL, N'Giving an example', N'To give you a real example...'),
    (129, 45, NULL, N'Summarising', N'To sum up, the key message is...'),
    (130, 45, NULL, N'Inviting questions', N'I am happy to take any questions now.'),
    (131, 47, NULL, N'print', N'Shows a value on the screen'),
    (132, 47, NULL, N'input', N'Reads text typed by the user'),
    (133, 47, NULL, N'while', N'Repeats while a condition is true'),
    (134, 47, NULL, N'return', N'Sends a value back from a function'),
    (135, 47, NULL, N'import', N'Loads a module such as math'),
    (136, 48, NULL, N'elif', N'Use ___ to test a second condition after an if.'),
    (137, 48, NULL, N'range', N'for i in ___(5): repeats five times.'),
    (138, 48, NULL, N'int', N'Convert typed text to a whole number with ___(text).'),
    (139, 48, NULL, N'def', N'Start a function definition with the keyword ___.'),
    (140, 50, NULL, N'Variable', N'A name that stores a value'),
    (141, 50, NULL, N'String', N'A piece of text in quotes'),
    (142, 50, NULL, N'List', N'An ordered collection such as [1, 2, 3]'),
    (143, 50, NULL, N'Function', N'A named block of reusable code'),
    (144, 50, NULL, N'Loop', N'Code that repeats'),
    (145, 50, NULL, N'Index', N'The position of an item, starting from 0'),
    (146, 52, NULL, N'Model', N'The trained program that makes predictions'),
    (147, 52, NULL, N'Training data', N'Labelled examples the model learns from'),
    (148, 52, NULL, N'Label', N'The correct answer attached to an example'),
    (149, 52, NULL, N'Prediction', N'The model''s answer for a new example'),
    (150, 52, NULL, N'Bias', N'A systematic unfairness learned from the data'),
    (151, 53, NULL, N'Collect example data', N'1'),
    (152, 53, NULL, N'Label each example with the correct answer', N'2'),
    (153, 53, NULL, N'Split the data into training and test sets', N'3'),
    (154, 53, NULL, N'Train the model on the training set', N'4'),
    (155, 53, NULL, N'Measure accuracy on the unseen test set', N'5'),
    (156, 55, NULL, N'False', N'AI systems understand the world exactly as humans do.'),
    (157, 55, NULL, N'True', N'A model can only learn patterns that appear in its data.'),
    (158, 55, NULL, N'True', N'Chatbots can state false information confidently.'),
    (159, 55, NULL, N'False', N'If a model is 95 percent accurate it is always useful.'),
    (160, 55, NULL, N'True', N'Biased training data can lead to unfair predictions.'),
    (161, 55, NULL, N'False', N'Today''s AI systems can do any task a human can do.'),
    (162, 57, NULL, N'IP address', N'Identifies a device on a network'),
    (163, 57, NULL, N'Port', N'Identifies a service on a device'),
    (164, 57, NULL, N'Router', N'Forwards packets between networks'),
    (165, 57, NULL, N'DNS', N'Turns website names into IP addresses'),
    (166, 57, NULL, N'Packet', N'A small piece of data sent across a network'),
    (167, 58, 13, N'Fake Wi-Fi hotspot with a free name', NULL),
    (168, 58, 13, N'Default router password left unchanged', NULL),
    (169, 58, 13, N'Malware in a pirated app', NULL),
    (170, 58, 14, N'Firewall blocking unknown traffic', NULL),
    (171, 58, 14, N'HTTPS encryption', NULL),
    (172, 58, 14, N'Regular software updates', NULL),
    (173, 61, NULL, N'Retrieval practice', N'Recalling information without looking'),
    (174, 61, NULL, N'Spaced practice', N'Reviewing after growing gaps of time'),
    (175, 61, NULL, N'Interleaving', N'Mixing different problem types'),
    (176, 61, NULL, N'Elaboration', N'Explaining how ideas connect'),
    (177, 64, NULL, N'List all topics for each exam', N'1'),
    (178, 64, NULL, N'Rate each topic red, amber or green', N'2'),
    (179, 64, NULL, N'Count the days until each exam', N'3'),
    (180, 64, NULL, N'Schedule weak topics first and most often', N'4'),
    (181, 64, NULL, N'Review the plan at the end of each week', N'5'),
    (182, 65, NULL, N'False', N'Cramming the night before is the best strategy.'),
    (183, 65, NULL, N'True', N'Timed past papers help you manage exam time.'),
    (184, 65, NULL, N'True', N'Sleep helps the brain store what you learned.'),
    (185, 65, NULL, N'False', N'Highlighting is the most effective revision method.'),
    (186, 65, NULL, N'True', N'Revisiting mistakes is a good use of revision time.'),
    (187, 67, 15, N'Assignment due tomorrow morning', NULL),
    (188, 67, 16, N'Exam revision for next month', NULL),
    (189, 67, 17, N'Reply to a group chat meme', NULL),
    (190, 67, 18, N'Scrolling videos for an hour', NULL),
    (191, 67, 16, N'Book a library study room for next week', NULL),
    (192, 67, 15, N'Fix a broken laptop charger before class', NULL),
    (193, 67, 17, N'Answer a shop''s promotional message', NULL),
    (194, 67, 18, N'Rewatching a series you have already seen', NULL),
    (195, 70, 19, N'Ask it to quiz you on a topic', NULL),
    (196, 70, 19, N'Ask it to explain feedback you received', NULL),
    (197, 70, 19, N'Ask for a study plan for the next two weeks', NULL),
    (198, 70, 20, N'Submit its essay as your own work', NULL),
    (199, 70, 20, N'Copy its references without checking them', NULL),
    (200, 70, 20, N'Paste a classmate''s personal data into it', NULL);
INSERT dbo.[GameItem] ([ItemID], [ActivityID], [GroupID], [ItemText], [MatchText]) VALUES
    (201, 71, NULL, N'True', N'AI tools can invent references that do not exist.'),
    (202, 71, NULL, N'False', N'Text produced by AI is always factually correct.'),
    (203, 71, NULL, N'True', N'You should check your college''s AI policy before using it in assessed work.'),
    (204, 71, NULL, N'False', N'Pasting personal data into a public chatbot is always safe.'),
    (205, 71, NULL, N'True', N'Asking an AI to quiz you is a form of retrieval practice.');
SET IDENTITY_INSERT dbo.[GameItem] OFF;

SET IDENTITY_INSERT dbo.[SimStep] ON;
INSERT dbo.[SimStep] ([StepID], [ActivityID], [StepText], [ImagePath], [ImageAlt], [IsEnding], [Outcome], [Feedback]) VALUES
    (1, 13, N'The message reads: "Your Inkwell College account will be deactivated at 5 PM today. Sign in now at inkwell-college-login.info to keep your files." What do you do first?', N'~/Uploads/Images/bd8397a2-c8e1-591e-8ba5-73c0193191e9.png', N'A phone screen showing an urgent text message with an unfamiliar link.', 0, NULL, NULL),
    (2, 13, N'You open the real college portal from your bookmark. There is no warning about your account. What next?', NULL, NULL, 0, NULL, NULL),
    (3, 13, N'The page looks like the college login, so you type your email and password. A moment later, you get an alert that your password was changed.', NULL, NULL, 1, N'Poor', N'You entered your password on a fake page. Immediately reset your password from the official site, turn on two-step verification and tell the IT help desk so they can warn others.'),
    (4, 13, N'You avoided the trap, but nobody at the college knows this message is going around.', NULL, NULL, 1, N'Acceptable', N'You kept your account safe. Reporting suspicious messages helps the IT team block the fake site and protect other students.'),
    (5, 13, N'The help desk thanks you, blocks the fake address and sends a warning to all students the same afternoon.', NULL, NULL, 1, N'Best', N'You checked through a trusted route and reported the message. Urgency is a pressure tactic, and verifying first is always the right move.'),
    (6, 59, N'Two networks appear: "Cafe_Guest" (password on the menu) and "FREE_FAST_WIFI" (no password). Which do you join?', NULL, NULL, 0, NULL, NULL),
    (7, 59, N'The open network shows a login page asking for your email password before you can browse.', NULL, NULL, 0, NULL, NULL),
    (8, 59, N'You are on the cafe''s real network. The payment page shows https and a padlock.', NULL, NULL, 0, NULL, NULL),
    (9, 59, N'You use your own mobile data for anything sensitive. Everything goes through without problems.', NULL, NULL, 1, N'Best', N'Mobile data or a trusted network is the safest choice for payments and passwords. You avoided the risks of shared Wi-Fi entirely.'),
    (10, 59, N'Your email password is now in the hands of whoever runs the fake hotspot.', NULL, NULL, 1, N'Poor', N'Open networks with tempting names are a common trap. Change your email password now from a trusted connection and turn on two-step verification.'),
    (11, 59, N'The payment works over an encrypted HTTPS connection on a network you checked.', NULL, NULL, 1, N'Acceptable', N'You checked the network name and used HTTPS, which is reasonable. Mobile data would still be safer for payments.'),
    (12, 72, N'You have notes and a rough outline but no draft. A friend says, "Just get the AI to write it." What do you do?', NULL, NULL, 0, NULL, NULL),
    (13, 72, N'The essay looks polished. You notice it mentions a project you never did and cites a book you cannot find anywhere.', NULL, NULL, 0, NULL, NULL),
    (14, 72, N'The AI asks you questions about your experience and suggests a paragraph order. You write the paragraphs yourself.', NULL, NULL, 0, NULL, NULL),
    (15, 72, N'You write steadily from your notes and finish by 1 AM. The essay is a little rough, but it is your own work.', NULL, NULL, 1, N'Acceptable', N'Writing it yourself is always acceptable. Next time, starting earlier would leave time to revise, and an AI study partner could have helped you plan faster.'),
    (16, 72, N'Your lecturer finds that the reflection describes events that did not happen and references a book that does not exist.', NULL, NULL, 1, N'Poor', N'Submitting AI-written work as your own breaks academic integrity rules, and invented details are easy to spot. Speak to your lecturer and be honest about what happened.'),
    (17, 72, N'You submit your own essay with a one-line statement: AI was used to suggest the order of paragraphs.', NULL, NULL, 1, N'Best', N'You used AI as a planning tutor, wrote the work yourself and were transparent. This is exactly how responsible use looks.'),
    (18, 72, N'The work is yours, but you did not disclose the AI help your college asks students to declare.', NULL, NULL, 1, N'Acceptable', N'Your writing is your own, which matters most. Check your college''s rules: many require a short statement of how AI was used.');
SET IDENTITY_INSERT dbo.[SimStep] OFF;

SET IDENTITY_INSERT dbo.[SimChoice] ON;
INSERT dbo.[SimChoice] ([ChoiceID], [FromStepID], [NextStepID], [ChoiceText]) VALUES
    (1, 1, 2, N'Open the college website from my own bookmark'),
    (2, 1, 3, N'Tap the link and sign in quickly'),
    (3, 1, 4, N'Delete the message and forget about it'),
    (4, 2, 5, N'Report the message to the college IT help desk'),
    (5, 2, 4, N'Ignore it now that I know it is fake'),
    (6, 6, 7, N'FREE_FAST_WIFI, it is faster'),
    (7, 6, 8, N'Cafe_Guest, after checking the name with staff'),
    (8, 6, 9, N'Neither, I use my phone''s mobile data'),
    (9, 7, 10, N'Enter my email password'),
    (10, 7, 8, N'Disconnect and ask the staff'),
    (11, 8, 11, N'Pay the fee and submit my assignment'),
    (12, 8, 9, N'Submit the assignment and pay later on mobile data'),
    (13, 12, 13, N'Ask the AI to write the whole essay'),
    (14, 12, 14, N'Ask the AI to help me turn my outline into a plan'),
    (15, 12, 15, N'Close the chatbot and write from my notes'),
    (16, 13, 16, N'Submit it anyway'),
    (17, 13, 14, N'Delete it and start from my own outline'),
    (18, 14, 17, N'Add a short note explaining how I used AI'),
    (19, 14, 18, N'Submit without mentioning it');
SET IDENTITY_INSERT dbo.[SimChoice] OFF;

-- Learner journeys: enrolments, completed lessons and submitted attempts at different stages.
INSERT dbo.[Enrolment] ([LearnerID], [CourseID], [EnrolDate]) VALUES
    (9, 16, DATEADD(minute, 540, DATEADD(day, -30, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (9, 1, DATEADD(minute, 540, DATEADD(day, -26, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (9, 3, DATEADD(minute, 540, DATEADD(day, -22, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (9, 4, DATEADD(minute, 540, DATEADD(day, -18, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (9, 6, DATEADD(minute, 540, DATEADD(day, -14, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (9, 2, DATEADD(minute, 540, DATEADD(day, -12, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (9, 17, DATEADD(minute, 540, DATEADD(day, -13, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (10, 1, DATEADD(minute, 540, DATEADD(day, -28, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (10, 4, DATEADD(minute, 540, DATEADD(day, -25, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (10, 9, DATEADD(minute, 540, DATEADD(day, -20, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (10, 17, DATEADD(minute, 540, DATEADD(day, -16, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (11, 3, DATEADD(minute, 540, DATEADD(day, -24, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (11, 11, DATEADD(minute, 540, DATEADD(day, -21, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (11, 13, DATEADD(minute, 540, DATEADD(day, -17, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (11, 14, DATEADD(minute, 540, DATEADD(day, -9, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (11, 15, DATEADD(minute, 540, DATEADD(day, -5, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (12, 6, DATEADD(minute, 540, DATEADD(day, -27, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (12, 7, DATEADD(minute, 540, DATEADD(day, -15, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (12, 12, DATEADD(minute, 540, DATEADD(day, -13, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (12, 18, DATEADD(minute, 540, DATEADD(day, -11, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (12, 9, DATEADD(minute, 540, DATEADD(day, -10, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (12, 10, DATEADD(minute, 540, DATEADD(day, -8, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (12, 14, DATEADD(minute, 540, DATEADD(day, -5, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (12, 17, DATEADD(minute, 540, DATEADD(day, -9, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0)))));

INSERT dbo.[MaterialCompletion] ([LearnerID], [MaterialID], [CompletedDate]) VALUES
    (9, 61, DATEADD(minute, 480, DATEADD(day, -0, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (9, 62, DATEADD(minute, 547, DATEADD(day, -1, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (9, 63, DATEADD(minute, 681, DATEADD(day, -3, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (9, 1, DATEADD(minute, 480, DATEADD(day, -0, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (9, 2, DATEADD(minute, 547, DATEADD(day, -1, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (9, 3, DATEADD(minute, 614, DATEADD(day, -2, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (9, 4, DATEADD(minute, 815, DATEADD(day, -5, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (9, 5, DATEADD(minute, 882, DATEADD(day, -6, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (9, 6, DATEADD(minute, 949, DATEADD(day, -9, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (9, 15, DATEADD(minute, 480, DATEADD(day, -0, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (9, 16, DATEADD(minute, 547, DATEADD(day, -1, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (9, 17, DATEADD(minute, 681, DATEADD(day, -3, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (9, 20, DATEADD(minute, 480, DATEADD(day, -0, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (9, 21, DATEADD(minute, 681, DATEADD(day, -3, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (9, 26, DATEADD(minute, 480, DATEADD(day, -0, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (9, 27, DATEADD(minute, 547, DATEADD(day, -1, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (9, 9, DATEADD(minute, 480, DATEADD(day, -0, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (9, 10, DATEADD(minute, 547, DATEADD(day, -1, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (9, 64, DATEADD(minute, 480, DATEADD(day, -0, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (10, 1, DATEADD(minute, 480, DATEADD(day, -1, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (10, 2, DATEADD(minute, 547, DATEADD(day, -2, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (10, 3, DATEADD(minute, 614, DATEADD(day, -4, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (10, 4, DATEADD(minute, 815, DATEADD(day, -1, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (10, 5, DATEADD(minute, 882, DATEADD(day, -2, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (10, 6, DATEADD(minute, 949, DATEADD(day, -4, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (10, 20, DATEADD(minute, 480, DATEADD(day, -1, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (10, 36, DATEADD(minute, 480, DATEADD(day, -1, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (10, 37, DATEADD(minute, 681, DATEADD(day, -8, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (10, 38, DATEADD(minute, 748, DATEADD(day, -12, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (10, 64, DATEADD(minute, 480, DATEADD(day, -1, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (10, 65, DATEADD(minute, 547, DATEADD(day, -2, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (11, 15, DATEADD(minute, 480, DATEADD(day, -0, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (11, 16, DATEADD(minute, 547, DATEADD(day, -1, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (11, 17, DATEADD(minute, 681, DATEADD(day, -5, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (11, 18, DATEADD(minute, 748, DATEADD(day, -9, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (11, 19, DATEADD(minute, 949, DATEADD(day, -1, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (11, 43, DATEADD(minute, 480, DATEADD(day, -0, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (11, 44, DATEADD(minute, 547, DATEADD(day, -1, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (11, 45, DATEADD(minute, 681, DATEADD(day, -5, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (11, 50, DATEADD(minute, 480, DATEADD(day, -0, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (11, 51, DATEADD(minute, 547, DATEADD(day, -1, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (11, 54, DATEADD(minute, 480, DATEADD(day, -0, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (11, 55, DATEADD(minute, 614, DATEADD(day, -3, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (11, 56, DATEADD(minute, 681, DATEADD(day, -5, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (11, 58, DATEADD(minute, 480, DATEADD(day, -0, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (12, 26, DATEADD(minute, 480, DATEADD(day, -2, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (12, 27, DATEADD(minute, 547, DATEADD(day, -3, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (12, 28, DATEADD(minute, 614, DATEADD(day, -6, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (12, 29, DATEADD(minute, 815, DATEADD(day, -2, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (12, 31, DATEADD(minute, 480, DATEADD(day, -2, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (12, 32, DATEADD(minute, 614, DATEADD(day, -6, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (12, 33, DATEADD(minute, 681, DATEADD(day, -10, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (12, 47, DATEADD(minute, 480, DATEADD(day, -2, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (12, 67, DATEADD(minute, 480, DATEADD(day, -2, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (12, 68, DATEADD(minute, 547, DATEADD(day, -3, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (12, 69, DATEADD(minute, 681, DATEADD(day, -10, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (12, 70, DATEADD(minute, 748, DATEADD(day, -11, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (12, 36, DATEADD(minute, 480, DATEADD(day, -2, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (12, 39, DATEADD(minute, 480, DATEADD(day, -2, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (12, 40, DATEADD(minute, 547, DATEADD(day, -3, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (12, 54, DATEADD(minute, 480, DATEADD(day, -2, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (12, 64, DATEADD(minute, 480, DATEADD(day, -2, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0)))));

-- Scores were calculated with the same rules the application uses.
SET IDENTITY_INSERT dbo.[Attempt] ON;
INSERT dbo.[Attempt] ([AttemptID], [ActivityID], [LearnerID], [EndingStepID], [SubmittedAt], [ScorePercent], [TimeTakenSeconds]) VALUES
    (1, 61, 9, NULL, DATEADD(minute, 614, DATEADD(day, -2, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0)))), 50.00, 62),
    (2, 62, 9, NULL, DATEADD(minute, 748, DATEADD(day, -4, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0)))), NULL, NULL),
    (3, 63, 9, NULL, DATEADD(minute, 1145, DATEADD(day, -7, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0)))), 20.00, 323),
    (4, 63, 9, NULL, DATEADD(minute, 815, DATEADD(day, -5, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0)))), 80.00, 237),
    (5, 1, 9, NULL, DATEADD(minute, 681, DATEADD(day, -3, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0)))), 100.00, 366),
    (6, 2, 9, NULL, DATEADD(minute, 748, DATEADD(day, -4, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0)))), 66.67, 121),
    (7, 3, 9, NULL, DATEADD(minute, 1148, DATEADD(day, -13, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0)))), 87.50, 135),
    (8, 3, 9, NULL, DATEADD(minute, 1016, DATEADD(day, -11, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0)))), 75.00, 48),
    (9, 4, 9, NULL, DATEADD(minute, 1149, DATEADD(day, -16, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0)))), 75.00, 128),
    (10, 4, 9, NULL, DATEADD(minute, 1023, DATEADD(day, -14, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0)))), 75.00, 190),
    (11, 11, 9, NULL, DATEADD(minute, 1142, DATEADD(day, -4, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0)))), 64.00, 121),
    (12, 11, 9, NULL, DATEADD(minute, 614, DATEADD(day, -2, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0)))), 91.00, 52),
    (13, 16, 9, NULL, DATEADD(minute, 614, DATEADD(day, -2, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0)))), 100.00, 121),
    (14, 1, 10, NULL, DATEADD(minute, 681, DATEADD(day, -8, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0)))), 83.33, 356),
    (15, 2, 10, NULL, DATEADD(minute, 748, DATEADD(day, -12, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0)))), 66.67, 104),
    (16, 16, 10, NULL, DATEADD(minute, 1142, DATEADD(day, -6, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0)))), 60.00, 50),
    (17, 16, 10, NULL, DATEADD(minute, 614, DATEADD(day, -4, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0)))), 60.00, 189),
    (18, 31, 10, NULL, DATEADD(minute, 547, DATEADD(day, -2, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0)))), 60.00, 149),
    (19, 32, 10, NULL, DATEADD(minute, 1142, DATEADD(day, -6, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0)))), 25.00, 119),
    (20, 32, 10, NULL, DATEADD(minute, 614, DATEADD(day, -4, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0)))), 100.00, 122),
    (21, 11, 11, NULL, DATEADD(minute, 614, DATEADD(day, -3, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0)))), 62.00, 69),
    (22, 12, 11, NULL, DATEADD(minute, 1145, DATEADD(day, -15, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0)))), 50.00, 167),
    (23, 12, 11, NULL, DATEADD(minute, 815, DATEADD(day, -13, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0)))), 66.67, 132),
    (24, 13, 11, 5, DATEADD(minute, 882, DATEADD(day, -0, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0)))), NULL, NULL),
    (25, 40, 11, NULL, DATEADD(minute, 614, DATEADD(day, -3, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0)))), 100.00, 182),
    (26, 47, 11, NULL, DATEADD(minute, 1142, DATEADD(day, -5, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0)))), 60.00, 108),
    (27, 47, 11, NULL, DATEADD(minute, 614, DATEADD(day, -3, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0)))), 100.00, 124),
    (28, 52, 11, NULL, DATEADD(minute, 547, DATEADD(day, -1, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0)))), 100.00, 177),
    (29, 53, 11, NULL, DATEADD(minute, 748, DATEADD(day, -9, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0)))), 100.00, 139),
    (30, 23, 12, NULL, DATEADD(minute, 681, DATEADD(day, -10, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0)))), 78.00, 36),
    (31, 24, 12, NULL, DATEADD(minute, 1144, DATEADD(day, -17, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0)))), 50.00, 184),
    (32, 24, 12, NULL, DATEADD(minute, 748, DATEADD(day, -15, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0)))), 100.00, 173),
    (33, 27, 12, NULL, DATEADD(minute, 1141, DATEADD(day, -5, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0)))), 16.67, 182),
    (34, 27, 12, NULL, DATEADD(minute, 547, DATEADD(day, -3, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0)))), 83.33, 116),
    (35, 44, 12, NULL, DATEADD(minute, 547, DATEADD(day, -3, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0)))), 83.33, 141),
    (36, 67, 12, NULL, DATEADD(minute, 1142, DATEADD(day, -8, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0)))), 62.50, 167),
    (37, 67, 12, NULL, DATEADD(minute, 614, DATEADD(day, -6, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0)))), 87.50, 104),
    (38, 31, 12, NULL, DATEADD(minute, 547, DATEADD(day, -3, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0)))), 80.00, 68);
SET IDENTITY_INSERT dbo.[Attempt] OFF;

INSERT dbo.[QuizAnswer] ([AttemptID], [QuestionID], [SelectedOptionID]) VALUES
    (3, 61, 241),
    (3, 62, 247),
    (3, 63, 251),
    (3, 64, 255),
    (4, 61, 242),
    (4, 62, 246),
    (4, 63, 251),
    (4, 64, 254),
    (5, 1, 1),
    (5, 2, 7),
    (5, 3, 10),
    (5, 4, 15),
    (5, 5, 18),
    (14, 1, 3),
    (14, 2, 7),
    (14, 3, 10),
    (14, 4, 15),
    (14, 5, 18);

INSERT dbo.[SAResponse] ([AttemptID], [StatementID], [Rating]) VALUES
    (2, 26, 4),
    (2, 27, 2),
    (2, 28, 3),
    (2, 29, 4);

SET IDENTITY_INSERT dbo.[DiscussionPost] ON;
INSERT dbo.[DiscussionPost] ([PostID], [ActivityID], [UserID], [ParentPostID], [Content], [PostedDate]) VALUES
    (1, 6, 9, NULL, N'I want to make a page for my brother''s tuition centre. Sections: subjects offered, timetable, and a contact form. The visitors are mostly parents, so it needs big text.', DATEADD(minute, 841, DATEADD(day, -9, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (2, 6, 2, 1, N'A good audience to design for. Put the timetable near the top, because that is what parents will look for first.', DATEADD(minute, 842, DATEADD(day, -8, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (3, 6, 10, NULL, N'A fan page for Nepali football. Sections: latest results, player profiles and a fixtures list.', DATEADD(minute, 843, DATEADD(day, -6, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (4, 10, 9, NULL, N'My counter showed 0111 instead of 3. I was adding a string "1" instead of the number 1, so JavaScript joined the text.', DATEADD(minute, 844, DATEADD(day, -4, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (5, 10, 2, 4, N'Classic one. Number(value) or parseInt converts text from inputs before you add it.', DATEADD(minute, 845, DATEADD(day, -4, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (6, 15, 9, NULL, N'Students queue for printing before deadlines. I would ask how often they print at the last minute and how long they usually wait.', DATEADD(minute, 846, DATEADD(day, -20, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (7, 15, 3, 6, N'Good focus on behaviour rather than opinion. Ask a few people at different times of day before you decide anything.', DATEADD(minute, 847, DATEADD(day, -19, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (8, 15, 10, NULL, N'There is nowhere to buy healthy snacks after 6 PM near our hostel. I would ask what people currently eat late at night and what they pay.', DATEADD(minute, 848, DATEADD(day, -15, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (9, 39, 12, NULL, N'A phone advert showed battery life with bars starting at 20 hours, so a 10 percent improvement looked like double.', DATEADD(minute, 849, DATEADD(day, -3, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (10, 39, 5, 9, N'A perfect example of a truncated axis. Always check where the axis starts.', DATEADD(minute, 850, DATEADD(day, -3, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (11, 43, 11, NULL, N'Draft: Public transport in Kathmandu should be improved because it would reduce pollution and help students reach college on time.', DATEADD(minute, 851, DATEADD(day, -7, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (12, 43, 6, 11, N'Clear and arguable. Consider naming one specific improvement, such as dedicated bus lanes, to make it sharper.', DATEADD(minute, 852, DATEADD(day, -6, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (13, 56, 11, NULL, N'Exam marking. A model could mark a creative answer as wrong just because it is unusual. A teacher should review any grade that affects a student''s future.', DATEADD(minute, 853, DATEADD(day, -5, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (14, 56, 7, 13, N'Good example. Unusual but correct answers are exactly where training data is thin.', DATEADD(minute, 854, DATEADD(day, -5, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (15, 56, 12, NULL, N'Loan approval, because a refusal changes someone''s life and the model might copy unfair patterns from old decisions.', DATEADD(minute, 855, DATEADD(day, -2, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (16, 66, 9, NULL, N'Flashcards for definitions worked really well for biology, but not for maths, where I needed to practise full problems.', DATEADD(minute, 856, DATEADD(day, -10, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (17, 66, 1, 16, N'That is a useful distinction. Matching the technique to the type of question is exactly the right instinct.', DATEADD(minute, 857, DATEADD(day, -10, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (18, 66, 12, NULL, N'Teaching my younger sister the topic. If she understood my explanation, I knew I understood it.', DATEADD(minute, 858, DATEADD(day, -6, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0)))));
SET IDENTITY_INSERT dbo.[DiscussionPost] OFF;

INSERT dbo.[Bookmark] ([LearnerID], [MaterialID], [CreatedDate]) VALUES
    (9, 2, DATEADD(minute, 600, DATEADD(day, -20, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (9, 15, DATEADD(minute, 600, DATEADD(day, -5, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0))))),
    (11, 50, DATEADD(minute, 600, DATEADD(day, -7, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0)))));

SET IDENTITY_INSERT dbo.[FAQ] ON;
INSERT dbo.[FAQ] ([FAQID], [Question], [Answer], [Audience], [SortOrder]) VALUES
    (1, N'How do I find a course?', N'Open Courses from the top menu. Search by a word in the title or description, choose a subject, or filter by free and paid courses.', N'All', 1),
    (2, N'Do I need an account to look around?', N'No. You can browse every published course, read course outlines and open lessons marked Free preview without an account. Create a free learner account to enrol and track your progress.', N'All', 2),
    (3, N'Are the courses free?', N'Most courses are free. A few lecturers charge a small fee in Nepali rupees. The price is shown on every course card and course page before you enrol.', N'All', 3),
    (4, N'How does course progress work?', N'Every published lesson and activity counts once. Lessons count when you choose Mark complete. Quizzes, games, self-assessments and scenarios count when you submit an attempt. A discussion counts when you have written a post or reply.', N'Learner', 4),
    (5, N'Can I retake a quiz or replay a game?', N'Yes. Games, self-assessments and scenarios can be repeated as often as you like. Some quizzes have an attempt limit set by the lecturer; the limit is shown before you start.', N'Learner', 5),
    (6, N'How do I get a certificate?', N'When your progress in a course reaches 100 percent, a Certificate link appears on My courses and on the course home page. You can print it or save it as a PDF from your browser.', N'Learner', 6),
    (7, N'What happens if I leave a course?', N'Leaving removes the course from My courses but keeps your results, completed lessons and posts. If you enrol again, your earlier progress returns.', N'Learner', 7),
    (8, N'What is a learning streak?', N'Your streak counts the days in a row on which you completed a lesson or submitted an activity. Studying a little every day keeps it going.', N'Learner', 8),
    (9, N'How do I become a lecturer?', N'Choose Create account, select Lecturer application and explain what you would like to teach. An administrator reviews every application before the account can sign in.', N'Teacher', 9),
    (10, N'Does previewing my own course change learner records?', N'No. Preview lets you check lessons and activities exactly as learners see them, including drafts, but it never saves attempts, completions or posts.', N'Teacher', 10),
    (11, N'Why can I no longer edit a quiz?', N'Once a learner has submitted an attempt, the questions and options are locked so that every result stays fair. You can still change the title and description, or unpublish the activity.', N'Teacher', 11),
    (12, N'Which game types can I build?', N'Matching, Memory, Word scramble, Sort into groups, Flashcards, Fill in the blank, True or false speed round and Put in order. Each game builder explains the minimum content needed before you can publish.', N'Teacher', 12),
    (13, N'How do I report a problem or ask a question?', N'Use the Contact page. Messages go straight to the administrator, who usually replies within two working days.', N'All', 13);
SET IDENTITY_INSERT dbo.[FAQ] OFF;

SET IDENTITY_INSERT dbo.[ContactMessage] ON;
INSERT dbo.[ContactMessage] ([MessageID], [UserID], [SenderName], [SenderEmail], [Subject], [Message], [SentDate], [IsRead]) VALUES
    (1, 10, N'Ben Lee', N'ben.lee@inkwell.test', N'Certificate name spelling', N'Hello, my certificate shows my name as Ben Lee but I would like it to show Benjamin Lee. Can I change this from my profile or do you need to update it?', DATEADD(minute, 660, DATEADD(day, -3, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0)))), 1),
    (2, NULL, N'Sita Poudel', N'sita.poudel@example.com', N'Courses for my students', N'I teach grade 11 at a school in Pokhara. Can my students use the free courses during class time, and is there a limit on how many can enrol in one course?', DATEADD(minute, 660, DATEADD(day, -1, CAST(CAST(SYSUTCDATETIME() AS date) AS datetime2(0)))), 0);
SET IDENTITY_INSERT dbo.[ContactMessage] OFF;

UPDATE dbo.Activity SET StartStepID = 1 WHERE ActivityID = 13;
UPDATE dbo.Activity SET StartStepID = 6 WHERE ActivityID = 59;
UPDATE dbo.Activity SET StartStepID = 12 WHERE ActivityID = 72;

-- Fail the rebuild before commit if required seed coverage or integrity is missing.
IF (SELECT COUNT(*) FROM sys.tables WHERE is_ms_shipped = 0) <> 25
    THROW 51001, 'Expected exactly 25 application tables.', 1;
IF (SELECT COUNT(*) FROM dbo.[User] WHERE Role = 'Admin') <> 1
    OR (SELECT COUNT(*) FROM dbo.[User] WHERE Role = 'Teacher' AND Status = 'Active') <> 6
    OR (SELECT COUNT(*) FROM dbo.[User] WHERE Role = 'Teacher' AND Status = 'Pending') <> 1
    OR (SELECT COUNT(*) FROM dbo.[User] WHERE Role = 'Learner' AND Status = 'Active') <> 4
    THROW 51002, 'Demo account coverage is incomplete.', 1;
IF (SELECT COUNT(*) FROM dbo.Course) <> 19
    OR NOT EXISTS (SELECT 1 FROM dbo.Course WHERE Status = 'Draft')
    OR (SELECT COUNT(*) FROM dbo.Course c JOIN dbo.[User] u ON u.UserID = c.TeacherID WHERE u.Role = 'Admin') NOT BETWEEN 4 AND 5
    THROW 51003, 'Course seed coverage is incomplete.', 1;
IF EXISTS (SELECT u.UserID FROM dbo.[User] u LEFT JOIN dbo.Course c ON c.TeacherID = u.UserID
           WHERE u.Role = 'Teacher' AND u.Status = 'Active' GROUP BY u.UserID HAVING COUNT(c.CourseID) NOT BETWEEN 2 AND 3)
    THROW 51004, 'Every lecturer needs two or three courses.', 1;
IF (SELECT COUNT(DISTINCT ActivityType) FROM dbo.Activity WHERE Status = 'Published') <> 5
    OR (SELECT COUNT(DISTINCT GameTemplate) FROM dbo.Activity WHERE Status = 'Published' AND ActivityType = 'Game') <> 8
    OR NOT EXISTS (SELECT 1 FROM dbo.Material WHERE MaterialType = 'Code' AND Status = 'Published')
    THROW 51006, 'Published activity coverage is incomplete.', 1;
IF EXISTS (
    SELECT q.QuestionID FROM dbo.QuizQuestion q
    LEFT JOIN dbo.QuizOption o ON o.QuestionID = q.QuestionID
    GROUP BY q.QuestionID
    HAVING COUNT(o.OptionID) NOT BETWEEN 2 AND 6
        OR SUM(CASE WHEN o.IsCorrect = 1 THEN 1 ELSE 0 END) <> 1)
    THROW 51007, 'Quiz options are invalid.', 1;
IF EXISTS (
    SELECT 1 FROM dbo.QuizAnswer qa
    JOIN dbo.Attempt a ON a.AttemptID = qa.AttemptID
    JOIN dbo.QuizQuestion q ON q.QuestionID = qa.QuestionID
    JOIN dbo.QuizOption o ON o.OptionID = qa.SelectedOptionID
    WHERE q.ActivityID <> a.ActivityID OR o.QuestionID <> q.QuestionID)
    THROW 51008, 'Quiz answers must belong to the submitted quiz.', 1;
IF EXISTS (
    SELECT 1 FROM dbo.SAResponse r
    JOIN dbo.Attempt a ON a.AttemptID = r.AttemptID
    JOIN dbo.SAStatement s ON s.StatementID = r.StatementID
    WHERE s.ActivityID <> a.ActivityID)
    THROW 51009, 'Self-assessment responses must belong to the submitted activity.', 1;
IF EXISTS (
    SELECT 1 FROM dbo.Attempt x JOIN dbo.Activity a ON a.ActivityID = x.ActivityID
    WHERE (a.ActivityType = 'Scenario' AND (x.EndingStepID IS NULL OR NOT EXISTS (SELECT 1 FROM dbo.SimStep s WHERE s.StepID = x.EndingStepID AND s.ActivityID = a.ActivityID AND s.IsEnding = 1)))
       OR (a.ActivityType <> 'Scenario' AND x.EndingStepID IS NOT NULL)
       OR (a.ActivityType IN ('Quiz','Game') AND x.ScorePercent IS NULL)
       OR (a.ActivityType IN ('SelfAssessment','Scenario') AND x.ScorePercent IS NOT NULL))
    THROW 51010, 'Attempt fields do not match their activity types.', 1;
IF EXISTS (
    SELECT 1 FROM dbo.DiscussionPost p JOIN dbo.Activity a ON a.ActivityID = p.ActivityID JOIN dbo.Topic t ON t.TopicID = a.TopicID
    JOIN dbo.Course c ON c.CourseID = t.CourseID JOIN dbo.[User] u ON u.UserID = p.UserID
    WHERE u.Role = 'Learner' AND NOT EXISTS (SELECT 1 FROM dbo.Enrolment e WHERE e.LearnerID = u.UserID AND e.CourseID = c.CourseID))
    THROW 51011, 'Learners may only post in courses they are enrolled in.', 1;
IF EXISTS (
    SELECT 1 FROM dbo.Enrolment e JOIN dbo.Course c ON c.CourseID = e.CourseID
    WHERE c.IsPaid = 1 AND NOT EXISTS (SELECT 1 FROM dbo.Payment p WHERE p.LearnerID = e.LearnerID AND p.CourseID = e.CourseID AND p.Status = 'Complete'))
    THROW 51012, 'Paid course enrolments need a completed payment.', 1;

COMMIT TRANSACTION;
SELECT N'Seed checks passed' AS Result,
    (SELECT COUNT(*) FROM dbo.[User]) AS Users,
    (SELECT COUNT(*) FROM dbo.Course) AS Courses,
    (SELECT COUNT(*) FROM dbo.Material) AS Materials,
    (SELECT COUNT(*) FROM dbo.Activity) AS Activities,
    (SELECT COUNT(*) FROM dbo.Attempt) AS Attempts;
GO
USE [master];
GO
ALTER DATABASE [LearningSystem] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
EXEC sys.sp_detach_db @dbname = N'LearningSystem';
PRINT 'LearningSystem detached successfully.';
GO
