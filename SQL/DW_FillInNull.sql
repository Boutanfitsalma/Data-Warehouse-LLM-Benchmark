use LLMPerformanceDW
go
UPDATE stg.RawLLMPerformanceData
SET metadata_submission_date = '1900-01-01'
WHERE metadata_submission_date = '""';

UPDATE stg.RawLLMPerformanceData
SET metadata_upload_date = '1900-01-01'
WHERE metadata_upload_date = '""';