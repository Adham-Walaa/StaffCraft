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
-- New signature: accepts expanded employee details and returns new EmployeeID (OUTPUT) and confirmation row

CREATE OR ALTER PROCEDURE dbo.AddEmployee
(
    @FullName               VARCHAR(200),
    @NationalID             VARCHAR(50)       = NULL,
    @DateOfBirth            DATE              = NULL,
    @CountryOfBirth         VARCHAR(100)      = NULL,
    @Phone                  VARCHAR(50)       = NULL,
    @Email                  VARCHAR(100),
    @Address                VARCHAR(255)      = NULL,
    @EmergencyContactName   VARCHAR(100)      = NULL,
    @EmergencyContactPhone  VARCHAR(50)       = NULL,
    @Relationship           VARCHAR(50)       = NULL,
    @Biography              VARCHAR(MAX)      = NULL,
    @EmploymentProgress     VARCHAR(100)      = NULL,
    @AccountStatus          VARCHAR(50)       = NULL,
    @EmploymentStatus       VARCHAR(50)       = NULL,
    @HireDate               DATE              = NULL,
    @IsActive               BIT               = 1,
    @ProfileCompletion      INT               = NULL,
    @DepartmentID           INT               = NULL,
    @PositionID             INT               = NULL,
    @ManagerID              INT               = NULL,
    @ContractID             INT               = NULL,
    @TaxFormID              INT               = NULL,
    @SalaryTypeID           INT               = NULL,
    @PayGrade               VARCHAR(50)       = NULL,
    @NewEmployeeID          INT               OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;

    -- Basic required fields
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

    -- Validate profile completion if provided
    IF @ProfileCompletion IS NOT NULL AND (@ProfileCompletion < 0 OR @ProfileCompletion > 100)
    BEGIN
        RAISERROR('ProfileCompletion must be between 0 and 100.', 16, 1);
        RETURN;
    END

    -- Validate referenced foreign keys if provided
    IF @DepartmentID IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.Department WHERE DepartmentID = @DepartmentID)
    BEGIN
        RAISERROR('Specified DepartmentID does not exist.', 16, 1);
        RETURN;
    END

    IF @PositionID IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.Position WHERE PositionID = @PositionID)
    BEGIN
        RAISERROR('Specified PositionID does not exist.', 16, 1);
        RETURN;
    END

    IF @ManagerID IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.Employee WHERE EmployeeID = @ManagerID)
    BEGIN
        RAISERROR('Specified ManagerID does not exist.', 16, 1);
        RETURN;
    END

    IF @ContractID IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.Contract WHERE ContractID = @ContractID)
    BEGIN
        RAISERROR('Specified ContractID does not exist.', 16, 1);
        RETURN;
    END

    IF @TaxFormID IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.TaxForm WHERE TaxFormID = @TaxFormID)
    BEGIN
        RAISERROR('Specified TaxFormID does not exist.', 16, 1);
        RETURN;
    END

    IF @SalaryTypeID IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.SalaryType WHERE SalaryTypeID = @SalaryTypeID)
    BEGIN
        RAISERROR('Specified SalaryTypeID does not exist.', 16, 1);
        RETURN;
    END

    -- Resolve PayGrade name to ID if provided
    DECLARE @PayGradeID INT = NULL;
    IF @PayGrade IS NOT NULL
    BEGIN
        SELECT @PayGradeID = PayGradeID FROM dbo.PayGrade WHERE grade_name = @PayGrade;
        IF @PayGradeID IS NULL
        BEGIN
            RAISERROR('Specified PayGrade does not exist.', 16, 1);
            RETURN;
        END
    END

    -- Ensure email uniqueness
    IF EXISTS (SELECT 1 FROM dbo.Employee WHERE email = @Email)
    BEGIN
        RAISERROR('Email already exists.', 16, 1);
        RETURN;
    END

    -- Split FullName into first and last name (simple heuristic)
    DECLARE @FirstName VARCHAR(50);
    DECLARE @LastName  VARCHAR(50);
    DECLARE @SpacePos  INT;

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

    BEGIN TRY
        BEGIN TRANSACTION;

        -- generate a new EmployeeID safely (table lock to avoid race conditions)
        SELECT @NewEmployeeID = ISNULL(MAX(EmployeeID), 0) + 1
        FROM dbo.Employee WITH (TABLOCKX, HOLDLOCK);

        INSERT INTO dbo.Employee
        (
            EmployeeID,
            first_name,
            last_name,
            national_id,
            date_of_birth,
            country_of_birth,
            phone,
            email,
            address,
            emergency_contact_name,
            emergency_contact_phone,
            relationship,
            biography,
            employment_progress,
            account_status,
            employment_status,
            hire_date,
            is_active,
            profile_completion_percentage,
            department_id,
            position_id,
            manager_id,
            contract_id,
            taxform_id,
            salary_type_id,
            paygrade_id
        )
        VALUES
        (
            @NewEmployeeID,
            @FirstName,
            @LastName,
            @NationalID,
            CASE WHEN @DateOfBirth IS NULL THEN NULL ELSE CONVERT(DATETIME, @DateOfBirth) END,
            @CountryOfBirth,
            @Phone,
            @Email,
            @Address,
            @EmergencyContactName,
            @EmergencyContactPhone,
            @Relationship,
            @Biography,
            @EmploymentProgress,
            @AccountStatus,
            @EmploymentStatus,
            CASE WHEN @HireDate IS NULL THEN NULL ELSE CONVERT(DATETIME, @HireDate) END,
            ISNULL(@IsActive, 1),
            @ProfileCompletion,
            @DepartmentID,
            @PositionID,
            @ManagerID,
            @ContractID,
            @TaxFormID,
            @SalaryTypeID,
            @PayGradeID
        );

        COMMIT TRANSACTION;

        SELECT 'Employee created' AS Message, @NewEmployeeID AS EmployeeID;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
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

--6
-- Procedure: ReassignManager
-- Input: @EmployeeID int, @NewManagerID int
-- Output: Confirmation message

CREATE OR ALTER PROCEDURE dbo.ReassignManager
(
    @EmployeeID   INT,
    @NewManagerID INT
)
AS
BEGIN
    SET NOCOUNT ON;

    -- Validate inputs exist
    IF NOT EXISTS (SELECT 1 FROM dbo.Employee WHERE EmployeeID = @EmployeeID)
    BEGIN
        RAISERROR('Employee with the specified ID does not exist.', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM dbo.Employee WHERE EmployeeID = @NewManagerID)
    BEGIN
        RAISERROR('New manager with the specified ID does not exist.', 16, 1);
        RETURN;
    END

    -- Prevent assigning an employee as their own manager
    IF @EmployeeID = @NewManagerID
    BEGIN
        RAISERROR('An employee cannot be their own manager.', 16, 1);
        RETURN;
    END

    -- Iteratively walk the manager chain upward from @NewManagerID to detect cycles
    DECLARE @current INT = @NewManagerID;
    WHILE @current IS NOT NULL
    BEGIN
        IF @current = @EmployeeID
        BEGIN
            RAISERROR('Reassign would create a circular manager relationship. Operation aborted.', 16, 1);
            RETURN;
        END

        SELECT @current = manager_id
        FROM dbo.Employee
        WHERE EmployeeID = @current;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE dbo.Employee
        SET manager_id = @NewManagerID
        WHERE EmployeeID = @EmployeeID;

        COMMIT TRANSACTION;

        SELECT 'Manager reassigned' AS Message, @EmployeeID AS EmployeeID, @NewManagerID AS NewManagerID;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('ReassignManager failed: %s', 16, 1, @ErrMsg);
        RETURN;
    END CATCH
END
GO

--7
-- Procedure: ReassignHierarchy
-- Input: @EmployeeID int, @NewDepartmentID int, @NewManagerID int
-- Output: Confirmation message

CREATE OR ALTER PROCEDURE dbo.ReassignHierarchy
(
    @EmployeeID      INT,
    @NewDepartmentID INT = NULL,
    @NewManagerID    INT = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    -- basic validation
    IF NOT EXISTS (SELECT 1 FROM dbo.Employee WHERE EmployeeID = @EmployeeID)
    BEGIN
        RAISERROR('Employee with the specified ID does not exist.', 16, 1);
        RETURN;
    END

    IF @NewDepartmentID IS NULL AND @NewManagerID IS NULL
    BEGIN
        RAISERROR('Either @NewDepartmentID or @NewManagerID must be supplied.', 16, 1);
        RETURN;
    END

    IF @NewDepartmentID IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.Department WHERE DepartmentID = @NewDepartmentID)
    BEGIN
        RAISERROR('Target department does not exist.', 16, 1);
        RETURN;
    END

    IF @NewManagerID IS NOT NULL
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM dbo.Employee WHERE EmployeeID = @NewManagerID)
        BEGIN
            RAISERROR('New manager with the specified ID does not exist.', 16, 1);
            RETURN;
        END

        IF @NewManagerID = @EmployeeID
        BEGIN
            RAISERROR('An employee cannot be assigned as their own manager.', 16, 1);
            RETURN;
        END

        -- if both department and manager are supplied, ensure manager is in the new department
        IF @NewDepartmentID IS NOT NULL
        BEGIN
            IF EXISTS (
                SELECT 1
                FROM dbo.Employee m
                WHERE m.EmployeeID = @NewManagerID
                  AND ISNULL(m.department_id, -1) <> @NewDepartmentID
            )
            BEGIN
                RAISERROR('The specified manager is not in the target department.', 16, 1);
                RETURN;
            END
        END

        -- detect cycles by walking the manager chain upward from @NewManagerID
        DECLARE @current INT = @NewManagerID;
        WHILE @current IS NOT NULL
        BEGIN
            IF @current = @EmployeeID
            BEGIN
                RAISERROR('Reassign would create a circular manager relationship. Operation aborted.', 16, 1);
                RETURN;
            END

            SELECT @current = manager_id
            FROM dbo.Employee
            WHERE EmployeeID = @current;
        END
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE dbo.Employee
        SET
            department_id = CASE WHEN @NewDepartmentID IS NOT NULL THEN @NewDepartmentID ELSE department_id END,
            manager_id    = CASE WHEN @NewManagerID    IS NOT NULL THEN @NewManagerID    ELSE manager_id    END
        WHERE EmployeeID = @EmployeeID;

        COMMIT TRANSACTION;

        SELECT
            'Reassignment completed' AS Message,
            e.EmployeeID,
            e.department_id AS NewDepartmentID,
            e.manager_id    AS NewManagerID
        FROM dbo.Employee e
        WHERE e.EmployeeID = @EmployeeID;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('ReassignHierarchy failed: %s', 16, 1, @ErrMsg);
        RETURN;
    END CATCH
END
GO

--8
-- Procedure: NotifyStructureChange
-- Input: @AffectedEmployees varchar(500), @Message varchar(200)
-- Output: new @NotificationID int (OUTPUT) and a confirmation row

CREATE OR ALTER PROCEDURE dbo.NotifyStructureChange
(
    @AffectedEmployees VARCHAR(500),
    @Message           VARCHAR(200)
)
AS
BEGIN
    SET NOCOUNT ON;

    -- Validate
    IF @Message IS NULL OR LTRIM(RTRIM(@Message)) = ''
    BEGIN
        RAISERROR('Message is required.', 16, 1);
        RETURN;
    END

    DECLARE @NotificationID INT;
    DECLARE @ErrMsg NVARCHAR(4000);

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Generate NotificationID (table uses manual PK pattern)
        SELECT @NotificationID = ISNULL(MAX(NotificationID), 0) + 1 FROM dbo.Notification WITH (TABLOCKX, HOLDLOCK);

        INSERT INTO dbo.Notification
        (
            NotificationID,
            mesage_content,
            timestamp,
            urgency,
            read_status,
            notification_type
        )
        VALUES
        (
            @NotificationID,
            @Message,
            GETDATE(),
            'NORMAL',
            0,
            'STRUCTURE_CHANGE'
        );

        -- Parse comma-separated employee IDs and insert EmployeeNotification rows for existing employees
        DECLARE @pos INT = 1;
        DECLARE @len INT = LEN(ISNULL(@AffectedEmployees, ''));
        DECLARE @next INT;
        DECLARE @token VARCHAR(50);
        DECLARE @empid INT;

        WHILE @pos <= @len
        BEGIN
            SET @next = CHARINDEX(',', @AffectedEmployees, @pos);
            IF @next = 0 SET @next = @len + 1;

            SET @token = LTRIM(RTRIM(SUBSTRING(@AffectedEmployees, @pos, @next - @pos)));

            IF @token <> ''
            BEGIN
                SET @empid = TRY_CONVERT(INT, @token);

                IF @empid IS NOT NULL AND EXISTS (SELECT 1 FROM dbo.Employee WHERE EmployeeID = @empid)
                BEGIN
                    INSERT INTO dbo.EmployeeNotification (employee_id, notification_id, delivery_status, delivered_at)
                    VALUES (@empid, @NotificationID, 'PENDING', NULL);
                END
                -- non-numeric tokens or non-existing employees are ignored silently
            END

            SET @pos = @next + 1;
        END

        COMMIT TRANSACTION;

        SELECT 'Notification created' AS Message, @NotificationID AS NotificationID;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        SET @ErrMsg = ERROR_MESSAGE();
        RAISERROR('NotifyStructureChange failed: %s', 16, 1, @ErrMsg);
        RETURN;
    END CATCH
END
GO

--9
-- Procedure: ViewOrgHierarchy
-- Input: @AffectedEmployees varchar(500), @Message varchar(200)
-- Output: hierarchical view of the organization

CREATE OR ALTER PROCEDURE dbo.ViewOrgHierarchy

AS
BEGIN
    SET NOCOUNT ON;

    -- Build hierarchy using a recursive CTE. Limit removed so deep orgs are allowed.
    ;WITH OrgCTE AS
    (
        -- roots (top-level managers)
        SELECT
            e.EmployeeID,
            ISNULL(e.first_name,'')   AS first_name,
            ISNULL(e.last_name,'')    AS last_name,
            (ISNULL(e.first_name,'') + ' ' + ISNULL(e.last_name,'')) AS EmployeeName,
            e.manager_id,
            e.department_id,
            e.position_id,
            CAST(RIGHT('0000' + CAST(e.EmployeeID AS VARCHAR(10)), 4) + '/' AS VARCHAR(MAX)) AS HierarchyPath,
            0 AS HierarchyLevel
        FROM dbo.Employee e
        WHERE e.manager_id IS NULL

        UNION ALL

        -- children
        SELECT
            c.EmployeeID,
            ISNULL(c.first_name,''),
            ISNULL(c.last_name,''),
            (ISNULL(c.first_name,'') + ' ' + ISNULL(c.last_name,'')),
            c.manager_id,
            c.department_id,
            c.position_id,
            CAST(p.HierarchyPath + RIGHT('0000' + CAST(c.EmployeeID AS VARCHAR(10)), 4) + '/' AS VARCHAR(MAX)),
            p.HierarchyLevel + 1
        FROM dbo.Employee c
        INNER JOIN OrgCTE p ON c.manager_id = p.EmployeeID
    )
    SELECT
        o.EmployeeID,
        o.first_name,
        o.last_name,
        o.Manager_id AS ManagerID,
        (mgr.first_name + ' ' + mgr.last_name) AS ManagerName,
        o.department_id AS DepartmentID,
        dept.department_name AS DepartmentName,
        o.position_id AS PositionID,
        pos.position_title AS PositionTitle,
        o.HierarchyLevel,
        o.HierarchyPath
    FROM OrgCTE o
    LEFT JOIN dbo.Employee mgr ON mgr.EmployeeID = o.manager_id
    LEFT JOIN dbo.Department dept ON dept.DepartmentID = o.department_id
    LEFT JOIN dbo.Position pos ON pos.PositionID = o.position_id
    ORDER BY o.HierarchyPath, o.HierarchyLevel, o.EmployeeName
    OPTION (MAXRECURSION 0); -- allow deep hierarchies
END
GO

--10
-- Procedure: AssignShiftToEmployee
-- Input: @EmployeeID int, @ShiftID int, @StartDate date, @EndDate date
-- Output: confirmation row with ShiftID, EmployeeID, StartDate, EndDate

CREATE OR ALTER PROCEDURE dbo.AssignShiftToEmployee
(
    @EmployeeID INT,
    @ShiftID    INT,
    @StartDate  DATE,
    @EndDate    DATE
)
AS
BEGIN
    SET NOCOUNT ON;

    -- validations
    IF NOT EXISTS (SELECT 1 FROM dbo.Employee WHERE EmployeeID = @EmployeeID)
    BEGIN
        RAISERROR('Employee with the specified ID does not exist.', 16, 1);
        RETURN;
    END

    IF @StartDate IS NULL OR @EndDate IS NULL
    BEGIN
        RAISERROR('StartDate and EndDate are required.', 16, 1);
        RETURN;
    END

    IF @StartDate > @EndDate
    BEGIN
        RAISERROR('StartDate must be on or before EndDate.', 16, 1);
        RETURN;
    END

    -- ensure provided ShiftID is not already used (ShiftID is primary key in ShiftSchedule)
    IF EXISTS (SELECT 1 FROM dbo.ShiftSchedule WHERE ShiftID = @ShiftID)
    BEGIN
        RAISERROR('ShiftID already exists. Provide a unique ShiftID or update existing schedule.', 16, 1);
        RETURN;
    END

    -- prevent overlapping shifts for the same employee
    IF EXISTS (
        SELECT 1
        FROM dbo.ShiftSchedule ss
        WHERE ss.employee_id = @EmployeeID
          AND NOT (ss.end_date < @StartDate OR ss.start_date > @EndDate)  -- overlap condition
    )
    BEGIN
        RAISERROR('Employee already has a shift that overlaps the specified term.', 16, 1);
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO dbo.ShiftSchedule
        (
            ShiftID,
            employee_id,
            start_date,
            end_date,
            status
        )
        VALUES
        (
            @ShiftID,
            @EmployeeID,
            @StartDate,
            @EndDate,
            'ASSIGNED'
        );

        COMMIT TRANSACTION;

        SELECT 'Shift assigned' AS Message, @ShiftID AS ShiftID, @EmployeeID AS EmployeeID, @StartDate AS StartDate, @EndDate AS EndDate;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('AssignShiftToEmployee failed: %s', 16, 1, @ErrMsg);
        RETURN;
    END CATCH
END
GO

--11
-- Procedure: UpdateShiftStatus
-- Input: @ShiftAssignmentID int, @Status varchar(20)
-- Output: Confirmation message

CREATE OR ALTER PROCEDURE dbo.UpdateShiftStatus
(
    @ShiftAssignmentID INT,
    @Status VARCHAR(20)
)
AS
BEGIN
    SET NOCOUNT ON;

    -- Validate ShiftAssignmentID exists
    IF NOT EXISTS (SELECT 1 FROM dbo.ShiftSchedule WHERE ShiftID = @ShiftAssignmentID)
    BEGIN
        RAISERROR('Shift assignment with the specified ID does not exist.', 16, 1);
        RETURN;
    END

    -- Validate Status value
    IF @Status NOT IN ('Approved', 'Cancelled', 'Entered', 'Expired', 'Postponed', 'Rejected', 'Submitted', 'ASSIGNED')
    BEGIN
        RAISERROR('Invalid status. Valid statuses are: Approved, Cancelled, Entered, Expired, Postponed, Rejected, Submitted, ASSIGNED.', 16, 1);
        RETURN;
    END

    -- Additional business rule: prevent changing from Approved to Rejected or vice versa without going through Submitted
    DECLARE @CurrentStatus VARCHAR(50);
    SELECT @CurrentStatus = status FROM dbo.ShiftSchedule WHERE ShiftID = @ShiftAssignmentID;

    IF (@CurrentStatus = 'Approved' AND @Status = 'Rejected')
    BEGIN
        RAISERROR('Cannot change status from Approved to Rejected directly. Submit for review first.', 16, 1);
        RETURN;
    END

    IF (@CurrentStatus = 'Rejected' AND @Status = 'Approved')
    BEGIN
        RAISERROR('Cannot change status from Rejected to Approved directly. Resubmit for review first.', 16, 1);
        RETURN;
    END

    -- Prevent changes to Expired shifts
    IF @CurrentStatus = 'Expired'
    BEGIN
        RAISERROR('Cannot modify an expired shift assignment.', 16, 1);
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE dbo.ShiftSchedule
        SET status = @Status
        WHERE ShiftID = @ShiftAssignmentID;

        COMMIT TRANSACTION;

        SELECT 'Shift status updated' AS Message, 
               @ShiftAssignmentID AS ShiftID, 
               @Status AS NewStatus;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('UpdateShiftStatus failed: %s', 16, 1, @ErrMsg);
        RETURN;
    END CATCH
END
GO

--12
-- Procedure: AssignShiftToDepartment
-- Input: @DepartmentID int, @ShiftID int, @StartDate date, @EndDate date
-- Output: Confirmation message

CREATE OR ALTER PROCEDURE dbo.AssignShiftToDepartment
(
    @DepartmentID INT,
    @ShiftID      INT,
    @StartDate    DATE,
    @EndDate      DATE
)
AS
BEGIN
    SET NOCOUNT ON;

    -- Validate department exists
    IF NOT EXISTS (SELECT 1 FROM dbo.Department WHERE DepartmentID = @DepartmentID)
    BEGIN
        RAISERROR('Department with the specified ID does not exist.', 16, 1);
        RETURN;
    END

    -- Validate dates
    IF @StartDate IS NULL OR @EndDate IS NULL
    BEGIN
        RAISERROR('StartDate and EndDate are required.', 16, 1);
        RETURN;
    END

    IF @StartDate > @EndDate
    BEGIN
        RAISERROR('StartDate must be on or before EndDate.', 16, 1);
        RETURN;
    END

    -- Ensure ShiftID is unique
    IF EXISTS (SELECT 1 FROM dbo.ShiftSchedule WHERE ShiftID = @ShiftID)
    BEGIN
        RAISERROR('ShiftID already exists. Provide a unique ShiftID.', 16, 1);
        RETURN;
    END

    -- Get all active employees in the department
    DECLARE @EmployeeCount INT;
    SELECT @EmployeeCount = COUNT(*)
    FROM dbo.Employee
    WHERE department_id = @DepartmentID
      AND is_active = 1;

    IF @EmployeeCount = 0
    BEGIN
        RAISERROR('No active employees found in the specified department.', 16, 1);
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        -- For department-wide assignment, we'll create individual shift records for each employee
        -- However, since ShiftID must be unique, we'll use a base ShiftID and increment
        DECLARE @BaseShiftID INT = @ShiftID;
        DECLARE @CurrentShiftID INT = @BaseShiftID;
        DECLARE @AssignedCount INT = 0;

        -- Create a temp table to hold employee IDs
        DECLARE @EmployeeList TABLE (EmployeeID INT);
        
        INSERT INTO @EmployeeList
        SELECT EmployeeID
        FROM dbo.Employee
        WHERE department_id = @DepartmentID
          AND is_active = 1;

        -- Assign shift to each employee
        DECLARE @EmpID INT;
        DECLARE emp_cursor CURSOR FOR
            SELECT EmployeeID FROM @EmployeeList;

        OPEN emp_cursor;
        FETCH NEXT FROM emp_cursor INTO @EmpID;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            -- Check for overlapping shifts for this employee
            IF NOT EXISTS (
                SELECT 1
                FROM dbo.ShiftSchedule ss
                WHERE ss.employee_id = @EmpID
                  AND NOT (ss.end_date < @StartDate OR ss.start_date > @EndDate)
            )
            BEGIN
                -- No overlap, insert the shift
                INSERT INTO dbo.ShiftSchedule
                (ShiftID, employee_id, start_date, end_date, status)
                VALUES
                (@CurrentShiftID, @EmpID, @StartDate, @EndDate, 'ASSIGNED');

                SET @AssignedCount = @AssignedCount + 1;
                SET @CurrentShiftID = @CurrentShiftID + 1;
            END

            FETCH NEXT FROM emp_cursor INTO @EmpID;
        END

        CLOSE emp_cursor;
        DEALLOCATE emp_cursor;

        COMMIT TRANSACTION;

        SELECT 'Department shift assignment completed' AS Message,
               @DepartmentID AS DepartmentID,
               @BaseShiftID AS BaseShiftID,
               @AssignedCount AS EmployeesAssigned,
               @EmployeeCount - @AssignedCount AS SkippedDueToOverlap;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        IF CURSOR_STATUS('local', 'emp_cursor') >= 0
        BEGIN
            CLOSE emp_cursor;
            DEALLOCATE emp_cursor;
        END

        DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('AssignShiftToDepartment failed: %s', 16, 1, @ErrMsg);
        RETURN;
    END CATCH
END
GO

--13
-- Procedure: AssignCustomShift
-- Input: @EmployeeID int, @ShiftName varchar(50), @ShiftType varchar(50), @StartTime time, @EndTime time, @StartDate date, @EndDate date
-- Output: Confirmation message
-- Note: This procedure requires additional columns in ShiftSchedule table

-- First, let's add required columns to ShiftSchedule if they don't exist
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.ShiftSchedule') AND name = 'shift_name')
BEGIN
    ALTER TABLE dbo.ShiftSchedule ADD shift_name VARCHAR(50) NULL;
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.ShiftSchedule') AND name = 'shift_type')
BEGIN
    ALTER TABLE dbo.ShiftSchedule ADD shift_type VARCHAR(50) NULL;
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.ShiftSchedule') AND name = 'start_time')
BEGIN
    ALTER TABLE dbo.ShiftSchedule ADD start_time TIME NULL;
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.ShiftSchedule') AND name = 'end_time')
BEGIN
    ALTER TABLE dbo.ShiftSchedule ADD end_time TIME NULL;
END
GO

CREATE OR ALTER PROCEDURE dbo.AssignCustomShift
(
    @EmployeeID INT,
    @ShiftName  VARCHAR(50),
    @ShiftType  VARCHAR(50),
    @StartTime  TIME,
    @EndTime    TIME,
    @StartDate  DATE,
    @EndDate    DATE
)
AS
BEGIN
    SET NOCOUNT ON;

    -- Validate employee exists
    IF NOT EXISTS (SELECT 1 FROM dbo.Employee WHERE EmployeeID = @EmployeeID)
    BEGIN
        RAISERROR('Employee with the specified ID does not exist.', 16, 1);
        RETURN;
    END

    -- Validate required fields
    IF @ShiftName IS NULL OR LTRIM(RTRIM(@ShiftName)) = ''
    BEGIN
        RAISERROR('Shift name is required.', 16, 1);
        RETURN;
    END

    IF @ShiftType IS NULL OR LTRIM(RTRIM(@ShiftType)) = ''
    BEGIN
        RAISERROR('Shift type is required.', 16, 1);
        RETURN;
    END

    IF @StartTime IS NULL OR @EndTime IS NULL
    BEGIN
        RAISERROR('Start time and end time are required.', 16, 1);
        RETURN;
    END

    IF @StartDate IS NULL OR @EndDate IS NULL
    BEGIN
        RAISERROR('Start date and end date are required.', 16, 1);
        RETURN;
    END

    IF @StartDate > @EndDate
    BEGIN
        RAISERROR('Start date must be on or before end date.', 16, 1);
        RETURN;
    END

    -- Validate shift times (basic validation - end time should typically be after start time)
    -- Note: this doesn't account for overnight shifts spanning midnight
    IF @StartTime >= @EndTime
    BEGIN
        -- Allow overnight shifts but warn via message
        PRINT 'Warning: Start time is after or equal to end time. Assuming overnight shift.';
    END

    -- Check for overlapping custom shifts for the same employee
    IF EXISTS (
        SELECT 1
        FROM dbo.ShiftSchedule ss
        WHERE ss.employee_id = @EmployeeID
          AND NOT (ss.end_date < @StartDate OR ss.start_date > @EndDate)
          AND ss.shift_name IS NOT NULL  -- only check custom shifts
    )
    BEGIN
        RAISERROR('Employee already has a custom shift that overlaps the specified period.', 16, 1);
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Generate new ShiftID
        DECLARE @NewShiftID INT;
        SELECT @NewShiftID = ISNULL(MAX(ShiftID), 0) + 1
        FROM dbo.ShiftSchedule WITH (TABLOCKX, HOLDLOCK);

        INSERT INTO dbo.ShiftSchedule
        (
            ShiftID,
            employee_id,
            start_date,
            end_date,
            status,
            shift_name,
            shift_type,
            start_time,
            end_time
        )
        VALUES
        (
            @NewShiftID,
            @EmployeeID,
            @StartDate,
            @EndDate,
            'ASSIGNED',
            @ShiftName,
            @ShiftType,
            @StartTime,
            @EndTime
        );

        COMMIT TRANSACTION;

        SELECT 'Custom shift assigned' AS Message,
               @NewShiftID AS ShiftID,
               @EmployeeID AS EmployeeID,
               @ShiftName AS ShiftName,
               @ShiftType AS ShiftType,
               @StartTime AS StartTime,
               @EndTime AS EndTime,
               @StartDate AS StartDate,
               @EndDate AS EndDate;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('AssignCustomShift failed: %s', 16, 1, @ErrMsg);
        RETURN;
    END CATCH
END
GO

--14
-- Procedure: ConfigureSplitShift
-- Input: @ShiftName varchar(50), @FirstSlotStart time, @FirstSlotEnd time, @SecondSlotStart time, @SecondSlotEnd time
-- Output: Confirmation message
-- Note: This requires a new table to store split shift configurations

-- Create SplitShiftConfiguration table if it doesn't exist
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SplitShiftConfiguration') AND type = 'U')
BEGIN
    CREATE TABLE dbo.SplitShiftConfiguration
    (
        ConfigID INT PRIMARY KEY,
        shift_name VARCHAR(50) NOT NULL,
        first_slot_start TIME NOT NULL,
        first_slot_end TIME NOT NULL,
        second_slot_start TIME NOT NULL,
        second_slot_end TIME NOT NULL,
        total_hours DECIMAL(5,2),
        break_duration_minutes INT,
        created_date DATETIME DEFAULT GETDATE(),
        is_active BIT DEFAULT 1
    );
END
GO

CREATE OR ALTER PROCEDURE dbo.ConfigureSplitShift
(
    @ShiftName VARCHAR(50),
    @FirstSlotStart TIME,
    @FirstSlotEnd TIME,
    @SecondSlotStart TIME,
    @SecondSlotEnd TIME
)
AS
BEGIN
    SET NOCOUNT ON;

    -- Validate required fields
    IF @ShiftName IS NULL OR LTRIM(RTRIM(@ShiftName)) = ''
    BEGIN
        RAISERROR('Shift name is required.', 16, 1);
        RETURN;
    END

    IF @FirstSlotStart IS NULL OR @FirstSlotEnd IS NULL OR @SecondSlotStart IS NULL OR @SecondSlotEnd IS NULL
    BEGIN
        RAISERROR('All time slots are required.', 16, 1);
        RETURN;
    END

    -- Validate first slot times
    IF @FirstSlotStart >= @FirstSlotEnd
    BEGIN
        RAISERROR('First slot start time must be before end time.', 16, 1);
        RETURN;
    END

    -- Validate second slot times
    IF @SecondSlotStart >= @SecondSlotEnd
    BEGIN
        RAISERROR('Second slot start time must be before end time.', 16, 1);
        RETURN;
    END

    -- Validate that second slot starts after first slot ends
    IF @SecondSlotStart <= @FirstSlotEnd
    BEGIN
        RAISERROR('Second slot must start after the first slot ends.', 16, 1);
        RETURN;
    END

    -- Calculate total hours and break duration
    DECLARE @FirstSlotHours DECIMAL(5,2);
    DECLARE @SecondSlotHours DECIMAL(5,2);
    DECLARE @TotalHours DECIMAL(5,2);
    DECLARE @BreakMinutes INT;

    SET @FirstSlotHours = DATEDIFF(MINUTE, @FirstSlotStart, @FirstSlotEnd) / 60.0;
    SET @SecondSlotHours = DATEDIFF(MINUTE, @SecondSlotStart, @SecondSlotEnd) / 60.0;
    SET @TotalHours = @FirstSlotHours + @SecondSlotHours;
    SET @BreakMinutes = DATEDIFF(MINUTE, @FirstSlotEnd, @SecondSlotStart);

    -- Check if shift name already exists
    IF EXISTS (SELECT 1 FROM dbo.SplitShiftConfiguration WHERE shift_name = @ShiftName AND is_active = 1)
    BEGIN
        RAISERROR('A split shift configuration with this name already exists. Please use a different name or deactivate the existing one.', 16, 1);
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Generate new ConfigID
        DECLARE @NewConfigID INT;
        SELECT @NewConfigID = ISNULL(MAX(ConfigID), 0) + 1
        FROM dbo.SplitShiftConfiguration WITH (TABLOCKX, HOLDLOCK);

        INSERT INTO dbo.SplitShiftConfiguration
        (
            ConfigID,
            shift_name,
            first_slot_start,
            first_slot_end,
            second_slot_start,
            second_slot_end,
            total_hours,
            break_duration_minutes,
            created_date,
            is_active
        )
        VALUES
        (
            @NewConfigID,
            @ShiftName,
            @FirstSlotStart,
            @FirstSlotEnd,
            @SecondSlotStart,
            @SecondSlotEnd,
            @TotalHours,
            @BreakMinutes,
            GETDATE(),
            1
        );

        COMMIT TRANSACTION;

        SELECT 'Split shift configured' AS Message,
               @NewConfigID AS ConfigID,
               @ShiftName AS ShiftName,
               @FirstSlotStart AS FirstSlotStart,
               @FirstSlotEnd AS FirstSlotEnd,
               @SecondSlotStart AS SecondSlotStart,
               @SecondSlotEnd AS SecondSlotEnd,
               @TotalHours AS TotalHours,
               @BreakMinutes AS BreakDurationMinutes;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('ConfigureSplitShift failed: %s', 16, 1, @ErrMsg);
        RETURN;
    END CATCH
END
GO

--15
-- Procedure: EnableFirstInLastOut
-- Input: @Enable bit
-- Output: Confirmation message
-- Note: This requires a configuration table to store system settings

-- Create SystemConfiguration table if it doesn't exist
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SystemConfiguration') AND type = 'U')
BEGIN
    CREATE TABLE dbo.SystemConfiguration
    (
        ConfigKey VARCHAR(100) PRIMARY KEY,
        ConfigValue VARCHAR(500),
        Description TEXT,
        LastModified DATETIME DEFAULT GETDATE(),
        ModifiedBy VARCHAR(100)
    );
END
GO

CREATE OR ALTER PROCEDURE dbo.EnableFirstInLastOut
(
    @Enable BIT
)
AS
BEGIN
    SET NOCOUNT ON;

    -- Validate input
    IF @Enable IS NULL
    BEGIN
        RAISERROR('@Enable parameter is required (0 = disable, 1 = enable).', 16, 1);
        RETURN;
    END

    DECLARE @ConfigKey VARCHAR(100) = 'ATTENDANCE_FIRST_IN_LAST_OUT';
    DECLARE @ConfigValue VARCHAR(10) = CASE WHEN @Enable = 1 THEN 'ENABLED' ELSE 'DISABLED' END;
    DECLARE @Description VARCHAR = 'When enabled, attendance processing uses first clock-in and last clock-out times for daily calculations. When disabled, all clock entries are considered individually.';

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Check if configuration exists
        IF EXISTS (SELECT 1 FROM dbo.SystemConfiguration WHERE ConfigKey = @ConfigKey)
        BEGIN
            -- Update existing configuration
            UPDATE dbo.SystemConfiguration
            SET ConfigValue = @ConfigValue,
                LastModified = GETDATE(),
                ModifiedBy = SYSTEM_USER
            WHERE ConfigKey = @ConfigKey;
        END
        ELSE
        BEGIN
            -- Insert new configuration
            INSERT INTO dbo.SystemConfiguration
            (ConfigKey, ConfigValue, Description, LastModified, ModifiedBy)
            VALUES
            (@ConfigKey, @ConfigValue, @Description, GETDATE(), SYSTEM_USER);
        END

        COMMIT TRANSACTION;

        SELECT 'First In/Last Out attendance processing ' + 
               CASE WHEN @Enable = 1 THEN 'enabled' ELSE 'disabled' END AS Message,
               @ConfigKey AS ConfigurationKey,
               @ConfigValue AS Status,
               GETDATE() AS Timestamp;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('EnableFirstInLastOut failed: %s', 16, 1, @ErrMsg);
        RETURN;
    END CATCH
END
GO