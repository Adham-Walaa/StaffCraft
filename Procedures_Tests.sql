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