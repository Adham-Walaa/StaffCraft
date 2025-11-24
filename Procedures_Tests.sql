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


