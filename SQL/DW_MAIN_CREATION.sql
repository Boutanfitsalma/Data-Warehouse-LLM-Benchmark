-- ===================================================================
-- Master Script to Create/Recreate LLMPerformanceDW Schema
-- Merges Table Creation, DimDate Population, and DimModel SCD2 Setup
-- ===================================================================
USE LLMPerformanceDW; -- Ensure you are in the correct database context
GO

---------------------------------------------------------------------
-- Drop Tables (in reverse order of dependencies for FKs)
---------------------------------------------------------------------
PRINT '=====================================================================';
PRINT 'Step 1: Dropping existing tables if they exist...';
PRINT '=====================================================================';

IF OBJECT_ID('dbo.FactBenchmarkEvaluation', 'U') IS NOT NULL
BEGIN
    DROP TABLE dbo.FactBenchmarkEvaluation;
    PRINT 'Table dbo.FactBenchmarkEvaluation dropped.';
END

IF OBJECT_ID('dbo.FactModelEvaluationScore', 'U') IS NOT NULL
BEGIN
    DROP TABLE dbo.FactModelEvaluationScore;
    PRINT 'Table dbo.FactModelEvaluationScore dropped.';
END

-- DimModel will be dropped and recreated, including its SCD2 columns
IF OBJECT_ID('dbo.DimModel', 'U') IS NOT NULL
BEGIN
    DROP TABLE dbo.DimModel;
    PRINT 'Table dbo.DimModel dropped.';
END

IF OBJECT_ID('dbo.DimBenchmark', 'U') IS NOT NULL
BEGIN
    DROP TABLE dbo.DimBenchmark;
    PRINT 'Table dbo.DimBenchmark dropped.';
END

-- DimDate will be dropped and recreated to ensure the 'Unknown' record and structure are correct
IF OBJECT_ID('dbo.DimDate', 'U') IS NOT NULL
BEGIN
    DROP TABLE dbo.DimDate;
    PRINT 'Table dbo.DimDate dropped.';
END
GO

---------------------------------------------------------------------
-- Create and Populate DimDate Table
---------------------------------------------------------------------
PRINT '=====================================================================';
PRINT 'Step 2: Creating and Populating dbo.DimDate Table...';
PRINT '=====================================================================';

-- Create DimDate Table
CREATE TABLE dbo.DimDate (
    DateSK INT PRIMARY KEY,              -- Surrogate Key
    FullDate DATE NULL UNIQUE,           -- The actual date, now NULLABLE for the unknown record. UNIQUE still applies to non-NULL values.
    [Year] INT NOT NULL,                 -- Using brackets as Year is a reserved keyword
    [Month] INT NOT NULL,                -- Using brackets as Month is a reserved keyword
    [Day] INT NOT NULL,                  -- Using brackets as Day is a reserved keyword
    DayOfWeek INT NOT NULL,              -- 1 (Sunday) to 7 (Saturday) - SQL Server default (or as per DATEFIRST)
    MonthName VARCHAR(20) NOT NULL,
    QuarterName VARCHAR(2) NOT NULL,     -- E.g., Q1
    IsWeekend BIT NOT NULL,
    IsHoliday BIT NOT NULL DEFAULT 0,    -- Default to 0 (Not a Holiday)
    Season VARCHAR(20) NULL
);
PRINT 'Table dbo.DimDate created successfully.';
GO

-- Insert the "Unknown" or "NULL Date" record
PRINT 'Inserting Unknown Date record (DateSK = 0) into dbo.DimDate.';
INSERT INTO dbo.DimDate (
    DateSK,
    FullDate,
    [Year],
    [Month],
    [Day],
    DayOfWeek,
    MonthName,
    QuarterName,
    IsWeekend,
    IsHoliday,
    Season
)
VALUES (
    0,          -- DateSK for Unknown/NULL date
    NULL,       -- FullDate is NULL
    0,          -- Placeholder Year for Unknown
    0,          -- Placeholder Month for Unknown
    0,          -- Placeholder Day for Unknown
    0,          -- Placeholder DayOfWeek (Note: DATEPART(WEEKDAY, '0000-00-00') would error, so 0 is a placeholder)
    'Null',  -- Placeholder MonthName
    'Na',      -- Placeholder QuarterName (was 'NULL' as string, changed to 'Unk' for consistency)
    0,          -- IsWeekend = False for Unknown
    0,          -- IsHoliday = False for Unknown
    'Null'   -- Placeholder Season (was 'NULL' as string, changed to 'Unknown')
);
GO

-- Populate DimDate Table with actual dates
DECLARE @PopulateStartDate DATE = '2022-03-02'; -- <<<<< YOUR MINIMUM DATE
DECLARE @PopulateEndDate DATE = DATEADD(YEAR, 2, GETDATE()); -- Generate dates for 2 years into the future from today

PRINT 'Populating DimDate table with actual dates from ' + CONVERT(VARCHAR, @PopulateStartDate, 120) + ' to ' + CONVERT(VARCHAR, @PopulateEndDate, 120);

DECLARE @CurrentProcessingDate DATE = @PopulateStartDate;
WHILE @CurrentProcessingDate <= @PopulateEndDate
BEGIN
    DECLARE @CalculatedIsWeekend BIT;
    DECLARE @CalculatedSeason VARCHAR(20);
    DECLARE @CurrentProcessingMonth INT = DATEPART(MONTH, @CurrentProcessingDate);

    -- Calculate IsWeekend
    IF DATEPART(WEEKDAY, @CurrentProcessingDate) IN (1, 7) -- Assuming DATEFIRST 7 (US English: Sunday=1, Saturday=7)
        SET @CalculatedIsWeekend = 1;
    ELSE
        SET @CalculatedIsWeekend = 0;

    -- Calculate Season (Northern Hemisphere meteorological seasons)
    IF @CurrentProcessingMonth IN (12, 1, 2)
        SET @CalculatedSeason = 'Winter';
    ELSE IF @CurrentProcessingMonth IN (3, 4, 5)
        SET @CalculatedSeason = 'Spring';
    ELSE IF @CurrentProcessingMonth IN (6, 7, 8)
        SET @CalculatedSeason = 'Summer';
    ELSE IF @CurrentProcessingMonth IN (9, 10, 11)
        SET @CalculatedSeason = 'Fall'; -- Or 'Autumn'
    ELSE
        SET @CalculatedSeason = NULL;

    INSERT INTO dbo.DimDate (
        DateSK,
        FullDate,
        [Year],
        [Month],
        [Day],
        DayOfWeek,
        MonthName,
        QuarterName,
        IsWeekend,
        IsHoliday,
        Season
    )
    VALUES (
        CONVERT(INT, CONVERT(VARCHAR(8), @CurrentProcessingDate, 112)), -- YYYYMMDD as integer for DateSK
        @CurrentProcessingDate,
        DATEPART(YEAR, @CurrentProcessingDate),
        @CurrentProcessingMonth,
        DATEPART(DAY, @CurrentProcessingDate),
        DATEPART(WEEKDAY, @CurrentProcessingDate),
        DATENAME(MONTH, @CurrentProcessingDate),
        'Q' + CONVERT(VARCHAR(1), DATEPART(QUARTER, @CurrentProcessingDate)),
        @CalculatedIsWeekend,
        0, -- Default for IsHoliday
        @CalculatedSeason
    );
    SET @CurrentProcessingDate = DATEADD(DAY, 1, @CurrentProcessingDate);
END;
PRINT 'DimDate table populated with actual dates successfully.';
GO

---------------------------------------------------------------------
-- Create Other Dimension Tables
---------------------------------------------------------------------
PRINT '=====================================================================';
PRINT 'Step 3: Creating other dimension tables...';
PRINT '=====================================================================';

-- DimModel (Initial creation without SCD2 specific constraint yet, SCD2 columns added later)
CREATE TABLE dbo.DimModel (
    ModelSK INT IDENTITY(1,1) PRIMARY KEY,       -- Surrogate Key
    SourceSystemID_NK VARCHAR(2000) NOT NULL,   -- Natural Key (stores the unique 'id' from CSV)
    ModelSHA_Val VARCHAR(255) NULL,
    ModelName VARCHAR(MAX) NULL,
    ModelPrecision VARCHAR(100) NULL,
    ModelType VARCHAR(255) NULL,
    ModelWeightType VARCHAR(255) NULL,
    ModelArchitecture VARCHAR(255) NULL,
    HasChatTemplate BIT NULL,
    IsNotAvailableOnHub BIT NULL,
    IsMerged BIT NULL,
    IsMoE BIT NULL,
    IsFlagged BIT NULL,
    IsOfficialProvider BIT NULL,
    BaseModel VARCHAR(500) NULL,
    HubLicense VARCHAR(MAX) NULL,
    ParamsBillions DECIMAL(10, 3) NULL,
    GenerationNumber INT NULL,
    DW_LoadDateTime DATETIME2(7) DEFAULT GETUTCDATE()
    -- Constraint UQ_DimModel_SourceSystemID_NK will be replaced by a filtered index for SCD2
);
PRINT 'Table dbo.DimModel created successfully (initial structure).';
GO

-- DimBenchmark
CREATE TABLE dbo.DimBenchmark (
    BenchmarkSK INT IDENTITY(1,1) PRIMARY KEY,
    BenchmarkName VARCHAR(255) NOT NULL,
    ShortCode VARCHAR(50) NULL,
    BenchmarkDescription VARCHAR(MAX) NULL,
    NormalizedScoreMethod VARCHAR(255) NULL,
    CONSTRAINT UQ_DimBenchmark_BenchmarkName UNIQUE (BenchmarkName)
);
PRINT 'Table dbo.DimBenchmark created successfully.';
GO

---------------------------------------------------------------------
-- Modify DimModel for SCD Type 2
---------------------------------------------------------------------
PRINT '=====================================================================';
PRINT 'Step 4: Modifying dbo.DimModel for SCD Type 2...';
PRINT '=====================================================================';

-- Add the SCD Type 2 columns to DimModel
-- Ensured only one 'Flag' column and corrected default for EffectiveDate.
ALTER TABLE dbo.DimModel
ADD Flag VARCHAR(55) NOT NULL DEFAULT 'Current', -- Default for new rows
    EffectiveDate DATETIME2(7) NOT NULL DEFAULT GETUTCDATE(),
    ExpirationDate DATETIME2(7) NULL;
PRINT 'SCD Type 2 columns (Flag, EffectiveDate, ExpirationDate) added to dbo.DimModel successfully.';
GO

-- Create the filtered unique index for SCD Type 2 (replaces the original UQ_DimModel_SourceSystemID_NK)
-- No need to drop UQ_DimModel_SourceSystemID_NK as it wasn't created in the initial DimModel CREATE TABLE statement.
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_DimModel_SourceSystemID_NK_Flag' AND object_id = OBJECT_ID('dbo.DimModel'))
BEGIN
    DROP INDEX IX_DimModel_SourceSystemID_NK_Flag ON dbo.DimModel;
    PRINT 'Existing filtered unique index IX_DimModel_SourceSystemID_NK_Flag dropped.';
END
GO

CREATE UNIQUE NONCLUSTERED INDEX IX_DimModel_SourceSystemID_NK_Flag
ON dbo.DimModel(SourceSystemID_NK)
WHERE Flag = 'Current'; -- Note: string literals for Flag
PRINT 'Filtered unique index IX_DimModel_SourceSystemID_NK_Flag added for SCD Type 2 in dbo.DimModel.';
GO

---------------------------------------------------------------------
-- Create Fact Tables
---------------------------------------------------------------------
PRINT '=====================================================================';
PRINT 'Step 5: Creating fact tables...';
PRINT '=====================================================================';

-- FactBenchmarkEvaluation
CREATE TABLE dbo.FactBenchmarkEvaluation (
    BenchmarkEvaluationSK INT IDENTITY(1,1) PRIMARY KEY,
    ModelSK INT NOT NULL,
    BenchmarkSK INT NOT NULL,
    UploadDateSK INT NOT NULL,
    SubmissionDateSK INT NOT NULL,
    BenchmarkRawScore DECIMAL(18, 4) NULL,
    BenchmarkNormalizedScore DECIMAL(18, 4) NULL,
    CONSTRAINT FK_FactBenchmarkEvaluation_DimModel FOREIGN KEY (ModelSK) REFERENCES dbo.DimModel(ModelSK),
    CONSTRAINT FK_FactBenchmarkEvaluation_DimBenchmark FOREIGN KEY (BenchmarkSK) REFERENCES dbo.DimBenchmark(BenchmarkSK),
    CONSTRAINT FK_FactBenchmarkEvaluation_DimDate_Upload FOREIGN KEY (UploadDateSK) REFERENCES dbo.DimDate(DateSK),
    CONSTRAINT FK_FactBenchmarkEvaluation_DimDate_Submission FOREIGN KEY (SubmissionDateSK) REFERENCES dbo.DimDate(DateSK)
);
PRINT 'Table dbo.FactBenchmarkEvaluation created successfully.';
GO

-- FactModelEvaluationScore
CREATE TABLE dbo.FactModelEvaluationScore (
    ModelEvaluationScoreSK INT IDENTITY(1,1) PRIMARY KEY,
    ModelSK INT NOT NULL,
    UploadDateSK INT NOT NULL,
    SubmissionDateSK INT NOT NULL,
    AverageScore DECIMAL(18, 4) NULL,
    HubHearts INT NULL,
    CO2Cost DECIMAL(18, 2) NULL,
    CONSTRAINT FK_FactModelEvaluationScore_DimModel FOREIGN KEY (ModelSK) REFERENCES dbo.DimModel(ModelSK),
    CONSTRAINT FK_FactModelEvaluationScore_DimDate_Upload FOREIGN KEY (UploadDateSK) REFERENCES dbo.DimDate(DateSK),
    CONSTRAINT FK_FactModelEvaluationScore_DimDate_Submission FOREIGN KEY (SubmissionDateSK) REFERENCES dbo.DimDate(DateSK)
);
PRINT 'Table dbo.FactModelEvaluationScore created successfully.';
GO

---------------------------------------------------------------------
-- Create Non-Clustered Indexes on FKs for better join performance
---------------------------------------------------------------------
PRINT '=====================================================================';
PRINT 'Step 6: Creating non-clustered indexes on fact table FKs...';
PRINT '=====================================================================';

-- For FactBenchmarkEvaluation
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_FactBenchmarkEvaluation_ModelSK' AND object_id = OBJECT_ID('dbo.FactBenchmarkEvaluation'))
    CREATE NONCLUSTERED INDEX IX_FactBenchmarkEvaluation_ModelSK ON dbo.FactBenchmarkEvaluation(ModelSK);
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_FactBenchmarkEvaluation_BenchmarkSK' AND object_id = OBJECT_ID('dbo.FactBenchmarkEvaluation'))
    CREATE NONCLUSTERED INDEX IX_FactBenchmarkEvaluation_BenchmarkSK ON dbo.FactBenchmarkEvaluation(BenchmarkSK);
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_FactBenchmarkEvaluation_UploadDateSK' AND object_id = OBJECT_ID('dbo.FactBenchmarkEvaluation'))
    CREATE NONCLUSTERED INDEX IX_FactBenchmarkEvaluation_UploadDateSK ON dbo.FactBenchmarkEvaluation(UploadDateSK);
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_FactBenchmarkEvaluation_SubmissionDateSK' AND object_id = OBJECT_ID('dbo.FactBenchmarkEvaluation'))
    CREATE NONCLUSTERED INDEX IX_FactBenchmarkEvaluation_SubmissionDateSK ON dbo.FactBenchmarkEvaluation(SubmissionDateSK);
PRINT 'Non-clustered indexes on FactBenchmarkEvaluation FKs checked/created.';
GO

-- For FactModelEvaluationScore
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_FactModelEvaluationScore_ModelSK' AND object_id = OBJECT_ID('dbo.FactModelEvaluationScore'))
    CREATE NONCLUSTERED INDEX IX_FactModelEvaluationScore_ModelSK ON dbo.FactModelEvaluationScore(ModelSK);
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_FactModelEvaluationScore_UploadDateSK' AND object_id = OBJECT_ID('dbo.FactModelEvaluationScore'))
    CREATE NONCLUSTERED INDEX IX_FactModelEvaluationScore_UploadDateSK ON dbo.FactModelEvaluationScore(UploadDateSK);
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_FactModelEvaluationScore_SubmissionDateSK' AND object_id = OBJECT_ID('dbo.FactModelEvaluationScore'))
    CREATE NONCLUSTERED INDEX IX_FactModelEvaluationScore_SubmissionDateSK ON dbo.FactModelEvaluationScore(SubmissionDateSK);
PRINT 'Non-clustered indexes on FactModelEvaluationScore FKs checked/created.';
GO

PRINT '=====================================================================';
PRINT 'All Data Warehouse tables created/recreated and setup successfully.';
PRINT '=====================================================================';
GO

-- Verification steps (optional, can be run separately)
PRINT 'Verification:';
SELECT * FROM dbo.DimDate WHERE DateSK = 0;
SELECT TOP 5 * FROM dbo.DimDate ORDER BY DateSK DESC;
SELECT TOP 5 * FROM dbo.DimModel;
SELECT TOP 5 * FROM dbo.DimBenchmark;
SELECT 'DimDate Row Count:', COUNT(*) FROM dbo.DimDate;
SELECT 'DimModel Row Count:', COUNT(*) FROM dbo.DimModel;
SELECT 'DimBenchmark Row Count:', COUNT(*) FROM dbo.DimBenchmark;
SELECT 'FactBenchmarkEvaluation Row Count:', COUNT(*) FROM dbo.FactBenchmarkEvaluation;
SELECT 'FactModelEvaluationScore Row Count:', COUNT(*) FROM dbo.FactModelEvaluationScore;
GO