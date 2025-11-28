-- Test script for Procedures.sql

--DROP TABLES PROCEDURE
USE MILESTONE2;
GO

IF OBJECT_ID('sp_DropAllTables', 'P') IS NOT NULL
    DROP PROCEDURE sp_DropAllTables;
GO

CREATE PROCEDURE sp_DropAllTables
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @sql NVARCHAR(MAX);

    -- Disable FK checks
    EXEC sp_msforeachtable 'ALTER TABLE ? NOCHECK CONSTRAINT ALL';

    -- Drop all foreign key constraints
    DECLARE fk_cursor CURSOR FOR
        SELECT 'ALTER TABLE [' + OBJECT_SCHEMA_NAME(parent_object_id) + '].[' + OBJECT_NAME(parent_object_id) + '] DROP CONSTRAINT [' + name + '];'
        FROM sys.foreign_keys;

    OPEN fk_cursor;
    FETCH NEXT FROM fk_cursor INTO @sql;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        EXEC sp_executesql @sql;
        FETCH NEXT FROM fk_cursor INTO @sql;
    END
    CLOSE fk_cursor;
    DEALLOCATE fk_cursor;

    -- Drop all tables dynamically
    DECLARE table_cursor CURSOR FOR
        SELECT '[' + SCHEMA_NAME(schema_id) + '].[' + name + ']' 
        FROM sys.tables;

    OPEN table_cursor;
    FETCH NEXT FROM table_cursor INTO @sql;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @sql = 'DROP TABLE ' + @sql;
        EXEC sp_executesql @sql;
        FETCH NEXT FROM table_cursor INTO @sql;
    END
    CLOSE table_cursor;
    DEALLOCATE table_cursor;

    PRINT 'All tables dropped successfully!';
END
GO

-- Execute the procedure
EXEC sp_DropAllTables;
GO

------------------------
--System Admin Tests
------------------------

-- Currency required by SalaryType
IF NOT EXISTS (SELECT 1 FROM dbo.Currency WHERE CurrencyCode = 'USD')
INSERT INTO dbo.Currency (CurrencyCode, currency_name, exchange_rate, created_date, last_updated)
VALUES ('USD', 'US Dollar', 1.0000, GETDATE(), GETDATE());

-- Positions
IF NOT EXISTS (SELECT 1 FROM dbo.Position WHERE PositionID = 1)
    INSERT INTO dbo.Position (PositionID, position_title, responsibilities, status) VALUES (1, 'Developer', 'Develops software', 'ACTIVE');
IF NOT EXISTS (SELECT 1 FROM dbo.Position WHERE PositionID = 2)
    INSERT INTO dbo.Position (PositionID, position_title, responsibilities, status) VALUES (2, 'Manager', 'Manages team', 'ACTIVE');

-- Departments
IF NOT EXISTS (SELECT 1 FROM dbo.Department WHERE DepartmentID = 1)
    INSERT INTO dbo.Department (DepartmentID, department_name, purpose, department_head_id) VALUES (1, 'Human Resources', 'HR and People Ops', NULL);
IF NOT EXISTS (SELECT 1 FROM dbo.Department WHERE DepartmentID = 2)
    INSERT INTO dbo.Department (DepartmentID, department_name, purpose, department_head_id) VALUES (2, 'Finance', 'Payroll and Finance', NULL);
IF NOT EXISTS (SELECT 1 FROM dbo.Department WHERE DepartmentID = 3)
    INSERT INTO dbo.Department (DepartmentID, department_name, purpose, department_head_id) VALUES (3, 'Engineering', 'Engineering Dept', NULL);

-- Roles (used by AssignRole tests)
IF NOT EXISTS (SELECT 1 FROM dbo.Role WHERE RoleID = 1)
    INSERT INTO dbo.Role (RoleID, role_name, purpose) VALUES (1, 'System Administrator', 'Full system privileges');

IF NOT EXISTS (SELECT 1 FROM dbo.Role WHERE RoleID = 2)
    INSERT INTO dbo.Role (RoleID, role_name, purpose) VALUES (2, 'Payroll Officer', 'Handles payroll');

IF NOT EXISTS (SELECT 1 FROM dbo.Role WHERE RoleID = 3)
    INSERT INTO dbo.Role (RoleID, role_name, purpose) VALUES (3, 'HR Administrator', 'HR administration and records');

IF NOT EXISTS (SELECT 1 FROM dbo.Role WHERE RoleID = 4)
    INSERT INTO dbo.Role (RoleID, role_name, purpose) VALUES (4, 'Line Manager', 'Shift management');

IF NOT EXISTS (SELECT 1 FROM dbo.Role WHERE RoleID = 5)
    INSERT INTO dbo.Role (RoleID, role_name, purpose) VALUES (5, 'Employee', 'Regular employee role');
GO

-- PayGrade
IF NOT EXISTS (SELECT 1 FROM dbo.PayGrade WHERE PayGradeID = 1)
    INSERT INTO dbo.PayGrade (PayGradeID, grade_name, min_salary, max_salary) VALUES (1, 'P1', 30000.00, 50000.00);

-- TaxForm
IF NOT EXISTS (SELECT 1 FROM dbo.TaxForm WHERE TaxFormID = 1)
    INSERT INTO dbo.TaxForm (TaxFormID, jurisdiction, validity_period, form_content) VALUES (1, 'Default', DATEADD(YEAR, 1, GETDATE()), 'Standard tax form');

-- SalaryType (references Currency)
IF NOT EXISTS (SELECT 1 FROM dbo.SalaryType WHERE SalaryTypeID = 1)
    INSERT INTO dbo.SalaryType (SalaryTypeID, type, payment_frequency, currency) VALUES (1, 'Monthly', 'Monthly', 'USD');

-- Contract
IF NOT EXISTS (SELECT 1 FROM dbo.Contract WHERE ContractID = 1)
    INSERT INTO dbo.Contract (ContractID, type, start_date, end_date, current_state) VALUES (1, 'Standard', '2025-01-01', '9999-12-31', 'ACTIVE');
GO

-- Use high, reserved test IDs to avoid duplicate PK collisions
USE MILESTONE2;
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Employee WHERE EmployeeID = 1)
INSERT INTO dbo.Employee (EmployeeID, first_name, last_name, email, hire_date, is_active, department_id, position_id, phone, address)
VALUES (1, 'Alice', 'Smith', 'alice.smith@example.com', '2025-01-15', 1, 1, 1, '555-0100', '123 Main St');

IF NOT EXISTS (SELECT 1 FROM dbo.Employee WHERE EmployeeID = 2)
INSERT INTO dbo.Employee (EmployeeID, first_name, last_name, email, hire_date, is_active, department_id, position_id, phone, address)
VALUES (2, 'Bob', 'Johnson', 'bob.johnson@example.com', '2024-10-01', 1, 2, 2, '555-0200', '456 Elm St');

IF NOT EXISTS (SELECT 1 FROM dbo.Employee WHERE EmployeeID = 3)
INSERT INTO dbo.Employee (EmployeeID, first_name, last_name, email, hire_date, is_active, department_id, position_id, phone, address)
VALUES (3, 'John', 'Doe', 'john.doe@example.com', '2025-02-20', 1, 3, 1, '555-0300', '789 Oak St');

IF NOT EXISTS (SELECT 1 FROM dbo.Employee WHERE EmployeeID = 4)
INSERT INTO dbo.Employee (EmployeeID, first_name, last_name, email, hire_date, is_active, department_id, position_id, phone, address)
VALUES (4, 'Jane', 'Roe', 'jane.roe@example.com', '2023-12-05', 1, 2, 2, '555-0400', '321 Pine St');
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Employee WHERE EmployeeID = 5)
INSERT INTO dbo.Employee (EmployeeID, first_name, last_name, email, national_id, country_of_birth, hire_date, is_active, department_id, position_id, phone, address)
VALUES (5, 'Jaaffar', 'Yakub', 'jaaffar.garry@example.com', '6742069', 'Agartha' , '2007-05-03', 1, 1, 5, '01227425396', 'Land Down Under');
GO


/***** 1) Test ViewEmployeeInfo *****/
EXEC dbo.ViewEmployeeInfo @EmployeeID = 1; --input
EXEC dbo.ViewEmployeeInfo @EmployeeID = 2; --input

/***** 2) Test AddEmployee *****/
DECLARE @Id3 INT, @Id4 INT;
GO

-- Successful inserts
EXEC dbo.AddEmployee
    @FullName = 'Taher Khalaf',  --input
    @Email = 'taher.skhalaf@gmail.com',  --input
    @DepartmentID = 3,  --input
    @PositionID = 2,  --input
    @HireDate = '2025-01-01',  --input
    @NewEmployeeID = @Id3 OUTPUT; --input
SELECT 'Created' AS Action, @Id3 AS EmployeeID;

EXEC dbo.AddEmployee
    @FullName = 'Bob Johnson',  --input
    @Email = 'bob.johnson@example.com',  --input
    @DepartmentID = 2,  --input
    @PositionID = 2,  --input
    @HireDate = '2024-10-01',  --input
    @NewEmployeeID = @Id4 OUTPUT;  --input
SELECT 'Created' AS Action, @Id4 AS EmployeeID;
GO

/***** 3) Test UpdateEmployeeInfo *****/
-- Use a local test variable (avoid colliding with later @Id1/@Id2)

EXEC dbo.UpdateEmployeeInfo
    @EmployeeID = 3,  --input
    @Email      = 'new.updated@example.com',  --input
    @Phone      = '555-0101',  --input
    @Address    = '123 Main St';  --input

-- Verify update
EXEC dbo.ViewEmployeeInfo @EmployeeID = 3;
GO

--PROC TUPLE CHECK:
Select *
From Employee

/***** 4) Test AssignRole *****/
-- Assign Payroll Officer to Alice
EXEC dbo.AssignRole @EmployeeID = 1, @RoleID = 1;  --input
-- Assign Manager role to Bob
EXEC dbo.AssignRole @EmployeeID = 2, @RoleID = 2;  --input
-- Re-assign same role (should return already assigned message)
EXEC dbo.AssignRole @EmployeeID = 1, @RoleID = 1;  --input

EXEC dbo.AssignRole @EmployeeID = 3, @RoleID = 3;  --input
EXEC dbo.AssignRole @EmployeeID = 4, @RoleID = 4;  --input
-- Show EmployeeRole contents for test employees
SELECT * FROM dbo.EmployeeRole er INNER JOIN Role r on er.role_id = r.RoleID WHERE employee_id IN (1, 2, 3, 4);
GO

/***** SubmitLeaveRequest tests *****/
USE MILESTONE2;
GO

PRINT '--- SubmitLeaveRequest tests ---';

-- Ensure leave types exist
IF NOT EXISTS (SELECT 1 FROM dbo.[Leave] WHERE LeaveID = 1)
    INSERT INTO dbo.[Leave] (LeaveID, leave_type, leave_description) VALUES (1, 'Vacation', 'Paid vacation');
IF NOT EXISTS (SELECT 1 FROM dbo.[Leave] WHERE LeaveID = 2)
    INSERT INTO dbo.[Leave] (LeaveID, leave_type, leave_description) VALUES (2, 'Sick', 'Sick leave');

-- Ensure a test employee exists (create via AddEmployee if required)
DECLARE @TestEmp INT;
IF NOT EXISTS (SELECT 1 FROM dbo.Employee WHERE email = 'submit.leave.test@example.com')
BEGIN
    DECLARE @NewEmpID INT;
    EXEC dbo.AddEmployee
        @FullName = 'Submit Leave',
        @Email = 'submit.leave.test@example.com',
        @DepartmentID = 1,
        @PositionID = 1,
        @HireDate = '2025-01-01',
        @NewEmployeeID = @NewEmpID OUTPUT;
    SET @TestEmp = @NewEmpID;
END
ELSE
    SELECT @TestEmp = EmployeeID FROM dbo.Employee WHERE email = 'submit.leave.test@example.com';

PRINT 'Test employee id:' + CONVERT(VARCHAR(12), @TestEmp);

-- 1) Normal submission (should succeed)
PRINT 'Test 1: normal submission (Vacation 2025-09-01 to 2025-09-05)';
BEGIN TRY
    EXEC dbo.SubmitLeaveRequest
        @EmployeeID = @TestEmp,
        @LeaveTypeID = 1,
        @StartDate = '2025-09-01',
        @EndDate   = '2025-09-05',
        @Reason    = 'Family vacation';
END TRY
BEGIN CATCH
    PRINT 'Test 1 FAILED: ' + ERROR_MESSAGE();
END CATCH

-- 2) Empty reason (should succeed, normalized to NULL)
PRINT 'Test 2: empty reason (should succeed)';
BEGIN TRY
    EXEC dbo.SubmitLeaveRequest
        @EmployeeID = @TestEmp,
        @LeaveTypeID = 1,
        @StartDate = '2025-10-01',
        @EndDate   = '2025-10-03',
        @Reason    = '';
END TRY
BEGIN CATCH
    PRINT 'Test 2 FAILED: ' + ERROR_MESSAGE();
END CATCH

-- 3) Invalid dates (StartDate > EndDate) - expect error
PRINT 'Test 3: invalid dates (StartDate > EndDate) - expect error';
BEGIN TRY
    EXEC dbo.SubmitLeaveRequest
        @EmployeeID = @TestEmp,
        @LeaveTypeID = 1,
        @StartDate = '2025-12-10',
        @EndDate   = '2025-12-01',
        @Reason    = 'Invalid date test';
    PRINT 'Test 3 UNEXPECTED: no error raised';
END TRY
BEGIN CATCH
    PRINT 'Test 3 expected failure caught: ' + ERROR_MESSAGE();
END CATCH

-- 4) Non-existing employee - expect error
PRINT 'Test 4: non-existing employee - expect error';
BEGIN TRY
    EXEC dbo.SubmitLeaveRequest
        @EmployeeID = 999999,
        @LeaveTypeID = 1,
        @StartDate = '2025-11-01',
        @EndDate   = '2025-11-03',
        @Reason    = 'Should fail - no employee';
    PRINT 'Test 4 UNEXPECTED: no error raised';
END TRY
BEGIN CATCH
    PRINT 'Test 4 expected failure caught: ' + ERROR_MESSAGE();
END CATCH

-- 5) Non-existing leave type - expect error
PRINT 'Test 5: non-existing leave type - expect error';
BEGIN TRY
    EXEC dbo.SubmitLeaveRequest
        @EmployeeID = @TestEmp,
        @LeaveTypeID = 9999,
        @StartDate = '2025-11-10',
        @EndDate   = '2025-11-12',
        @Reason    = 'Should fail - invalid leave type';
    PRINT 'Test 5 UNEXPECTED: no error raised';
END TRY
BEGIN CATCH
    PRINT 'Test 5 expected failure caught: ' + ERROR_MESSAGE();
END CATCH

-- 6) Verify inserted LeaveRequest rows for the test employee and show durations
PRINT 'Verifying created LeaveRequest rows for the test employee:';
SELECT TOP (10)
    RequestID,
    employee_id,
    leave_id,
    justification,
    duration,
    approval_timing,
    status,
    CAST(RequestID AS VARCHAR(20)) + ' / ' + CAST(duration AS VARCHAR(10)) AS DebugInfo
FROM dbo.LeaveRequest
WHERE employee_id = @TestEmp
ORDER BY RequestID DESC;

GO

/***** Cleanup / verification queries (optional) *****/
-- Quick listing of employees created during tests
SELECT EmployeeID, first_name, last_name, email, department_id, position_id, hire_date
FROM dbo.Employee
WHERE email IN ('alice.updated@example.com','bob.johnson@example.com','carol.white@example.com',
                'test.notify.one@example.com','test.notify.two@example.com','test.notify.three@example.com');
GO

------------------------------------------------------------------------------------------------------------------------
--HR Administrator
--1
-- Correct case: Valid EmployeeID, Type, StartDate, and EndDate
EXEC CreateContract 
   @EmployeeID = 1, 
   @Type = 'Full-time', 
   @StartDate = '2025-01-01', 
   @EndDate = '2025-12-31';

-- Incorrect case: Non-existing EmployeeID
EXEC CreateContract 
   @EmployeeID = 999, 
   @Type = 'Full-time', 
   @StartDate = '2025-01-01', 
   @EndDate = '2025-12-31';

-- Incorrect case: NULL StartDate or EndDate
EXEC CreateContract 
   @EmployeeID = 1, 
   @Type = 'Full-time', 
   @StartDate = NULL, 
   @EndDate = '2025-12-31';

-- Incorrect case: Invalid EndDate (start date after end date)
EXEC CreateContract 
   @EmployeeID = 1, 
   @Type = 'Full-time', 
   @StartDate = '2025-01-01', 
   @EndDate = '2024-12-31';

-- Incorrect case: Missing Contract table
EXEC CreateContract 
   @EmployeeID = 1, 
   @Type = 'Full-time', 
   @StartDate = '2025-01-01', 
   @EndDate = '2025-12-31';

-- Incorrect case: Type too long
EXEC CreateContract 
   @EmployeeID = 1, 
   @Type = 'ThisTypeIsWayTooLongForTheVarcharField',  -- 50+ characters
   @StartDate = '2025-01-01', 
   @EndDate = '2025-12-31';
-----------------------------------------------
--2
-- Correct case: Valid ContractID and EndDate
EXEC RenewContract 
   @ContractID = 101, 
   @EndDate = '2026-12-31';

-- Incorrect case: Non-existing ContractID
EXEC RenewContract 
   @ContractID = 9999, 
   @EndDate = '2026-12-31';

-- Incorrect case: NULL EndDate
EXEC RenewContract 
   @ContractID = 101, 
   @EndDate = NULL;

-- Incorrect case: Invalid EndDate (start date after end date)
EXEC RenewContract 
   @ContractID = 101, 
   @EndDate = '2024-12-31';  -- EndDate earlier than StartDate

-- Incorrect case: Missing Contract table
EXEC RenewContract 
   @ContractID = 101, 
   @EndDate = '2026-12-31';

-- Incorrect case: Invalid EndDate data type (passing a string)
EXEC RenewContract 
   @ContractID = 101, 
   @EndDate = 'InvalidDate';

-- Incorrect case: Invalid ContractID data type (passing a string)
EXEC RenewContract 
   @ContractID = 'ABC',  -- Not an integer
   @EndDate = '2026-12-31';
-----------------------------------------------------------
--3
-- Correct case: Valid LeaveRequestID, ApproverID, and Status
EXEC ApproveLeaveRequest 
   @LeaveRequestID = 101, 
   @ApproverID = 1001, 
   @Status = 'Approved';

-- Incorrect case: Non-existing LeaveRequestID
EXEC ApproveLeaveRequest 
   @LeaveRequestID = 9999, 
   @ApproverID = 1001, 
   @Status = 'Approved';

-- Incorrect case: Status exceeds the allowed length (more than 20 characters)
EXEC ApproveLeaveRequest 
   @LeaveRequestID = 101, 
   @ApproverID = 1001, 
   @Status = 'Approved with extended terms';  -- 25 characters

-- Incorrect case: NULL LeaveRequestID
EXEC ApproveLeaveRequest 
   @LeaveRequestID = NULL, 
   @ApproverID = 1001, 
   @Status = 'Approved';

-- Incorrect case: NULL ApproverID
EXEC ApproveLeaveRequest 
   @LeaveRequestID = 101, 
   @ApproverID = NULL, 
   @Status = 'Approved';

-- Incorrect case: Invalid Status data type (passing an integer)
EXEC ApproveLeaveRequest 
   @LeaveRequestID = 101, 
   @ApproverID = 1001, 
   @Status = 1234;  -- Integer instead of VARCHAR

-- Incorrect case: Missing LeaveRequest table
EXEC ApproveLeaveRequest 
   @LeaveRequestID = 101, 
   @ApproverID = 1001, 
   @Status = 'Approved';
-------------------------------------------------------------
--4
-- Correct case: Valid EmployeeID, ManagerID, Destination, StartDate, and EndDate
EXEC AssignMission 
   @EmployeeID = 101, 
   @ManagerID = 1001, 
   @Destination = 'New York', 
   @StartDate = '2025-01-01', 
   @EndDate = '2025-01-07';

-- Incorrect case: Non-existing EmployeeID
EXEC AssignMission 
   @EmployeeID = 9999, 
   @ManagerID = 1001, 
   @Destination = 'Paris', 
   @StartDate = '2025-01-01', 
   @EndDate = '2025-01-07';

-- Incorrect case: Invalid Destination data type (passing integer)
EXEC AssignMission 
   @EmployeeID = 101, 
   @ManagerID = 1001, 
   @Destination = 12345,  -- Integer instead of VARCHAR
   @StartDate = '2025-01-01', 
   @EndDate = '2025-01-07';

-- Incorrect case: NULL StartDate
EXEC AssignMission 
   @EmployeeID = 101, 
   @ManagerID = 1001, 
   @Destination = 'Tokyo', 
   @StartDate = NULL, 
   @EndDate = '2025-01-07';

-- Incorrect case: NULL EndDate
EXEC AssignMission 
   @EmployeeID = 101, 
   @ManagerID = 1001, 
   @Destination = 'Tokyo', 
   @StartDate = '2025-01-01', 
   @EndDate = NULL;

-- Incorrect case: Missing Mission table
EXEC AssignMission 
   @EmployeeID = 101, 
   @ManagerID = 1001, 
   @Destination = 'Berlin', 
   @StartDate = '2025-01-01', 
   @EndDate = '2025-01-07';

-- Incorrect case: Invalid ManagerID data type (passing string instead of integer)
EXEC AssignMission 
   @EmployeeID = 101, 
   @ManagerID = 'ManagerX',  -- String instead of INT
   @Destination = 'Rome', 
   @StartDate = '2025-01-01', 
   @EndDate = '2025-01-07';
------------------------------------------------------
--5 


--6
-- Correct case: Retrieve active contracts
EXEC GetActiveContracts;

--7
-- Correct case: Retrieve employees under ManagerID = 1001
EXEC GetTeamByManager 
   @ManagerID = 1001;

-- Incorrect case: Non-existing ManagerID
EXEC GetTeamByManager 
   @ManagerID = 9999;  -- Assuming 9999 is not a valid manager_id

-- Incorrect case: NULL ManagerID
EXEC GetTeamByManager 
   @ManagerID = NULL;

-- Incorrect case: Missing Employee table
EXEC GetTeamByManager 
   @ManagerID = 1001;

-- Incorrect case: Missing manager_id column in Employee table
EXEC GetTeamByManager 
   @ManagerID = 1001;

--8
-- Correct case: Update leave policy with valid PolicyID, EligibilityRules, and NoticePeriod
EXEC UpdateLeavePolicy 
   @PolicyID = 101, 
   @EligibilityRules = 'Employees must be with the company for at least 6 months to qualify for leave.', 
   @NoticePeriod = 30;

-- Incorrect case: Non-existing PolicyID
EXEC UpdateLeavePolicy 
   @PolicyID = 9999, 
   @EligibilityRules = 'New rules for leave eligibility.', 
   @NoticePeriod = 15;

-- Incorrect case: NULL PolicyID
EXEC UpdateLeavePolicy 
   @PolicyID = NULL, 
   @EligibilityRules = 'Updated eligibility rules.', 
   @NoticePeriod = 20;

-- Incorrect case: Invalid data type for EligibilityRules (passing an integer)
EXEC UpdateLeavePolicy 
   @PolicyID = 101, 
   @EligibilityRules = 12345,  -- Integer instead of VARCHAR
   @NoticePeriod = 20;

-- Incorrect case: Missing LeavePolicy table
EXEC UpdateLeavePolicy 
   @PolicyID = 101, 
   @EligibilityRules = 'Updated eligibility rules.', 
   @NoticePeriod = 20;

-- Incorrect case: Invalid data type for NoticePeriod (passing a string)
EXEC UpdateLeavePolicy 
   @PolicyID = 101, 
   @EligibilityRules = 'Updated eligibility rules.', 
   @NoticePeriod = 'Thirty';  -- String instead of INT

--9
-- Correct case: Retrieve contracts expiring within the next 30 days
EXEC GetExpiringContracts 
   @DaysBefore = 30;

-- Incorrect case: No contracts expiring within the next 5 days
EXEC GetExpiringContracts 
   @DaysBefore = 5;

-- Incorrect case: NULL DaysBefore
EXEC GetExpiringContracts 
   @DaysBefore = NULL;

-- Incorrect case: Invalid data type for DaysBefore (passing string)
EXEC GetExpiringContracts 
   @DaysBefore = 'Thirty';  -- String instead of INT

-- Incorrect case: Missing Contract table
EXEC GetExpiringContracts 
   @DaysBefore = 30;


--10
-- Correct case: Assign manager with ID 1001 as the department head for department 1
EXEC AssignDepartmentHead 
   @DepartmentID = 1, 
   @ManagerID = 1001;

-- Incorrect case: Non-existing DepartmentID
EXEC AssignDepartmentHead 
   @DepartmentID = 9999, 
   @ManagerID = 1001;

-- Incorrect case: NULL ManagerID
EXEC AssignDepartmentHead 
   @DepartmentID = 1, 
   @ManagerID = NULL;

-- Incorrect case: Invalid data type for ManagerID (passing a string)
EXEC AssignDepartmentHead 
   @DepartmentID = 1, 
   @ManagerID = 'ManagerX';  -- String instead of INT

-- Incorrect case: Missing Department table
EXEC AssignDepartmentHead 
   @DepartmentID = 1, 
   @ManagerID = 1001;

--11
-- Correct case: Insert new employee profile with valid data
EXEC CreateEmployeeProfile 
   @FirstName = 'John', 
   @LastName = 'Doe', 
   @DepartmentID = 1, 
   @RoleID = 2, 
   @HireDate = '2025-01-01', 
   @Email = 'john.doe@example.com', 
   @Phone = '123-456-7890';

-- Incorrect case: Invalid DepartmentID or RoleID
EXEC CreateEmployeeProfile 
   @FirstName = 'Jane', 
   @LastName = 'Smith', 
   @DepartmentID = 9999,  -- Non-existing DepartmentID
   @RoleID = 9999,        -- Non-existing RoleID
   @HireDate = '2025-01-01', 
   @Email = 'jane.smith@example.com', 
   @Phone = '987-654-3210';

-- Incorrect case: NULL FirstName or LastName
EXEC CreateEmployeeProfile 
   @FirstName = NULL, 
   @LastName = NULL, 
   @DepartmentID = 1, 
   @RoleID = 2, 
   @HireDate = '2025-01-01', 
   @Email = 'jane.smith@example.com', 
   @Phone = '987-654-3210';

-- Incorrect case: Invalid email and phone number format
EXEC CreateEmployeeProfile 
   @FirstName = 'Mark', 
   @LastName = 'Taylor', 
   @DepartmentID = 1, 
   @RoleID = 2, 
   @HireDate = '2025-01-01', 
   @Email = 'invalidemail',  -- Invalid email format
   @Phone = '12345';         -- Invalid phone format

--12
-- Correct case: Update first_name for EmployeeID = 101
EXEC UpdateEmployeeProfile 
   @EmployeeID = 101, 
   @FieldName = 'first_name', 
   @NewValue = 'John';

-- Incorrect case: Non-existing EmployeeID
EXEC UpdateEmployeeProfile 
   @EmployeeID = 9999, 
   @FieldName = 'first_name', 
   @NewValue = 'Jane';

-- Incorrect case: Invalid FieldName
EXEC UpdateEmployeeProfile 
   @EmployeeID = 101, 
   @FieldName = 'invalid_field', 
   @NewValue = 'NewValue';

-- Incorrect case: NULL FieldName
EXEC UpdateEmployeeProfile 
   @EmployeeID = 101, 
   @FieldName = NULL, 
   @NewValue = 'NewValue';

-- Incorrect case: Invalid data type for NewValue (passing integer instead of string)
EXEC UpdateEmployeeProfile 
   @EmployeeID = 101, 
   @FieldName = 'first_name', 
   @NewValue = 12345;  -- Invalid, should be a string

--13
-- Test Case 1: Update Profile Completeness to 75%
EXEC dbo.SetProfileCompleteness 
    @EmployeeID = 1, 
    @CompletenessPercentage = 75;

-- Test Case 2: Update Profile Completeness to 100%
EXEC dbo.SetProfileCompleteness 
    @EmployeeID = 2, 
    @CompletenessPercentage = 100;

-- Test Case 1: Invalid Completeness Percentage (Negative Value)
EXEC dbo.SetProfileCompleteness 
    @EmployeeID = 3, 
    @CompletenessPercentage = -5;

-- Test Case 2: Invalid Completeness Percentage (Greater than 100)
EXEC dbo.SetProfileCompleteness 
    @EmployeeID = 4,   
    @CompletenessPercentage = 105;

-- Test Case 3: Invalid Employee ID (Non-Existent Employee)
EXEC dbo.SetProfileCompleteness 
    @EmployeeID = 9999, 
    @CompletenessPercentage = 80;


--14
-- Test Case 1: Filter by Department (Valid Case)
EXEC GenerateProfileReport 
    @FilterField = 'department', 
    @FilterValue = 'Sales';

-- Test Case 2: Filter by Position (Valid Case)
EXEC GenerateProfileReport 
    @FilterField = 'position', 
    @FilterValue = 'Manager';

-- Test Case 3: Filter by Employment Status (Valid Case)
EXEC GenerateProfileReport 
    @FilterField = 'employment_status', 
    @FilterValue = 'Active';

-- Test Case 4: Filter by Hire Date (Valid Case)
EXEC GenerateProfileReport 
    @FilterField = 'hire_date', 
    @FilterValue = '2022-01-01';

-- Test Case 5: Invalid Filter Field (Invalid Case)
EXEC GenerateProfileReport 
    @FilterField = 'gender', 
    @FilterValue = 'Male';

-- Test Case 6: No Matching Records (Invalid Case)
EXEC GenerateProfileReport 
    @FilterField = 'department', 
    @FilterValue = 'NonExistentDept';


--15
-- Test Case 1: Create a Normal Shift Type
EXEC CreateShiftType   
    @ShiftID = 1, 
    @Name = 'Morning Shift', 
    @Type = 'Normal', 
    @Start_Time = '09:00:00', 
    @End_Time = '17:00:00', 
    @Break_Duration = 60, 
    @Shift_Date = '2025-11-15', 
    @Status = 'Active';

-- Test Case 2: Create a Split Shift Type (e.g., 9 AM to 12 PM, and 1 PM to 5 PM)
EXEC CreateShiftType 
    @ShiftID = 2, 
    @Name = 'Split Shift', 
    @Type = 'Split', 
    @Start_Time = '09:00:00', 
    @End_Time = '17:00:00', 
    @Break_Duration = 120, 
    @Shift_Date = '2025-11-15', 
    @Status = 'Active';

-- Test Case 3: Create an Overnight Shift Type (e.g., 8 PM to 4 AM)
EXEC CreateShiftType 
    @ShiftID = 3, 
    @Name = 'Overnight Shift', 
    @Type = 'Overnight', 
    @Start_Time = '20:00:00', 
    @End_Time = '04:00:00', 
    @Break_Duration = 30, 
    @Shift_Date = '2025-11-15', 
    @Status = 'Active';

-- Test Case 4: Create a Mission Shift Type
EXEC CreateShiftType 
    @ShiftID = 4,
    @Name = 'Mission Shift',
    @Type = 'Mission', 
    @Start_Time = '10:00:00', 
    @End_Time = '18:00:00', 
    @Break_Duration = 45, 
    @Shift_Date = '2025-11-15', 
    @Status = 'Active';

-- Test Case 1: Missing required field (e.g., missing @Shift_Date)
EXEC CreateShiftType 
    @ShiftID = 6, 
    @Name = 'Morning Shift', 
    @Type = 'Normal', 
    @Start_Time = '08:00:00', 
    @End_Time = '16:00:00', 
    @Break_Duration = 60, 
    @Shift_Date = NULL, 
    @Status = 'Active';

-- Test Case 2: Invalid time format (e.g., '25:00:00' is invalid)
EXEC CreateShiftType 
    @ShiftID = 7, 
    @Name = 'Invalid Shift', 
    @Type = 'Normal', 
    @Start_Time = '25:00:00', 
    @End_Time = '26:00:00', 
    @Break_Duration = 60, 
    @Shift_Date = '2025-11-15', 
    @Status = 'Active';


--16
-- Test Case 1: Assign a valid shift cycle (Morning) to an employee
EXEC AssignRotationalShift 
    @EmployeeID = 1, 
    @ShiftCycle = 1, 
    @StartDate = '2025-11-15',
    @EndDate = '2025-11-15', 
    @Status = 'Active';

-- Test Case 2: Assign a valid shift cycle (Evening) to an employee
EXEC AssignRotationalShift 
    @EmployeeID = 2, 
    @ShiftCycle = 2, 
    @StartDate = '2025-11-16', 
    @EndDate = '2025-11-16', 
    @Status = 'Active';

-- Test Case 3: Assign a valid shift cycle (Night) to an employee
EXEC AssignRotationalShift 
    @EmployeeID = 3, 
    @ShiftCycle = 3, 
    @StartDate = '2025-11-17', 
    @EndDate = '2025-11-17', 
    @Status = 'Active';

-- Test Case 1: Invalid Employee ID (Employee doesn't exist)
EXEC AssignRotationalShift 
    @EmployeeID = 9999, 
    @ShiftCycle = 1, 
    @StartDate = '2025-11-18', 
    @EndDate = '2025-11-18', 
    @Status = 'Active';

-- Test Case 2: Invalid ShiftCycle ID (ID doesn't exist in ShiftCycle table)
EXEC AssignRotationalShift 
    @EmployeeID = 1, 
    @ShiftCycle = 999, 
    @StartDate = '2025-11-19', 
    @EndDate = '2025-11-19', 
    @Status = 'Active';

-- Test Case 3: Missing or NULL ShiftCycle parameter
EXEC AssignRotationalShift 
    @EmployeeID = 2, 
    @ShiftCycle = NULL, 
    @StartDate = '2025-11-20', 
    @EndDate = '2025-11-20', 
    @Status = 'Active';

-- Test Case 4: Invalid status field length (exceeds 20 characters)
EXEC AssignRotationalShift 
    @EmployeeID = 3, 
    @ShiftCycle = 1, 
    @StartDate = '2025-11-21', 
    @EndDate = '2025-11-21', 
    @Status = 'ThisStatusIsWayTooLongForTheField';

--17
-- Test Case 1: Notify employee when shift assignment is nearing expiry
EXEC NotifyShiftExpiry 
    @EmployeeID = 1, 
    @ShiftAssignmentID = 101, 
    @ExpiryDate = '2025-11-20';

-- Test Case 2: Do not notify if the shift assignment expiry is not near (more than 7 days away)
EXEC NotifyShiftExpiry 
    @EmployeeID = 2, 
    @ShiftAssignmentID = 102, 
    @ExpiryDate = '2025-12-01';

-- Test Case 1: Invalid ShiftAssignmentID or EmployeeID
EXEC NotifyShiftExpiry 
    @EmployeeID = 9999, 
    @ShiftAssignmentID = 9999, 
    @ExpiryDate = '2025-11-25';

-- Test Case 2: Invalid Expiry Date format (non-date value)
EXEC NotifyShiftExpiry 
    @EmployeeID = 3, 
    @ShiftAssignmentID = 103, 
    @ExpiryDate = 'InvalidDate';


--18
-- Test Case 1: Define a Late Arrival rule
EXEC DefineShortTimeRules 
    @RuleName = 'Late Arrival', 
    @LateMinutes = 15, 
    @EarlyLeaveMinutes = 0, 
    @PenaltyType = 'Deduction';

-- Test Case 2: Define an Early Out rule
EXEC DefineShortTimeRules 
    @RuleName = 'Early Out', 
    @LateMinutes = 0, 
    @EarlyLeaveMinutes = 10, 
    @PenaltyType = 'Warning';

-- Test Case 1: Missing Rule Name
EXEC DefineShortTimeRules 
    @RuleName = NULL, 
    @LateMinutes = 15, 
    @EarlyLeaveMinutes = 0, 
    @PenaltyType = 'Deduction';

-- Test Case 2: Invalid Penalty Type Length
EXEC DefineShortTimeRules 
    @RuleName = 'Late Arrival', 
    @LateMinutes = 15, 
    @EarlyLeaveMinutes = 0, 
    @PenaltyType = 'This penalty type is way too long to fit in the 50 character limit';


-------------------------------------------------------------------------------
--19








---------------------------------------------------------------------------------
--20
-- Test Case 1: Normal valid grace period
EXEC SetGracePeriod 
    @Minutes = 10;

-- Test Case 2: Zero minutes (allowed)
EXEC SetGracePeriod 
    @Minutes = 0;

-- Test Case 3: Negative grace period should fail
EXEC SetGracePeriod 
    @Minutes = -5;

-- Test Case 4: LatenessPolicy table empty ? should fail
-- (Run only if LatenessPolicy has no rows)
EXEC SetGracePeriod 
    @Minutes = 5;
--------------------------------------------------------------------------------
--21
-- Test Case 1: Normal threshold rule
EXEC DefinePenaltyThreshold 
    @LateMinutes = 15, 
    @DeductionType = 'Half-day deduction';

-- Test Case 2: Small threshold
EXEC DefinePenaltyThreshold 
    @LateMinutes = 5, 
    @DeductionType = 'Minor deduction';

-- Test Case 3: Negative minutes (invalid)
EXEC DefinePenaltyThreshold 
    @LateMinutes = -10, 
    @DeductionType = 'Half-day deduction';

-- Test Case 4: No LatenessPolicy rows exist
-- (Only works if the table is empty)
EXEC DefinePenaltyThreshold 
    @LateMinutes = 20, 
    @DeductionType = 'Full deduction';
-----------------------------------------------------------------------------------
--22

-- Test Case 1: Normal permission limits
EXEC DefinePermissionLimits 
    @MinHours = 1, 
    @MaxHours = 5;

-- Test Case 2: Larger range
EXEC DefinePermissionLimits 
    @MinHours = 2, 
    @MaxHours = 10;

-- Test Case 3: Negative min hours
EXEC DefinePermissionLimits 
    @MinHours = -1, 
    @MaxHours = 5;

-- Test Case 4: Max <= Min
EXEC DefinePermissionLimits 
    @MinHours = 5, 
    @MaxHours = 5;

-- Test Case 5: Max < Min
EXEC DefinePermissionLimits 
    @MinHours = 6, 
    @MaxHours = 3;

-----------------------------------------------------------------------------------
--23  leave for now





-----------------------------------------------------------------------------------
--24

-- Test Case 1: Valid package-to-employee link
-- (package ID matches the employee ID)
EXEC LinkVacationToShift 
    @VacationPackageID = 7, 
    @EmployeeID = 7;

-- Test Case 2: Employee does not exist
EXEC LinkVacationToShift 
    @VacationPackageID = 5, 
    @EmployeeID = 9999;

-- Test Case 3: Package does not match employee
EXEC LinkVacationToShift 
    @VacationPackageID = 4, 
    @EmployeeID = 9;

------------------------------------------------------------------------------------
--25
-- Test Case 1: Start the leave configuration process
EXEC ConfigureLeavePolicies;


-- Test Case 2: Run again to log multiple starts 
EXEC ConfigureLeavePolicies;


-- Test Case 3: Verify the policy was created
SELECT * FROM LeavePolicy WHERE name = 'Leave Configuration Start';

------------------------------------------------------------------------------------
--26 



-----------------------------------------------------------------------------------
--27
-- Test Case 1: Apply configuration
EXEC ApplyLeaveConfiguration;


-- Test Case 2: Apply again (allowed)
EXEC ApplyLeaveConfiguration;


-- Test Case 3: Verify applied logs
SELECT * FROM LeavePolicy WHERE name = 'Leave Configuration Applied';

------------------------------------------------------------------------------------
--28 
-- Test Case 1: Valid employee entitlement update
EXEC UpdateLeaveEntitlements 
    @EmployeeID = 5;


-- Test Case 2: Another valid employee
EXEC UpdateLeaveEntitlements 
    @EmployeeID = 12;


-- Test Case 3: Invalid employee (should fail)
EXEC UpdateLeaveEntitlements 
    @EmployeeID = 9999;


-- Test Case 4: Verify logs inside LeavePolicy
SELECT * FROM LeavePolicy WHERE name = 'Leave Entitlement Update';

--------------------------------------------------------------------------------------
--29
-- Test Case 1: Normal eligibility rule for Annual Leave
EXEC ConfigureLeaveEligibility
    @LeaveType = 'Annual Leave',
    @MinTenure = 12,
    @EmployeeType = 'Full-Time';

-- Test Case 2: Sick leave accessible to all
EXEC ConfigureLeaveEligibility
    @LeaveType = 'Sick Leave',
    @MinTenure = 0,
    @EmployeeType = 'All Employees';

-- Test Case 3: Negative tenure (invalid)
EXEC ConfigureLeaveEligibility
    @LeaveType = 'Emergency Leave',
    @MinTenure = -3,
    @EmployeeType = 'Any';

-- Test Case 4: Verify the inserted eligibility rules
SELECT * FROM LeavePolicy WHERE name = 'Annual Leave';
---------------------------------------------------------------------------------------
--30
-- Test Case 1: Normal insertion
EXEC ManageLeaveTypes
    @LeaveType = 'Annual Leave',
    @Description = 'Paid annual leave for employees.';

-- Test Case 2: Works even with spaces (since validation removed)
EXEC ManageLeaveTypes
    @LeaveType = '   ',
    @Description = 'Testing no validation.';

-- Test Case 3: View all leave types
SELECT * FROM LeavePolicy;














