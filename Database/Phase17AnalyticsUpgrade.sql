-- Select the existing LearningSystem database before executing this script.
-- Adds the already-contracted analytics table without rebuilding or reseeding data.
SET XACT_ABORT ON;
BEGIN TRY
    BEGIN TRANSACTION;
    IF OBJECT_ID('dbo.Course', 'U') IS NULL OR OBJECT_ID('dbo.[User]', 'U') IS NULL
        THROW 51000, 'Select the existing LearningSystem database first.', 1;

    IF OBJECT_ID('dbo.PageView', 'U') IS NULL
    BEGIN
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
    END;

    IF NOT EXISTS (SELECT 1 FROM sys.indexes
        WHERE object_id = OBJECT_ID('dbo.PageView') AND name = 'IX_PageView_ViewedAt')
        CREATE INDEX [IX_PageView_ViewedAt] ON dbo.[PageView] ([ViewedAt]);

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;
