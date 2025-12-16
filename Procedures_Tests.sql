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

--Payroll Officer Procedure Tests

-- Insert Currency
INSERT INTO Currency (CurrencyCode, currency_name, exchange_rate, created_date, last_updated)
VALUES ('USD', 'US Dollar', 1.0000, GETDATE(), GETDATE());
GO

-- Insert Departments
INSERT INTO Department (DepartmentID, department_name, purpose, department_head_id)
VALUES (1, 'Engineering', 'Software Development', NULL),
       (2, 'Sales', 'Revenue Generation', NULL);
GO

-- Insert Positions
INSERT INTO Position (PositionID, position_title, responsibilities, status)
VALUES (1, 'Software Engineer', 'Develop software', 'Active'),
       (2, 'Sales Manager', 'Manage sales team', 'Active');
GO

-- Insert PayGrades
INSERT INTO PayGrade (PayGradeID, grade_name, min_salary, max_salary)
VALUES (1, 'Junior', 40000, 60000),
       (2, 'Senior', 80000, 120000);
GO

-- Insert TaxForms
INSERT INTO TaxForm (TaxFormID, jurisdiction, validity_period, form_content)
VALUES (1, 'US', '2025-12-31', 'W-4 Form'),
       (2, 'US', '2025-12-31', 'W-2 Form');
GO

-- Insert Contracts
INSERT INTO Contract (ContractID, type, start_date, end_date, current_state)
VALUES (1, 'Full-Time', '2024-01-01', NULL, 'Active'),
       (2, 'Part-Time', '2024-06-01', '2025-06-01', 'Active'),
       (3, 'Full-Time', '2023-01-01', NULL, 'Active');
GO

-- Insert FullTimeContract
INSERT INTO FullTimeContract (contract_id, leave_entitlement, insurance_eligibility, weekly_working_hours)
VALUES (1, 20, 1, 40),
       (3, 25, 1, 40);
GO

-- Insert PartTimeContract
INSERT INTO PartTimeContract (contract_id, working_hours, hourly_rate)
VALUES (2, 20, 25.00);
GO

-- Insert SalaryTypes
INSERT INTO SalaryType (SalaryTypeID, type, payment_frequency, currency)
VALUES (1, 'Monthly', 'Monthly', 'USD'),
       (2, 'Hourly', 'Weekly', 'USD'),
       (3, 'Contract', 'Milestone', 'USD');
GO

-- Insert MonthlySalaryType
INSERT INTO MonthlySalaryType (salary_type_id, tax_rule, contribution_scheme)
VALUES (1, 'Standard Tax', '401k');
GO

-- Insert HourlySalaryType
INSERT INTO HourlySalaryType (salary_type_id, hourly_rate, max_monthly_hours)
VALUES (2, 25.00, 160);
GO

-- Insert ContractSalaryType
INSERT INTO ContractSalaryType (salary_type_id, contract_value, installement_details)
VALUES (3, 100000.00, 'Quarterly payments');
GO

-- Insert Employees
INSERT INTO Employee (EmployeeID, first_name, last_name, national_id, date_of_birth, country_of_birth, 
                     phone, email, address, emergency_contact_name, emergency_contact_phone, relationship,
                     biography, profile_image, employment_progress, account_status, employment_status, 
                     hire_date, is_active, department_id, position_id, paygrade_id, taxform_id, 
                     manager_id, salary_type_id, contract_id, profile_completion_percentage)
VALUES 
(1, 'John', 'Doe', 'N001', '1990-05-15', 'USA', '555-0001', 'john.doe@company.com', 
 '123 Main St', 'Jane Doe', '555-0002', 'Spouse', 'Experienced developer', NULL, 
 'Active', 'Active', 'Full-Time', '2024-01-15', 1, 1, 1, 1, 1, NULL, 1, 1, 100),
(2, 'Sarah', 'Smith', 'N002', '1992-08-22', 'USA', '555-0003', 'sarah.smith@company.com',
 '456 Oak Ave', 'Bob Smith', '555-0004', 'Father', 'Sales professional', NULL,
 'Active', 'Active', 'Part-Time', '2024-06-01', 1, 2, 2, 2, 2, NULL, 2, 2, 100),
(3, 'Mike', 'Johnson', 'N003', '1988-03-10', 'USA', '555-0005', 'mike.johnson@company.com',
 '789 Elm St', 'Lisa Johnson', '555-0006', 'Spouse', 'Senior engineer', NULL,
 'Active', 'Active', 'Full-Time', '2023-01-15', 1, 1, 1, 2, 1, NULL, 1, 3, 100);
 GO

-- Insert PayrollPolicies
INSERT INTO PayrollPolicy (PolicyID, effective_date, type, description)
VALUES (1, '2024-01-01', 'Bonus', 'Annual Performance Bonus'),
       (2, '2024-01-01', 'Overtime', 'Overtime Compensation'),
       (3, '2024-01-01', 'Deduction', 'Lateness Penalty');
GO

-- Insert specific policy types
INSERT INTO BonusPolicy (policy_id, bonus_type, eligibility_criteria)
VALUES (1, 'Performance', 'Full-time employees with good performance');
GO

INSERT INTO OvertimePolicy (policy_id, weekday_rate_multiplier, weekend_rate_multiplier, max_hours_per_month)
VALUES (2, 1.5, 2.0, 40);
GO

INSERT INTO DeductionPolicy (policy_id, deduction_reason, calculation_mode)
VALUES (3, 'Lateness', 'Per Incident');
GO

-- Insert sample payroll records for testing
INSERT INTO Payroll (PayrollID, employee_id, taxes, period_start, period_end, base_amount, 
                     adjustments, contributions, actual_pay, net_salary, payment_date)
VALUES 
(1, 1, 500.00, '2024-11-01', '2024-11-30', 5000.00, 0.00, 200.00, 4300.00, 4300.00, '2024-12-01'),
(2, 2, 300.00, '2024-11-01', '2024-11-30', 4000.00, 0.00, 150.00, 3550.00, 3550.00, '2024-12-01'),
(3, 3, 800.00, '2024-11-01', '2024-11-30', 8000.00, 0.00, 400.00, 6800.00, 6800.00, '2024-12-01');
GO

-- Insert PayrollPeriod for testing
INSERT INTO PayrollPeriod (PayrollPeriodID, payroll_id, start_date, end_date, status)
VALUES 
(1, 1, '2024-11-01', '2024-11-30', 'Closed'),
(2, 2, '2024-11-01', '2024-11-30', 'Closed'),
(3, NULL, '2024-12-01', '2024-12-31', 'Open');
GO

-- Insert Leave types for testing
INSERT INTO Leave (LeaveID, leave_type, leave_description)
VALUES (1, 'Vacation', 'Annual vacation leave'),
       (2, 'Sick', 'Medical leave');
GO

-- Insert LeaveRequest for testing
INSERT INTO LeaveRequest (RequestID, employee_id, leave_id, justification, duration, approval_timing, status)
VALUES 
(1, 1, 1, 'Family vacation', 5, '2024-11-15', 'Approved'),
(2, 2, 2, 'Medical treatment', 3, '2024-11-20', 'Approved');
GO

-- Insert Attendance for testing
INSERT INTO Attendance (AttendanceID, employee_id, entry_time, exit_time, duration, login_method, logout_method, exception_id)
VALUES 
(1, 1, '09:00:00', '17:00:00', 480, 'Biometric', 'Biometric', NULL),
(2, 2, '09:15:00', '17:00:00', 465, 'Manual', 'Manual', NULL),
(3, 3, '09:00:00', '18:00:00', 540, 'Biometric', 'Biometric', NULL);
GO

-- Insert AttendanceCorrectionRequest for testing
INSERT INTO AttendanceCorrectionRequest (RequestID, employee_id, date, correction_type, reason, status, recommended_by)
VALUES 
(1, 1, '2024-11-25', 'Missed Punch', 'Forgot to punch out', 'Pending', 3),
(2, 2, '2024-11-26', 'Time Adjustment', 'System error', 'Pending', 3);

GO
-- Insert ApprovalWorkflow for testing
INSERT INTO ApprovalWorkflow (WorkflowID, workflow_type, threshold_amount, approved_role, created_by, status)
VALUES (1, 'Payroll Config', 10000.00, 'Admin', 1, 'Pending');
GO

PRINT 'Test data setup completed';
PRINT '';

-- ========================================
-- TEST 1: GeneratePayroll
-- ========================================
PRINT '========================================';
PRINT 'TEST 1: GeneratePayroll';
PRINT '========================================';

-- Test 1.1: Valid date range
PRINT 'Test 1.1: Generate payroll for December 2024';
EXEC GeneratePayroll @StartDate = '2024-12-01', @EndDate = '2024-12-31';
PRINT '';

-- Test 1.2: Invalid date range (start > end)
PRINT 'Test 1.2: Invalid date range (should fail)';
BEGIN TRY
    EXEC GeneratePayroll @StartDate = '2024-12-31', @EndDate = '2024-12-01';
END TRY
BEGIN CATCH
    PRINT 'Expected error: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 1.3: Future date range
PRINT 'Test 1.3: Generate payroll for future period';
EXEC GeneratePayroll @StartDate = '2025-01-01', @EndDate = '2025-01-31';
PRINT '';

-- ========================================
-- TEST 2: AdjustPayrollItem
-- ========================================
PRINT '========================================';
PRINT 'TEST 2: AdjustPayrollItem';
PRINT '========================================';

-- Test 2.1: Add allowance
PRINT 'Test 2.1: Add allowance to payroll';
EXEC AdjustPayrollItem @PayrollID = 1, @Type = 'Allowance', @Amount = 500.00, @Duration = 60, @Timezone = 'UTC';
SELECT 'Payroll after allowance:' AS Info, adjustments, net_salary FROM Payroll WHERE PayrollID = 1;
PRINT '';

-- Test 2.2: Add deduction
PRINT 'Test 2.2: Add deduction to payroll';
EXEC AdjustPayrollItem @PayrollID = 2, @Type = 'Deduction', @Amount = 200.00, @Duration = 30, @Timezone = 'EST';
SELECT 'Payroll after deduction:' AS Info, adjustments, net_salary FROM Payroll WHERE PayrollID = 2;
PRINT '';

-- Test 2.3: Invalid payroll ID (corner case)
PRINT 'Test 2.3: Invalid payroll ID (should fail)';
BEGIN TRY
    EXEC AdjustPayrollItem @PayrollID = 999, @Type = 'Allowance', @Amount = 100.00, @Duration = 30, @Timezone = 'UTC';
END TRY
BEGIN CATCH
    PRINT 'Expected error: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 2.4: Invalid type (corner case)
PRINT 'Test 2.4: Invalid type (should fail)';
BEGIN TRY
    EXEC AdjustPayrollItem @PayrollID = 1, @Type = 'Invalid', @Amount = 100.00, @Duration = 30, @Timezone = 'UTC';
END TRY
BEGIN CATCH
    PRINT 'Expected error: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- ========================================
-- TEST 3: CalculateNetSalary
-- ========================================
PRINT '========================================';
PRINT 'TEST 3: CalculateNetSalary';
PRINT '========================================';

-- Test 3.1: Calculate net salary for valid payroll
PRINT 'Test 3.1: Calculate net salary for payroll ID 1';
DECLARE @NetSal1 decimal(18,2);
EXEC CalculateNetSalary @PayrollID = 1, @NetSalary = @NetSal1 OUTPUT;
PRINT 'Calculated Net Salary: ' + CAST(@NetSal1 AS varchar(20));
PRINT '';

-- Test 3.2: Calculate net salary for another payroll
PRINT 'Test 3.2: Calculate net salary for payroll ID 3';
DECLARE @NetSal2 decimal(18,2);
EXEC CalculateNetSalary @PayrollID = 3, @NetSalary = @NetSal2 OUTPUT;
PRINT 'Calculated Net Salary: ' + CAST(@NetSal2 AS varchar(20));
PRINT '';

-- Test 3.3: Invalid payroll ID (corner case)
PRINT 'Test 3.3: Invalid payroll ID (should fail)';
BEGIN TRY
    DECLARE @NetSal3 decimal(18,2);
    EXEC CalculateNetSalary @PayrollID = 999, @NetSalary = @NetSal3 OUTPUT;
END TRY
BEGIN CATCH
    PRINT 'Expected error: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- ========================================
-- TEST 4: ApplyPayrollPolicy
-- ========================================
PRINT '========================================';
PRINT 'TEST 4: ApplyPayrollPolicy';
PRINT '========================================';

-- Test 4.1: Apply bonus policy
PRINT 'Test 4.1: Apply bonus policy to payroll';
EXEC ApplyPayrollPolicy @PolicyID = 1, @PayrollID = 1, @Type = 'Bonus', @Description = 'Performance bonus';
SELECT 'Payroll after bonus:' AS Info, adjustments, net_salary FROM Payroll WHERE PayrollID = 1;
PRINT '';

-- Test 4.2: Apply overtime policy
PRINT 'Test 4.2: Apply overtime policy to payroll';
EXEC ApplyPayrollPolicy @PolicyID = 2, @PayrollID = 2, @Type = 'Overtime', @Description = 'Overtime pay';
SELECT 'Payroll after overtime:' AS Info, adjustments, net_salary FROM Payroll WHERE PayrollID = 2;
PRINT '';

-- Test 4.3: Invalid policy ID (corner case)
PRINT 'Test 4.3: Invalid policy ID (should fail)';
BEGIN TRY
    EXEC ApplyPayrollPolicy @PolicyID = 999, @PayrollID = 1, @Type = 'Bonus', @Description = 'Test';
END TRY
BEGIN CATCH
    PRINT 'Expected error: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- ========================================
-- TEST 5: GetMonthlyPayrollSummary
-- ========================================
PRINT '========================================';
PRINT 'TEST 5: GetMonthlyPayrollSummary';
PRINT '========================================';

-- Test 5.1: Valid month and year
PRINT 'Test 5.1: Get payroll summary for November 2024';
EXEC GetMonthlyPayrollSummary @Month = 11, @Year = 2024;
PRINT '';

-- Test 5.2: Month with no payroll data
PRINT 'Test 5.2: Get payroll summary for January 2025 (no data)';
EXEC GetMonthlyPayrollSummary @Month = 1, @Year = 2025;
PRINT '';

-- Test 5.3: Invalid month (corner case)
PRINT 'Test 5.3: Invalid month (should fail)';
BEGIN TRY
    EXEC GetMonthlyPayrollSummary @Month = 13, @Year = 2024;
END TRY
BEGIN CATCH
    PRINT 'Expected error: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- ========================================
-- TEST 6: GetEmployeePayrollHistory
-- ========================================
PRINT '========================================';
PRINT 'TEST 6: GetEmployeePayrollHistory';
PRINT '========================================';

-- Test 6.1: Valid employee with history
PRINT 'Test 6.1: Get payroll history for employee 1';
EXEC GetEmployeePayrollHistory @EmployeeID = 1;
PRINT '';

-- Test 6.2: Valid employee with history
PRINT 'Test 6.2: Get payroll history for employee 3';
EXEC GetEmployeePayrollHistory @EmployeeID = 3;
PRINT '';

-- Test 6.3: Invalid employee ID (corner case)
PRINT 'Test 6.3: Invalid employee ID (should fail)';
BEGIN TRY
    EXEC GetEmployeePayrollHistory @EmployeeID = 999;
END TRY
BEGIN CATCH
    PRINT 'Expected error: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- ========================================
-- TEST 8 GetBonusEligibleEmployees
-- ========================================
PRINT '========================================';
PRINT 'TEST 7: GetBonusEligibleEmployees';
PRINT '========================================';

-- Test 8.1: Full-time employees
PRINT 'Test 7.1: Get full-time employees eligible for bonus';
EXEC GetBonusEligibleEmployees @EligibilityCriteria = 'FullTime';
PRINT '';

-- Test 8.2: Employees with tenure > 1 year
PRINT 'Test 7.2: Get employees with tenure > 1 year';
EXEC GetBonusEligibleEmployees @EligibilityCriteria = 'TenureGreaterThan1Year';
PRINT '';

-- Test 8.3: Default criteria (all active)
PRINT 'Test 7.3: Get all active employees (default)';
EXEC GetBonusEligibleEmployees @EligibilityCriteria = 'AllActive';
PRINT '';

-- ========================================
-- TEST 9 UpdateSalaryType
-- ========================================
PRINT '========================================';
PRINT 'TEST 8: UpdateSalaryType';
PRINT '========================================';

-- Test 9.1: Valid salary type update
PRINT 'Test 8.1: Update employee 2 salary type to Monthly';
SELECT 'Before update:' AS Info, salary_type_id FROM Employee WHERE EmployeeID = 2;
EXEC UpdateSalaryType @EmployeeID = 2, @SalaryTypeID = 1;
SELECT 'After update:' AS Info, salary_type_id FROM Employee WHERE EmployeeID = 2;
PRINT '';

-- Test 9.2: Invalid employee ID (corner case)
PRINT 'Test 8.2: Invalid employee ID (should fail)';
BEGIN TRY
    EXEC UpdateSalaryType @EmployeeID = 999, @SalaryTypeID = 1;
END TRY
BEGIN CATCH
    PRINT 'Expected error: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 9.3: Invalid salary type ID (corner case)
PRINT 'Test 8.3: Invalid salary type ID (should fail)';
BEGIN TRY
    EXEC UpdateSalaryType @EmployeeID = 1, @SalaryTypeID = 999;
END TRY
BEGIN CATCH
    PRINT 'Expected error: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- ========================================
-- TEST 10: GetPayrollByDepartment
-- ========================================
PRINT '========================================';
PRINT 'TEST 10: GetPayrollByDepartment';
PRINT '========================================';

-- Test 10.1: Valid department with payroll data
PRINT 'Test 10.1: Get payroll summary for Engineering department';
EXEC GetPayrollByDepartment @DepartmentID = 1, @Month = 11, @Year = 2024;
PRINT '';

-- Test 10.2: Department with no payroll data
PRINT 'Test 10.2: Get payroll summary for department with no data';
EXEC GetPayrollByDepartment @DepartmentID = 2, @Month = 11, @Year = 2024;
PRINT '';

-- Test 10.3: Invalid department ID (corner case)
PRINT 'Test 10.3: Invalid department ID (should fail)';
BEGIN TRY
    EXEC GetPayrollByDepartment @DepartmentID = 999, @Month = 11, @Year = 2024;
END TRY
BEGIN CATCH
    PRINT 'Expected error: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 10.4: Invalid month (corner case)
PRINT 'Test 10.4: Invalid month (should fail)';
BEGIN TRY
    EXEC GetPayrollByDepartment @DepartmentID = 1, @Month = 15, @Year = 2024;
END TRY
BEGIN CATCH
    PRINT 'Expected error: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- ========================================
-- TEST 11: ValidateAttendanceBeforePayroll
-- ========================================
PRINT '========================================';
PRINT 'TEST 11: ValidateAttendanceBeforePayroll';
PRINT '========================================';

-- Test 11.1: Valid payroll period with unresolved punches
PRINT 'Test 11.1: Check for unresolved attendance issues';
EXEC ValidateAttendanceBeforePayroll @PayrollPeriodID = 3;
PRINT '';

-- Test 11.2: Payroll period with no issues
PRINT 'Test 11.2: Check completed payroll period';
EXEC ValidateAttendanceBeforePayroll @PayrollPeriodID = 1;
PRINT '';

-- Test 11.3: Invalid payroll period ID (corner case)
PRINT 'Test 11.3: Invalid payroll period ID (should fail)';
BEGIN TRY
    EXEC ValidateAttendanceBeforePayroll @PayrollPeriodID = 999;
END TRY
BEGIN CATCH
    PRINT 'Expected error: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- ========================================
-- TEST 12: SyncAttendanceToPayroll
-- ========================================
PRINT '========================================';
PRINT 'TEST 12: SyncAttendanceToPayroll';
PRINT '========================================';

-- Test 12.1: Sync valid date
PRINT 'Test 12.1: Sync attendance for today';
EXEC SyncAttendanceToPayroll @SyncDate = '2024-11-29';
PRINT '';

-- Test 12.2: Sync past date
PRINT 'Test 12.2: Sync attendance for past date';
EXEC SyncAttendanceToPayroll @SyncDate = '2024-11-01';
PRINT '';

-- Test 12.3: Future date (corner case - should fail)
PRINT 'Test 12.3: Future date sync (should fail)';
BEGIN TRY
    EXEC SyncAttendanceToPayroll @SyncDate = '2025-12-31';
END TRY
BEGIN CATCH
    PRINT 'Expected error: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- ========================================
-- TEST 13: SyncApprovedPermissionsToPayroll
-- ========================================
PRINT '========================================';
PRINT 'TEST 13: SyncApprovedPermissionsToPayroll';
PRINT '========================================';

-- Test 13.1: Sync approved permissions for valid period
PRINT 'Test 13.1: Sync approved leave requests';
EXEC SyncApprovedPermissionsToPayroll @PayrollPeriodID = 1;
PRINT '';

-- Test 13.2: Sync for period with no approved leaves
PRINT 'Test 13.2: Sync for open period';
EXEC SyncApprovedPermissionsToPayroll @PayrollPeriodID = 3;
PRINT '';

-- Test 13.3: Invalid payroll period (corner case)
PRINT 'Test 13.3: Invalid payroll period (should fail)';
BEGIN TRY
    EXEC SyncApprovedPermissionsToPayroll @PayrollPeriodID = 999;
END TRY
BEGIN CATCH
    PRINT 'Expected error: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- ========================================
-- TEST 14: ConfigurePayGrades
-- ========================================
PRINT '========================================';
PRINT 'TEST 14: ConfigurePayGrades';
PRINT '========================================';

-- Test 14.1: Create new pay grade
PRINT 'Test 14.1: Create new pay grade "Manager"';
EXEC ConfigurePayGrades @GradeName = 'Manager', @MinSalary = 70000.00, @MaxSalary = 100000.00;
PRINT '';

-- Test 14.2: Update existing pay grade
PRINT 'Test 14.2: Update existing pay grade "Junior"';
EXEC ConfigurePayGrades @GradeName = 'Junior', @MinSalary = 45000.00, @MaxSalary = 65000.00;
SELECT 'Updated grade:' AS Info, * FROM PayGrade WHERE grade_name = 'Junior';
PRINT '';

-- Test 14.3: Invalid salary range (corner case)
PRINT 'Test 14.3: Invalid salary range (should fail)';
BEGIN TRY
    EXEC ConfigurePayGrades @GradeName = 'Invalid', @MinSalary = 100000.00, @MaxSalary = 50000.00;
END TRY
BEGIN CATCH
    PRINT 'Expected error: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 14.4: Negative salary (corner case)
PRINT 'Test 14.4: Negative salary (should fail)';
BEGIN TRY
    EXEC ConfigurePayGrades @GradeName = 'Test', @MinSalary = -1000.00, @MaxSalary = 50000.00;
END TRY
BEGIN CATCH
    PRINT 'Expected error: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- ========================================
-- TEST 15: ConfigureShiftAllowances
-- ========================================
PRINT '========================================';
PRINT 'TEST 15: ConfigureShiftAllowances';
PRINT '========================================';

-- Test 15.1: Create night shift allowance
PRINT 'Test 15.1: Configure night shift allowance';
EXEC ConfigureShiftAllowances @ShiftType = 'Night', @AllowanceName = 'Night Differential', @Amount = 150.00;
PRINT '';

-- Test 15.2: Create weekend allowance
PRINT 'Test 15.2: Configure weekend shift allowance';
EXEC ConfigureShiftAllowances @ShiftType = 'Weekend', @AllowanceName = 'Weekend Premium', @Amount = 200.00;
PRINT '';

-- Test 15.3: Negative amount (corner case)
PRINT 'Test 15.3: Negative allowance amount (should fail)';
BEGIN TRY
    EXEC ConfigureShiftAllowances @ShiftType = 'Test', @AllowanceName = 'Test', @Amount = -50.00;
END TRY
BEGIN CATCH
    PRINT 'Expected error: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- ========================================
-- TEST 16: EnableMultiCurrencyPayroll
-- ========================================
PRINT '========================================';
PRINT 'TEST 16: EnableMultiCurrencyPayroll';
PRINT '========================================';

-- Test 16.1: Add new currency
PRINT 'Test 16.1: Enable EUR currency';
EXEC EnableMultiCurrencyPayroll @CurrencyCode = 'EUR', @ExchangeRate = 0.92;
PRINT '';

-- Test 16.2: Update existing currency
PRINT 'Test 16.2: Update USD exchange rate';
EXEC EnableMultiCurrencyPayroll @CurrencyCode = 'USD', @ExchangeRate = 1.00;
SELECT 'Updated currency:' AS Info, * FROM Currency WHERE CurrencyCode = 'USD';
PRINT '';

-- Test 16.3: Invalid exchange rate (corner case)
PRINT 'Test 16.3: Invalid exchange rate (should fail)';
BEGIN TRY
    EXEC EnableMultiCurrencyPayroll @CurrencyCode = 'GBP', @ExchangeRate = -0.5;
END TRY
BEGIN CATCH
    PRINT 'Expected error: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- ========================================
-- TEST 17: ManageTaxRules
-- ========================================
PRINT '========================================';
PRINT 'TEST 17: ManageTaxRules';
PRINT '========================================';

-- Test 17.1: Create new tax rule
PRINT 'Test 17.1: Create tax rule for Canada';
EXEC ManageTaxRules @TaxRuleName = 'Canadian Federal Tax', @CountryCode = 'CA', @Rate = 15.00, @Exemption = 12000.00;
PRINT '';

-- Test 17.2: Update existing tax rule
PRINT 'Test 17.2: Update US tax rule';
EXEC ManageTaxRules @TaxRuleName = 'US Federal Tax Updated', @CountryCode = 'US', @Rate = 22.00, @Exemption = 13850.00;
SELECT 'Updated tax form:' AS Info, TaxFormID, jurisdiction, form_content FROM TaxForm WHERE jurisdiction = 'US';
PRINT '';

-- Test 17.3: Invalid tax rate (corner case)
PRINT 'Test 17.3: Invalid tax rate (should fail)';
BEGIN TRY
    EXEC ManageTaxRules @TaxRuleName = 'Invalid', @CountryCode = 'XX', @Rate = 150.00, @Exemption = 1000.00;
END TRY
BEGIN CATCH
    PRINT 'Expected error: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- ========================================
-- TEST 18: ApprovePayrollConfigChanges
-- ========================================
PRINT '========================================';
PRINT 'TEST 18: ApprovePayrollConfigChanges';
PRINT '========================================';

-- Test 18.1: Approve configuration
PRINT 'Test 18.1: Approve payroll configuration';
EXEC ApprovePayrollConfigChanges @ConfigID = 1, @ApproverID = 1, @Status = 'Approved';
SELECT 'Approval status:' AS Info, WorkflowID, status FROM ApprovalWorkflow WHERE WorkflowID = 1;
PRINT '';

-- Test 18.2: Reject configuration
PRINT 'Test 18.2: Reject payroll configuration';
EXEC ApprovePayrollConfigChanges @ConfigID = 1, @ApproverID = 3, @Status = 'Rejected';
SELECT 'Rejection status:' AS Info, WorkflowID, status FROM ApprovalWorkflow WHERE WorkflowID = 1;
PRINT '';

-- Test 18.3: Invalid approver (corner case)
PRINT 'Test 18.3: Invalid approver ID (should fail)';
BEGIN TRY
    EXEC ApprovePayrollConfigChanges @ConfigID = 1, @ApproverID = 999, @Status = 'Approved';
END TRY
BEGIN CATCH
    PRINT 'Expected error: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 18.4: Invalid status (corner case)
PRINT 'Test 18.4: Invalid status (should fail)';
BEGIN TRY
    EXEC ApprovePayrollConfigChanges @ConfigID = 1, @ApproverID = 1, @Status = 'InvalidStatus';
END TRY
BEGIN CATCH
    PRINT 'Expected error: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- ========================================
-- TEST 19: ConfigureSigningBonus
-- ========================================
PRINT '========================================';
PRINT 'TEST 19: ConfigureSigningBonus';
PRINT '========================================';

-- Test 19.1: Configure signing bonus for new hire
PRINT 'Test 19.1: Configure signing bonus for employee 1';
EXEC ConfigureSigningBonus @EmployeeID = 1, @BonusAmount = 5000.00, @EffectiveDate = '2025-01-01';
PRINT '';

-- Test 19.2: Configure higher signing bonus
PRINT 'Test 19.2: Configure signing bonus for employee 3';
EXEC ConfigureSigningBonus @EmployeeID = 3, @BonusAmount = 10000.00, @EffectiveDate = '2025-02-01';
PRINT '';

-- Test 19.3: Invalid employee ID (corner case)
PRINT 'Test 19.3: Invalid employee ID (should fail)';
BEGIN TRY
    EXEC ConfigureSigningBonus @EmployeeID = 999, @BonusAmount = 5000.00, @EffectiveDate = '2025-01-01';
END TRY
BEGIN CATCH
    PRINT 'Expected error: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 19.4: Past effective date (corner case)
PRINT 'Test 19.4: Past effective date (should fail)';
BEGIN TRY
    EXEC ConfigureSigningBonus @EmployeeID = 1, @BonusAmount = 5000.00, @EffectiveDate = '2020-01-01';
END TRY
BEGIN CATCH
    PRINT 'Expected error: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- ========================================
-- TEST 20: ConfigureTerminationBenefits
-- ========================================
PRINT '========================================';
PRINT 'TEST 20: ConfigureTerminationBenefits';
PRINT '========================================';

-- Test 20.1: Configure termination with compensation
PRINT 'Test 20.1: Configure termination benefits for employee';
EXEC ConfigureTerminationBenefits @EmployeeID = 2, @CompensationAmount = 10000.00, @EffectiveDate = '2025-01-15', @Reason = 'Voluntary Resignation';
SELECT 'Termination record:' AS Info, * FROM Termination WHERE contract_id = 2;
SELECT 'Employee status:' AS Info, EmployeeID, is_active, employment_status FROM Employee WHERE EmployeeID = 2;
PRINT '';

-- Test 20.2: Configure termination with different reason
PRINT 'Test 20.2: Configure termination for another employee';
EXEC ConfigureTerminationBenefits @EmployeeID = 3, @CompensationAmount = 15000.00, @EffectiveDate = '2025-02-01', @Reason = 'Retirement';
PRINT '';

-- Test 20.3: Invalid employee ID (corner case)
PRINT 'Test 20.3: Invalid employee ID (should fail)';
BEGIN TRY
    EXEC ConfigureTerminationBenefits @EmployeeID = 999, @CompensationAmount = 5000.00, @EffectiveDate = '2025-01-01', @Reason = 'Test';
END TRY
BEGIN CATCH
    PRINT 'Expected error: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 20.4: Past effective date (corner case)
PRINT 'Test 20.4: Past effective date (should fail)';
BEGIN TRY
    EXEC ConfigureTerminationBenefits @EmployeeID = 1, @CompensationAmount = 5000.00, @EffectiveDate = '2020-01-01', @Reason = 'Test';
END TRY
BEGIN CATCH
    PRINT 'Expected error: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- ========================================
-- TEST 21: ConfigureInsuranceBrackets
-- ========================================
PRINT '========================================';
PRINT 'TEST 21: ConfigureInsuranceBrackets';
PRINT '========================================';

-- Test 21.1: Configure basic insurance bracket
PRINT 'Test 21.1: Configure health insurance bracket';
EXEC ConfigureInsuranceBrackets @InsuranceType = 'Health', @MinSalary = 30000.00, @MaxSalary = 60000.00, @EmployeeContribution = 5.00, @EmployerContribution = 10.00;
PRINT '';

-- Test 21.2: Configure premium insurance bracket
PRINT 'Test 21.2: Configure premium insurance bracket';
EXEC ConfigureInsuranceBrackets @InsuranceType = 'Premium Health', @MinSalary = 60000.00, @MaxSalary = 120000.00, @EmployeeContribution = 3.00, @EmployerContribution = 12.00;
SELECT 'Insurance records:' AS Info, InsuranceID, type, contribution_rate FROM Insurance;
PRINT '';

-- Test 21.3: Invalid salary range (corner case)
PRINT 'Test 21.3: Invalid salary range (should fail)';
BEGIN TRY
    EXEC ConfigureInsuranceBrackets @InsuranceType = 'Test', @MinSalary = 60000.00, @MaxSalary = 30000.00, @EmployeeContribution = 5.00, @EmployerContribution = 10.00;
END TRY
BEGIN CATCH
    PRINT 'Expected error: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 21.4: Invalid contribution percentage (corner case)
PRINT 'Test 21.4: Invalid contribution percentage (should fail)';
BEGIN TRY
    EXEC ConfigureInsuranceBrackets @InsuranceType = 'Test', @MinSalary = 30000.00, @MaxSalary = 60000.00, @EmployeeContribution = 150.00, @EmployerContribution = 10.00;
END TRY
BEGIN CATCH
    PRINT 'Expected error: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- ========================================
-- TEST 22: UpdateInsuranceBrackets
-- ========================================
PRINT '========================================';
PRINT 'TEST 22: UpdateInsuranceBrackets';
PRINT '========================================';

-- Test 22.1: Update existing insurance bracket
PRINT 'Test 22.1: Update insurance bracket 1';
DECLARE @BracketID1 int = (SELECT TOP 1 InsuranceID FROM Insurance ORDER BY InsuranceID);
SELECT 'Before update:' AS Info, InsuranceID, contribution_rate FROM Insurance WHERE InsuranceID = @BracketID1;
EXEC UpdateInsuranceBrackets @BracketID = @BracketID1, @MinSalary = 30000.00, @MaxSalary = 65000.00, @EmployeeContribution = 6.00, @EmployerContribution = 11.00;
SELECT 'After update:' AS Info, InsuranceID, contribution_rate FROM Insurance WHERE InsuranceID = @BracketID1;
PRINT '';

-- Test 22.2: Update another bracket
PRINT 'Test 22.2: Update second insurance bracket';
DECLARE @BracketID2 int = (SELECT TOP 1 InsuranceID FROM Insurance ORDER BY InsuranceID DESC);
EXEC UpdateInsuranceBrackets @BracketID = @BracketID2, @MinSalary = 65000.00, @MaxSalary = 130000.00, @EmployeeContribution = 4.00, @EmployerContribution = 13.00;
PRINT '';

-- Test 22.3: Invalid bracket ID (corner case)
PRINT 'Test 22.3: Invalid bracket ID (should fail)';
BEGIN TRY
    EXEC UpdateInsuranceBrackets @BracketID = 999, @MinSalary = 30000.00, @MaxSalary = 60000.00, @EmployeeContribution = 5.00, @EmployerContribution = 10.00;
END TRY
BEGIN CATCH
    PRINT 'Expected error: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- ========================================
-- TEST 23: ConfigurePayrollPolicies
-- ========================================
PRINT '========================================';
PRINT 'TEST 23: ConfigurePayrollPolicies';
PRINT '========================================';

-- Test 23.1: Configure bonus policy
PRINT 'Test 23.1: Configure annual bonus policy';
EXEC ConfigurePayrollPolicies @PolicyType = 'Bonus', @PolicyDetails = 'Annual performance bonus based on KPIs', @EffectiveDate = '2025-01-01';
PRINT '';

-- Test 23.2: Configure deduction policy
PRINT 'Test 23.2: Configure absence deduction policy';
EXEC ConfigurePayrollPolicies @PolicyType = 'Deduction', @PolicyDetails = 'Absence without approval deduction policy', @EffectiveDate = '2025-01-01';
PRINT '';

-- Test 23.3: Configure overtime policy
PRINT 'Test 23.3: Configure enhanced overtime policy';
EXEC ConfigurePayrollPolicies @PolicyType = 'Overtime', @PolicyDetails = 'Enhanced overtime compensation for critical projects', @EffectiveDate = '2025-01-15';
SELECT 'Policies created:' AS Info, PolicyID, type, description FROM PayrollPolicy WHERE effective_date >= '2025-01-01';
PRINT '';

-- Test 23.4: Invalid policy type (corner case)
PRINT 'Test 23.4: Invalid policy type (should fail)';
BEGIN TRY
    EXEC ConfigurePayrollPolicies @PolicyType = 'InvalidType', @PolicyDetails = 'Test', @EffectiveDate = '2025-01-01';
END TRY
BEGIN CATCH
    PRINT 'Expected error: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- ========================================
-- TEST 24: DefinePayGrades
-- ========================================
PRINT '========================================';
PRINT 'TEST 24: DefinePayGrades';
PRINT '========================================';

-- Test 24.1: Define new pay grade
PRINT 'Test 24.1: Define Executive pay grade';
EXEC DefinePayGrades @GradeName = 'Executive', @MinSalary = 150000.00, @MaxSalary = 300000.00, @CreatedBy = 1;
PRINT '';

-- Test 24.2: Define another pay grade
PRINT 'Test 24.2: Define Lead pay grade';
EXEC DefinePayGrades @GradeName = 'Lead', @MinSalary = 90000.00, @MaxSalary = 150000.00, @CreatedBy = 1;
SELECT 'Pay grades:' AS Info, PayGradeID, grade_name, min_salary, max_salary FROM PayGrade WHERE grade_name IN ('Executive', 'Lead');
PRINT '';

-- Test 24.3: Duplicate grade name (corner case)
PRINT 'Test 24.3: Duplicate grade name (should fail)';
BEGIN TRY
    EXEC DefinePayGrades @GradeName = 'Executive', @MinSalary = 150000.00, @MaxSalary = 300000.00, @CreatedBy = 1;
END TRY
BEGIN CATCH
    PRINT 'Expected error: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 24.4: Invalid creator (corner case)
PRINT 'Test 24.4: Invalid creator employee (should fail)';
BEGIN TRY
    EXEC DefinePayGrades @GradeName = 'Test', @MinSalary = 50000.00, @MaxSalary = 80000.00, @CreatedBy = 999;
END TRY
BEGIN CATCH
    PRINT 'Expected error: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- ========================================
-- TEST 25: ConfigureEscalationWorkflow
-- ========================================
PRINT '========================================';
PRINT 'TEST 25: ConfigureEscalationWorkflow';
PRINT '========================================';

-- Test 25.1: Configure manager approval threshold
PRINT 'Test 25.1: Configure manager approval workflow';
EXEC ConfigureEscalationWorkflow @ThresholdAmount = 1000.00, @ApproverRole = 'Manager', @CreatedBy = 1;
PRINT '';

-- Test 25.2: Configure director approval threshold
PRINT 'Test 25.2: Configure director approval workflow';
EXEC ConfigureEscalationWorkflow @ThresholdAmount = 10000.00, @ApproverRole = 'Director', @CreatedBy = 1;
PRINT '';

-- Test 25.3: Configure CFO approval threshold
PRINT 'Test 25.3: Configure CFO approval workflow';
EXEC ConfigureEscalationWorkflow @ThresholdAmount = 50000.00, @ApproverRole = 'CFO', @CreatedBy = 1;
SELECT 'Workflows:' AS Info, WorkflowID, workflow_type, threshold_amount, approved_role FROM ApprovalWorkflow WHERE workflow_type = 'Payroll Escalation';
PRINT '';

-- Test 25.4: Invalid approver role (corner case)
PRINT 'Test 25.4: Invalid approver role (should fail)';
BEGIN TRY
    EXEC ConfigureEscalationWorkflow @ThresholdAmount = 5000.00, @ApproverRole = 'InvalidRole', @CreatedBy = 1;
END TRY
BEGIN CATCH
    PRINT 'Expected error: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- ========================================
-- TEST 26: DefinePayType
-- ========================================
PRINT '========================================';
PRINT 'TEST 26: DefinePayType';
PRINT '========================================';

-- Test 26.1: Define monthly pay type
PRINT 'Test 26.1: Define monthly pay type for employee 1';
SELECT 'Before:' AS Info, EmployeeID, salary_type_id FROM Employee WHERE EmployeeID = 1;
EXEC DefinePayType @EmployeeID = 1, @PayType = 'Monthly', @EffectiveDate = '2025-01-01';
SELECT 'After:' AS Info, e.EmployeeID, e.salary_type_id, st.type FROM Employee e LEFT JOIN SalaryType st ON e.salary_type_id = st.SalaryTypeID WHERE e.EmployeeID = 1;
PRINT '';

-- Test 26.2: Define hourly pay type
PRINT 'Test 26.2: Define hourly pay type for new employee';
-- First restore employee 2 for testing
UPDATE Employee SET is_active = 1, employment_status = 'Active' WHERE EmployeeID = 2;
EXEC DefinePayType @EmployeeID = 2, @PayType = 'Hourly', @EffectiveDate = '2025-01-01';
PRINT '';

-- Test 26.3: Define weekly pay type
PRINT 'Test 26.3: Define weekly pay type';
-- Restore employee 3 for testing
UPDATE Employee SET is_active = 1, employment_status = 'Active' WHERE EmployeeID = 3;
EXEC DefinePayType @EmployeeID = 3, @PayType = 'Weekly', @EffectiveDate = '2025-01-01';
PRINT '';

-- Test 26.4: Invalid pay type (corner case)
PRINT 'Test 26.4: Invalid pay type (should fail)';
BEGIN TRY
    EXEC DefinePayType @EmployeeID = 1, @PayType = 'InvalidType', @EffectiveDate = '2025-01-01';
END TRY
BEGIN CATCH
    PRINT 'Expected error: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- ========================================
-- TEST 27: ConfigureOvertimeRules
-- ========================================
PRINT '========================================';
PRINT 'TEST 27: ConfigureOvertimeRules';
PRINT '========================================';

-- Test 27.1: Configure weekday overtime
PRINT 'Test 27.1: Configure weekday overtime rules';
EXEC ConfigureOvertimeRules @DayType = 'Weekday', @Multiplier = 1.5, @HoursPerMonth = 40;
PRINT '';

-- Test 27.2: Configure weekend overtime
PRINT 'Test 27.2: Configure weekend overtime rules';
EXEC ConfigureOvertimeRules @DayType = 'Weekend', @Multiplier = 2.0, @HoursPerMonth = 30;
PRINT '';

-- Test 27.3: Configure holiday overtime
PRINT 'Test 27.3: Configure holiday overtime rules';
EXEC ConfigureOvertimeRules @DayType = 'Holiday', @Multiplier = 3.0, @HoursPerMonth = 20;
SELECT 'Overtime policies:' AS Info, op.policy_id, pp.description, op.weekday_rate_multiplier, op.weekend_rate_multiplier, op.max_hours_per_month 
FROM OvertimePolicy op 
INNER JOIN PayrollPolicy pp ON op.policy_id = pp.PolicyID 
WHERE pp.type = 'Overtime' AND pp.effective_date >= GETDATE();
PRINT '';

-- Test 27.4: Invalid multiplier (corner case)
PRINT 'Test 27.4: Invalid multiplier (should fail)';
BEGIN TRY
    EXEC ConfigureOvertimeRules @DayType = 'Weekday', @Multiplier = 10.0, @HoursPerMonth = 40;
END TRY
BEGIN CATCH
    PRINT 'Expected error: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- ========================================
-- TEST 28: ConfigureShiftAllowance
-- ========================================
PRINT '========================================';
PRINT 'TEST 28: ConfigureShiftAllowance';
PRINT '========================================';

-- Test 28.1: Configure night shift allowance
PRINT 'Test 28.1: Configure night shift allowance';
EXEC ConfigureShiftAllowance @ShiftType = 'Night', @AllowanceAmount = 250.00, @CreatedBy = 1;
PRINT '';

-- Test 28.2: Configure hazard pay
PRINT 'Test 28.2: Configure hazard pay allowance';
EXEC ConfigureShiftAllowance @ShiftType = 'Hazard', @AllowanceAmount = 500.00, @CreatedBy = 1;
PRINT '';

-- Test 28.3: Configure remote work allowance
PRINT 'Test 28.3: Configure remote work allowance';
EXEC ConfigureShiftAllowance @ShiftType = 'Remote', @AllowanceAmount = 100.00, @CreatedBy = 1;
SELECT 'Shift allowances:' AS Info, PolicyID, type, description FROM PayrollPolicy WHERE type = 'Allowance' AND description LIKE '%Shift Allowance%';
PRINT '';

-- Test 28.4: Invalid shift type (corner case)
PRINT 'Test 28.4: Invalid shift type (should fail)';
BEGIN TRY
    EXEC ConfigureShiftAllowance @ShiftType = 'InvalidShift', @AllowanceAmount = 100.00, @CreatedBy = 1;
END TRY
BEGIN CATCH
    PRINT 'Expected error: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- ========================================
-- TEST 30: ConfigureSigningBonusPolicy
-- ========================================
PRINT '========================================';
PRINT 'TEST 30: ConfigureSigningBonusPolicy';
PRINT '========================================';

-- Test 30.1: Configure signing bonus policy
PRINT 'Test 30.1: Configure signing bonus policy for new hires';
EXEC ConfigureSigningBonusPolicy @BonusType = 'Signing', @Amount = 5000.00, @EligibilityCriteria = 'All full-time new hires with engineering positions';
PRINT '';

-- Test 30.2: Configure retention bonus policy
PRINT 'Test 30.2: Configure retention bonus policy';
EXEC ConfigureSigningBonusPolicy @BonusType = 'Retention', @Amount = 10000.00, @EligibilityCriteria = 'Employees completing 5 years of service';
PRINT '';

-- Test 30.3: Configure relocation bonus policy
PRINT 'Test 30.3: Configure relocation bonus policy';
EXEC ConfigureSigningBonusPolicy @BonusType = 'Relocation', @Amount = 7500.00, @EligibilityCriteria = 'Employees relocating more than 500 miles';
SELECT 'Bonus policies:' AS Info, PolicyID, type, description FROM PayrollPolicy WHERE type = 'Bonus' AND effective_date >= CAST(GETDATE() AS date);
PRINT '';

-- Test 30.4: Invalid bonus type (corner case)
PRINT 'Test 30.4: Invalid bonus type (should fail)';
BEGIN TRY
    EXEC ConfigureSigningBonusPolicy @BonusType = 'InvalidBonus', @Amount = 5000.00, @EligibilityCriteria = 'Test';
END TRY
BEGIN CATCH
    PRINT 'Expected error: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- ========================================
-- TEST 32: GenerateTaxStatement
-- ========================================
PRINT '========================================';
PRINT 'TEST 32: GenerateTaxStatement';
PRINT '========================================';

-- Test 32.1: Generate tax statement for employee 1
PRINT 'Test 32.1: Generate tax statement for employee 1 for 2024';
EXEC GenerateTaxStatement @EmployeeID = 1, @TaxYear = 2024;
PRINT '';

-- Test 32.2: Generate tax statement for employee 3
PRINT 'Test 32.2: Generate tax statement for employee 3 for 2024';
EXEC GenerateTaxStatement @EmployeeID = 3, @TaxYear = 2024;
PRINT '';

-- Test 32.3: Generate tax statement for future year
PRINT 'Test 32.3: Generate tax statement for 2025';
EXEC GenerateTaxStatement @EmployeeID = 1, @TaxYear = 2025;
PRINT '';

-- Test 32.4: Invalid employee ID (corner case)
PRINT 'Test 32.4: Invalid employee ID (should fail)';
BEGIN TRY
    EXEC GenerateTaxStatement @EmployeeID = 999, @TaxYear = 2024;
END TRY
BEGIN CATCH
    PRINT 'Expected error: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- ========================================
-- TEST 33: ApprovePayrollConfiguration
-- ========================================
PRINT '========================================';
PRINT 'TEST 33: ApprovePayrollConfiguration';
PRINT '========================================';

-- Insert a pending configuration for testing
INSERT INTO ApprovalWorkflow (WorkflowID, workflow_type, threshold_amount, approved_role, created_by, status)
VALUES (100, 'Test Config', 5000.00, 'Manager', 1, 'Pending');
GO

-- Test 33.1: Approve pending configuration
PRINT 'Test 33.1: Approve pending payroll configuration';
SELECT 'Before approval:' AS Info, WorkflowID, status FROM ApprovalWorkflow WHERE WorkflowID = 100;
EXEC ApprovePayrollConfiguration @ConfigID = 100, @ApprovedBy = 1;
SELECT 'After approval:' AS Info, WorkflowID, status FROM ApprovalWorkflow WHERE WorkflowID = 100;
PRINT '';

-- Insert another pending configuration
INSERT INTO ApprovalWorkflow (WorkflowID, workflow_type, threshold_amount, approved_role, created_by, status)
VALUES (101, 'Test Config 2', 3000.00, 'Director', 1, 'Pending');
GO

-- Test 33.2: Approve another configuration
PRINT 'Test 33.2: Approve second configuration';
EXEC ApprovePayrollConfiguration @ConfigID = 101, @ApprovedBy = 3;
PRINT '';

-- Test 33.3: Approve already approved configuration (corner case)
PRINT 'Test 33.3: Approve already approved configuration (should fail)';
BEGIN TRY
    EXEC ApprovePayrollConfiguration @ConfigID = 100, @ApprovedBy = 1;
END TRY
BEGIN CATCH
    PRINT 'Expected error: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- Test 33.4: Invalid configuration ID (corner case)
PRINT 'Test 33.4: Invalid configuration ID (should fail)';
BEGIN TRY
    EXEC ApprovePayrollConfiguration @ConfigID = 999, @ApprovedBy = 1;
END TRY
BEGIN CATCH
    PRINT 'Expected error: ' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- ========================================
-- TEST 34: ModifyPastPayroll
-- ========================================
PRINT '========================================';
PRINT 'TEST 34: ModifyPastPayroll';
PRINT '========================================';

-- Test 34.1: Modify base amount
PRINT 'Test 34.1: Modify base amount for payroll 1';
SELECT 'Before modification:' AS Info, PayrollID, employee_id, base_amount, net_salary FROM Payroll WHERE PayrollID = 1;
EXEC ModifyPastPayroll @PayrollRunID = 1, @EmployeeID = 1, @FieldName = 'base_amount', @NewValue = 5500.00, @ModifiedBy = 1;
SELECT 'After modification:' AS Info, PayrollID, employee_id, base_amount, net_salary FROM Payroll WHERE PayrollID = 1;
PRINT '';

-- Test 34.2: Modify adjustments
PRINT 'Test 34.2: Modify adjustments for payroll 2';
SELECT 'Before modification:' AS Info, PayrollID, employee_id, adjustments, net_salary FROM Payroll WHERE PayrollID = 2;
EXEC ModifyPastPayroll @PayrollRunID = 2, @EmployeeID = 2, @FieldName = 'adjustments', @NewValue = 100.00, @ModifiedBy = 1;
SELECT 'After modification:' AS Info, PayrollID, employee_id, adjustments, net_salary FROM Payroll WHERE PayrollID = 2;
PRINT '';

-- Test 34.3: Modify taxes
PRINT 'Test 34.3: Modify taxes for payroll 3';
SELECT 'Before modification:' AS Info, PayrollID, employee_id, taxes, net_salary FROM Payroll WHERE PayrollID = 3;
EXEC ModifyPastPayroll @PayrollRunID = 3, @EmployeeID = 3, @FieldName = 'taxes', @NewValue = 900.00, @ModifiedBy = 1;
SELECT 'After modification:' AS Info, PayrollID, employee_id, taxes, net_salary FROM Payroll WHERE PayrollID = 3;
SELECT 'Payroll logs:' AS Info, payroll_log_id, payroll_id, modification_type FROM PayrollLog WHERE payroll_id IN (1,2,3);
PRINT '';

-- Test 34.4: Invalid field name (corner case)
PRINT 'Test 34.4: Invalid field name (should fail)';
BEGIN TRY
    EXEC ModifyPastPayroll @PayrollRunID = 1, @EmployeeID = 1, @FieldName = 'invalid_field', @NewValue = 1000.00, @ModifiedBy = 1;
END TRY
BEGIN CATCH
    PRINT 'Expected error: ' + ERROR_MESSAGE();
END CATCH
PRINT '';


-- Test ReviewLeaveRequest
PRINT '--- ReviewLeaveRequest tests ---';

-- Using the test employee from SubmitLeaveRequest tests
DECLARE @TestEmp INT;
DECLARE @TestManager INT = 2; -- Bob Johnson is a manager (from your setup)

-- Get the test employee ID
SELECT @TestEmp = EmployeeID FROM dbo.Employee WHERE email = 'submit.leave.test@example.com';

-- If that employee doesn't exist, use Employee 1 (Alice) with Manager 2 (Bob)
IF @TestEmp IS NULL
    SET @TestEmp = 1;

PRINT 'Using Test Employee: ' + CAST(@TestEmp AS VARCHAR(10));
PRINT 'Using Test Manager: ' + CAST(@TestManager AS VARCHAR(10));

-- Update employee to have the test manager
UPDATE dbo.Employee SET manager_id = @TestManager WHERE EmployeeID = @TestEmp;

-- Create fresh leave requests for testing
DECLARE @LeaveReqID1 INT, @LeaveReqID2 INT, @LeaveReqID3 INT;

EXEC dbo.SubmitLeaveRequest
    @EmployeeID = @TestEmp,
    @LeaveTypeID = 1,
    @StartDate = '2025-12-01',
    @EndDate = '2025-12-05',
    @Reason = 'For review test 1';

SELECT @LeaveReqID1 = MAX(RequestID) FROM dbo.LeaveRequest WHERE employee_id = @TestEmp;

EXEC dbo.SubmitLeaveRequest
    @EmployeeID = @TestEmp,
    @LeaveTypeID = 1,
    @StartDate = '2025-12-10',
    @EndDate = '2025-12-15',
    @Reason = 'For review test 2';

SELECT @LeaveReqID2 = MAX(RequestID) FROM dbo.LeaveRequest WHERE employee_id = @TestEmp;

EXEC dbo.SubmitLeaveRequest
    @EmployeeID = @TestEmp,
    @LeaveTypeID = 2,
    @StartDate = '2025-12-20',
    @EndDate = '2025-12-22',
    @Reason = 'For review test 3';

SELECT @LeaveReqID3 = MAX(RequestID) FROM dbo.LeaveRequest WHERE employee_id = @TestEmp;

PRINT 'Created leave requests with IDs: ' + CAST(@LeaveReqID1 AS VARCHAR(10)) + ', ' + 
      CAST(@LeaveReqID2 AS VARCHAR(10)) + ', ' + CAST(@LeaveReqID3 AS VARCHAR(10));

-- Test 1: Manager approves leave request
PRINT 'Test 1: Manager approves leave request';
BEGIN TRY
    EXEC dbo.ReviewLeaveRequest 
        @LeaveRequestID = @LeaveReqID1,
        @ManagerID = @TestManager,
        @Decision = 'APPROVED';
    PRINT 'Test 1 PASSED';
END TRY
BEGIN CATCH
    PRINT 'Test 1 FAILED: ' + ERROR_MESSAGE();
END CATCH

-- Test 2: Manager rejects leave request
PRINT 'Test 2: Manager rejects leave request';
BEGIN TRY
    EXEC dbo.ReviewLeaveRequest 
        @LeaveRequestID = @LeaveReqID2,
        @ManagerID = @TestManager,
        @Decision = 'REJECTED';
    PRINT 'Test 2 PASSED';
END TRY
BEGIN CATCH
    PRINT 'Test 2 FAILED: ' + ERROR_MESSAGE();
END CATCH

-- Test 3: Invalid decision (should fail)
PRINT 'Test 3: Invalid decision (should fail)';
BEGIN TRY
    EXEC dbo.ReviewLeaveRequest 
        @LeaveRequestID = @LeaveReqID3,
        @ManagerID = @TestManager,
        @Decision = 'INVALID';
    PRINT 'Test 3 UNEXPECTED: no error raised';
END TRY
BEGIN CATCH
    PRINT 'Test 3 expected failure caught: ' + ERROR_MESSAGE();
END CATCH

-- Test 4: Unauthorized manager (should fail)
PRINT 'Test 4: Unauthorized manager (should fail)';
BEGIN TRY
    EXEC dbo.ReviewLeaveRequest 
        @LeaveRequestID = @LeaveReqID3,
        @ManagerID = 999,
        @Decision = 'APPROVED';
    PRINT 'Test 4 UNEXPECTED: no error raised';
END TRY
BEGIN CATCH
    PRINT 'Test 4 expected failure caught: ' + ERROR_MESSAGE();
END CATCH

-- Test 5: Non-existing leave request (should fail)
PRINT 'Test 5: Non-existing leave request (should fail)';
BEGIN TRY
    EXEC dbo.ReviewLeaveRequest 
        @LeaveRequestID = 999999,
        @ManagerID = @TestManager,
        @Decision = 'APPROVED';
    PRINT 'Test 5 UNEXPECTED: no error raised';
END TRY
BEGIN CATCH
    PRINT 'Test 5 expected failure caught: ' + ERROR_MESSAGE();
END CATCH

-- Test 6: Manager not authorized for this employee (should fail)
-- First create an employee with a different manager
DECLARE @OtherEmp INT, @OtherManager INT = 4;
IF NOT EXISTS (SELECT 1 FROM dbo.Employee WHERE EmployeeID = 100)
BEGIN
    INSERT INTO dbo.Employee (EmployeeID, first_name, last_name, email, hire_date, is_active, department_id, position_id, manager_id)
    VALUES (100, 'Other', 'Employee', 'other.emp@example.com', '2025-01-01', 1, 1, 1, @OtherManager);
END
ELSE
BEGIN
    UPDATE dbo.Employee SET manager_id = @OtherManager WHERE EmployeeID = 100;
END

DECLARE @OtherLeaveReq INT;
EXEC dbo.SubmitLeaveRequest
    @EmployeeID = 100,
    @LeaveTypeID = 1,
    @StartDate = '2025-12-25',
    @EndDate = '2025-12-26',
    @Reason = 'For authorization test';

SELECT @OtherLeaveReq = MAX(RequestID) FROM dbo.LeaveRequest WHERE employee_id = 100;

PRINT 'Test 6: Manager reviews request for employee they don''t manage (should fail)';
BEGIN TRY
    EXEC dbo.ReviewLeaveRequest 
        @LeaveRequestID = @OtherLeaveReq,
        @ManagerID = @TestManager,
        @Decision = 'APPROVED';
    PRINT 'Test 6 UNEXPECTED: no error raised';
END TRY
BEGIN CATCH
    PRINT 'Test 6 expected failure caught: ' + ERROR_MESSAGE();
END CATCH

-- Verify updates
PRINT 'Verifying LeaveRequest updates:';
SELECT 
    RequestID,
    employee_id,
    leave_id,
    status,
    approval_timing,
    justification
FROM dbo.LeaveRequest 
WHERE RequestID IN (@LeaveReqID1, @LeaveReqID2, @LeaveReqID3, @OtherLeaveReq)
ORDER BY RequestID;

GO

--2--
-- Test AssignShift
PRINT '--- AssignShift tests ---';

-- Setup: Create test shifts in ShiftSchedule
DECLARE @TestEmp1 INT = 1; -- Alice
DECLARE @TestEmp2 INT = 2; -- Bob
DECLARE @TestManager INT = 2; -- Bob is manager

PRINT 'Setting up test shifts...';

-- Create test shifts if they don't exist
DECLARE @ShiftID1 INT, @ShiftID2 INT, @ShiftID3 INT;

-- Get next available ShiftID
SELECT @ShiftID1 = ISNULL(MAX(ShiftID), 0) + 1 FROM dbo.ShiftSchedule;
SELECT @ShiftID2 = @ShiftID1 + 1;
SELECT @ShiftID3 = @ShiftID1 + 2;

-- Insert test shifts (unassigned initially)
IF NOT EXISTS (SELECT 1 FROM dbo.ShiftSchedule WHERE ShiftID = @ShiftID1)
BEGIN
    INSERT INTO dbo.ShiftSchedule (ShiftID, employee_id, start_date, end_date, status)
    VALUES (@ShiftID1, NULL, '2025-12-01', '2025-12-31', 'PENDING');
    PRINT 'Created shift ' + CAST(@ShiftID1 AS VARCHAR(10));
END

IF NOT EXISTS (SELECT 1 FROM dbo.ShiftSchedule WHERE ShiftID = @ShiftID2)
BEGIN
    INSERT INTO dbo.ShiftSchedule (ShiftID, employee_id, start_date, end_date, status)
    VALUES (@ShiftID2, NULL, '2026-01-01', '2026-01-31', 'PENDING');
    PRINT 'Created shift ' + CAST(@ShiftID2 AS VARCHAR(10));
END

IF NOT EXISTS (SELECT 1 FROM dbo.ShiftSchedule WHERE ShiftID = @ShiftID3)
BEGIN
    INSERT INTO dbo.ShiftSchedule (ShiftID, employee_id, start_date, end_date, status)
    VALUES (@ShiftID3, NULL, '2026-02-01', '2026-02-28', 'PENDING');
    PRINT 'Created shift ' + CAST(@ShiftID3 AS VARCHAR(10));
END

PRINT 'Test shifts created: ' + CAST(@ShiftID1 AS VARCHAR(10)) + ', ' + 
      CAST(@ShiftID2 AS VARCHAR(10)) + ', ' + CAST(@ShiftID3 AS VARCHAR(10));

-- Test 1: Successfully assign shift to employee
PRINT 'Test 1: Successfully assign shift to employee';
BEGIN TRY
    EXEC dbo.AssignShift 
        @EmployeeID = @TestEmp1,
        @ShiftID = @ShiftID1;
    PRINT 'Test 1 PASSED';
END TRY
BEGIN CATCH
    PRINT 'Test 1 FAILED: ' + ERROR_MESSAGE();
END CATCH

-- Test 2: Assign different shift to same employee
PRINT 'Test 2: Assign different shift to same employee';
BEGIN TRY
    EXEC dbo.AssignShift 
        @EmployeeID = @TestEmp1,
        @ShiftID = @ShiftID2;
    PRINT 'Test 2 PASSED';
END TRY
BEGIN CATCH
    PRINT 'Test 2 FAILED: ' + ERROR_MESSAGE();
END CATCH

-- Test 3: Assign shift to different employee
PRINT 'Test 3: Assign shift to different employee';
BEGIN TRY
    EXEC dbo.AssignShift 
        @EmployeeID = @TestEmp2,
        @ShiftID = @ShiftID3;
    PRINT 'Test 3 PASSED';
END TRY
BEGIN CATCH
    PRINT 'Test 3 FAILED: ' + ERROR_MESSAGE();
END CATCH

-- Test 4: Assign same shift again (should show already assigned)
PRINT 'Test 4: Re-assign same shift (should show already assigned)';
BEGIN TRY
    EXEC dbo.AssignShift 
        @EmployeeID = @TestEmp1,
        @ShiftID = @ShiftID1;
    PRINT 'Test 4 PASSED (duplicate handled gracefully)';
END TRY
BEGIN CATCH
    PRINT 'Test 4 FAILED: ' + ERROR_MESSAGE();
END CATCH

-- Test 5: Non-existing employee (should fail)
PRINT 'Test 5: Non-existing employee (should fail)';
BEGIN TRY
    EXEC dbo.AssignShift 
        @EmployeeID = 999999,
        @ShiftID = @ShiftID1;
    PRINT 'Test 5 UNEXPECTED: no error raised';
END TRY
BEGIN CATCH
    PRINT 'Test 5 expected failure caught: ' + ERROR_MESSAGE();
END CATCH

-- Test 6: Non-existing shift (should fail)
PRINT 'Test 6: Non-existing shift (should fail)';
BEGIN TRY
    EXEC dbo.AssignShift 
        @EmployeeID = @TestEmp1,
        @ShiftID = 999999;
    PRINT 'Test 6 UNEXPECTED: no error raised';
END TRY
BEGIN CATCH
    PRINT 'Test 6 expected failure caught: ' + ERROR_MESSAGE();
END CATCH

-- Test 7: NULL EmployeeID (should fail)
PRINT 'Test 7: NULL EmployeeID (should fail)';
BEGIN TRY
    EXEC dbo.AssignShift 
        @EmployeeID = NULL,
        @ShiftID = @ShiftID1;
    PRINT 'Test 7 UNEXPECTED: no error raised';
END TRY
BEGIN CATCH
    PRINT 'Test 7 expected failure caught: ' + ERROR_MESSAGE();
END CATCH

-- Test 8: NULL ShiftID (should fail)
PRINT 'Test 8: NULL ShiftID (should fail)';
BEGIN TRY
    EXEC dbo.AssignShift 
        @EmployeeID = @TestEmp1,
        @ShiftID = NULL;
    PRINT 'Test 8 UNEXPECTED: no error raised';
END TRY
BEGIN CATCH
    PRINT 'Test 8 expected failure caught: ' + ERROR_MESSAGE();
END CATCH

-- Verify results
PRINT 'Verifying ShiftSchedule assignments:';
SELECT 
    ShiftID,
    employee_id,
    start_date,
    end_date,
    status,
    CASE 
        WHEN employee_id IS NOT NULL THEN 'Assigned to Employee ' + CAST(employee_id AS VARCHAR(10))
        ELSE 'Unassigned'
    END AS AssignmentStatus
FROM dbo.ShiftSchedule
WHERE ShiftID IN (@ShiftID1, @ShiftID2, @ShiftID3)
ORDER BY ShiftID;

-- Show which employees have which shifts
PRINT 'Employee shift assignments:';
SELECT 
    e.EmployeeID,
    e.first_name + ' ' + e.last_name AS EmployeeName,
    ss.ShiftID,
    ss.start_date,
    ss.end_date,
    ss.status
FROM dbo.Employee e
INNER JOIN dbo.ShiftSchedule ss ON e.EmployeeID = ss.employee_id
WHERE e.EmployeeID IN (@TestEmp1, @TestEmp2)
ORDER BY e.EmployeeID, ss.ShiftID;

GO
--4--
-- Test ViewTeamAttendance
PRINT '--- ViewTeamAttendance tests ---';

DECLARE @ManagerID INT = 2;   -- Bob Johnson as manager
DECLARE @TeamEmp1 INT = 1;    -- Alice
DECLARE @TeamEmp2 INT = 3;    -- John

-- Ensure manager/employee relationships
UPDATE dbo.Employee
SET manager_id = @ManagerID
WHERE EmployeeID IN (@TeamEmp1, @TeamEmp2);

-- Create sample attendance records
DECLARE @NextAttendanceID INT;
SELECT @NextAttendanceID = ISNULL(MAX(AttendanceID), 0) + 1 FROM dbo.Attendance;

DECLARE @AttID1 INT = @NextAttendanceID;
DECLARE @AttID2 INT = @NextAttendanceID + 1;
DECLARE @AttID3 INT = @NextAttendanceID + 2;  -- outside date range

INSERT INTO dbo.Attendance
    (AttendanceID, employee_id, entry_time, exit_time, duration, login_method, logout_method, exception_id)
VALUES
    (@AttID1, @TeamEmp1, '09:00', '17:00', 480, 'BIOMETRIC', 'BIOMETRIC', NULL),
    (@AttID2, @TeamEmp2, '10:00', '18:00', 480, 'WEB',       'WEB',       NULL),
    (@AttID3, @TeamEmp1, '09:00', '12:00', 180, 'BIOMETRIC', 'BIOMETRIC', NULL);

-- Create matching attendance logs with dates
DECLARE @NextLogID INT;
SELECT @NextLogID = ISNULL(MAX(AttendanceLogID), 0) + 1 FROM dbo.AttendanceLog;

INSERT INTO dbo.AttendanceLog
    (AttendanceLogID, attendance_id, actor, [timestamp], reason)
VALUES
    (@NextLogID,     @AttID1, 'TEST', '2025-12-05T09:00:00', 'Within range'),
    (@NextLogID + 1, @AttID2, 'TEST', '2025-12-10T10:00:00', 'Within range'),
    (@NextLogID + 2, @AttID3, 'TEST', '2026-01-10T09:00:00', 'Outside range');

PRINT 'Test 1: View attendance for team members between 2025-12-01 and 2025-12-31';
EXEC dbo.ViewTeamAttendance
    @ManagerID      = @ManagerID,
    @DateRangeStart = '2025-12-01',
    @DateRangeEnd   = '2025-12-31';

PRINT 'Test 2: Invalid manager (should fail)';
BEGIN TRY
    EXEC dbo.ViewTeamAttendance
        @ManagerID      = 999999,
        @DateRangeStart = '2025-12-01',
        @DateRangeEnd   = '2025-12-31';
    PRINT 'Test 2 UNEXPECTED: no error raised';
END TRY
BEGIN CATCH
    PRINT 'Test 2 expected failure caught: ' + ERROR_MESSAGE();
END CATCH;

GO


PRINT '--- SendTeamNotification tests ---';

DECLARE @ManagerID INT  = 2;  -- Bob Johnson (from seed data)
DECLARE @TeamEmp1  INT  = 1;  -- Alice
DECLARE @TeamEmp2  INT  = 3;  -- John
DECLARE @LatestNotificationID INT;

-- Ensure team members are assigned to this manager
UPDATE dbo.Employee
SET manager_id = @ManagerID
WHERE EmployeeID IN (@TeamEmp1, @TeamEmp2);

PRINT 'Test 1: Send notification to manager''s team';
EXEC dbo.SendTeamNotification
    @ManagerID      = @ManagerID,
    @MessageContent = 'Team meeting at 10:00',
    @UrgencyLevel   = 'HIGH';

-- Inspect the most recent notification and its deliveries
SELECT @LatestNotificationID = MAX(NotificationID)
FROM dbo.Notification;

SELECT 
    n.NotificationID,
    n.mesage_content,
    n.urgency,
    en.employee_id,
    en.delivery_status,
    en.delivered_at
FROM dbo.Notification n
JOIN dbo.EmployeeNotification en
    ON n.NotificationID = en.notification_id
WHERE n.NotificationID = @LatestNotificationID
ORDER BY en.employee_id;

PRINT 'Test 2: Invalid manager (should fail)';
BEGIN TRY
    EXEC dbo.SendTeamNotification
        @ManagerID      = 999999,
        @MessageContent = 'This should fail',
        @UrgencyLevel   = 'LOW';
    PRINT 'Test 2 UNEXPECTED: no error raised';
END TRY
BEGIN CATCH
    PRINT 'Test 2 expected failure caught: ' + ERROR_MESSAGE();
END CATCH;

PRINT 'Test 3: Empty message (should fail)';
BEGIN TRY
    EXEC dbo.SendTeamNotification
        @ManagerID      = @ManagerID,
        @MessageContent = '   ',
        @UrgencyLevel   = 'MEDIUM';
    PRINT 'Test 3 UNEXPECTED: no error raised';
END TRY
BEGIN CATCH
    PRINT 'Test 3 expected failure caught: ' + ERROR_MESSAGE();
END CATCH;

GO

/***** ApproveMissionCompletion tests *****/

PRINT '--- ApproveMissionCompletion tests ---';

DECLARE @TestManagerID  INT = 2;  -- e.g., Bob Johnson
DECLARE @TestEmployeeID INT = 1;  -- e.g., Alice Smith
DECLARE @NewMissionID   INT;

-- Ensure these employees exist from seed (1 = employee, 2 = manager)
-- and that employee reports to this manager (optional, but consistent)
UPDATE dbo.Employee
SET manager_id = @TestManagerID
WHERE EmployeeID = @TestEmployeeID;

-- Create a test mission
SELECT @NewMissionID = ISNULL(MAX(MissionID), 0) + 1
FROM dbo.Mission;

INSERT INTO dbo.Mission
    (MissionID, destination, start_date, end_date, status, employee_id, manager_id)
VALUES
    (@NewMissionID, 'Berlin', '2025-01-01', '2025-01-07', 'IN_PROGRESS', @TestEmployeeID, @TestManagerID);

PRINT 'Test 1: Approve mission completion with valid manager';
EXEC dbo.ApproveMissionCompletion
     @MissionID = @NewMissionID,
     @ManagerID = @TestManagerID,
     @Remarks   = 'Mission completed successfully and on time.';

-- Check mission status and manager note
SELECT *
FROM dbo.Mission
WHERE MissionID = @NewMissionID;

SELECT TOP 5 *
FROM dbo.ManagerNotes
WHERE employee_id = @TestEmployeeID
ORDER BY created_at DESC;

PRINT 'Test 2: Attempt approval with wrong manager (should fail)';
BEGIN TRY
    EXEC dbo.ApproveMissionCompletion
         @MissionID = @NewMissionID,
         @ManagerID = 999999,  -- not the mission manager
         @Remarks   = 'This should not be allowed.';
    PRINT 'Test 2 UNEXPECTED: no error raised';
END TRY
BEGIN CATCH
    PRINT 'Test 2 expected failure caught: ' + ERROR_MESSAGE();
END CATCH;
GO
/***** RequestReplacement tests *****/

PRINT '--- RequestReplacement tests ---';

DECLARE @EmpID INT = 1;      -- existing seeded employee
DECLARE @MgrID INT = 2;      -- existing seeded manager (e.g., Bob)

/* Ensure employee has a manager so the proc can infer it */
UPDATE dbo.Employee
SET manager_id = @MgrID
WHERE EmployeeID = @EmpID;

PRINT 'Test 1: valid replacement request';
EXEC dbo.RequestReplacement
    @EmployeeID = @EmpID,
    @Reason     = 'On sick leave, need shift coverage.';

-- Inspect the latest manager notes for that employee
SELECT TOP 5
    NoteID, employee_id, manager_id, note_content, created_at
FROM dbo.ManagerNotes
WHERE employee_id = @EmpID
ORDER BY created_at DESC;

PRINT 'Test 2: invalid employee (should fail)';
BEGIN TRY
    EXEC dbo.RequestReplacement
        @EmployeeID = 999999,
        @Reason     = 'Invalid employee ID test.';
    PRINT 'Test 2 UNEXPECTED: no error raised';
END TRY
BEGIN CATCH
    PRINT 'Test 2 expected failure caught: ' + ERROR_MESSAGE();
END CATCH;

PRINT 'Test 3: employee without manager (should fail)';
DECLARE @NoManagerEmp INT = 200000;

IF NOT EXISTS (SELECT 1 FROM dbo.Employee WHERE EmployeeID = @NoManagerEmp)
BEGIN
    INSERT INTO dbo.Employee
        (EmployeeID, first_name, last_name, email, hire_date, is_active, department_id, position_id)
    VALUES
        (@NoManagerEmp, 'NoManager', 'Employee', 'nomanager@example.com',
         GETDATE(), 1, 1, 1);
END;

UPDATE dbo.Employee
SET manager_id = NULL
WHERE EmployeeID = @NoManagerEmp;

BEGIN TRY
    EXEC dbo.RequestReplacement
        @EmployeeID = @NoManagerEmp,
        @Reason     = 'Testing no-manager scenario.';
    PRINT 'Test 3 UNEXPECTED: no error raised';
END TRY
BEGIN CATCH
    PRINT 'Test 3 expected failure caught: ' + ERROR_MESSAGE();
END CATCH;

GO
/***** ViewDepartmentSummary tests *****/

PRINT '--- ViewDepartmentSummary tests ---';

DECLARE @DeptID INT = 1;       -- test department
DECLARE @Emp1   INT = 1;       -- existing seeded employee
DECLARE @Emp2   INT = 3;       -- existing seeded employee
DECLARE @MgrID  INT = 2;       -- existing seeded manager
DECLARE @MissionID1 INT;
DECLARE @MissionID2 INT;

-- Ensure the department exists (create a basic one if missing)
IF NOT EXISTS (SELECT 1 FROM dbo.Department WHERE DepartmentID = @DeptID)
BEGIN
    INSERT INTO dbo.Department (DepartmentID, department_name, purpose, department_head_id)
    VALUES (@DeptID, 'Test Department', 'Testing department summary', @MgrID);
END;

-- Assign employees to this department
UPDATE dbo.Employee
SET department_id = @DeptID,
    manager_id    = @MgrID
WHERE EmployeeID IN (@Emp1, @Emp2);

-- Create some IN_PROGRESS missions (treated as active projects)
SELECT @MissionID1 = ISNULL(MAX(MissionID), 0) + 1
FROM dbo.Mission;

SET @MissionID2 = @MissionID1 + 1;

INSERT INTO dbo.Mission
    (MissionID, destination, start_date, end_date, status, employee_id, manager_id)
VALUES
    (@MissionID1, 'Project Alpha', '2025-01-01', '2025-03-01', 'IN_PROGRESS', @Emp1, @MgrID),
    (@MissionID2, 'Project Beta',  '2025-02-01', '2025-04-01', 'IN_PROGRESS', @Emp2, @MgrID);

PRINT 'Test 1: View summary for valid department';
EXEC dbo.ViewDepartmentSummary
    @DepartmentID = @DeptID;

PRINT 'Test 2: Invalid department (should fail)';
BEGIN TRY
    EXEC dbo.ViewDepartmentSummary
        @DepartmentID = 999999;
    PRINT 'Test 2 UNEXPECTED: no error raised';
END TRY
BEGIN CATCH
    PRINT 'Test 2 expected failure caught: ' + ERROR_MESSAGE();
END CATCH;
GO

/***** ReassignShift tests *****/

PRINT '--- ReassignShift tests ---';

DECLARE @EmpID       INT = 1;  -- existing employee (e.g., Alice)
DECLARE @OldShiftID  INT;
DECLARE @NewShiftID  INT;

-- Get two new ShiftIDs
SELECT @OldShiftID = ISNULL(MAX(ShiftID), 0) + 1 FROM dbo.ShiftSchedule;
SET @NewShiftID = @OldShiftID + 1;

-- Create old shift assigned to employee and new shift as free (PENDING)
INSERT INTO dbo.ShiftSchedule (ShiftID, employee_id, start_date, end_date, status)
VALUES
    (@OldShiftID, @EmpID, '2025-11-01', '2025-11-30', 'ACTIVE'),
    (@NewShiftID, NULL,  '2025-12-01', '2025-12-31', 'PENDING');

PRINT 'Test 1: Successfully reassign shift from old to new';
BEGIN TRY
    EXEC dbo.ReassignShift
        @EmployeeID = @EmpID,
        @OldShiftID = @OldShiftID,
        @NewShiftID = @NewShiftID;
    PRINT 'Test 1 DONE';
END TRY
BEGIN CATCH
    PRINT 'Test 1 FAILED: ' + ERROR_MESSAGE();
END CATCH;

-- Verify results
PRINT 'Verifying ShiftSchedule after reassignment:';
SELECT ShiftID, employee_id, start_date, end_date, status
FROM dbo.ShiftSchedule
WHERE ShiftID IN (@OldShiftID, @NewShiftID)
ORDER BY ShiftID;

PRINT 'Test 2: New shift does not exist (should fail)';
BEGIN TRY
    EXEC dbo.ReassignShift
        @EmployeeID = @EmpID,
        @OldShiftID = @NewShiftID,  -- now current shift
        @NewShiftID = 999999;       -- non-existing shift
    PRINT 'Test 2 UNEXPECTED: no error raised';
END TRY
BEGIN CATCH
    PRINT 'Test 2 expected failure caught: ' + ERROR_MESSAGE();
END CATCH;
GO

/***** GetPendingLeaveRequests tests *****/

PRINT '--- GetPendingLeaveRequests tests ---';

DECLARE @ManagerID INT = 2;   -- example manager (e.g., Bob)
DECLARE @Emp1      INT = 1;   -- example employee 1
DECLARE @Emp2      INT = 3;   -- example employee 2
DECLARE @LeaveID1  INT = 1;
DECLARE @LeaveID2  INT = 2;
DECLARE @ReqID1    INT;
DECLARE @ReqID2    INT;
DECLARE @ReqID3    INT;

-- Make sure employees report to this manager
UPDATE dbo.Employee
SET manager_id = @ManagerID
WHERE EmployeeID IN (@Emp1, @Emp2);

-- Ensure Leave rows exist
IF NOT EXISTS (SELECT 1 FROM dbo.Leave WHERE LeaveID = @LeaveID1)
BEGIN
    INSERT INTO dbo.Leave (LeaveID, leave_type, leave_description)
    VALUES (@LeaveID1, 'Annual Leave', 'Annual vacation leave');
END;

IF NOT EXISTS (SELECT 1 FROM dbo.Leave WHERE LeaveID = @LeaveID2)
BEGIN
    INSERT INTO dbo.Leave (LeaveID, leave_type, leave_description)
    VALUES (@LeaveID2, 'Sick Leave', 'Medical sick leave');
END;

-- Create some leave requests (two pending, one approved)
SELECT @ReqID1 = ISNULL(MAX(RequestID), 0) + 1
FROM dbo.LeaveRequest;
SET @ReqID2 = @ReqID1 + 1;
SET @ReqID3 = @ReqID1 + 2;

INSERT INTO dbo.LeaveRequest
    (RequestID, employee_id, leave_id, justification, duration, approval_timing, status)
VALUES
    (@ReqID1, @Emp1, @LeaveID1, 'Family vacation',      5, NULL,          'PENDING'),
    (@ReqID2, @Emp2, @LeaveID2, 'Flu and high fever',   3, NULL,          'Pending'),
    (@ReqID3, @Emp1, @LeaveID1, 'Previously approved',  2, GETDATE(),     'APPROVED');

PRINT 'Test 1: Pending leave requests for valid manager';
EXEC dbo.GetPendingLeaveRequests
    @ManagerID = @ManagerID;

PRINT 'Test 2: Invalid manager (should fail)';
BEGIN TRY
    EXEC dbo.GetPendingLeaveRequests
        @ManagerID = 999999;
    PRINT 'Test 2 UNEXPECTED: no error raised';
END TRY
BEGIN CATCH
    PRINT 'Test 2 expected failure caught: ' + ERROR_MESSAGE();
END CATCH;
GO


/***** 10 : GetTeamStatistics tests *****/

PRINT '--- GetTeamStatistics tests ---';

DECLARE @ManagerID INT = 2;  -- example manager (e.g., Bob)
DECLARE @Emp1      INT = 1;  -- direct report 1
DECLARE @Emp2      INT = 3;  -- direct report 2

-- Ensure pay grades exist
IF NOT EXISTS (SELECT 1 FROM dbo.PayGrade WHERE PayGradeID = 1)
BEGIN
    INSERT INTO dbo.PayGrade (PayGradeID, grade_name, min_salary, max_salary)
    VALUES (1, 'Junior', 3000.00, 5000.00);
END;

IF NOT EXISTS (SELECT 1 FROM dbo.PayGrade WHERE PayGradeID = 2)
BEGIN
    INSERT INTO dbo.PayGrade (PayGradeID, grade_name, min_salary, max_salary)
    VALUES (2, 'Senior', 5000.00, 8000.00);
END;

-- Ensure employees report to this manager and have pay grades
UPDATE dbo.Employee
SET manager_id = @ManagerID,
    paygrade_id = 1
WHERE EmployeeID = @Emp1;

UPDATE dbo.Employee
SET manager_id = @ManagerID,
    paygrade_id = 2
WHERE EmployeeID = @Emp2;

-- Ensure EmployeeHierarchy contains entries for span of control
IF NOT EXISTS (
    SELECT 1 FROM dbo.EmployeeHierarchy
    WHERE employee_id = @Emp1 AND manager_id = @ManagerID
)
BEGIN
    INSERT INTO dbo.EmployeeHierarchy (employee_id, manager_id, hierarchy_level)
    VALUES (@Emp1, @ManagerID, 1);
END;

IF NOT EXISTS (
    SELECT 1 FROM dbo.EmployeeHierarchy
    WHERE employee_id = @Emp2 AND manager_id = @ManagerID
)
BEGIN
    INSERT INTO dbo.EmployeeHierarchy (employee_id, manager_id, hierarchy_level)
    VALUES (@Emp2, @ManagerID, 1);
END;

PRINT 'Test 1: Team statistics for valid manager';
EXEC dbo.GetTeamStatistics
    @ManagerID = @ManagerID;

PRINT 'Test 2: Invalid manager (should fail)';
BEGIN TRY
    EXEC dbo.GetTeamStatistics
        @ManagerID = 999999;
    PRINT 'Test 2 UNEXPECTED: no error raised';
END TRY
BEGIN CATCH
    PRINT 'Test 2 expected failure caught: ' + ERROR_MESSAGE();
END CATCH;
GO

/***** ViewTeamProfiles tests *****/

PRINT '--- ViewTeamProfiles tests ---';

DECLARE @ManagerID INT = 2;  -- e.g., Bob
DECLARE @Emp1      INT = 1;  -- e.g., Alice
DECLARE @Emp2      INT = 3;  -- e.g., John

-- Make sure some basic department/position rows exist
IF NOT EXISTS (SELECT 1 FROM dbo.Department WHERE DepartmentID = 1)
BEGIN
    INSERT INTO dbo.Department (DepartmentID, department_name, purpose, department_head_id)
    VALUES (1, 'IT Department', 'Handles IT services', @ManagerID);
END;

IF NOT EXISTS (SELECT 1 FROM dbo.Position WHERE PositionID = 1)
BEGIN
    INSERT INTO dbo.Position (PositionID, position_title, responsibilities, status)
    VALUES (1, 'Developer', 'Develops software', 'ACTIVE');
END;

IF NOT EXISTS (SELECT 1 FROM dbo.Position WHERE PositionID = 2)
BEGIN
    INSERT INTO dbo.Position (PositionID, position_title, responsibilities, status)
    VALUES (2, 'Analyst', 'Analyzes data', 'ACTIVE');
END;

-- Ensure employees are active team members under this manager
UPDATE dbo.Employee
SET manager_id    = @ManagerID,
    department_id = 1,
    position_id   = 1,
    is_active     = 1,
    employment_status = 'FULL_TIME',
    account_status    = 'ACTIVE'
WHERE EmployeeID = @Emp1;

UPDATE dbo.Employee
SET manager_id    = @ManagerID,
    department_id = 1,
    position_id   = 2,
    is_active     = 1,
    employment_status = 'FULL_TIME',
    account_status    = 'ACTIVE'
WHERE EmployeeID = @Emp2;

PRINT 'Test 1: View team profiles for valid manager';
EXEC dbo.ViewTeamProfiles
    @ManagerID = @ManagerID;

PRINT 'Test 2: Invalid manager (should fail)';
BEGIN TRY
    EXEC dbo.ViewTeamProfiles
        @ManagerID = 999999;
    PRINT 'Test 2 UNEXPECTED: no error raised';
END TRY
BEGIN CATCH
    PRINT 'Test 2 expected failure caught: ' + ERROR_MESSAGE();
END CATCH;
GO

/***** GetTeamSummary tests *****/

PRINT '--- GetTeamSummary tests ---';

DECLARE @ManagerID INT = 2;  -- e.g., Bob
DECLARE @Emp1      INT = 1;  -- e.g., Alice
DECLARE @Emp2      INT = 3;  -- e.g., John

-- Ensure departments exist
IF NOT EXISTS (SELECT 1 FROM dbo.Department WHERE DepartmentID = 1)
BEGIN
    INSERT INTO dbo.Department (DepartmentID, department_name, purpose, department_head_id)
    VALUES (1, 'IT Department', 'Handles IT services', @ManagerID);
END;

IF NOT EXISTS (SELECT 1 FROM dbo.Department WHERE DepartmentID = 2)
BEGIN
    INSERT INTO dbo.Department (DepartmentID, department_name, purpose, department_head_id)
    VALUES (2, 'Finance Department', 'Handles finances', @ManagerID);
END;

-- Ensure positions exist
IF NOT EXISTS (SELECT 1 FROM dbo.Position WHERE PositionID = 1)
BEGIN
    INSERT INTO dbo.Position (PositionID, position_title, responsibilities, status)
    VALUES (1, 'Developer', 'Develops software', 'ACTIVE');
END;

IF NOT EXISTS (SELECT 1 FROM dbo.Position WHERE PositionID = 2)
BEGIN
    INSERT INTO dbo.Position (PositionID, position_title, responsibilities, status)
    VALUES (2, 'Analyst', 'Analyzes data', 'ACTIVE');
END;

-- Set up two direct reports with different roles/departments/tenure
UPDATE dbo.Employee
SET manager_id    = @ManagerID,
    department_id = 1,
    position_id   = 1,
    is_active     = 1,
    hire_date     = '2020-01-01'
WHERE EmployeeID = @Emp1;

UPDATE dbo.Employee
SET manager_id    = @ManagerID,
    department_id = 2,
    position_id   = 2,
    is_active     = 1,
    hire_date     = '2022-06-15'
WHERE EmployeeID = @Emp2;

PRINT 'Test 1: Team summary for valid manager';
EXEC dbo.GetTeamSummary
    @ManagerID = @ManagerID;

PRINT 'Test 2: Invalid manager (should fail)';
BEGIN TRY
    EXEC dbo.GetTeamSummary
        @ManagerID = 999999;
    PRINT 'Test 2 UNEXPECTED: no error raised';
END TRY
BEGIN CATCH
    PRINT 'Test 2 expected failure caught: ' + ERROR_MESSAGE();
END CATCH;
GO
/***** FilterTeamProfiles tests *****/

PRINT '--- FilterTeamProfiles tests ---';

DECLARE @ManagerID INT = 2;  -- e.g., Bob
DECLARE @Emp1      INT = 1;  -- e.g., Alice
DECLARE @Emp2      INT = 3;  -- e.g., John

-- Ensure some roles exist (should already be seeded, but keep idempotent)
IF NOT EXISTS (SELECT 1 FROM dbo.Role WHERE RoleID = 5)
BEGIN
    INSERT INTO dbo.Role (RoleID, role_name, purpose)
    VALUES (5, 'Employee', 'Regular employee role');
END;

IF NOT EXISTS (SELECT 1 FROM dbo.Role WHERE RoleID = 4)
BEGIN
    INSERT INTO dbo.Role (RoleID, role_name, purpose)
    VALUES (4, 'Line Manager', 'Manages a team');
END;

-- Ensure skills exist
IF NOT EXISTS (SELECT 1 FROM dbo.Skill WHERE SkillID = 1)
BEGIN
    INSERT INTO dbo.Skill (SkillID, skill_name, description)
    VALUES (1, 'SQL', 'Structured Query Language');
END;

IF NOT EXISTS (SELECT 1 FROM dbo.Skill WHERE SkillID = 2)
BEGIN
    INSERT INTO dbo.Skill (SkillID, skill_name, description)
    VALUES (2, 'C#', 'C# programming language');
END;

-- Make employees report to this manager and be active
UPDATE dbo.Employee
SET manager_id = @ManagerID,
    is_active  = 1
WHERE EmployeeID IN (@Emp1, @Emp2);

-- Assign roles
IF NOT EXISTS (
    SELECT 1 FROM dbo.EmployeeRole
    WHERE employee_id = @Emp1 AND role_id = 5
)
BEGIN
    INSERT INTO dbo.EmployeeRole (employee_id, role_id, assigned_date)
    VALUES (@Emp1, 5, GETDATE());
END;

IF NOT EXISTS (
    SELECT 1 FROM dbo.EmployeeRole
    WHERE employee_id = @Emp2 AND role_id = 4
)
BEGIN
    INSERT INTO dbo.EmployeeRole (employee_id, role_id, assigned_date)
    VALUES (@Emp2, 4, GETDATE());
END;

-- Assign skills
IF NOT EXISTS (
    SELECT 1 FROM dbo.EmployeeSkill
    WHERE employee_id = @Emp1 AND skill_id = 1
)
BEGIN
    INSERT INTO dbo.EmployeeSkill (employee_id, skill_id, proficiency_level)
    VALUES (@Emp1, 1, 'Intermediate');
END;

IF NOT EXISTS (
    SELECT 1 FROM dbo.EmployeeSkill
    WHERE employee_id = @Emp2 AND skill_id = 2
)
BEGIN
    INSERT INTO dbo.EmployeeSkill (employee_id, skill_id, proficiency_level)
    VALUES (@Emp2, 2, 'Advanced');
END;

PRINT 'Test 1: Filter by skill = ''SQL'' (should return Emp1)';
EXEC dbo.FilterTeamProfiles
    @ManagerID = @ManagerID,
    @Skill     = 'SQL',
    @RoleID    = NULL;

PRINT 'Test 2: Filter by role = 5 (Employee) only (should return Emp1)';
EXEC dbo.FilterTeamProfiles
    @ManagerID = @ManagerID,
    @Skill     = '',
    @RoleID    = 5;

PRINT 'Test 3: Filter by skill = ''C#'' and role = 4 (Line Manager) (should return Emp2)';
EXEC dbo.FilterTeamProfiles
    @ManagerID = @ManagerID,
    @Skill     = 'C#',
    @RoleID    = 4;

PRINT 'Test 4: Invalid manager (should fail)';
BEGIN TRY
    EXEC dbo.FilterTeamProfiles
        @ManagerID = 999999,
        @Skill     = 'SQL',
        @RoleID    = 5;
    PRINT 'Test 4 UNEXPECTED: no error raised';
END TRY
BEGIN CATCH
    PRINT 'Test 4 expected failure caught: ' + ERROR_MESSAGE();
END CATCH;
GO

/***** ViewTeamCertifications tests *****/

PRINT '--- ViewTeamCertifications tests ---';

DECLARE @ManagerID INT = 2;  -- e.g., Bob
DECLARE @Emp1      INT = 1;  -- e.g., Alice
DECLARE @Emp2      INT = 3;  -- e.g., John

-- Make employees part of this manager's team
UPDATE dbo.Employee
SET manager_id = @ManagerID,
    is_active  = 1
WHERE EmployeeID IN (@Emp1, @Emp2);

-- Ensure skills exist
IF NOT EXISTS (SELECT 1 FROM dbo.Skill WHERE SkillID = 1)
BEGIN
    INSERT INTO dbo.Skill (SkillID, skill_name, description)
    VALUES (1, 'SQL', 'Structured Query Language');
END;

IF NOT EXISTS (SELECT 1 FROM dbo.Skill WHERE SkillID = 2)
BEGIN
    INSERT INTO dbo.Skill (SkillID, skill_name, description)
    VALUES (2, 'Project Management', 'Managing projects and teams');
END;

-- Ensure verifications (certifications) exist
IF NOT EXISTS (SELECT 1 FROM dbo.Verification WHERE VerificationID = 1)
BEGIN
    INSERT INTO dbo.Verification
        (VerificationID, verification_type, issuer, issue_date, expiry_period)
    VALUES
        (1, 'PMP Certification', 'PMI', '2022-01-01', '2025-01-01');
END;

IF NOT EXISTS (SELECT 1 FROM dbo.Verification WHERE VerificationID = 2)
BEGIN
    INSERT INTO dbo.Verification
        (VerificationID, verification_type, issuer, issue_date, expiry_period)
    VALUES
        (2, 'SQL Expert', 'Tech Institute', '2023-05-10', '2026-05-10');
END;

-- Assign skills to employees
IF NOT EXISTS (
    SELECT 1 FROM dbo.EmployeeSkill
    WHERE employee_id = @Emp1 AND skill_id = 1
)
BEGIN
    INSERT INTO dbo.EmployeeSkill (employee_id, skill_id, proficiency_level)
    VALUES (@Emp1, 1, 'Advanced');
END;

IF NOT EXISTS (
    SELECT 1 FROM dbo.EmployeeSkill
    WHERE employee_id = @Emp2 AND skill_id = 2
)
BEGIN
    INSERT INTO dbo.EmployeeSkill (employee_id, skill_id, proficiency_level)
    VALUES (@Emp2, 2, 'Intermediate');
END;

-- Assign verifications (certifications) to employees
IF NOT EXISTS (
    SELECT 1 FROM dbo.EmployeeVerification
    WHERE employee_id = @Emp1 AND verification_id = 2
)
BEGIN
    INSERT INTO dbo.EmployeeVerification (employee_id, verification_id)
    VALUES (@Emp1, 2);
END;

IF NOT EXISTS (
    SELECT 1 FROM dbo.EmployeeVerification
    WHERE employee_id = @Emp2 AND verification_id = 1
)
BEGIN
    INSERT INTO dbo.EmployeeVerification (employee_id, verification_id)
    VALUES (@Emp2, 1);
END;

PRINT 'Test 1: View certifications and skills for manager''s team';
EXEC dbo.ViewTeamCertifications
    @ManagerID = @ManagerID;

PRINT 'Test 2: Invalid manager (should fail)';
BEGIN TRY
    EXEC dbo.ViewTeamCertifications
        @ManagerID = 999999;
    PRINT 'Test 2 UNEXPECTED: no error raised';
END TRY
BEGIN CATCH
    PRINT 'Test 2 expected failure caught: ' + ERROR_MESSAGE();
END CATCH;
GO

/***** AddManagerNotes tests *****/

PRINT '--- AddManagerNotes tests ---';

DECLARE @EmpID        INT = 1;  -- e.g., Alice
DECLARE @ManagerID    INT = 2;  -- e.g., Bob (actual manager)
DECLARE @OtherManager INT = 3;  -- some other employee, not the manager

-- Ensure employee 1 has manager 2
UPDATE dbo.Employee
SET manager_id = @ManagerID
WHERE EmployeeID = @EmpID;

PRINT 'Test 1: Add valid manager note';
BEGIN TRY
    EXEC dbo.AddManagerNotes
        @EmployeeID = @EmpID,
        @ManagerID  = @ManagerID,
        @Note       = 'Strong performance in Q4, recommended for leadership track.';
    PRINT 'Test 1 DONE';
END TRY
BEGIN CATCH
    PRINT 'Test 1 FAILED: ' + ERROR_MESSAGE();
END CATCH;

-- Inspect latest notes for this employee
SELECT TOP 5
    NoteID, employee_id, manager_id, note_content, created_at
FROM dbo.ManagerNotes
WHERE employee_id = @EmpID
ORDER BY created_at DESC;

PRINT 'Test 2: Wrong manager for this employee (should fail)';
BEGIN TRY
    EXEC dbo.AddManagerNotes
        @EmployeeID = @EmpID,
        @ManagerID  = @OtherManager,
        @Note       = 'This should not be allowed.';
    PRINT 'Test 2 UNEXPECTED: no error raised';
END TRY
BEGIN CATCH
    PRINT 'Test 2 expected failure caught: ' + ERROR_MESSAGE();
END CATCH;

PRINT 'Test 3: Empty note (should fail)';
BEGIN TRY
    EXEC dbo.AddManagerNotes
        @EmployeeID = @EmpID,
        @ManagerID  = @ManagerID,
        @Note       = '   ';
    PRINT 'Test 3 UNEXPECTED: no error raised';
END TRY
BEGIN CATCH
    PRINT 'Test 3 expected failure caught: ' + ERROR_MESSAGE();
END CATCH;
GO

/***** RecordManualAttendance tests *****/

PRINT '--- RecordManualAttendance tests ---';

DECLARE @EmpID       INT = 1;   -- e.g., Alice
DECLARE @RecordedBy  INT = 2;   -- e.g., Bob (manager/admin)
DECLARE @TestDate    DATE = '2025-01-10';

PRINT 'Test 1: Record manual attendance for a missing day';
BEGIN TRY
    EXEC dbo.RecordManualAttendance
        @EmployeeID = @EmpID,
        @Date       = @TestDate,
        @ClockIn    = '09:00',
        @ClockOut   = '17:00',
        @Reason     = 'Missed punch on timeclock.',
        @RecordedBy = @RecordedBy;
    PRINT 'Test 1 DONE';
END TRY
BEGIN CATCH
    PRINT 'Test 1 FAILED: ' + ERROR_MESSAGE();
END CATCH;

PRINT 'Check resulting Attendance row(s) for employee and date:';
SELECT a.*
FROM dbo.Attendance a
JOIN dbo.AttendanceLog l
    ON l.attendance_id = a.AttendanceID
WHERE a.employee_id = @EmpID
  AND CAST(l.[timestamp] AS DATE) = @TestDate;

PRINT 'Check corresponding AttendanceLog (audit trail):';
SELECT *
FROM dbo.AttendanceLog l
JOIN dbo.Attendance a
    ON a.AttendanceID = l.attendance_id
WHERE a.employee_id = @EmpID
  AND CAST(l.[timestamp] AS DATE) = @TestDate
ORDER BY l.[timestamp];

PRINT 'Test 2: Correct (update) existing manual attendance for same date';
BEGIN TRY
    EXEC dbo.RecordManualAttendance
        @EmployeeID = @EmpID,
        @Date       = @TestDate,
        @ClockIn    = '08:30',
        @ClockOut   = '17:30',
        @Reason     = 'Adjusted after verifying logs.',
        @RecordedBy = @RecordedBy;
    PRINT 'Test 2 DONE';
END TRY
BEGIN CATCH
    PRINT 'Test 2 FAILED: ' + ERROR_MESSAGE();
END CATCH;

PRINT 'Re-check Attendance and AttendanceLog after correction:';
SELECT a.*
FROM dbo.Attendance a
JOIN dbo.AttendanceLog l
    ON l.attendance_id = a.AttendanceID
WHERE a.employee_id = @EmpID
  AND CAST(l.[timestamp] AS DATE) = @TestDate;

SELECT *
FROM dbo.AttendanceLog l
JOIN dbo.Attendance a
    ON a.AttendanceID = l.attendance_id
WHERE a.employee_id = @EmpID
  AND CAST(l.[timestamp] AS DATE) = @TestDate
ORDER BY l.[timestamp];

PRINT 'Test 3: Invalid employee (should fail)';
BEGIN TRY
    EXEC dbo.RecordManualAttendance
        @EmployeeID = 999999,
        @Date       = @TestDate,
        @ClockIn    = '09:00',
        @ClockOut   = '17:00',
        @Reason     = 'Invalid employee test.',
        @RecordedBy = @RecordedBy;
    PRINT 'Test 3 UNEXPECTED: no error raised';
END TRY
BEGIN CATCH
    PRINT 'Test 3 expected failure caught: ' + ERROR_MESSAGE();
END CATCH;
GO

/***** ReviewMissedPunches tests *****/

PRINT '--- ReviewMissedPunches tests ---';

DECLARE @ManagerID INT = 2;   -- e.g., Bob (manager)
DECLARE @Emp1      INT = 1;   -- e.g., Alice
DECLARE @Emp2      INT = 3;   -- e.g., John
DECLARE @TestDate  DATE = '2025-01-15';

DECLARE @ExcID1 INT;
DECLARE @ExcID2 INT;
DECLARE @AttID1 INT;
DECLARE @AttID2 INT;

-- Make employees report to this manager
UPDATE dbo.Employee
SET manager_id = @ManagerID
WHERE EmployeeID IN (@Emp1, @Emp2);

-- Create attendance-related exceptions for the test date
SELECT @ExcID1 = ISNULL(MAX(ExceptionID), 0) + 1
FROM dbo.Exception;

SET @ExcID2 = @ExcID1 + 1;

INSERT INTO dbo.Exception
    (ExceptionID, name,              category,      date,        status)
VALUES
    (@ExcID1,    'Missed clock-out', 'ATTENDANCE',  @TestDate,   'FLAGGED'),
    (@ExcID2,    'Old issue',        'ATTENDANCE',  @TestDate,   'RESOLVED');

-- Create matching Attendance records and link exceptions
SELECT @AttID1 = ISNULL(MAX(AttendanceID), 0) + 1
FROM dbo.Attendance;

SET @AttID2 = @AttID1 + 1;

INSERT INTO dbo.Attendance
    (AttendanceID, employee_id, entry_time, exit_time, duration, login_method, logout_method, exception_id)
VALUES
    (@AttID1, @Emp1, '09:00', '17:00', 480, 'BIOMETRIC', 'BIOMETRIC', @ExcID1),  -- flagged
    (@AttID2, @Emp2, '09:00', '17:00', 480, 'BIOMETRIC', 'BIOMETRIC', @ExcID2);  -- resolved

PRINT 'Test 1: Review missed punches for manager and date (should show only FLAGGED/Open/Pending)';
EXEC dbo.ReviewMissedPunches
    @ManagerID = @ManagerID,
    @Date      = @TestDate;

PRINT 'Test 2: Invalid manager (should fail)';
BEGIN TRY
    EXEC dbo.ReviewMissedPunches
        @ManagerID = 999999,
        @Date      = @TestDate;
    PRINT 'Test 2 UNEXPECTED: no error raised';
END TRY
BEGIN CATCH
    PRINT 'Test 2 expected failure caught: ' + ERROR_MESSAGE();
END CATCH;
GO

/***** ApproveTimeRequest tests *****/

PRINT '--- ApproveTimeRequest tests ---';

DECLARE @ManagerID INT = 2;   -- e.g., Bob (manager)
DECLARE @EmpID     INT = 1;   -- e.g., Alice (employee)
DECLARE @ReqID     INT;
DECLARE @Today     DATE = '2025-01-20';

-- Ensure employee reports to this manager
UPDATE dbo.Employee
SET manager_id = @ManagerID
WHERE EmployeeID = @EmpID;

-- Create a pending AttendanceCorrectionRequest
SELECT @ReqID = ISNULL(MAX(RequestID), 0) + 1
FROM dbo.AttendanceCorrectionRequest;

INSERT INTO dbo.AttendanceCorrectionRequest
    (RequestID, employee_id, date, correction_type, reason, status, recommended_by)
VALUES
    (@ReqID, @EmpID, @Today, 'Missed clock-out', 'Forgot to punch out', 'PENDING', @ManagerID);

PRINT 'Test 1: Approve pending time request with valid manager';
BEGIN TRY
    EXEC dbo.ApproveTimeRequest
        @RequestID = @ReqID,
        @ManagerID = @ManagerID,
        @Decision  = 'APPROVED',
        @Comments  = 'Verified against system logs.';
    PRINT 'Test 1 DONE';
END TRY
BEGIN CATCH
    PRINT 'Test 1 FAILED: ' + ERROR_MESSAGE();
END CATCH;

PRINT 'Check updated AttendanceCorrectionRequest row:';
SELECT *
FROM dbo.AttendanceCorrectionRequest
WHERE RequestID = @ReqID;

PRINT 'Check ManagerNotes for this decision:';
SELECT TOP 5 *
FROM dbo.ManagerNotes
WHERE employee_id = @EmpID
ORDER BY created_at DESC;

PRINT 'Test 2: Try to re-approve already processed request (should fail)';
BEGIN TRY
    EXEC dbo.ApproveTimeRequest
        @RequestID = @ReqID,
        @ManagerID = @ManagerID,
        @Decision  = 'APPROVED',
        @Comments  = 'Second attempt.';
    PRINT 'Test 2 UNEXPECTED: no error raised';
END TRY
BEGIN CATCH
    PRINT 'Test 2 expected failure caught: ' + ERROR_MESSAGE();
END CATCH;

PRINT 'Test 3: Wrong manager (not the employee''s manager) (should fail)';
BEGIN TRY
    EXEC dbo.ApproveTimeRequest
        @RequestID = @ReqID,
        @ManagerID = 999999,
        @Decision  = 'REJECTED',
        @Comments  = 'Unauthorized manager.';
    PRINT 'Test 3 UNEXPECTED: no error raised';
END TRY
BEGIN CATCH
    PRINT 'Test 3 expected failure caught: ' + ERROR_MESSAGE();
END CATCH;
GO

/***** ViewLeaveRequest tests *****/

PRINT '--- ViewLeaveRequest tests ---';

DECLARE @ManagerID      INT = 2;   -- e.g., Bob
DECLARE @EmpID          INT = 1;   -- e.g., Alice
DECLARE @LeaveTypeID    INT = 1;
DECLARE @LeaveRequestID INT;
DECLARE @TestDate       DATE = '2025-02-01';

-- Ensure employee reports to this manager
UPDATE dbo.Employee
SET manager_id = @ManagerID
WHERE EmployeeID = @EmpID;

-- Ensure a Leave type exists
IF NOT EXISTS (SELECT 1 FROM dbo.Leave WHERE LeaveID = @LeaveTypeID)
BEGIN
    INSERT INTO dbo.Leave (LeaveID, leave_type, leave_description)
    VALUES (@LeaveTypeID, 'Annual Leave', 'Standard annual leave');
END;

-- Create a leave request for this employee
SELECT @LeaveRequestID = ISNULL(MAX(RequestID), 0) + 1
FROM dbo.LeaveRequest;

INSERT INTO dbo.LeaveRequest
    (RequestID, employee_id, leave_id, justification, duration, approval_timing, status)
VALUES
    (@LeaveRequestID, @EmpID, @LeaveTypeID,
     'Family trip', 5, NULL, 'PENDING');

PRINT 'Test 1: Valid manager viewing own assigned leave request';
EXEC dbo.ViewLeaveRequest
    @LeaveRequestID = @LeaveRequestID,
    @ManagerID      = @ManagerID;

PRINT 'Test 2: Wrong manager (should fail)';
BEGIN TRY
    EXEC dbo.ViewLeaveRequest
        @LeaveRequestID = @LeaveRequestID,
        @ManagerID      = 999999;
    PRINT 'Test 2 UNEXPECTED: no error raised';
END TRY
BEGIN CATCH
    PRINT 'Test 2 expected failure caught: ' + ERROR_MESSAGE();
END CATCH;

PRINT 'Test 3: Non-existing leave request (should fail)';
BEGIN TRY
    EXEC dbo.ViewLeaveRequest
        @LeaveRequestID = 999999,
        @ManagerID      = @ManagerID;
    PRINT 'Test 3 UNEXPECTED: no error raised';
END TRY
BEGIN CATCH
    PRINT 'Test 3 expected failure caught: ' + ERROR_MESSAGE();
END CATCH;
GO
/***** ApproveLeaveRequest tests *****/

PRINT '--- ApproveLeaveRequest tests ---';

DECLARE @ManagerID      INT = 2;   -- e.g., Bob
DECLARE @EmpID          INT = 1;   -- e.g., Alice
DECLARE @LeaveTypeID    INT = 1;
DECLARE @LeaveRequestID INT;

-- Ensure employee reports to this manager
UPDATE dbo.Employee
SET manager_id = @ManagerID
WHERE EmployeeID = @EmpID;

-- Ensure a Leave type exists
IF NOT EXISTS (SELECT 1 FROM dbo.Leave WHERE LeaveID = @LeaveTypeID)
BEGIN
    INSERT INTO dbo.Leave (LeaveID, leave_type, leave_description)
    VALUES (@LeaveTypeID, 'Annual Leave', 'Standard annual leave');
END;

-- Create a pending leave request
SELECT @LeaveRequestID = ISNULL(MAX(RequestID), 0) + 1
FROM dbo.LeaveRequest;

INSERT INTO dbo.LeaveRequest
    (RequestID, employee_id, leave_id, justification, duration, approval_timing, status)
VALUES
    (@LeaveRequestID, @EmpID, @LeaveTypeID,
     'Conference trip', 3, NULL, 'PENDING');

PRINT 'Test 1: Approve leave request with valid manager';
BEGIN TRY
    EXEC dbo.ApproveLeaveRequest
        @LeaveRequestID = @LeaveRequestID,
        @ManagerID      = @ManagerID;
    PRINT 'Test 1 DONE';
END TRY
BEGIN CATCH
    PRINT 'Test 1 FAILED: ' + ERROR_MESSAGE();
END CATCH;

PRINT 'Check updated LeaveRequest row:';
SELECT *
FROM dbo.LeaveRequest
WHERE RequestID = @LeaveRequestID;

PRINT 'Check ManagerNotes audit for approval:';
SELECT TOP 5 *
FROM dbo.ManagerNotes
WHERE employee_id = @EmpID
ORDER BY created_at DESC;

PRINT 'Test 2: Try to re-approve already processed request (should fail)';
BEGIN TRY
    EXEC dbo.ApproveLeaveRequest
        @LeaveRequestID = @LeaveRequestID,
        @ManagerID      = @ManagerID;
    PRINT 'Test 2 UNEXPECTED: no error raised';
END TRY
BEGIN CATCH
    PRINT 'Test 2 expected failure caught: ' + ERROR_MESSAGE();
END CATCH;

PRINT 'Test 3: Wrong manager (should fail)';
BEGIN TRY
    EXEC dbo.ApproveLeaveRequest
        @LeaveRequestID = @LeaveRequestID,
        @ManagerID      = 999999;
    PRINT 'Test 3 UNEXPECTED: no error raised';
END TRY
BEGIN CATCH
    PRINT 'Test 3 expected failure caught: ' + ERROR_MESSAGE();
END CATCH;
GO

/***** RejectLeaveRequest tests *****/

PRINT '--- RejectLeaveRequest tests ---';

DECLARE @ManagerID      INT = 2;   -- e.g., Bob
DECLARE @EmpID          INT = 1;   -- e.g., Alice
DECLARE @LeaveTypeID    INT = 1;
DECLARE @LeaveRequestID INT;

-- Ensure employee reports to this manager
UPDATE dbo.Employee
SET manager_id = @ManagerID
WHERE EmployeeID = @EmpID;

-- Ensure a Leave type exists
IF NOT EXISTS (SELECT 1 FROM dbo.Leave WHERE LeaveID = @LeaveTypeID)
BEGIN
    INSERT INTO dbo.Leave (LeaveID, leave_type, leave_description)
    VALUES (@LeaveTypeID, 'Annual Leave', 'Standard annual leave');
END;

-- Create a pending leave request
SELECT @LeaveRequestID = ISNULL(MAX(RequestID), 0) + 1
FROM dbo.LeaveRequest;

INSERT INTO dbo.LeaveRequest
    (RequestID, employee_id, leave_id, justification, duration, approval_timing, status)
VALUES
    (@LeaveRequestID, @EmpID, @LeaveTypeID,
     'Personal reasons', 2, NULL, 'PENDING');

PRINT 'Test 1: Reject leave request with valid manager and reason';
BEGIN TRY
    EXEC dbo.RejectLeaveRequest
        @LeaveRequestID = @LeaveRequestID,
        @ManagerID      = @ManagerID,
        @Reason         = 'Team workload is critical during requested dates.';
    PRINT 'Test 1 DONE';
END TRY
BEGIN CATCH
    PRINT 'Test 1 FAILED: ' + ERROR_MESSAGE();
END CATCH;

PRINT 'Check updated LeaveRequest row:';
SELECT *
FROM dbo.LeaveRequest
WHERE RequestID = @LeaveRequestID;

PRINT 'Check ManagerNotes audit for rejection:';
SELECT TOP 5 *
FROM dbo.ManagerNotes
WHERE employee_id = @EmpID
ORDER BY created_at DESC;

PRINT 'Test 2: Try to re-reject already processed request (should fail)';
BEGIN TRY
    EXEC dbo.RejectLeaveRequest
        @LeaveRequestID = @LeaveRequestID,
        @ManagerID      = @ManagerID,
        @Reason         = 'Second attempt.';
    PRINT 'Test 2 UNEXPECTED: no error raised';
END TRY
BEGIN CATCH
    PRINT 'Test 2 expected failure caught: ' + ERROR_MESSAGE();
END CATCH;

PRINT 'Test 3: Wrong manager (should fail)';
BEGIN TRY
    EXEC dbo.RejectLeaveRequest
        @LeaveRequestID = @LeaveRequestID,
        @ManagerID      = 999999,
        @Reason         = 'Not authorized.';
    PRINT 'Test 3 UNEXPECTED: no error raised';
END TRY
BEGIN CATCH
    PRINT 'Test 3 expected failure caught: ' + ERROR_MESSAGE();
END CATCH;
GO

/***** DelegateLeaveApproval tests *****/

PRINT '--- DelegateLeaveApproval tests ---';

DECLARE @ManagerID  INT = 2;  -- e.g., Bob
DECLARE @DelegateID INT = 3;  -- e.g., John

-- Ensure both employees exist (and just treat ManagerID as a manager logically)
-- (No extra setup needed beyond existence)

PRINT 'Test 1: Valid delegation';
BEGIN TRY
    EXEC dbo.DelegateLeaveApproval
        @ManagerID  = @ManagerID,
        @DelegateID = @DelegateID,
        @StartDate  = '2025-03-01',
        @EndDate    = '2025-03-31';
    PRINT 'Test 1 DONE';
END TRY
BEGIN CATCH
    PRINT 'Test 1 FAILED: ' + ERROR_MESSAGE();
END CATCH;

PRINT 'Check ManagerNotes for delegation record:';
SELECT TOP 5
    NoteID, employee_id, manager_id, note_content, created_at
FROM dbo.ManagerNotes
WHERE employee_id = @DelegateID
  AND manager_id  = @ManagerID
ORDER BY created_at DESC;

PRINT 'Test 2: StartDate after EndDate (should fail)';
BEGIN TRY
    EXEC dbo.DelegateLeaveApproval
        @ManagerID  = @ManagerID,
        @DelegateID = @DelegateID,
        @StartDate  = '2025-04-10',
        @EndDate    = '2025-04-01';
    PRINT 'Test 2 UNEXPECTED: no error raised';
END TRY
BEGIN CATCH
    PRINT 'Test 2 expected failure caught: ' + ERROR_MESSAGE();
END CATCH;

PRINT 'Test 3: Manager and delegate same person (should fail)';
BEGIN TRY
    EXEC dbo.DelegateLeaveApproval
        @ManagerID  = @ManagerID,
        @DelegateID = @ManagerID,
        @StartDate  = '2025-05-01',
        @EndDate    = '2025-05-15';
    PRINT 'Test 3 UNEXPECTED: no error raised';
END TRY
BEGIN CATCH
    PRINT 'Test 3 expected failure caught: ' + ERROR_MESSAGE();
END CATCH;
GO

/***** NotifyNewLeaveRequest tests *****/

PRINT '--- NotifyNewLeaveRequest tests ---';

DECLARE @ManagerID      INT = 2;   -- e.g., Bob
DECLARE @EmpID          INT = 1;   -- e.g., Alice
DECLARE @LeaveTypeID    INT = 1;
DECLARE @LeaveRequestID INT;
DECLARE @LatestNotifID  INT;

-- Ensure employee reports to this manager
UPDATE dbo.Employee
SET manager_id = @ManagerID
WHERE EmployeeID = @EmpID;

-- Ensure a Leave type exists
IF NOT EXISTS (SELECT 1 FROM dbo.Leave WHERE LeaveID = @LeaveTypeID)
BEGIN
    INSERT INTO dbo.Leave (LeaveID, leave_type, leave_description)
    VALUES (@LeaveTypeID, 'Annual Leave', 'Standard annual leave');
END;

-- Create a leave request for this employee
SELECT @LeaveRequestID = ISNULL(MAX(RequestID), 0) + 1
FROM dbo.LeaveRequest;

INSERT INTO dbo.LeaveRequest
    (RequestID, employee_id, leave_id, justification, duration, approval_timing, status)
VALUES
    (@LeaveRequestID, @EmpID, @LeaveTypeID,
     'Family vacation', 7, NULL, 'PENDING');

PRINT 'Test 1: Notify manager for new leave request';
BEGIN TRY
    EXEC dbo.NotifyNewLeaveRequest
        @ManagerID = @ManagerID,
        @RequestID = @LeaveRequestID;
    PRINT 'Test 1 DONE';
END TRY
BEGIN CATCH
    PRINT 'Test 1 FAILED: ' + ERROR_MESSAGE();
END CATCH;

-- Use notification_id here, not NotificationID
SELECT @LatestNotifID = MAX(notification_id)
FROM dbo.EmployeeNotification
WHERE employee_id = @ManagerID;

PRINT 'Latest notification for manager:';
SELECT n.NotificationID,
       n.mesage_content,
       n.timestamp,
       n.urgency,
       en.employee_id,
       en.delivery_status,
       en.delivered_at
FROM dbo.Notification n
JOIN dbo.EmployeeNotification en
    ON n.NotificationID = en.notification_id
WHERE en.notification_id = @LatestNotifID;

PRINT 'Test 2: Wrong manager (not employee''s manager) (should fail)';
BEGIN TRY
    EXEC dbo.NotifyNewLeaveRequest
        @ManagerID = 999999,
        @RequestID = @LeaveRequestID;
    PRINT 'Test 2 UNEXPECTED: no error raised';
END TRY
BEGIN CATCH
    PRINT 'Test 2 expected failure caught: ' + ERROR_MESSAGE();
END CATCH;

PRINT 'Test 3: Non-existing request (should fail)';
BEGIN TRY
    EXEC dbo.NotifyNewLeaveRequest
        @ManagerID = @ManagerID,
        @RequestID = 999999;
    PRINT 'Test 3 UNEXPECTED: no error raised';
END TRY
BEGIN CATCH
    PRINT 'Test 3 expected failure caught: ' + ERROR_MESSAGE();
END CATCH;
GO

--Employee Procedures Tests

/***** 1)SubmitLeaveRequest tests *****/

PRINT '--- SubmitLeaveRequest tests ---';

-- Ensure leave types exist
IF NOT EXISTS (SELECT 1 FROM dbo.[Leave] WHERE LeaveID = 1)
    INSERT INTO dbo.[Leave] (LeaveID, leave_type, leave_description) VALUES (1, 'Vacation', 'Paid vacation');

IF NOT EXISTS (SELECT 1 FROM dbo.[Leave] WHERE LeaveID = 2)
    INSERT INTO dbo.[Leave] (LeaveID, leave_type, leave_description) VALUES (2, 'Sick', 'Sick leave');

-- Create a test employee if not exists
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

PRINT 'Test employee id: ' + CAST(@TestEmp AS VARCHAR(12));


PRINT 'Test 1: Normal submission';
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
END CATCH;


PRINT 'Test 2: Empty reason (should succeed)';
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
END CATCH;


PRINT 'Test 3: Invalid dates (should fail)';
BEGIN TRY
    EXEC dbo.SubmitLeaveRequest
        @EmployeeID = @TestEmp,
        @LeaveTypeID = 1,
        @StartDate = '2025-12-10',
        @EndDate   = '2025-12-01',
        @Reason    = 'Invalid test';
    PRINT 'ERROR: Test 3 passed unexpectedly';
END TRY
BEGIN CATCH
    PRINT 'Test 3 expected failure caught: ' + ERROR_MESSAGE();
END CATCH;


PRINT 'Test 4: Non-existing employee (should fail)';
BEGIN TRY
    EXEC dbo.SubmitLeaveRequest
        @EmployeeID = 999999,
        @LeaveTypeID = 1,
        @StartDate = '2025-11-01',
        @EndDate   = '2025-11-02',
        @Reason    = 'Should fail';
    PRINT 'ERROR: Test 4 passed unexpectedly';
END TRY
BEGIN CATCH
    PRINT 'Test 4 expected failure caught: ' + ERROR_MESSAGE();
END CATCH;


PRINT 'Test 5: Non-existing leave type (should fail)';
BEGIN TRY
    EXEC dbo.SubmitLeaveRequest
        @EmployeeID = @TestEmp,
        @LeaveTypeID = 9999,
        @StartDate = '2025-11-10',
        @EndDate   = '2025-11-11',
        @Reason    = 'Should fail';
    PRINT 'ERROR: Test 5 passed unexpectedly';
END TRY
BEGIN CATCH
    PRINT 'Test 5 expected failure caught: ' + ERROR_MESSAGE();
END CATCH;


PRINT 'Show inserted rows:';
SELECT TOP (10) *
FROM dbo.LeaveRequest
WHERE employee_id = @TestEmp
ORDER BY RequestID DESC;
GO
/***** 2)GetLeaveBalance tests *****/

PRINT '--- GetLeaveBalance tests ---';

DECLARE @Emp INT = 1;

PRINT 'Test 1: Normal check';
EXEC dbo.GetLeaveBalance @EmployeeID = @Emp;

PRINT 'Test 2: Non-existing employee (should fail)';
BEGIN TRY
    EXEC dbo.GetLeaveBalance @EmployeeID = 999999;
    PRINT 'ERROR: should have failed';
END TRY
BEGIN CATCH
    PRINT 'Expected failure: ' + ERROR_MESSAGE();
END CATCH;

PRINT 'Show approved leaves for employee:';
SELECT * FROM dbo.LeaveRequest WHERE employee_id = @Emp AND status = 'APPROVED';
GO


/***** 3)RecordAttendance tests *****/

PRINT '--- RecordAttendance tests ---';

DECLARE @EmpID   INT = 1;
DECLARE @ShiftID INT;

-- Ensure a shift exists for this employee
IF NOT EXISTS (SELECT 1 FROM dbo.ShiftSchedule WHERE employee_id = @EmpID)
BEGIN
    SELECT @ShiftID = ISNULL(MAX(ShiftID), 0) + 1 FROM dbo.ShiftSchedule;
    INSERT INTO dbo.ShiftSchedule (ShiftID, employee_id, start_date, end_date, status)
    VALUES (@ShiftID, @EmpID, '2025-01-01', '2025-01-01', 'ACTIVE');
END
ELSE
    SELECT TOP 1 @ShiftID = ShiftID FROM dbo.ShiftSchedule WHERE employee_id = @EmpID;

PRINT 'Test 1: Valid attendance record';
BEGIN TRY
    EXEC dbo.RecordAttendance
        @EmployeeID = @EmpID,
        @ShiftID    = @ShiftID,
        @EntryTime  = '09:00',
        @ExitTime   = '17:00';
    PRINT 'Test 1 DONE';
END TRY
BEGIN CATCH
    PRINT 'Test 1 FAILED: ' + ERROR_MESSAGE();
END CATCH;

PRINT 'Check Attendance rows for employee:';
SELECT TOP 10 *
FROM dbo.Attendance
WHERE employee_id = @EmpID
ORDER BY AttendanceID DESC;

PRINT 'Test 2: Non-existing employee (should fail)';
BEGIN TRY
    EXEC dbo.RecordAttendance
        @EmployeeID = 999999,
        @ShiftID    = @ShiftID,
        @EntryTime  = '09:00',
        @ExitTime   = '17:00';
    PRINT 'Test 2 UNEXPECTED: no error raised';
END TRY
BEGIN CATCH
    PRINT 'Test 2 expected failure caught: ' + ERROR_MESSAGE();
END CATCH;
GO

/***** 4)SubmitReimbursement tests *****/

PRINT '--- SubmitReimbursement tests ---';

DECLARE @EmpID INT = 3001;

IF NOT EXISTS (SELECT 1 FROM dbo.Employee WHERE EmployeeID = @EmpID)
BEGIN
    INSERT INTO dbo.Employee
        (EmployeeID, first_name, last_name, national_id, date_of_birth,
         country_of_birth, phone, email, address, employment_progress,
         account_status, employment_status, hire_date, is_active,
         profile_completion_percentage)
    VALUES
        (@EmpID, 'Reim', 'Test', 'NID3001', '1990-01-01',
         'TestCountry', '0000000', 'reim@test.com', 'TestAddr',
         'Onboarded', 'ACTIVE', 'FULL_TIME', '2022-01-01', 1, 100);
END;

PRINT 'Test 1: Valid reimbursement submission';
EXEC dbo.SubmitReimbursement
    @EmployeeID = @EmpID,
    @ExpenseType = 'Travel',
    @Amount = 150.75;

PRINT 'Test 2: Missing expense type (should fail)';
BEGIN TRY
    EXEC dbo.SubmitReimbursement
        @EmployeeID = @EmpID,
        @ExpenseType = '',
        @Amount = 100;
    PRINT 'UNEXPECTED: test passed';
END TRY
BEGIN CATCH
    PRINT 'Expected failure: ' + ERROR_MESSAGE();
END CATCH;

PRINT 'Test 3: Invalid amount (should fail)';
BEGIN TRY
    EXEC dbo.SubmitReimbursement
        @EmployeeID = @EmpID,
        @ExpenseType = 'Meals',
        @Amount = -50;
    PRINT 'UNEXPECTED: test passed';
END TRY
BEGIN CATCH
    PRINT 'Expected failure: ' + ERROR_MESSAGE();
END CATCH;

PRINT 'Test 4: Non-existing employee (should fail)';
BEGIN TRY
    EXEC dbo.SubmitReimbursement
        @EmployeeID = 999999,
        @ExpenseType = 'Taxi',
        @Amount = 30;
    PRINT 'UNEXPECTED: test passed';
END TRY
BEGIN CATCH
    PRINT 'Expected failure: ' + ERROR_MESSAGE();
END CATCH;



/***** 5)AddEmployeeSkill tests *****/

PRINT '--- AddEmployeeSkill tests ---';

DECLARE @EmpID INT = 4001;

IF NOT EXISTS (SELECT 1 FROM dbo.Employee WHERE EmployeeID = @EmpID)
BEGIN
    INSERT INTO dbo.Employee
        (EmployeeID, first_name, last_name, national_id, date_of_birth,
         country_of_birth, phone, email, address, employment_progress,
         account_status, employment_status, hire_date, is_active,
         profile_completion_percentage)
    VALUES
        (@EmpID, 'Skill', 'Test', 'NID4001', '1990-01-01',
         'TestCountry', '0000000', 'skill@test.com', 'TestAddr',
         'Onboarded', 'ACTIVE', 'FULL_TIME', '2022-01-01', 1, 100);
END;

PRINT 'Test 1: Add new skill';
EXEC dbo.AddEmployeeSkill
    @EmployeeID = @EmpID,
    @SkillName  = 'Teamwork';

PRINT 'Test 2: Add same skill again (should fail)';
BEGIN TRY
    EXEC dbo.AddEmployeeSkill
        @EmployeeID = @EmpID,
        @SkillName  = 'Teamwork';
    PRINT 'ERROR: Test 2 passed unexpectedly';
END TRY
BEGIN CATCH
    PRINT 'Expected failure: ' + ERROR_MESSAGE();
END CATCH;

PRINT 'Test 3: Add another skill';
EXEC dbo.AddEmployeeSkill
    @EmployeeID = @EmpID,
    @SkillName  = 'Communication';

PRINT 'Test 4: Non-existing employee (should fail)';
BEGIN TRY
    EXEC dbo.AddEmployeeSkill
        @EmployeeID = 999999,
        @SkillName  = 'Something';
    PRINT 'ERROR: Test 4 passed unexpectedly';
END TRY
BEGIN CATCH
    PRINT 'Expected failure: ' + ERROR_MESSAGE();
END CATCH;

SELECT *
FROM dbo.EmployeeSkill
WHERE employee_id = @EmpID;





/***** 6)ViewAssignedShifts tests *****/

PRINT '--- ViewAssignedShifts tests ---';

DECLARE @EmpID INT = 5001;

IF NOT EXISTS (SELECT 1 FROM dbo.Department WHERE DepartmentID = 50)
BEGIN
    INSERT INTO dbo.Department (DepartmentID, department_name, purpose, department_head_id)
    VALUES (50, 'Test Department', 'For shift tests', NULL);
END;

IF NOT EXISTS (SELECT 1 FROM dbo.Employee WHERE EmployeeID = @EmpID)
BEGIN
    INSERT INTO dbo.Employee
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
        employment_progress,
        account_status,
        employment_status,
        hire_date,
        is_active,
        department_id,
        profile_completion_percentage
    )
    VALUES
    (
        @EmpID,
        'Shift',
        'Viewer',
        'NID5001',
        '1990-01-01',
        'TestCountry',
        '0000000000',
        'shift.viewer@test.com',
        'Test Address',
        'Onboarded',
        'ACTIVE',
        'FULL_TIME',
        '2024-01-01',
        1,
        50,
        100
    );
END;

DECLARE @ShiftA INT = 9101;
DECLARE @ShiftB INT = 9102;

IF NOT EXISTS (SELECT 1 FROM dbo.ShiftSchedule WHERE ShiftID = @ShiftA)
BEGIN
    INSERT INTO dbo.ShiftSchedule (ShiftID, employee_id, start_date, end_date, status)
    VALUES (@ShiftA, @EmpID, '2025-12-01T09:00:00', '2025-12-01T17:00:00', 'ACTIVE');
END;

IF NOT EXISTS (SELECT 1 FROM dbo.ShiftSchedule WHERE ShiftID = @ShiftB)
BEGIN
    INSERT INTO dbo.ShiftSchedule (ShiftID, employee_id, start_date, end_date, status)
    VALUES (@ShiftB, @EmpID, '2025-12-02T10:00:00', '2025-12-02T18:00:00', 'ACTIVE');
END;

PRINT 'Test 1: ViewAssignedShifts for existing employee with shifts';
EXEC dbo.ViewAssignedShifts @EmployeeID = @EmpID;

PRINT 'Test 2: ViewAssignedShifts for employee with no shifts';
DECLARE @EmpNoShift INT = 5002;

IF NOT EXISTS (SELECT 1 FROM dbo.Employee WHERE EmployeeID = @EmpNoShift)
BEGIN
    INSERT INTO dbo.Employee
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
        employment_progress,
        account_status,
        employment_status,
        hire_date,
        is_active,
        department_id,
        profile_completion_percentage
    )
    VALUES
    (
        @EmpNoShift,
        'NoShift',
        'Employee',
        'NID5002',
        '1991-01-01',
        'TestCountry',
        '0000000001',
        'noshift.employee@test.com',
        'Test Address 2',
        'Onboarded',
        'ACTIVE',
        'FULL_TIME',
        '2024-01-01',
        1,
        50,
        100
    );
END;

EXEC dbo.ViewAssignedShifts @EmployeeID = @EmpNoShift;

PRINT 'Test 3: ViewAssignedShifts for non-existing employee (should fail)';
BEGIN TRY
    EXEC dbo.ViewAssignedShifts @EmployeeID = 999999;
    PRINT 'Test 3 UNEXPECTED: no error raised';
END TRY
BEGIN CATCH
    PRINT 'Test 3 expected failure: ' + ERROR_MESSAGE();
END CATCH;


/***** 7)ViewMyContracts tests *****/

PRINT '--- ViewMyContracts tests ---';

DECLARE @EmpWithContract INT = 7001;
DECLARE @EmpNoContract   INT = 7002;
DECLARE @ContractActive  INT = 8101;
DECLARE @ContractTerm    INT = 8102;

IF NOT EXISTS (SELECT 1 FROM dbo.Contract WHERE ContractID = @ContractActive)
BEGIN
    INSERT INTO dbo.Contract (ContractID, type, start_date, end_date, current_state)
    VALUES (@ContractActive, 'Full-Time', '2024-01-01', '2026-12-31', 'ACTIVE');
END;

IF NOT EXISTS (SELECT 1 FROM dbo.Contract WHERE ContractID = @ContractTerm)
BEGIN
    INSERT INTO dbo.Contract (ContractID, type, start_date, end_date, current_state)
    VALUES (@ContractTerm, 'Consultant', '2022-01-01', '2023-12-31', 'TERMINATED');
END;

IF NOT EXISTS (SELECT 1 FROM dbo.Termination WHERE TerminationID = 9101)
BEGIN
    INSERT INTO dbo.Termination (TerminationID, date, reason, contract_id)
    VALUES (9101, '2023-12-31', 'End of fixed term', @ContractTerm);
END;

IF NOT EXISTS (SELECT 1 FROM dbo.Employee WHERE EmployeeID = @EmpWithContract)
BEGIN
    INSERT INTO dbo.Employee (EmployeeID, first_name, last_name, hire_date, is_active, contract_id)
    VALUES (@EmpWithContract, 'Active', 'Contract', '2024-01-01', 1, @ContractActive);
END
ELSE
BEGIN
    UPDATE dbo.Employee
    SET contract_id = @ContractActive
    WHERE EmployeeID = @EmpWithContract;
END;

IF NOT EXISTS (SELECT 1 FROM dbo.Employee WHERE EmployeeID = @EmpNoContract)
BEGIN
    INSERT INTO dbo.Employee (EmployeeID, first_name, last_name, hire_date, is_active, contract_id)
    VALUES (@EmpNoContract, 'Terminated', 'Contract', '2022-01-01', 0, @ContractTerm);
END
ELSE
BEGIN
    UPDATE dbo.Employee
    SET contract_id = @ContractTerm
    WHERE EmployeeID = @EmpNoContract;
END;

PRINT 'Test 1: Employee with active contract';
EXEC dbo.ViewMyContracts @EmployeeID = @EmpWithContract;

PRINT 'Test 2: Employee with terminated contract';
EXEC dbo.ViewMyContracts @EmployeeID = @EmpNoContract;

PRINT 'Test 3: Non-existing employee (should fail)';
BEGIN TRY
    EXEC dbo.ViewMyContracts @EmployeeID = 999999;
    PRINT 'Test 3 UNEXPECTED: no error raised';
END TRY
BEGIN CATCH
    PRINT 'Test 3 expected failure: ' + ERROR_MESSAGE();
END CATCH;

/***** 8)ViewMyPayroll tests *****/

PRINT '--- ViewMyPayroll tests ---';

DECLARE @EmpWithPayroll INT = 8001;
DECLARE @EmpNoPayroll   INT = 8002;

IF NOT EXISTS (SELECT 1 FROM dbo.Employee WHERE EmployeeID = @EmpWithPayroll)
BEGIN
    INSERT INTO dbo.Employee (EmployeeID, first_name, last_name, hire_date, is_active)
    VALUES (@EmpWithPayroll, 'Payroll', 'History', '2024-01-01', 1);
END;

IF NOT EXISTS (SELECT 1 FROM dbo.Employee WHERE EmployeeID = @EmpNoPayroll)
BEGIN
    INSERT INTO dbo.Employee (EmployeeID, first_name, last_name, hire_date, is_active)
    VALUES (@EmpNoPayroll, 'No', 'Payroll', '2024-01-01', 1);
END;

-- Clean old test rows for these employees
DELETE FROM dbo.Payroll WHERE employee_id IN (@EmpWithPayroll, @EmpNoPayroll);

-- Insert sample payroll for @EmpWithPayroll
INSERT INTO dbo.Payroll
    (PayrollID, employee_id, taxes, period_start, period_end,
     base_amount, adjustments, contributions, actual_pay, net_salary, payment_date)
VALUES
    (90001, @EmpWithPayroll, 500.00, '2025-01-01', '2025-01-31', 5000.00, 200.00, 300.00, 5500.00, 4700.00, '2025-02-01'),
    (90002, @EmpWithPayroll, 520.00, '2025-02-01', '2025-02-28', 5100.00, 150.00, 320.00, 5570.00, 4750.00, '2025-03-01');

PRINT 'Test 1: Employee with payroll history (should return 2 rows)';
EXEC dbo.ViewMyPayroll @EmployeeID = @EmpWithPayroll;

PRINT 'Test 2: Employee with no payroll history (should return 0 rows, no error)';
EXEC dbo.ViewMyPayroll @EmployeeID = @EmpNoPayroll;

PRINT 'Test 3: Non-existing employee (should raise error)';
BEGIN TRY
    EXEC dbo.ViewMyPayroll @EmployeeID = 999999;
    PRINT 'Test 3 UNEXPECTED: no error raised';
END TRY
BEGIN CATCH
    PRINT 'Test 3 expected failure: ' + ERROR_MESSAGE();
END CATCH;
/***** UpdatePersonalDetails tests *****/

PRINT '--- UpdatePersonalDetails tests ---';

DECLARE @EmpID INT = 9001;

-- Create test employee
IF NOT EXISTS (SELECT 1 FROM dbo.Employee WHERE EmployeeID = @EmpID)
BEGIN
    INSERT INTO dbo.Employee
        (EmployeeID, first_name, last_name, hire_date, is_active, phone, address)
    VALUES
        (@EmpID, 'Update', 'Test', '2024-01-01', 1, '0000', 'Old Address');
END;

PRINT 'Test 1: Valid update';
EXEC dbo.UpdatePersonalDetails
     @EmployeeID = @EmpID,
     @Phone = '123456789',
     @Address = 'New Address 123';

SELECT EmployeeID, phone, address
FROM dbo.Employee
WHERE EmployeeID = @EmpID;


PRINT 'Test 2: Employee does not exist (should fail)';
BEGIN TRY
    EXEC dbo.UpdatePersonalDetails
         @EmployeeID = 999999,
         @Phone = '555',
         @Address = 'Nowhere';
    PRINT 'UNEXPECTED: Test 2 passed';
END TRY
BEGIN CATCH
    PRINT 'Expected failure: ' + ERROR_MESSAGE();
END CATCH;


PRINT 'Test 3: Update with NULL values (allowed but should overwrite)';
EXEC dbo.UpdatePersonalDetails
     @EmployeeID = @EmpID,
     @Phone = NULL,
     @Address = NULL;

SELECT EmployeeID, phone, address
FROM dbo.Employee
WHERE EmployeeID = @EmpID;

/***** ViewEmployeeProfile tests *****/

PRINT '--- ViewEmployeeProfile tests ---';

DECLARE @ProfileEmpID INT = 9101;

/* Ensure we have a test employee with department + position */
IF NOT EXISTS (SELECT 1 FROM dbo.Department WHERE DepartmentID = 101)
BEGIN
    INSERT INTO dbo.Department (DepartmentID, department_name, purpose, department_head_id)
    VALUES (101, 'Test Department - Profile', 'Department for profile tests', NULL);
END;

IF NOT EXISTS (SELECT 1 FROM dbo.Position WHERE PositionID = 201)
BEGIN
    INSERT INTO dbo.Position (PositionID, position_title, responsibilities, status)
    VALUES (201, 'Test Position - Profile', 'Testing responsibilities', 'ACTIVE');
END;

IF NOT EXISTS (SELECT 1 FROM dbo.Employee WHERE EmployeeID = @ProfileEmpID)
BEGIN
    INSERT INTO dbo.Employee
        (EmployeeID, first_name, last_name, national_id,
         date_of_birth, country_of_birth, phone, email, address,
         employment_status, account_status, hire_date, is_active,
         department_id, position_id)
    VALUES
        (@ProfileEmpID, 'Profile', 'Employee', 'NAT-9101',
         '1990-01-01', 'Egypt', '+20-100-0000000', 'profile.employee@example.com',
         '123 Test Street, Cairo',
         'FULL_TIME', 'ACTIVE', '2020-01-01', 1,
         101, 201);
END;

PRINT 'Test 1: View profile for existing employee (should return 1 row with personal + job info)';
EXEC dbo.ViewEmployeeProfile @EmployeeID = @ProfileEmpID;


/* Test 2: Non-existing employee -> should raise error */
PRINT 'Test 2: Non-existing employee (should fail with ""Employee does not exist."")';
BEGIN TRY
    EXEC dbo.ViewEmployeeProfile @EmployeeID = 999999;
    PRINT 'Test 2 UNEXPECTED: no error raised';
END TRY
BEGIN CATCH
    PRINT 'Test 2 expected failure caught: ' + ERROR_MESSAGE();
END CATCH;


/* Test 3: NULL EmployeeID -> should raise validation error */
PRINT 'Test 3: NULL EmployeeID (should fail with ""EmployeeID is required."")';
BEGIN TRY
    EXEC dbo.ViewEmployeeProfile @EmployeeID = NULL;
    PRINT 'Test 3 UNEXPECTED: no error raised';
END TRY
BEGIN CATCH
    PRINT 'Test 3 expected failure caught: ' + ERROR_MESSAGE();
END CATCH;

GO


/***** UpdateContactInformation tests *****/


PRINT '--- UpdateContactInformation tests ---';

DECLARE @ContactEmpID INT = 9102;

-- Ensure a test employee exists
IF NOT EXISTS (SELECT 1 FROM dbo.Employee WHERE EmployeeID = @ContactEmpID)
BEGIN
    INSERT INTO dbo.Employee
        (EmployeeID, first_name, last_name, hire_date, is_active, phone, address)
    VALUES
        (@ContactEmpID, 'Contact', 'Update', '2024-01-01', 1, '0000', 'Old Address 1');
END;

PRINT 'Test 1: Valid PHONE update (should succeed and update phone only)';
EXEC dbo.UpdateContactInformation
     @EmployeeID  = @ContactEmpID,
     @RequestType = 'PHONE',
     @NewValue    = '+20-100-1234567';

SELECT EmployeeID, phone, address
FROM dbo.Employee
WHERE EmployeeID = @ContactEmpID;


PRINT 'Test 2: Valid ADDRESS update (should succeed and update address only)';
EXEC dbo.UpdateContactInformation
     @EmployeeID  = @ContactEmpID,
     @RequestType = 'ADDRESS',
     @NewValue    = 'New Test Address 123, Cairo';

SELECT EmployeeID, phone, address
FROM dbo.Employee
WHERE EmployeeID = @ContactEmpID;


PRINT 'Test 3: Non-existing employee (should fail with "Employee with the specified ID does not exist.")';
BEGIN TRY
    EXEC dbo.UpdateContactInformation
         @EmployeeID  = 999999,
         @RequestType = 'PHONE',
         @NewValue    = '123';
    PRINT 'Test 3 UNEXPECTED: no error raised';
END TRY
BEGIN CATCH
    PRINT 'Test 3 expected failure caught: ' + ERROR_MESSAGE();
END CATCH;


PRINT 'Test 4: Invalid RequestType (should fail with "RequestType must be PHONE or ADDRESS.")';
BEGIN TRY
    EXEC dbo.UpdateContactInformation
         @EmployeeID  = @ContactEmpID,
         @RequestType = 'EMAIL',
         @NewValue    = 'x@y.com';
    PRINT 'Test 4 UNEXPECTED: no error raised';
END TRY
BEGIN CATCH
    PRINT 'Test 4 expected failure caught: ' + ERROR_MESSAGE();
END CATCH;


PRINT 'Test 5: Empty NewValue (should fail with "NewValue cannot be empty.")';
BEGIN TRY
    EXEC dbo.UpdateContactInformation
         @EmployeeID  = @ContactEmpID,
         @RequestType = 'PHONE',
         @NewValue    = '   ';
    PRINT 'Test 5 UNEXPECTED: no error raised';
END TRY
BEGIN CATCH
    PRINT 'Test 5 expected failure caught: ' + ERROR_MESSAGE();
END CATCH;

GO
/***** 13) ViewEmploymentTimeline tests *****/

PRINT '--- ViewEmploymentTimeline tests ---';

DECLARE @TimelineEmpID      INT = 9201;
DECLARE @TimelineEmpNoContr INT = 9202;
DECLARE @TimelineDeptID     INT = 120;
DECLARE @TimelinePosID      INT = 220;
DECLARE @TimelineContractID INT = 93001;
DECLARE @TimelineTermID     INT = 93002;

-- Ensure supporting Department + Position exist
IF NOT EXISTS (SELECT 1 FROM dbo.Department WHERE DepartmentID = @TimelineDeptID)
BEGIN
    INSERT INTO dbo.Department (DepartmentID, department_name, purpose, department_head_id)
    VALUES (@TimelineDeptID, 'Timeline Test Dept', 'For employment timeline tests', NULL);
END;

IF NOT EXISTS (SELECT 1 FROM dbo.Position WHERE PositionID = @TimelinePosID)
BEGIN
    INSERT INTO dbo.Position (PositionID, position_title, responsibilities, status)
    VALUES (@TimelinePosID, 'Timeline Test Position', 'Timeline test responsibilities', 'ACTIVE');
END;

-- Ensure Contract row exists
IF NOT EXISTS (SELECT 1 FROM dbo.Contract WHERE ContractID = @TimelineContractID)
BEGIN
    INSERT INTO dbo.Contract (ContractID, type, start_date, end_date, current_state)
    VALUES (@TimelineContractID, 'Full-Time', '2022-01-01', '2024-12-31', 'TERMINATED');
END;

-- Ensure Termination row exists
IF NOT EXISTS (SELECT 1 FROM dbo.Termination WHERE TerminationID = @TimelineTermID)
BEGIN
    INSERT INTO dbo.Termination (TerminationID, date, reason, contract_id)
    VALUES (@TimelineTermID, '2024-12-31', 'Contract ended – project closure', @TimelineContractID);
END;

-- Employee with full timeline (hire + contract + termination)
IF NOT EXISTS (SELECT 1 FROM dbo.Employee WHERE EmployeeID = @TimelineEmpID)
BEGIN
    INSERT INTO dbo.Employee
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
        employment_status,
        account_status,
        hire_date,
        is_active,
        department_id,
        position_id,
        contract_id
    )
    VALUES
    (
        @TimelineEmpID,
        'Timeline',
        'Employee',
        'NID-9201',
        '1990-01-01',
        'Egypt',
        '0000000000',
        'timeline.employee@test.com',
        'Timeline Test Address',
        'FULL_TIME',
        'INACTIVE',
        '2020-01-01',
        0,
        @TimelineDeptID,
        @TimelinePosID,
        @TimelineContractID
    );
END
ELSE
BEGIN
    UPDATE dbo.Employee
    SET hire_date    = '2020-01-01',
        is_active    = 0,
        department_id = @TimelineDeptID,
        position_id   = @TimelinePosID,
        contract_id   = @TimelineContractID
    WHERE EmployeeID = @TimelineEmpID;
END;

-- Employee with hire only (no contract / termination)
IF NOT EXISTS (SELECT 1 FROM dbo.Employee WHERE EmployeeID = @TimelineEmpNoContr)
BEGIN
    INSERT INTO dbo.Employee
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
        employment_status,
        account_status,
        hire_date,
        is_active,
        department_id,
        position_id
    )
    VALUES
    (
        @TimelineEmpNoContr,
        'HireOnly',
        'Employee',
        'NID-9202',
        '1995-01-01',
        'Egypt',
        '0000000001',
        'hireonly.employee@test.com',
        'HireOnly Test Address',
        'FULL_TIME',
        'ACTIVE',
        '2023-06-01',
        1,
        @TimelineDeptID,
        @TimelinePosID
    );
END;

PRINT 'Test 1: Employee with hire + contract + termination timeline (expected multiple rows)';
EXEC dbo.ViewEmploymentTimeline @EmployeeID = @TimelineEmpID;

PRINT 'Test 2: Employee with hire only (expected 1 row for hire event)';
EXEC dbo.ViewEmploymentTimeline @EmployeeID = @TimelineEmpNoContr;

PRINT 'Test 3: Non-existing employee (should fail with "Employee does not exist.")';
BEGIN TRY
    EXEC dbo.ViewEmploymentTimeline @EmployeeID = 999999;
    PRINT 'Test 3 UNEXPECTED: no error raised';
END TRY
BEGIN CATCH
    PRINT 'Test 3 expected failure: ' + ERROR_MESSAGE();
END CATCH;

PRINT 'Test 4: NULL EmployeeID (should fail with "EmployeeID is required.")';
BEGIN TRY
    EXEC dbo.ViewEmploymentTimeline @EmployeeID = NULL;
    PRINT 'Test 4 UNEXPECTED: no error raised';
END TRY
BEGIN CATCH
    PRINT 'Test 4 expected failure: ' + ERROR_MESSAGE();
END CATCH;
GO
/***** 14) UpdateEmergencyContact tests *****/

PRINT '--- UpdateEmergencyContact tests ---';

DECLARE @EmergencyEmpID INT = 9301;

-- Ensure a test employee exists
IF NOT EXISTS (SELECT 1 FROM dbo.Employee WHERE EmployeeID = @EmergencyEmpID)
BEGIN
    INSERT INTO dbo.Employee
        (EmployeeID, first_name, last_name, hire_date, is_active)
    VALUES
        (@EmergencyEmpID, 'Emergency', 'Test', '2024-01-01', 1);
END;

PRINT 'Test 1: Valid emergency contact update (should succeed and return confirmation message)';
EXEC dbo.UpdateEmergencyContact
     @EmployeeID   = @EmergencyEmpID,
     @ContactName  = 'Test Contact',
     @Relation     = 'Brother',
     @Phone        = '+20-100-0000000';


PRINT 'Test 2: Non-existing employee (should fail)';
BEGIN TRY
    EXEC dbo.UpdateEmergencyContact
         @EmployeeID   = 999999,
         @ContactName  = 'Ghost Person',
         @Relation     = 'Friend',
         @Phone        = '+20-111-1111111';
    PRINT 'Test 2 UNEXPECTED: no error raised';
END TRY
BEGIN CATCH
    PRINT 'Test 2 expected failure caught: ' + ERROR_MESSAGE();
END CATCH;


PRINT 'Test 3: Empty ContactName (should fail)';
BEGIN TRY
    EXEC dbo.UpdateEmergencyContact
         @EmployeeID   = @EmergencyEmpID,
         @ContactName  = '   ',
         @Relation     = 'Mother',
         @Phone        = '+20-122-2222222';
    PRINT 'Test 3 UNEXPECTED: no error raised';
END TRY
BEGIN CATCH
    PRINT 'Test 3 expected failure caught: ' + ERROR_MESSAGE();
END CATCH;


PRINT 'Test 4: Empty Relation (should fail)';
BEGIN TRY
    EXEC dbo.UpdateEmergencyContact
         @EmployeeID   = @EmergencyEmpID,
         @ContactName  = 'Valid Name',
         @Relation     = '   ',
         @Phone        = '+20-133-3333333';
    PRINT 'Test 4 UNEXPECTED: no error raised';
END TRY
BEGIN CATCH
    PRINT 'Test 4 expected failure caught: ' + ERROR_MESSAGE();
END CATCH;


PRINT 'Test 5: Empty Phone (should fail)';
BEGIN TRY
    EXEC dbo.UpdateEmergencyContact
         @EmployeeID   = @EmergencyEmpID,
         @ContactName  = 'Valid Name',
         @Relation     = 'Father',
         @Phone        = '   ';
    PRINT 'Test 5 UNEXPECTED: no error raised';
END TRY
BEGIN CATCH
    PRINT 'Test 5 expected failure caught: ' + ERROR_MESSAGE();
END CATCH;

GO
--------------------------------------------------------------
-- 15) RequestHRDocument tests
--------------------------------------------------------------
DECLARE @Test15EmpID INT = 1801;

-- Ensure a test Employee exists (no department/position to avoid FK issues)
IF NOT EXISTS (SELECT 1 FROM dbo.Employee WHERE EmployeeID = @Test15EmpID)
BEGIN
    INSERT INTO dbo.Employee
    (
        EmployeeID,
        first_name,
        last_name,
        hire_date,
        is_active
    )
    VALUES
    (
        @Test15EmpID,
        'HRDoc',
        'Employee',
        GETDATE(),
        1
    );
END;

-- Ensure at least one HRAdministrator row exists for this employee
IF NOT EXISTS (SELECT 1 FROM dbo.HRAdministrator WHERE employee_id = @Test15EmpID)
BEGIN
    INSERT INTO dbo.HRAdministrator
    (
        employee_id,
        approval_level,
        record_access_scope,
        document_validation_rights
    )
    VALUES
    (
        @Test15EmpID,
        'LEVEL1',
        'ALL_EMPLOYEES',
        1
    );
END;

PRINT 'Test 1: Valid HR document request (Employment Verification)';
EXEC dbo.RequestHRDocument
     @EmployeeID   = @Test15EmpID,
     @DocumentType = 'Employment Verification';

PRINT 'Test 2: Invalid EmployeeID (should fail)';
BEGIN TRY
    EXEC dbo.RequestHRDocument
         @EmployeeID   = -1,
         @DocumentType = 'Employment Verification';
END TRY
BEGIN CATCH
    SELECT ERROR_MESSAGE() AS ErrorMessage;
END CATCH;

PRINT 'Test 3: Missing DocumentType (should fail)';
BEGIN TRY
    EXEC dbo.RequestHRDocument
         @EmployeeID   = @Test15EmpID,
         @DocumentType = NULL;
END TRY
BEGIN CATCH
    SELECT ERROR_MESSAGE() AS ErrorMessage;
END CATCH;

PRINT 'Test 15 complete.';
GO
/***** 16) NotifyProfileUpdate tests *****/

PRINT '--- NotifyProfileUpdate tests ---';

DECLARE @NotifyEmpID INT = 1901;

-- Ensure a test employee exists (no FKs hit: dept/position left NULL)
IF NOT EXISTS (SELECT 1 FROM dbo.Employee WHERE EmployeeID = @NotifyEmpID)
BEGIN
    INSERT INTO dbo.Employee
    (
        EmployeeID,
        first_name,
        last_name,
        hire_date,
        is_active
    )
    VALUES
    (
        @NotifyEmpID,
        'Notify',
        'Employee',
        GETDATE(),
        1
    );
END;

PRINT 'Test 1: Valid notification preference (PROFILE_UPDATES)';
EXEC dbo.NotifyProfileUpdate
     @EmployeeID      = @NotifyEmpID,
     @notificationType = 'PROFILE_UPDATES';

PRINT 'Test 2: Valid notification preference (DOCUMENT_CHANGES)';
EXEC dbo.NotifyProfileUpdate
     @EmployeeID      = @NotifyEmpID,
     @notificationType = 'DOCUMENT_CHANGES';

PRINT 'Test 3: Non-existing employee (should fail)';
BEGIN TRY
    EXEC dbo.NotifyProfileUpdate
         @EmployeeID      = 999999,
         @notificationType = 'PROFILE_UPDATES';
    PRINT 'Test 3 UNEXPECTED: no error raised';
END TRY
BEGIN CATCH
    PRINT 'Test 3 expected failure caught: ' + ERROR_MESSAGE();
END CATCH;

PRINT 'Test 4: Empty notificationType (should fail)';
BEGIN TRY
    EXEC dbo.NotifyProfileUpdate
         @EmployeeID      = @NotifyEmpID,
         @notificationType = '   ';
    PRINT 'Test 4 UNEXPECTED: no error raised';
END TRY
BEGIN CATCH
    PRINT 'Test 4 expected failure caught: ' + ERROR_MESSAGE();
END CATCH;

PRINT 'Test 5: NULL EmployeeID (should fail)';
BEGIN TRY
    EXEC dbo.NotifyProfileUpdate
         @EmployeeID      = NULL,
         @notificationType = 'PROFILE_UPDATES';
    PRINT 'Test 5 UNEXPECTED: no error raised';
END TRY
BEGIN CATCH
    PRINT 'Test 5 expected failure caught: ' + ERROR_MESSAGE();
END CATCH;

GO
/***** 17) LogFlexibleAttendance tests *****/

PRINT '--- LogFlexibleAttendance tests ---';

DECLARE @FlexEmpID INT = 2001;

-- Ensure a test employee exists (no department/position to avoid FK issues)
IF NOT EXISTS (SELECT 1 FROM dbo.Employee WHERE EmployeeID = @FlexEmpID)
BEGIN
    INSERT INTO dbo.Employee
    (
        EmployeeID,
        first_name,
        last_name,
        hire_date,
        is_active
    )
    VALUES
    (
        @FlexEmpID,
        'Flex',
        'Employee',
        GETDATE(),
        1
    );
END;

------------------------------------------------------------
-- Test 1: Valid flex attendance (expected success + message)
------------------------------------------------------------
PRINT 'Test 1: Valid flex attendance (09:00 - 17:30)';
EXEC dbo.LogFlexibleAttendance
     @EmployeeID = @FlexEmpID,
     @Date       = '2024-01-10',
     @CheckIn    = '09:00',
     @CheckOut   = '17:30';

------------------------------------------------------------
-- Test 2: Same day, new times (update existing attendance)
------------------------------------------------------------
PRINT 'Test 2: Update the same date with new times (08:30 - 16:00)';
EXEC dbo.LogFlexibleAttendance
     @EmployeeID = @FlexEmpID,
     @Date       = '2024-01-10',
     @CheckIn    = '08:30',
     @CheckOut   = '16:00';

------------------------------------------------------------
-- Test 3: CheckOut <= CheckIn (should fail)
------------------------------------------------------------
PRINT 'Test 3: Invalid times (CheckOut <= CheckIn, should fail)';
BEGIN TRY
    EXEC dbo.LogFlexibleAttendance
         @EmployeeID = @FlexEmpID,
         @Date       = '2024-01-11',
         @CheckIn    = '10:00',
         @CheckOut   = '09:00';
    PRINT 'Test 3 UNEXPECTED: no error raised';
END TRY
BEGIN CATCH
    PRINT 'Test 3 expected failure caught: ' + ERROR_MESSAGE();
END CATCH;

------------------------------------------------------------
-- Test 4: Non-existing employee (should fail)
------------------------------------------------------------
PRINT 'Test 4: Non-existing employee (should fail)';
BEGIN TRY
    EXEC dbo.LogFlexibleAttendance
         @EmployeeID = 999999,
         @Date       = '2024-01-12',
         @CheckIn    = '09:00',
         @CheckOut   = '17:00';
    PRINT 'Test 4 UNEXPECTED: no error raised';
END TRY
BEGIN CATCH
    PRINT 'Test 4 expected failure caught: ' + ERROR_MESSAGE();
END CATCH;

------------------------------------------------------------
-- Test 5: NULL Date (should fail)
------------------------------------------------------------
PRINT 'Test 5: NULL date (should fail)';
BEGIN TRY
    EXEC dbo.LogFlexibleAttendance
         @EmployeeID = @FlexEmpID,
         @Date       = NULL,
         @CheckIn    = '09:00',
         @CheckOut   = '17:00';
    PRINT 'Test 5 UNEXPECTED: no error raised';
END TRY
BEGIN CATCH
    PRINT 'Test 5 expected failure caught: ' + ERROR_MESSAGE();
END CATCH;

GO

/***** 18) NotifyMissedPunch tests *****/

PRINT '--- NotifyMissedPunch tests ---';

DECLARE @MissedEmpID   INT  = 2101;
DECLARE @MissedDate    DATE = '2025-01-15';
DECLARE @MissedExID    INT  = 91001;
DECLARE @MissedAttID   INT;

/* Ensure a test employee exists (no FK issues: leave dept/position/paygrade NULL) */
IF NOT EXISTS (SELECT 1 FROM dbo.Employee WHERE EmployeeID = @MissedEmpID)
BEGIN
    INSERT INTO dbo.Employee
    (
        EmployeeID,
        first_name,
        last_name,
        hire_date,
        is_active
    )
    VALUES
    (
        @MissedEmpID,
        'Missed',
        'Punch',
        GETDATE(),
        1
    );
END;

/* Ensure an ATTENDANCE exception exists for that date (FLAGGED/OPEN/PENDING) */
IF NOT EXISTS (SELECT 1 FROM dbo.Exception WHERE ExceptionID = @MissedExID)
BEGIN
    INSERT INTO dbo.Exception
    (
        ExceptionID,
        name,
        category,
        date,
        status
    )
    VALUES
    (
        @MissedExID,
        'MISSED_PUNCH',
        'ATTENDANCE',
        @MissedDate,
        'FLAGGED'
    );
END;

/* Create an Attendance row linked to that exception for the employee */
SELECT @MissedAttID = ISNULL(MAX(AttendanceID), 0) + 1
FROM dbo.Attendance;

IF NOT EXISTS (SELECT 1 FROM dbo.Attendance WHERE AttendanceID = @MissedAttID)
BEGIN
    INSERT INTO dbo.Attendance
    (
        AttendanceID,
        employee_id,
        entry_time,
        exit_time,
        duration,
        login_method,
        logout_method,
        exception_id
    )
    VALUES
    (
        @MissedAttID,
        @MissedEmpID,
        NULL,
        NULL,
        0,
        'AUTO',
        'AUTO',
        @MissedExID
    );
END;

------------------------------------------------------------
PRINT 'Test 1: Employee with flagged ATTENDANCE exception on given date';
EXEC dbo.NotifyMissedPunch
     @EmployeeID = @MissedEmpID,
     @Date       = @MissedDate;

------------------------------------------------------------
PRINT 'Test 2: Same employee on a date with NO missed punch (should say "No missed punch detected...")';
EXEC dbo.NotifyMissedPunch
     @EmployeeID = @MissedEmpID,
     @Date       = '2025-01-16';

------------------------------------------------------------
PRINT 'Test 3: Non-existing employee (should fail)';
BEGIN TRY
    EXEC dbo.NotifyMissedPunch
         @EmployeeID = 999999,
         @Date       = @MissedDate;
    PRINT 'Test 3 UNEXPECTED: no error raised';
END TRY
BEGIN CATCH
    PRINT 'Test 3 expected failure caught: ' + ERROR_MESSAGE();
END CATCH;

------------------------------------------------------------
PRINT 'Test 4: NULL date (should fail)';
BEGIN TRY
    EXEC dbo.NotifyMissedPunch
         @EmployeeID = @MissedEmpID,
         @Date       = NULL;
    PRINT 'Test 4 UNEXPECTED: no error raised';
END TRY
BEGIN CATCH
    PRINT 'Test 4 expected failure caught: ' + ERROR_MESSAGE();
END CATCH;

GO

/***** 19) Test RecordMultiplePunches *****/
PRINT '========================================';
PRINT 'TEST 19: RecordMultiplePunches';
PRINT '========================================';

USE MILESTONE2;
GO

-- Setup
IF NOT EXISTS (SELECT 1 FROM dbo.Employee WHERE EmployeeID = 190)
    INSERT INTO dbo.Employee (EmployeeID, first_name, last_name, email, hire_date, is_active, department_id, position_id)
    VALUES (190, 'Multi', 'Punch', 'multipunch@test.com', GETDATE(), 1, 1, 1);
GO

-- Test 1: Valid clock IN (first punch of the day)
DECLARE @TestDate DATETIME = '2025-01-25 09:00:00';
PRINT 'Test 1: First clock IN of the day';
BEGIN TRY
    EXEC dbo.RecordMultiplePunches 
        @EmployeeID = 190,
        @ClockInOutTime = @TestDate,
        @Type = 'IN';
    SELECT entry_time, exit_time FROM dbo.Attendance 
    WHERE employee_id = 190 AND CAST(DATEADD(HOUR, 0, @TestDate) AS DATE) = CAST(@TestDate AS DATE);
END TRY
BEGIN CATCH
    SELECT 'Error' AS TestResult, ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
GO

-- Test 2: Valid clock OUT (lunch break start)
PRINT 'Test 2: Clock OUT for lunch break';
BEGIN TRY
    EXEC dbo.RecordMultiplePunches 
        @EmployeeID = 190,
        @ClockInOutTime = '2025-01-25 12:00:00',
        @Type = 'OUT';
    SELECT entry_time, exit_time, duration FROM dbo.Attendance 
    WHERE employee_id = 190 AND CAST(DATEADD(HOUR, 0, '2025-01-25') AS DATE) = '2025-01-25';
END TRY
BEGIN CATCH
    SELECT 'Error' AS TestResult, ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
GO

-- Test 3: Invalid type (should fail)
PRINT 'Test 3: Invalid punch type (should fail)';
BEGIN TRY
    EXEC dbo.RecordMultiplePunches 
        @EmployeeID = 190,
        @ClockInOutTime = '2025-01-25 13:00:00',
        @Type = 'BREAK';
END TRY
BEGIN CATCH
    SELECT 'Expected error' AS TestResult, ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
GO

PRINT 'Test 19 complete.';
PRINT '';
GO

/***** 20) Test SubmitCorrectionRequest *****/
PRINT '========================================';
PRINT 'TEST 20: SubmitCorrectionRequest';
PRINT '========================================';

USE MILESTONE2;
GO

-- Setup
IF NOT EXISTS (SELECT 1 FROM dbo.Employee WHERE EmployeeID = 200)
    INSERT INTO dbo.Employee (EmployeeID, first_name, last_name, email, hire_date, is_active, department_id, position_id, manager_id)
    VALUES (200, 'Correction', 'Requester', 'correction@test.com', GETDATE(), 1, 1, 1, 2);
GO

-- Test 1: Valid correction request for missed punch
PRINT 'Test 1: Valid missed punch correction';
BEGIN TRY
    EXEC dbo.SubmitCorrectionRequest 
        @EmployeeID = 200,
        @Date = '2025-01-20',
        @CorrectionType = 'Missed Punch',
        @Reason = 'Forgot to clock in due to emergency meeting';
    SELECT TOP 1 * FROM dbo.AttendanceCorrectionRequest WHERE employee_id = 200 ORDER BY RequestID DESC;
END TRY
BEGIN CATCH
    SELECT 'Error' AS TestResult, ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
GO

-- Test 2: Valid incorrect time correction
PRINT 'Test 2: Valid incorrect time correction';
BEGIN TRY
    EXEC dbo.SubmitCorrectionRequest 
        @EmployeeID = 200,
        @Date = '2025-01-21',
        @CorrectionType = 'Incorrect Time',
        @Reason = 'System recorded wrong time, actual entry was 9:00 AM';
    SELECT TOP 2 * FROM dbo.AttendanceCorrectionRequest WHERE employee_id = 200 ORDER BY RequestID DESC;
END TRY
BEGIN CATCH
    SELECT 'Error' AS TestResult, ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
GO

-- Test 3: Future date (should fail)
PRINT 'Test 3: Future date correction (should fail)';
BEGIN TRY
    EXEC dbo.SubmitCorrectionRequest 
        @EmployeeID = 200,
        @Date = '2025-12-31',
        @CorrectionType = 'Missed Punch',
        @Reason = 'Future correction attempt';
END TRY
BEGIN CATCH
    SELECT 'Expected error' AS TestResult, ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
GO

-- Test 4: Empty reason (should fail)
PRINT 'Test 4: Empty reason (should fail)';
BEGIN TRY
    EXEC dbo.SubmitCorrectionRequest 
        @EmployeeID = 200,
        @Date = '2025-01-22',
        @CorrectionType = 'Missed Punch',
        @Reason = '   ';
END TRY
BEGIN CATCH
    SELECT 'Expected error' AS TestResult, ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
GO

PRINT 'Test 20 complete.';
PRINT '';
GO

/***** 21) Test ViewRequestStatus *****/
PRINT '========================================';
PRINT 'TEST 21: ViewRequestStatus';
PRINT '========================================';

USE MILESTONE2;
GO

-- Setup: Create employee with various requests
IF NOT EXISTS (SELECT 1 FROM dbo.Employee WHERE EmployeeID = 210)
    INSERT INTO dbo.Employee (EmployeeID, first_name, last_name, email, hire_date, is_active, department_id, position_id)
    VALUES (210, 'Status', 'Viewer', 'status@test.com', GETDATE(), 1, 1, 1);
GO

-- Create sample leave request
IF NOT EXISTS (SELECT 1 FROM dbo.Leave WHERE LeaveID = 2101)
    INSERT INTO dbo.Leave (LeaveID, leave_type, leave_description)
    VALUES (2101, 'Vacation', 'Test leave type');
GO

DELETE FROM dbo.LeaveRequest WHERE employee_id = 210;
INSERT INTO dbo.LeaveRequest (RequestID, employee_id, leave_id, justification, duration, status)
VALUES (21001, 210, 2101, 'Test leave', 5, 'PENDING');
GO

-- Create correction request
DELETE FROM dbo.AttendanceCorrectionRequest WHERE employee_id = 210;
INSERT INTO dbo.AttendanceCorrectionRequest (RequestID, employee_id, date, correction_type, reason, status, recommended_by)
VALUES (21002, 210, '2025-01-15', 'Missed Punch', 'Test correction', 'PENDING', NULL);
GO

-- Test 1: View all request statuses
PRINT 'Test 1: View all request statuses for employee';
BEGIN TRY
    EXEC dbo.ViewRequestStatus @EmployeeID = 210;
END TRY
BEGIN CATCH
    SELECT 'Error' AS TestResult, ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
GO

-- Test 2: Invalid employee (should fail)
PRINT 'Test 2: Invalid employee (should fail)';
BEGIN TRY
    EXEC dbo.ViewRequestStatus @EmployeeID = 999999;
END TRY
BEGIN CATCH
    SELECT 'Expected error' AS TestResult, ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
GO

PRINT 'Test 21 complete.';
PRINT '';
GO

/***** 22) Test AttachLeaveDocuments *****/
PRINT '========================================';
PRINT 'TEST 22: AttachLeaveDocuments';
PRINT '========================================';

USE MILESTONE2;
GO

-- Setup
IF NOT EXISTS (SELECT 1 FROM dbo.Employee WHERE EmployeeID = 220)
    INSERT INTO dbo.Employee (EmployeeID, first_name, last_name, email, hire_date, is_active, department_id, position_id)
    VALUES (220, 'Document', 'Attacher', 'docattach@test.com', GETDATE(), 1, 1, 1);
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Leave WHERE LeaveID = 2201)
    INSERT INTO dbo.Leave (LeaveID, leave_type, leave_description)
    VALUES (2201, 'Sick', 'Sick leave type');
GO

DELETE FROM dbo.LeaveDocument WHERE leave_request_id IN (22001, 22002);
DELETE FROM dbo.LeaveRequest WHERE RequestID IN (22001, 22002);
GO

-- Create pending leave request
INSERT INTO dbo.LeaveRequest (RequestID, employee_id, leave_id, justification, duration, status)
VALUES (22001, 220, 2201, 'Medical leave', 3, 'PENDING');
GO

-- Create approved leave request for negative test
INSERT INTO dbo.LeaveRequest (RequestID, employee_id, leave_id, justification, duration, status, approval_timing)
VALUES (22002, 220, 2201, 'Already approved', 2, 'APPROVED', GETDATE());
GO

-- Test 1: Valid document attachment to pending request
PRINT 'Test 1: Attach document to pending leave request';
BEGIN TRY
    EXEC dbo.AttachLeaveDocuments 
        @LeaveRequestID = 22001,
        @FilePath = '/documents/medical_cert_22001.pdf';
    SELECT * FROM dbo.LeaveDocument WHERE leave_request_id = 22001;
END TRY
BEGIN CATCH
    SELECT 'Error' AS TestResult, ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
GO

-- Test 2: Attach multiple documents
PRINT 'Test 2: Attach additional document';
BEGIN TRY
    EXEC dbo.AttachLeaveDocuments 
        @LeaveRequestID = 22001,
        @FilePath = '/documents/doctor_note_22001.pdf';
    SELECT * FROM dbo.LeaveDocument WHERE leave_request_id = 22001;
END TRY
BEGIN CATCH
    SELECT 'Error' AS TestResult, ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
GO

-- Test 3: Attach to approved request (should fail)
PRINT 'Test 3: Attach to approved request (should fail)';
BEGIN TRY
    EXEC dbo.AttachLeaveDocuments 
        @LeaveRequestID = 22002,
        @FilePath = '/documents/should_fail.pdf';
END TRY
BEGIN CATCH
    SELECT 'Expected error' AS TestResult, ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
GO

-- Test 4: Empty file path (should fail)
PRINT 'Test 4: Empty file path (should fail)';
BEGIN TRY
    EXEC dbo.AttachLeaveDocuments 
        @LeaveRequestID = 22001,
        @FilePath = '   ';
END TRY
BEGIN CATCH
    SELECT 'Expected error' AS TestResult, ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
GO

PRINT 'Test 22 complete.';
PRINT '';
GO

/***** 24) Test ModifyLeaveRequest *****/
PRINT '========================================';
PRINT 'TEST 24: ModifyLeaveRequest';
PRINT '========================================';

USE MILESTONE2;
GO

-- Setup
IF NOT EXISTS (SELECT 1 FROM dbo.Employee WHERE EmployeeID = 240)
    INSERT INTO dbo.Employee (EmployeeID, first_name, last_name, email, hire_date, is_active, department_id, position_id)
    VALUES (240, 'Leave', 'Modifier', 'modifier@test.com', GETDATE(), 1, 1, 1);
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Leave WHERE LeaveID = 2401)
    INSERT INTO dbo.Leave (LeaveID, leave_type, leave_description)
    VALUES (2401, 'Vacation', 'Vacation leave');
GO

DELETE FROM dbo.LeaveRequest WHERE RequestID IN (24001, 24002);
GO

-- Create pending leave request
INSERT INTO dbo.LeaveRequest (RequestID, employee_id, leave_id, justification, duration, status)
VALUES (24001, 240, 2401, 'Original vacation plan', 7, 'PENDING');
GO

-- Create approved leave request for negative test
INSERT INTO dbo.LeaveRequest (RequestID, employee_id, leave_id, justification, duration, status, approval_timing)
VALUES (24002, 240, 2401, 'Approved leave', 5, 'APPROVED', GETDATE());
GO

-- Test 1: Valid modification of pending request
PRINT 'Test 1: Modify pending leave request dates and reason';
BEGIN TRY
    EXEC dbo.ModifyLeaveRequest 
        @LeaveRequestID = 24001,
        @StartDate = '2025-07-01',
        @EndDate = '2025-07-10',
        @Reason = 'Extended vacation to include family event';
    SELECT RequestID, justification, duration, status FROM dbo.LeaveRequest WHERE RequestID = 24001;
END TRY
BEGIN CATCH
    SELECT 'Error' AS TestResult, ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
GO

-- Test 2: Modify only dates (keep original reason)
PRINT 'Test 2: Modify only dates';
BEGIN TRY
    EXEC dbo.ModifyLeaveRequest 
        @LeaveRequestID = 24001,
        @StartDate = '2025-07-05',
        @EndDate = '2025-07-10',
        @Reason = '';
    SELECT RequestID, justification, duration FROM dbo.LeaveRequest WHERE RequestID = 24001;
END TRY
BEGIN CATCH
    SELECT 'Error' AS TestResult, ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
GO

-- Test 3: Invalid dates (start after end) - should fail
PRINT 'Test 3: Invalid dates (should fail)';
BEGIN TRY
    EXEC dbo.ModifyLeaveRequest 
        @LeaveRequestID = 24001,
        @StartDate = '2025-07-15',
        @EndDate = '2025-07-10',
        @Reason = 'Invalid modification';
END TRY
BEGIN CATCH
    SELECT 'Expected error' AS TestResult, ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
GO

-- Test 4: Modify approved request (should fail)
PRINT 'Test 4: Modify approved request (should fail)';
BEGIN TRY
    EXEC dbo.ModifyLeaveRequest 
        @LeaveRequestID = 24002,
        @StartDate = '2025-08-01',
        @EndDate = '2025-08-05',
        @Reason = 'Should not work';
END TRY
BEGIN CATCH
    SELECT 'Expected error' AS TestResult, ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
GO

PRINT 'Test 24 complete.';
PRINT '';
GO

/***** 25) Test CancelLeaveRequest *****/
PRINT '========================================';
PRINT 'TEST 25: CancelLeaveRequest';
PRINT '========================================';

USE MILESTONE2;
GO

-- Setup
IF NOT EXISTS (SELECT 1 FROM dbo.Employee WHERE EmployeeID = 250)
    INSERT INTO dbo.Employee (EmployeeID, first_name, last_name, email, hire_date, is_active, department_id, position_id)
    VALUES (250, 'Leave', 'Canceller', 'canceller@test.com', GETDATE(), 1, 1, 1);
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Leave WHERE LeaveID = 2501)
    INSERT INTO dbo.Leave (LeaveID, leave_type, leave_description)
    VALUES (2501, 'Personal', 'Personal leave');
GO

DELETE FROM dbo.LeaveRequest WHERE RequestID IN (25001, 25002, 25003);
GO

-- Create pending request
INSERT INTO dbo.LeaveRequest (RequestID, employee_id, leave_id, justification, duration, status)
VALUES (25001, 250, 2501, 'Personal matters', 3, 'PENDING');
GO

-- Create approved request for negative test
INSERT INTO dbo.LeaveRequest (RequestID, employee_id, leave_id, justification, duration, status, approval_timing)
VALUES (25002, 250, 2501, 'Approved leave', 2, 'APPROVED', GETDATE());
GO

-- Create already cancelled request
INSERT INTO dbo.LeaveRequest (RequestID, employee_id, leave_id, justification, duration, status)
VALUES (25003, 250, 2501, 'Already cancelled', 1, 'CANCELLED');
GO

-- Test 1: Valid cancellation of pending request
PRINT 'Test 1: Cancel pending leave request';
BEGIN TRY
    EXEC dbo.CancelLeaveRequest @LeaveRequestID = 25001;
    SELECT RequestID, status FROM dbo.LeaveRequest WHERE RequestID = 25001;
END TRY
BEGIN CATCH
    SELECT 'Error' AS TestResult, ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
GO

-- Test 2: Cancel approved request (should fail)
PRINT 'Test 2: Cancel approved request (should fail)';
BEGIN TRY
    EXEC dbo.CancelLeaveRequest @LeaveRequestID = 25002;
END TRY
BEGIN CATCH
    SELECT 'Expected error' AS TestResult, ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
GO

-- Test 3: Cancel already cancelled request (should fail)
PRINT 'Test 3: Cancel already cancelled request (should fail)';
BEGIN TRY
    EXEC dbo.CancelLeaveRequest @LeaveRequestID = 25003;
END TRY
BEGIN CATCH
    SELECT 'Expected error' AS TestResult, ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
GO

-- Test 4: Non-existent request (should fail)
PRINT 'Test 4: Non-existent request (should fail)';
BEGIN TRY
    EXEC dbo.CancelLeaveRequest @LeaveRequestID = 999999;
END TRY
BEGIN CATCH
    SELECT 'Expected error' AS TestResult, ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
GO

PRINT 'Test 25 complete.';
PRINT '';
GO

/***** 26) Test ViewLeaveBalance *****/
PRINT '========================================';
PRINT 'TEST 26: ViewLeaveBalance';
PRINT '========================================';

USE MILESTONE2;
GO

-- Setup
IF NOT EXISTS (SELECT 1 FROM dbo.Employee WHERE EmployeeID = 260)
    INSERT INTO dbo.Employee (EmployeeID, first_name, last_name, email, hire_date, is_active, department_id, position_id)
    VALUES (260, 'Balance', 'Viewer', 'balance@test.com', GETDATE(), 1, 1, 1);
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Leave WHERE LeaveID = 2601)
    INSERT INTO dbo.Leave (LeaveID, leave_type, leave_description)
    VALUES (2601, 'Annual', 'Annual leave');
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Leave WHERE LeaveID = 2602)
    INSERT INTO dbo.Leave (LeaveID, leave_type, leave_description)
    VALUES (2602, 'Sick', 'Sick leave');
GO

DELETE FROM dbo.LeaveEntitlement WHERE employee_id = 260;
DELETE FROM dbo.LeaveRequest WHERE employee_id = 260;
GO

-- Setup entitlements
INSERT INTO dbo.LeaveEntitlement (employee_id, leave_type_id, entitlement)
VALUES 
    (260, 2601, 20),
    (260, 2602, 10);
GO

-- Add some approved leave
INSERT INTO dbo.LeaveRequest (RequestID, employee_id, leave_id, justification, duration, status, approval_timing)
VALUES 
    (26001, 260, 2601, 'Summer vacation', 5, 'APPROVED', GETDATE()),
    (26002, 260, 2602, 'Flu', 2, 'APPROVED', GETDATE());
GO

-- Test 1: View leave balance with some usage
PRINT 'Test 1: View leave balance';
BEGIN TRY
    EXEC dbo.ViewLeaveBalance @EmployeeID = 260;
END TRY
BEGIN CATCH
    SELECT 'Error' AS TestResult, ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
GO

-- Test 2: Invalid employee (should fail)
PRINT 'Test 2: Invalid employee (should fail)';
BEGIN TRY
    EXEC dbo.ViewLeaveBalance @EmployeeID = 999999;
END TRY
BEGIN CATCH
    SELECT 'Expected error' AS TestResult, ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
GO

PRINT 'Test 26 complete.';
PRINT '';
GO

/***** 27) Test ViewLeaveHistory *****/
PRINT '========================================';
PRINT 'TEST 27: ViewLeaveHistory';
PRINT '========================================';

USE MILESTONE2;
GO

-- Setup (using data from previous test)
-- Test 1: View leave history
PRINT 'Test 1: View leave history';
BEGIN TRY
    EXEC dbo.ViewLeaveHistory @EmployeeID = 260;
END TRY
BEGIN CATCH
    SELECT 'Error' AS TestResult, ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
GO

-- Test 2: Invalid employee (should fail)
PRINT 'Test 2: Invalid employee (should fail)';
BEGIN TRY
    EXEC dbo.ViewLeaveHistory @EmployeeID = 999999;
END TRY
BEGIN CATCH
    SELECT 'Expected error' AS TestResult, ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
GO

PRINT 'Test 27 complete.';
PRINT '';
GO

/***** 28) Test SubmitLeaveAfterAbsence *****/
PRINT '========================================';
PRINT 'TEST 28: SubmitLeaveAfterAbsence';
PRINT '========================================';

USE MILESTONE2;
GO

-- Setup
IF NOT EXISTS (SELECT 1 FROM dbo.Employee WHERE EmployeeID = 280)
    INSERT INTO dbo.Employee (EmployeeID, first_name, last_name, email, hire_date, is_active, department_id, position_id, manager_id)
    VALUES (280, 'Retro', 'Leave', 'retroleave@test.com', GETDATE(), 1, 1, 1, 2);
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Leave WHERE LeaveID = 2801)
    INSERT INTO dbo.Leave (LeaveID, leave_type, leave_description)
    VALUES (2801, 'Emergency', 'Emergency leave');
GO

-- Test 1: Valid retroactive leave (within 30 days)
PRINT 'Test 1: Valid retroactive leave request';
BEGIN TRY
    EXEC dbo.SubmitLeaveAfterAbsence 
        @EmployeeID = 280,
        @LeaveTypeID = 2801,
        @StartDate = '2025-11-29',
        @EndDate = '2025-12-22',
        @Reason = 'Family emergency, could not submit in advance';
    SELECT TOP 1 * FROM dbo.LeaveRequest WHERE employee_id = 280 ORDER BY RequestID DESC;
END TRY
BEGIN CATCH
    SELECT 'Error' AS TestResult, ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
GO

-- Test 2: Valid single day retroactive leave
PRINT 'Test 2: Valid single day retroactive leave';
BEGIN TRY
    EXEC dbo.SubmitLeaveAfterAbsence 
        @EmployeeID = 280,
        @LeaveTypeID = 2801,
        @StartDate = '2025-11-30',
        @EndDate = '2025-11-30',
        @Reason = 'Sudden illness';
    SELECT TOP 1 * FROM dbo.LeaveRequest WHERE employee_id = 280 ORDER BY RequestID DESC;
END TRY
BEGIN CATCH
    SELECT 'Error' AS TestResult, ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
GO

-- Test 3: Too old (should fail)
PRINT 'Test 3: Retroactive leave too old (should fail)';
BEGIN TRY
    EXEC dbo.SubmitLeaveAfterAbsence 
        @EmployeeID = 280,
        @LeaveTypeID = 2801,
        @StartDate = '2024-01-01',
        @EndDate = '2024-01-02',
        @Reason = 'Too old';
END TRY
BEGIN CATCH
    SELECT 'Expected error' AS TestResult, ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
GO

-- Test 4: Future date (should fail)
PRINT 'Test 4: Future date for retroactive leave (should fail)';
BEGIN TRY
    EXEC dbo.SubmitLeaveAfterAbsence 
        @EmployeeID = 280,
        @LeaveTypeID = 2801,
        @StartDate = '2025-12-01',
        @EndDate = '2025-12-05',
        @Reason = 'Future leave';
END TRY
BEGIN CATCH
    SELECT 'Expected error' AS TestResult, ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
GO

PRINT 'Test 28 complete.';
PRINT '';
GO

/***** 29) Test NotifyLeaveStatusChange *****/
PRINT '========================================';
PRINT 'TEST 29: NotifyLeaveStatusChange';
PRINT '========================================';

USE MILESTONE2;
GO

-- Setup
IF NOT EXISTS (SELECT 1 FROM dbo.Employee WHERE EmployeeID = 290)
    INSERT INTO dbo.Employee (EmployeeID, first_name, last_name, email, hire_date, is_active, department_id, position_id)
    VALUES (290, 'Notif', 'Receiver', 'notif@test.com', GETDATE(), 1, 1, 1);
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Leave WHERE LeaveID = 2901)
    INSERT INTO dbo.Leave (LeaveID, leave_type, leave_description)
    VALUES (2901, 'Vacation', 'Vacation leave');
GO

DELETE FROM dbo.LeaveRequest WHERE RequestID = 29001;
INSERT INTO dbo.LeaveRequest (RequestID, employee_id, leave_id, justification, duration, status)
VALUES (29001, 290, 2901, 'Test notification', 5, 'PENDING');
GO

-- Test 1: Notify APPROVED status
PRINT 'Test 1: Notify leave approved';
BEGIN TRY
    EXEC dbo.NotifyLeaveStatusChange 
        @EmployeeID = 290,
        @RequestID = 29001,
        @Status = 'APPROVED';
    SELECT TOP 1 * FROM dbo.Notification ORDER BY NotificationID DESC;
END TRY
BEGIN CATCH
    SELECT 'Error' AS TestResult, ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
GO

-- Test 2: Notify REJECTED status
PRINT 'Test 2: Notify leave rejected';
BEGIN TRY
    EXEC dbo.NotifyLeaveStatusChange 
        @EmployeeID = 290,
        @RequestID = 29001,
        @Status = 'REJECTED';
    SELECT TOP 1 * FROM dbo.Notification ORDER BY NotificationID DESC;
END TRY
BEGIN CATCH
    SELECT 'Error' AS TestResult, ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
GO

-- Test 3: Invalid status (should fail)
PRINT 'Test 3: Invalid status (should fail)';
BEGIN TRY
    EXEC dbo.NotifyLeaveStatusChange 
        @EmployeeID = 290,
        @RequestID = 29001,
        @Status = 'INVALID_STATUS';
END TRY
BEGIN CATCH
    SELECT 'Expected error' AS TestResult, ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
GO

-- Test 4: Wrong employee for request (should fail)
PRINT 'Test 4: Wrong employee for request (should fail)';
BEGIN TRY
    EXEC dbo.NotifyLeaveStatusChange 
        @EmployeeID = 999,
        @RequestID = 29001,
        @Status = 'APPROVED';
END TRY
BEGIN CATCH
    SELECT 'Expected error' AS TestResult, ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
GO

PRINT 'Test 29 complete.';
PRINT '';
GO