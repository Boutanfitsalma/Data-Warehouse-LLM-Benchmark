-- ===================================================================
-- Phase 1, Step 1: Create Staging Schema and Table (Using VARCHAR)
-- ===================================================================
USE LLMPerformanceDW; -- Ensure you are in the correct database context
GO

-- Create a schema for staging tables if it doesn't exist
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'stg')
BEGIN
    EXEC('CREATE SCHEMA stg');
    PRINT 'Schema "stg" created successfully.';
END
ELSE
BEGIN
    PRINT 'Schema "stg" already exists.';
END
GO

-- Drop the staging table if it already exists (for easy re-runs during development)
IF OBJECT_ID('stg.RawLLMPerformanceData', 'U') IS NOT NULL
    DROP TABLE stg.RawLLMPerformanceData;
GO

-- Create the Staging Table to hold raw CSV data (Using VARCHAR)
CREATE TABLE stg.RawLLMPerformanceData (
    -- Using VARCHAR for most columns from CSV.
    -- Ensure your CSV data does not contain Unicode characters that require NVARCHAR.
    id VARCHAR(2000) NULL,
    model_name VARCHAR(MAX) NULL, -- Or a more specific VARCHAR(500) or VARCHAR(8000)
    model_sha VARCHAR(255) NULL,
    model_precision VARCHAR(100) NULL,
    model_type VARCHAR(255) NULL,
    model_weight_type VARCHAR(255) NULL,
    model_architecture VARCHAR(255) NULL,
    model_average_score VARCHAR(50) NULL,       -- Store as string, convert to DECIMAL later
    model_has_chat_template VARCHAR(50) NULL, -- Store as string ('true'/'false'), convert to BIT later
    evaluations_ifeval_name VARCHAR(255) NULL,
    evaluations_ifeval_value VARCHAR(50) NULL,      -- Store as string, convert to DECIMAL later
    evaluations_ifeval_normalized_score VARCHAR(50) NULL, -- Store as string, convert to DECIMAL later
    evaluations_bbh_name VARCHAR(255) NULL,
    evaluations_bbh_value VARCHAR(50) NULL,         -- Store as string, convert to DECIMAL later
    evaluations_bbh_normalized_score VARCHAR(50) NULL, -- Store as string, convert to DECIMAL later
    evaluations_math_name VARCHAR(255) NULL,
    evaluations_math_value VARCHAR(50) NULL,        -- Store as string, convert to DECIMAL later
    evaluations_math_normalized_score VARCHAR(50) NULL, -- Store as string, convert to DECIMAL later
    evaluations_gpqa_name VARCHAR(255) NULL,
    evaluations_gpqa_value VARCHAR(50) NULL,        -- Store as string, convert to DECIMAL later
    evaluations_gpqa_normalized_score VARCHAR(50) NULL, -- Store as string, convert to DECIMAL later
    evaluations_musr_name VARCHAR(255) NULL,
    evaluations_musr_value VARCHAR(50) NULL,        -- Store as string, convert to DECIMAL later
    evaluations_musr_normalized_score VARCHAR(50) NULL, -- Store as string, convert to DECIMAL later
    evaluations_mmlu_pro_name VARCHAR(255) NULL,
    evaluations_mmlu_pro_value VARCHAR(50) NULL,    -- Store as string, convert to DECIMAL later
    evaluations_mmlu_pro_normalized_score VARCHAR(50) NULL, -- Store as string, convert to DECIMAL later
    features_is_not_available_on_hub VARCHAR(50) NULL, -- Store as string, convert to BIT later
    features_is_merged VARCHAR(50) NULL,               -- Store as string, convert to BIT later
    features_is_moe VARCHAR(50) NULL,                  -- Store as string, convert to BIT later
    features_is_flagged VARCHAR(50) NULL,              -- Store as string, convert to BIT later
    features_is_official_provider VARCHAR(50) NULL,    -- Store as string, convert to BIT later
    metadata_upload_date VARCHAR(50) NULL,           -- Store as string, convert to DATE later
    metadata_submission_date VARCHAR(50) NULL,       -- Store as string, convert to DATE later
    metadata_generation VARCHAR(MAX) NULL,
    metadata_base_model VARCHAR(MAX) NULL,
    metadata_hub_license VARCHAR(MAX) NULL,
    metadata_hub_hearts VARCHAR(50) NULL,           -- Store as string, convert to INT later
    metadata_params_billions VARCHAR(50) NULL,      -- Store as string, convert to DECIMAL later
    metadata_co2_cost VARCHAR(50) NULL,             -- Store as string, convert to DECIMAL later

    _LoadDateTime DATETIME2(7) DEFAULT GETDATE() -- Timestamp of when the row was loaded
);
GO

PRINT 'Staging table "stg.RawLLMPerformanceData" (using VARCHAR) created successfully.';
GO