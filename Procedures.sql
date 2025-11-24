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

-------------------------------------------------------------------------------------------------------------------
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
--There is NO column for: approver_id, decision_date, status/decision except current_status. Any field that can store who approved a claim.

--6
CREATE PROCEDURE dbo.getActiveContracts
AS
BEGIN
   SELECT *
   FROM Contract
   WHERE current_state = 'ACTIVE' or end_date > GETDATE();
END;
GO

-- Correct case: Retrieve active contracts
-- EXEC dbo.GetActiveContracts;

-- Incorrect case: No active contracts
-- EXEC dbo.GetActiveContracts;

-- Incorrect case: Missing or empty Contract table
-- EXEC dbo.GetActiveContracts;

-- Incorrect case: Missing current_state or end_date columns in Contract table
-- EXEC dbo.GetActiveContracts;

-- Incorrect case: NULL values in current_state or end_date
-- EXEC dbo.GetActiveContracts;
------------------------------------------------------

--7
CREATE PROCEDURE dbo.GetTeamByManager
    @ManagerID INT
AS
BEGIN
    SELECT employee_id, first_name, last_name
    FROM Employee
    WHERE manager_id = @ManagerID;
END;
GO

-- Correct case: Retrieve employees under ManagerID = 1001
-- EXEC dbo.GetTeamByManager 
   -- @ManagerID = 1001;

-- Incorrect case: Non-existing ManagerID
-- EXEC dbo.GetTeamByManager 
   -- @ManagerID = 9999;  -- Assuming 9999 is not a valid manager_id

-- Incorrect case: NULL ManagerID
-- EXEC dbo.GetTeamByManager 
   -- @ManagerID = NULL;

-- Incorrect case: Missing Employee table
-- EXEC dbo.GetTeamByManager 
   -- @ManagerID = 1001;

-- Incorrect case: Missing manager_id column in Employee table
-- EXEC dbo.GetTeamByManager 
   -- @ManagerID = 1001;
------------------------------------------------------
--8
CREATE PROCEDURE dbo.UpdateLeavePolicy
    @PolicyID INT,
    @EligibilityRules VARCHAR(500),
    @NoticePeriod INT
    AS
    BEGIN
    UPDATE LeavePolicy
    SET eligibility_rules = @EligibilityRules,
        notice_period = @NoticePeriod
    WHERE PolicyID = @PolicyID;
    PRINT 'Leave policy updated successfully';
    END;
    GO

-- Correct case: Update leave policy with valid PolicyID, EligibilityRules, and NoticePeriod
-- EXEC dbo.UpdateLeavePolicy 
   -- @PolicyID = 101, 
   -- @EligibilityRules = 'Employees must be with the company for at least 6 months to qualify for leave.', 
   -- @NoticePeriod = 30;

-- Incorrect case: Non-existing PolicyID
--EXEC dbo.UpdateLeavePolicy 
   -- @PolicyID = 9999, 
   -- @EligibilityRules = 'New rules for leave eligibility.', 
   -- @NoticePeriod = 15;

-- Incorrect case: NULL PolicyID
-- EXEC dbo.UpdateLeavePolicy 
   -- @PolicyID = NULL, 
   -- @EligibilityRules = 'Updated eligibility rules.', 
   -- @NoticePeriod = 20;

-- Incorrect case: Invalid data type for EligibilityRules (passing an integer)
-- EXEC dbo.UpdateLeavePolicy 
   -- @PolicyID = 101, 
   -- @EligibilityRules = 12345,  -- Integer instead of VARCHAR
   -- @NoticePeriod = 20;

-- Incorrect case: Missing LeavePolicy table
-- EXEC dbo.UpdateLeavePolicy 
   -- @PolicyID = 101, 
   -- @EligibilityRules = 'Updated eligibility rules.', 
   -- @NoticePeriod = 20;

-- Incorrect case: Invalid data type for NoticePeriod (passing a string)
-- EXEC dbo.UpdateLeavePolicy 
   -- @PolicyID = 101, 
   -- @EligibilityRules = 'Updated eligibility rules.', 
   -- @NoticePeriod = 'Thirty';  -- String instead of INT
-------------------------------------------------------
--9
CREATE PROCEDURE dbo.GetExpiringContracts
    @DaysBefore INT
AS
BEGIN
    SELECT contract_id, type, start_date, end_date, current_state
    FROM Contract
    WHERE DATEDIFF(DAY, GETDATE(), end_date) <= @DaysBefore
      AND current_state = 'ACTIVE';
END;
GO

-- Correct case: Retrieve contracts expiring within the next 30 days
-- EXEC dbo.GetExpiringContracts 
   -- @DaysBefore = 30;

-- Incorrect case: No contracts expiring within the next 5 days
-- EXEC dbo.GetExpiringContracts 
   -- @DaysBefore = 5;

-- Incorrect case: NULL DaysBefore
-- EXEC dbo.GetExpiringContracts 
   -- @DaysBefore = NULL;

-- Incorrect case: Invalid data type for DaysBefore (passing string)
-- EXEC dbo.GetExpiringContracts 
   -- @DaysBefore = 'Thirty';  -- String instead of INT

-- Incorrect case: Missing Contract table
-- EXEC dbo.GetExpiringContracts 
   -- @DaysBefore = 30;
-------------------------------------------------------
--10
CREATE PROCEDURE dbo.AssignDepartmentHead
    @DepartmentID INT,
    @ManagerID INT
AS
BEGIN
    UPDATE Department
    SET department_head_id = @ManagerID
    WHERE department_id = @DepartmentID;

    PRINT 'Department head assigned successfully';
END;
GO

-- Correct case: Assign manager with ID 1001 as the department head for department 1
-- EXEC dbo.AssignDepartmentHead 
   -- @DepartmentID = 1, 
   -- @ManagerID = 1001;

-- Incorrect case: Non-existing DepartmentID
-- EXEC dbo.AssignDepartmentHead 
   -- @DepartmentID = 9999, 
   -- @ManagerID = 1001;

-- Incorrect case: NULL ManagerID
-- EXEC dbo.AssignDepartmentHead 
   -- @DepartmentID = 1, 
   -- @ManagerID = NULL;

-- Incorrect case: Invalid data type for ManagerID (passing a string)
-- EXEC dbo.AssignDepartmentHead 
   -- @DepartmentID = 1, 
   -- @ManagerID = 'ManagerX';  -- String instead of INT

-- Incorrect case: Missing Department table
-- EXEC dbo.AssignDepartmentHead 
   -- @DepartmentID = 1, 
   -- @ManagerID = 1001;
---------------------------------------------------------
--11
CREATE PROCEDURE dbo.CreateEmployeeProfile
    @FirstName VARCHAR(50),
    @LastName VARCHAR(50),
    @DepartmentID INT,
    @RoleID INT,
    @HireDate DATE,
    @Email VARCHAR(100),
    @Phone VARCHAR(20)
AS
BEGIN
    INSERT INTO Employee (first_name, last_name, hire_date, email, phone, department_id, role_id, national_id, date_of_birth, country_of_birth)
    VALUES (@FirstName, @LastName, @HireDate, @Email, @Phone, @DepartmentID, @RoleID, @NationalID, @DateOfBirth, @CountryOfBirth);

    DECLARE @EmployeeID INT;
    SET @EmployeeID = SCOPE_IDENTITY();

    PRINT 'Employee profile created successfully with EmployeeID ';
END;
GO

-- Correct case: Insert new employee profile with valid data
-- EXEC dbo.CreateEmployeeProfile 
   -- @FirstName = 'John', 
   -- @LastName = 'Doe', 
   -- @DepartmentID = 1, 
   -- @RoleID = 2, 
   -- @HireDate = '2025-01-01', 
   -- @Email = 'john.doe@example.com', 
   -- @Phone = '123-456-7890';

-- Incorrect case: Invalid DepartmentID or RoleID
-- EXEC dbo.CreateEmployeeProfile 
   -- @FirstName = 'Jane', 
   -- @LastName = 'Smith', 
   -- @DepartmentID = 9999,  -- Non-existing DepartmentID
   -- @RoleID = 9999,        -- Non-existing RoleID
   -- @HireDate = '2025-01-01', 
   -- @Email = 'jane.smith@example.com', 
   -- @Phone = '987-654-3210';

-- Incorrect case: NULL FirstName or LastName
-- EXEC dbo.CreateEmployeeProfile 
   -- @FirstName = NULL, 
   -- @LastName = NULL, 
   -- @DepartmentID = 1, 
   -- @RoleID = 2, 
   -- @HireDate = '2025-01-01', 
   -- @Email = 'jane.smith@example.com', 
   -- @Phone = '987-654-3210';

-- Incorrect case: Invalid email and phone number format
-- EXEC dbo.CreateEmployeeProfile 
   -- @FirstName = 'Mark', 
   -- @LastName = 'Taylor', 
   -- @DepartmentID = 1, 
   -- @RoleID = 2, 
   -- @HireDate = '2025-01-01', 
   -- @Email = 'invalidemail',  -- Invalid email format
   -- @Phone = '12345';         -- Invalid phone format
------------------------------------------------------------
--12 (Keep for now still)
CREATE PROCEDURE dbo.UpdateEmployeeProfile
    @EmployeeID INT,
    @FieldName VARCHAR(50),
    @NewValue VARCHAR(255)
AS
BEGIN
    -- Declare a variable to hold the dynamic SQL query
    IF @FieldName = 'email' 
    Update Employee SET email = @NewValue WHERE EmployeeID = @EmployeeID;
    ELSE IF @FieldName = 'phone'
    Update Employee SET phone = @NewValue WHERE EmployeeID = @EmployeeID;
    ELSE IF @FieldName = 'address'
    Update Employee SET address = @NewValue WHERE EmployeeID = @EmployeeID;
    ELSE IF @FieldName = 'employment_status'
    Update Employee SET employment_status = @NewValue WHERE EmployeeID = @EmployeeID;
    ELSE IF @FieldName = 'emergency_contact_phone'
    Update Employee SET emergency_contact_phone = @NewValue WHERE EmployeeID = @EmployeeID;
    ELSE IF @FieldName = 'emergency_contact_name'
    Update Employee SET emergency_contact_name = @NewValue WHERE EmployeeID = @EmployeeID;
    ELSE IF @FieldName = 'is_active'
    Update Employee SET is_active = CASE WHEN @NewValue = '1' THEN 1 ELSE 0 END WHERE EmployeeID = @EmployeeID;
    ELSE IF @FieldName = 'profile_completion_percentage'
    Update Employee SET profile_completion_percentage = CAST(@NewValue AS INT) WHERE EmployeeID = @EmployeeID;
    ELSE IF @FieldName = 'account_status'
    Update Employee SET account_status = @NewValue WHERE EmployeeID = @EmployeeID;
    ELSE IF @FieldName = 'employment_progress'
    Update Employee SET employment_progress = @NewValue WHERE EmployeeID = @EmployeeID;
    ELSE IF @FieldName = 'relationship'
    Update Employee SET relationship = @NewValue WHERE EmployeeID = @EmployeeID;
    ELSE IF @FieldName = 'biography'
    Update Employee SET biography = @NewValue WHERE EmployeeID = @EmployeeID;
    BEGIN
        RAISERROR('Invalid FieldName provided.', 16, 1);
        RETURN;
    END
    PRINT 'Employee profile updated successfully';
    END;



-- Correct case: Update first_name for EmployeeID = 101
-- EXEC dbo.UpdateEmployeeProfile 
   -- @EmployeeID = 101, 
   -- @FieldName = 'first_name', 
   -- @NewValue = 'John';

-- Incorrect case: Non-existing EmployeeID
-- EXEC dbo.UpdateEmployeeProfile 
   -- @EmployeeID = 9999, 
   -- @FieldName = 'first_name', 
   -- @NewValue = 'Jane';

-- Incorrect case: Invalid FieldName
-- EXEC dbo.UpdateEmployeeProfile 
   -- @EmployeeID = 101, 
   -- @FieldName = 'invalid_field', 
   -- @NewValue = 'NewValue';

-- Incorrect case: NULL FieldName
-- EXEC dbo.UpdateEmployeeProfile 
   -- @EmployeeID = 101, 
   -- @FieldName = NULL, 
   -- @NewValue = 'NewValue';

-- Incorrect case: Invalid data type for NewValue (passing integer instead of string)
-- EXEC dbo.UpdateEmployeeProfile 
   -- @EmployeeID = 101, 
   -- @FieldName = 'first_name', 
   -- @NewValue = 12345;  -- Invalid, should be a string


--------------------------------------------------------
--13 

CREATE PROCEDURE dbo.SetProfileCompleteness
    @EmployeeID INT,
    @CompletenessPercentage INT
AS
BEGIN
    -- Update the profile_completion_percentage for the specified employee
    UPDATE Employee
    SET profile_completion_percentage = @CompletenessPercentage
    WHERE EmployeeID = @EmployeeID;

    -- Print a success message or return the updated value
    PRINT 'Employee profile completeness for EmployeeID ' + CAST(@EmployeeID AS VARCHAR) + 
          ' updated to ' + CAST(@CompletenessPercentage AS VARCHAR) + '%';
END;
GO

-- Correct case: Update profile completeness for EmployeeID = 101
-- EXEC dbo.SetProfileCompleteness 
   -- @EmployeeID = 101, 
   -- @CompletenessPercentage = 85;

-- Incorrect case: Non-existing EmployeeID
-- EXEC dbo.SetProfileCompleteness 
   -- @EmployeeID = 9999, 
   -- @CompletenessPercentage = 90;

-- Incorrect case: NULL EmployeeID
-- EXEC dbo.SetProfileCompleteness 
   -- @EmployeeID = NULL, 
   -- @CompletenessPercentage = 80;

-- Incorrect case: Invalid data type for CompletenessPercentage (passing a string instead of an integer)
-- EXEC dbo.SetProfileCompleteness 
   -- @EmployeeID = 101, 
   -- @CompletenessPercentage = 'Eighty';  -- String instead of INT

-- Incorrect case: CompletenessPercentage outside valid range
-- EXEC dbo.SetProfileCompleteness 
   -- @EmployeeID = 101, 
   -- @CompletenessPercentage = 110;  -- Invalid percentage


---------------------------------------------------------
--14
CREATE PROCEDURE dbo.GenerateProfileReport
    @FilterField VARCHAR(50),
    @FilterValue VARCHAR(100)
AS
BEGIN
    -- Declare a variable to hold the dynamic SQL query
    DECLARE @SQL NVARCHAR(MAX);
    
    -- Build the dynamic SQL query
    IF @FilterField = 'department_id'
    BEGIN
        SET @SQL = 'SELECT e.employee_id, e.first_name, e.last_name, e.email, e.phone, e.department_id, e.position_id, e.employment_status
                    FROM Employee e
                    INNER JOIN Department d ON e.department_id = d.department_id
                    WHERE d.department_name = @FilterValue';
    END
    ELSE IF @FilterField = 'position_id'
    BEGIN
        SET @SQL = 'SELECT e.employee_id, e.first_name, e.last_name, e.email, e.phone, e.department_id, e.position_id, e.employment_status
                    FROM Employee e
                    INNER JOIN Position p ON e.position_id = p.position_id
                    WHERE p.position_title = @FilterValue';
    END
    ELSE
    BEGIN
        SET @SQL = 'SELECT employee_id, first_name, last_name, email, phone, department_id, position_id, employment_status
                    FROM Employee
                    WHERE ' + QUOTENAME(@FilterField) + ' = @FilterValue';
    END

    -- Execute the dynamic SQL query
    EXEC sp_executesql @SQL, N'@FilterValue VARCHAR(100)', @FilterValue;

    -- Print a success message
    PRINT 'Report generated successfully based on ' + @FilterField + ' = ' + @FilterValue;
END;
GO

-- Correct case: Filter by department_name 'IT'
-- EXEC dbo.GenerateProfileReport 
   -- @FilterField = 'department_id', 
   -- @FilterValue = 'IT';

-- Correct case: Filter by position_title 'Manager'
-- EXEC dbo.GenerateProfileReport 
   -- @FilterField = 'position_id', 
   -- @FilterValue = 'Manager';

-- Incorrect case: Invalid FilterField
-- EXEC dbo.GenerateProfileReport 
   -- @FilterField = 'invalid_field', 
   -- @FilterValue = 'Value';

-- Incorrect case: NULL FilterField
-- EXEC dbo.GenerateProfileReport 
   -- @FilterField = NULL, 
   -- @FilterValue = 'Value';
--------------------------------------------------------------
--15








