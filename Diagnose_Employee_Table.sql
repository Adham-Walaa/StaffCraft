-- ========================================
-- DIAGNOSTIC SCRIPT: Employee Table Schema Check
-- ========================================
-- This script checks the current state of the Employee table
-- and helps identify any schema issues
-- ========================================

USE MILESTONE2;
GO

PRINT '========================================';
PRINT 'EMPLOYEE TABLE DIAGNOSTIC REPORT';
PRINT '========================================';
PRINT '';

-- Check if Employee table exists
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'Employee')
BEGIN
    PRINT 'ERROR: Employee table does not exist!';
    PRINT 'You need to run Tables.sql to create the database schema.';
END
ELSE
BEGIN
    PRINT 'Employee table exists: ✓';
    PRINT '';
    
    -- Check for password_hash columns
    PRINT '--- Checking password_hash column(s) ---';
    DECLARE @ColumnCount INT;
    SELECT @ColumnCount = COUNT(*) 
    FROM sys.columns 
    WHERE object_id = OBJECT_ID('dbo.Employee') 
    AND name = 'password_hash';
    
    PRINT CONCAT('Number of password_hash columns found: ', @ColumnCount);
    
    IF @ColumnCount = 0
    BEGIN
        PRINT 'ERROR: No password_hash column found!';
        PRINT 'The Employee table is missing the password_hash column.';
        PRINT '';
        PRINT 'SOLUTION: Run Fix_Password_Hash_Column.sql to recreate the table with correct schema.';
    END
    ELSE IF @ColumnCount = 1
    BEGIN
        PRINT 'SUCCESS: Exactly one password_hash column exists ✓';
        
        -- Show column details
        SELECT 
            COLUMN_NAME as 'Column Name',
            DATA_TYPE as 'Data Type',
            CHARACTER_MAXIMUM_LENGTH as 'Max Length',
            IS_NULLABLE as 'Nullable',
            ORDINAL_POSITION as 'Position'
        FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_NAME = 'Employee' 
        AND COLUMN_NAME = 'password_hash';
        
        PRINT '';
        PRINT 'Column details look correct ✓';
    END
    ELSE
    BEGIN
        PRINT CONCAT('ERROR: Multiple password_hash columns found (', @ColumnCount, ' columns)!');
        PRINT 'This is the duplicate column issue.';
        PRINT '';
        
        -- Show all password_hash columns
        SELECT 
            COLUMN_NAME as 'Column Name',
            DATA_TYPE as 'Data Type',
            CHARACTER_MAXIMUM_LENGTH as 'Max Length',
            IS_NULLABLE as 'Nullable',
            ORDINAL_POSITION as 'Position'
        FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_NAME = 'Employee' 
        AND COLUMN_NAME = 'password_hash';
        
        PRINT '';
        PRINT 'SOLUTION: Run Fix_Password_Hash_Column.sql to fix this issue.';
    END
    
    PRINT '';
    PRINT '--- All Employee table columns (in order) ---';
    
    -- Show all columns in the Employee table
    SELECT 
        ORDINAL_POSITION as 'Pos',
        COLUMN_NAME as 'Column Name',
        DATA_TYPE as 'Type',
        CHARACTER_MAXIMUM_LENGTH as 'MaxLen',
        IS_NULLABLE as 'Null?'
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'Employee'
    ORDER BY ORDINAL_POSITION;
    
    PRINT '';
    PRINT '--- Checking Employee records ---';
    
    DECLARE @EmployeeCount INT;
    SELECT @EmployeeCount = COUNT(*) FROM dbo.Employee;
    PRINT CONCAT('Total employees in database: ', @EmployeeCount);
    
    IF @EmployeeCount > 0
    BEGIN
        PRINT '';
        PRINT 'Sample employee data (first 3 records):';
        SELECT TOP 3
            EmployeeID,
            first_name,
            last_name,
            email,
            CASE 
                WHEN password_hash IS NULL THEN 'NULL'
                WHEN LEN(password_hash) > 0 THEN CONCAT('Set (', LEN(password_hash), ' chars)')
                ELSE 'Empty'
            END as password_status,
            is_active
        FROM dbo.Employee;
    END
END

PRINT '';
PRINT '========================================';
PRINT 'DIAGNOSTIC COMPLETE';
PRINT '========================================';
PRINT '';
PRINT 'NEXT STEPS:';
PRINT '1. If you see duplicate password_hash columns: Run Fix_Password_Hash_Column.sql';
PRINT '2. If password_hash column is missing: Run Fix_Password_Hash_Column.sql';
PRINT '3. If everything looks correct: Try registering again and check application error logs';
PRINT '';
GO
