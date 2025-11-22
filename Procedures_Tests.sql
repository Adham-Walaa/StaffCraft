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

/***** 5) Test GetDepartmentEmployeeStats *****/
-- Add a third employee to Department 1 to exercise counts
DECLARE @Id4 INT;
EXEC dbo.AddEmployee 
    @FullName = 'Carol White',  --input
    @Email = 'carol.white@example.com',  --input
    @DepartmentID = 1,  --input
    @PositionID = 1,  --input 
    @HireDate = '2025-03-10',  --input 
    @NewEmployeeID = @Id4 OUTPUT;  --input

-- Run stats
EXEC dbo.GetDepartmentEmployeeStats;
GO
