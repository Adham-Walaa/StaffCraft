-- Migration script to add password_hash column to Employee table
-- Run this script on existing MILESTONE2 databases

USE MILESTONE2;
GO

-- Check if the column already exists before adding it
IF NOT EXISTS (SELECT 1 FROM sys.columns 
               WHERE object_id = OBJECT_ID('dbo.Employee') 
               AND name = 'password_hash')
BEGIN
    ALTER TABLE Employee
    ADD password_hash varchar(255) NULL;
    
    PRINT 'password_hash column added successfully to Employee table';
END
ELSE
BEGIN
    PRINT 'password_hash column already exists in Employee table';
END
GO
