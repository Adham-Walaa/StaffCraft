--SYSTEM ADMIN PROCEDURES 123

USE MILESTONE2;
GO

--1 
-- Procedure: ViewEmployeeInfo
-- Input: @EmployeeID int
-- Output: single row with columns from the Employee table only

CREATE OR ALTER PROCEDURE dbo.ViewEmployeeInfo
    @EmployeeID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT *
    FROM dbo.Employee
    WHERE EmployeeID = @EmployeeID;
END
GO

--2 
-- Procedure: AddEmployee
-- Input: @FullName varchar(100), @Email varchar(100), @DepartmentID int, @PositionID int, @HireDate date
-- Output: new @NewEmployeeID int (OUTPUT) and a confirmation row

CREATE OR ALTER PROCEDURE dbo.AddEmployee
(
    @FullName      VARCHAR(100),
    @Email         VARCHAR(100),
    @DepartmentID  INT,
    @PositionID    INT,
    @HireDate      DATE,
    @NewEmployeeID INT OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;

    IF @FullName IS NULL OR LTRIM(RTRIM(@FullName)) = ''
    BEGIN
        RAISERROR('FullName is required.', 16, 1);
        RETURN;
    END

    IF @Email IS NULL OR LTRIM(RTRIM(@Email)) = ''
    BEGIN
        RAISERROR('Email is required.', 16, 1);
        RETURN;
    END

    -- simple split of FullName into first and last (first token => first_name, rest => last_name)
    DECLARE @FirstName  VARCHAR(50);
    DECLARE @LastName   VARCHAR(50);
    DECLARE @SpacePos   INT;

    SET @FullName = LTRIM(RTRIM(@FullName));
    SET @SpacePos = CHARINDEX(' ', @FullName);

    IF @SpacePos = 0
    BEGIN
        SET @FirstName = LEFT(@FullName, 50);
        SET @LastName  = NULL;
    END
    ELSE
    BEGIN
        SET @FirstName = LEFT(@FullName, CASE WHEN @SpacePos-1 > 50 THEN 50 ELSE @SpacePos-1 END);
        SET @LastName  = LTRIM(SUBSTRING(@FullName, @SpacePos + 1, 50));
    END

    -- check email uniqueness
    IF EXISTS (SELECT 1 FROM dbo.Employee WHERE email = @Email)
    BEGIN
        RAISERROR('Email already exists.', 16, 1);
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        -- generate a new EmployeeID safely (lock the table to avoid race conditions)
        SELECT @NewEmployeeID = ISNULL(MAX(EmployeeID), 0) + 1
        FROM dbo.Employee WITH (TABLOCKX, HOLDLOCK);

        -- insert required minimal fields; other nullable fields left NULL
        INSERT INTO dbo.Employee
        (
            EmployeeID,
            first_name,
            last_name,
            email,
            hire_date,
            is_active,
            department_id,
            position_id
        )
        VALUES
        (
            @NewEmployeeID,
            @FirstName,
            @LastName,
            @Email,
            @HireDate,
            1,         
            @DepartmentID,
            @PositionID
        );

        COMMIT TRANSACTION;

        -- return confirmation row
        SELECT 'Employee created' AS Message, @NewEmployeeID AS EmployeeID;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrNumber INT = ERROR_NUMBER();
        RAISERROR('AddEmployee failed: %s', 16, 1, @ErrMsg);
        RETURN;
    END CATCH
END
GO

--3
-- Procedure: UpdateEmployeeInfo
-- Input: @EmployeeID int, @Email varchar(100), @Phone varchar(20), @Address varchar(150)
-- Output: Confirmation message

CREATE OR ALTER PROCEDURE dbo.UpdateEmployeeInfo
(
    @EmployeeID INT,
    @Email      VARCHAR(100) = NULL,
    @Phone      VARCHAR(20)  = NULL,
    @Address    VARCHAR(150) = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    -- validate employee exists
    IF NOT EXISTS (SELECT 1 FROM dbo.Employee WHERE EmployeeID = @EmployeeID)
    BEGIN
        RAISERROR('Employee with the specified ID does not exist.', 16, 1);
        RETURN;
    END

    -- if email provided, ensure uniqueness (exclude current employee)
    IF @Email IS NOT NULL AND EXISTS (SELECT 1 FROM dbo.Employee WHERE email = @Email AND EmployeeID <> @EmployeeID)
    BEGIN
        RAISERROR('The provided email is already used by another employee.', 16, 1);
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE dbo.Employee
        SET
            email   = CASE WHEN @Email   IS NOT NULL THEN @Email   ELSE email   END,
            phone   = CASE WHEN @Phone   IS NOT NULL THEN @Phone   ELSE phone   END,
            address = CASE WHEN @Address IS NOT NULL THEN @Address ELSE address END
        WHERE EmployeeID = @EmployeeID;

        COMMIT TRANSACTION;

        SELECT 'Employee updated' AS Message, @EmployeeID AS EmployeeID;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('UpdateEmployeeInfo failed: %s', 16, 1, @ErrMsg);
        RETURN;
    END CATCH
END
GO

--4
-- Procedure: AssignRole
-- Input: @EmployeeID int, @RoleID int
-- Output: Confirmation message

CREATE OR ALTER PROCEDURE dbo.AssignRole
(
    @EmployeeID INT,
    @RoleID     INT
)
AS
BEGIN
    SET NOCOUNT ON;

    -- validate employee exists
    IF NOT EXISTS (SELECT 1 FROM dbo.Employee WHERE EmployeeID = @EmployeeID)
    BEGIN
        RAISERROR('Employee with the specified ID does not exist.', 16, 1);
        RETURN;
    END

    -- validate role exists
    IF NOT EXISTS (SELECT 1 FROM dbo.Role WHERE RoleID = @RoleID)
    BEGIN
        RAISERROR('Role with the specified ID does not exist.', 16, 1);
        RETURN;
    END

    -- avoid duplicate assignment
    IF EXISTS (SELECT 1 FROM dbo.EmployeeRole WHERE employee_id = @EmployeeID AND role_id = @RoleID)
    BEGIN
        SELECT 'Employee already assigned to this role' AS Message, @EmployeeID AS EmployeeID, @RoleID AS RoleID;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO dbo.EmployeeRole (employee_id, role_id, assigned_date)
        VALUES (@EmployeeID, @RoleID, CONVERT(date, GETDATE()));

        COMMIT TRANSACTION;

        SELECT 'Role assigned' AS Message, @EmployeeID AS EmployeeID, @RoleID AS RoleID;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('AssignRole failed: %s', 16, 1, @ErrMsg);
        RETURN;
    END CATCH
END
GO

--5
-- Procedure: GetDepartmentEmployeeStats
-- Input: None
-- Output: result set with DepartmentID, department_name, EmployeeCount

CREATE OR ALTER PROCEDURE dbo.GetDepartmentEmployeeStats
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        d.DepartmentID,
        d.department_name,
        COUNT(e.EmployeeID) AS EmployeeCount
    FROM dbo.Department d
    LEFT JOIN dbo.Employee e
        ON e.department_id = d.DepartmentID
    GROUP BY
        d.DepartmentID,
        d.department_name
    ORDER BY
        EmployeeCount DESC, d.department_name;
END
GO


--HR Adminsator 

--1
--Create a new employment contract for an employee.
--Signature:
--Name: CreateContract.
--Input: @EmployeeID int, @Type varchar(50), @StartDate date, @EndDate date.
--Output: Confirmation message.
CREATE PROCEDURE dbo.CreateContract
    @EmployeeID INT,
    @Type VARCHAR(50),
    @StartDate DATETIME,
    @EndDate DATETIME
AS
BEGIN
    INSERT INTO Contract (type, start_date, end_date, current_state)
    VALUES (@Type, @StartDate, @EndDate, @CurrentState, 'PENDING');

    Update Employee
    SET contract_id = SCOPE_IDENTITY()
    WHERE EmployeeID = @EmployeeID;
    
    PRINT 'Contract created successfully';
END;
GO
-- Correct case: Valid EmployeeID, Type, StartDate, and EndDate
--EXEC dbo.CreateContract 
   -- @EmployeeID = 1, 
   -- @Type = 'Full-time', 
   -- @StartDate = '2025-01-01', 
   -- @EndDate = '2025-12-31';

--Testing (Incorrect one)
-- Incorrect case: Non-existing EmployeeID
--EXEC dbo.CreateContract 
   -- @EmployeeID = 999, 
   -- @Type = 'Full-time', 
   -- @StartDate = '2025-01-01', 
   -- @EndDate = '2025-12-31';

--Testing (Incorrect one)
-- Incorrect case: NULL StartDate or EndDate
--EXEC dbo.CreateContract 
   -- @EmployeeID = 1, 
   -- @Type = 'Full-time', 
   -- @StartDate = NULL, 
   -- @EndDate = '2025-12-31';

-- Incorrect case: Invalid EndDate (start date after end date)
-- EXEC dbo.CreateContract 
   -- @EmployeeID = 1, 
   -- @Type = 'Full-time', 
   -- @StartDate = '2025-01-01', 
   -- @EndDate = '2024-12-31';

-- Incorrect case: Missing Contract table
-- EXEC dbo.CreateContract 
   -- @EmployeeID = 1, 
   -- @Type = 'Full-time', 
   -- @StartDate = '2025-01-01', 
   -- @EndDate = '2025-12-31';

-- Incorrect case: Type too long
-- EXEC dbo.CreateContract 
   -- @EmployeeID = 1, 
   -- @Type = 'ThisTypeIsWayTooLongForTheVarcharField',  -- 50+ characters
   -- @StartDate = '2025-01-01', 
   -- @EndDate = '2025-12-31';


-----------------------------------------------------

--2
--Renew or extend an existing contract.
--Signature:
--Name: RenewContract.
--Input: @ContractID int, @NewEndDate date.
--Output: Confirmation message.
CREATE PROCEDURE dbo.RenewContract
    @ContractID INT,
    @EndDate DATETIME
    AS
    BEGIN
        UPDATE Contract
        SET end_date = @EndDate
        WHERE ContractID = @ContractID;
        PRINT 'Contract renewed successfully';
    END;
    GO

-- Correct case: Valid ContractID and EndDate
-- EXEC dbo.RenewContract 
  --  @ContractID = 101, 
  --  @EndDate = '2026-12-31';

-- Incorrect case: Non-existing ContractID
-- EXEC dbo.RenewContract 
   -- @ContractID = 9999, 
   -- @EndDate = '2026-12-31';

-- Incorrect case: NULL EndDate
-- EXEC dbo.RenewContract 
   -- @ContractID = 101, 
   -- @EndDate = NULL;

-- Incorrect case: Invalid EndDate (start date after end date)
-- EXEC dbo.RenewContract 
   -- @ContractID = 101, 
    -- @EndDate = '2024-12-31';  -- EndDate earlier than StartDate


-- Incorrect case: Missing Contract table
-- EXEC dbo.RenewContract 
   -- @ContractID = 101, 
   -- @EndDate = '2026-12-31';
 
-- Incorrect case: Invalid EndDate data type (passing a string)
-- EXEC dbo.RenewContract 
   -- @ContractID = 101, 
   -- @EndDate = 'InvalidDate';

-- Incorrect case: Invalid ContractID data type (passing a string)
-- EXEC dbo.RenewContract 
   -- @ContractID = 'ABC',  -- Not an integer
   -- @EndDate = '2026-12-31';


-----------------------------------------------------

--3
--Approve or reject leave requests from employees.
--Signature:
--Name: ApproveLeaveRequest.
--Input: @LeaveRequestID int, @ApproverID int, @Status varchar(20).
--Output: Confirmation message.
CREATE PROCEDURE dbo.ApproveLeaveRequest
    @LeaveRequestID INT,
    @ApproverID INT,
    @Status VARCHAR(20)
    AS
    BEGIN
        UPDATE LeaveRequest
        SET status = @Status, approver_id = @ApproverID, decision_date = GETDATE()
        WHERE LeaveRequestID = @LeaveRequestID;
        PRINT 'Leave request updated successfully';
    END;
    GO

-- Correct case: Valid LeaveRequestID, ApproverID, and Status
-- EXEC dbo.ApproveLeaveRequest 
   -- @LeaveRequestID = 101, 
   -- @ApproverID = 1001, 
   -- @Status = 'Approved';

-- Incorrect case: Non-existing LeaveRequestID
-- EXEC dbo.ApproveLeaveRequest 
   -- @LeaveRequestID = 9999, 
   -- @ApproverID = 1001, 
   -- @Status = 'Approved';

-- Incorrect case: Status exceeds the allowed length (more than 20 characters)
-- EXEC dbo.ApproveLeaveRequest 
   -- @LeaveRequestID = 101, 
   -- @ApproverID = 1001, 
   -- @Status = 'Approved with extended terms';  -- 25 characters

-- Incorrect case: NULL LeaveRequestID
-- EXEC dbo.ApproveLeaveRequest 
   -- @LeaveRequestID = NULL, 
   -- @ApproverID = 1001, 
   -- @Status = 'Approved';

-- Incorrect case: NULL ApproverID
-- EXEC dbo.ApproveLeaveRequest 
   -- @LeaveRequestID = 101, 
   -- @ApproverID = NULL, 
   --@Status = 'Approved';

-- Incorrect case: Invalid Status data type (passing an integer)
-- EXEC dbo.ApproveLeaveRequest 
   -- @LeaveRequestID = 101, 
   -- @ApproverID = 1001, 
   -- @Status = 1234;  -- Integer instead of VARCHAR

-- Incorrect case: Missing LeaveRequest table
--EXEC dbo.ApproveLeaveRequest 
   -- @LeaveRequestID = 101, 
   -- @ApproverID = 1001, 
   -- @Status = 'Approved';

-----------------------------------------------------

--4
--Assign missions or business trips to employees.
--Signature:
--Name: AssignMission.
--Input: @EmployeeID int, @ManagerID int, @Destination varchar(50), @StartDate date, @EndDate date.
--Output: Confirmation message.
 
CREATE PROCEDURE dbo.AssignMission
    @EmployeeID INT,
    @ManagerID INT,
    @Destination VARCHAR(50),
    @StartDate DATE,
    @EndDate DATE
AS
BEGIN
    INSERT INTO Mission (destination, start_date, end_date, employee_id, manager_id)
    VALUES (@Destination, @StartDate, @EndDate, @EmployeeID, @ManagerID);
    
    PRINT 'Mission assigned successfully to employee ';
END;
GO

-- Correct case: Valid EmployeeID, ManagerID, Destination, StartDate, and EndDate
-- EXEC dbo.AssignMission 
   -- @EmployeeID = 101, 
   -- @ManagerID = 1001, 
   -- @Destination = 'New York', 
   -- @StartDate = '2025-01-01', 
   -- @EndDate = '2025-01-07';

-- Incorrect case: Non-existing EmployeeID
-- EXEC dbo.AssignMission 
   -- @EmployeeID = 9999, 
   -- @ManagerID = 1001, 
   -- @Destination = 'Paris', 
   -- @StartDate = '2025-01-01', 
   -- @EndDate = '2025-01-07';

-- Incorrect case: Invalid Destination data type (passing integer)
-- EXEC dbo.AssignMission 
   -- @EmployeeID = 101, 
   -- @ManagerID = 1001, 
   -- @Destination = 12345,  -- Integer instead of VARCHAR
   -- @StartDate = '2025-01-01', 
   -- @EndDate = '2025-01-07';

-- Incorrect case: NULL StartDate
-- EXEC dbo.AssignMission 
   -- @EmployeeID = 101, 
   -- @ManagerID = 1001, 
   -- @Destination = 'Tokyo', 
   -- @StartDate = NULL, 
   -- @EndDate = '2025-01-07';

-- Incorrect case: NULL EndDate
-- EXEC dbo.AssignMission 
   -- @EmployeeID = 101, 
   -- @ManagerID = 1001, 
   -- @Destination = 'Tokyo', 
   -- @StartDate = '2025-01-01', 
   -- @EndDate = NULL;

-- Incorrect case: Missing Mission table
-- EXEC dbo.AssignMission 
   -- @EmployeeID = 101, 
   -- @ManagerID = 1001, 
   -- @Destination = 'Berlin', 
   -- @StartDate = '2025-01-01', 
   -- @EndDate = '2025-01-07';

-- Incorrect case: Invalid ManagerID data type (passing string instead of integer)
-- EXEC dbo.AssignMission 
   -- @EmployeeID = 101, 
   -- @ManagerID = 'ManagerX',  -- String instead of INT
   -- @Destination = 'Rome', 
   -- @StartDate = '2025-01-01', 
   -- @EndDate = '2025-01-07';
------------------------------------------------------
--5
CREATE PROCEDURE dbo.ReviewReimbursement
    @ReimbursementID INT,
    @ApproverID INT,


    











