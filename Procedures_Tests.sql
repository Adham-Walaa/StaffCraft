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

-- Successful inserts
EXEC dbo.AddEmployee
    @FullName = 'Taher Khalaf',  --input
    @Email = 'taher.skhalaf@gmail.com',  --input
    @DepartmentID = 3,  --input
    @PositionID = 2,  --input
    @HireDate = '2025-01-01',  --input
    @NewEmployeeID = 6; --input

EXEC dbo.AddEmployee
    @FullName = 'Jaquavius Johnson',  --input
    @Email = 'JAQ.johnson@example.com',  --input
    @DepartmentID = 2,  --input
    @PositionID = 2,  --input
    @HireDate = '2024-10-01',  --input
    @NewEmployeeID =7;  --input
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

/***** 5) Test GetDepartmentEmployeeStats *****/
-- Run stats
EXEC dbo.GetDepartmentEmployeeStats;
GO

/***** 6) Test ReassignManager *****/
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

-- Run the procedure (parameters accepted but not used)
EXEC dbo.ViewOrgHierarchy @AffectedEmployees = NULL, @Message = NULL;
GO


/***** 10) Test AssignShiftToEmployee *****/
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
