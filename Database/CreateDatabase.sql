-- Phase 1: destructive local demo rebuild. Run with sqlcmd -b and -v DataPath="...\App_Data".
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
    CONSTRAINT [CK_Material_3] CHECK (MaterialType IN ('Text','Image','PDF','Video','Audio','YouTube')),
    CONSTRAINT [CK_Material_4] CHECK (TextContent IS NULL OR LEN(TextContent) BETWEEN 20 AND 10000),
    CONSTRAINT [CK_Material_5] CHECK (AltText IS NULL OR LEN(AltText) BETWEEN 5 AND 150),
    CONSTRAINT [CK_Material_6] CHECK (MaterialType <> 'Text' OR TextContent IS NOT NULL),
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
    [GameTemplate] NVARCHAR(8) NULL,
    [IsClosed] BIT NULL,
    [StartStepID] INT NULL,
    CONSTRAINT [PK_Activity] PRIMARY KEY ([ActivityID]),
    CONSTRAINT [CK_Activity_1] CHECK (ActivityType IN ('Quiz','SelfAssessment','Discussion','Game','Scenario')),
    CONSTRAINT [CK_Activity_2] CHECK (Status IN ('Draft','Published')),
    CONSTRAINT [CK_Activity_3] CHECK (LEN(Title) BETWEEN 3 AND 100 AND (ActivityType <> 'Discussion' OR LEN(Title) >= 5)),
    CONSTRAINT [CK_Activity_4] CHECK (Description IS NULL OR LEN(Description) <= 1000),
    CONSTRAINT [CK_Activity_5] CHECK (ActivityType NOT IN ('Discussion','Scenario') OR (Description IS NOT NULL AND LEN(Description) BETWEEN 10 AND 1000)),
    CONSTRAINT [CK_Activity_6] CHECK ((ActivityType = 'Quiz' AND TimeLimitMinutes IS NOT NULL AND TimeLimitMinutes BETWEEN 0 AND 180 AND MaxAttempts IS NOT NULL AND MaxAttempts BETWEEN 0 AND 10) OR (ActivityType <> 'Quiz' AND TimeLimitMinutes IS NULL AND MaxAttempts IS NULL)),
    CONSTRAINT [CK_Activity_7] CHECK ((ActivityType = 'Game' AND GameTemplate IS NOT NULL AND GameTemplate IN ('Matching','Memory','Scramble','Sort')) OR (ActivityType <> 'Game' AND GameTemplate IS NULL)),
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

-- Demo records: fixed IDs make relationships easy to explain and inspect.
-- Hashes generated by GenerateDemoHashes.ps1; each account has its own random salt.
SET IDENTITY_INSERT dbo.[User] ON;
INSERT dbo.[User] ([UserID], [FullName], [Email], [PasswordHash], [Role], [Status], [ApplicationReason]) VALUES
    (1, N'Demo Administrator', N'admin@example.test', N'PBKDF2$100000$d6txkgO39nPDX4oNV1k9SA==$GQoudyBob792v8E3iMuFMP4ieoqJo25lLo9Y/uy3c/E=', N'Admin', N'Active', NULL),
    (2, N'Asha Sharma', N'asha.teacher@example.test', N'PBKDF2$100000$70A8tsQC93I18oAnHgRHkQ==$DxhihKGHmrxH1uKMwEBrb6/TpNMBx4FRArrg+gQM2Mc=', N'Teacher', N'Active', NULL),
    (3, N'Daniel Tan', N'daniel.teacher@example.test', N'PBKDF2$100000$Qq1pxJ01IRUDFZWtNMKAkQ==$hbzLC/AW/hXA5HBMEeV42PtTN48UutOa3Xd+H/cOUi8=', N'Teacher', N'Active', NULL),
    (4, N'Maya Rai', N'maya.teacher@example.test', N'PBKDF2$100000$8usfu4Ol2ytAlft7G4VQMg==$GR1WgdUub/a+GF35FhJhBOG/DDR8klWuOyikFhuNSzI=', N'Teacher', N'Active', NULL),
    (5, N'Ravi Thapa', N'ravi.pending@example.test', N'PBKDF2$100000$j76CGy6I5FY7qvJC8dG/nQ==$3H+F7SbFLyDmO+briktcKT8ZjKrat3ePVIJbAIPP3GQ=', N'Teacher', N'Pending', N'I would like to teach introductory mathematics using worked examples and practice activities.'),
    (6, N'Sara Lim', N'sara.rejected@example.test', N'PBKDF2$100000$t5My/tKgq6r6awRiN+OLRA==$+S6ZdlygjCtO+GiwV28TfbKMovMTmIZC73qble5sql0=', N'Teacher', N'Rejected', N'I would like to offer foundation study skills lessons and guided revision exercises.'),
    (7, N'Anita Karki', N'anita.learner@example.test', N'PBKDF2$100000$Y1SOatfekl9/7slhiXmZhA==$0FMxuDcvTv8IvuLeDMJuwO/ZF7P5xDrESVWyhZf44ck=', N'Learner', N'Active', NULL),
    (8, N'Ben Lee', N'ben.learner@example.test', N'PBKDF2$100000$Jce0Zq4S5UEmNF092riKVg==$oINHKPMea5Pa8AIeQXe492ExP1MKML2WxmPc5N7gLP4=', N'Learner', N'Active', NULL),
    (9, N'Chandra Gurung', N'chandra.learner@example.test', N'PBKDF2$100000$yYoOmBCp0pKuPHU3Ssb+pw==$XIog83s8QNhS1UjYHVJgg1koHGuU66HGy7Y5Hqn6mzY=', N'Learner', N'Active', NULL),
    (10, N'Dina Wong', N'dina.learner@example.test', N'PBKDF2$100000$DXLQa9GIKVv8rv+OpCd50g==$6D65ew67EtPTBG4B03Tjbren9aKFG0PumbxcxyL6CVQ=', N'Learner', N'Active', NULL),
    (11, N'Eshan Shah', N'eshan.learner@example.test', N'PBKDF2$100000$K68Cyb61DWbwx8FS5vDbIA==$TTFbKU2nlsk2XHBto59bBDyr1a+lGc1PEoLC/LoxQGQ=', N'Learner', N'Active', NULL),
    (12, N'Farah Ali', N'farah.learner@example.test', N'PBKDF2$100000$7ZzIA9jyk53QSnCYnfycww==$ur6D5ndx/cPdKC7pcipmJnBS8H+vMvD6nr/R6Mv+9ig=', N'Learner', N'Deactivated', NULL);
SET IDENTITY_INSERT dbo.[User] OFF;

SET IDENTITY_INSERT dbo.[Subject] ON;
INSERT dbo.[Subject] ([SubjectID], [SubjectName], [Description]) VALUES
    (1, N'IT', N'Understand computing systems, relational data and safe online habits.'),
    (2, N'Business', N'Explore customer needs, costs, revenue and evidence-based business decisions.'),
    (3, N'Science', N'Practise scientific enquiry, cell biology and safe laboratory work.');
SET IDENTITY_INSERT dbo.[Subject] OFF;

SET IDENTITY_INSERT dbo.[Course] ON;
INSERT dbo.[Course] ([CourseID], [TeacherID], [SubjectID], [Title], [Description], [Status]) VALUES
    (1, 2, 1, N'Relational Databases for Beginners', N'Learn how tables, keys and SELECT queries organise data. Practise identifying records and linking related tables.', N'Published'),
    (2, 2, 1, N'Digital Safety Essentials', N'Learn to recognise suspicious messages, protect accounts and make careful decisions when sharing information online.', N'Published'),
    (3, 3, 2, N'Starting a Small Business', N'Identify customer needs, distinguish fixed and variable costs, and calculate the revenue needed to cover costs.', N'Published'),
    (4, 4, 3, N'Cells and Scientific Enquiry', N'Explore the roles of cell structures and design fair investigations with controlled variables and repeated measurements.', N'Published'),
    (5, 4, 3, N'Introduction to Ecosystems', N'A draft course exploring food chains, producers and consumers. Its learning activities are still being prepared.', N'Draft');
SET IDENTITY_INSERT dbo.[Course] OFF;

SET IDENTITY_INSERT dbo.[Topic] ON;
INSERT dbo.[Topic] ([TopicID], [CourseID], [Title], [SortOrder]) VALUES
    (1, 1, N'Tables and keys', 1),
    (2, 1, N'Reading data with SELECT', 2),
    (3, 2, N'Protecting your accounts', 1),
    (4, 2, N'Recognising suspicious messages', 2),
    (5, 3, N'Customers and value', 1),
    (6, 3, N'Costs and break-even', 2),
    (7, 4, N'Inside a cell', 1),
    (8, 4, N'Planning a fair test', 2),
    (9, 5, N'Food chains', 1);
SET IDENTITY_INSERT dbo.[Topic] OFF;

SET IDENTITY_INSERT dbo.[Material] ON;
INSERT dbo.[Material] ([MaterialID], [TopicID], [Title], [MaterialType], [Status], [TextContent], [FilePath], [AltText], [IsPreview], [SortOrder]) VALUES
    (1, 1, N'Rows, columns and primary keys', N'Text', N'Published', N'A relational table stores one kind of thing. In a Learner table, each row represents one learner and each column holds an attribute such as a name. A primary key uniquely identifies a row. Names are poor keys because different people can share them. An integer LearnerID provides a stable reference even when a name changes.

A foreign key points to a key in another table. Enrolment can hold LearnerID and CourseID to connect learners to courses without repeating all their personal details. Together these two values can prevent a learner joining the same course twice.', NULL, NULL, 1, 1),
    (2, 2, N'Selecting the columns you need', N'Text', N'Published', N'SELECT chooses the columns to return, FROM names the table, and WHERE filters rows. For example: SELECT Title FROM Course WHERE Status = ''Published''. This returns course titles only for published rows; it does not change the stored records.

When an application accepts a search term, it should pass that value as a SQL parameter. Joining text typed by a user directly into SQL can change the meaning of the query. Practise explaining the difference between choosing columns and filtering rows.', NULL, NULL, 0, 1),
    (3, 1, N'How an enrolment connects two tables', N'Image', N'Published', NULL, N'~/Uploads/Images/35f96cb1-24e5-4556-85de-d4b3f5adce01.png', N'Learner and Course keys connect through the Enrolment table.', 0, 2),
    (4, 3, N'Building a safer account', N'Text', N'Published', N'Use a long, unique password for each account so that a leak from one service does not unlock another. A password manager can help you keep track of different passwords. Never send passwords to someone who asks for them in a message.

A second verification factor adds another check at login. Keep recovery codes somewhere private. On a shared computer, log out when finished and avoid saving your password in the browser. If you suspect an account has been compromised, use the service''s known official address to change its password.', NULL, NULL, 1, 1),
    (5, 4, N'Pause before following a link', N'Text', N'Published', N'Suspicious messages often create urgency: an account will close today, a prize will expire, or money must be transferred immediately. These claims encourage action before careful checking. A familiar logo or sender display name is not proof that a message is genuine.

Check the actual sender address and destination domain. Avoid opening unexpected attachments. Contact the organisation using details you already trust, rather than a telephone number or link in the message. Report the message through the organisation''s normal support channel.', NULL, NULL, 0, 1),
    (6, 4, N'A safe response to an urgent message', N'Image', N'Published', NULL, N'~/Uploads/Images/35f96cb1-24e5-4556-85de-d4b3f5adce02.png', N'Pause, inspect the request, verify through a trusted channel, then report.', 0, 2),
    (7, 5, N'Find a need before choosing a product', N'Text', N'Published', N'A useful business idea starts with a customer need. A student who has little time between classes may value a quick, affordable lunch more than an extensive menu. Interview potential customers about their current problems before assuming they want your proposed product.

A value proposition explains who the customer is, what problem you solve and why your offer is useful. Test a small version of the idea and collect evidence. Sales, repeat visits and clear feedback are stronger evidence than compliments alone.', NULL, NULL, 1, 1),
    (8, 6, N'Fixed costs, variable costs and break-even', N'Text', N'Published', N'Fixed costs stay the same within the planned level of activity, such as a monthly stall rental. Variable costs increase with each unit produced, such as ingredients and packaging. Revenue equals selling price multiplied by units sold.

If a sandwich sells for 5 currency units and its variable cost is 3, each sale contributes 2 towards fixed costs. With fixed costs of 100, break-even is 100 divided by 2, or 50 sandwiches. At break-even, total revenue equals total cost. This simple model assumes all units are sold and costs remain stable.', NULL, NULL, 0, 1),
    (9, 6, N'Worked break-even example', N'Image', N'Published', NULL, N'~/Uploads/Images/35f96cb1-24e5-4556-85de-d4b3f5adce03.png', N'Price 5 minus variable cost 3 gives contribution 2; fixed cost 100 divided by 2 gives 50 units.', 0, 2),
    (10, 7, N'Cell structures and their jobs', N'Text', N'Published', N'The cell membrane controls movement of substances into and out of the cell. Cytoplasm is the region where many chemical reactions occur. In typical plant and animal cells, the nucleus contains genetic material that helps control cell activities.

Plant cells also have a cellulose cell wall that provides support. Chloroplasts absorb light for photosynthesis in green plant tissues. A large permanent vacuole contains cell sap and helps maintain pressure against the cell wall. A structure''s function helps explain why different cells have different shapes.', NULL, NULL, 1, 1),
    (11, 8, N'Change one factor at a time', N'Text', N'Published', N'An independent variable is the factor deliberately changed. A dependent variable is the outcome measured. Controlled variables are factors kept the same so that comparisons are fair. To investigate how light affects seedling growth, change the light level and measure growth over a fixed period.

Keep the seed type, water amount, container and growth time consistent. Use several seedlings at each light level and repeat measurements to reduce the influence of unusual individuals. Record units and observations honestly, including results that do not support your prediction.', NULL, NULL, 0, 1),
    (12, 8, N'Variables in a seedling investigation', N'Image', N'Published', NULL, N'~/Uploads/Images/35f96cb1-24e5-4556-85de-d4b3f5adce04.png', N'Change light level, measure growth, and keep water, seed type and time constant.', 0, 2),
    (13, 9, N'Producers and consumers', N'Text', N'Draft', N'Plants are producers because they use light energy to make food. Consumers obtain energy by eating other organisms. Arrows in a food chain show the direction in which energy is transferred, from the food source to the organism that eats it.', NULL, NULL, 0, 1);
SET IDENTITY_INSERT dbo.[Material] OFF;

SET IDENTITY_INSERT dbo.[Activity] ON;
INSERT dbo.[Activity] ([ActivityID], [TopicID], [ActivityType], [Title], [Description], [Status], [SortOrder], [TimeLimitMinutes], [MaxAttempts], [GameTemplate], [IsClosed]) VALUES
    (1, 2, N'Quiz', N'Database foundations check', N'Check your understanding of keys and SELECT queries.', N'Published', 1, 10, 3, NULL, NULL),
    (2, 8, N'SelfAssessment', N'Planning an investigation', N'Rate your confidence in planning a fair scientific test.', N'Published', 1, NULL, NULL, NULL, NULL),
    (3, 5, N'Discussion', N'Test a business idea', N'Describe a customer problem on campus. Suggest one question you could ask to test whether your proposed solution is useful.', N'Published', 1, NULL, NULL, NULL, 0),
    (4, 1, N'Game', N'Match database vocabulary', N'Match each database term to its meaning.', N'Published', 1, NULL, NULL, N'Matching', NULL),
    (5, 7, N'Game', N'Remember cell structures', N'Match each cell structure with its function.', N'Published', 1, NULL, NULL, N'Memory', NULL),
    (6, 7, N'Game', N'Unscramble science words', N'Use each hint to recover a scientific word.', N'Published', 2, NULL, NULL, N'Scramble', NULL),
    (7, 6, N'Game', N'Sort business costs', N'Classify each cost for a small sandwich stall.', N'Published', 1, NULL, NULL, N'Sort', NULL),
    (8, 4, N'Scenario', N'An urgent account message', N'You receive a message saying your college account will close today unless you sign in through its link. Decide how to respond.', N'Published', 1, NULL, NULL, NULL, NULL);
SET IDENTITY_INSERT dbo.[Activity] OFF;

SET IDENTITY_INSERT dbo.[QuizQuestion] ON;
INSERT dbo.[QuizQuestion] ([QuestionID], [ActivityID], [QuestionText], [Marks], [SortOrder]) VALUES
    (1, 1, N'Which field is the best primary key for a learner table?', 1, 1),
    (2, 1, N'Which SQL clause filters the rows returned by a SELECT query?', 1, 2),
    (3, 1, N'What does a foreign key connect?', 1, 3);
SET IDENTITY_INSERT dbo.[QuizQuestion] OFF;

SET IDENTITY_INSERT dbo.[QuizOption] ON;
INSERT dbo.[QuizOption] ([OptionID], [QuestionID], [OptionText], [IsCorrect]) VALUES
    (1, 1, N'A unique LearnerID', 1),
    (2, 1, N'The learner''s first name', 0),
    (3, 1, N'The learner''s favourite subject', 0),
    (4, 2, N'WHERE', 1),
    (5, 2, N'FROM', 0),
    (6, 2, N'ORDER BY', 0),
    (7, 3, N'A row to a referenced key in another table', 1),
    (8, 3, N'A password to a browser colour', 0),
    (9, 3, N'Every column to an image file', 0);
SET IDENTITY_INSERT dbo.[QuizOption] OFF;

SET IDENTITY_INSERT dbo.[SAStatement] ON;
INSERT dbo.[SAStatement] ([StatementID], [ActivityID], [StatementText], [SortOrder]) VALUES
    (1, 2, N'I can identify the independent variable in an investigation.', 1),
    (2, 2, N'I can choose a measurable dependent variable and state its units.', 2),
    (3, 2, N'I can explain which variables must be kept the same for a fair test.', 3);
SET IDENTITY_INSERT dbo.[SAStatement] OFF;

SET IDENTITY_INSERT dbo.[GameGroup] ON;
INSERT dbo.[GameGroup] ([GroupID], [ActivityID], [GroupName]) VALUES
    (1, 7, N'Fixed costs'),
    (2, 7, N'Variable costs');
SET IDENTITY_INSERT dbo.[GameGroup] OFF;

SET IDENTITY_INSERT dbo.[GameItem] ON;
INSERT dbo.[GameItem] ([ItemID], [ActivityID], [GroupID], [ItemText], [MatchText]) VALUES
    (1, 4, NULL, N'Primary key', N'Uniquely identifies a row'),
    (2, 4, NULL, N'Foreign key', N'References a key in another table'),
    (3, 4, NULL, N'Row', N'One record in a table'),
    (4, 4, NULL, N'Column', N'One attribute recorded for each row'),
    (5, 5, NULL, N'Nucleus', N'Contains genetic material'),
    (6, 5, NULL, N'Cell membrane', N'Controls movement into and out of the cell'),
    (7, 5, NULL, N'Cell wall', N'Provides support in a plant cell'),
    (8, 5, NULL, N'Chloroplast', N'Absorbs light for photosynthesis'),
    (9, 6, NULL, N'nucleus', N'Cell structure containing genetic material'),
    (10, 6, NULL, N'variable', N'A factor that can change in an investigation'),
    (11, 6, NULL, N'membrane', N'Boundary controlling movement into and out of a cell'),
    (12, 7, 1, N'Monthly stall rental', NULL),
    (13, 7, 1, N'Annual trading licence', NULL),
    (14, 7, 2, N'Bread used for each sandwich', NULL),
    (15, 7, 2, N'Packaging used for each sale', NULL);
SET IDENTITY_INSERT dbo.[GameItem] OFF;

SET IDENTITY_INSERT dbo.[SimStep] ON;
INSERT dbo.[SimStep] ([StepID], [ActivityID], [StepText], [IsEnding], [Outcome], [Feedback]) VALUES
    (1, 8, N'The message demands an immediate login through an unfamiliar link. What will you do first?', 0, NULL, NULL),
    (2, 8, N'You open the college website using a saved bookmark. There is no account warning. What will you do next?', 0, NULL, NULL),
    (3, 8, N'The college support team confirms the message was fraudulent. You report it without entering your password.', 1, N'Best', N'You verified the request through a trusted channel and reported the message. Urgency alone is not evidence that a request is genuine.'),
    (4, 8, N'You entered your password on the linked page before checking its address. Your account may now be at risk.', 1, N'Poor', N'Stop using the suspicious page. Open the official college site independently, change the affected password and contact support promptly.'),
    (5, 8, N'You delete the message without following its link, but do not report it to the support team.', 1, N'Acceptable', N'You avoided sharing your password. Reporting the suspicious message would also help support warn other students.');
SET IDENTITY_INSERT dbo.[SimStep] OFF;

SET IDENTITY_INSERT dbo.[SimChoice] ON;
INSERT dbo.[SimChoice] ([ChoiceID], [FromStepID], [NextStepID], [ChoiceText]) VALUES
    (1, 1, 2, N'Open the college website using my saved bookmark.'),
    (2, 1, 4, N'Follow the message link and enter my password.'),
    (3, 1, 5, N'Delete the message without following the link.'),
    (4, 2, 3, N'Contact support using the official site''s contact details.'),
    (5, 2, 5, N'Ignore and delete the message.');
SET IDENTITY_INSERT dbo.[SimChoice] OFF;

UPDATE dbo.Activity SET StartStepID = 1 WHERE ActivityID = 8;

INSERT dbo.[Enrolment] ([LearnerID], [CourseID]) VALUES
    (7, 1),
    (7, 2),
    (7, 3),
    (7, 4),
    (8, 1),
    (8, 3),
    (9, 2),
    (9, 4),
    (10, 3),
    (10, 4),
    (11, 1),
    (11, 4),
    (12, 1);

INSERT dbo.[MaterialCompletion] ([LearnerID], [MaterialID]) VALUES
    (7, 1),
    (7, 2),
    (7, 3),
    (7, 10),
    (8, 1),
    (8, 7),
    (9, 4),
    (10, 11),
    (11, 10);

SET IDENTITY_INSERT dbo.[Attempt] ON;
INSERT dbo.[Attempt] ([AttemptID], [ActivityID], [LearnerID], [SubmittedAt], [ScorePercent], [TimeTakenSeconds]) VALUES
    (1, 1, 7, N'2026-09-27T09:00:00', 100, 95),
    (2, 1, 8, N'2026-09-27T10:00:00', 0, 110),
    (3, 2, 7, N'2026-09-27T11:00:00', NULL, NULL),
    (4, 2, 10, N'2026-09-27T12:00:00', NULL, NULL);
SET IDENTITY_INSERT dbo.[Attempt] OFF;

INSERT dbo.[QuizAnswer] ([AttemptID], [QuestionID], [SelectedOptionID]) VALUES
    (1, 1, 1),
    (1, 2, 4),
    (1, 3, 7),
    (2, 1, 2),
    (2, 2, 5),
    (2, 3, 8);

INSERT dbo.[SAResponse] ([AttemptID], [StatementID], [Rating]) VALUES
    (3, 1, 4),
    (3, 2, 3),
    (3, 3, 4),
    (4, 1, 2),
    (4, 2, 3),
    (4, 3, 2);

SET IDENTITY_INSERT dbo.[DiscussionPost] ON;
INSERT dbo.[DiscussionPost] ([PostID], [ActivityID], [UserID], [ParentPostID], [Content]) VALUES
    (1, 3, 7, NULL, N'Students queue for lunch between classes. I would ask how long they can wait and what they usually spend before designing a pre-order service.'),
    (2, 3, 8, 1, N'I would also ask whether students can collect at a fixed time. That might affect whether pre-ordering is convenient.'),
    (3, 3, 3, 1, N'Good focus on the customer''s problem. Compare answers from several students before deciding which feature matters most.'),
    (4, 3, 10, NULL, N'Some students forget printing deadlines. I would ask how often they need urgent printing and which part of the current process takes longest.');
SET IDENTITY_INSERT dbo.[DiscussionPost] OFF;

SET IDENTITY_INSERT dbo.[FAQ] ON;
INSERT dbo.[FAQ] ([FAQID], [Question], [Answer], [Audience], [SortOrder]) VALUES
    (1, N'How do I find a course?', N'Open Courses and search by a word in its title or description. You can also filter the catalogue by subject.', N'All', 1),
    (2, N'How do I join a published course?', N'Sign in as a learner, open the course outline and choose Enrol. Your enrolled courses appear in My Courses.', N'Learner', 2),
    (3, N'Why is my teacher application pending?', N'An administrator reviews teacher applications before activating access. A pending application cannot sign in yet.', N'Teacher', 3),
    (4, N'Does a teacher preview save results?', N'No. An authorised teacher preview lets you check your content without creating learner attempts or completions.', N'Teacher', 4);
SET IDENTITY_INSERT dbo.[FAQ] OFF;

-- Historical activity data follows account creation, enrolment and study.
UPDATE dbo.[User] SET CreatedDate = '2026-09-20T08:00:00';
UPDATE dbo.Course SET CreatedDate = DATEADD(day, CourseID, CONVERT(datetime2(0), '2026-09-20T08:00:00')),
    LastUpdated = '2026-09-26T08:00:00';
UPDATE dbo.Activity SET CreatedDate = '2026-09-26T08:00:00';
UPDATE dbo.Enrolment SET EnrolDate = '2026-09-26T09:00:00';
UPDATE dbo.MaterialCompletion SET CompletedDate = '2026-09-26T10:00:00';
UPDATE dbo.DiscussionPost SET PostedDate = DATEADD(minute, PostID, CONVERT(datetime2(0), '2026-09-27T13:00:00'));

-- Optional Review, ContactMessage and Bookmark tables are intentionally empty.
-- No game attempts or feedback thresholds are invented while runtime Q10 is open.

-- Fail the rebuild before commit if required seed coverage or integrity is missing.
IF (SELECT COUNT(*) FROM sys.tables WHERE is_ms_shipped = 0) <> 24
    THROW 51001, 'Expected exactly 24 application tables.', 1;
IF (SELECT COUNT(*) FROM dbo.[User]) <> 12
    OR (SELECT COUNT(*) FROM dbo.[User] WHERE Role = 'Admin') <> 1
    OR (SELECT COUNT(*) FROM dbo.[User] WHERE Role = 'Teacher' AND Status = 'Active') <> 3
    OR (SELECT COUNT(*) FROM dbo.[User] WHERE Role = 'Teacher' AND Status = 'Pending') <> 1
    OR (SELECT COUNT(*) FROM dbo.[User] WHERE Role = 'Teacher' AND Status = 'Rejected') <> 1
    OR (SELECT COUNT(*) FROM dbo.[User] WHERE Role = 'Learner') <> 6
    OR (SELECT COUNT(*) FROM dbo.[User] WHERE Role = 'Learner' AND Status = 'Deactivated') <> 1
    THROW 51002, 'Demo account coverage is incomplete.', 1;
IF (SELECT COUNT(*) FROM dbo.Subject) <> 3
    OR (SELECT COUNT(*) FROM dbo.Course WHERE Status = 'Published') < 4
    OR NOT EXISTS (SELECT 1 FROM dbo.Course WHERE Status = 'Draft')
    THROW 51003, 'Subject/course seed coverage is incomplete.', 1;
IF EXISTS (
    SELECT c.CourseID FROM dbo.Course c
    LEFT JOIN dbo.Topic t ON t.CourseID = c.CourseID
    WHERE c.Status = 'Published' GROUP BY c.CourseID
    HAVING COUNT(t.TopicID) NOT BETWEEN 2 AND 3)
    THROW 51004, 'Every published course needs two or three topics.', 1;
IF EXISTS (
    SELECT c.CourseID FROM dbo.Course c
    LEFT JOIN dbo.Topic t ON t.CourseID = c.CourseID
    LEFT JOIN dbo.Material m ON m.TopicID = t.TopicID AND m.Status = 'Published'
    WHERE c.Status = 'Published' GROUP BY c.CourseID
    HAVING COUNT(DISTINCT m.MaterialType) < 2)
    THROW 51005, 'Every published course needs mixed material types.', 1;
IF (SELECT COUNT(DISTINCT ActivityType) FROM dbo.Activity WHERE Status = 'Published') <> 5
    OR (SELECT COUNT(DISTINCT GameTemplate) FROM dbo.Activity WHERE Status = 'Published' AND ActivityType = 'Game') <> 4
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
    THROW 51009, 'Self-assessment responses belong to a different activity.', 1;
IF EXISTS (
    SELECT 1 FROM dbo.GameItem i JOIN dbo.Activity a ON a.ActivityID = i.ActivityID
    LEFT JOIN dbo.GameGroup g ON g.GroupID = i.GroupID
    WHERE (a.GameTemplate = 'Sort' AND (i.MatchText IS NOT NULL OR i.GroupID IS NULL OR g.ActivityID <> a.ActivityID))
       OR (a.GameTemplate <> 'Sort' AND (i.GroupID IS NOT NULL OR i.MatchText IS NULL)))
    THROW 51010, 'Game items violate the approved Q10 mapping.', 1;
IF EXISTS (
    SELECT a.ActivityID FROM dbo.Activity a LEFT JOIN dbo.GameItem i ON i.ActivityID = a.ActivityID
    WHERE a.GameTemplate IN ('Matching','Memory','Scramble')
    GROUP BY a.ActivityID, a.GameTemplate
    HAVING (a.GameTemplate = 'Matching' AND COUNT(i.ItemID) < 4)
        OR (a.GameTemplate = 'Memory' AND COUNT(i.ItemID) NOT BETWEEN 4 AND 12)
        OR (a.GameTemplate = 'Scramble' AND COUNT(i.ItemID) < 3))
    THROW 51011, 'A game has too few or too many items.', 1;
IF (SELECT COUNT(*) FROM dbo.GameGroup WHERE ActivityID = 7) NOT BETWEEN 2 AND 4
    OR EXISTS (SELECT g.GroupID FROM dbo.GameGroup g
        LEFT JOIN dbo.GameItem i ON i.GroupID = g.GroupID
        GROUP BY g.GroupID HAVING COUNT(i.ItemID) < 2)
    THROW 51012, 'Sort requires two to four groups with at least two items each.', 1;
IF NOT EXISTS (SELECT 1 FROM dbo.Activity a JOIN dbo.SimStep s ON s.StepID = a.StartStepID
    WHERE a.ActivityID = 8 AND s.ActivityID = a.ActivityID)
    OR (SELECT COUNT(*) FROM dbo.SimStep WHERE ActivityID = 8 AND IsEnding = 1) < 2
    OR EXISTS (SELECT 1 FROM dbo.SimStep s WHERE s.IsEnding = 0
        AND NOT EXISTS (SELECT 1 FROM dbo.SimChoice c WHERE c.FromStepID = s.StepID))
    OR EXISTS (SELECT 1 FROM dbo.SimChoice c JOIN dbo.SimStep f ON f.StepID = c.FromStepID
        JOIN dbo.SimStep n ON n.StepID = c.NextStepID WHERE f.ActivityID <> n.ActivityID OR f.IsEnding = 1)
    THROW 51013, 'Scenario start, choices or endings are invalid.', 1;
IF EXISTS (SELECT 1 FROM dbo.DiscussionPost p JOIN dbo.DiscussionPost parent ON parent.PostID = p.ParentPostID
    WHERE parent.ParentPostID IS NOT NULL OR parent.ActivityID <> p.ActivityID)
    THROW 51014, 'Discussion replies must have one level in the same activity.', 1;
IF EXISTS (
    SELECT 1 FROM sys.foreign_key_columns f
    WHERE NOT EXISTS (
        SELECT 1 FROM sys.index_columns ic JOIN sys.indexes i
            ON i.object_id = ic.object_id AND i.index_id = ic.index_id
        WHERE ic.object_id = f.parent_object_id AND ic.column_id = f.parent_column_id
            AND ic.key_ordinal = 1 AND i.is_disabled = 0))
    THROW 51015, 'A foreign key lacks an index with its column first.', 1;
IF EXISTS (
    SELECT 1 FROM dbo.Attempt a JOIN dbo.Activity act ON act.ActivityID = a.ActivityID
    JOIN dbo.Topic t ON t.TopicID = act.TopicID
    WHERE NOT EXISTS (SELECT 1 FROM dbo.Enrolment e WHERE e.LearnerID = a.LearnerID AND e.CourseID = t.CourseID))
    THROW 51016, 'A seeded attempt has no matching enrolment.', 1;

COMMIT TRANSACTION;
SELECT N'Phase 1 seed checks passed' AS Result,
    (SELECT COUNT(*) FROM dbo.[User]) AS Users,
    (SELECT COUNT(*) FROM dbo.Course) AS Courses,
    (SELECT COUNT(*) FROM dbo.Material) AS Materials,
    (SELECT COUNT(*) FROM dbo.Activity) AS Activities,
    (SELECT COUNT(*) FROM dbo.Attempt) AS Attempts;
GO
USE [master];
GO
ALTER DATABASE [LearningSystem] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
-- Persist normal access mode before detaching for the web application's next attach.
ALTER DATABASE [LearningSystem] SET MULTI_USER;
EXEC master.dbo.sp_detach_db @dbname = N'LearningSystem', @skipchecks = N'false';
IF DB_ID(N'LearningSystem') IS NOT NULL
    THROW 51017, 'LearningSystem was not detached.', 1;
PRINT 'LearningSystem detached successfully. Files are ready for AttachDbFilename.';
GO




