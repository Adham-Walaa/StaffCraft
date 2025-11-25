--SYSTEM ADMIN PROCEDURES

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
    @EmployeeID INT = NULL,
    @IdentifierEmail VARCHAR(100) = NULL, -- optional: locate employee by email when ID isn't provided
    @Email      VARCHAR(100) = NULL,
    @Phone      VARCHAR(20)  = NULL,
    @Address    VARCHAR(150) = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @TargetEmployeeID INT;

    -- Determine target employee: prefer explicit ID, otherwise try identifier email
    IF @EmployeeID IS NOT NULL
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM dbo.Employee WHERE EmployeeID = @EmployeeID)
        BEGIN
            RAISERROR('Employee with the specified ID does not exist.', 16, 1);
            RETURN;
        END
        SET @TargetEmployeeID = @EmployeeID;
    END
    ELSE IF @IdentifierEmail IS NOT NULL
    BEGIN
        SELECT @TargetEmployeeID = EmployeeID
        FROM dbo.Employee
        WHERE email = @IdentifierEmail;

        IF @TargetEmployeeID IS NULL
        BEGIN
            RAISERROR('No employee found with the specified identifier email.', 16, 1);
            RETURN;
        END
    END
    ELSE
    BEGIN
        RAISERROR('Either @EmployeeID or @IdentifierEmail must be supplied to identify the employee.', 16, 1);
        RETURN;
    END

    -- if email provided, ensure uniqueness (exclude target employee)
    IF @Email IS NOT NULL AND EXISTS (SELECT 1 FROM dbo.Employee WHERE email = @Email AND EmployeeID <> @TargetEmployeeID)
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
        WHERE EmployeeID = @TargetEmployeeID;

        COMMIT TRANSACTION;

        SELECT 'Employee updated' AS Message, @TargetEmployeeID AS EmployeeID, @@ROWCOUNT AS RowsAffected;
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
CREATE PROCEDURE CreateContract
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


-----------------------------------------------------

--2
--Renew or extend an existing contract.
--Signature:
--Name: RenewContract.
--Input: @ContractID int, @NewEndDate date.
--Output: Confirmation message.
CREATE PROCEDURE RenewContract
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


-----------------------------------------------------

--3
--Approve or reject leave requests from employees.
--Signature:
--Name: ApproveLeaveRequest.
--Input: @LeaveRequestID int, @ApproverID int, @Status varchar(20).
--Output: Confirmation message.
CREATE PROCEDURE ApproveLeaveRequest
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


-----------------------------------------------------

--4
--Assign missions or business trips to employees.
--Signature:
--Name: AssignMission.
--Input: @EmployeeID int, @ManagerID int, @Destination varchar(50), @StartDate date, @EndDate date.
--Output: Confirmation message.
 
CREATE PROCEDURE AssignMission
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


------------------------------------------------------
--5
--There is NO column for: approver_id, decision_date, status/decision except current_status. Any field that can store who approved a claim.

--6
CREATE PROCEDURE getActiveContracts
AS
BEGIN
   SELECT *
   FROM Contract
   WHERE current_state = 'ACTIVE' or end_date > GETDATE();
END;
GO

------------------------------------------------------

--7
CREATE PROCEDURE GetTeamByManager
    @ManagerID INT
AS
BEGIN
    SELECT employee_id, first_name, last_name
    FROM Employee
    WHERE manager_id = @ManagerID;
END;
GO


------------------------------------------------------
--8
CREATE PROCEDURE UpdateLeavePolicy
    @PolicyID INT,
    @EligibilityRules VARCHAR(500),
    @NoticePeriod INT
    AS
    BEGIN
    UPDATE LeavePolicy
    SET eligibility_rules = @EligibilityRules,
        notice_period = @NoticePeriod
    WHERE PolicyID = @PolicyID;
    SELECT 'Leave policy updated successfully' AS ConfirmationMessage;
    END;
    GO

-------------------------------------------------------
--9
CREATE PROCEDURE GetExpiringContracts
    @DaysBefore INT
AS
BEGIN
    SELECT contract_id, type, start_date, end_date, current_state
    FROM Contract
    WHERE DATEDIFF(DAY, GETDATE(), end_date) <= @DaysBefore
      AND current_state = 'ACTIVE';
END;
GO

-------------------------------------------------------
--10
CREATE PROCEDURE AssignDepartmentHead
    @DepartmentID INT,
    @ManagerID INT
AS
BEGIN
    UPDATE Department
    SET department_head_id = @ManagerID
    WHERE department_id = @DepartmentID;

    SELECT 'Department head assigned successfully' AS ConfirmationMessage;
END;
GO

---------------------------------------------------------
--11
CREATE PROCEDURE CreateEmployeeProfile
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

    PRINT 'Employee profile created successfully! ';
END;
GO


------------------------------------------------------------
--12 (Keep for now still)
CREATE PROCEDURE UpdateEmployeeProfile
    @EmployeeID INT,
    @FieldName VARCHAR(50),
    @NewValue VARCHAR(255)
AS
BEGIN
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
    SELECT 'Employee profile updated successfully! ' AS ConfirmationMessage;
    END;
    GO


--------------------------------------------------------
--13 
CREATE PROCEDURE dbo.SetProfileCompleteness
    @EmployeeID INT, 
    @CompletenessPercentage INT
AS
BEGIN
    -- Check if the completeness percentage is valid (between 0 and 100)
    IF @CompletenessPercentage < 0 OR @CompletenessPercentage > 100
    BEGIN
        RAISERROR('Invalid percentage. It must be between 0 and 100.', 16, 1);
        RETURN;
    END

    -- Update the employee profile completion in the Employee table
    UPDATE Employee
    SET profile_completion = @CompletenessPercentage
    WHERE employee_id = @EmployeeID;

    -- Check if any rows were affected
    IF @@ROWCOUNT = 0
    BEGIN
        RAISERROR('Employee ID not found or invalid.', 16, 1);
        RETURN;
    END

    -- Return a confirmation message
    SELECT 'Profile completeness updated successfully.' AS ConfirmationMessage;
END;
GO

---------------------------------------------------------
--14
CREATE PROCEDURE GenerateProfileReport
    @FilterField VARCHAR(50), 
    @FilterValue VARCHAR(100)
AS
BEGIN
    IF @FilterField = 'department'
    BEGIN
        SELECT employee_id, full_name, national_id, email, department_id, position_id, employment_status, hire_date
        FROM Employee
        WHERE department_id = @FilterValue;
    END
    ELSE IF @FilterField = 'position_id'
    BEGIN
        SELECT employee_id, full_name, national_id, email, department_id, position_id, employment_status, hire_date
        FROM Employee
        WHERE position_id = @FilterValue;
    END
    ELSE IF @FilterField = 'employment_status'
    BEGIN
        SELECT employee_id, full_name, national_id, email, department_id, position_id, employment_status, hire_date
        FROM Employee
        WHERE employment_status = @FilterValue;
    END
    ELSE IF @FilterField = 'hire_date'
    BEGIN
        SELECT employee_id, full_name, national_id, email, department_id, position_id, employment_status, hire_date
        FROM Employee
        WHERE hire_date = @FilterValue;
    END

    ELSE
    BEGIN
        RAISERROR('Invalid filter field. Please use: department, position, employment_status, hire_date.', 16, 1);
    END

    IF @@ROWCOUNT = 0
    BEGIN
        RAISERROR('No records found for the given filter.', 16, 1);
    END
END;
GO
    
--------------------------------------------------------------
--15
CREATE PROCEDURE CreateShiftType
    @ShiftID int, 
    @Name varchar(100),
    @Type varchar(50), 
    @Start_Time time, 
    @End_Time time, 
    @Break_Duration int, 
    @Shift_Date date, 
    @Status varchar(50)

AS
BEGIN
    INSERT INTO ShiftType (ShiftID, Name, Type, Start_Time, End_Time, Break_Duration, Shift_Date, Status)
    VALUES (@ShiftID, @Name, @Type, @Start_Time, @End_Time, @Break_Duration, @Shift_Date, @Status);
    SELECT 'Shift type created successfully' AS ConfirmationMessage;
END;
GO

--------------------------------------------------------------
--16 (Cancelled)



--------------------------------------------------------------
--17
CREATE PROCEDURE dbo.AssignRotationalShift
    @EmployeeID INT, 
    @ShiftCycle INT,  
    @StartDate DATE, 
    @EndDate DATE, 
    @Status VARCHAR(20)
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Employee WHERE EmployeeID = @EmployeeID)
    BEGIN
        RAISERROR('No employee', 16, 1);
        RETURN;
    END
    DECLARE @RequieedShiftID INT;
    SELECT @RequieedShiftID = ShiftID FROM ShiftCycle WHERE ShiftCycleID = @ShiftCycle;
    IF @RequieedShiftID IS NULL
    BEGIN
        RAISERROR('Invalid ShiftCycleID provided.', 16, 1);
        RETURN;
    END
    INSERT INTO ShiftAssignment (EmployeeID, ShiftID, StartDate, EndDate, Status)
    VALUES (@EmployeeID, @RequieedShiftID, @StartDate, @EndDate, @Status);
    SELECT 'Employee shift assigned successfully.' AS ConfirmationMessage;

    IF @@ROWCOUNT = 0
    BEGIN
        RAISERROR('Failed to assign shift. Invalid EmployeeID or other issue.', 16, 1);
    END
END;
GO
--------------------------------------------------------------
--18
CREATE PROCEDURE dbo.NotifyShiftExpiry
    @EmployeeID INT, 
    @ShiftAssignmentID INT, 
    @ExpiryDate DATE
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM ShiftAssignment WHERE EmployeeID = @EmployeeID AND ShiftAssignmentID = @ShiftAssignmentID)
    BEGIN
        RAISERROR('No shift assignment found for the given EmployeeID and ShiftAssignmentID.', 16, 1);
        RETURN;
    END

    IF DATEDIFF(DAY, GETDATE(), @ExpiryDate) <= 7
    BEGIN
        SELECT 'Your shift assignment is nearing expiry. Please review your schedule.' AS NotificationMessage;
    END
    ELSE
    BEGIN
        SELECT 'The shift assignment is not nearing expiry.' AS NotificationMessage;
    END
END;
GO

--------------------------------------------------------------
--19 (revise later)
CREATE PROCEDURE DefineShortTimeRules
    @RuleName VARCHAR(50),
    @LateMinutes INT,
    @EarlyLeaveMinutes INT,
    @PenaltyType VARCHAR(50)

    AS
    BEGIN
        -- Insert the rule into the PayrollPolicy table first
    INSERT INTO PayrollPolicy (RuleName, PenaltyType)
    VALUES (@RuleName, @PenaltyType);

    -- Get the PayrollPolicyID of the newly inserted rule
    DECLARE @PayrollPolicyID INT = SCOPE_IDENTITY();  -- Get the last inserted PayrollPolicyID

    -- Insert the lateness details into the LatenessPolicy table
    INSERT INTO LatenessPolicy (PayrollPolicyID, LateMinutes, EarlyLeaveMinutes)
    VALUES (@PayrollPolicyID, @LateMinutes, @EarlyLeaveMinutes);

    -- Confirmation message
    SELECT 'Short time rules defined successfully.' AS ConfirmationMessage;
END;
GO
--------------------------------------------------------------
--20
CREATE PROCEDURE SetGracePeriod
    @Minutes INT
AS
BEGIN
    IF @Minutes < 0
    BEGIN
        RAISERROR('Grace period cannot be negative.', 16, 1);
        RETURN;

    END
    IF NOT EXISTS (SELECT 1 FROM LatenessPolicy)
    BEGIN
        RAISERROR('No lateness policy found to update.', 16, 1);
        RETURN;
    END

    UPDATE LatenessPolicy
    SET grace_period_mins = @Minutes;

    SELECT 'Grace period set successfully.' AS ConfirmationMessage;
END;
GO
--------------------------------------------------------------
--21
CREATE PROCEDURE DefinePenaltyThreshold
    @LateMinutes INT,
    @DeductionType VARCHAR(50)
AS
BEGIN
    IF @LateMinutes < 0
    BEGIN
        RAISERROR('Late minutes cannot be negative.', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM LatenessPolicy)
    BEGIN
        RAISERROR('No lateness policy found to update.', 16, 1);
        RETURN;
    END

    INSERT INTO PayrollPolicy (type, description)
    VALUES ('Penalty Threshold', @DeductionType);

    DECLARE @PolicyID INT = SCOPE_IDENTITY();

    INSERT INTO LatenessPolicy (policy_id, grace_period_mins, deduction_rate)
    VALUES (@PolicyID, NULL, @LateMinutes);

    SELECT 'Penalty threshold defined successfully.' AS ConfirmationMessage;
END;
GO
--------------------------------------------------------------
--22




--------------------------------------------------------------
--23



--------------------------------------------------------------
--24



--------------------------------------------------------------
--25


--------------------------------------------------------------
--26



--------------------------------------------------------------
--27



--------------------------------------------------------------
--28



--------------------------------------------------------------
--29



--------------------------------------------------------------
--30



--------------------------------------------------------------
--31



--------------------------------------------------------------
--32



--------------------------------------------------------------
--33



--------------------------------------------------------------
--34



--------------------------------------------------------------
--35

--------------------------------------------------------------
--36


--------------------------------------------------------------
--37


--------------------------------------------------------------
--38


--------------------------------------------------------------
--39



--------------------------------------------------------------
--40



--------------------------------------------------------------
--41


--------------------------------------------------------------
--42


--------------------------------------------------------------
--43


--------------------------------------------------------------
--44


--------------------------------------------------------------
--45

    IF @Reason IS NULL OR LTRIM(RTRIM(@Reason)) = ''
    BEGIN
        SET @Reason = NULL; -- allow NULL justification, but normalize empty -> NULL
    END

    -- ensure referenced records exist
    IF NOT EXISTS (SELECT 1 FROM dbo.Employee WHERE EmployeeID = @EmployeeID)
    BEGIN
        RAISERROR('Specified employee does not exist.', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM dbo.Leave WHERE LeaveID = @LeaveTypeID)
    BEGIN
        RAISERROR('Specified leave type does not exist.', 16, 1);
        RETURN;
    END

    DECLARE @RequestID INT;
    DECLARE @Duration INT = DATEDIFF(DAY, @StartDate, @EndDate) + 1;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- generate a new RequestID safely to avoid race conditions
        SELECT @RequestID = ISNULL(MAX(RequestID), 0) + 1
        FROM dbo.LeaveRequest WITH (TABLOCKX, HOLDLOCK);

        INSERT INTO dbo.LeaveRequest
        (
            RequestID,
            employee_id,
            leave_id,
            justification,
            duration,
            approval_timing,
            status
        )
        VALUES
        (
            @RequestID,
            @EmployeeID,
            @LeaveTypeID,
            @Reason,
            @Duration,
            NULL,
            'PENDING'
        );

        COMMIT TRANSACTION;

        SELECT 'Leave request submitted' AS Message, @RequestID AS RequestID, 'PENDING' AS Status, @Duration AS Duration;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('SubmitLeaveRequest failed: %s', 16, 1, @ErrMsg);
        RETURN;
    END CATCH
END
GO




