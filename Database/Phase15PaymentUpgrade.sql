-- Execute against the existing LearningSystem database, not master. No data is rebuilt.
SET XACT_ABORT ON;
BEGIN TRANSACTION;
IF OBJECT_ID('dbo.Course','U') IS NULL THROW 51000, 'Select the existing LearningSystem database first.', 1;
IF COL_LENGTH('dbo.Course','IsPaid') IS NULL
 ALTER TABLE dbo.Course ADD IsPaid BIT NOT NULL CONSTRAINT DF_Course_IsPaid DEFAULT(0) WITH VALUES;
IF COL_LENGTH('dbo.Course','PriceNPR') IS NULL
 ALTER TABLE dbo.Course ADD PriceNPR DECIMAL(10,2) NOT NULL CONSTRAINT DF_Course_PriceNPR DEFAULT(0) WITH VALUES;
-- Dynamic constant DDL avoids compile-time binding of newly added columns in this batch.
IF OBJECT_ID('dbo.CK_Course_Price','C') IS NULL
 EXEC('ALTER TABLE dbo.Course ADD CONSTRAINT CK_Course_Price CHECK ((IsPaid=0 AND PriceNPR=0) OR (IsPaid=1 AND PriceNPR>0))');
IF OBJECT_ID('dbo.Payment','U') IS NULL
BEGIN
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
END;
COMMIT;
