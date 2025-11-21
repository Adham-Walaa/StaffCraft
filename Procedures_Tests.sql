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

USE MILESTONE2;
GO

/***** Setup required reference data *****/
-- Departments
IF NOT EXISTS (SELECT 1 FROM dbo.Department WHERE DepartmentID = 1)
    INSERT INTO dbo.Department (DepartmentID, department_name, purpose) VALUES (1, 'Human Resources', 'HR and People Ops');
IF NOT EXISTS (SELECT 1 FROM dbo.Department WHERE DepartmentID = 2)
    INSERT INTO dbo.Department (DepartmentID, department_name, purpose) VALUES (2, 'Finance', 'Payroll and Finance');
IF NOT EXISTS (SELECT 1 FROM dbo.Department WHERE DepartmentID = 3)
    INSERT INTO dbo.Department (DepartmentID, department_name, purpose) VALUES (3, 'Engineering', 'Engineering Dept');

-- Positions
IF NOT EXISTS (SELECT 1 FROM dbo.Position WHERE PositionID = 1)
    INSERT INTO dbo.Position (PositionID, position_title, responsibilities) VALUES (1, 'Developer', 'Develops software');
IF NOT EXISTS (SELECT 1 FROM dbo.Position WHERE PositionID = 2)
    INSERT INTO dbo.Position (PositionID, position_title, responsibilities) VALUES (2, 'Manager', 'Manages team');

-- Roles
IF NOT EXISTS (SELECT 1 FROM dbo.Role WHERE RoleID = 1)
    INSERT INTO dbo.Role (RoleID, role_name, purpose) VALUES (1, 'Payroll Officer', 'Handles payroll');
IF NOT EXISTS (SELECT 1 FROM dbo.Role WHERE RoleID = 2)
    INSERT INTO dbo.Role (RoleID, role_name, purpose) VALUES (2, 'Manager', 'Manager role');
GO

/***** 1) Test ViewEmployeeInfo *****/
PRINT '--- ViewEmployeeInfo tests ---';
DECLARE @Id1 INT, @Id2 INT;
-- View Alice
EXEC dbo.ViewEmployeeInfo @EmployeeID = @Id1;
-- View Bob
EXEC dbo.ViewEmployeeInfo @EmployeeID = @Id2;
-- Non-existent ID (should return 0 rows)
EXEC dbo.ViewEmployeeInfo @EmployeeID = 9999;
GO

/***** 2) Test AddEmployee *****/
PRINT '--- AddEmployee tests ---';
DECLARE @Id1 INT, @Id2 INT, @Id3 INT;

-- Successful inserts
EXEC dbo.AddEmployee
    @FullName = 'Alice Smith',
    @Email = 'alice.smith@example.com',
    @DepartmentID = 1,
    @PositionID = 1,
    @HireDate = '2025-01-15',
    @NewEmployeeID = @Id1 OUTPUT;
SELECT 'Created' AS Action, @Id1 AS EmployeeID;

EXEC dbo.AddEmployee
    @FullName = 'Bob Johnson',
    @Email = 'bob.johnson@example.com',
    @DepartmentID = 2,
    @PositionID = 2,
    @HireDate = '2024-10-01',
    @NewEmployeeID = @Id2 OUTPUT;
SELECT 'Created' AS Action, @Id2 AS EmployeeID;

-- Attempt duplicate email (expected to error) - commented out; uncomment to verify error path
-- EXEC dbo.AddEmployee @FullName='Alice Dup', @Email='alice.smith@example.com', @DepartmentID=1, @PositionID=1, @HireDate='2025-02-01', @NewEmployeeID=@Id3 OUTPUT;
GO

/***** 3) Test UpdateEmployeeInfo *****/
PRINT '--- UpdateEmployeeInfo tests ---';
-- Update Alice's contact details
EXEC dbo.UpdateEmployeeInfo
    @EmployeeID = @Id1,
    @Email = 'alice.updated@example.com',
    @Phone = '555-0101',
    @Address = '123 Main St';
-- Verify update
EXEC dbo.ViewEmployeeInfo @EmployeeID = @Id1;

-- Attempt update with existing email of another employee (should RAISERROR) - commented
-- EXEC dbo.UpdateEmployeeInfo @EmployeeID = @Id1, @Email = 'bob.johnson@example.com';
GO

/***** 4) Test AssignRole *****/
PRINT '--- AssignRole tests ---';
-- Assign Payroll Officer to Alice
EXEC dbo.AssignRole @EmployeeID = @Id1, @RoleID = 1;
-- Assign Manager role to Bob
EXEC dbo.AssignRole @EmployeeID = @Id2, @RoleID = 2;
-- Re-assign same role (should return already assigned message)
EXEC dbo.AssignRole @EmployeeID = @Id1, @RoleID = 1;

-- Show EmployeeRole contents for test employees
SELECT * FROM dbo.EmployeeRole WHERE employee_id IN (@Id1, @Id2);
GO

/***** 5) Test GetDepartmentEmployeeStats *****/
PRINT '--- GetDepartmentEmployeeStats tests ---';
-- Add a third employee to Department 1 to exercise counts
DECLARE @Id4 INT;
EXEC dbo.AddEmployee
    @FullName = 'Carol White',
    @Email = 'carol.white@example.com',
    @DepartmentID = 1,
    @PositionID = 1,
    @HireDate = '2025-03-10',
    @NewEmployeeID = @Id4 OUTPUT;

-- Run stats
EXEC dbo.GetDepartmentEmployeeStats;
GO



