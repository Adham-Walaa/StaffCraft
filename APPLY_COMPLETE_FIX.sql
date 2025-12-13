-- ========================================
-- COMPLETE DATABASE FIX - ONE-CLICK SOLUTION
-- ========================================
-- This script will:
-- 1. Check if MILESTONE2 database exists
-- 2. Fix the Employee table schema (remove duplicate password_hash)
-- 3. Add the SetEmployeePassword stored procedure
-- 4. Run diagnostics to verify everything is correct
-- ========================================

PRINT '========================================';
PRINT 'STARTING COMPLETE DATABASE FIX';
PRINT '========================================';
PRINT '';

-- Check if database exists
IF NOT EXISTS (SELECT 1 FROM sys.databases WHERE name = 'MILESTONE2')
BEGIN
    PRINT 'ERROR: Database MILESTONE2 does not exist!';
    PRINT 'Please create the database first by running Tables.sql';
    PRINT '';
    RAISERROR('Database MILESTONE2 not found.', 16, 1);
    RETURN;
END

USE MILESTONE2;
GO

PRINT 'Using database: MILESTONE2';
PRINT '';

-- ========================================
-- STEP 1: Fix Employee Table Schema
-- ========================================
PRINT '========================================';
PRINT 'STEP 1: Fixing Employee Table Schema';
PRINT '========================================';
PRINT '';

-- Check if Employee table exists
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'Employee')
BEGIN
    PRINT 'ERROR: Employee table does not exist!';
    PRINT 'Please run Tables.sql first to create the database schema.';
    PRINT '';
    RAISERROR('Employee table not found.', 16, 1);
    RETURN;
END

-- Check for duplicate password_hash columns
DECLARE @ColumnCount INT;
SELECT @ColumnCount = COUNT(*) 
FROM sys.columns 
WHERE object_id = OBJECT_ID('dbo.Employee') 
AND name = 'password_hash';

PRINT CONCAT('Found ', @ColumnCount, ' password_hash column(s)');

IF @ColumnCount = 0
BEGIN
    PRINT 'ERROR: No password_hash column found!';
    PRINT 'Adding password_hash column to Employee table...';
    
    ALTER TABLE dbo.Employee
    ADD password_hash varchar(255) NULL;
    
    PRINT 'password_hash column added successfully!';
END
ELSE IF @ColumnCount = 1
BEGIN
    PRINT 'SUCCESS: Employee table has correct schema (1 password_hash column) ✓';
END
ELSE
BEGIN
    PRINT CONCAT('WARNING: Multiple password_hash columns detected (', @ColumnCount, ' columns)!');
    PRINT 'Fixing duplicate column issue...';
    
    -- Drop all foreign key constraints referencing Employee table
    DECLARE @sql NVARCHAR(MAX) = '';
    
    SELECT @sql = @sql + 'ALTER TABLE ' + QUOTENAME(OBJECT_SCHEMA_NAME(parent_object_id)) + '.' + QUOTENAME(OBJECT_NAME(parent_object_id)) + 
                  ' DROP CONSTRAINT ' + QUOTENAME(name) + ';' + CHAR(13)
    FROM sys.foreign_keys
    WHERE referenced_object_id = OBJECT_ID('dbo.Employee');
    
    IF @sql <> ''
    BEGIN
        PRINT 'Dropping foreign key constraints...';
        EXEC sp_executesql @sql;
    END
    
    -- Create temporary table with correct schema
    PRINT 'Creating temporary table with correct schema...';
    CREATE TABLE dbo.Employee_Temp
    (
        EmployeeID int PRIMARY KEY,
        first_name varchar(50),
        last_name varchar(50),
        full_name AS (first_name + ' ' + last_name) PERSISTED,
        national_id varchar(20),
        date_of_birth datetime,
        country_of_birth varchar(50),
        phone varchar(15),
        email varchar(100),
        address varchar(200),
        emergency_contact_name varchar(100),
        emergency_contact_phone varchar(15),
        relationship varchar(50),
        biography text,
        profile_image varbinary(max),
        employment_progress varchar(100),
        account_status varchar(50),
        employment_status varchar(50),
        hire_date datetime,
        is_active bit DEFAULT 1,
        department_id int,
        position_id int,
        paygrade_id int,
        taxform_id int,
        manager_id int,
        salary_type_id int,
        contract_id int,
        profile_completion_percentage int CHECK (profile_completion_percentage BETWEEN 0 AND 100),
        password_hash varchar(255) NULL
    );
    
    -- Copy data from old table to new table
    PRINT 'Copying data to temporary table...';
    
    INSERT INTO dbo.Employee_Temp 
    (
        EmployeeID, first_name, last_name, national_id, date_of_birth, country_of_birth,
        phone, email, address, emergency_contact_name, emergency_contact_phone,
        relationship, biography, profile_image, employment_progress, account_status,
        employment_status, hire_date, is_active, department_id, position_id,
        paygrade_id, taxform_id, manager_id, salary_type_id, contract_id,
        profile_completion_percentage, password_hash
    )
    SELECT 
        EmployeeID, first_name, last_name, national_id, date_of_birth, country_of_birth,
        phone, email, address, emergency_contact_name, emergency_contact_phone,
        relationship, biography, profile_image, employment_progress, account_status,
        employment_status, hire_date, is_active, department_id, position_id,
        paygrade_id, taxform_id, manager_id, salary_type_id, contract_id,
        profile_completion_percentage, password_hash
    FROM dbo.Employee;
    
    PRINT CONCAT('Copied ', @@ROWCOUNT, ' employee records');
    
    -- Drop the old table
    PRINT 'Dropping old Employee table...';
    DROP TABLE dbo.Employee;
    
    -- Rename temp table to Employee
    PRINT 'Renaming temporary table to Employee...';
    EXEC sp_rename 'dbo.Employee_Temp', 'Employee';
    
    -- Recreate foreign key constraints
    PRINT 'Recreating foreign key constraints...';
    
    ALTER TABLE HRAdministrator ADD CONSTRAINT FK_HRAdministrator_Employee FOREIGN KEY (employee_id) REFERENCES Employee(EmployeeID);
    ALTER TABLE SystemAdministrator ADD CONSTRAINT FK_SystemAdministrator_Employee FOREIGN KEY (employee_id) REFERENCES Employee(EmployeeID);
    ALTER TABLE PayrollSpecialist ADD CONSTRAINT FK_PayrollSpecialist_Employee FOREIGN KEY (employee_id) REFERENCES Employee(EmployeeID);
    ALTER TABLE LineManager ADD CONSTRAINT FK_LineManager_Employee FOREIGN KEY (employee_id) REFERENCES Employee(EmployeeID);
    ALTER TABLE Department ADD CONSTRAINT FK_Department_Employee FOREIGN KEY (department_head_id) REFERENCES Employee(EmployeeID);
    ALTER TABLE EmployeeSkill ADD CONSTRAINT FK_EmployeeSkill_Employee FOREIGN KEY (employee_id) REFERENCES Employee(EmployeeID);
    ALTER TABLE EmployeeVerification ADD CONSTRAINT FK_EmployeeVerification_Employee FOREIGN KEY (employee_id) REFERENCES Employee(EmployeeID);
    ALTER TABLE EmployeeRole ADD CONSTRAINT FK_EmployeeRole_Employee FOREIGN KEY (employee_id) REFERENCES Employee(EmployeeID);
    ALTER TABLE Reimbursement ADD CONSTRAINT FK_Reimbursement_Employee FOREIGN KEY (employee_id) REFERENCES Employee(EmployeeID);
    ALTER TABLE Mission ADD CONSTRAINT FK_Mission_Employee FOREIGN KEY (employee_id) REFERENCES Employee(EmployeeID);
    ALTER TABLE Mission ADD CONSTRAINT FK_Mission_Manager FOREIGN KEY (manager_id) REFERENCES Employee(EmployeeID);
    ALTER TABLE LeaveRequest ADD CONSTRAINT FK_LeaveRequest_Employee FOREIGN KEY (employee_id) REFERENCES Employee(EmployeeID);
    ALTER TABLE LeaveEntitlement ADD CONSTRAINT FK_LeaveEntitlement_Employee FOREIGN KEY (employee_id) REFERENCES Employee(EmployeeID);
    ALTER TABLE Attendance ADD CONSTRAINT FK_Attendance_Employee FOREIGN KEY (employee_id) REFERENCES Employee(EmployeeID);
    ALTER TABLE AttendanceCorrectionRequest ADD CONSTRAINT FK_AttendanceCorrectionRequest_Employee FOREIGN KEY (employee_id) REFERENCES Employee(EmployeeID);
    ALTER TABLE AttendanceCorrectionRequest ADD CONSTRAINT FK_AttendanceCorrectionRequest_RecommendedBy FOREIGN KEY (recommended_by) REFERENCES Employee(EmployeeID);
    ALTER TABLE ShiftSchedule ADD CONSTRAINT FK_ShiftSchedule_Employee FOREIGN KEY (employee_id) REFERENCES Employee(EmployeeID);
    ALTER TABLE EmployeeException ADD CONSTRAINT FK_EmployeeException_Employee FOREIGN KEY (employee_id) REFERENCES Employee(EmployeeID);
    ALTER TABLE Payroll ADD CONSTRAINT FK_Payroll_Employee FOREIGN KEY (employee_id) REFERENCES Employee(EmployeeID);
    ALTER TABLE AllowanceDeduction ADD CONSTRAINT FK_AllowanceDeduction_Employee FOREIGN KEY (employee_id) REFERENCES Employee(EmployeeID);
    ALTER TABLE EmployeeNotification ADD CONSTRAINT FK_EmployeeNotification_Employee FOREIGN KEY (employee_id) REFERENCES Employee(EmployeeID);
    ALTER TABLE EmployeeHierarchy ADD CONSTRAINT FK_EmployeeHierarchy_Employee FOREIGN KEY (employee_id) REFERENCES Employee(EmployeeID);
    ALTER TABLE EmployeeHierarchy ADD CONSTRAINT FK_EmployeeHierarchy_Manager FOREIGN KEY (manager_id) REFERENCES Employee(EmployeeID);
    ALTER TABLE Device ADD CONSTRAINT FK_Device_Employee FOREIGN KEY (employee_id) REFERENCES Employee(EmployeeID);
    ALTER TABLE ApprovalWorkflow ADD CONSTRAINT FK_ApprovalWorkflow_CreatedBy FOREIGN KEY (created_by) REFERENCES Employee(EmployeeID);
    ALTER TABLE ManagerNotes ADD CONSTRAINT FK_ManagerNotes_Employee FOREIGN KEY (employee_id) REFERENCES Employee(EmployeeID);
    ALTER TABLE ManagerNotes ADD CONSTRAINT FK_ManagerNotes_Manager FOREIGN KEY (manager_id) REFERENCES Employee(EmployeeID);
    ALTER TABLE Employee ADD CONSTRAINT FK_Employee_Position FOREIGN KEY (position_id) REFERENCES Position(PositionID);
    ALTER TABLE Employee ADD CONSTRAINT FK_Employee_PayGrade FOREIGN KEY (paygrade_id) REFERENCES PayGrade(PayGradeID);
    ALTER TABLE Employee ADD CONSTRAINT FK_Employee_TaxForm FOREIGN KEY (taxform_id) REFERENCES TaxForm(TaxFormID);
    ALTER TABLE Employee ADD CONSTRAINT FK_Employee_Department FOREIGN KEY (department_id) REFERENCES Department(DepartmentID);
    ALTER TABLE Employee ADD CONSTRAINT FK_Employee_Manager FOREIGN KEY (manager_id) REFERENCES Employee(EmployeeID);
    ALTER TABLE Employee ADD CONSTRAINT FK_Employee_SalaryType FOREIGN KEY (salary_type_id) REFERENCES SalaryType(SalaryTypeID);
    ALTER TABLE Employee ADD CONSTRAINT FK_Employee_Contract FOREIGN KEY (contract_id) REFERENCES Contract(ContractID);
    
    PRINT 'Employee table schema fixed successfully!';
END

PRINT '';
PRINT '========================================';
PRINT 'STEP 2: Adding SetEmployeePassword Procedure';
PRINT '========================================';
PRINT '';

-- Create or update the SetEmployeePassword stored procedure
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'SetEmployeePassword')
BEGIN
    PRINT 'SetEmployeePassword procedure already exists, updating...';
END
ELSE
BEGIN
    PRINT 'Creating SetEmployeePassword procedure...';
END

EXEC('
CREATE OR ALTER PROCEDURE dbo.SetEmployeePassword
    @EmployeeID INT,
    @PasswordHash VARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validate employee exists
    IF NOT EXISTS (SELECT 1 FROM dbo.Employee WHERE EmployeeID = @EmployeeID)
    BEGIN
        RAISERROR(''Employee with ID %d does not exist.'', 16, 1, @EmployeeID);
        RETURN;
    END;
    
    -- Update password hash
    UPDATE dbo.Employee
    SET password_hash = @PasswordHash
    WHERE EmployeeID = @EmployeeID;
    
    SELECT ''Password updated successfully'' AS Message;
END;
');

PRINT 'SetEmployeePassword procedure created/updated successfully! ✓';
PRINT '';

-- ========================================
-- STEP 3: Run Diagnostics
-- ========================================
PRINT '========================================';
PRINT 'STEP 3: Running Diagnostics';
PRINT '========================================';
PRINT '';

-- Check password_hash column
SELECT @ColumnCount = COUNT(*) 
FROM sys.columns 
WHERE object_id = OBJECT_ID('dbo.Employee') 
AND name = 'password_hash';

PRINT CONCAT('password_hash columns: ', @ColumnCount, ' (should be 1)');

IF @ColumnCount = 1
    PRINT '✓ PASS: Exactly one password_hash column exists';
ELSE
    PRINT '✗ FAIL: Wrong number of password_hash columns!';

-- Check SetEmployeePassword procedure
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'SetEmployeePassword')
    PRINT '✓ PASS: SetEmployeePassword procedure exists';
ELSE
    PRINT '✗ FAIL: SetEmployeePassword procedure not found!';

-- Show column details
PRINT '';
PRINT 'Password hash column details:';
SELECT 
    COLUMN_NAME as [Column],
    DATA_TYPE as [Type],
    CHARACTER_MAXIMUM_LENGTH as [Length],
    IS_NULLABLE as [Nullable]
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Employee' 
AND COLUMN_NAME = 'password_hash';

-- Count employees
DECLARE @EmployeeCount INT;
SELECT @EmployeeCount = COUNT(*) FROM dbo.Employee;
PRINT '';
PRINT CONCAT('Total employees in database: ', @EmployeeCount);

PRINT '';
PRINT '========================================';
PRINT 'FIX COMPLETE!';
PRINT '========================================';
PRINT '';
PRINT 'Next steps:';
PRINT '1. Rebuild your application in Visual Studio (Build -> Rebuild Solution)';
PRINT '2. Press F5 to run the application';
PRINT '3. Try registering a new account';
PRINT '';
PRINT 'If you still have issues, check the application error logs in Visual Studio Output window.';
PRINT '';
GO
