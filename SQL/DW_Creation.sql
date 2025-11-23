-- ===================================================================
-- Script to Create the Data Warehouse Database (If not already done)
-- RUN THIS PART ONLY ONCE IF THE DATABASE DOESN'T EXIST
-- ===================================================================
USE master; -- Switch to the master database to create a new database
GO

IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'LLMPerformanceDW')
BEGIN
    CREATE DATABASE LLMPerformanceDW;
    PRINT 'Database LLMPerformanceDW created successfully.';
END
ELSE
BEGIN
    PRINT 'Database LLMPerformanceDW already exists.';
END
GO