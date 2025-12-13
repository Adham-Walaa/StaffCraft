-- ========================================
-- FIX: Remove Duplicate password_hash Column
-- ========================================
-- This script fixes the duplicate password_hash column issue in the Employee table
-- Run this script if you're experiencing "Invalid column name 'password_hash'" errors during registration
-- ========================================

USE MILESTONE2;
GO

-- Check if the duplicate column issue exists
IF EXISTS (
    SELECT 1 
    FROM sys.columns 
    WHERE object_id = OBJECT_ID('dbo.Employee') 
    AND name = 'password_hash'
)
BEGIN
    PRINT 'Fixing Employee table schema...';
    
    -- Step 1: Drop all foreign key constraints that reference the Employee table
    DECLARE @sql NVARCHAR(MAX) = '';
    
    SELECT @sql = @sql + 'ALTER TABLE ' + QUOTENAME(OBJECT_SCHEMA_NAME(parent_object_id)) + '.' + QUOTENAME(OBJECT_NAME(parent_object_id)) + 
                  ' DROP CONSTRAINT ' + QUOTENAME(name) + ';' + CHAR(13)
    FROM sys.foreign_keys
    WHERE referenced_object_id = OBJECT_ID('dbo.Employee');
    
    -- Execute dropping foreign keys
    IF @sql <> ''
    BEGIN
        PRINT 'Dropping foreign key constraints...';
        EXEC sp_executesql @sql;
    END
    
    -- Step 2: Create a temporary table with the correct schema
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
    
    -- Step 3: Copy data from old table to new table
    PRINT 'Copying data to temporary table...';
    
    INSERT INTO dbo.Employee_Temp 
    (
        EmployeeID,
        first_name,
        last_name,
        national_id,
        date_of_birth,
        country_of_birth,
        phone,
        email,
        address,
        emergency_contact_name,
        emergency_contact_phone,
        relationship,
        biography,
        profile_image,
        employment_progress,
        account_status,
        employment_status,
        hire_date,
        is_active,
        department_id,
        position_id,
        paygrade_id,
        taxform_id,
        manager_id,
        salary_type_id,
        contract_id,
        profile_completion_percentage,
        password_hash
    )
    SELECT 
        EmployeeID,
        first_name,
        last_name,
        national_id,
        date_of_birth,
        country_of_birth,
        phone,
        email,
        address,
        emergency_contact_name,
        emergency_contact_phone,
        relationship,
        biography,
        profile_image,
        employment_progress,
        account_status,
        employment_status,
        hire_date,
        is_active,
        department_id,
        position_id,
        paygrade_id,
        taxform_id,
        manager_id,
        salary_type_id,
        contract_id,
        profile_completion_percentage,
        password_hash
    FROM dbo.Employee;
    
    -- Step 4: Drop the old table
    PRINT 'Dropping old Employee table...';
    DROP TABLE dbo.Employee;
    
    -- Step 5: Rename temp table to Employee
    PRINT 'Renaming temporary table to Employee...';
    EXEC sp_rename 'dbo.Employee_Temp', 'Employee';
    
    -- Step 6: Recreate foreign key constraints
    PRINT 'Recreating foreign key constraints...';
    
    ALTER TABLE HRAdministrator
    ADD CONSTRAINT FK_HRAdministrator_Employee FOREIGN KEY (employee_id) REFERENCES Employee(EmployeeID);
    
    ALTER TABLE SystemAdministrator
    ADD CONSTRAINT FK_SystemAdministrator_Employee FOREIGN KEY (employee_id) REFERENCES Employee(EmployeeID);
    
    ALTER TABLE PayrollSpecialist
    ADD CONSTRAINT FK_PayrollSpecialist_Employee FOREIGN KEY (employee_id) REFERENCES Employee(EmployeeID);
    
    ALTER TABLE LineManager
    ADD CONSTRAINT FK_LineManager_Employee FOREIGN KEY (employee_id) REFERENCES Employee(EmployeeID);
    
    ALTER TABLE Department
    ADD CONSTRAINT FK_Department_Employee FOREIGN KEY (department_head_id) REFERENCES Employee(EmployeeID);
    
    ALTER TABLE EmployeeSkill
    ADD CONSTRAINT FK_EmployeeSkill_Employee FOREIGN KEY (employee_id) REFERENCES Employee(EmployeeID);
    
    ALTER TABLE EmployeeVerification
    ADD CONSTRAINT FK_EmployeeVerification_Employee FOREIGN KEY (employee_id) REFERENCES Employee(EmployeeID);
    
    ALTER TABLE EmployeeRole
    ADD CONSTRAINT FK_EmployeeRole_Employee FOREIGN KEY (employee_id) REFERENCES Employee(EmployeeID);
    
    ALTER TABLE Reimbursement
    ADD CONSTRAINT FK_Reimbursement_Employee FOREIGN KEY (employee_id) REFERENCES Employee(EmployeeID);
    
    ALTER TABLE Mission
    ADD CONSTRAINT FK_Mission_Employee FOREIGN KEY (employee_id) REFERENCES Employee(EmployeeID);
    
    ALTER TABLE Mission
    ADD CONSTRAINT FK_Mission_Manager FOREIGN KEY (manager_id) REFERENCES Employee(EmployeeID);
    
    ALTER TABLE LeaveRequest
    ADD CONSTRAINT FK_LeaveRequest_Employee FOREIGN KEY (employee_id) REFERENCES Employee(EmployeeID);
    
    ALTER TABLE LeaveEntitlement
    ADD CONSTRAINT FK_LeaveEntitlement_Employee FOREIGN KEY (employee_id) REFERENCES Employee(EmployeeID);
    
    ALTER TABLE Attendance
    ADD CONSTRAINT FK_Attendance_Employee FOREIGN KEY (employee_id) REFERENCES Employee(EmployeeID);
    
    ALTER TABLE AttendanceCorrectionRequest
    ADD CONSTRAINT FK_AttendanceCorrectionRequest_Employee FOREIGN KEY (employee_id) REFERENCES Employee(EmployeeID);
    
    ALTER TABLE AttendanceCorrectionRequest
    ADD CONSTRAINT FK_AttendanceCorrectionRequest_RecommendedBy FOREIGN KEY (recommended_by) REFERENCES Employee(EmployeeID);
    
    ALTER TABLE ShiftSchedule
    ADD CONSTRAINT FK_ShiftSchedule_Employee FOREIGN KEY (employee_id) REFERENCES Employee(EmployeeID);
    
    ALTER TABLE EmployeeException
    ADD CONSTRAINT FK_EmployeeException_Employee FOREIGN KEY (employee_id) REFERENCES Employee(EmployeeID);
    
    ALTER TABLE Payroll
    ADD CONSTRAINT FK_Payroll_Employee FOREIGN KEY (employee_id) REFERENCES Employee(EmployeeID);
    
    ALTER TABLE AllowanceDeduction
    ADD CONSTRAINT FK_AllowanceDeduction_Employee FOREIGN KEY (employee_id) REFERENCES Employee(EmployeeID);
    
    ALTER TABLE EmployeeNotification
    ADD CONSTRAINT FK_EmployeeNotification_Employee FOREIGN KEY (employee_id) REFERENCES Employee(EmployeeID);
    
    ALTER TABLE EmployeeHierarchy
    ADD CONSTRAINT FK_EmployeeHierarchy_Employee FOREIGN KEY (employee_id) REFERENCES Employee(EmployeeID);
    
    ALTER TABLE EmployeeHierarchy
    ADD CONSTRAINT FK_EmployeeHierarchy_Manager FOREIGN KEY (manager_id) REFERENCES Employee(EmployeeID);
    
    ALTER TABLE Device
    ADD CONSTRAINT FK_Device_Employee FOREIGN KEY (employee_id) REFERENCES Employee(EmployeeID);
    
    ALTER TABLE ApprovalWorkflow
    ADD CONSTRAINT FK_ApprovalWorkflow_CreatedBy FOREIGN KEY (created_by) REFERENCES Employee(EmployeeID);
    
    ALTER TABLE ManagerNotes
    ADD CONSTRAINT FK_ManagerNotes_Employee FOREIGN KEY (employee_id) REFERENCES Employee(EmployeeID);
    
    ALTER TABLE ManagerNotes
    ADD CONSTRAINT FK_ManagerNotes_Manager FOREIGN KEY (manager_id) REFERENCES Employee(EmployeeID);
    
    ALTER TABLE Employee
    ADD CONSTRAINT FK_Employee_Position FOREIGN KEY (position_id) REFERENCES Position(PositionID);
    
    ALTER TABLE Employee
    ADD CONSTRAINT FK_Employee_PayGrade FOREIGN KEY (paygrade_id) REFERENCES PayGrade(PayGradeID);
    
    ALTER TABLE Employee
    ADD CONSTRAINT FK_Employee_TaxForm FOREIGN KEY (taxform_id) REFERENCES TaxForm(TaxFormID);
    
    ALTER TABLE Employee
    ADD CONSTRAINT FK_Employee_Department FOREIGN KEY (department_id) REFERENCES Department(DepartmentID);
    
    ALTER TABLE Employee
    ADD CONSTRAINT FK_Employee_Manager FOREIGN KEY (manager_id) REFERENCES Employee(EmployeeID);
    
    ALTER TABLE Employee
    ADD CONSTRAINT FK_Employee_SalaryType FOREIGN KEY (salary_type_id) REFERENCES SalaryType(SalaryTypeID);
    
    ALTER TABLE Employee
    ADD CONSTRAINT FK_Employee_Contract FOREIGN KEY (contract_id) REFERENCES Contract(ContractID);
    
    PRINT 'Employee table schema fixed successfully!';
    PRINT 'You can now register new accounts without the "Invalid column name" error.';
END
ELSE
BEGIN
    PRINT 'Employee table schema is already correct. No changes needed.';
END
GO
