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

-- Execute the drop-all (keeps script deterministic for repeated runs)
EXEC sp_DropAllTables;
GO

------------------------
--System Admin Tests
------------------------

-- Currency required by SalaryType
IF NOT EXISTS (SELECT 1 FROM dbo.Currency WHERE CurrencyCode = 'USD')
INSERT INTO dbo.Currency (CurrencyCode, currency_name, exchange_rate, created_date, last_updated)
VALUES ('USD', 'US Dollar', 1.0000, GETDATE(), GETDATE());
GO

-- Positions
IF NOT EXISTS (SELECT 1 FROM dbo.Position WHERE PositionID = 1)
    INSERT INTO dbo.Position (PositionID, position_title, responsibilities, status) VALUES (1, 'Developer', 'Develops software', 'ACTIVE');
GO
IF NOT EXISTS (SELECT 1 FROM dbo.Position WHERE PositionID = 2)
    INSERT INTO dbo.Position (PositionID, position_title, responsibilities, status) VALUES (2, 'Manager', 'Manages team', 'ACTIVE');
GO

-- Departments
IF NOT EXISTS (SELECT 1 FROM dbo.Department WHERE DepartmentID = 1)
    INSERT INTO dbo.Department (DepartmentID, department_name, purpose, department_head_id) VALUES (1, 'Human Resources', 'HR and People Ops', NULL);
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Department WHERE DepartmentID = 2)
    INSERT INTO dbo.Department (DepartmentID, department_name, purpose, department_head_id) VALUES (2, 'Finance', 'Payroll and Finance', NULL);
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Department WHERE DepartmentID = 3)
    INSERT INTO dbo.Department (DepartmentID, department_name, purpose, department_head_id) VALUES (3, 'Engineering', 'Engineering Dept', NULL);
GO

-- Roles (used by AssignRole tests)
IF NOT EXISTS (SELECT 1 FROM dbo.Role WHERE RoleID = 1)
    INSERT INTO dbo.Role (RoleID, role_name, purpose) VALUES (1, 'System Administrator', 'Full system privileges');
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Role WHERE RoleID = 2)
    INSERT INTO dbo.Role (RoleID, role_name, purpose) VALUES (2, 'Payroll Officer', 'Handles payroll');
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Role WHERE RoleID = 3)
    INSERT INTO dbo.Role (RoleID, role_name, purpose) VALUES (3, 'HR Administrator', 'HR administration and records');
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Role WHERE RoleID = 4)
    INSERT INTO dbo.Role (RoleID, role_name, purpose) VALUES (4, 'Line Manager', 'Shift management');
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Role WHERE RoleID = 5)
    INSERT INTO dbo.Role (RoleID, role_name, purpose) VALUES (5, 'Employee', 'Regular employee role');
GO

-- PayGrade
IF NOT EXISTS (SELECT 1 FROM dbo.PayGrade WHERE PayGradeID = 1)
    INSERT INTO dbo.PayGrade (PayGradeID, grade_name, min_salary, max_salary) VALUES (1, 'P1', 30000.00, 50000.00);
GO

-- TaxForm
IF NOT EXISTS (SELECT 1 FROM dbo.TaxForm WHERE TaxFormID = 1)
    INSERT INTO dbo.TaxForm (TaxFormID, jurisdiction, validity_period, form_content) VALUES (1, 'Default', DATEADD(YEAR, 1, GETDATE()), 'Standard tax form');
GO

-- SalaryType (references Currency)
IF NOT EXISTS (SELECT 1 FROM dbo.SalaryType WHERE SalaryTypeID = 1)
    INSERT INTO dbo.SalaryType (SalaryTypeID, type, payment_frequency, currency) VALUES (1, 'Monthly', 'Monthly', 'USD');
GO

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
VALUES (5, 'Jaaffar', 'Yakub', 'jaaffar.garry@example.com', '6742069', 'Agartha' , '2007-05-03', 1, 1, 1, '01227425396', 'Land Down Under');
GO

/***** 1) Test ViewEmployeeInfo *****/

PRINT '========================================';
PRINT 'TEST 1: ViewEmployeeInfo';
PRINT '========================================';

EXEC dbo.ViewEmployeeInfo @EmployeeID = 1; --input
EXEC dbo.ViewEmployeeInfo @EmployeeID = 2; --input

/***** 2) Test AddEmployee *****/

PRINT '========================================';
PRINT 'TEST 2: AddEmployee';
PRINT '========================================';

-- Successful inserts: updated to new signature. Use OUTPUT variable to capture new ID.
DECLARE @NewEmpID INT;

EXEC dbo.AddEmployee
    @FullName = 'Taher Khalaf',
    @NationalID = 'NID-0001',
    @DateOfBirth = '1990-05-10',
    @CountryOfBirth = 'Egypt',
    @Phone = '555-1000',
    @Email = 'taher.skhalaf@gmail.com',
    @Address = '1 Example St',
    @EmergencyContactName = 'Ali Khalaf',
    @EmergencyContactPhone = '555-9999',
    @Relationship = 'Brother',
    @Biography = 'Experienced developer',
    @EmploymentProgress = 'Onboarding',
    @AccountStatus = 'Active',
    @EmploymentStatus = 'Full-time',
    @HireDate = '2025-01-01',
    @IsActive = 1,
    @ProfileCompletion = 80,
    @DepartmentID = 3,
    @PositionID = 2,
    @ManagerID = 1,
    @ContractID = 1,
    @TaxFormID = 1,
    @SalaryTypeID = 1,
    @PayGrade = 'P1',
    @NewEmployeeID = @NewEmpID OUTPUT;

SELECT @NewEmpID AS NewEmployeeID;

-- Second insert
DECLARE @NewEmpID INT;

EXEC dbo.AddEmployee
    @FullName = 'Jaquavius Johnson',
    @NationalID = 'NID-0002',
    @DateOfBirth = '1992-08-12',
    @CountryOfBirth = 'CountryY',
    @Phone = '555-2000',
    @Email = 'JAQ.johnson@example.com',
    @Address = '2 Example Ave',
    @EmergencyContactName = 'Jane Doe',
    @EmergencyContactPhone = '555-8888',
    @Relationship = 'Friend',
    @Biography = 'Contractor',
    @EmploymentProgress = 'Active',
    @AccountStatus = 'Active',
    @EmploymentStatus = 'Contractor',
    @HireDate = '2024-10-01',
    @IsActive = 1,
    @ProfileCompletion = 60,
    @DepartmentID = 2,
    @PositionID = 2,
    @ManagerID = NULL,
    @ContractID = 1,
    @TaxFormID = 1,
    @SalaryTypeID = 1,
    @PayGrade = 'P1',
    @NewEmployeeID = @NewEmpID OUTPUT;

SELECT @NewEmpID AS NewEmployeeID;
GO

/***** 3) Test UpdateEmployeeInfo *****/

PRINT '========================================';
PRINT 'TEST 3: UpdateEmployeeInfo';
PRINT '========================================';

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

PRINT '========================================';
PRINT 'TEST 4: AssignRole';
PRINT '========================================';

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

/***** 5) Test GetDepartmentEmployeeStats *****/

PRINT '========================================';
PRINT 'TEST 5: GetDepartmentEmployeeStats';
PRINT '========================================';

-- Run stats
EXEC dbo.GetDepartmentEmployeeStats;
GO

/***** 6) Test ReassignManager *****/

PRINT '========================================';
PRINT 'TEST 6: ReassignManager';
PRINT '========================================';

USE MILESTONE2;
GO

-- Normalize manager columns for test employees (idempotent)
UPDATE dbo.Employee
SET manager_id = NULL
WHERE EmployeeID IN (1,2,3,4,5);

-- Ensure baseline: employee 3 reports to employee 1 (for valid and cycle tests)
UPDATE dbo.Employee
SET manager_id = 1
WHERE EmployeeID = 3 AND EXISTS (SELECT 1 FROM dbo.Employee WHERE EmployeeID = 1);

-- Test 1: Valid reassignment (employee 3 -> manager 2)
BEGIN TRY
    EXEC dbo.ReassignManager @EmployeeID = 3, @NewManagerID = 2;
    SELECT 'OK' AS TestResult, EmployeeID, first_name, last_name, manager_id
    FROM dbo.Employee WHERE EmployeeID = 3;
END TRY
BEGIN CATCH
    SELECT ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
GO

-- Restore baseline for next tests (employee 3 -> 1)
UPDATE dbo.Employee
SET manager_id = 1
WHERE EmployeeID = 3;

-- Test 2: Self-assignment (employee 3 -> manager 3) - should error
BEGIN TRY
    EXEC dbo.ReassignManager @EmployeeID = 3, @NewManagerID = 3;
END TRY
BEGIN CATCH
    SELECT 'Expected error' AS TestResult, ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
GO

-- Test 3: Non-existent new manager (employee 3 -> manager 9999) - should error
BEGIN TRY
    EXEC dbo.ReassignManager @EmployeeID = 3, @NewManagerID = 9999;
END TRY
BEGIN CATCH
    SELECT 'Expected error' AS TestResult, ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
GO

-- Test 4: Cycle detection
-- Setup: employee 3 -> manager = 1 (already set). Attempt to set employee 1 -> manager 3 (would create a cycle)
BEGIN TRY
    EXEC dbo.ReassignManager @EmployeeID = 1, @NewManagerID = 3;
END TRY
BEGIN CATCH
    SELECT 'Expected error' AS TestResult, ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
GO

-- Final verification: show manager relationships for the involved employees
SELECT EmployeeID, first_name, last_name, manager_id
FROM dbo.Employee
WHERE EmployeeID IN (3) 
ORDER BY EmployeeID;
GO

/***** 7) Test ReassignHierarchy *****/

PRINT '========================================';
PRINT 'TEST 7: ReassignHierarchy';
PRINT '========================================';

USE MILESTONE2;
GO

-- ensure baseline departments/managers for tests
UPDATE dbo.Employee SET manager_id = NULL WHERE EmployeeID IN (1,2,3,4);
UPDATE dbo.Employee SET department_id = 1 WHERE EmployeeID IN (1,2) AND department_id IS NULL;

-- baseline: employee 3 -> dept 3 and manager -> 1
UPDATE dbo.Employee SET department_id = 3, manager_id = 1 WHERE EmployeeID = 3;
-- baseline: employee 4 -> dept 2 and manager -> 2
UPDATE dbo.Employee SET department_id = 2, manager_id = 2 WHERE EmployeeID = 4;
GO

-- Test 1: Reassign department only (3 -> dept 2)
BEGIN TRY
    EXEC dbo.ReassignHierarchy @EmployeeID = 3, @NewDepartmentID = 2;
    SELECT 'Result' AS Tag, EmployeeID, department_id, manager_id FROM dbo.Employee WHERE EmployeeID = 3;
END TRY
BEGIN CATCH
    SELECT 'Error' AS Tag, ERROR_MESSAGE() AS Msg;
END CATCH;
GO

-- restore baseline for employee 3
UPDATE dbo.Employee SET department_id = 3, manager_id = 1 WHERE EmployeeID = 3;
GO

-- Test 2: Reassign manager only (3 -> manager 2)
BEGIN TRY
    EXEC dbo.ReassignHierarchy @EmployeeID = 3, @NewManagerID = 2;
    SELECT 'Result' AS Tag, EmployeeID, department_id, manager_id FROM dbo.Employee WHERE EmployeeID = 3;
END TRY
BEGIN CATCH
    SELECT 'Error' AS Tag, ERROR_MESSAGE() AS Msg;
END CATCH;
GO

-- restore baseline for employee 3
UPDATE dbo.Employee SET manager_id = 1 WHERE EmployeeID = 3;
GO

-- Test 3: Reassign both (4 -> dept 1, manager 1)
BEGIN TRY
    -- ensure manager 1 is in dept 1
    UPDATE dbo.Employee SET department_id = 1 WHERE EmployeeID = 1;
    EXEC dbo.ReassignHierarchy @EmployeeID = 4, @NewDepartmentID = 1, @NewManagerID = 1;
    SELECT 'Result' AS Tag, EmployeeID, department_id, manager_id FROM dbo.Employee WHERE EmployeeID = 4;
END TRY
BEGIN CATCH
    SELECT 'Error' AS Tag, ERROR_MESSAGE() AS Msg;
END CATCH;
GO

-- restore baseline for employee 4
UPDATE dbo.Employee SET department_id = 2, manager_id = 2 WHERE EmployeeID = 4;
GO

-- Test 4: Cycle detection (attempt to make 1 report to 3 when 3 -> 1 exists)
BEGIN TRY
    -- set 3 -> 1
    UPDATE dbo.Employee SET manager_id = 1 WHERE EmployeeID = 3;
    EXEC dbo.ReassignHierarchy @EmployeeID = 1, @NewManagerID = 3;
END TRY
BEGIN CATCH
    SELECT 'Expected error' AS Tag, ERROR_MESSAGE() AS Msg;
END CATCH;
GO

-- final state check
SELECT EmployeeID, first_name, last_name, department_id, manager_id
FROM dbo.Employee
WHERE EmployeeID IN (1,2,3,4)
ORDER BY EmployeeID;
GO

/***** 8) Test NotifyStructureChange  *****/

PRINT '========================================';
PRINT 'TEST 8: NotifyStructureChange';
PRINT '========================================';

USE MILESTONE2;
GO

-- Clean up any prior test notifications for deterministic results (optional)
DELETE en
FROM dbo.EmployeeNotification en
JOIN dbo.Notification n ON en.notification_id = n.NotificationID
WHERE n.notification_type = 'STRUCTURE_CHANGE';

DELETE FROM dbo.Notification WHERE notification_type = 'STRUCTURE_CHANGE';
GO

-- Test 1: normal case (some valid, one invalid id)
EXEC dbo.NotifyStructureChange
    @AffectedEmployees = '1,2,9999,abc', 
    @Message = 'Organizational restructure approved. Please check new assignments.';

-- Verify created notification and employee links
SELECT n.NotificationID, n.mesage_content, n.timestamp, n.notification_type
FROM dbo.Notification n
WHERE n.notification_type = 'STRUCTURE_CHANGE';

SELECT en.employee_id, en.notification_id, en.delivery_status, en.delivered_at
FROM dbo.EmployeeNotification en
WHERE en.notification_id IN (SELECT NotificationID FROM dbo.Notification WHERE notification_type = 'STRUCTURE_CHANGE')
ORDER BY en.employee_id;
GO

-- Test 2: missing message (expected to error)
BEGIN TRY
    EXEC dbo.NotifyStructureChange @AffectedEmployees = '1,2', @Message = '';
END TRY
BEGIN CATCH
    SELECT 'Expected error' AS TestResult, ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
GO

/***** 9) Test ViewOrgHierarchy *****/

PRINT '========================================';
PRINT 'TEST 9: ViewOrgHierarchy';
PRINT '========================================';

USE MILESTONE2;
GO

-- Ensure required reference rows exist (idempotent)
IF NOT EXISTS (SELECT 1 FROM dbo.Position WHERE PositionID = 1)
    INSERT INTO dbo.Position (PositionID, position_title, responsibilities, status) VALUES (1, 'Developer', 'Develops software', 'ACTIVE');
IF NOT EXISTS (SELECT 1 FROM dbo.Position WHERE PositionID = 2)
    INSERT INTO dbo.Position (PositionID, position_title, responsibilities, status) VALUES (2, 'Manager', 'Manages team', 'ACTIVE');

IF NOT EXISTS (SELECT 1 FROM dbo.Department WHERE DepartmentID = 1)
    INSERT INTO dbo.Department (DepartmentID, department_name, purpose) VALUES (1, 'Human Resources', 'HR');
IF NOT EXISTS (SELECT 1 FROM dbo.Department WHERE DepartmentID = 2)
    INSERT INTO dbo.Department (DepartmentID, department_name, purpose) VALUES (2, 'Finance', 'Payroll');

-- Ensure sample employees and manager links
IF NOT EXISTS (SELECT 1 FROM dbo.Employee WHERE EmployeeID = 10)
    INSERT INTO dbo.Employee (EmployeeID, first_name, last_name, email, hire_date, is_active, department_id, position_id)
    VALUES (10, 'Top', 'Manager', 'top.manager@example.com', GETDATE(), 1, 1, 2);

IF NOT EXISTS (SELECT 1 FROM dbo.Employee WHERE EmployeeID = 11)
    INSERT INTO dbo.Employee (EmployeeID, first_name, last_name, email, hire_date, is_active, department_id, position_id, manager_id)
    VALUES (11, 'Mid', 'Manager', 'mid.manager@example.com', GETDATE(), 1, 2, 2, 10);

IF NOT EXISTS (SELECT 1 FROM dbo.Employee WHERE EmployeeID = 12)
    INSERT INTO dbo.Employee (EmployeeID, first_name, last_name, email, hire_date, is_active, department_id, position_id, manager_id)
    VALUES (12, 'Junior', 'Staff', 'junior.staff@example.com', GETDATE(), 1, 2, 1, 11);

-- Run the procedure (no parameters)
EXEC dbo.ViewOrgHierarchy;
GO

/***** 10) Test AssignShiftToEmployee *****/

PRINT '========================================';
PRINT 'TEST 10: AssignShiftToEmployee';
PRINT '========================================';

USE MILESTONE2;
GO

-- Clean up any prior test shifts we will use (idempotent)
DELETE FROM dbo.ShiftSchedule WHERE ShiftID IN (1001, 1002);
GO

-- Test 1: valid assignment; Assign shift 1001 to employee 1
BEGIN TRY
    EXEC dbo.AssignShiftToEmployee @EmployeeID = 1, @ShiftID = 1001, @StartDate = '2025-06-01', @EndDate = '2025-06-07';
    SELECT * FROM dbo.ShiftSchedule WHERE ShiftID = 1001;
END TRY
BEGIN CATCH
    SELECT 'Error' AS Test, ERROR_MESSAGE() AS Msg;
END CATCH;
GO

-- Test 2: overlapping assignment for same employee (should error)
BEGIN TRY
    EXEC dbo.AssignShiftToEmployee @EmployeeID = 1, @ShiftID = 1002, @StartDate = '2025-06-05', @EndDate = '2025-06-10';
END TRY
BEGIN CATCH
    SELECT 'Expected error' AS Test, ERROR_MESSAGE() AS Msg;
END CATCH;
GO

-- Test 3: non-existent employee (should error)
BEGIN TRY
    PRINT 'Test 3: non-existent employee (expect error)';
    EXEC dbo.AssignShiftToEmployee @EmployeeID = 9999, @ShiftID = 2001, @StartDate = '2025-07-01', @EndDate = '2025-07-07';
END TRY
BEGIN CATCH
    SELECT 'Expected error' AS Test, ERROR_MESSAGE() AS Msg;
END CATCH;
GO

USE MILESTONE2;
GO

-- Ensure test employees exist
IF NOT EXISTS (SELECT 1 FROM dbo.Employee WHERE EmployeeID = 100)
    INSERT INTO dbo.Employee (EmployeeID, first_name, last_name, email, hire_date, is_active, department_id, position_id)
    VALUES (100, 'Test', 'Employee100', 'test.emp100@example.com', GETDATE(), 1, 1, 1);
    GO

IF NOT EXISTS (SELECT 1 FROM dbo.Employee WHERE EmployeeID = 101)
    INSERT INTO dbo.Employee (EmployeeID, first_name, last_name, email, hire_date, is_active, department_id, position_id)
    VALUES (101, 'Test', 'Employee101', 'test.emp101@example.com', GETDATE(), 1, 1, 1);
    GO

IF NOT EXISTS (SELECT 1 FROM dbo.Employee WHERE EmployeeID = 102)
    INSERT INTO dbo.Employee (EmployeeID, first_name, last_name, email, hire_date, is_active, department_id, position_id)
    VALUES (102, 'Test', 'Employee102', 'test.emp102@example.com', GETDATE(), 1, 2, 1);
    GO

IF NOT EXISTS (SELECT 1 FROM dbo.Employee WHERE EmployeeID = 103)
    INSERT INTO dbo.Employee (EmployeeID, first_name, last_name, email, hire_date, is_active, department_id, position_id)
    VALUES (103, 'Test', 'Employee103', 'test.emp103@example.com', GETDATE(), 1, 3, 1);
GO

PRINT 'Test data setup complete.';
GO


/***** 11) Test UpdateShiftStatus *****/


PRINT '========================================';
PRINT 'TEST 11: UpdateShiftStatus';
PRINT '========================================';
-- Clean up test shifts
DELETE FROM dbo.ShiftSchedule WHERE ShiftID BETWEEN 2001 AND 2010;
GO

-- Setup: Create test shifts with different statuses
INSERT INTO dbo.ShiftSchedule (ShiftID, employee_id, start_date, end_date, status)
VALUES 
    (2001, 100, '2025-06-01', '2025-06-07', 'ASSIGNED'),
    (2002, 100, '2025-06-08', '2025-06-14', 'Submitted'),
    (2003, 100, '2025-06-15', '2025-06-21', 'Approved'),
    (2004, 100, '2025-06-22', '2025-06-28', 'Rejected'),
    (2005, 100, '2025-06-29', '2025-07-05', 'Expired');
GO

-- Test 1: Valid status update (ASSIGNED -> Submitted)
PRINT 'Test 1: Valid status update (ASSIGNED -> Submitted)';
BEGIN TRY
    EXEC dbo.UpdateShiftStatus @ShiftAssignmentID = 2001, @Status = 'Submitted';
    SELECT status FROM dbo.ShiftSchedule WHERE ShiftID = 2001;
END TRY
BEGIN CATCH
    SELECT 'Error' AS TestResult, ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
GO

-- Test 2: Valid status update (Submitted -> Approved)
PRINT 'Test 2: Valid status update (Submitted -> Approved)';
BEGIN TRY
    EXEC dbo.UpdateShiftStatus @ShiftAssignmentID = 2002, @Status = 'Approved';
    SELECT status FROM dbo.ShiftSchedule WHERE ShiftID = 2002;
END TRY
BEGIN CATCH
    SELECT 'Error' AS TestResult, ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
GO

-- Test 3: Invalid status value
PRINT 'Test 3: Invalid status value (should fail)';
BEGIN TRY
    EXEC dbo.UpdateShiftStatus @ShiftAssignmentID = 2001, @Status = 'InvalidStatus';
END TRY
BEGIN CATCH
    SELECT 'Expected error' AS TestResult, ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
GO

-- Test 4: Non-existent shift ID
PRINT 'Test 4: Non-existent shift ID (should fail)';
BEGIN TRY
    EXEC dbo.UpdateShiftStatus @ShiftAssignmentID = 9999, @Status = 'Approved';
END TRY
BEGIN CATCH
    SELECT 'Expected error' AS TestResult, ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
GO

-- Test 5: Direct Approved to Rejected transition (should fail)
PRINT 'Test 5: Direct Approved to Rejected transition (should fail)';
BEGIN TRY
    EXEC dbo.UpdateShiftStatus @ShiftAssignmentID = 2003, @Status = 'Rejected';
END TRY
BEGIN CATCH
    SELECT 'Expected error' AS TestResult, ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
GO

-- Test 6: Direct Rejected to Approved transition (should fail)
PRINT 'Test 6: Direct Rejected to Approved transition (should fail)';
BEGIN TRY
    EXEC dbo.UpdateShiftStatus @ShiftAssignmentID = 2004, @Status = 'Approved';
END TRY
BEGIN CATCH
    SELECT 'Expected error' AS TestResult, ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
GO

-- Test 7: Modifying expired shift (should fail)
PRINT 'Test 7: Modifying expired shift (should fail)';
BEGIN TRY
    EXEC dbo.UpdateShiftStatus @ShiftAssignmentID = 2005, @Status = 'Approved';
END TRY
BEGIN CATCH
    SELECT 'Expected error' AS TestResult, ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
GO

-- Test 8: Valid status update (ASSIGNED -> Cancelled)
PRINT 'Test 8: Valid status update (ASSIGNED -> Cancelled)';
-- Create a fresh shift for this test
DELETE FROM dbo.ShiftSchedule WHERE ShiftID = 2006;
INSERT INTO dbo.ShiftSchedule (ShiftID, employee_id, start_date, end_date, status)
VALUES (2006, 100, '2025-07-06', '2025-07-12', 'ASSIGNED');
GO

BEGIN TRY
    EXEC dbo.UpdateShiftStatus @ShiftAssignmentID = 2006, @Status = 'Cancelled';
    SELECT status FROM dbo.ShiftSchedule WHERE ShiftID = 2006;
END TRY
BEGIN CATCH
    SELECT 'Error' AS TestResult, ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
GO


/***** 12) Test AssignShiftToDepartment *****/


PRINT '========================================';
PRINT 'TEST 12: AssignShiftToDepartment';
PRINT '========================================';

-- Clean up test shifts for department assignment
DELETE FROM dbo.ShiftSchedule WHERE ShiftID BETWEEN 3001 AND 3100;
GO

-- Test 1: Valid department shift assignment
PRINT 'Test 1: Valid department shift assignment';
BEGIN TRY
    EXEC dbo.AssignShiftToDepartment 
        @DepartmentID = 1, 
        @ShiftID = 3001, 
        @StartDate = '2025-08-01', 
        @EndDate = '2025-08-07';
    
    -- Verify assignments
    SELECT COUNT(*) AS AssignedShifts, MIN(ShiftID) AS FirstShiftID, MAX(ShiftID) AS LastShiftID
    FROM dbo.ShiftSchedule
    WHERE ShiftID >= 3001 AND employee_id IN (SELECT EmployeeID FROM dbo.Employee WHERE department_id = 1);
END TRY
BEGIN CATCH
    SELECT 'Error' AS TestResult, ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
GO

-- Test 2: Invalid department ID
PRINT 'Test 2: Invalid department ID (should fail)';
BEGIN TRY
    EXEC dbo.AssignShiftToDepartment 
        @DepartmentID = 9999, 
        @ShiftID = 3050, 
        @StartDate = '2025-08-08', 
        @EndDate = '2025-08-14';
END TRY
BEGIN CATCH
    SELECT 'Expected error' AS TestResult, ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
GO

-- Test 3: Duplicate ShiftID
PRINT 'Test 3: Duplicate ShiftID (should fail)';
BEGIN TRY
    EXEC dbo.AssignShiftToDepartment 
        @DepartmentID = 1, 
        @ShiftID = 3001, -- Already used
        @StartDate = '2025-08-15', 
        @EndDate = '2025-08-21';
END TRY
BEGIN CATCH
    SELECT 'Expected error' AS TestResult, ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
GO

-- Test 4: Invalid date range (start after end)
PRINT 'Test 4: Invalid date range (should fail)';
BEGIN TRY
    EXEC dbo.AssignShiftToDepartment 
        @DepartmentID = 1, 
        @ShiftID = 3060, 
        @StartDate = '2025-08-30', 
        @EndDate = '2025-08-23';
END TRY
BEGIN CATCH
    SELECT 'Expected error' AS TestResult, ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
GO

-- Test 5: Department with no active employees
PRINT 'Test 5: Department with no active employees';
-- Create a department with no employees
IF NOT EXISTS (SELECT 1 FROM dbo.Department WHERE DepartmentID = 99)
    INSERT INTO dbo.Department (DepartmentID, department_name, purpose)
    VALUES (99, 'Empty Dept', 'Test department with no employees');
GO

BEGIN TRY
    EXEC dbo.AssignShiftToDepartment 
        @DepartmentID = 99, 
        @ShiftID = 3070, 
        @StartDate = '2025-08-22', 
        @EndDate = '2025-08-28';
END TRY
BEGIN CATCH
    SELECT 'Expected error' AS TestResult, ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
GO

-- Test 6: Overlapping shifts (some employees may be skipped)
PRINT 'Test 6: Overlapping shifts handling';
BEGIN TRY
    -- First assignment
    EXEC dbo.AssignShiftToDepartment 
        @DepartmentID = 2, 
        @ShiftID = 3080, 
        @StartDate = '2025-09-01', 
        @EndDate = '2025-09-07';
    
    -- Attempt overlapping assignment
    EXEC dbo.AssignShiftToDepartment 
        @DepartmentID = 2, 
        @ShiftID = 3090, 
        @StartDate = '2025-09-05', 
        @EndDate = '2025-09-11';
END TRY
BEGIN CATCH
    SELECT 'Error' AS TestResult, ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
GO

PRINT 'Test 12 complete.';
PRINT '';
GO

/***** 13) Test AssignCustomShift *****/

PRINT '========================================';
PRINT 'TEST 13: AssignCustomShift';
PRINT '========================================';


-- Clean up test custom shifts
DELETE FROM dbo.ShiftSchedule WHERE ShiftID BETWEEN 4001 AND 4020 OR shift_name LIKE 'CustomTest%';
GO

-- Test 1: Valid custom shift assignment (regular day shift)
PRINT 'Test 1: Valid custom shift assignment (day shift)';
BEGIN TRY
    DECLARE @NewShiftID1 INT;
    EXEC dbo.AssignCustomShift 
        @EmployeeID = 101,
        @ShiftName = 'CustomTest-DayShift',
        @ShiftType = 'Regular',
        @StartTime = '09:00:00',
        @EndTime = '17:00:00',
        @StartDate = '2025-10-01',
        @EndDate = '2025-10-31';
    
    -- Verify
    SELECT ShiftID, employee_id, shift_name, shift_type, start_time, end_time, start_date, end_date
    FROM dbo.ShiftSchedule
    WHERE shift_name = 'CustomTest-DayShift';
END TRY
BEGIN CATCH
    SELECT 'Error' AS TestResult, ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
GO

-- Test 2: Valid custom shift assignment (night shift / overnight)
PRINT 'Test 2: Valid custom shift assignment (overnight shift)';
BEGIN TRY
    EXEC dbo.AssignCustomShift 
        @EmployeeID = 102,
        @ShiftName = 'CustomTest-NightShift',
        @ShiftType = 'Overnight',
        @StartTime = '22:00:00',
        @EndTime = '06:00:00',
        @StartDate = '2025-11-01',
        @EndDate = '2025-11-30';
    
    -- Verify
    SELECT ShiftID, employee_id, shift_name, shift_type, start_time, end_time
    FROM dbo.ShiftSchedule
    WHERE shift_name = 'CustomTest-NightShift';
END TRY
BEGIN CATCH
    SELECT 'Error' AS TestResult, ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
GO

-- Test 3: Non-existent employee
PRINT 'Test 3: Non-existent employee (should fail)';
BEGIN TRY
    EXEC dbo.AssignCustomShift 
        @EmployeeID = 9999,
        @ShiftName = 'CustomTest-Invalid',
        @ShiftType = 'Regular',
        @StartTime = '09:00:00',
        @EndTime = '17:00:00',
        @StartDate = '2025-11-01',
        @EndDate = '2025-11-30';
END TRY
BEGIN CATCH
    SELECT 'Expected error' AS TestResult, ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
GO

-- Test 4: Missing required field (shift name)
PRINT 'Test 4: Missing shift name (should fail)';
BEGIN TRY
    EXEC dbo.AssignCustomShift 
        @EmployeeID = 101,
        @ShiftName = '',
        @ShiftType = 'Regular',
        @StartTime = '09:00:00',
        @EndTime = '17:00:00',
        @StartDate = '2025-12-01',
        @EndDate = '2025-12-31';
END TRY
BEGIN CATCH
    SELECT 'Expected error' AS TestResult, ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
GO

-- Test 5: Invalid date range
PRINT 'Test 5: Invalid date range (should fail)';
BEGIN TRY
    EXEC dbo.AssignCustomShift 
        @EmployeeID = 101,
        @ShiftName = 'CustomTest-InvalidDates',
        @ShiftType = 'Regular',
        @StartTime = '09:00:00',
        @EndTime = '17:00:00',
        @StartDate = '2025-12-31',
        @EndDate = '2025-12-01';
END TRY
BEGIN CATCH
    SELECT 'Expected error' AS TestResult, ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
GO

-- Test 6: Overlapping custom shift
PRINT 'Test 6: Overlapping custom shift (should fail)';
BEGIN TRY
    EXEC dbo.AssignCustomShift 
        @EmployeeID = 101,
        @ShiftName = 'CustomTest-Overlap',
        @ShiftType = 'Regular',
        @StartTime = '10:00:00',
        @EndTime = '18:00:00',
        @StartDate = '2025-10-15', -- Overlaps with first test shift
        @EndDate = '2025-10-20';
END TRY
BEGIN CATCH
    SELECT 'Expected error' AS TestResult, ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
GO

-- Test 7: Split shift timing
PRINT 'Test 7: Split shift timing (valid)';
BEGIN TRY
    EXEC dbo.AssignCustomShift 
        @EmployeeID = 103,
        @ShiftName = 'CustomTest-SplitStyle',
        @ShiftType = 'Split',
        @StartTime = '08:00:00',
        @EndTime = '12:00:00', -- First part of split shift
        @StartDate = '2025-12-01',
        @EndDate = '2025-12-31';
    
    SELECT ShiftID, shift_name, start_time, end_time
    FROM dbo.ShiftSchedule
    WHERE shift_name = 'CustomTest-SplitStyle';
END TRY
BEGIN CATCH
    SELECT 'Error' AS TestResult, ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
GO

PRINT 'Test 13 complete.';
PRINT '';
GO

/***** 14) Test ConfigureSplitShift *****/
GO


PRINT '========================================';
PRINT 'TEST 14: ConfigureSplitShift';
PRINT '========================================';

-- Clean up test split shift configurations
DELETE FROM dbo.SplitShiftConfiguration WHERE shift_name LIKE 'TestSplit%';
GO

-- Test 1: Valid split shift configuration (8-12, 4-8 pattern)
PRINT 'Test 1: Valid split shift configuration (8-12, 4-8)';
BEGIN TRY
    EXEC dbo.ConfigureSplitShift 
        @ShiftName = 'TestSplit-Morning-Evening',
        @FirstSlotStart = '08:00:00',
        @FirstSlotEnd = '12:00:00',
        @SecondSlotStart = '16:00:00',
        @SecondSlotEnd = '20:00:00';
    
    -- Verify
    SELECT * FROM dbo.SplitShiftConfiguration WHERE shift_name = 'TestSplit-Morning-Evening';
END TRY
BEGIN CATCH
    SELECT 'Error' AS TestResult, ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
GO

-- Test 2: Valid split shift configuration (different pattern)
PRINT 'Test 2: Valid split shift configuration (6-10, 2-6)';
BEGIN TRY
    EXEC dbo.ConfigureSplitShift 
        @ShiftName = 'TestSplit-EarlyLate',
        @FirstSlotStart = '06:00:00',
        @FirstSlotEnd = '10:00:00',
        @SecondSlotStart = '14:00:00',
        @SecondSlotEnd = '18:00:00';
    
    -- Verify
    SELECT shift_name, total_hours, break_duration_minutes 
    FROM dbo.SplitShiftConfiguration 
    WHERE shift_name = 'TestSplit-EarlyLate';
END TRY
BEGIN CATCH
    SELECT 'Error' AS TestResult, ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
GO

-- Test 3: Missing shift name
PRINT 'Test 3: Missing shift name (should fail)';
BEGIN TRY
    EXEC dbo.ConfigureSplitShift 
        @ShiftName = '',
        @FirstSlotStart = '08:00:00',
        @FirstSlotEnd = '12:00:00',
        @SecondSlotStart = '16:00:00',
        @SecondSlotEnd = '20:00:00';
END TRY
BEGIN CATCH
    SELECT 'Expected error' AS TestResult, ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
GO

-- Test 4: Invalid first slot (start >= end)
PRINT 'Test 4: Invalid first slot timing (should fail)';
BEGIN TRY
    EXEC dbo.ConfigureSplitShift 
        @ShiftName = 'TestSplit-Invalid1',
        @FirstSlotStart = '12:00:00',
        @FirstSlotEnd = '08:00:00',
        @SecondSlotStart = '16:00:00',
        @SecondSlotEnd = '20:00:00';
END TRY
BEGIN CATCH
    SELECT 'Expected error' AS TestResult, ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
GO

-- Test 5: Invalid second slot (start >= end)
PRINT 'Test 5: Invalid second slot timing (should fail)';
BEGIN TRY
    EXEC dbo.ConfigureSplitShift 
        @ShiftName = 'TestSplit-Invalid2',
        @FirstSlotStart = '08:00:00',
        @FirstSlotEnd = '12:00:00',
        @SecondSlotStart = '20:00:00',
        @SecondSlotEnd = '16:00:00';
END TRY
BEGIN CATCH
    SELECT 'Expected error' AS TestResult, ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
GO

-- Test 6: Second slot starts before first slot ends
PRINT 'Test 6: Second slot overlaps first slot (should fail)';
BEGIN TRY
    EXEC dbo.ConfigureSplitShift 
        @ShiftName = 'TestSplit-Overlap',
        @FirstSlotStart = '08:00:00',
        @FirstSlotEnd = '12:00:00',
        @SecondSlotStart = '11:00:00',
        @SecondSlotEnd = '15:00:00';
END TRY
BEGIN CATCH
    SELECT 'Expected error' AS TestResult, ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
GO

-- Test 7: Duplicate shift name
PRINT 'Test 7: Duplicate shift name (should fail)';
BEGIN TRY
    EXEC dbo.ConfigureSplitShift 
        @ShiftName = 'TestSplit-Morning-Evening', -- Already exists from Test 1
        @FirstSlotStart = '09:00:00',
        @FirstSlotEnd = '13:00:00',
        @SecondSlotStart = '17:00:00',
        @SecondSlotEnd = '21:00:00';
END TRY
BEGIN CATCH
    SELECT 'Expected error' AS TestResult, ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
GO

-- Test 8: Very short break between slots
PRINT 'Test 8: Short break between slots (valid)';
BEGIN TRY
    EXEC dbo.ConfigureSplitShift 
        @ShiftName = 'TestSplit-ShortBreak',
        @FirstSlotStart = '08:00:00',
        @FirstSlotEnd = '12:00:00',
        @SecondSlotStart = '12:30:00',
        @SecondSlotEnd = '16:30:00';
    
    SELECT shift_name, break_duration_minutes 
    FROM dbo.SplitShiftConfiguration 
    WHERE shift_name = 'TestSplit-ShortBreak';
END TRY
BEGIN CATCH
    SELECT 'Error' AS TestResult, ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
GO

PRINT 'Test 14 complete.';
PRINT '';
GO


/***** 15) Test EnableFirstInLastOut *****/

PRINT '========================================';
PRINT 'TEST 15: EnableFirstInLastOut';
PRINT '========================================';

-- Test 1: Enable First In/Last Out
PRINT 'Test 1: Enable First In/Last Out';
BEGIN TRY
    EXEC dbo.EnableFirstInLastOut @Enable = 1;
    
    -- Verify
    SELECT ConfigKey, ConfigValue, LastModified
    FROM dbo.SystemConfiguration
    WHERE ConfigKey = 'ATTENDANCE_FIRST_IN_LAST_OUT';
END TRY
BEGIN CATCH
    SELECT 'Error' AS TestResult, ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
GO

-- Test 2: Disable First In/Last Out
PRINT 'Test 2: Disable First In/Last Out';
BEGIN TRY
    EXEC dbo.EnableFirstInLastOut @Enable = 0;
    
    -- Verify
    SELECT ConfigKey, ConfigValue, LastModified
    FROM dbo.SystemConfiguration
    WHERE ConfigKey = 'ATTENDANCE_FIRST_IN_LAST_OUT';
END TRY
BEGIN CATCH
    SELECT 'Error' AS TestResult, ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
GO

-- Test 3: Re-enable (update existing configuration)
PRINT 'Test 3: Re-enable (update existing configuration)';
BEGIN TRY
    EXEC dbo.EnableFirstInLastOut @Enable = 1;
    
    -- Verify
    SELECT ConfigKey, ConfigValue, ModifiedBy, LastModified
    FROM dbo.SystemConfiguration
    WHERE ConfigKey = 'ATTENDANCE_FIRST_IN_LAST_OUT';
END TRY
BEGIN CATCH
    SELECT 'Error' AS TestResult, ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
GO

-- Test 4: NULL parameter (should fail)
PRINT 'Test 4: NULL parameter (should fail)';
BEGIN TRY
    EXEC dbo.EnableFirstInLastOut @Enable = NULL;
END TRY
BEGIN CATCH
    SELECT 'Expected error' AS TestResult, ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
GO

-- Test 5: Multiple toggles (stress test)
PRINT 'Test 5: Multiple toggles';
BEGIN TRY
    EXEC dbo.EnableFirstInLastOut @Enable = 0;
    EXEC dbo.EnableFirstInLastOut @Enable = 1;
    EXEC dbo.EnableFirstInLastOut @Enable = 0;
    EXEC dbo.EnableFirstInLastOut @Enable = 1;
    
    -- Final state
    SELECT ConfigKey, ConfigValue, LastModified
    FROM dbo.SystemConfiguration
    WHERE ConfigKey = 'ATTENDANCE_FIRST_IN_LAST_OUT';
END TRY
BEGIN CATCH
    SELECT 'Error' AS TestResult, ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
GO

--Additional verification for procs 12, 13, 14, 15
-- Show final state of key tables
PRINT 'Final state verification:';
SELECT 'ShiftSchedule' AS TableName, COUNT(*) AS RecordCount FROM dbo.ShiftSchedule WHERE ShiftID >= 2001
UNION ALL
SELECT 'SplitShiftConfiguration', COUNT(*) FROM dbo.SplitShiftConfiguration WHERE shift_name LIKE 'TestSplit%'
UNION ALL
SELECT 'SystemConfiguration', COUNT(*) FROM dbo.SystemConfiguration WHERE ConfigKey = 'ATTENDANCE_FIRST_IN_LAST_OUT';
GO


/***** 16) Test TagAttendanceSource *****/
USE MILESTONE2;
GO

PRINT '========================================';
PRINT 'TEST 16: TagAttendanceSource';
PRINT '========================================';

-- Setup: Create test device and attendance records
IF NOT EXISTS (SELECT 1 FROM dbo.Device WHERE DeviceID = 5001)
    INSERT INTO dbo.Device (DeviceID, device_type, terminal_id, latitude, longitude, employee_id)
    VALUES (5001, 'Biometric', 'TERM-5001', 40.712800, -74.006000, NULL);
GO

DELETE FROM dbo.AttendanceSource WHERE attendance_id BETWEEN 6001 AND 6004;
DELETE FROM dbo.Attendance WHERE AttendanceID BETWEEN 6001 AND 6004;
GO

INSERT INTO dbo.Attendance (AttendanceID, employee_id, entry_time, exit_time, duration, login_method, logout_method, exception_id)
VALUES 
    (6001, 100, '08:00:00', NULL, NULL, 'Device', NULL, NULL),
    (6002, 101, '09:00:00', NULL, NULL, 'Manual', NULL, NULL);
GO

-- Test 1: Valid device-based attendance source
PRINT 'Test 1: Valid device tagging';
EXEC dbo.TagAttendanceSource 
    @AttendanceID = 6001, @SourceType = 'Device', @DeviceID = 5001, 
    @Latitude = 40.712800, @Longitude = -74.006000;
GO

-- Test 2: Valid GPS source
PRINT 'Test 2: Valid GPS source';
EXEC dbo.TagAttendanceSource 
    @AttendanceID = 6002, @SourceType = 'GPS', @Latitude = 51.507400, @Longitude = -0.127800;
GO

-- Test 3: Invalid source type (should fail)
PRINT 'Test 3: Invalid source type (should fail)';
BEGIN TRY
    EXEC dbo.TagAttendanceSource @AttendanceID = 6001, @SourceType = 'InvalidType';
END TRY
BEGIN CATCH
    SELECT 'Expected error' AS TestResult, ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
GO

PRINT 'Test 16 complete.';
GO


/***** 17) Test SyncOfflineAttendance *****/
USE MILESTONE2;
GO

PRINT '========================================';
PRINT 'TEST 17: SyncOfflineAttendance';
PRINT '========================================';

-- Setup
IF NOT EXISTS (SELECT 1 FROM dbo.Device WHERE DeviceID = 5003)
    INSERT INTO dbo.Device (DeviceID, device_type, terminal_id, latitude, longitude, employee_id)
    VALUES (5003, 'Clock Terminal', 'TERM-5003', 34.052200, -118.243700, NULL);
GO

DELETE FROM dbo.OfflineAttendanceQueue WHERE device_id = 5003;
GO

-- Test 1: Valid clock IN sync
PRINT 'Test 1: Valid clock IN sync';
EXEC dbo.SyncOfflineAttendance 
    @DeviceID = 5003, @EmployeeID = 100, 
    @ClockTime = '2025-11-27 08:00:00', @Type = 'IN';
GO

-- Test 2: Valid clock OUT sync
PRINT 'Test 2: Valid clock OUT sync';
EXEC dbo.SyncOfflineAttendance 
    @DeviceID = 5003, @EmployeeID = 100, 
    @ClockTime = '2025-11-27 17:00:00', @Type = 'OUT';
GO

-- Test 3: Invalid clock type (should fail)
PRINT 'Test 3: Invalid clock type (should fail)';
BEGIN TRY
    EXEC dbo.SyncOfflineAttendance 
        @DeviceID = 5003, @EmployeeID = 100, 
        @ClockTime = '2025-11-27 08:00:00', @Type = 'INVALID';
END TRY
BEGIN CATCH
    SELECT 'Expected error' AS TestResult, ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
GO

PRINT 'Test 17 complete.';
GO


/***** 18) Test LogAttendanceEdit *****/
USE MILESTONE2;
GO


PRINT '========================================';
PRINT 'TEST 18: LogAttendanceEdit';
PRINT '========================================';

-- Setup
DELETE FROM dbo.AttendanceLog WHERE attendance_id BETWEEN 7001 AND 7002;
DELETE FROM dbo.Attendance WHERE AttendanceID BETWEEN 7001 AND 7002;
GO

INSERT INTO dbo.Attendance (AttendanceID, employee_id, entry_time, exit_time, duration, login_method, logout_method, exception_id)
VALUES 
    (7001, 100, '08:00:00', '17:00:00', 540, 'Manual', 'Manual', NULL),
    (7002, 101, '09:00:00', '18:00:00', 540, 'Device', 'Device', NULL);
GO

-- Test 1: Valid attendance edit log
PRINT 'Test 1: Valid edit log';
EXEC dbo.LogAttendanceEdit 
    @AttendanceID = 7001, @EditedBy = 1, 
    @OldValue = '2025-11-27 08:00:00', @NewValue = '2025-11-27 08:05:00';
GO

-- Test 2: Multiple edits to same attendance
PRINT 'Test 2: Multiple edits (audit trail)';
EXEC dbo.LogAttendanceEdit 
    @AttendanceID = 7002, @EditedBy = 1, 
    @OldValue = '2025-11-27 09:00:00', @NewValue = '2025-11-27 09:05:00';
EXEC dbo.LogAttendanceEdit 
    @AttendanceID = 7002, @EditedBy = 2, 
    @OldValue = '2025-11-27 09:05:00', @NewValue = '2025-11-27 09:10:00';
GO

-- Test 3: Identical values (should fail)
PRINT 'Test 3: Identical values (should fail)';
BEGIN TRY
    EXEC dbo.LogAttendanceEdit 
        @AttendanceID = 7001, @EditedBy = 1, 
        @OldValue = '2025-11-27 08:00:00', @NewValue = '2025-11-27 08:00:00';
END TRY
BEGIN CATCH
    SELECT 'Expected error' AS TestResult, ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
GO

PRINT 'Test 18 complete.';
GO

/***** 19) Test ApplyHolidayOverrides *****/
USE MILESTONE2;
GO

PRINT '========================================';
PRINT 'TEST 19: ApplyHolidayOverrides';
PRINT '========================================';

-- Setup
IF NOT EXISTS (SELECT 1 FROM dbo.Leave WHERE LeaveID = 8001)
    INSERT INTO dbo.Leave (LeaveID, leave_type, leave_description)
    VALUES (8001, 'Holiday', 'New Year Day');
GO

IF NOT EXISTS (SELECT 1 FROM dbo.HolidayLeave WHERE leave_id = 8001)
    INSERT INTO dbo.HolidayLeave (leave_id, holiday_name, official_recognition, regional_scope)
    VALUES (8001, 'New Year Day 2026', 1, 'National');
GO

DELETE FROM dbo.ShiftSchedule WHERE ShiftID BETWEEN 8001 AND 8003;
GO

INSERT INTO dbo.ShiftSchedule (ShiftID, employee_id, start_date, end_date, status)
VALUES 
    (8001, 100, '2026-01-01', '2026-01-05', 'ASSIGNED'),
    (8002, 101, '2025-12-30', '2026-01-03', 'ASSIGNED');
GO

-- Test 1: Apply holiday to all employees
PRINT 'Test 1: Apply holiday to all employees';
EXEC dbo.ApplyHolidayOverrides 
    @HolidayID = 8001, @EmployeeID = NULL, 
    @StartDate = '2026-01-01', @EndDate = '2026-01-01';
GO

-- Test 2: Apply holiday to specific employee
PRINT 'Test 2: Apply to specific employee';
INSERT INTO dbo.ShiftSchedule (ShiftID, employee_id, start_date, end_date, status)
VALUES (8003, 100, '2026-07-04', '2026-07-08', 'ASSIGNED');
GO

EXEC dbo.ApplyHolidayOverrides 
    @HolidayID = 8001, @EmployeeID = 100, 
    @StartDate = '2026-07-04', @EndDate = '2026-07-04';
GO

-- Test 3: Invalid date range (should fail)
PRINT 'Test 3: Invalid date range (should fail)';
BEGIN TRY
    EXEC dbo.ApplyHolidayOverrides 
        @HolidayID = 8001, @StartDate = '2026-01-10', @EndDate = '2026-01-01';
END TRY
BEGIN CATCH
    SELECT 'Expected error' AS TestResult, ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
GO

PRINT 'Test 19 complete.';
GO


/***** 20) Test ManageUserAccounts *****/
USE MILESTONE2;
GO

PRINT '========================================';
PRINT 'TEST 20: ManageUserAccounts';
PRINT '========================================';

-- Setup
IF NOT EXISTS (SELECT 1 FROM dbo.Employee WHERE EmployeeID = 200)
    INSERT INTO dbo.Employee (EmployeeID, first_name, last_name, email, hire_date, is_active, department_id, position_id, account_status)
    VALUES (200, 'Test', 'Admin', 'test.admin@example.com', GETDATE(), 1, 1, 1, 'ACTIVE');
GO

DELETE FROM dbo.EmployeeRole WHERE employee_id = 200;
DELETE FROM dbo.SystemAdministrator WHERE employee_id = 200;
DELETE FROM dbo.HRAdministrator WHERE employee_id = 200;
GO

-- Test 1: ADD System Administrator role
PRINT 'Test 1: ADD System Administrator role';
EXEC dbo.ManageUserAccounts 
    @UserID = 200, @Role = 'System Administrator', @Action = 'ADD';
GO

-- Test 2: ADD duplicate role (should show already assigned)
PRINT 'Test 2: ADD duplicate role';
EXEC dbo.ManageUserAccounts 
    @UserID = 200, @Role = 'System Administrator', @Action = 'ADD';
GO

-- Test 3: DEACTIVATE user account
PRINT 'Test 3: DEACTIVATE user account';
EXEC dbo.ManageUserAccounts 
    @UserID = 200, @Role = 'System Administrator', @Action = 'DEACTIVATE';
SELECT EmployeeID, is_active, account_status FROM dbo.Employee WHERE EmployeeID = 200;
GO

-- Test 4: ACTIVATE user account
PRINT 'Test 4: ACTIVATE user account';
EXEC dbo.ManageUserAccounts 
    @UserID = 200, @Role = 'System Administrator', @Action = 'ACTIVATE';
SELECT EmployeeID, is_active, account_status FROM dbo.Employee WHERE EmployeeID = 200;
GO

-- Test 5: Invalid action (should fail)
PRINT 'Test 5: Invalid action (should fail)';
BEGIN TRY
    EXEC dbo.ManageUserAccounts 
        @UserID = 200, @Role = 'System Administrator', @Action = 'INVALID';
END TRY
BEGIN CATCH
    SELECT 'Expected error' AS TestResult, ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
GO

PRINT 'Test 20 complete.';
GO


-- TEST SUITE FOR HR ADMIN PROCEDURES
USE MILESTONE2;
GO

-- ========================================
-- SETUP: Create Test Data
-- ========================================
PRINT 'Setting up test data...';
GO

-- Create test departments
IF NOT EXISTS (SELECT 1 FROM Department WHERE DepartmentID = 1)
    INSERT INTO Department (DepartmentID, department_name, purpose) VALUES (1, 'IT Department', 'Technology');
IF NOT EXISTS (SELECT 1 FROM Department WHERE DepartmentID = 2)
    INSERT INTO Department (DepartmentID, department_name, purpose) VALUES (2, 'HR Department', 'Human Resources');

-- Create test positions
IF NOT EXISTS (SELECT 1 FROM Position WHERE PositionID = 1)
    INSERT INTO Position (PositionID, position_title, responsibilities, status) VALUES (1, 'Software Engineer', 'Development', 'Active');
IF NOT EXISTS (SELECT 1 FROM Position WHERE PositionID = 2)
    INSERT INTO Position (PositionID, position_title, responsibilities, status) VALUES (2, 'HR Manager', 'HR Operations', 'Active');

-- Create test roles
IF NOT EXISTS (SELECT 1 FROM Role WHERE RoleID = 1)
    INSERT INTO Role (RoleID, role_name, purpose) VALUES (1, 'Developer', 'Software Development');
IF NOT EXISTS (SELECT 1 FROM Role WHERE RoleID = 2)
    INSERT INTO Role (RoleID, role_name, purpose) VALUES (2, 'HR Admin', 'HR Administration');

-- Create test employees
IF NOT EXISTS (SELECT 1 FROM Employee WHERE EmployeeID = 1001)
    INSERT INTO Employee (EmployeeID, first_name, last_name, national_id, date_of_birth, country_of_birth, phone, email, hire_date, is_active, employment_status, account_status)
    VALUES (1001, 'John', 'Doe', 'N1001', '1990-01-01', 'USA', '1234567890', 'john.doe@test.com', '2023-01-01', 1, 'Active', 'Active');

IF NOT EXISTS (SELECT 1 FROM Employee WHERE EmployeeID = 1002)
    INSERT INTO Employee (EmployeeID, first_name, last_name, national_id, date_of_birth, country_of_birth, phone, email, hire_date, is_active, employment_status, account_status, manager_id, department_id)
    VALUES (1002, 'Jane', 'Smith', 'N1002', '1992-05-15', 'USA', '0987654321', 'jane.smith@test.com', '2023-02-01', 1, 'Active', 'Active', 1001, 1);

IF NOT EXISTS (SELECT 1 FROM Employee WHERE EmployeeID = 1003)
    INSERT INTO Employee (EmployeeID, first_name, last_name, national_id, date_of_birth, country_of_birth, phone, email, hire_date, is_active, employment_status, account_status, manager_id, department_id)
    VALUES (1003, 'Bob', 'Johnson', 'N1003', '1988-08-20', 'USA', '5551234567', 'bob.johnson@test.com', '2023-03-01', 1, 'Active', 'Active', 1001, 1);

-- Create Line Manager
IF NOT EXISTS (SELECT 1 FROM LineManager WHERE employee_id = 1001)
    INSERT INTO LineManager (employee_id, team_size, supervised_departments, approval_limit) VALUES (1001, 5, 'IT', 10000.00);

-- Create HR Administrator
IF NOT EXISTS (SELECT 1 FROM HRAdministrator WHERE employee_id = 1001)
    INSERT INTO HRAdministrator (employee_id, approval_level, record_access_scope, document_validation_rights) VALUES (1001, 'Senior', 'All', 1);

-- Create test leave types
IF NOT EXISTS (SELECT 1 FROM Leave WHERE LeaveID = 1)
    INSERT INTO Leave (LeaveID, leave_type, leave_description) VALUES (1, 'Vacation', 'Annual vacation leave');
IF NOT EXISTS (SELECT 1 FROM Leave WHERE LeaveID = 2)
    INSERT INTO Leave (LeaveID, leave_type, leave_description) VALUES (2, 'Sick', 'Medical sick leave');

-- Create vacation leave details
IF NOT EXISTS (SELECT 1 FROM VacationLeave WHERE leave_id = 1)
    INSERT INTO VacationLeave (leave_id, carry_over_days, approving_manager) VALUES (1, 5, 'Line Manager');

-- Create sick leave details
IF NOT EXISTS (SELECT 1 FROM SickLeave WHERE leave_id = 2)
    INSERT INTO SickLeave (leave_id, medical_certificate_required, physician_id) VALUES (2, 1, NULL);

    
-- Ensure test employees exist
IF NOT EXISTS (SELECT 1 FROM Employee WHERE EmployeeID = 2001)
    INSERT INTO Employee (EmployeeID, first_name, last_name, national_id, date_of_birth, country_of_birth, phone, email, hire_date, is_active, employment_status, account_status, manager_id)
    VALUES (2001, 'David', 'Miller', 'N2001', '1987-04-12', 'USA', '5551112233', 'david.miller@test.com', '2023-05-01', 1, 'Active', 'Active', 1001);

IF NOT EXISTS (SELECT 1 FROM Employee WHERE EmployeeID = 2002)
    INSERT INTO Employee (EmployeeID, first_name, last_name, national_id, date_of_birth, country_of_birth, phone, email, hire_date, is_active, employment_status, account_status, manager_id)
    VALUES (2002, 'Emma', 'Davis', 'N2002', '1994-11-08', 'UK', '5552223344', 'emma.davis@test.com', '2023-06-15', 1, 'Active', 'Active', 1001);

-- Create contracts for test employees
IF NOT EXISTS (SELECT 1 FROM Contract WHERE ContractID = 101)
BEGIN
    INSERT INTO Contract (ContractID, type, start_date, end_date, current_state)
    VALUES (101, 'Full-Time', '2023-05-01', '2025-05-01', 'Active');
    
    UPDATE Employee SET contract_id = 101 WHERE EmployeeID = 2001;
    
    INSERT INTO FullTimeContract (contract_id, leave_entitlement, insurance_eligibility, weekly_working_hours)
    VALUES (101, 21, 1, 40);
END

IF NOT EXISTS (SELECT 1 FROM Contract WHERE ContractID = 102)
BEGIN
    INSERT INTO Contract (ContractID, type, start_date, end_date, current_state)
    VALUES (102, 'Part-Time', '2023-06-15', '2024-12-31', 'Active');
    
    UPDATE Employee SET contract_id = 102 WHERE EmployeeID = 2002;
    
    INSERT INTO PartTimeContract (contract_id, working_hours, hourly_rate)
    VALUES (102, 20, 25.00);
END

-- Ensure Vacation leave type exists
IF NOT EXISTS (SELECT 1 FROM Leave WHERE leave_type = 'Vacation')
BEGIN
    INSERT INTO Leave (LeaveID, leave_type, leave_description) VALUES (10, 'Vacation', 'Annual vacation leave');
    INSERT INTO VacationLeave (leave_id, carry_over_days, approving_manager) VALUES (10, 5, 'Line Manager');
END

-- Create ShiftAssignment table if not exists
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'ShiftAssignment')
BEGIN
    CREATE TABLE ShiftAssignment (
        AssignmentID INT PRIMARY KEY,
        employee_id INT,
        shift_cycle_days INT,
        start_date DATE,
        end_date DATE,
        status VARCHAR(50)
    );
END

-- Create LeaveRole table if not exists
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'LeaveRole')
BEGIN
    CREATE TABLE LeaveRole (
        role_id INT PRIMARY KEY,
        role_name VARCHAR(100),
        permissions VARCHAR(200),
        created_at DATETIME,
        updated_at DATETIME
    );
END

-- Create test shift assignments
IF NOT EXISTS (SELECT 1 FROM ShiftAssignment WHERE employee_id = 2001 AND status = 'Active')
    INSERT INTO ShiftAssignment (AssignmentID, employee_id, shift_cycle_days, start_date, end_date, status)
    VALUES (201, 2001, 7, '2024-01-01', '2024-12-31', 'Active');

IF NOT EXISTS (SELECT 1 FROM ShiftAssignment WHERE employee_id = 2002 AND status = 'Active')
    INSERT INTO ShiftAssignment (AssignmentID, employee_id, shift_cycle_days, start_date, end_date, status)
    VALUES (202, 2002, 14, '2024-01-01', '2024-12-31', 'Active');

-- Create test leave entitlements
IF NOT EXISTS (SELECT 1 FROM LeaveEntitlement WHERE employee_id = 2001)
BEGIN
    DECLARE @VacLeaveID INT;
    SELECT @VacLeaveID = LeaveID FROM Leave WHERE leave_type = 'Vacation';
    
    IF @VacLeaveID IS NOT NULL
    BEGIN
        INSERT INTO LeaveEntitlement (employee_id, leave_type_id, entitlement)
        VALUES (2001, @VacLeaveID, 21);
        
        INSERT INTO LeaveEntitlement (employee_id, leave_type_id, entitlement)
        VALUES (2002, @VacLeaveID, 10);
    END
END


-- Create Currency table if not exists
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Currency')
BEGIN
    CREATE TABLE Currency (
        CurrencyCode VARCHAR(10) PRIMARY KEY,
        currency_name VARCHAR(50),
        exchange_rate DECIMAL(18,4),
        created_date DATETIME,
        last_updated DATETIME
    );
END

-- Insert test currency
IF NOT EXISTS (SELECT 1 FROM Currency WHERE CurrencyCode = 'USD')
    INSERT INTO Currency (CurrencyCode, currency_name, exchange_rate, created_date, last_updated)
    VALUES ('USD', 'US Dollar', 1.0000, GETDATE(), GETDATE());

-- Create PayrollSpecialist table entries
IF NOT EXISTS (SELECT 1 FROM PayrollSpecialist WHERE employee_id = 1001)
    INSERT INTO PayrollSpecialist (employee_id, assigned_region, processing_frequency, last_processed_period)
    VALUES (1001, 'All', 'Monthly', GETDATE());

-- Create test leave documents table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'LeaveDocument')
BEGIN
    CREATE TABLE LeaveDocument (
        DocumentID INT PRIMARY KEY,
        leave_request_id INT,
        file_path VARCHAR(200),
        uploaded_at DATETIME
    );
END

-- Ensure leave entitlements exist for testing procedures 35, 37, 39, 41
DECLARE @VacID INT;
SELECT @VacID = LeaveID FROM Leave WHERE leave_type = 'Vacation';

IF @VacID IS NOT NULL
BEGIN
    -- Ensure employee 2001 has vacation entitlement
    IF NOT EXISTS (SELECT 1 FROM LeaveEntitlement WHERE employee_id = 2001 AND leave_type_id = @VacID)
        INSERT INTO LeaveEntitlement (employee_id, leave_type_id, entitlement)
        VALUES (2001, @VacID, 21);
    
    -- Ensure employee 2002 has vacation entitlement  
    IF NOT EXISTS (SELECT 1 FROM LeaveEntitlement WHERE employee_id = 2002 AND leave_type_id = @VacID)
        INSERT INTO LeaveEntitlement (employee_id, leave_type_id, entitlement)
        VALUES (2002, @VacID, 10);
END

-- Create test leave requests for procedures 37, 38, 39, 40, 41
IF NOT EXISTS (SELECT 1 FROM LeaveRequest WHERE RequestID = 500)
    INSERT INTO LeaveRequest (RequestID, employee_id, leave_id, justification, duration, approval_timing, status)
    VALUES (500, 2001, @VacID, 'Testing finalization', 5, GETDATE(), 'APPROVED');

IF NOT EXISTS (SELECT 1 FROM LeaveRequest WHERE RequestID = 501)
    INSERT INTO LeaveRequest (RequestID, employee_id, leave_id, justification, duration, approval_timing, status)
    VALUES (501, 2002, @VacID, 'For bulk processing', 3, GETDATE(), 'APPROVED');

IF NOT EXISTS (SELECT 1 FROM LeaveRequest WHERE RequestID = 502)
    INSERT INTO LeaveRequest (RequestID, employee_id, leave_id, justification, duration, approval_timing, status)
    VALUES (502, 2001, 2, 'Medical leave for testing', 2, GETDATE(), 'APPROVED');

PRINT 'Test data setup complete.';
PRINT '';

-- ========================================
-- TEST PROCEDURE 1: CreateContract
-- ========================================
PRINT '========================================';
PRINT 'TEST 1: CreateContract';
PRINT '========================================';

-- Test 1.1: Successful Full-Time Contract Creation
PRINT 'Test 1.1: Create Full-Time contract for employee 1001';
BEGIN TRY
    EXEC CreateContract @EmployeeID = 1001, @Type = 'Full-Time', @StartDate = '2024-01-01', @EndDate = '2025-12-31';
    PRINT '? Test 1.1 PASSED: Full-Time contract created successfully';
END TRY
BEGIN CATCH
    PRINT '? Test 1.1 FAILED: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 1.2: Successful Part-Time Contract Creation
PRINT 'Test 1.2: Create Part-Time contract for employee 1002';
BEGIN TRY
    EXEC CreateContract @EmployeeID = 1002, @Type = 'Part-Time', @StartDate = '2024-01-01', @EndDate = '2024-12-31';
    PRINT '? Test 1.2 PASSED: Part-Time contract created successfully';
END TRY
BEGIN CATCH
    PRINT '? Test 1.2 FAILED: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 1.3: Corner Case - Invalid Contract Type
PRINT 'Test 1.3: Attempt to create contract with invalid type';
BEGIN TRY
    EXEC CreateContract @EmployeeID = 1003, @Type = 'InvalidType', @StartDate = '2024-01-01', @EndDate = '2024-12-31';
    PRINT '? Test 1.3 FAILED: Should have rejected invalid contract type';
END TRY
BEGIN CATCH
    PRINT '? Test 1.3 PASSED: Correctly rejected invalid contract type';
END CATCH
PRINT '';

-- Test 1.4: Corner Case - Start Date After End Date
PRINT 'Test 1.4: Attempt to create contract with start date after end date';
BEGIN TRY
    EXEC CreateContract @EmployeeID = 1003, @Type = 'Internship', @StartDate = '2024-12-31', @EndDate = '2024-01-01';
    PRINT '? Test 1.4 FAILED: Should have rejected invalid date range';
END TRY
BEGIN CATCH
    PRINT '? Test 1.4 PASSED: Correctly rejected invalid date range';
END CATCH
PRINT '';

-- ========================================
-- TEST PROCEDURE 2: RenewContract
-- ========================================
PRINT '========================================';
PRINT 'TEST 2: RenewContract';
PRINT '========================================';

-- Test 2.1: Successful Contract Renewal
PRINT 'Test 2.1: Renew contract with new end date';
BEGIN TRY
    DECLARE @ContractID INT;
    SELECT @ContractID = contract_id FROM Employee WHERE EmployeeID = 1001;
    EXEC RenewContract @ContractID = @ContractID, @EndDate = '2026-12-31';
    PRINT '? Test 2.1 PASSED: Contract renewed successfully';
END TRY
BEGIN CATCH
    PRINT '? Test 2.1 FAILED: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 2.2: Renew Another Contract
PRINT 'Test 2.2: Renew another contract';
BEGIN TRY
    DECLARE @ContractID2 INT;
    SELECT @ContractID2 = contract_id FROM Employee WHERE EmployeeID = 1002;
    EXEC RenewContract @ContractID = @ContractID2, @EndDate = '2025-12-31';
    PRINT '? Test 2.2 PASSED: Contract renewed successfully';
END TRY
BEGIN CATCH
    PRINT '? Test 2.2 FAILED: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 2.3: Corner Case - Non-existent Contract
PRINT 'Test 2.3: Attempt to renew non-existent contract';
BEGIN TRY
    EXEC RenewContract @ContractID = 99999, @EndDate = '2025-12-31';
    -- Check if any rows were affected
    IF @@ROWCOUNT = 0
        PRINT '? Test 2.3 PASSED: No contract was updated (non-existent ID)';
    ELSE
        PRINT '? Test 2.3 FAILED: Should not update non-existent contract';
END TRY
BEGIN CATCH
    PRINT '? Test 2.3 PASSED: Correctly handled non-existent contract';
END CATCH
PRINT '';

-- ========================================
-- TEST PROCEDURE 3: ApproveLeaveRequest
-- ========================================
PRINT '========================================';
PRINT 'TEST 3: ApproveLeaveRequest';
PRINT '========================================';

-- Create test leave request
IF NOT EXISTS (SELECT 1 FROM LeaveRequest WHERE RequestID = 1)
    INSERT INTO LeaveRequest (RequestID, employee_id, leave_id, justification, duration, approval_timing, status)
    VALUES (1, 1002, 1, 'Summer vacation', 5, GETDATE(), 'PENDING');

-- Test 3.1: Successful Approval
PRINT 'Test 3.1: Approve leave request';
BEGIN TRY
    EXEC ApproveLeaveRequest @LeaveRequestID = 1, @ApproverID = 1001, @Status = 'APPROVED';
    PRINT '? Test 3.1 PASSED: Leave request approved successfully';
END TRY
BEGIN CATCH
    PRINT '? Test 3.1 FAILED: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Create another test leave request
IF NOT EXISTS (SELECT 1 FROM LeaveRequest WHERE RequestID = 2)
    INSERT INTO LeaveRequest (RequestID, employee_id, leave_id, justification, duration, approval_timing, status)
    VALUES (2, 1003, 2, 'Medical leave', 3, GETDATE(), 'PENDING');

-- Test 3.2: Successful Rejection
PRINT 'Test 3.2: Reject leave request';
BEGIN TRY
    EXEC ApproveLeaveRequest @LeaveRequestID = 2, @ApproverID = 1001, @Status = 'REJECTED';
    PRINT '? Test 3.2 PASSED: Leave request rejected successfully';
END TRY
BEGIN CATCH
    PRINT '? Test 3.2 FAILED: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 3.3: Corner Case - Non-existent Request
PRINT 'Test 3.3: Attempt to approve non-existent leave request';
BEGIN TRY
    EXEC ApproveLeaveRequest @LeaveRequestID = 99999, @ApproverID = 1001, @Status = 'APPROVED';
    IF @@ROWCOUNT = 0
        PRINT '? Test 3.3 PASSED: No request was updated (non-existent ID)';
    ELSE
        PRINT '? Test 3.3 FAILED: Should not update non-existent request';
END TRY
BEGIN CATCH
    PRINT '? Test 3.3 PASSED: Correctly handled non-existent request';
END CATCH
PRINT '';

-- ========================================
-- TEST PROCEDURE 4: AssignMission
-- ========================================
PRINT '========================================';
PRINT 'TEST 4: AssignMission';
PRINT '========================================';

-- Test 4.1: Successful Mission Assignment
PRINT 'Test 4.1: Assign mission to employee';
BEGIN TRY
    EXEC AssignMission @EmployeeID = 1002, @ManagerID = 1001, @Destination = 'New York', @StartDate = '2024-06-01', @EndDate = '2024-06-05';
    PRINT '? Test 4.1 PASSED: Mission assigned successfully';
END TRY
BEGIN CATCH
    PRINT '? Test 4.1 FAILED: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 4.2: Assign Another Mission
PRINT 'Test 4.2: Assign another mission';
BEGIN TRY
    EXEC AssignMission @EmployeeID = 1003, @ManagerID = 1001, @Destination = 'London', @StartDate = '2024-07-01', @EndDate = '2024-07-10';
    PRINT '? Test 4.2 PASSED: Mission assigned successfully';
END TRY
BEGIN CATCH
    PRINT '? Test 4.2 FAILED: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 4.3: Assign Mission with Short Duration
PRINT 'Test 4.3: Assign mission with short duration';
BEGIN TRY
    EXEC AssignMission @EmployeeID = 1002, @ManagerID = 1001, @Destination = 'Boston', @StartDate = '2024-08-01', @EndDate = '2024-08-01';
    PRINT '? Test 4.3 PASSED: Short duration mission assigned successfully';
END TRY
BEGIN CATCH
    PRINT '? Test 4.3 FAILED: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- ========================================
-- TEST PROCEDURE 5: ReviewReimbursement
-- ========================================
PRINT '========================================';
PRINT 'TEST 5: ReviewReimbursement';
PRINT '========================================';

-- Create test reimbursement claim
IF NOT EXISTS (SELECT 1 FROM Reimbursement WHERE ReimbursementID = 1)
    INSERT INTO Reimbursement (ReimbursementID, type, claim_type, approval_date, current_status, employee_id)
    VALUES (1, 'Travel', 'Expense', NULL, 'Pending', 1002);

-- Test 5.1: Successful Approval
PRINT 'Test 5.1: Approve reimbursement claim';
BEGIN TRY
    EXEC ReviewReimbursement @ClaimID = 1, @ApproverID = 1001, @Decision = 'Approved';
    PRINT '? Test 5.1 PASSED: Reimbursement approved successfully';
END TRY
BEGIN CATCH
    PRINT '? Test 5.1 FAILED: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Create another test reimbursement
IF NOT EXISTS (SELECT 1 FROM Reimbursement WHERE ReimbursementID = 2)
    INSERT INTO Reimbursement (ReimbursementID, type, claim_type, approval_date, current_status, employee_id)
    VALUES (2, 'Medical', 'Healthcare', NULL, 'Pending', 1003);

-- Test 5.2: Successful Rejection
PRINT 'Test 5.2: Reject reimbursement claim';
BEGIN TRY
    EXEC ReviewReimbursement @ClaimID = 2, @ApproverID = 1001, @Decision = 'Rejected';
    PRINT '? Test 5.2 PASSED: Reimbursement rejected successfully';
END TRY
BEGIN CATCH
    PRINT '? Test 5.2 FAILED: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 5.3: Corner Case - Invalid Decision
PRINT 'Test 5.3: Attempt to review with invalid decision';
IF NOT EXISTS (SELECT 1 FROM Reimbursement WHERE ReimbursementID = 3)
    INSERT INTO Reimbursement (ReimbursementID, type, claim_type, approval_date, current_status, employee_id)
    VALUES (3, 'Equipment', 'Purchase', NULL, 'Pending', 1002);
BEGIN TRY
    EXEC ReviewReimbursement @ClaimID = 3, @ApproverID = 1001, @Decision = 'Maybe';
    PRINT '? Test 5.3 FAILED: Should have rejected invalid decision';
END TRY
BEGIN CATCH
    PRINT '? Test 5.3 PASSED: Correctly rejected invalid decision - ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 5.4: Corner Case - Non-pending Claim
PRINT 'Test 5.4: Attempt to review already processed claim';
BEGIN TRY
    EXEC ReviewReimbursement @ClaimID = 1, @ApproverID = 1001, @Decision = 'Approved';
    PRINT '? Test 5.4 FAILED: Should not allow review of non-pending claim';
END TRY
BEGIN CATCH
    PRINT '? Test 5.4 PASSED: Correctly rejected non-pending claim - ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- ========================================
-- TEST PROCEDURE 6: GetActiveContracts
-- ========================================
PRINT '========================================';
PRINT 'TEST 6: GetActiveContracts';
PRINT '========================================';

-- Test 6.1: Retrieve Active Contracts
PRINT 'Test 6.1: Retrieve all active contracts';
BEGIN TRY
    DECLARE @ActiveContractCount INT;
    EXEC GetActiveContracts;
    SELECT @ActiveContractCount = COUNT(*) FROM Contract WHERE current_state = 'ACTIVE' OR end_date > GETDATE();
    PRINT '? Test 6.1 PASSED: Retrieved ' + CAST(@ActiveContractCount AS VARCHAR(10)) + ' active contracts';
END TRY
BEGIN CATCH
    PRINT '? Test 6.1 FAILED: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- ========================================
-- TEST PROCEDURE 7: GetTeamByManager
-- ========================================
PRINT '========================================';
PRINT 'TEST 7: GetTeamByManager';
PRINT '========================================';

-- Test 7.1: Successful Team Retrieval
PRINT 'Test 7.1: Get team members under manager 1001';
BEGIN TRY
    EXEC GetTeamByManager @ManagerID = 1001;
    PRINT '? Test 7.1 PASSED: Team members retrieved successfully';
END TRY
BEGIN CATCH
    PRINT '? Test 7.1 FAILED: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 7.2: Corner Case - Non-existent Manager
PRINT 'Test 7.2: Attempt to get team for non-existent manager';
BEGIN TRY
    EXEC GetTeamByManager @ManagerID = 99999;
    PRINT '? Test 7.2 FAILED: Should have rejected non-existent manager';
END TRY
BEGIN CATCH
    PRINT '? Test 7.2 PASSED: Correctly rejected non-existent manager';
END CATCH
PRINT '';

-- Test 7.3: Manager with No Team Members
PRINT 'Test 7.3: Get team for manager with no direct reports';
BEGIN TRY
    EXEC GetTeamByManager @ManagerID = 1002;
    PRINT '? Test 7.3 PASSED: Handled manager with no team members';
END TRY
BEGIN CATCH
    PRINT '? Test 7.3 FAILED: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- ========================================
-- TEST PROCEDURE 8: UpdateLeavePolicy
-- ========================================
PRINT '========================================';
PRINT 'TEST 8: UpdateLeavePolicy';
PRINT '========================================';

-- Create test leave policy
IF NOT EXISTS (SELECT 1 FROM LeavePolicy WHERE PolicyID = 1)
    INSERT INTO LeavePolicy (PolicyID, name, purpose, eligibility_rules, notice_period)
    VALUES (1, 'Standard Leave Policy', 'Default policy', 'All employees eligible', 7);

-- Test 8.1: Successful Policy Update
PRINT 'Test 8.1: Update leave policy with new rules';
BEGIN TRY
    EXEC UpdateLeavePolicy @PolicyID = 1, @EligibilityRules = 'Employees with 6+ months tenure', @NoticePeriod = 14;
    PRINT '? Test 8.1 PASSED: Leave policy updated successfully';
END TRY
BEGIN CATCH
    PRINT '? Test 8.1 FAILED: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 8.2: Update with Different Values
PRINT 'Test 8.2: Update leave policy with different notice period';
BEGIN TRY
    EXEC UpdateLeavePolicy @PolicyID = 1, @EligibilityRules = 'Full-time employees only', @NoticePeriod = 30;
    PRINT '? Test 8.2 PASSED: Leave policy updated successfully';
END TRY
BEGIN CATCH
    PRINT '? Test 8.2 FAILED: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 8.3: Corner Case - Non-existent Policy
PRINT 'Test 8.3: Attempt to update non-existent policy';
BEGIN TRY
    EXEC UpdateLeavePolicy @PolicyID = 99999, @EligibilityRules = 'Test rules', @NoticePeriod = 7;
    PRINT '? Test 8.3 FAILED: Should have rejected non-existent policy';
END TRY
BEGIN CATCH
    PRINT '? Test 8.3 PASSED: Correctly rejected non-existent policy';
END CATCH
PRINT '';

-- Test 8.4: Corner Case - Negative Notice Period
PRINT 'Test 8.4: Attempt to set negative notice period';
BEGIN TRY
    EXEC UpdateLeavePolicy @PolicyID = 1, @EligibilityRules = 'Test rules', @NoticePeriod = -5;
    PRINT '? Test 8.4 FAILED: Should have rejected negative notice period';
END TRY
BEGIN CATCH
    PRINT '? Test 8.4 PASSED: Correctly rejected negative notice period';
END CATCH
PRINT '';

-- ========================================
-- TEST PROCEDURE 9: GetExpiringContracts
-- ========================================
PRINT '========================================';
PRINT 'TEST 9: GetExpiringContracts';
PRINT '========================================';

-- Test 9.1: Get Contracts Expiring in 30 Days
PRINT 'Test 9.1: Get contracts expiring within 30 days';
BEGIN TRY
    EXEC GetExpiringContracts @DaysBefore = 30;
    PRINT '? Test 9.1 PASSED: Retrieved expiring contracts';
END TRY
BEGIN CATCH
    PRINT '? Test 9.1 FAILED: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 9.2: Get Contracts Expiring in 90 Days
PRINT 'Test 9.2: Get contracts expiring within 90 days';
BEGIN TRY
    EXEC GetExpiringContracts @DaysBefore = 90;
    PRINT '? Test 9.2 PASSED: Retrieved expiring contracts';
END TRY
BEGIN CATCH
    PRINT '? Test 9.2 FAILED: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 9.3: Corner Case - Zero Days
PRINT 'Test 9.3: Attempt to get contracts with zero days';
BEGIN TRY
    EXEC GetExpiringContracts @DaysBefore = 0;
    PRINT '? Test 9.3 FAILED: Should have rejected zero days';
END TRY
BEGIN CATCH
    PRINT '? Test 9.3 PASSED: Correctly rejected zero days';
END CATCH
PRINT '';

-- Test 9.4: Corner Case - Negative Days
PRINT 'Test 9.4: Attempt to get contracts with negative days';
BEGIN TRY
    EXEC GetExpiringContracts @DaysBefore = -10;
    PRINT '? Test 9.4 FAILED: Should have rejected negative days';
END TRY
BEGIN CATCH
    PRINT '? Test 9.4 PASSED: Correctly rejected negative days';
END CATCH
PRINT '';

-- ========================================
-- TEST PROCEDURE 10: AssignDepartmentHead
-- ========================================
PRINT '========================================';
PRINT 'TEST 10: AssignDepartmentHead';
PRINT '========================================';

-- Test 10.1: Successful Department Head Assignment
PRINT 'Test 10.1: Assign department head to IT department';
BEGIN TRY
    EXEC AssignDepartmentHead @DepartmentID = 1, @ManagerID = 1001;
    PRINT '? Test 10.1 PASSED: Department head assigned successfully';
END TRY
BEGIN CATCH
    PRINT '? Test 10.1 FAILED: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 10.2: Reassign Department Head
PRINT 'Test 10.2: Reassign department head to HR department';
BEGIN TRY
    EXEC AssignDepartmentHead @DepartmentID = 2, @ManagerID = 1001;
    PRINT '? Test 10.2 PASSED: Department head reassigned successfully';
END TRY
BEGIN CATCH
    PRINT '? Test 10.2 FAILED: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 10.3: Corner Case - Non-existent Department
PRINT 'Test 10.3: Attempt to assign head to non-existent department';
BEGIN TRY
    EXEC AssignDepartmentHead @DepartmentID = 99999, @ManagerID = 1001;
    PRINT '? Test 10.3 FAILED: Should have rejected non-existent department';
END TRY
BEGIN CATCH
    PRINT '? Test 10.3 PASSED: Correctly rejected non-existent department';
END CATCH
PRINT '';

-- Test 10.4: Corner Case - Non-Line Manager Employee
PRINT 'Test 10.4: Attempt to assign non-line manager as department head';
BEGIN TRY
    EXEC AssignDepartmentHead @DepartmentID = 1, @ManagerID = 1002;
    PRINT '? Test 10.4 FAILED: Should have rejected non-line manager';
END TRY
BEGIN CATCH
    PRINT '? Test 10.4 PASSED: Correctly rejected non-line manager';
END CATCH
PRINT '';

-- ========================================
-- TEST PROCEDURE 11: CreateEmployeeProfile
-- ========================================
PRINT '========================================';
PRINT 'TEST 11: CreateEmployeeProfile';
PRINT '========================================';

-- Test 11.1: Successful Employee Profile Creation
PRINT 'Test 11.1: Create new employee profile';
BEGIN TRY
    EXEC CreateEmployeeProfile 
        @FirstName = 'Alice', 
        @LastName = 'Williams', 
        @DepartmentID = 1, 
        @RoleID = 1, 
        @HireDate = '2024-01-15', 
        @Email = 'alice.williams@test.com', 
        @Phone = '5559876543', 
        @NationalID = 'N1004', 
        @DateOfBirth = '1995-03-10', 
        @CountryOfBirth = 'Canada';
    PRINT '? Test 11.1 PASSED: Employee profile created successfully';
END TRY
BEGIN CATCH
    PRINT '? Test 11.1 FAILED: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 11.2: Create Another Employee
PRINT 'Test 11.2: Create another employee profile';
BEGIN TRY
    EXEC CreateEmployeeProfile 
        @FirstName = 'Charlie', 
        @LastName = 'Brown', 
        @DepartmentID = 2, 
        @RoleID = 2, 
        @HireDate = '2024-02-01', 
        @Email = 'charlie.brown@test.com', 
        @Phone = '5551112222', 
        @NationalID = 'N1005', 
        @DateOfBirth = '1991-07-25', 
        @CountryOfBirth = 'UK';
    PRINT '? Test 11.2 PASSED: Employee profile created successfully';
END TRY
BEGIN CATCH
    PRINT '? Test 11.2 FAILED: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 11.3: Corner Case - Duplicate Email
PRINT 'Test 11.3: Attempt to create employee with duplicate email';
BEGIN TRY
    EXEC CreateEmployeeProfile 
        @FirstName = 'Test', 
        @LastName = 'User', 
        @DepartmentID = 1, 
        @RoleID = 1, 
        @HireDate = '2024-03-01', 
        @Email = 'alice.williams@test.com', 
        @Phone = '5553334444', 
        @NationalID = 'N1006', 
        @DateOfBirth = '1993-09-15', 
        @CountryOfBirth = 'USA';
    PRINT '? Test 11.3 FAILED: Should have rejected duplicate email';
END TRY
BEGIN CATCH
    PRINT '? Test 11.3 PASSED: Correctly rejected duplicate email';
END CATCH
PRINT '';

-- Test 11.4: Corner Case - Non-existent Department
PRINT 'Test 11.4: Attempt to create employee with non-existent department';
BEGIN TRY
    EXEC CreateEmployeeProfile 
        @FirstName = 'Test', 
        @LastName = 'User2', 
        @DepartmentID = 99999, 
        @RoleID = 1, 
        @HireDate = '2024-03-01', 
        @Email = 'test.user2@test.com', 
        @Phone = '5553334444', 
        @NationalID = 'N1007', 
        @DateOfBirth = '1993-09-15', 
        @CountryOfBirth = 'USA';
    PRINT '? Test 11.4 FAILED: Should have rejected non-existent department';
END TRY
BEGIN CATCH
    PRINT '? Test 11.4 PASSED: Correctly rejected non-existent department';
END CATCH
PRINT '';

-- ========================================
-- TEST PROCEDURE 12: UpdateEmployeeProfile
-- ========================================
PRINT '========================================';
PRINT 'TEST 12: UpdateEmployeeProfile';
PRINT '========================================';

-- Test 12.1: Successful Phone Update
PRINT 'Test 12.1: Update employee phone number';
BEGIN TRY
    EXEC UpdateEmployeeProfile @EmployeeID = 1002, @FieldName = 'phone', @NewValue = '5557778888';
    PRINT '? Test 12.1 PASSED: Phone number updated successfully';
END TRY
BEGIN CATCH
    PRINT '? Test 12.1 FAILED: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 12.2: Successful Address Update
PRINT 'Test 12.2: Update employee address';
BEGIN TRY
    EXEC UpdateEmployeeProfile @EmployeeID = 1002, @FieldName = 'address', @NewValue = '123 Main Street, City, State';
    PRINT '? Test 12.2 PASSED: Address updated successfully';
END TRY
BEGIN CATCH
    PRINT '? Test 12.2 FAILED: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 12.3: Corner Case - Invalid Field Name
PRINT 'Test 12.3: Attempt to update with invalid field name';
BEGIN TRY
    EXEC UpdateEmployeeProfile @EmployeeID = 1002, @FieldName = 'invalid_field', @NewValue = 'test';
    PRINT '? Test 12.3 FAILED: Should have rejected invalid field name';
END TRY
BEGIN CATCH
    PRINT '? Test 12.3 PASSED: Correctly rejected invalid field name';
END CATCH
PRINT '';

-- Test 12.4: Corner Case - Non-existent Employee
PRINT 'Test 12.4: Attempt to update non-existent employee';
BEGIN TRY
    EXEC UpdateEmployeeProfile @EmployeeID = 99999, @FieldName = 'phone', @NewValue = '5559998888';
    PRINT '? Test 12.4 FAILED: Should have rejected non-existent employee';
END TRY
BEGIN CATCH
    PRINT '? Test 12.4 PASSED: Correctly rejected non-existent employee';
END CATCH
PRINT '';

-- ========================================
-- TEST PROCEDURE 13: SetProfileCompleteness
-- ========================================
PRINT '========================================';
PRINT 'TEST 13: SetProfileCompleteness';
PRINT '========================================';

-- Test 13.1: Set Completeness to 50%
PRINT 'Test 13.1: Set profile completeness to 50%';
BEGIN TRY
    EXEC SetProfileCompleteness @EmployeeID = 1002, @CompletenessPercentage = 50;
    PRINT '? Test 13.1 PASSED: Profile completeness set to 50%';
END TRY
BEGIN CATCH
    PRINT '? Test 13.1 FAILED: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 13.2: Set Completeness to 100%
PRINT 'Test 13.2: Set profile completeness to 100%';
BEGIN TRY
    EXEC SetProfileCompleteness @EmployeeID = 1002, @CompletenessPercentage = 100;
    PRINT '? Test 13.2 PASSED: Profile completeness set to 100%';
END TRY
BEGIN CATCH
    PRINT '? Test 13.2 FAILED: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 13.3: Corner Case - Percentage > 100
PRINT 'Test 13.3: Attempt to set completeness > 100%';
BEGIN TRY
    EXEC SetProfileCompleteness @EmployeeID = 1002, @CompletenessPercentage = 150;
    PRINT '? Test 13.3 FAILED: Should have rejected percentage > 100';
END TRY
BEGIN CATCH
    PRINT '? Test 13.3 PASSED: Correctly rejected percentage > 100';
END CATCH
PRINT '';

-- Test 13.4: Corner Case - Negative Percentage
PRINT 'Test 13.4: Attempt to set negative completeness';
BEGIN TRY
    EXEC SetProfileCompleteness @EmployeeID = 1002, @CompletenessPercentage = -10;
    PRINT '? Test 13.4 FAILED: Should have rejected negative percentage';
END TRY
BEGIN CATCH
    PRINT '? Test 13.4 PASSED: Correctly rejected negative percentage';
END CATCH
PRINT '';

-- ========================================
-- TEST PROCEDURE 14: GenerateProfileReport
-- ========================================
PRINT '========================================';
PRINT 'TEST 14: GenerateProfileReport';
PRINT '========================================';

-- Test 14.1: Filter by Department
PRINT 'Test 14.1: Generate report filtered by department';
BEGIN TRY
    EXEC GenerateProfileReport @FilterField = 'department', @FilterValue = '1';
    PRINT '? Test 14.1 PASSED: Report generated by department';
END TRY
BEGIN CATCH
    PRINT '? Test 14.1 FAILED: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 14.2: Filter by Employment Status
PRINT 'Test 14.2: Generate report filtered by employment status';
BEGIN TRY
    EXEC GenerateProfileReport @FilterField = 'employment_status', @FilterValue = 'Active';
    PRINT '? Test 14.2 PASSED: Report generated by employment status';
END TRY
BEGIN CATCH
    PRINT '? Test 14.2 FAILED: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 14.3: Corner Case - Invalid Filter Field
PRINT 'Test 14.3: Attempt to generate report with invalid filter field';
BEGIN TRY
    EXEC GenerateProfileReport @FilterField = 'invalid_field', @FilterValue = 'test';
    PRINT '? Test 14.3 FAILED: Should have rejected invalid filter field';
END TRY
BEGIN CATCH
    PRINT '? Test 14.3 PASSED: Correctly rejected invalid filter field';
END CATCH
PRINT '';

-- ========================================
-- TEST PROCEDURE 15: CreateShiftType
-- ========================================
PRINT '========================================';
PRINT 'TEST 15: CreateShiftType';
PRINT '========================================';

-- Create Shift table if not exists (simplified)
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Shift')
BEGIN
    CREATE TABLE Shift (
        ShiftID INT PRIMARY KEY,
        shift_name VARCHAR(100),
        shift_type VARCHAR(50),
        start_time TIME,
        end_time TIME,
        break_duration INT,
        shift_date DATE,
        status VARCHAR(50)
    );
END

-- Test 15.1: Create Normal Shift
PRINT 'Test 15.1: Create Normal shift type';
BEGIN TRY
    EXEC CreateShiftType 
        @ShiftID = 1, 
        @Name = 'Morning Shift', 
        @Type = 'Normal', 
        @Start_Time = '08:00:00', 
        @End_Time = '16:00:00', 
        @Break_Duration = 60, 
        @Shift_Date = '2024-01-01', 
        @Status = 'Active';
    PRINT '? Test 15.1 PASSED: Normal shift created successfully';
END TRY
BEGIN CATCH
    PRINT '? Test 15.1 FAILED: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 15.2: Create Overnight Shift
PRINT 'Test 15.2: Create Overnight shift type';
BEGIN TRY
    EXEC CreateShiftType 
        @ShiftID = 2, 
        @Name = 'Night Shift', 
        @Type = 'Overnight', 
        @Start_Time = '22:00:00', 
        @End_Time = '06:00:00', 
        @Break_Duration = 30, 
        @Shift_Date = '2024-01-01', 
        @Status = 'Active';
    PRINT '? Test 15.2 PASSED: Overnight shift created successfully';
END TRY
BEGIN CATCH
    PRINT '? Test 15.2 FAILED: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 15.3: Corner Case - Invalid Shift Type
PRINT 'Test 15.3: Attempt to create shift with invalid type';
BEGIN TRY
    EXEC CreateShiftType 
        @ShiftID = 3, 
        @Name = 'Invalid Shift', 
        @Type = 'InvalidType', 
        @Start_Time = '09:00:00', 
        @End_Time = '17:00:00', 
        @Break_Duration = 60, 
        @Shift_Date = '2024-01-01', 
        @Status = 'Active';
    PRINT '? Test 15.3 FAILED: Should have rejected invalid shift type';
END TRY
BEGIN CATCH
    PRINT '? Test 15.3 PASSED: Correctly rejected invalid shift type';
END CATCH
PRINT '';

-- Test 15.4: Corner Case - Duplicate Shift ID
PRINT 'Test 15.4: Attempt to create shift with duplicate ID';
BEGIN TRY
    EXEC CreateShiftType 
        @ShiftID = 1, 
        @Name = 'Duplicate Shift', 
        @Type = 'Normal', 
        @Start_Time = '09:00:00', 
        @End_Time = '17:00:00', 
        @Break_Duration = 60, 
        @Shift_Date = '2024-01-01', 
        @Status = 'Active';
    PRINT '? Test 15.4 FAILED: Should have rejected duplicate shift ID';
END TRY
BEGIN CATCH
    PRINT '? Test 15.4 PASSED: Correctly rejected duplicate shift ID';
END CATCH
PRINT '';

-- ========================================
-- TEST PROCEDURE 16: AssignRotationalShift
-- ========================================
PRINT '========================================';
PRINT 'TEST 16: AssignRotationalShift';
PRINT '========================================';

-- Create ShiftAssignment table if not exists
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'ShiftAssignment')
BEGIN
    CREATE TABLE ShiftAssignment (
        AssignmentID INT PRIMARY KEY,
        employee_id INT,
        shift_cycle_days INT,
        start_date DATE,
        end_date DATE,
        status VARCHAR(50)
    );
END

-- Test 16.1: Assign Rotational Shift
PRINT 'Test 16.1: Assign rotational shift to employee';
BEGIN TRY
    EXEC AssignRotationalShift 
        @EmployeeID = 1002, 
        @ShiftCycle = 7, 
        @StartDate = '2024-06-01', 
        @EndDate = '2024-12-31', 
        @Status = 'Active';
    PRINT '? Test 16.1 PASSED: Rotational shift assigned successfully';
END TRY
BEGIN CATCH
    PRINT '? Test 16.1 FAILED: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 16.2: Assign Different Shift Cycle
PRINT 'Test 16.2: Assign shift with different cycle to another employee';
BEGIN TRY
    EXEC AssignRotationalShift 
        @EmployeeID = 1003, 
        @ShiftCycle = 14, 
        @StartDate = '2024-07-01', 
        @EndDate = '2024-12-31', 
        @Status = 'Active';
    PRINT '? Test 16.2 PASSED: Rotational shift assigned successfully';
END TRY
BEGIN CATCH
    PRINT '? Test 16.2 FAILED: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 16.3: Corner Case - Invalid Date Range
PRINT 'Test 16.3: Attempt to assign shift with start date after end date';
BEGIN TRY
    EXEC AssignRotationalShift 
        @EmployeeID = 1002, 
        @ShiftCycle = 7, 
        @StartDate = '2024-12-31', 
        @EndDate = '2024-06-01', 
        @Status = 'Active';
    PRINT '? Test 16.3 FAILED: Should have rejected invalid date range';
END TRY
BEGIN CATCH
    PRINT '? Test 16.3 PASSED: Correctly rejected invalid date range';
END CATCH
PRINT '';

-- Test 16.4: Corner Case - Non-positive Shift Cycle
PRINT 'Test 16.4: Attempt to assign shift with zero cycle days';
BEGIN TRY
    EXEC AssignRotationalShift 
        @EmployeeID = 1002, 
        @ShiftCycle = 0, 
        @StartDate = '2024-06-01', 
        @EndDate = '2024-12-31', 
        @Status = 'Active';
    PRINT '? Test 16.4 FAILED: Should have rejected zero shift cycle';
END TRY
BEGIN CATCH
    PRINT '? Test 16.4 PASSED: Correctly rejected zero shift cycle';
END CATCH
PRINT '';

-- ========================================
-- TEST PROCEDURE 18: NotifyShiftExpiry
-- ========================================
PRINT '========================================';
PRINT 'TEST 18: NotifyShiftExpiry';
PRINT '========================================';

-- Test 18.1: Notify Shift Expiry (7 days)
PRINT 'Test 18.1: Send notification for shift expiring in 7 days';
BEGIN TRY
    DECLARE @ExpiryDate1 DATE = DATEADD(DAY, 7, GETDATE());
    EXEC NotifyShiftExpiry @EmployeeID = 1002, @ShiftAssignmentID = 1, @ExpiryDate = @ExpiryDate1;
    PRINT '? Test 18.1 PASSED: Notification sent successfully';
END TRY
BEGIN CATCH
    PRINT '? Test 18.1 FAILED: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 18.2: Notify Critical Expiry (2 days)
PRINT 'Test 18.2: Send critical notification for shift expiring in 2 days';
BEGIN TRY
    DECLARE @ExpiryDate2 DATE = DATEADD(DAY, 2, GETDATE());
    EXEC NotifyShiftExpiry @EmployeeID = 1003, @ShiftAssignmentID = 2, @ExpiryDate = @ExpiryDate2;
    PRINT '? Test 18.2 PASSED: Critical notification sent successfully';
END TRY
BEGIN CATCH
    PRINT '? Test 18.2 FAILED: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 18.3: Corner Case - Non-existent Employee
PRINT 'Test 18.3: Attempt to notify non-existent employee';
BEGIN TRY
    DECLARE @ExpiryDate3 DATE = DATEADD(DAY, 7, GETDATE());
    EXEC NotifyShiftExpiry @EmployeeID = 99999, @ShiftAssignmentID = 1, @ExpiryDate = @ExpiryDate3;
    PRINT '? Test 18.3 FAILED: Should have rejected non-existent employee';
END TRY
BEGIN CATCH
    PRINT '? Test 18.3 PASSED: Correctly rejected non-existent employee';
END CATCH
PRINT '';

-- ========================================
-- TEST PROCEDURE 19: DefineShortTimeRules
-- ========================================
PRINT '========================================';
PRINT 'TEST 19: DefineShortTimeRules';
PRINT '========================================';

-- Create AttendancePolicy table if not exists
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'AttendancePolicy')
BEGIN
    CREATE TABLE AttendancePolicy (
        PolicyID INT PRIMARY KEY,
        policy_name VARCHAR(100),
        policy_type VARCHAR(50),
        description VARCHAR(500),
        parameters VARCHAR(500),
        effective_date DATETIME,
        status VARCHAR(50)
    );
END

-- Test 19.1: Define Short Time Rule
PRINT 'Test 19.1: Define short time rule with deduction penalty';
BEGIN TRY
    EXEC DefineShortTimeRules 
        @RuleName = 'Standard Lateness Rule', 
        @LateMinutes = 15, 
        @EarlyLeaveMinutes = 15, 
        @PenaltyType = 'Deduction';
    PRINT '? Test 19.1 PASSED: Short time rule defined successfully';
END TRY
BEGIN CATCH
    PRINT '? Test 19.1 FAILED: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 19.2: Define Another Rule
PRINT 'Test 19.2: Define short time rule with warning penalty';
BEGIN TRY
    EXEC DefineShortTimeRules 
        @RuleName = 'Lenient Lateness Rule', 
        @LateMinutes = 30, 
        @EarlyLeaveMinutes = 30, 
        @PenaltyType = 'Warning';
    PRINT '? Test 19.2 PASSED: Short time rule defined successfully';
END TRY
BEGIN CATCH
    PRINT '? Test 19.2 FAILED: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 19.3: Corner Case - Invalid Penalty Type
PRINT 'Test 19.3: Attempt to define rule with invalid penalty type';
BEGIN TRY
    EXEC DefineShortTimeRules 
        @RuleName = 'Invalid Rule', 
        @LateMinutes = 15, 
        @EarlyLeaveMinutes = 15, 
        @PenaltyType = 'InvalidPenalty';
    PRINT '? Test 19.3 FAILED: Should have rejected invalid penalty type';
END TRY
BEGIN CATCH
    PRINT '? Test 19.3 PASSED: Correctly rejected invalid penalty type';
END CATCH
PRINT '';

-- Test 19.4: Corner Case - Negative Minutes
PRINT 'Test 19.4: Attempt to define rule with negative minutes';
BEGIN TRY
    EXEC DefineShortTimeRules 
        @RuleName = 'Negative Minutes Rule', 
        @LateMinutes = -10, 
        @EarlyLeaveMinutes = 15, 
        @PenaltyType = 'Warning';
    PRINT '? Test 19.4 FAILED: Should have rejected negative minutes';
END TRY
BEGIN CATCH
    PRINT '? Test 19.4 PASSED: Correctly rejected negative minutes';
END CATCH
PRINT '';

-- ========================================
-- TEST PROCEDURE 20: SetGracePeriod
-- ========================================
PRINT '========================================';
PRINT 'TEST 20: SetGracePeriod';
PRINT '========================================';

-- Test 20.1: Set Grace Period to 10 Minutes
PRINT 'Test 20.1: Set grace period to 10 minutes';
BEGIN TRY
    EXEC SetGracePeriod @Minutes = 10;
    PRINT '? Test 20.1 PASSED: Grace period set successfully';
END TRY
BEGIN CATCH
    PRINT '? Test 20.1 FAILED: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 20.2: Update Grace Period to 15 Minutes
PRINT 'Test 20.2: Update grace period to 15 minutes';
BEGIN TRY
    EXEC SetGracePeriod @Minutes = 15;
    PRINT '? Test 20.2 PASSED: Grace period updated successfully';
END TRY
BEGIN CATCH
    PRINT '? Test 20.2 FAILED: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 20.3: Corner Case - Exceeds Maximum
PRINT 'Test 20.3: Attempt to set grace period > 60 minutes';
BEGIN TRY
    EXEC SetGracePeriod @Minutes = 75;
    PRINT '? Test 20.3 FAILED: Should have rejected grace period > 60 minutes';
END TRY
BEGIN CATCH
    PRINT '? Test 20.3 PASSED: Correctly rejected grace period > 60 minutes';
END CATCH
PRINT '';

-- Test 20.4: Corner Case - Negative Minutes
PRINT 'Test 20.4: Attempt to set negative grace period';
BEGIN TRY
    EXEC SetGracePeriod @Minutes = -5;
    PRINT '? Test 20.4 FAILED: Should have rejected negative grace period';
END TRY
BEGIN CATCH
    PRINT '? Test 20.4 PASSED: Correctly rejected negative grace period';
END CATCH
PRINT '';

-- ========================================
-- TEST PROCEDURE 21: DefinePenaltyThreshold
-- ========================================
PRINT '========================================';
PRINT 'TEST 21: DefinePenaltyThreshold';
PRINT '========================================';

-- Test 21.1: Define Penalty Threshold
PRINT 'Test 21.1: Define penalty threshold for 30 minutes late';
BEGIN TRY
    EXEC DefinePenaltyThreshold @LateMinutes = 30, @DeductionType = 'Half-Day';
    PRINT '? Test 21.1 PASSED: Penalty threshold defined successfully';
END TRY
BEGIN CATCH
    PRINT '? Test 21.1 FAILED: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 21.2: Define Another Threshold
PRINT 'Test 21.2: Define penalty threshold for 60 minutes late';
BEGIN TRY
    EXEC DefinePenaltyThreshold @LateMinutes = 60, @DeductionType = 'Full-Day';
    PRINT '? Test 21.2 PASSED: Penalty threshold defined successfully';
END TRY
BEGIN CATCH
    PRINT '? Test 21.2 FAILED: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 21.3: Corner Case - Invalid Deduction Type
PRINT 'Test 21.3: Attempt to define threshold with invalid deduction type';
BEGIN TRY
    EXEC DefinePenaltyThreshold @LateMinutes = 45, @DeductionType = 'InvalidType';
    PRINT '? Test 21.3 FAILED: Should have rejected invalid deduction type';
END TRY
BEGIN CATCH
    PRINT '? Test 21.3 PASSED: Correctly rejected invalid deduction type';
END CATCH
PRINT '';

-- Test 21.4: Corner Case - Zero or Negative Minutes
PRINT 'Test 21.4: Attempt to define threshold with zero minutes';
BEGIN TRY
    EXEC DefinePenaltyThreshold @LateMinutes = 0, @DeductionType = 'Warning';
    PRINT '? Test 21.4 FAILED: Should have rejected zero minutes';
END TRY
BEGIN CATCH
    PRINT '? Test 21.4 PASSED: Correctly rejected zero minutes';
END CATCH
PRINT '';

-- ========================================
-- TEST PROCEDURE 22: DefinePermissionLimits
-- ========================================
PRINT '========================================';
PRINT 'TEST 22: DefinePermissionLimits';
PRINT '========================================';

-- Test 22.1: Define Permission Limits
PRINT 'Test 22.1: Define permission limits (1-4 hours)';
BEGIN TRY
    EXEC DefinePermissionLimits @MinHours = 1, @MaxHours = 4;
    PRINT '? Test 22.1 PASSED: Permission limits defined successfully';
END TRY
BEGIN CATCH
    PRINT '? Test 22.1 FAILED: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 22.2: Update Permission Limits
PRINT 'Test 22.2: Update permission limits (1-8 hours)';
BEGIN TRY
    EXEC DefinePermissionLimits @MinHours = 1, @MaxHours = 8;
    PRINT '? Test 22.2 PASSED: Permission limits updated successfully';
END TRY
BEGIN CATCH
    PRINT '? Test 22.2 FAILED: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 22.3: Corner Case - Min > Max
PRINT 'Test 22.3: Attempt to define limits where min > max';
BEGIN TRY
    EXEC DefinePermissionLimits @MinHours = 8, @MaxHours = 4;
    PRINT '? Test 22.3 FAILED: Should have rejected min > max';
END TRY
BEGIN CATCH
    PRINT '? Test 22.3 PASSED: Correctly rejected min > max';
END CATCH
PRINT '';

-- Test 22.4: Corner Case - Exceeds 24 Hours
PRINT 'Test 22.4: Attempt to define limits exceeding 24 hours';
BEGIN TRY
    EXEC DefinePermissionLimits @MinHours = 1, @MaxHours = 30;
    PRINT '? Test 22.4 FAILED: Should have rejected max > 24 hours';
END TRY
BEGIN CATCH
    PRINT '? Test 22.4 PASSED: Correctly rejected max > 24 hours';
END CATCH
PRINT '';

-- ========================================
-- TEST PROCEDURE 23: EscalatePendingRequests
-- ========================================
PRINT '========================================';
PRINT 'TEST 23: EscalatePendingRequests';
PRINT '========================================';

-- Create some pending leave requests for testing
IF NOT EXISTS (SELECT 1 FROM LeaveRequest WHERE RequestID = 101)
    INSERT INTO LeaveRequest (RequestID, employee_id, leave_id, justification, duration, approval_timing, status)
    VALUES (101, 1002, 1, 'Overdue request', 3, DATEADD(DAY, -10, GETDATE()), 'PENDING');

-- Test 23.1: Escalate Pending Requests
PRINT 'Test 23.1: Escalate pending requests past deadline';
BEGIN TRY
    DECLARE @PastDeadline DATETIME = DATEADD(DAY, -5, GETDATE());
    EXEC EscalatePendingRequests @Deadline = @PastDeadline;
    PRINT '? Test 23.1 PASSED: Pending requests escalated successfully';
END TRY
BEGIN CATCH
    PRINT '? Test 23.1 FAILED: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 23.2: Escalate with Earlier Deadline
PRINT 'Test 23.2: Escalate with earlier deadline';
BEGIN TRY
    DECLARE @EarlierDeadline DATETIME = DATEADD(DAY, -15, GETDATE());
    EXEC EscalatePendingRequests @Deadline = @EarlierDeadline;
    PRINT '? Test 23.2 PASSED: Requests escalated with earlier deadline';
END TRY
BEGIN CATCH
    PRINT '? Test 23.2 FAILED: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 23.3: Corner Case - Future Deadline
PRINT 'Test 23.3: Attempt to escalate with future deadline';
BEGIN TRY
    DECLARE @FutureDeadline DATETIME = DATEADD(DAY, 5, GETDATE());
    EXEC EscalatePendingRequests @Deadline = @FutureDeadline;
    PRINT '? Test 23.3 FAILED: Should have rejected future deadline';
END TRY
BEGIN CATCH
    PRINT '? Test 23.3 PASSED: Correctly rejected future deadline';
END CATCH
PRINT '';

-- ========================================
-- TEST PROCEDURE 24: LinkVacationToShift
-- ========================================
PRINT '========================================';
PRINT 'TEST 24: LinkVacationToShift';
PRINT '========================================';

-- Ensure employee has an active shift assignment
IF NOT EXISTS (SELECT 1 FROM ShiftAssignment WHERE employee_id = 1002 AND status = 'Active')
BEGIN
    INSERT INTO ShiftAssignment (AssignmentID, employee_id, shift_cycle_days, start_date, end_date, status)
    VALUES (100, 1002, 7, '2024-01-01', '2024-12-31', 'Active');
END

-- Test 24.1: Link Vacation to Shift
PRINT 'Test 24.1: Link vacation package to employee shift';
BEGIN TRY
    EXEC LinkVacationToShift @VacationPackageID = 1, @EmployeeID = 1002;
    PRINT '? Test 24.1 PASSED: Vacation linked to shift successfully';
END TRY
BEGIN CATCH
    PRINT '? Test 24.1 FAILED: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 24.2: Link Vacation to Another Employee
IF NOT EXISTS (SELECT 1 FROM ShiftAssignment WHERE employee_id = 1003 AND status = 'Active')
BEGIN
    INSERT INTO ShiftAssignment (AssignmentID, employee_id, shift_cycle_days, start_date, end_date, status)
    VALUES (101, 1003, 7, '2024-01-01', '2024-12-31', 'Active');
END
PRINT 'Test 24.2: Link vacation to another employee with active shift';
BEGIN TRY
    EXEC LinkVacationToShift @VacationPackageID = 1, @EmployeeID = 1003;
    PRINT '? Test 24.2 PASSED: Vacation linked to another employee successfully';
END TRY
BEGIN CATCH
    PRINT '? Test 24.2 FAILED: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 24.3: Corner Case - Non-existent Employee
PRINT 'Test 24.3: Attempt to link vacation for non-existent employee';
BEGIN TRY
    EXEC LinkVacationToShift @VacationPackageID = 10, @EmployeeID = 99999;
    PRINT '? Test 24.3 FAILED: Should have rejected non-existent employee';
END TRY
BEGIN CATCH
    PRINT '? Test 24.3 PASSED: Correctly rejected non-existent employee - ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 24.4: Corner Case - Employee Without Active Shift
PRINT 'Test 24.4: Attempt to link vacation for employee without active shift';
IF NOT EXISTS (SELECT 1 FROM Employee WHERE EmployeeID = 2003)
    INSERT INTO Employee (EmployeeID, first_name, last_name, national_id, date_of_birth, country_of_birth, phone, email, hire_date, is_active, employment_status, account_status)
    VALUES (2003, 'Test', 'NoShift', 'N2003', '1990-01-01', 'USA', '5553334455', 'noshift@test.com', '2024-01-01', 1, 'Active', 'Active');

BEGIN TRY
    EXEC LinkVacationToShift @VacationPackageID = 10, @EmployeeID = 2003;
    PRINT '? Test 24.4 FAILED: Should have rejected employee without active shift';
END TRY
BEGIN CATCH
    PRINT '? Test 24.4 PASSED: Correctly rejected employee without active shift - ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- ========================================
-- TEST PROCEDURE 25: ConfigureLeavePolicies
-- ========================================
PRINT '========================================';
PRINT 'TEST 25: ConfigureLeavePolicies';
PRINT '========================================';

-- Test 25.1: Initial Configuration
PRINT 'Test 25.1: Configure leave policies for the first time';
BEGIN TRY
    -- Clean up if already configured
    DELETE FROM LeavePolicy WHERE name = 'Base Leave Configuration';
    
    EXEC ConfigureLeavePolicies;
    PRINT '? Test 25.1 PASSED: Leave policies configured successfully';
END TRY
BEGIN CATCH
    PRINT '? Test 25.1 FAILED: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 25.2: Verify Configuration Created Leave Types
PRINT 'Test 25.2: Verify leave types were created';
BEGIN TRY
    DECLARE @VacationExists BIT, @SickExists BIT, @EmergencyExists BIT;
    
    SELECT @VacationExists = CASE WHEN COUNT(*) > 0 THEN 1 ELSE 0 END 
    FROM Leave WHERE leave_type = 'Vacation';
    
    SELECT @SickExists = CASE WHEN COUNT(*) > 0 THEN 1 ELSE 0 END 
    FROM Leave WHERE leave_type = 'Sick';
    
    SELECT @EmergencyExists = CASE WHEN COUNT(*) > 0 THEN 1 ELSE 0 END 
    FROM Leave WHERE leave_type = 'Emergency';
END TRY
BEGIN CATCH
    PRINT '? Test 25.2 FAILED: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 25.3: Corner Case - Duplicate Configuration
PRINT 'Test 25.3: Attempt to configure policies again (should reject)';
BEGIN TRY
    EXEC ConfigureLeavePolicies;
    PRINT '? Test 25.3 FAILED: Should have rejected duplicate configuration';
END TRY
BEGIN CATCH
    PRINT '? Test 25.3 PASSED: Correctly rejected duplicate configuration - ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- ========================================
-- TEST PROCEDURE 26: AuthenticateLeaveAdmin
-- ========================================
PRINT '========================================';
PRINT 'TEST 26: AuthenticateLeaveAdmin';
PRINT '========================================';

-- Ensure HR Administrator exists with proper privileges
IF NOT EXISTS (SELECT 1 FROM HRAdministrator WHERE employee_id = 1001)
    INSERT INTO HRAdministrator (employee_id, approval_level, record_access_scope, document_validation_rights)
    VALUES (1001, 'Senior', 'All', 1);
ELSE
    UPDATE HRAdministrator 
    SET approval_level = 'Senior', document_validation_rights = 1 
    WHERE employee_id = 1001;

-- Test 26.1: Successful Authentication
PRINT 'Test 26.1: Authenticate valid HR administrator';
BEGIN TRY
    EXEC AuthenticateLeaveAdmin @AdminID = 1001, @Password = 'TestPassword123';
    PRINT '? Test 26.1 PASSED: HR admin authenticated successfully';
END TRY
BEGIN CATCH
    PRINT '? Test 26.1 FAILED: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 26.2: Authentication with Different Admin
PRINT 'Test 26.2: Authenticate another HR administrator';
IF NOT EXISTS (SELECT 1 FROM Employee WHERE EmployeeID = 2010)
    INSERT INTO Employee (EmployeeID, first_name, last_name, national_id, date_of_birth, country_of_birth, phone, email, hire_date, is_active, employment_status, account_status)
    VALUES (2010, 'HR', 'Admin2', 'N2010', '1985-06-20', 'USA', '5554445566', 'hradmin2@test.com', '2020-01-01', 1, 'Active', 'Active');

IF NOT EXISTS (SELECT 1 FROM HRAdministrator WHERE employee_id = 2010)
    INSERT INTO HRAdministrator (employee_id, approval_level, record_access_scope, document_validation_rights)
    VALUES (2010, 'Manager', 'Department', 1);

BEGIN TRY
    EXEC AuthenticateLeaveAdmin @AdminID = 2010, @Password = 'TestPassword456';
    PRINT '? Test 26.2 PASSED: Another HR admin authenticated successfully';
END TRY
BEGIN CATCH
    PRINT '? Test 26.2 FAILED: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 26.3: Corner Case - Non-existent Admin
PRINT 'Test 26.3: Attempt to authenticate non-existent admin';
BEGIN TRY
    EXEC AuthenticateLeaveAdmin @AdminID = 99999, @Password = 'TestPassword';
    PRINT '? Test 26.3 FAILED: Should have rejected non-existent admin';
END TRY
BEGIN CATCH
    PRINT '? Test 26.3 PASSED: Correctly rejected non-existent admin - ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 26.4: Corner Case - Non-HR Employee
PRINT 'Test 26.4: Attempt to authenticate non-HR employee';
BEGIN TRY
    EXEC AuthenticateLeaveAdmin @AdminID = 1002, @Password = 'TestPassword';
    PRINT '? Test 26.4 FAILED: Should have rejected non-HR employee';
END TRY
BEGIN CATCH
    PRINT '? Test 26.4 PASSED: Correctly rejected non-HR employee - ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- ========================================
-- TEST PROCEDURE 27: ApplyLeaveConfiguration
-- ========================================
PRINT '========================================';
PRINT 'TEST 27: ApplyLeaveConfiguration';
PRINT '========================================';

-- Test 27.1: Apply Configuration to All Employees
PRINT 'Test 27.1: Apply leave configuration to all active employees';
BEGIN TRY
    EXEC ApplyLeaveConfiguration;
    PRINT '? Test 27.1 PASSED: Leave configuration applied successfully';
END TRY
BEGIN CATCH
    PRINT '? Test 27.1 FAILED: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 27.2: Verify Entitlements Were Created
PRINT 'Test 27.2: Verify leave entitlements were created for employees';
BEGIN TRY
    DECLARE @EntitlementCount INT;
    SELECT @EntitlementCount = COUNT(*) 
    FROM LeaveEntitlement 
    WHERE employee_id IN (2001, 2002);
    
    IF @EntitlementCount > 0
        PRINT '? Test 27.2 PASSED: Entitlements created - Count: ' + CAST(@EntitlementCount AS VARCHAR(10));
    ELSE
        PRINT '? Test 27.2 FAILED: No entitlements created';
END TRY
BEGIN CATCH
    PRINT '? Test 27.2 FAILED: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 27.3: Apply Configuration Again (Should Update)
PRINT 'Test 27.3: Apply configuration again (should update existing)';
BEGIN TRY
    EXEC ApplyLeaveConfiguration;
    PRINT '? Test 27.3 PASSED: Configuration reapplied successfully';
END TRY
BEGIN CATCH
    PRINT '? Test 27.3 FAILED: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- ========================================
-- TEST PROCEDURE 28: UpdateLeaveEntitlements
-- ========================================
PRINT '========================================';
PRINT 'TEST 28: UpdateLeaveEntitlements';
PRINT '========================================';

-- Test 28.1: Update Entitlements for Full-Time Employee
PRINT 'Test 28.1: Update leave entitlements for full-time employee';
BEGIN TRY
    EXEC UpdateLeaveEntitlements @EmployeeID = 2001;
    PRINT '? Test 28.1 PASSED: Entitlements updated for full-time employee';
END TRY
BEGIN CATCH
    PRINT '? Test 28.1 FAILED: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 28.2: Update Entitlements for Part-Time Employee
PRINT 'Test 28.2: Update leave entitlements for part-time employee';
BEGIN TRY
    EXEC UpdateLeaveEntitlements @EmployeeID = 2002;
    PRINT '? Test 28.2 PASSED: Entitlements updated for part-time employee';
END TRY
BEGIN CATCH
    PRINT '? Test 28.2 FAILED: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 28.3: Corner Case - Non-existent Employee
PRINT 'Test 28.3: Attempt to update entitlements for non-existent employee';
BEGIN TRY
    EXEC UpdateLeaveEntitlements @EmployeeID = 99999;
    PRINT '? Test 28.3 FAILED: Should have rejected non-existent employee';
END TRY
BEGIN CATCH
    PRINT '? Test 28.3 PASSED: Correctly rejected non-existent employee - ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 28.4: Corner Case - Employee Without Contract
PRINT 'Test 28.4: Attempt to update entitlements for employee without contract';
IF NOT EXISTS (SELECT 1 FROM Employee WHERE EmployeeID = 2020)
    INSERT INTO Employee (EmployeeID, first_name, last_name, national_id, date_of_birth, country_of_birth, phone, email, hire_date, is_active, employment_status, account_status)
    VALUES (2020, 'No', 'Contract', 'N2020', '1992-08-15', 'USA', '5556667788', 'nocontract@test.com', '2024-01-01', 1, 'Active', 'Active');

BEGIN TRY
    EXEC UpdateLeaveEntitlements @EmployeeID = 2020;
    PRINT '? Test 28.4 FAILED: Should have rejected employee without contract';
END TRY
BEGIN CATCH
    PRINT '? Test 28.4 PASSED: Correctly rejected employee without contract - ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- ========================================
-- TEST PROCEDURE 29: ConfigureLeaveEligibility
-- ========================================
PRINT '========================================';
PRINT 'TEST 29: ConfigureLeaveEligibility';
PRINT '========================================';

-- Test 29.1: Configure Eligibility for Vacation Leave
PRINT 'Test 29.1: Configure eligibility for vacation leave';
BEGIN TRY
    EXEC ConfigureLeaveEligibility 
        @LeaveType = 'Vacation', 
        @MinTenure = 6, 
        @EmployeeType = 'Full-Time';
    PRINT '? Test 29.1 PASSED: Eligibility configured for vacation leave';
END TRY
BEGIN CATCH
    PRINT '? Test 29.1 FAILED: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 29.2: Configure Eligibility for All Employee Types
PRINT 'Test 29.2: Configure eligibility for all employee types';
BEGIN TRY
    EXEC ConfigureLeaveEligibility 
        @LeaveType = 'Sick', 
        @MinTenure = 0, 
        @EmployeeType = 'All';
    PRINT '? Test 29.2 PASSED: Eligibility configured for all types';
END TRY
BEGIN CATCH
    PRINT '? Test 29.2 FAILED: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 29.3: Update Existing Eligibility
PRINT 'Test 29.3: Update existing eligibility rules';
BEGIN TRY
    EXEC ConfigureLeaveEligibility 
        @LeaveType = 'Vacation', 
        @MinTenure = 3, 
        @EmployeeType = 'Full-Time';
    PRINT '? Test 29.3 PASSED: Eligibility rules updated successfully';
END TRY
BEGIN CATCH
    PRINT '? Test 29.3 FAILED: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 29.4: Corner Case - Non-existent Leave Type
PRINT 'Test 29.4: Attempt to configure eligibility for non-existent leave type';
BEGIN TRY
    EXEC ConfigureLeaveEligibility 
        @LeaveType = 'NonExistentLeave', 
        @MinTenure = 6, 
        @EmployeeType = 'Full-Time';
    PRINT '? Test 29.4 FAILED: Should have rejected non-existent leave type';
END TRY
BEGIN CATCH
    PRINT '? Test 29.4 PASSED: Correctly rejected non-existent leave type - ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 29.5: Corner Case - Invalid Employee Type
PRINT 'Test 29.5: Attempt to configure with invalid employee type';
BEGIN TRY
    EXEC ConfigureLeaveEligibility 
        @LeaveType = 'Vacation', 
        @MinTenure = 6, 
        @EmployeeType = 'InvalidType';
    PRINT '? Test 29.5 FAILED: Should have rejected invalid employee type';
END TRY
BEGIN CATCH
    PRINT '? Test 29.5 PASSED: Correctly rejected invalid employee type - ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- ========================================
-- TEST PROCEDURE 30: ManageLeaveTypes
-- ========================================
PRINT '========================================';
PRINT 'TEST 30: ManageLeaveTypes';
PRINT '========================================';

-- Test 30.1: Create New Leave Type
PRINT 'Test 30.1: Create new leave type - Maternity';
BEGIN TRY
    EXEC ManageLeaveTypes 
        @LeaveType = 'Maternity', 
        @Description = 'Maternity leave for expecting mothers';
    PRINT '? Test 30.1 PASSED: New leave type created successfully';
END TRY
BEGIN CATCH
    PRINT '? Test 30.1 FAILED: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 30.2: Create Another Leave Type
PRINT 'Test 30.2: Create new leave type - Bereavement';
BEGIN TRY
    EXEC ManageLeaveTypes 
        @LeaveType = 'Bereavement', 
        @Description = 'Leave for family bereavement';
    PRINT '? Test 30.2 PASSED: Bereavement leave type created successfully';
END TRY
BEGIN CATCH
    PRINT '? Test 30.2 FAILED: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 30.3: Update Existing Leave Type
PRINT 'Test 30.3: Update existing leave type description';
BEGIN TRY
    EXEC ManageLeaveTypes 
        @LeaveType = 'Maternity', 
        @Description = 'Extended maternity leave for new mothers (updated)';
    PRINT '? Test 30.3 PASSED: Leave type updated successfully';
END TRY
BEGIN CATCH
    PRINT '? Test 30.3 FAILED: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 30.4: Corner Case - Empty Description
PRINT 'Test 30.4: Attempt to create leave type with empty description';
BEGIN TRY
    EXEC ManageLeaveTypes 
        @LeaveType = 'TestLeave', 
        @Description = '';
    PRINT '? Test 30.4 FAILED: Should have rejected empty description';
END TRY
BEGIN CATCH
    PRINT '? Test 30.4 PASSED: Correctly rejected empty description - ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- ========================================
-- TEST PROCEDURE 31: AssignLeaveEntitlement
-- ========================================
PRINT '========================================';
PRINT 'TEST 31: AssignLeaveEntitlement';
PRINT '========================================';

-- Test 31.1: Assign Custom Entitlement
PRINT 'Test 31.1: Assign custom vacation entitlement to employee';
BEGIN TRY
    EXEC AssignLeaveEntitlement 
        @EmployeeID = 2001, 
        @LeaveType = 'Vacation', 
        @Entitlement = 25.00;
    PRINT '? Test 31.1 PASSED: Custom entitlement assigned successfully';
END TRY
BEGIN CATCH
    PRINT '? Test 31.1 FAILED: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 31.2: Assign Entitlement for New Leave Type
PRINT 'Test 31.2: Assign entitlement for maternity leave';
BEGIN TRY
    EXEC AssignLeaveEntitlement 
        @EmployeeID = 2002, 
        @LeaveType = 'Maternity', 
        @Entitlement = 90.00;
    PRINT '? Test 31.2 PASSED: Maternity entitlement assigned successfully';
END TRY
BEGIN CATCH
    PRINT '? Test 31.2 FAILED: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 31.3: Update Existing Entitlement
PRINT 'Test 31.3: Update existing entitlement';
BEGIN TRY
    EXEC AssignLeaveEntitlement 
        @EmployeeID = 2001, 
        @LeaveType = 'Vacation', 
        @Entitlement = 30.00;
    PRINT '? Test 31.3 PASSED: Entitlement updated successfully';
END TRY
BEGIN CATCH
    PRINT '? Test 31.3 FAILED: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 31.4: Corner Case - Negative Entitlement
PRINT 'Test 31.4: Attempt to assign negative entitlement';
BEGIN TRY
    EXEC AssignLeaveEntitlement 
        @EmployeeID = 2001, 
        @LeaveType = 'Vacation', 
        @Entitlement = -5.00;
    PRINT '? Test 31.4 FAILED: Should have rejected negative entitlement';
END TRY
BEGIN CATCH
    PRINT '? Test 31.4 PASSED: Correctly rejected negative entitlement - ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 31.5: Corner Case - Excessive Entitlement
PRINT 'Test 31.5: Attempt to assign entitlement exceeding maximum';
BEGIN TRY
    EXEC AssignLeaveEntitlement 
        @EmployeeID = 2001, 
        @LeaveType = 'Vacation', 
        @Entitlement = 1500.00;
    PRINT '? Test 31.5 FAILED: Should have rejected excessive entitlement';
END TRY
BEGIN CATCH
    PRINT '? Test 31.5 PASSED: Correctly rejected excessive entitlement - ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- ========================================
-- TEST PROCEDURE 32: ConfigureLeaveRules
-- ========================================
PRINT '========================================';
PRINT 'TEST 32: ConfigureLeaveRules';
PRINT '========================================';

-- Test 32.1: Configure Rules for Vacation Leave
PRINT 'Test 32.1: Configure rules for vacation leave';
BEGIN TRY
    EXEC ConfigureLeaveRules 
        @LeaveType = 'Vacation', 
        @MaxDuration = 14, 
        @NoticePeriod = 7, 
        @WorkflowType = 'Direct Manager';
    PRINT '? Test 32.1 PASSED: Vacation leave rules configured successfully';
END TRY
BEGIN CATCH
    PRINT '? Test 32.1 FAILED: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 32.2: Configure Rules for Sick Leave
PRINT 'Test 32.2: Configure rules for sick leave';
BEGIN TRY
    EXEC ConfigureLeaveRules 
        @LeaveType = 'Sick', 
        @MaxDuration = 5, 
        @NoticePeriod = 0, 
        @WorkflowType = 'Automatic';
    PRINT '? Test 32.2 PASSED: Sick leave rules configured successfully';
END TRY
BEGIN CATCH
    PRINT '? Test 32.2 FAILED: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 32.3: Configure Rules with Two-Level Approval
PRINT 'Test 32.3: Configure rules with two-level approval workflow';
BEGIN TRY
    EXEC ConfigureLeaveRules 
        @LeaveType = 'Maternity', 
        @MaxDuration = 90, 
        @NoticePeriod = 30, 
        @WorkflowType = 'Two-Level';
    PRINT '? Test 32.3 PASSED: Two-level approval rules configured successfully';
END TRY
BEGIN CATCH
    PRINT '? Test 32.3 FAILED: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 32.4: Corner Case - Non-existent Leave Type
PRINT 'Test 32.4: Attempt to configure rules for non-existent leave type';
BEGIN TRY
    EXEC ConfigureLeaveRules 
        @LeaveType = 'NonExistentLeave', 
        @MaxDuration = 10, 
        @NoticePeriod = 5, 
        @WorkflowType = 'Direct Manager';
    PRINT '? Test 32.4 FAILED: Should have rejected non-existent leave type';
END TRY
BEGIN CATCH
    PRINT '? Test 32.4 PASSED: Correctly rejected non-existent leave type - ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 32.5: Corner Case - Invalid Workflow Type
PRINT 'Test 32.5: Attempt to configure with invalid workflow type';
BEGIN TRY
    EXEC ConfigureLeaveRules 
        @LeaveType = 'Vacation', 
        @MaxDuration = 10, 
        @NoticePeriod = 5, 
        @WorkflowType = 'InvalidWorkflow';
    PRINT '? Test 32.5 FAILED: Should have rejected invalid workflow type';
END TRY
BEGIN CATCH
    PRINT '? Test 32.5 PASSED: Correctly rejected invalid workflow type - ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 32.6: Corner Case - Zero or Negative Max Duration
PRINT 'Test 32.6: Attempt to configure with zero max duration';
BEGIN TRY
    EXEC ConfigureLeaveRules 
        @LeaveType = 'Vacation', 
        @MaxDuration = 0, 
        @NoticePeriod = 5, 
        @WorkflowType = 'Direct Manager';
    PRINT '? Test 32.6 FAILED: Should have rejected zero max duration';
END TRY
BEGIN CATCH
    PRINT '? Test 32.6 PASSED: Correctly rejected zero max duration - ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- ========================================
-- TEST PROCEDURE 33: ConfigureSpecialLeave
-- ========================================
PRINT '========================================';
PRINT 'TEST 33: ConfigureSpecialLeave';
PRINT '========================================';

-- Test 33.1: Configure Special Leave - Bereavement
PRINT 'Test 33.1: Configure special leave type - Bereavement';
BEGIN TRY
    EXEC ConfigureSpecialLeave 
        @LeaveType = 'Bereavement Special', 
        @Rules = 'Up to 3 days for immediate family, 1 day for extended family';
    PRINT '? Test 33.1 PASSED: Bereavement special leave configured successfully';
END TRY
BEGIN CATCH
    PRINT '? Test 33.1 FAILED: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 33.2: Configure Special Leave - Jury Duty
PRINT 'Test 33.2: Configure special leave type - Jury Duty';
BEGIN TRY
    EXEC ConfigureSpecialLeave 
        @LeaveType = 'Jury Duty', 
        @Rules = 'Full pay maintained, requires court documentation';
    PRINT '? Test 33.2 PASSED: Jury duty special leave configured successfully';
END TRY
BEGIN CATCH
    PRINT '? Test 33.2 FAILED: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 33.3: Configure Special Leave - Study Leave
PRINT 'Test 33.3: Configure special leave type - Study Leave';
BEGIN TRY
    EXEC ConfigureSpecialLeave 
        @LeaveType = 'Study Leave', 
        @Rules = 'Up to 5 days per year for professional development';
    PRINT '? Test 33.3 PASSED: Study leave configured successfully';
END TRY
BEGIN CATCH
    PRINT '? Test 33.3 FAILED: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 33.4: Corner Case - Empty Leave Type
PRINT 'Test 33.4: Attempt to configure with empty leave type';
BEGIN TRY
    EXEC ConfigureSpecialLeave 
        @LeaveType = '', 
        @Rules = 'Some rules';
    PRINT '? Test 33.4 FAILED: Should have rejected empty leave type';
END TRY
BEGIN CATCH
    PRINT '? Test 33.4 PASSED: Correctly rejected empty leave type - ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 33.5: Corner Case - Empty Rules
PRINT 'Test 33.5: Attempt to configure with empty rules';
BEGIN TRY
    EXEC ConfigureSpecialLeave 
        @LeaveType = 'Test Leave', 
        @Rules = '';
    PRINT '? Test 33.5 FAILED: Should have rejected empty rules';
END TRY
BEGIN CATCH
    PRINT '? Test 33.5 PASSED: Correctly rejected empty rules - ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 33.6: Corner Case - Duplicate Special Leave
PRINT 'Test 33.6: Attempt to configure duplicate special leave';
BEGIN TRY
    EXEC ConfigureSpecialLeave 
        @LeaveType = 'Bereavement Special', 
        @Rules = 'Duplicate rules';
    PRINT '? Test 33.6 FAILED: Should have rejected duplicate special leave';
END TRY
BEGIN CATCH
    PRINT '? Test 33.6 PASSED: Correctly rejected duplicate special leave - ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- ========================================
-- TEST PROCEDURE 34: SetLeaveYearRules
-- ========================================
PRINT '========================================';
PRINT 'TEST 34: SetLeaveYearRules';
PRINT '========================================';

-- Clean up existing leave year rule for testing
DELETE FROM LeavePolicy WHERE name = 'Leave Year Rule';

-- Test 34.1: Set Leave Year Rules
PRINT 'Test 34.1: Set leave year rules (Jan 1 - Dec 31)';
BEGIN TRY
    EXEC SetLeaveYearRules 
        @StartDate = '2024-01-01', 
        @EndDate = '2024-12-31';
    PRINT '? Test 34.1 PASSED: Leave year rules set successfully';
END TRY
BEGIN CATCH
    PRINT '? Test 34.1 FAILED: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 34.2: Update Leave Year Rules
PRINT 'Test 34.2: Update leave year rules (Apr 1 - Mar 31)';
BEGIN TRY
    EXEC SetLeaveYearRules 
        @StartDate = '2024-04-01', 
        @EndDate = '2025-03-31';
    PRINT '? Test 34.2 PASSED: Leave year rules updated successfully';
END TRY
BEGIN CATCH
    PRINT '? Test 34.2 FAILED: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 34.3: Set Leave Year with Different Range
PRINT 'Test 34.3: Set leave year rules (Jul 1 - Jun 30)';
BEGIN TRY
    -- Clean up first
    DELETE FROM LeavePolicy WHERE name = 'Leave Year Rule';
    
    EXEC SetLeaveYearRules 
        @StartDate = '2024-07-01', 
        @EndDate = '2025-06-30';
    PRINT '? Test 34.3 PASSED: Leave year rules with different range set successfully';
END TRY
BEGIN CATCH
    PRINT '? Test 34.3 FAILED: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 34.4: Corner Case - End Date Before Start Date
PRINT 'Test 34.4: Attempt to set leave year with end date before start date';
BEGIN TRY
    EXEC SetLeaveYearRules 
        @StartDate = '2024-12-31', 
        @EndDate = '2024-01-01';
    PRINT '? Test 34.4 FAILED: Should have rejected end date before start date';
END TRY
BEGIN CATCH
    PRINT '? Test 34.4 PASSED: Correctly rejected end date before start date - ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 34.5: Corner Case - Exceeds Maximum Duration
PRINT 'Test 34.5: Attempt to set leave year exceeding 13 months';
BEGIN TRY
    EXEC SetLeaveYearRules 
        @StartDate = '2024-01-01', 
        @EndDate = '2025-03-01';
    PRINT '? Test 34.5 FAILED: Should have rejected duration > 13 months';
END TRY
BEGIN CATCH
    PRINT '? Test 34.5 PASSED: Correctly rejected duration > 13 months - ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 34.6: Corner Case - NULL Dates
PRINT 'Test 34.6: Attempt to set leave year with NULL dates';
BEGIN TRY
    EXEC SetLeaveYearRules 
        @StartDate = NULL, 
        @EndDate = '2024-12-31';
    PRINT '? Test 34.6 FAILED: Should have rejected NULL start date';
END TRY
BEGIN CATCH
    PRINT '? Test 34.6 PASSED: Correctly rejected NULL start date - ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- ========================================
-- TEST PROCEDURE 35: AdjustLeaveBalance
-- ========================================
PRINT '========================================';
PRINT 'TEST 35: AdjustLeaveBalance';
PRINT '========================================';

-- Test 35.1: Successful Positive Adjustment
PRINT 'Test 35.1: Add 5 days to vacation leave balance';
BEGIN TRY
    EXEC AdjustLeaveBalance @EmployeeID = 2001, @LeaveType = 'Vacation', @Adjustment = 5.00;
    PRINT '? Test 35.1 PASSED: Leave balance adjusted successfully (positive)';
END TRY
BEGIN CATCH
    PRINT '? Test 35.1 FAILED: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 35.2: Successful Negative Adjustment
PRINT 'Test 35.2: Deduct 3 days from vacation leave balance';
BEGIN TRY
    EXEC AdjustLeaveBalance @EmployeeID = 2001, @LeaveType = 'Vacation', @Adjustment = -3.00;
    PRINT '? Test 35.2 PASSED: Leave balance adjusted successfully (negative)';
END TRY
BEGIN CATCH
    PRINT '? Test 35.2 FAILED: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 35.3: Corner Case - Adjustment Results in Negative Balance
PRINT 'Test 35.3: Attempt adjustment that would result in negative balance';
BEGIN TRY
    EXEC AdjustLeaveBalance @EmployeeID = 2002, @LeaveType = 'Vacation', @Adjustment = -50.00;
    PRINT '? Test 35.3 FAILED: Should have rejected adjustment causing negative balance';
END TRY
BEGIN CATCH
    PRINT '? Test 35.3 PASSED: Correctly rejected negative balance - ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 35.4: Corner Case - Non-existent Leave Type
PRINT 'Test 35.4: Attempt to adjust balance for non-existent leave type';
BEGIN TRY
    EXEC AdjustLeaveBalance @EmployeeID = 2001, @LeaveType = 'NonExistentLeave', @Adjustment = 5.00;
    PRINT '? Test 35.4 FAILED: Should have rejected non-existent leave type';
END TRY
BEGIN CATCH
    PRINT '? Test 35.4 PASSED: Correctly rejected non-existent leave type - ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- ========================================
-- TEST PROCEDURE 36: ManageLeaveRoles
-- ========================================
PRINT '========================================';
PRINT 'TEST 36: ManageLeaveRoles';
PRINT '========================================';

-- Test 36.1: Create New Leave Role
PRINT 'Test 36.1: Create new leave role with permissions';
BEGIN TRY
    EXEC ManageLeaveRoles @RoleID = 1000, @Permissions = 'Approve,Reject,ViewAll';
    PRINT '? Test 36.1 PASSED: Leave role created successfully';
END TRY
BEGIN CATCH
    PRINT '? Test 36.1 FAILED: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 36.2: Update Existing Leave Role
PRINT 'Test 36.2: Update existing leave role permissions';
BEGIN TRY
    EXEC ManageLeaveRoles @RoleID = 1000, @Permissions = 'Approve,Reject,ViewAll,Override';
    PRINT '? Test 36.2 PASSED: Leave role updated successfully';
END TRY
BEGIN CATCH
    PRINT '? Test 36.2 FAILED: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 36.3: Create Another Role
PRINT 'Test 36.3: Create another leave role';
BEGIN TRY
    EXEC ManageLeaveRoles @RoleID = 1001, @Permissions = 'ViewOwn,Submit';
    PRINT '? Test 36.3 PASSED: Another leave role created successfully';
END TRY
BEGIN CATCH
    PRINT '? Test 36.3 FAILED: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 36.4: Corner Case - Empty Permissions
PRINT 'Test 36.4: Attempt to create role with empty permissions';
BEGIN TRY
    EXEC ManageLeaveRoles @RoleID = 1002, @Permissions = '';
    PRINT '? Test 36.4 FAILED: Should have rejected empty permissions';
END TRY
BEGIN CATCH
    PRINT '? Test 36.4 PASSED: Correctly rejected empty permissions - ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- ========================================
-- TEST PROCEDURE 37: FinalizeLeaveRequest
-- ========================================
PRINT '========================================';
PRINT 'TEST 37: FinalizeLeaveRequest';
PRINT '========================================';

-- Test 37.1: Successful Finalization
PRINT 'Test 37.1: Finalize approved leave request';
BEGIN TRY
    EXEC FinalizeLeaveRequest @LeaveRequestID = 500;
    PRINT '? Test 37.1 PASSED: Leave request finalized successfully';
END TRY
BEGIN CATCH
    PRINT '? Test 37.1 FAILED: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 37.2: Successful Finalization of Another Request
PRINT 'Test 37.2: Finalize another approved leave request';
-- Create another approved request
IF NOT EXISTS (SELECT 1 FROM LeaveRequest WHERE RequestID = 503)
BEGIN
    DECLARE @VacLeaveID2 INT;
    SELECT @VacLeaveID2 = LeaveID FROM Leave WHERE leave_type = 'Vacation';
    INSERT INTO LeaveEntitlement (employee_id, leave_type_id, entitlement)
    SELECT 2002, @VacLeaveID2, 15
    WHERE NOT EXISTS (SELECT 1 FROM LeaveEntitlement WHERE employee_id = 2002 AND leave_type_id = @VacLeaveID2);
    
    INSERT INTO LeaveRequest (RequestID, employee_id, leave_id, justification, duration, approval_timing, status)
    VALUES (503, 2002, @VacLeaveID2, 'Another test', 2, GETDATE(), 'APPROVED');
END

BEGIN TRY
    EXEC FinalizeLeaveRequest @LeaveRequestID = 503;
    PRINT '? Test 37.2 PASSED: Another leave request finalized successfully';
END TRY
BEGIN CATCH
    PRINT '? Test 37.2 FAILED: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 37.3: Corner Case - Non-existent Request
PRINT 'Test 37.3: Attempt to finalize non-existent leave request';
BEGIN TRY
    EXEC FinalizeLeaveRequest @LeaveRequestID = 99999;
    PRINT '? Test 37.3 FAILED: Should have rejected non-existent request';
END TRY
BEGIN CATCH
    PRINT '? Test 37.3 PASSED: Correctly rejected non-existent request - ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 37.4: Corner Case - Already Finalized Request
PRINT 'Test 37.4: Attempt to finalize already finalized request';
BEGIN TRY
    EXEC FinalizeLeaveRequest @LeaveRequestID = 500;
    PRINT '? Test 37.4 FAILED: Should have rejected already finalized request';
END TRY
BEGIN CATCH
    PRINT '? Test 37.4 PASSED: Correctly rejected already finalized request - ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- ========================================
-- TEST PROCEDURE 38: OverrideLeaveDecision
-- ========================================
PRINT '========================================';
PRINT 'TEST 38: OverrideLeaveDecision';
PRINT '========================================';

-- Create test request for override
IF NOT EXISTS (SELECT 1 FROM LeaveRequest WHERE RequestID = 504)
BEGIN
    DECLARE @VacLeaveID3 INT;
    SELECT @VacLeaveID3 = LeaveID FROM Leave WHERE leave_type = 'Vacation';
    INSERT INTO LeaveRequest (RequestID, employee_id, leave_id, justification, duration, approval_timing, status)
    VALUES (504, 2001, @VacLeaveID3, 'For override test', 3, GETDATE(), 'APPROVED');
END

-- Create rejected request for override test
IF NOT EXISTS (SELECT 1 FROM LeaveRequest WHERE RequestID = 505)
BEGIN
    DECLARE @VacLeaveID4 INT;
    SELECT @VacLeaveID4 = LeaveID FROM Leave WHERE leave_type = 'Vacation';
    INSERT INTO LeaveRequest (RequestID, employee_id, leave_id, justification, duration, approval_timing, status)
    VALUES (505, 2002, @VacLeaveID4, 'Rejected request', 2, GETDATE(), 'REJECTED');
END

-- Test 38.1: Successful Override of Approved Request
PRINT 'Test 38.1: Override approved leave request';
BEGIN TRY
    EXEC OverrideLeaveDecision @LeaveRequestID = 504, @Reason = 'Business critical project requires all hands on deck';
    PRINT '? Test 38.1 PASSED: Leave request overridden successfully';
END TRY
BEGIN CATCH
    PRINT '? Test 38.1 FAILED: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 38.2: Successful Override of Rejected Request
PRINT 'Test 38.2: Override rejected leave request';
BEGIN TRY
    EXEC OverrideLeaveDecision @LeaveRequestID = 505, @Reason = 'Medical emergency requires reconsideration';
    PRINT '? Test 38.2 PASSED: Rejected request overridden successfully';
END TRY
BEGIN CATCH
    PRINT '? Test 38.2 FAILED: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 38.3: Corner Case - Pending Request (No Decision Yet)
PRINT 'Test 38.3: Attempt to override pending request (no decision yet)';
IF NOT EXISTS (SELECT 1 FROM LeaveRequest WHERE RequestID = 506)
BEGIN
    DECLARE @VacLeaveID5 INT;
    SELECT @VacLeaveID5 = LeaveID FROM Leave WHERE leave_type = 'Vacation';
    INSERT INTO LeaveRequest (RequestID, employee_id, leave_id, justification, duration, approval_timing, status)
    VALUES (506, 2001, @VacLeaveID5, 'Pending request', 1, GETDATE(), 'PENDING');
END

BEGIN TRY
    EXEC OverrideLeaveDecision @LeaveRequestID = 506, @Reason = 'Cannot override pending';
    PRINT '? Test 38.3 FAILED: Should have rejected pending request override';
END TRY
BEGIN CATCH
    PRINT '? Test 38.3 PASSED: Correctly rejected pending request - ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 38.4: Corner Case - Empty Reason
PRINT 'Test 38.4: Attempt to override without providing reason';
BEGIN TRY
    EXEC OverrideLeaveDecision @LeaveRequestID = 504, @Reason = '';
    PRINT '? Test 38.4 FAILED: Should have rejected empty reason';
END TRY
BEGIN CATCH
    PRINT '? Test 38.4 PASSED: Correctly rejected empty reason - ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- ========================================
-- TEST PROCEDURE 39: BulkProcessLeaveRequests
-- ========================================
PRINT '========================================';
PRINT 'TEST 39: BulkProcessLeaveRequests';
PRINT '========================================';

-- Create multiple approved requests for bulk processing
DECLARE @BulkVacLeaveID INT;
SELECT @BulkVacLeaveID = LeaveID FROM Leave WHERE leave_type = 'Vacation';

IF NOT EXISTS (SELECT 1 FROM LeaveRequest WHERE RequestID = 600)
BEGIN
    -- Ensure adequate leave balance
    UPDATE LeaveEntitlement SET entitlement = 30 WHERE employee_id = 2001 AND leave_type_id = @BulkVacLeaveID;
    
    INSERT INTO LeaveRequest (RequestID, employee_id, leave_id, justification, duration, approval_timing, status)
    VALUES (600, 2001, @BulkVacLeaveID, 'Bulk test 1', 3, GETDATE(), 'APPROVED');
END

IF NOT EXISTS (SELECT 1 FROM LeaveRequest WHERE RequestID = 601)
    INSERT INTO LeaveRequest (RequestID, employee_id, leave_id, justification, duration, approval_timing, status)
    VALUES (601, 2001, @BulkVacLeaveID, 'Bulk test 2', 2, GETDATE(), 'APPROVED');

IF NOT EXISTS (SELECT 1 FROM LeaveRequest WHERE RequestID = 602)
    INSERT INTO LeaveRequest (RequestID, employee_id, leave_id, justification, duration, approval_timing, status)
    VALUES (602, 2002, @BulkVacLeaveID, 'Bulk test 3', 1, GETDATE(), 'APPROVED');

-- Test 39.1: Successful Bulk Processing
PRINT 'Test 39.1: Bulk process multiple leave requests';
BEGIN TRY
    EXEC BulkProcessLeaveRequests @LeaveRequestIDs = '600,601,602';
    PRINT '? Test 39.1 PASSED: Bulk processing completed successfully';
END TRY
BEGIN CATCH
    PRINT '? Test 39.1 FAILED: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 39.2: Bulk Process with Single Request
PRINT 'Test 39.2: Bulk process with single request';
IF NOT EXISTS (SELECT 1 FROM LeaveRequest WHERE RequestID = 603)
BEGIN
    INSERT INTO LeaveRequest (RequestID, employee_id, leave_id, justification, duration, approval_timing, status)
    VALUES (603, 2002, @BulkVacLeaveID, 'Single bulk', 1, GETDATE(), 'APPROVED');
END

BEGIN TRY
    EXEC BulkProcessLeaveRequests @LeaveRequestIDs = '603';
    PRINT '? Test 39.2 PASSED: Single request bulk processing successful';
END TRY
BEGIN CATCH
    PRINT '? Test 39.2 FAILED: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 39.3: Corner Case - Empty Request IDs
PRINT 'Test 39.3: Attempt bulk processing with empty list';
BEGIN TRY
    EXEC BulkProcessLeaveRequests @LeaveRequestIDs = '';
    PRINT '? Test 39.3 FAILED: Should have rejected empty list';
END TRY
BEGIN CATCH
    PRINT '? Test 39.3 PASSED: Correctly rejected empty list - ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 39.4: Corner Case - Mix of Valid and Invalid IDs
PRINT 'Test 39.4: Bulk process with mix of valid and invalid IDs';
BEGIN TRY
    EXEC BulkProcessLeaveRequests @LeaveRequestIDs = '603,99999,604';
    PRINT '? Test 39.4 PASSED: Bulk processing handled mixed IDs appropriately';
END TRY
BEGIN CATCH
    PRINT '? Test 39.4 FAILED: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- ========================================
-- TEST PROCEDURE 40: VerifyMedicalLeave
-- ========================================
PRINT '========================================';
PRINT 'TEST 40: VerifyMedicalLeave';
PRINT '========================================';

-- Create sick leave request
DECLARE @SickLeaveID INT;
SELECT @SickLeaveID = LeaveID FROM Leave WHERE leave_type = 'Sick';

IF NOT EXISTS (SELECT 1 FROM LeaveRequest WHERE RequestID = 700)
    INSERT INTO LeaveRequest (RequestID, employee_id, leave_id, justification, duration, approval_timing, status)
    VALUES (700, 2001, @SickLeaveID, 'Medical certificate attached', 3, GETDATE(), 'APPROVED');

-- Create medical document
IF NOT EXISTS (SELECT 1 FROM LeaveDocument WHERE DocumentID = 1000)
    INSERT INTO LeaveDocument (DocumentID, leave_request_id, file_path, uploaded_at)
    VALUES (1000, 700, '/documents/medical_cert_700.pdf', GETDATE());

-- Test 40.1: Successful Medical Leave Verification
PRINT 'Test 40.1: Verify medical leave with document';
BEGIN TRY
    EXEC VerifyMedicalLeave @LeaveRequestID = 700, @DocumentID = 1000;
    PRINT '? Test 40.1 PASSED: Medical leave verified successfully';
END TRY
BEGIN CATCH
    PRINT '? Test 40.1 FAILED: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 40.2: Create and Verify Another Medical Leave
PRINT 'Test 40.2: Verify another medical leave request';
IF NOT EXISTS (SELECT 1 FROM LeaveRequest WHERE RequestID = 701)
    INSERT INTO LeaveRequest (RequestID, employee_id, leave_id, justification, duration, approval_timing, status)
    VALUES (701, 2002, @SickLeaveID, 'Hospital admission', 5, GETDATE(), 'APPROVED');

IF NOT EXISTS (SELECT 1 FROM LeaveDocument WHERE DocumentID = 1001)
    INSERT INTO LeaveDocument (DocumentID, leave_request_id, file_path, uploaded_at)
    VALUES (1001, 701, '/documents/medical_cert_701.pdf', GETDATE());

BEGIN TRY
    EXEC VerifyMedicalLeave @LeaveRequestID = 701, @DocumentID = 1001;
    PRINT '? Test 40.2 PASSED: Another medical leave verified successfully';
END TRY
BEGIN CATCH
    PRINT '? Test 40.2 FAILED: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 40.3: Corner Case - Non-existent Document
PRINT 'Test 40.3: Attempt verification with non-existent document';
BEGIN TRY
    EXEC VerifyMedicalLeave @LeaveRequestID = 700, @DocumentID = 99999;
    PRINT '? Test 40.3 FAILED: Should have rejected non-existent document';
END TRY
BEGIN CATCH
    PRINT '? Test 40.3 PASSED: Correctly rejected non-existent document - ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 40.4: Corner Case - Document Doesn't Match Request
PRINT 'Test 40.4: Attempt verification with mismatched document';
BEGIN TRY
    EXEC VerifyMedicalLeave @LeaveRequestID = 700, @DocumentID = 1001;
    PRINT '? Test 40.4 FAILED: Should have rejected mismatched document';
END TRY
BEGIN CATCH
    PRINT '? Test 40.4 PASSED: Correctly rejected mismatched document - ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- ========================================
-- TEST PROCEDURE 41: SyncLeaveBalances
-- ========================================
PRINT '========================================';
PRINT 'TEST 41: SyncLeaveBalances';
PRINT '========================================';

-- Create approved request for sync
DECLARE @SyncVacLeaveID INT;
SELECT @SyncVacLeaveID = LeaveID FROM Leave WHERE leave_type = 'Vacation';

-- Ensure employee has adequate balance
UPDATE LeaveEntitlement SET entitlement = 20 WHERE employee_id = 2001 AND leave_type_id = @SyncVacLeaveID;

IF NOT EXISTS (SELECT 1 FROM LeaveRequest WHERE RequestID = 800)
    INSERT INTO LeaveRequest (RequestID, employee_id, leave_id, justification, duration, approval_timing, status)
    VALUES (800, 2001, @SyncVacLeaveID, 'Sync test', 3, GETDATE(), 'APPROVED');

-- Test 41.1: Successful Balance Sync
PRINT 'Test 41.1: Sync leave balance for approved request';
BEGIN TRY
    EXEC SyncLeaveBalances @LeaveRequestID = 800;
    PRINT '? Test 41.1 PASSED: Leave balance synced successfully';
END TRY
BEGIN CATCH
    PRINT '? Test 41.1 FAILED: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 41.2: Sync Another Request
PRINT 'Test 41.2: Sync another approved request';
IF NOT EXISTS (SELECT 1 FROM LeaveRequest WHERE RequestID = 801)
    INSERT INTO LeaveRequest (RequestID, employee_id, leave_id, justification, duration, approval_timing, status)
    VALUES (801, 2002, @SyncVacLeaveID, 'Another sync test', 2, GETDATE(), 'APPROVED');

BEGIN TRY
    EXEC SyncLeaveBalances @LeaveRequestID = 801;
    PRINT '? Test 41.2 PASSED: Another balance synced successfully';
END TRY
BEGIN CATCH
    PRINT '? Test 41.2 FAILED: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 41.3: Corner Case - Non-approved Request
PRINT 'Test 41.3: Attempt to sync balance for pending request';
IF NOT EXISTS (SELECT 1 FROM LeaveRequest WHERE RequestID = 802)
    INSERT INTO LeaveRequest (RequestID, employee_id, leave_id, justification, duration, approval_timing, status)
    VALUES (802, 2001, @SyncVacLeaveID, 'Pending sync', 1, GETDATE(), 'PENDING');

BEGIN TRY
    EXEC SyncLeaveBalances @LeaveRequestID = 802;
    PRINT '? Test 41.3 FAILED: Should have rejected non-approved request';
END TRY
BEGIN CATCH
    PRINT '? Test 41.3 PASSED: Correctly rejected non-approved request - ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 41.4: Corner Case - Insufficient Balance
PRINT 'Test 41.4: Attempt to sync with insufficient balance';
UPDATE LeaveEntitlement SET entitlement = 1 WHERE employee_id = 2001 AND leave_type_id = @SyncVacLeaveID;

IF NOT EXISTS (SELECT 1 FROM LeaveRequest WHERE RequestID = 803)
    INSERT INTO LeaveRequest (RequestID, employee_id, leave_id, justification, duration, approval_timing, status)
    VALUES (803, 2001, @SyncVacLeaveID, 'Insufficient balance', 5, GETDATE(), 'APPROVED');

BEGIN TRY
    EXEC SyncLeaveBalances @LeaveRequestID = 803;
    PRINT '? Test 41.4 FAILED: Should have rejected insufficient balance';
END TRY
BEGIN CATCH
    PRINT '? Test 41.4 PASSED: Correctly rejected insufficient balance - ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- ========================================
-- TEST PROCEDURE 42: ProcessLeaveCarryForward
-- ========================================
PRINT '========================================';
PRINT 'TEST 42: ProcessLeaveCarryForward';
PRINT '========================================';

-- Test 42.1: Successful Carry Forward Processing
PRINT 'Test 42.1: Process leave carry forward for 2024';
BEGIN TRY
    EXEC ProcessLeaveCarryForward @Year = 2024;
    PRINT '? Test 42.1 PASSED: Carry forward processed successfully';
END TRY
BEGIN CATCH
    PRINT '? Test 42.1 FAILED: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 42.2: Process Carry Forward for Different Year
PRINT 'Test 42.2: Process carry forward for 2025';
BEGIN TRY
    EXEC ProcessLeaveCarryForward @Year = 2025;
    PRINT '? Test 42.2 PASSED: Carry forward for 2025 processed successfully';
END TRY
BEGIN CATCH
    PRINT '? Test 42.2 FAILED: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 42.3: Corner Case - Duplicate Processing for Same Year
PRINT 'Test 42.3: Attempt to process carry forward for same year twice';
BEGIN TRY
    EXEC ProcessLeaveCarryForward @Year = 2024;
    PRINT '? Test 42.3 FAILED: Should have rejected duplicate processing';
END TRY
BEGIN CATCH
    PRINT '? Test 42.3 PASSED: Correctly rejected duplicate processing - ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 42.4: Corner Case - Invalid Year
PRINT 'Test 42.4: Attempt to process with invalid year';
BEGIN TRY
    EXEC ProcessLeaveCarryForward @Year = 1999;
    PRINT '? Test 42.4 FAILED: Should have rejected invalid year';
END TRY
BEGIN CATCH
    PRINT '? Test 42.4 PASSED: Correctly rejected invalid year - ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- ========================================
-- TEST PROCEDURE 43: SyncLeaveToAttendance
-- ========================================
PRINT '========================================';
PRINT 'TEST 43: SyncLeaveToAttendance';
PRINT '========================================';

-- Create approved leave request for attendance sync
DECLARE @AttendVacLeaveID INT;
SELECT @AttendVacLeaveID = LeaveID FROM Leave WHERE leave_type = 'Vacation';

IF NOT EXISTS (SELECT 1 FROM LeaveRequest WHERE RequestID = 900)
    INSERT INTO LeaveRequest (RequestID, employee_id, leave_id, justification, duration, approval_timing, status)
    VALUES (900, 2001, @AttendVacLeaveID, 'Attendance sync test', 3, GETDATE(), 'APPROVED');

-- Test 43.1: Successful Leave to Attendance Sync
PRINT 'Test 43.1: Sync approved leave to attendance system';
BEGIN TRY
    EXEC SyncLeaveToAttendance @LeaveRequestID = 900;
    PRINT '? Test 43.1 PASSED: Leave synced to attendance successfully';
END TRY
BEGIN CATCH
    PRINT '? Test 43.1 FAILED: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 43.2: Sync Another Leave Request
PRINT 'Test 43.2: Sync another leave request to attendance';
IF NOT EXISTS (SELECT 1 FROM LeaveRequest WHERE RequestID = 901)
    INSERT INTO LeaveRequest (RequestID, employee_id, leave_id, justification, duration, approval_timing, status)
    VALUES (901, 2002, @AttendVacLeaveID, 'Another attendance sync', 2, GETDATE(), 'APPROVED');

BEGIN TRY
    EXEC SyncLeaveToAttendance @LeaveRequestID = 901;
    PRINT '? Test 43.2 PASSED: Another leave synced successfully';
END TRY
BEGIN CATCH
    PRINT '? Test 43.2 FAILED: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 43.3: Corner Case - Non-approved Request
PRINT 'Test 43.3: Attempt to sync pending leave request';
IF NOT EXISTS (SELECT 1 FROM LeaveRequest WHERE RequestID = 902)
    INSERT INTO LeaveRequest (RequestID, employee_id, leave_id, justification, duration, approval_timing, status)
    VALUES (902, 2001, @AttendVacLeaveID, 'Pending leave', 1, GETDATE(), 'PENDING');

BEGIN TRY
    EXEC SyncLeaveToAttendance @LeaveRequestID = 902;
    PRINT '? Test 43.3 FAILED: Should have rejected pending request';
END TRY
BEGIN CATCH
    PRINT '? Test 43.3 PASSED: Correctly rejected pending request - ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- ========================================
-- TEST PROCEDURE 44: UpdateInsuranceBrackets
-- ========================================
PRINT '========================================';
PRINT 'TEST 44: UpdateInsuranceBrackets';
PRINT '========================================';

-- Create test insurance bracket
IF NOT EXISTS (SELECT 1 FROM Insurance WHERE InsuranceID = 1)
    INSERT INTO Insurance (InsuranceID, type, contribution_rate, coverage)
    VALUES (1, 'Health', 5.00, 'Basic coverage');

-- Test 44.1: Successful Insurance Bracket Update
PRINT 'Test 44.1: Update insurance bracket with new rates';
BEGIN TRY
    EXEC UpdateInsuranceBrackets 
        @BracketID = 1, 
        @NewMinSalary = 30000.00, 
        @NewMaxSalary = 60000.00,
        @NewEmployeeContribution = 7.50,
        @NewEmployerContribution = 12.50,
        @UpdatedBy = 1001;
    PRINT '? Test 44.1 PASSED: Insurance bracket updated successfully';
END TRY
BEGIN CATCH
    PRINT '? Test 44.1 FAILED: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 44.2: Update with Different Values
PRINT 'Test 44.2: Update insurance bracket with different contribution rates';
BEGIN TRY
    EXEC UpdateInsuranceBrackets 
        @BracketID = 1, 
        @NewMinSalary = 60000.00, 
        @NewMaxSalary = 100000.00,
        @NewEmployeeContribution = 10.00,
        @NewEmployerContribution = 15.00,
        @UpdatedBy = 1001;
    PRINT '? Test 44.2 PASSED: Insurance bracket updated with new rates';
END TRY
BEGIN CATCH
    PRINT '? Test 44.2 FAILED: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 44.3: Corner Case - Invalid Salary Range
PRINT 'Test 44.3: Attempt update with invalid salary range (max < min)';
BEGIN TRY
    EXEC UpdateInsuranceBrackets 
        @BracketID = 1, 
        @NewMinSalary = 100000.00, 
        @NewMaxSalary = 50000.00,
        @NewEmployeeContribution = 5.00,
        @NewEmployerContribution = 10.00,
        @UpdatedBy = 1001;
    PRINT '? Test 44.3 FAILED: Should have rejected invalid salary range';
END TRY
BEGIN CATCH
    PRINT '? Test 44.3 PASSED: Correctly rejected invalid salary range - ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 44.4: Corner Case - Invalid Contribution Rate
PRINT 'Test 44.4: Attempt update with contribution rate > 100%';
BEGIN TRY
    EXEC UpdateInsuranceBrackets 
        @BracketID = 1, 
        @NewMinSalary = 30000.00, 
        @NewMaxSalary = 60000.00,
        @NewEmployeeContribution = 150.00,
        @NewEmployerContribution = 10.00,
        @UpdatedBy = 1001;
    PRINT '? Test 44.4 FAILED: Should have rejected invalid contribution rate';
END TRY
BEGIN CATCH
    PRINT '? Test 44.4 PASSED: Correctly rejected invalid contribution rate - ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- ========================================
-- TEST PROCEDURE 45: ApprovePolicyUpdate
-- ========================================
PRINT '========================================';
PRINT 'TEST 45: ApprovePolicyUpdate';
PRINT '========================================';

-- Create test payroll policy
IF NOT EXISTS (SELECT 1 FROM PayrollPolicy WHERE PolicyID = 1)
    INSERT INTO PayrollPolicy (PolicyID, effective_date, type, description)
    VALUES (1, NULL, 'Overtime', 'Overtime payment policy - pending approval');

-- Test 45.1: Successful Policy Approval
PRINT 'Test 45.1: Approve payroll policy update';
BEGIN TRY
    EXEC ApprovePolicyUpdate @PolicyID = 1, @ApprovedBy = 1001;
    PRINT '? Test 45.1 PASSED: Policy approved successfully';
END TRY
BEGIN CATCH
    PRINT '? Test 45.1 FAILED: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 45.2: Approve Another Policy
PRINT 'Test 45.2: Approve another payroll policy';
IF NOT EXISTS (SELECT 1 FROM PayrollPolicy WHERE PolicyID = 2)
    INSERT INTO PayrollPolicy (PolicyID, effective_date, type, description)
    VALUES (2, NULL, 'Bonus', 'Annual bonus policy - pending approval');

BEGIN TRY
    EXEC ApprovePolicyUpdate @PolicyID = 2, @ApprovedBy = 1001;
    PRINT '? Test 45.2 PASSED: Another policy approved successfully';
END TRY
BEGIN CATCH
    PRINT '? Test 45.2 FAILED: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 45.3: Corner Case - Non-existent Policy
PRINT 'Test 45.3: Attempt to approve non-existent policy';
BEGIN TRY
    EXEC ApprovePolicyUpdate @PolicyID = 99999, @ApprovedBy = 1001;
    PRINT '? Test 45.3 FAILED: Should have rejected non-existent policy';
END TRY
BEGIN CATCH
    PRINT '? Test 45.3 PASSED: Correctly rejected non-existent policy - ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 45.4: Corner Case - Non-HR Approver
PRINT 'Test 45.4: Attempt approval by non-HR administrator';
BEGIN TRY
    IF NOT EXISTS (SELECT 1 FROM PayrollPolicy WHERE PolicyID = 3)
        INSERT INTO PayrollPolicy (PolicyID, effective_date, type, description)
        VALUES (3, NULL, 'Deduction', 'Deduction policy - pending');
    
    EXEC ApprovePolicyUpdate @PolicyID = 3, @ApprovedBy = 1002;
    PRINT '? Test 45.4 FAILED: Should have rejected non-HR approver';
END TRY
BEGIN CATCH
    PRINT '? Test 45.4 PASSED: Correctly rejected non-HR approver - ' + ERROR_MESSAGE();
END CATCH
PRINT '';
