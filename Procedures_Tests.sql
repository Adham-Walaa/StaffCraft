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

/***** 8) Test NotifyStructureChange *****/
PRINT '--- NotifyStructureChange tests ---';

DECLARE @Nt1 INT, @Nt2 INT, @Nt3 INT;

/* create three test employees if they do not exist; reuse existing ones if present */
IF NOT EXISTS (SELECT 1 FROM dbo.Employee WHERE email = 'test.notify.one@example.com')
BEGIN
    EXEC dbo.AddEmployee
        @FullName = 'Test Notify One',
        @Email = 'test.notify.one@example.com',
        @DepartmentID = 1,
        @PositionID = 1,
        @HireDate = '2025-01-01',
        @NewEmployeeID = @Nt1 OUTPUT;
END
ELSE
BEGIN
    SELECT @Nt1 = EmployeeID FROM dbo.Employee WHERE email = 'test.notify.one@example.com';
END

IF NOT EXISTS (SELECT 1 FROM dbo.Employee WHERE email = 'test.notify.two@example.com')
BEGIN
    EXEC dbo.AddEmployee
        @FullName = 'Test Notify Two',
        @Email = 'test.notify.two@example.com',
        @DepartmentID = 1,
        @PositionID = 1,
        @HireDate = '2025-01-02',
        @NewEmployeeID = @Nt2 OUTPUT;
END
ELSE
BEGIN
    SELECT @Nt2 = EmployeeID FROM dbo.Employee WHERE email = 'test.notify.two@example.com';
END

IF NOT EXISTS (SELECT 1 FROM dbo.Employee WHERE email = 'test.notify.three@example.com')
BEGIN
    EXEC dbo.AddEmployee
        @FullName = 'Test Notify Three',
        @Email = 'test.notify.three@example.com',
        @DepartmentID = 1,
        @PositionID = 1,
        @HireDate = '2025-01-03',
        @NewEmployeeID = @Nt3 OUTPUT;
END
ELSE
BEGIN
    SELECT @Nt3 = EmployeeID FROM dbo.Employee WHERE email = 'test.notify.three@example.com';
END

PRINT 'Test employees for notifications:';
SELECT @Nt1 AS Nt1, @Nt2 AS Nt2, @Nt3 AS Nt3;

-- Build comma-separated list
DECLARE @AffectedList VARCHAR(500) = CONVERT(VARCHAR(12), @Nt1) + ',' + CONVERT(VARCHAR(12), @Nt2) + ',' + CONVERT(VARCHAR(12), @Nt3);
DECLARE @NotifyMsg VARCHAR(200) = 'Test structure change notification: please review changes.';

-- Normal execution
PRINT 'Executing NotifyStructureChange:';
EXEC dbo.NotifyStructureChange @AffectedEmployees = @AffectedList, @Message = @NotifyMsg;

-- Verify entries created
PRINT 'Verify Notification and EmployeeNotification entries:';
SELECT TOP (5) NotificationID, mesage_content, timestamp, urgency, read_status, notification_type
FROM dbo.Notification
WHERE notification_type = 'StructureChange'
ORDER BY NotificationID DESC;

SELECT en.employee_id, en.notification_id, en.delivery_status, n.mesage_content
FROM dbo.EmployeeNotification en
JOIN dbo.Notification n ON n.NotificationID = en.notification_id
WHERE en.employee_id IN (@Nt1, @Nt2, @Nt3)
ORDER BY en.employee_id;
GO

/***** 9) Test ViewOrgHierarchy *****/
PRINT '--- ViewOrgHierarchy tests ---';

-- Ensure a simple hierarchy: make @Nt1 the manager of @Nt2 and @Nt3
BEGIN
    -- If ReassignManager raises an error it will abort the batch; use conditional to avoid duplicate attempts
    IF EXISTS (SELECT 1 FROM dbo.Employee WHERE EmployeeID = @Nt2) AND NOT EXISTS (SELECT 1 FROM dbo.Employee WHERE EmployeeID = @Nt2 AND manager_id = @Nt1)
        EXEC dbo.ReassignManager @EmployeeID = @Nt2, @NewManagerID = @Nt1;

    IF EXISTS (SELECT 1 FROM dbo.Employee WHERE EmployeeID = @Nt3) AND NOT EXISTS (SELECT 1 FROM dbo.Employee WHERE EmployeeID = @Nt3 AND manager_id = @Nt1)
        EXEC dbo.ReassignManager @EmployeeID = @Nt3, @NewManagerID = @Nt1;
END

PRINT 'Full organization hierarchy (sample):';
EXEC dbo.ViewOrgHierarchy @AffectedEmployees = NULL, @Message = NULL;

PRINT 'Filtered hierarchy for test employees:';
EXEC dbo.ViewOrgHierarchy @AffectedEmployees = @AffectedList, @Message = NULL;
GO

/***** 10) Test AssignShiftToEmployee *****/
PRINT '--- AssignShiftToEmployee tests ---';

-- Validate required tables exist
IF OBJECT_ID('dbo.ShiftSchedule', 'U') IS NULL
BEGIN
    PRINT 'Skipping AssignShiftToEmployee tests: dbo.ShiftSchedule table is missing.';
END
ELSE
BEGIN
    -- find a ShiftID to reference
    DECLARE @TestShiftID INT;
    IF OBJECT_ID('dbo.Shift', 'U') IS NULL
    BEGIN
        PRINT 'dbo.Shift table is missing; attempt to insert into ShiftSchedule would fail due to FK. Skipping shift assignment tests.';
    END
    ELSE
    BEGIN
        SELECT TOP (1) @TestShiftID = ShiftID FROM dbo.Shift;

        IF @TestShiftID IS NULL
        BEGIN
            PRINT 'dbo.Shift exists but contains no rows. Insert a Shift row first to run AssignShiftToEmployee tests.';
        END
        ELSE
        BEGIN
            -- prepare a non-overlapping term for @Nt2
            DECLARE @SStart DATE = '2025-08-01';
            DECLARE @SEnd   DATE = '2025-08-31';

            PRINT 'Assigning a shift (normal case):';
            EXEC dbo.AssignShiftToEmployee @EmployeeID = @Nt2, @ShiftID = @TestShiftID, @StartDate = @SStart, @EndDate = @SEnd;

            -- show recent ShiftSchedule rows for the employee
            SELECT ShiftID AS ShiftSchedulePK, employee_id, shift_id AS ShiftRef, start_date, end_date, status
            FROM dbo.ShiftSchedule
            WHERE employee_id = @Nt2
            ORDER BY ShiftID DESC;

            -- attempt overlapping assignment (should be rejected)
            PRINT 'Attempt overlapping assignment (expected to fail):';
            BEGIN TRY
                EXEC dbo.AssignShiftToEmployee @EmployeeID = @Nt2, @ShiftID = @TestShiftID, @StartDate = '2025-08-15', @EndDate = '2025-09-15';
            END TRY
            BEGIN CATCH
                PRINT 'Overlapping assignment prevented (caught RAISERROR).';
            END CATCH
        END
    END
END
GO

/***** Cleanup / verification queries (optional) *****/
-- Quick listing of employees created during tests
SELECT EmployeeID, first_name, last_name, email, department_id, position_id, hire_date
FROM dbo.Employee
WHERE email IN ('alice.updated@example.com','bob.johnson@example.com','carol.white@example.com',
                'test.notify.one@example.com','test.notify.two@example.com','test.notify.three@example.com');
GO
