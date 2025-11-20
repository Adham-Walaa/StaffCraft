-- Test script for Procedures.sql
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

/***** 1) Test AddEmployee *****/
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

/***** 2) Test ViewEmployeeInfo *****/
PRINT '--- ViewEmployeeInfo tests ---';
-- View Alice
EXEC dbo.ViewEmployeeInfo @EmployeeID = @Id1;
-- View Bob
EXEC dbo.ViewEmployeeInfo @EmployeeID = @Id2;
-- Non-existent ID (should return 0 rows)
EXEC dbo.ViewEmployeeInfo @EmployeeID = 9999;
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

/***** 6) Test ReassignManager *****/
PRINT '--- ReassignManager tests ---';

-- Create two employees in the same batch and capture their IDs
DECLARE @MgrID INT, @EmpID INT;

EXEC dbo.AddEmployee
    @FullName = 'Manager Test',
    @Email = 'manager.test@example.com',
    @DepartmentID = 1,
    @PositionID = 2,
    @HireDate = '2025-01-01',
    @NewEmployeeID = @MgrID OUTPUT;

EXEC dbo.AddEmployee
    @FullName = 'Employee Test',
    @Email = 'employee.test@example.com',
    @DepartmentID = 1,
    @PositionID = 1,
    @HireDate = '2025-02-01',
    @NewEmployeeID = @EmpID OUTPUT;

SELECT 'Created' AS Action, @MgrID AS ManagerID, @EmpID AS EmployeeID;

-- Reassign manager (normal case)
EXEC dbo.ReassignManager @EmployeeID = @EmpID, @NewManagerID = @MgrID;

-- Verify assignment
PRINT 'Verify manager assignment for employee:';
EXEC dbo.ViewEmployeeInfo @EmployeeID = @EmpID;

-- Attempt to create a cycle: assign employee as manager of their manager (should error)
PRINT 'Attempt cycle creation (expected error):';
-- The following call is expected to RAISERROR due to cycle prevention
EXEC dbo.ReassignManager @EmployeeID = @MgrID, @NewManagerID = @EmpID;

GO

/***** 7) Test ReassignHierarchy *****/
PRINT '--- ReassignHierarchy tests ---';

DECLARE @MgrA INT, @MgrB INT, @EmpA INT, @Dept3 INT;

-- ensure a third department exists for testing
IF NOT EXISTS (SELECT 1 FROM dbo.Department WHERE DepartmentID = 3)
    INSERT INTO dbo.Department (DepartmentID, department_name, purpose) VALUES (3, 'Engineering', 'Engineering Dept');

SET @Dept3 = 3;

-- create two managers and one employee
EXEC dbo.AddEmployee
    @FullName = 'Manager A',
    @Email = 'manager.a@example.com',
    @DepartmentID = 1,
    @PositionID = 2,
    @HireDate = '2025-01-01',
    @NewEmployeeID = @MgrA OUTPUT;

EXEC dbo.AddEmployee
    @FullName = 'Manager B',
    @Email = 'manager.b@example.com',
    @DepartmentID = 2,
    @PositionID = 2,
    @HireDate = '2025-01-02',
    @NewEmployeeID = @MgrB OUTPUT;

EXEC dbo.AddEmployee
    @FullName = 'Employee A',
    @Email = 'employee.a@example.com',
    @DepartmentID = 1,
    @PositionID = 1,
    @HireDate = '2025-02-01',
    @NewEmployeeID = @EmpA OUTPUT;

SELECT 'Created' AS Action, @MgrA AS ManagerAID, @MgrB AS ManagerBID, @EmpA AS EmployeeAID;

-- 1) Change department only
PRINT 'Test: change department only';
EXEC dbo.ReassignHierarchy @EmployeeID = @EmpA, @NewDepartmentID = @Dept3, @NewManagerID = NULL;
EXEC dbo.ViewEmployeeInfo @EmployeeID = @EmpA;

-- 2) Change manager only
PRINT 'Test: change manager only';
EXEC dbo.ReassignHierarchy @EmployeeID = @EmpA, @NewDepartmentID = NULL, @NewManagerID = @MgrB;
EXEC dbo.ViewEmployeeInfo @EmployeeID = @EmpA;

-- 3) Change both department and manager
PRINT 'Test: change both department and manager';
EXEC dbo.ReassignHierarchy @EmployeeID = @EmpA, @NewDepartmentID = 2, @NewManagerID = @MgrB;
EXEC dbo.ViewEmployeeInfo @EmployeeID = @EmpA;

-- 4) Attempt invalid manager (cycle) - create a subordinate relationship and attempt reverse
PRINT 'Test: cycle prevention (expected error)';
-- make EmpA manager of MgrA (to create subordinate)
EXEC dbo.ReassignManager @EmployeeID = @MgrA, @NewManagerID = @EmpA;

-- Now attempt to set EmpA's manager to MgrA which would create a cycle (expected RAISERROR)
-- This call should fail due to cycle detection
EXEC dbo.ReassignHierarchy @EmployeeID = @EmpA, @NewManagerID = @MgrA;

GO

/***** Cleanup / verification queries (optional) *****/
-- Quick listing of employees created during tests
SELECT EmployeeID, first_name, last_name, email, department_id, position_id, hire_date
FROM dbo.Employee
WHERE email IN ('alice.updated@example.com','bob.johnson@example.com','carol.white@example.com');
GO
