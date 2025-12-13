-- ========================================
-- FIX FOR MISSING PASSWORD_HASH COLUMN
-- ========================================
-- This script adds the password_hash column to the Employee table
-- if it doesn't already exist. Run this if you're getting the error:
-- "Invalid column name 'password_hash'"
-- ========================================

USE MILESTONE2;
GO

-- Check if the column exists and add it if it doesn't
IF NOT EXISTS (
    SELECT 1 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = 'Employee' 
    AND COLUMN_NAME = 'password_hash'
)
BEGIN
    PRINT 'Adding password_hash column to Employee table...';
    ALTER TABLE Employee
    ADD password_hash varchar(255) NULL;
    PRINT 'Column added successfully!';
END
ELSE
BEGIN
    PRINT 'password_hash column already exists.';
END
GO

PRINT 'Fix complete! You can now register and login.';
GO
