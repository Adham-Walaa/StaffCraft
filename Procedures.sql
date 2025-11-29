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

--16
-- Procedure: TagAttendanceSource
-- Input: @AttendanceID int, @SourceType varchar(20), @DeviceID int, @Latitude decimal(10,7), @Longitude decimal(10,7)
-- Output: Confirmation message

CREATE OR ALTER PROCEDURE dbo.TagAttendanceSource
(
    @AttendanceID INT,
    @SourceType   VARCHAR(20),
    @DeviceID     INT = NULL,
    @Latitude     DECIMAL(10,7) = NULL,
    @Longitude    DECIMAL(10,7) = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    -- Validate attendance record exists
    IF NOT EXISTS (SELECT 1 FROM dbo.Attendance WHERE AttendanceID = @AttendanceID)
    BEGIN
        RAISERROR('Attendance record with the specified ID does not exist.', 16, 1);
        RETURN;
    END

    -- Validate source type
    IF @SourceType NOT IN ('Device', 'Terminal', 'GPS', 'Mobile', 'Web', 'Biometric', 'Manual')
    BEGIN
        RAISERROR('Invalid source type. Valid types are: Device, Terminal, GPS, Mobile, Web, Biometric, Manual.', 16, 1);
        RETURN;
    END
       
    -- Validate device exists if DeviceID provided
    IF @DeviceID IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.Device WHERE DeviceID = @DeviceID)
    BEGIN
        RAISERROR('Device with the specified ID does not exist.', 16, 1);
        RETURN;
    END

    -- Validate GPS coordinates if provided (basic range check)
    IF @Latitude IS NOT NULL AND (@Latitude < -90 OR @Latitude > 90)
    BEGIN
        RAISERROR('Latitude must be between -90 and 90 degrees.', 16, 1);
        RETURN;
    END

    IF @Longitude IS NOT NULL AND (@Longitude < -180 OR @Longitude > 180)
    BEGIN
        RAISERROR('Longitude must be between -180 and 180 degrees.', 16, 1);
        RETURN;
    END

    -- For GPS source type, coordinates are required
    IF @SourceType = 'GPS' AND (@Latitude IS NULL OR @Longitude IS NULL)
    BEGIN
        RAISERROR('GPS coordinates (Latitude and Longitude) are required for GPS source type.', 16, 1);
        RETURN;
    END

    -- Check if attendance source already exists for this attendance record
    IF EXISTS (SELECT 1 FROM dbo.AttendanceSource WHERE attendance_id = @AttendanceID)
    BEGIN
        RAISERROR('Attendance source already tagged for this record. Use update instead of create.', 16, 1);
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO dbo.AttendanceSource
        (
            attendance_id,
            device_id,
            source_type,
            latitude,
            longitude,
            recorded_at
        )
        VALUES
        (
            @AttendanceID,
            @DeviceID,
            @SourceType,
            @Latitude,
            @Longitude,
            GETDATE()
        );

        COMMIT TRANSACTION;

        SELECT 'Attendance source tagged' AS Message,
               @AttendanceID AS AttendanceID,
               @SourceType AS SourceType,
               @DeviceID AS DeviceID,
               @Latitude AS Latitude,
               @Longitude AS Longitude;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('TagAttendanceSource failed: %s', 16, 1, @ErrMsg);
        RETURN;
    END CATCH
END
GO

--17
-- Procedure: SyncOfflineAttendance
-- Input: @DeviceID int, @EmployeeID int, @ClockTime datetime, @Type varchar(10)
-- Output: Confirmation message
-- Note: This requires a table to store offline attendance records before they're synced

-- Create OfflineAttendanceQueue table if it doesn't exist
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID('dbo.OfflineAttendanceQueue') AND type = 'U')
BEGIN
    CREATE TABLE dbo.OfflineAttendanceQueue
    (
        QueueID INT PRIMARY KEY IDENTITY(1,1),
        device_id INT NOT NULL,
        employee_id INT NOT NULL,
        clock_time DATETIME NOT NULL,
        clock_type VARCHAR(10) NOT NULL, -- 'IN' or 'OUT'
        sync_status VARCHAR(20) DEFAULT 'PENDING', -- PENDING, SYNCED, FAILED
        created_at DATETIME DEFAULT GETDATE(),
        synced_at DATETIME NULL,
        attendance_id INT NULL, -- Reference to created Attendance record after sync
        error_message VARCHAR(500) NULL,
        CONSTRAINT FK_OfflineQueue_Device FOREIGN KEY (device_id) REFERENCES Device(DeviceID),
        CONSTRAINT FK_OfflineQueue_Employee FOREIGN KEY (employee_id) REFERENCES Employee(EmployeeID)
    );
END
GO

CREATE OR ALTER PROCEDURE dbo.SyncOfflineAttendance
(
    @DeviceID   INT,
    @EmployeeID INT,
    @ClockTime  DATETIME,
    @Type       VARCHAR(10)
)
AS
BEGIN
    SET NOCOUNT ON;

    -- Validate device exists
    IF NOT EXISTS (SELECT 1 FROM dbo.Device WHERE DeviceID = @DeviceID)
    BEGIN
        RAISERROR('Device with the specified ID does not exist.', 16, 1);
        RETURN;
    END

    -- Validate employee exists
    IF NOT EXISTS (SELECT 1 FROM dbo.Employee WHERE EmployeeID = @EmployeeID)
    BEGIN
        RAISERROR('Employee with the specified ID does not exist.', 16, 1);
        RETURN;
    END

    -- Validate clock type
    IF @Type NOT IN ('IN', 'OUT', 'BREAK_START', 'BREAK_END')
    BEGIN
        RAISERROR('Invalid clock type. Valid types are: IN, OUT, BREAK_START, BREAK_END.', 16, 1);
        RETURN;
    END

    -- Validate clock time is not in the future
    IF @ClockTime > GETDATE()
    BEGIN
        RAISERROR('Clock time cannot be in the future.', 16, 1);
        RETURN;
    END

    -- Validate clock time is not too old (e.g., more than 30 days)
    IF DATEDIFF(DAY, @ClockTime, GETDATE()) > 30
    BEGIN
        RAISERROR('Clock time is too old (more than 30 days). Please contact HR for manual correction.', 16, 1);
        RETURN;
    END

    DECLARE @NewAttendanceID INT;
    DECLARE @QueueID INT;
    DECLARE @SyncStatus VARCHAR(20) = 'SYNCED';
    DECLARE @ErrorMsg VARCHAR(500) = NULL;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Try to create attendance record
        -- Generate new AttendanceID
        SELECT @NewAttendanceID = ISNULL(MAX(AttendanceID), 0) + 1
        FROM dbo.Attendance WITH (TABLOCKX, HOLDLOCK);

        -- Determine entry/exit time based on type
        DECLARE @EntryTime TIME = NULL;
        DECLARE @ExitTime TIME = NULL;

        IF @Type IN ('IN', 'BREAK_END')
            SET @EntryTime = CAST(@ClockTime AS TIME);
        ELSE IF @Type IN ('OUT', 'BREAK_START')
            SET @ExitTime = CAST(@ClockTime AS TIME);

        -- Insert into Attendance table
        INSERT INTO dbo.Attendance
        (
            AttendanceID,
            employee_id,
            entry_time,
            exit_time,
            duration,
            login_method,
            logout_method,
            exception_id
        )
        VALUES
        (
            @NewAttendanceID,
            @EmployeeID,
            @EntryTime,
            @ExitTime,
            NULL, -- Duration calculated later by another process
            CASE WHEN @Type IN ('IN', 'BREAK_END') THEN 'Device_' + CAST(@DeviceID AS VARCHAR(10)) ELSE NULL END,
            CASE WHEN @Type IN ('OUT', 'BREAK_START') THEN 'Device_' + CAST(@DeviceID AS VARCHAR(10)) ELSE NULL END,
            NULL
        );

        -- Tag the attendance source
        INSERT INTO dbo.AttendanceSource
        (
            attendance_id,
            device_id,
            source_type,
            latitude,
            longitude,
            recorded_at
        )
        SELECT
            @NewAttendanceID,
            @DeviceID,
            'Device',
            d.latitude,
            d.longitude,
            @ClockTime
        FROM dbo.Device d
        WHERE d.DeviceID = @DeviceID;

        -- Record in offline queue for tracking
        INSERT INTO dbo.OfflineAttendanceQueue
        (
            device_id,
            employee_id,
            clock_time,
            clock_type,
            sync_status,
            synced_at,
            attendance_id,
            error_message
        )
        VALUES
        (
            @DeviceID,
            @EmployeeID,
            @ClockTime,
            @Type,
            @SyncStatus,
            GETDATE(),
            @NewAttendanceID,
            NULL
        );

        SET @QueueID = SCOPE_IDENTITY();

        COMMIT TRANSACTION;

        SELECT 'Offline attendance synced successfully' AS Message,
               @QueueID AS QueueID,
               @NewAttendanceID AS AttendanceID,
               @EmployeeID AS EmployeeID,
               @DeviceID AS DeviceID,
               @ClockTime AS ClockTime,
               @Type AS ClockType;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        SET @ErrorMsg = ERROR_MESSAGE();
        SET @SyncStatus = 'FAILED';

        -- Log failed sync attempt
        BEGIN TRY
            INSERT INTO dbo.OfflineAttendanceQueue
            (device_id, employee_id, clock_time, clock_type, sync_status, error_message)
            VALUES
            (@DeviceID, @EmployeeID, @ClockTime, @Type, @SyncStatus, @ErrorMsg);
        END TRY
        BEGIN CATCH
            -- If even logging fails, just report the original error
        END CATCH

        RAISERROR('SyncOfflineAttendance failed: %s', 16, 1, @ErrorMsg);
        RETURN;
    END CATCH
END
GO

--18
-- Procedure: LogAttendanceEdit
-- Input: @AttendanceID int, @EditedBy int, @OldValue datetime, @NewValue datetime, @EditTimestamp datetime
-- Output: Confirmation message
-- Note: The signature in requirements mentions @HolidayID but description says attendance edits
--       I'm implementing for attendance edits as per the description

CREATE OR ALTER PROCEDURE dbo.LogAttendanceEdit
(
    @AttendanceID   INT,
    @EditedBy       INT,
    @OldValue       DATETIME,
    @NewValue       DATETIME,
    @EditTimestamp  DATETIME = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    -- Use current time if not provided
    IF @EditTimestamp IS NULL
        SET @EditTimestamp = GETDATE();

    -- Validate attendance record exists
    IF NOT EXISTS (SELECT 1 FROM dbo.Attendance WHERE AttendanceID = @AttendanceID)
    BEGIN
        RAISERROR('Attendance record with the specified ID does not exist.', 16, 1);
        RETURN;
    END

    -- Validate editor exists
    IF NOT EXISTS (SELECT 1 FROM dbo.Employee WHERE EmployeeID = @EditedBy)
    BEGIN
        RAISERROR('Editor employee with the specified ID does not exist.', 16, 1);
        RETURN;
    END

    -- Validate that old and new values are different
    IF @OldValue = @NewValue
    BEGIN
        RAISERROR('Old value and new value are identical. No change to log.', 16, 1);
        RETURN;
    END

    -- Validate timestamp is not in the future
    IF @EditTimestamp > GETDATE()
    BEGIN
        RAISERROR('Edit timestamp cannot be in the future.', 16, 1);
        RETURN;
    END

    -- Get employee associated with attendance record for the reason
    DECLARE @AttendanceEmployeeID INT;
    SELECT @AttendanceEmployeeID = employee_id
    FROM dbo.Attendance
    WHERE AttendanceID = @AttendanceID;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Generate new AttendanceLogID
        DECLARE @NewLogID INT;
        SELECT @NewLogID = ISNULL(MAX(AttendanceLogID), 0) + 1
        FROM dbo.AttendanceLog WITH (TABLOCKX, HOLDLOCK);

        -- Build reason text
        DECLARE @ReasonText VARCHAR(500);
        SET @ReasonText = 'Time changed from ' + 
                         CONVERT(VARCHAR(20), @OldValue, 120) + 
                         ' to ' + 
                         CONVERT(VARCHAR(20), @NewValue, 120) +
                         ' by Employee ID ' + CAST(@EditedBy AS VARCHAR(10));

        -- Insert log entry
        INSERT INTO dbo.AttendanceLog
        (
            AttendanceLogID,
            attendance_id,
            actor,
            timestamp,
            reason
        )
        VALUES
        (
            @NewLogID,
            @AttendanceID,
            'Employee_' + CAST(@EditedBy AS VARCHAR(10)),
            @EditTimestamp,
            @ReasonText
        );

        COMMIT TRANSACTION;

        SELECT 'Attendance edit logged' AS Message,
               @NewLogID AS LogID,
               @AttendanceID AS AttendanceID,
               @EditedBy AS EditedBy,
               @OldValue AS OldValue,
               @NewValue AS NewValue,
               @EditTimestamp AS EditTimestamp;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('LogAttendanceEdit failed: %s', 16, 1, @ErrMsg);
        RETURN;
    END CATCH
END
GO

--19
-- Procedure: ApplyHolidayOverrides
-- Input: @HolidayID int (based on signature), @EmployeeID int, @StartDate date, @EndDate date
-- Output: Confirmation message
-- Note: This applies holiday leave to employee shifts in the specified date range

CREATE OR ALTER PROCEDURE dbo.ApplyHolidayOverrides
(
    @HolidayID INT,
    @EmployeeID INT = NULL, -- NULL means apply to all employees
    @StartDate DATE = NULL,
    @EndDate DATE = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    -- Validate holiday leave exists
    IF NOT EXISTS (
        SELECT 1 
        FROM dbo.Leave l
        INNER JOIN dbo.HolidayLeave hl ON l.LeaveID = hl.leave_id
        WHERE l.LeaveID = @HolidayID
    )
    BEGIN
        RAISERROR('Holiday leave with the specified ID does not exist.', 16, 1);
        RETURN;
    END

    -- If employee specified, validate they exist
    IF @EmployeeID IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.Employee WHERE EmployeeID = @EmployeeID)
    BEGIN
        RAISERROR('Employee with the specified ID does not exist.', 16, 1);
        RETURN;
    END

    -- Get holiday information
    DECLARE @HolidayName VARCHAR(100);
    DECLARE @RegionalScope VARCHAR(100);
    
    SELECT 
        @HolidayName = hl.holiday_name,
        @RegionalScope = hl.regional_scope
    FROM dbo.HolidayLeave hl
    WHERE hl.leave_id = @HolidayID;

    -- If dates not provided, try to infer from holiday name or use reasonable defaults
    IF @StartDate IS NULL
        SET @StartDate = CAST(GETDATE() AS DATE);
    
    IF @EndDate IS NULL
        SET @EndDate = @StartDate; -- Single day holiday by default

    -- Validate date range
    IF @StartDate > @EndDate
    BEGIN
        RAISERROR('Start date must be on or before end date.', 16, 1);
        RETURN;
    END

    DECLARE @AffectedShifts INT = 0;
    DECLARE @AffectedEmployees INT = 0;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Create a temp table to track affected shifts
        CREATE TABLE #AffectedShifts (ShiftID INT, EmployeeID INT);

        -- Find all shifts that overlap with the holiday period
        INSERT INTO #AffectedShifts (ShiftID, EmployeeID)
        SELECT 
            ss.ShiftID,
            ss.employee_id
        FROM dbo.ShiftSchedule ss
        WHERE 
            (@EmployeeID IS NULL OR ss.employee_id = @EmployeeID)
            AND NOT (ss.end_date < @StartDate OR ss.start_date > @EndDate)
            AND ss.status NOT IN ('Cancelled', 'Expired');

        SET @AffectedShifts = @@ROWCOUNT;

        -- Update shift statuses to indicate holiday override
        UPDATE ss
        SET ss.status = 'Holiday Override'
        FROM dbo.ShiftSchedule ss
        INNER JOIN #AffectedShifts a ON ss.ShiftID = a.ShiftID;

        -- Count distinct employees affected
        SELECT @AffectedEmployees = COUNT(DISTINCT EmployeeID)
        FROM #AffectedShifts;

        -- Create exception records for the holiday
        DECLARE @ExceptionID INT;
        SELECT @ExceptionID = ISNULL(MAX(ExceptionID), 0) + 1
        FROM dbo.Exception WITH (TABLOCKX, HOLDLOCK);

        -- Insert exception if it doesn't exist for this date range
        IF NOT EXISTS (
            SELECT 1 
            FROM dbo.Exception 
            WHERE name = @HolidayName 
              AND CAST(date AS DATE) BETWEEN @StartDate AND @EndDate
        )
        BEGIN
            INSERT INTO dbo.Exception
            (
                ExceptionID,
                name,
                category,
                date,
                status
            )
            VALUES
            (
                @ExceptionID,
                @HolidayName,
                'Holiday',
                @StartDate,
                'Active'
            );

            -- Link affected employees to this exception
            INSERT INTO dbo.EmployeeException (employee_id, exception_id)
            SELECT DISTINCT EmployeeID, @ExceptionID
            FROM #AffectedShifts
            WHERE NOT EXISTS (
                SELECT 1 
                FROM dbo.EmployeeException ee 
                WHERE ee.employee_id = #AffectedShifts.EmployeeID 
                  AND ee.exception_id = @ExceptionID
            );
        END

        DROP TABLE #AffectedShifts;

        COMMIT TRANSACTION;

        SELECT 'Holiday overrides applied' AS Message,
               @HolidayID AS HolidayID,
               @HolidayName AS HolidayName,
               @StartDate AS StartDate,
               @EndDate AS EndDate,
               @AffectedShifts AS AffectedShifts,
               @AffectedEmployees AS AffectedEmployees;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        IF OBJECT_ID('tempdb..#AffectedShifts') IS NOT NULL
            DROP TABLE #AffectedShifts;

        DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('ApplyHolidayOverrides failed: %s', 16, 1, @ErrMsg);
        RETURN;
    END CATCH
END
GO

--20
-- Procedure: ManageUserAccounts
-- Input: @UserID int, @Role varchar(50), @Action varchar(20)
-- Output: Confirmation message
-- Note: This manages user roles for payroll and system access

CREATE OR ALTER PROCEDURE dbo.ManageUserAccounts
(
    @UserID INT,
    @Role   VARCHAR(50),
    @Action VARCHAR(20)
)
AS
BEGIN
    SET NOCOUNT ON;

    -- Validate user (employee) exists
    IF NOT EXISTS (SELECT 1 FROM dbo.Employee WHERE EmployeeID = @UserID)
    BEGIN
        RAISERROR('User/Employee with the specified ID does not exist.', 16, 1);
        RETURN;
    END

    -- Validate action
    IF @Action NOT IN ('ADD', 'REMOVE', 'UPDATE', 'ACTIVATE', 'DEACTIVATE')
    BEGIN
        RAISERROR('Invalid action. Valid actions are: ADD, REMOVE, UPDATE, ACTIVATE, DEACTIVATE.', 16, 1);
        RETURN;
    END

    -- Validate role
    IF @Role NOT IN ('System Administrator', 'HR Administrator', 'Payroll Officer', 'Payroll Specialist', 'Line Manager', 'Employee')
    BEGIN
        RAISERROR('Invalid role. Valid roles are: System Administrator, HR Administrator, Payroll Officer, Payroll Specialist, Line Manager, Employee.', 16, 1);
        RETURN;
    END

    DECLARE @RoleID INT;
    DECLARE @ActionResult VARCHAR(100);

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Get or create role
        SELECT @RoleID = RoleID
        FROM dbo.Role
        WHERE role_name = @Role;

        IF @RoleID IS NULL
        BEGIN
            -- Create role if it doesn't exist
            SELECT @RoleID = ISNULL(MAX(RoleID), 0) + 1
            FROM dbo.Role WITH (TABLOCKX, HOLDLOCK);

            INSERT INTO dbo.Role (RoleID, role_name, purpose)
            VALUES (@RoleID, @Role, 'Automatically created role for ' + @Role);
        END

        -- Process action
        IF @Action = 'ADD'
        BEGIN
            -- Check if already assigned
            IF EXISTS (SELECT 1 FROM dbo.EmployeeRole WHERE employee_id = @UserID AND role_id = @RoleID)
            BEGIN
                SET @ActionResult = 'Role already assigned to user';
            END
            ELSE
            BEGIN
                INSERT INTO dbo.EmployeeRole (employee_id, role_id, assigned_date)
                VALUES (@UserID, @RoleID, GETDATE());

                -- Create corresponding specialized table entry if applicable
                IF @Role = 'System Administrator' AND NOT EXISTS (SELECT 1 FROM dbo.SystemAdministrator WHERE employee_id = @UserID)
                BEGIN
                    INSERT INTO dbo.SystemAdministrator (employee_id, system_privilege_level, configurable_fields, audit_visibility_scope)
                    VALUES (@UserID, 'FULL', 'ALL', 'FULL');
                END
                ELSE IF @Role = 'HR Administrator' AND NOT EXISTS (SELECT 1 FROM dbo.HRAdministrator WHERE employee_id = @UserID)
                BEGIN
                    INSERT INTO dbo.HRAdministrator (employee_id, approval_level, record_access_scope, document_validation_rights)
                    VALUES (@UserID, 'STANDARD', 'DEPARTMENT', 1);
                END
                ELSE IF @Role IN ('Payroll Officer', 'Payroll Specialist') AND NOT EXISTS (SELECT 1 FROM dbo.PayrollSpecialist WHERE employee_id = @UserID)
                BEGIN
                    INSERT INTO dbo.PayrollSpecialist (employee_id, assigned_region, processing_frequency, last_processed_period)
                    VALUES (@UserID, 'Default', 'Monthly', NULL);
                END
                ELSE IF @Role = 'Line Manager' AND NOT EXISTS (SELECT 1 FROM dbo.LineManager WHERE employee_id = @UserID)
                BEGIN
                    INSERT INTO dbo.LineManager (employee_id, team_size, supervised_departments, approval_limit)
                    VALUES (@UserID, 0, NULL, 5000.00);
                END

                SET @ActionResult = 'Role added successfully';
            END
        END
        ELSE IF @Action = 'REMOVE'
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM dbo.EmployeeRole WHERE employee_id = @UserID AND role_id = @RoleID)
            BEGIN
                SET @ActionResult = 'Role not assigned to user';
            END
            ELSE
            BEGIN
                DELETE FROM dbo.EmployeeRole
                WHERE employee_id = @UserID AND role_id = @RoleID;

                -- Remove from specialized tables
                IF @Role = 'System Administrator'
                    DELETE FROM dbo.SystemAdministrator WHERE employee_id = @UserID;
                ELSE IF @Role = 'HR Administrator'
                    DELETE FROM dbo.HRAdministrator WHERE employee_id = @UserID;
                ELSE IF @Role IN ('Payroll Officer', 'Payroll Specialist')
                    DELETE FROM dbo.PayrollSpecialist WHERE employee_id = @UserID;
                ELSE IF @Role = 'Line Manager'
                    DELETE FROM dbo.LineManager WHERE employee_id = @UserID;

                SET @ActionResult = 'Role removed successfully';
            END
        END
        ELSE IF @Action = 'ACTIVATE'
        BEGIN
            UPDATE dbo.Employee
            SET is_active = 1,
                account_status = 'ACTIVE'
            WHERE EmployeeID = @UserID;

            SET @ActionResult = 'User account activated';
        END
        ELSE IF @Action = 'DEACTIVATE'
        BEGIN
            UPDATE dbo.Employee
            SET is_active = 0,
                account_status = 'INACTIVE'
            WHERE EmployeeID = @UserID;

            SET @ActionResult = 'User account deactivated';
        END
        ELSE IF @Action = 'UPDATE'
        BEGIN
            -- Update existing role assignment date
            IF EXISTS (SELECT 1 FROM dbo.EmployeeRole WHERE employee_id = @UserID AND role_id = @RoleID)
            BEGIN
                UPDATE dbo.EmployeeRole
                SET assigned_date = GETDATE()
                WHERE employee_id = @UserID AND role_id = @RoleID;

                SET @ActionResult = 'Role assignment updated';
            END
            ELSE
            BEGIN
                SET @ActionResult = 'Role not found for update. Use ADD action instead.';
            END
        END

        COMMIT TRANSACTION;

        SELECT @ActionResult AS Message,
               @UserID AS UserID,
               @Role AS Role,
               @Action AS Action,
               @RoleID AS RoleID;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('ManageUserAccounts failed: %s', 16, 1, @ErrMsg);
        RETURN;
    END CATCH
END
GO

--HR Adminsator 
USE MILESTONE2;
GO

--1
-- ========================================
-- 1) Create a new employment contract for an employee (FIXED & IMPROVED)
-- ========================================
IF OBJECT_ID('CreateContract', 'P') IS NOT NULL
    DROP PROCEDURE CreateContract;
GO

CREATE OR ALTER PROCEDURE CreateContract
    @EmployeeID int,
    @Type varchar(50),
    @StartDate date,
    @EndDate date
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validate employee exists
        IF NOT EXISTS (SELECT 1 FROM Employee WHERE EmployeeID = @EmployeeID)
        BEGIN
            RAISERROR('Employee not found', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- Validate contract type
        IF @Type NOT IN ('Full-Time', 'Part-Time', 'Consultant', 'Internship')
        BEGIN
            RAISERROR('Invalid contract type. Must be: Full-Time, Part-Time, Consultant, or Internship', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- Validate date range
        IF @StartDate > @EndDate
        BEGIN
            RAISERROR('Start date cannot be after end date', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- Check if employee already has an active contract
        DECLARE @ExistingContractID int;
        SELECT @ExistingContractID = contract_id 
        FROM Employee 
        WHERE EmployeeID = @EmployeeID;
        
        IF @ExistingContractID IS NOT NULL
        BEGIN
            -- Check if existing contract is active
            DECLARE @ContractState varchar(50);
            SELECT @ContractState = current_state 
            FROM Contract 
            WHERE ContractID = @ExistingContractID;
            
            IF @ContractState = 'Active'
            BEGIN
                RAISERROR('Employee already has an active contract. Please terminate or expire the existing contract first.', 16, 1);
                ROLLBACK TRANSACTION;
                RETURN;
            END
        END
        
        -- Generate new ContractID
        DECLARE @NewContractID int;
        SET @NewContractID = (SELECT ISNULL(MAX(ContractID), 0) + 1 FROM Contract);
        
        -- Insert contract
        INSERT INTO Contract (ContractID, type, start_date, end_date, current_state)
        VALUES (@NewContractID, @Type, @StartDate, @EndDate, 'Active');
        
        -- Update employee record with new contract
        UPDATE Employee
        SET contract_id = @NewContractID
        WHERE EmployeeID = @EmployeeID;
        
        -- Create specific contract type record based on type
        IF @Type = 'Full-Time'
        BEGIN
            INSERT INTO FullTimeContract (contract_id, leave_entitlement, insurance_eligibility, weekly_working_hours)
            VALUES (@NewContractID, 20, 1, 40); -- Default values
        END
        ELSE IF @Type = 'Part-Time'
        BEGIN
            INSERT INTO PartTimeContract (contract_id, working_hours, hourly_rate)
            VALUES (@NewContractID, 20, 0.00); -- Default values
        END
        ELSE IF @Type = 'Consultant'
        BEGIN
            INSERT INTO ConsultantContract (contract_id, project_scope, fees, payment_schedule)
            VALUES (@NewContractID, 'To be defined', 0.00, 'Monthly'); -- Default values
        END
        ELSE IF @Type = 'Internship'
        BEGIN
            INSERT INTO InternshipContract (contract_id, mentoring, evaluation, stipend_related)
            VALUES (@NewContractID, 'To be assigned', 'Quarterly evaluation', 0.00); -- Default values
        END
        
        COMMIT TRANSACTION;
        
        PRINT 'Contract created successfully for employee ' + CAST(@EmployeeID AS varchar(10)) + 
              ' with Contract ID: ' + CAST(@NewContractID AS varchar(10));
              
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        DECLARE @ErrorMessage nvarchar(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO
-----------------------------------------------------

--2         runs
--Renew or extend an existing contract.
--Signature:
--Name: RenewContract.
--Input: @ContractID int, @NewEndDate date.
--Output: Confirmation message.
CREATE OR ALTER PROCEDURE RenewContract            
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
CREATE OR ALTER PROCEDURE ApproveLeaveRequest                --Runs well
    @LeaveRequestID INT,
    @ApproverID INT,
    @Status VARCHAR(20)
    AS
    BEGIN
        UPDATE LeaveRequest
        SET status = @Status, employee_id = @ApproverID, approval_timing = GETDATE()
        WHERE RequestID = @LeaveRequestID;
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
 
CREATE OR ALTER PROCEDURE AssignMission               --Runs well
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
CREATE OR ALTER PROCEDURE ReviewReimbursement
    @ClaimID INT,
    @ApproverID INT,
    @Decision VARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Variable declarations
    DECLARE @CurrentStatus VARCHAR(50);
    DECLARE @EmployeeID INT;
    DECLARE @IsAuthorized BIT = 0;
    
    -- Check if the claim exists and get current status
    SELECT @CurrentStatus = current_status, 
           @EmployeeID = employee_id
    FROM Reimbursement
    WHERE ReimbursementID = @ClaimID;
    
    -- If claim doesn't exist, raise error
    IF @CurrentStatus IS NULL
    BEGIN
        RAISERROR('Error: Reimbursement claim does not exist.', 16, 1);
        RETURN;
    END
    
    -- Check if claim is in pending status
    IF @CurrentStatus != 'Pending'
    BEGIN
        RAISERROR('Error: Only pending claims can be reviewed.', 16, 1);
        RETURN;
    END
    
    -- Validate decision input
    IF @Decision NOT IN ('Approved', 'Rejected')
    BEGIN
        RAISERROR('Error: Decision must be either ''Approved'' or ''Rejected''.', 16, 1);
        RETURN;
    END
    
    -- Check if approver is authorized (must be HR Admin, Line Manager, or the employee's manager)
    -- Check if approver is HR Administrator
    IF EXISTS (SELECT 1 FROM HRAdministrator WHERE employee_id = @ApproverID)
    BEGIN
        SET @IsAuthorized = 1;
    END
    
    -- Check if approver is Line Manager
    IF EXISTS (SELECT 1 FROM LineManager WHERE employee_id = @ApproverID)
    BEGIN
        SET @IsAuthorized = 1;
    END
    
    -- Check if approver is the employee's direct manager
    IF EXISTS (SELECT 1 FROM Employee WHERE EmployeeID = @EmployeeID AND manager_id = @ApproverID)
    BEGIN
        SET @IsAuthorized = 1;
    END
    
    -- If not authorized, raise error
    IF @IsAuthorized = 0
    BEGIN
        RAISERROR('Error: Approver is not authorized to review this claim.', 16, 1);
        RETURN;
    END
    
    -- Update the reimbursement record
    UPDATE Reimbursement
    SET current_status = @Decision,
        approval_date = GETDATE()
    WHERE ReimbursementID = @ClaimID;
    
    -- Return confirmation message
    SELECT 'Reimbursement claim ' + CAST(@ClaimID AS VARCHAR(10)) + 
           ' has been ' + @Decision + ' by approver ' + CAST(@ApproverID AS VARCHAR(10)) + '.' AS ConfirmationMessage;
END;
GO
------------------------------------------------------------------------------------------------------
--6
CREATE OR ALTER PROCEDURE getActiveContracts              --Runs well
AS
BEGIN
   SELECT *
   FROM Contract
   WHERE current_state = 'ACTIVE' or end_date > GETDATE();
END;
GO
------------------------------------------------------

--7 (FIXED) - Retrieve employees under a specific manager
------------------------------------------------------
IF OBJECT_ID('GetTeamByManager', 'P') IS NOT NULL
    DROP PROCEDURE GetTeamByManager;
GO

CREATE OR ALTER PROCEDURE GetTeamByManager
    @ManagerID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validate manager exists
    IF NOT EXISTS (SELECT 1 FROM Employee WHERE EmployeeID = @ManagerID)
    BEGIN
        RAISERROR('Manager not found.', 16, 1);
        RETURN;
    END
    
    -- Return employees under this manager
    SELECT 
        EmployeeID,
        first_name,
        last_name,
        full_name,
        email,
        phone,
        employment_status,
        hire_date
    FROM Employee
    WHERE manager_id = @ManagerID
    ORDER BY last_name, first_name;
    
    -- Return count message
    DECLARE @TeamCount INT;
    SELECT @TeamCount = COUNT(*) FROM Employee WHERE manager_id = @ManagerID;
    
    PRINT 'Found ' + CAST(@TeamCount AS VARCHAR(10)) + ' team members under Manager ID: ' + CAST(@ManagerID AS VARCHAR(10));
END;
GO


--------------------------------------------------------------
--8 UpdateLeavePolicy (NEW)
--------------------------------------------------------------
IF OBJECT_ID('UpdateLeavePolicy', 'P') IS NOT NULL
    DROP PROCEDURE UpdateLeavePolicy;
GO

CREATE OR ALTER PROCEDURE UpdateLeavePolicy
    @PolicyID INT,
    @EligibilityRules VARCHAR(200),
    @NoticePeriod INT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validate policy exists
    IF NOT EXISTS (SELECT 1 FROM LeavePolicy WHERE PolicyID = @PolicyID)
    BEGIN
        RAISERROR('Leave policy not found.', 16, 1);
        RETURN;
    END
    
    -- Validate notice period is non-negative
    IF @NoticePeriod < 0
    BEGIN
        RAISERROR('Notice period cannot be negative.', 16, 1);
        RETURN;
    END
    
    -- Validate eligibility rules are not empty
    IF @EligibilityRules IS NULL OR LTRIM(RTRIM(@EligibilityRules)) = ''
    BEGIN
        RAISERROR('Eligibility rules cannot be empty.', 16, 1);
        RETURN;
    END
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Update leave policy
        UPDATE LeavePolicy
        SET eligibility_rules = @EligibilityRules,
            notice_period = @NoticePeriod
        WHERE PolicyID = @PolicyID;
        
        -- Create notification for HR administrators
        INSERT INTO Notification (mesage_content, timestamp, urgency, read_status, notification_type)
        VALUES (
            CONCAT('Leave Policy (ID: ', @PolicyID, ') has been updated. ',
                   'New eligibility rules: ', @EligibilityRules, '. ',
                   'New notice period: ', @NoticePeriod, ' days.'),
            GETDATE(),
            'MEDIUM',
            0,
            'Policy Update'
        );
        
        DECLARE @NotificationID INT = SCOPE_IDENTITY();
        
        -- Notify all HR Administrators
        INSERT INTO EmployeeNotification (employee_id, notification_id, delivery_status, delivered_at)
        SELECT employee_id, @NotificationID, 'PENDING', GETDATE()
        FROM HRAdministrator;
        
        COMMIT TRANSACTION;
        
        SELECT 'Leave policy updated successfully.' AS ConfirmationMessage,
               @PolicyID AS PolicyID,
               @EligibilityRules AS NewEligibilityRules,
               @NoticePeriod AS NewNoticePeriod;
               
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END;
GO

--------------------------------------------------------------
--9 GetExpiringContracts (NEW)
--------------------------------------------------------------
IF OBJECT_ID('GetExpiringContracts', 'P') IS NOT NULL
    DROP PROCEDURE GetExpiringContracts;
GO

CREATE OR ALTER PROCEDURE GetExpiringContracts
    @DaysBefore INT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validate days before is positive
    IF @DaysBefore <= 0
    BEGIN
        RAISERROR('Days before must be a positive number.', 16, 1);
        RETURN;
    END
    
    -- Calculate threshold date
    DECLARE @ThresholdDate DATE = DATEADD(DAY, @DaysBefore, GETDATE());
    
    -- Return contracts expiring within the specified period
    SELECT 
        c.ContractID,
        e.EmployeeID,
        e.full_name AS EmployeeName,
        e.email,
        c.type AS ContractType,
        c.start_date AS StartDate,
        c.end_date AS EndDate,
        DATEDIFF(DAY, GETDATE(), c.end_date) AS DaysUntilExpiry,
        c.current_state AS CurrentState
    FROM Contract c
    INNER JOIN Employee e ON e.contract_id = c.ContractID
    WHERE c.end_date BETWEEN GETDATE() AND @ThresholdDate
    AND c.current_state = 'Active'
    ORDER BY c.end_date ASC;
    
    -- Return count message
    DECLARE @ExpiringCount INT;
    SELECT @ExpiringCount = COUNT(*)
    FROM Contract c
    WHERE c.end_date BETWEEN GETDATE() AND @ThresholdDate
    AND c.current_state = 'Active';
    
    PRINT 'Found ' + CAST(@ExpiringCount AS VARCHAR(10)) + 
          ' contracts expiring within ' + CAST(@DaysBefore AS VARCHAR(10)) + ' days.';
END;
GO

--------------------------------------------------------------
--10 AssignDepartmentHead (NEW)
--------------------------------------------------------------
IF OBJECT_ID('AssignDepartmentHead', 'P') IS NOT NULL
    DROP PROCEDURE AssignDepartmentHead;
GO

CREATE OR ALTER PROCEDURE AssignDepartmentHead
    @DepartmentID INT,
    @ManagerID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validate department exists
        IF NOT EXISTS (SELECT 1 FROM Department WHERE DepartmentID = @DepartmentID)
        BEGIN
            RAISERROR('Department not found.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- Validate manager exists
        IF NOT EXISTS (SELECT 1 FROM Employee WHERE EmployeeID = @ManagerID)
        BEGIN
            RAISERROR('Manager not found.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- Validate manager is a Line Manager
        IF NOT EXISTS (SELECT 1 FROM LineManager WHERE employee_id = @ManagerID)
        BEGIN
            RAISERROR('Employee is not a Line Manager.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- Update department with new head
        UPDATE Department
        SET department_head_id = @ManagerID
        WHERE DepartmentID = @DepartmentID;
        
        -- Create notification
        DECLARE @DepartmentName VARCHAR(100);
        SELECT @DepartmentName = department_name FROM Department WHERE DepartmentID = @DepartmentID;
        
        INSERT INTO Notification (mesage_content, timestamp, urgency, read_status, notification_type)
        VALUES (
            CONCAT('Department Head Assignment: ', @DepartmentName, 
                   ' (ID: ', @DepartmentID, ') now managed by Employee ID: ', @ManagerID),
            GETDATE(),
            'HIGH',
            0,
            'Department Update'
        );
        
        DECLARE @NotificationID INT = SCOPE_IDENTITY();
        
        -- Notify the new department head
        INSERT INTO EmployeeNotification (employee_id, notification_id, delivery_status, delivered_at)
        VALUES (@ManagerID, @NotificationID, 'PENDING', GETDATE());
        
        -- Notify HR Administrators
        INSERT INTO EmployeeNotification (employee_id, notification_id, delivery_status, delivered_at)
        SELECT employee_id, @NotificationID, 'PENDING', GETDATE()
        FROM HRAdministrator;
        
        COMMIT TRANSACTION;
        
        SELECT 'Department head assigned successfully.' AS ConfirmationMessage,
               @DepartmentID AS DepartmentID,
               @DepartmentName AS DepartmentName,
               @ManagerID AS NewHeadID;
               
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END;
GO

------------------------------------------------------------
--11 (FIXED) - Create employee profile
------------------------------------------------------------
IF OBJECT_ID('CreateEmployeeProfile', 'P') IS NOT NULL
    DROP PROCEDURE CreateEmployeeProfile;
GO

CREATE OR ALTER PROCEDURE CreateEmployeeProfile
    @FirstName VARCHAR(50),
    @LastName VARCHAR(50),
    @DepartmentID INT,
    @RoleID INT,
    @HireDate DATE,
    @Email VARCHAR(100),
    @Phone VARCHAR(20),
    @NationalID VARCHAR(50), 
    @DateOfBirth DATE, 
    @CountryOfBirth VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validate department exists
        IF NOT EXISTS (SELECT 1 FROM Department WHERE DepartmentID = @DepartmentID)
        BEGIN
            RAISERROR('Department not found.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- Validate role exists
        IF NOT EXISTS (SELECT 1 FROM Role WHERE RoleID = @RoleID)
        BEGIN
            RAISERROR('Role not found.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- Validate email is unique
        IF EXISTS (SELECT 1 FROM Employee WHERE email = @Email)
        BEGIN
            RAISERROR('Email already exists.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- Validate national_id is unique
        IF EXISTS (SELECT 1 FROM Employee WHERE national_id = @NationalID)
        BEGIN
            RAISERROR('National ID already exists.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- Generate new EmployeeID
        DECLARE @NewEmployeeID INT;
        SET @NewEmployeeID = (SELECT ISNULL(MAX(EmployeeID), 0) + 1 FROM Employee);
        
        -- Insert employee record
        INSERT INTO Employee (
            EmployeeID, first_name, last_name, national_id, date_of_birth, 
            country_of_birth, phone, email, hire_date, is_active, 
            employment_status, account_status, profile_completion_percentage
        )
        VALUES (
            @NewEmployeeID, @FirstName, @LastName, @NationalID, @DateOfBirth,
            @CountryOfBirth, @Phone, @Email, @HireDate, 1,
            'Active', 'Active', 0
        );
        
        -- Link employee to role
        INSERT INTO EmployeeRole (employee_id, role_id, assigned_date)
        VALUES (@NewEmployeeID, @RoleID, GETDATE());
        
        -- Note: Department linking is done via direct column, not separate table
        -- Update employee with department
        UPDATE Employee
        SET department_id = @DepartmentID
        WHERE EmployeeID = @NewEmployeeID;
        
        COMMIT TRANSACTION;
        
        SELECT 'Employee profile created successfully!' AS ConfirmationMessage,
               @NewEmployeeID AS NewEmployeeID;
               
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END;
GO

--------------------------------------------------------
--12 (FIXED) - Update employee profile
--------------------------------------------------------
IF OBJECT_ID('UpdateEmployeeProfile', 'P') IS NOT NULL
    DROP PROCEDURE UpdateEmployeeProfile;
GO

CREATE OR ALTER PROCEDURE UpdateEmployeeProfile
    @EmployeeID INT,
    @FieldName VARCHAR(50),
    @NewValue VARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validate employee exists
    IF NOT EXISTS (SELECT 1 FROM Employee WHERE EmployeeID = @EmployeeID)
    BEGIN
        RAISERROR('Employee not found.', 16, 1);
        RETURN;
    END
    
    -- Update based on field name
    IF @FieldName = 'email'
    BEGIN
        -- Validate email uniqueness
        IF EXISTS (SELECT 1 FROM Employee WHERE email = @NewValue AND EmployeeID != @EmployeeID)
        BEGIN
            RAISERROR('Email already exists for another employee.', 16, 1);
            RETURN;
        END
        UPDATE Employee SET email = @NewValue WHERE EmployeeID = @EmployeeID;
    END
    ELSE IF @FieldName = 'phone'
        UPDATE Employee SET phone = @NewValue WHERE EmployeeID = @EmployeeID;
    ELSE IF @FieldName = 'address'
        UPDATE Employee SET address = @NewValue WHERE EmployeeID = @EmployeeID;
    ELSE IF @FieldName = 'employment_status'
        UPDATE Employee SET employment_status = @NewValue WHERE EmployeeID = @EmployeeID;
    ELSE IF @FieldName = 'emergency_contact_phone'
        UPDATE Employee SET emergency_contact_phone = @NewValue WHERE EmployeeID = @EmployeeID;
    ELSE IF @FieldName = 'emergency_contact_name'
        UPDATE Employee SET emergency_contact_name = @NewValue WHERE EmployeeID = @EmployeeID;
    ELSE IF @FieldName = 'is_active'
        UPDATE Employee SET is_active = CASE WHEN @NewValue = '1' THEN 1 ELSE 0 END WHERE EmployeeID = @EmployeeID;
    ELSE IF @FieldName = 'profile_completion'
    BEGIN
        DECLARE @Percentage INT = CAST(@NewValue AS INT);
        IF @Percentage < 0 OR @Percentage > 100
        BEGIN
            RAISERROR('Profile completion percentage must be between 0 and 100.', 16, 1);
            RETURN;
        END
        UPDATE Employee SET profile_completion_percentage = @Percentage WHERE EmployeeID = @EmployeeID;
    END
    ELSE IF @FieldName = 'account_status'
        UPDATE Employee SET account_status = @NewValue WHERE EmployeeID = @EmployeeID;
    ELSE IF @FieldName = 'employment_progress'
        UPDATE Employee SET employment_progress = @NewValue WHERE EmployeeID = @EmployeeID;
    ELSE IF @FieldName = 'relationship'
        UPDATE Employee SET relationship = @NewValue WHERE EmployeeID = @EmployeeID;
    ELSE IF @FieldName = 'biography'
        UPDATE Employee SET biography = @NewValue WHERE EmployeeID = @EmployeeID;
    ELSE
    BEGIN
        RAISERROR('Invalid FieldName provided.', 16, 1);
        RETURN;
    END
    
    SELECT 'Employee profile updated successfully!' AS ConfirmationMessage;
END;
GO

--------------------------------------------------------
--13 (FIXED) - Set profile completeness
--------------------------------------------------------
IF OBJECT_ID('SetProfileCompleteness', 'P') IS NOT NULL
    DROP PROCEDURE SetProfileCompleteness;
GO

CREATE OR ALTER PROCEDURE SetProfileCompleteness
    @EmployeeID INT, 
    @CompletenessPercentage INT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Check if the completeness percentage is valid (between 0 and 100)
    IF @CompletenessPercentage < 0 OR @CompletenessPercentage > 100
    BEGIN
        RAISERROR('Invalid percentage. It must be between 0 and 100.', 16, 1);
        RETURN;
    END

    -- Update the employee profile completion in the Employee table
    UPDATE Employee
    SET profile_completion_percentage = @CompletenessPercentage
    WHERE EmployeeID = @EmployeeID;

    -- Validate employee exists
    IF NOT EXISTS (SELECT 1 FROM Employee WHERE EmployeeID = @EmployeeID)
    BEGIN
        RAISERROR('Employee ID not found or invalid.', 16, 1);
        RETURN;
    END

    -- Update the employee profile completion in the Employee table
    UPDATE Employee
    SET profile_completion_percentage = @CompletenessPercentage
    WHERE EmployeeID = @EmployeeID;

    -- Return a confirmation message
    SELECT 'Profile completeness updated successfully.' AS ConfirmationMessage,
           @EmployeeID AS EmployeeID,
           @CompletenessPercentage AS NewCompletenessPercentage;
END;
GO

---------------------------------------------------------
--14 (FIXED) - Generate profile report
---------------------------------------------------------
IF OBJECT_ID('GenerateProfileReport', 'P') IS NOT NULL
    DROP PROCEDURE GenerateProfileReport;
GO

CREATE OR ALTER PROCEDURE GenerateProfileReport
    @FilterField VARCHAR(50), 
    @FilterValue VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validate filter field
    IF @FilterField NOT IN ('department', 'position', 'employment_status', 'hire_date')
    BEGIN
        RAISERROR('Invalid filter field. Please use: department, position, employment_status, hire_date.', 16, 1);
        RETURN;
    END
    
    -- Apply filter and return results
    IF @FilterField = 'department'
    BEGIN
        -- Validate department exists
        IF NOT EXISTS (SELECT 1 FROM Department WHERE DepartmentID = TRY_CAST(@FilterValue AS INT))
        BEGIN
            RAISERROR('Department not found.', 16, 1);
            RETURN;
        END
        
        SELECT 
            e.EmployeeID,
            e.full_name,
            e.national_id,
            e.email,
            d.department_name,
            p.position_title,
            e.employment_status,
            e.hire_date
        FROM Employee e
        LEFT JOIN Department d ON e.department_id = d.DepartmentID
        LEFT JOIN Position p ON e.position_id = p.PositionID
        WHERE e.department_id = TRY_CAST(@FilterValue AS INT);
    END
    ELSE IF @FilterField = 'position'
    BEGIN
        -- Validate position exists
        IF NOT EXISTS (SELECT 1 FROM Position WHERE PositionID = TRY_CAST(@FilterValue AS INT))
        BEGIN
            RAISERROR('Position not found.', 16, 1);
            RETURN;
        END
        
        SELECT 
            e.EmployeeID,
            e.full_name,
            e.national_id,
            e.email,
            d.department_name,
            p.position_title,
            e.employment_status,
            e.hire_date
        FROM Employee e
        LEFT JOIN Department d ON e.department_id = d.DepartmentID
        LEFT JOIN Position p ON e.position_id = p.PositionID
        WHERE e.position_id = TRY_CAST(@FilterValue AS INT);
    END
    ELSE IF @FilterField = 'employment_status'
    BEGIN
        SELECT 
            e.EmployeeID,
            e.full_name,
            e.national_id,
            e.email,
            d.department_name,
            p.position_title,
            e.employment_status,
            e.hire_date
        FROM Employee e
        LEFT JOIN Department d ON e.department_id = d.DepartmentID
        LEFT JOIN Position p ON e.position_id = p.PositionID
        WHERE e.employment_status = @FilterValue;
    END
    ELSE IF @FilterField = 'hire_date'
    BEGIN
        SELECT 
            e.EmployeeID,
            e.full_name,
            e.national_id,
            e.email,
            d.department_name,
            p.position_title,
            e.employment_status,
            e.hire_date
        FROM Employee e
        LEFT JOIN Department d ON e.department_id = d.DepartmentID
        LEFT JOIN Position p ON e.position_id = p.PositionID
        WHERE CAST(e.hire_date AS DATE) = TRY_CAST(@FilterValue AS DATE);
    END

    -- Check if any records were returned
    IF @@ROWCOUNT = 0
    BEGIN
        PRINT 'No records found for the given filter.';
    END
END;
GO


--------------------------------------------------------------
--15 CreateShiftType (NEW)
--------------------------------------------------------------
IF OBJECT_ID('CreateShiftType', 'P') IS NOT NULL
    DROP PROCEDURE CreateShiftType;
GO

CREATE OR ALTER PROCEDURE CreateShiftType
    @ShiftID INT,
    @Name VARCHAR(100),
    @Type VARCHAR(50),
    @Start_Time TIME,
    @End_Time TIME,
    @Break_Duration INT,
    @Shift_Date DATE,
    @Status VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validate shift type
        IF @Type NOT IN ('Normal', 'Split', 'Overnight', 'Mission', 'Flexible')
        BEGIN
            RAISERROR('Invalid shift type. Must be: Normal, Split, Overnight, Mission, or Flexible.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- Validate times
        IF @Start_Time IS NULL OR @End_Time IS NULL
        BEGIN
            RAISERROR('Start time and end time cannot be NULL.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- Validate break duration
        IF @Break_Duration < 0
        BEGIN
            RAISERROR('Break duration cannot be negative.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- Validate status
        IF @Status NOT IN ('Active', 'Inactive', 'Pending')
        BEGIN
            RAISERROR('Invalid status. Must be: Active, Inactive, or Pending.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- Check if shift ID already exists
        IF EXISTS (SELECT 1 FROM Shift WHERE ShiftID = @ShiftID)
        BEGIN
            RAISERROR('Shift ID already exists.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- Insert shift
        INSERT INTO Shift (ShiftID, shift_name, shift_type, start_time, end_time, break_duration, shift_date, status)
        VALUES (@ShiftID, @Name, @Type, @Start_Time, @End_Time, @Break_Duration, @Shift_Date, @Status);
        
        COMMIT TRANSACTION;
        
        SELECT 'Shift type created successfully.' AS ConfirmationMessage,
               @ShiftID AS ShiftID,
               @Name AS ShiftName,
               @Type AS ShiftType;
               
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END;
GO

--------------------------------------------------------------
--16 AssignRotationalShift (NEW)
--------------------------------------------------------------
IF OBJECT_ID('AssignRotationalShift', 'P') IS NOT NULL
    DROP PROCEDURE AssignRotationalShift;
GO

CREATE OR ALTER PROCEDURE AssignRotationalShift
    @EmployeeID INT,
    @ShiftCycle INT,
    @StartDate DATE,
    @EndDate DATE,
    @Status VARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validate employee exists
        IF NOT EXISTS (SELECT 1 FROM Employee WHERE EmployeeID = @EmployeeID)
        BEGIN
            RAISERROR('Employee not found.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- Validate date range
        IF @StartDate > @EndDate
        BEGIN
            RAISERROR('Start date cannot be after end date.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- Validate shift cycle
        IF @ShiftCycle <= 0
        BEGIN
            RAISERROR('Shift cycle must be a positive number (days in cycle).', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- Validate status
        IF @Status NOT IN ('Active', 'Inactive', 'Pending', 'Completed')
        BEGIN
            RAISERROR('Invalid status. Must be: Active, Inactive, Pending, or Completed.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- Check for overlapping assignments
        IF EXISTS (
            SELECT 1 
            FROM ShiftAssignment sa
            WHERE sa.employee_id = @EmployeeID
            AND sa.status = 'Active'
            AND (
                (@StartDate BETWEEN sa.start_date AND sa.end_date)
                OR (@EndDate BETWEEN sa.start_date AND sa.end_date)
                OR (sa.start_date BETWEEN @StartDate AND @EndDate)
            )
        )
        BEGIN
            RAISERROR('Employee already has an active shift assignment overlapping with this date range.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- Generate new assignment ID
        DECLARE @NewAssignmentID INT;
        SET @NewAssignmentID = (SELECT ISNULL(MAX(AssignmentID), 0) + 1 FROM ShiftAssignment);
        
        -- Insert rotational shift assignment
        INSERT INTO ShiftAssignment (AssignmentID, employee_id, shift_cycle_days, start_date, end_date, status)
        VALUES (@NewAssignmentID, @EmployeeID, @ShiftCycle, @StartDate, @EndDate, @Status);
        
        -- Create notification for employee
        INSERT INTO Notification (mesage_content, timestamp, urgency, read_status, notification_type)
        VALUES (
            CONCAT('Rotational Shift Assignment: You have been assigned to a ', @ShiftCycle, 
                   '-day rotational shift cycle from ', CONVERT(VARCHAR(10), @StartDate, 120), 
                   ' to ', CONVERT(VARCHAR(10), @EndDate, 120)),
            GETDATE(),
            'MEDIUM',
            0,
            'Shift Assignment'
        );
        
        DECLARE @NotificationID INT = SCOPE_IDENTITY();
        
        INSERT INTO EmployeeNotification (employee_id, notification_id, delivery_status, delivered_at)
        VALUES (@EmployeeID, @NotificationID, 'PENDING', GETDATE());
        
        COMMIT TRANSACTION;
        
        SELECT 'Rotational shift assigned successfully.' AS ConfirmationMessage,
               @NewAssignmentID AS AssignmentID,
               @EmployeeID AS EmployeeID,
               @ShiftCycle AS ShiftCycleDays,
               @StartDate AS StartDate,
               @EndDate AS EndDate;
               
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END;
GO

-- 17 Does not exist

--------------------------------------------------------------
--18 NotifyShiftExpiry (NEW)
--------------------------------------------------------------
IF OBJECT_ID('NotifyShiftExpiry', 'P') IS NOT NULL
    DROP PROCEDURE NotifyShiftExpiry;
GO

CREATE OR ALTER PROCEDURE NotifyShiftExpiry
    @EmployeeID INT,
    @ShiftAssignmentID INT,
    @ExpiryDate DATE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validate employee exists
    IF NOT EXISTS (SELECT 1 FROM Employee WHERE EmployeeID = @EmployeeID)
    BEGIN
        RAISERROR('Employee not found.', 16, 1);
        RETURN;
    END
    
    -- Validate shift assignment exists
    IF NOT EXISTS (SELECT 1 FROM ShiftAssignment WHERE AssignmentID = @ShiftAssignmentID)
    BEGIN
        RAISERROR('Shift assignment not found.', 16, 1);
        RETURN;
    END
    
    -- Validate assignment belongs to employee
    IF NOT EXISTS (
        SELECT 1 FROM ShiftAssignment 
        WHERE AssignmentID = @ShiftAssignmentID AND employee_id = @EmployeeID
    )
    BEGIN
        RAISERROR('Shift assignment does not belong to this employee.', 16, 1);
        RETURN;
    END
    
    -- Calculate days until expiry
    DECLARE @DaysUntilExpiry INT = DATEDIFF(DAY, GETDATE(), @ExpiryDate);
    
    -- Determine urgency based on days remaining
    DECLARE @Urgency VARCHAR(20);
    IF @DaysUntilExpiry <= 3
        SET @Urgency = 'CRITICAL';
    ELSE IF @DaysUntilExpiry <= 7
        SET @Urgency = 'HIGH';
    ELSE
        SET @Urgency = 'MEDIUM';
    
    -- Create notification
    INSERT INTO Notification (mesage_content, timestamp, urgency, read_status, notification_type)
    VALUES (
        CONCAT('Shift Assignment Expiry Alert: Your shift assignment (ID: ', @ShiftAssignmentID, 
               ') will expire on ', CONVERT(VARCHAR(10), @ExpiryDate, 120), 
               ' (', @DaysUntilExpiry, ' days remaining). Please contact your manager for renewal.'),
        GETDATE(),
        @Urgency,
        0,
        'Shift Expiry'
    );
    
    DECLARE @NotificationID INT = SCOPE_IDENTITY();
    
    -- Send notification to employee
    INSERT INTO EmployeeNotification (employee_id, notification_id, delivery_status, delivered_at)
    VALUES (@EmployeeID, @NotificationID, 'PENDING', GETDATE());
    
    -- Also notify the employee's manager
    DECLARE @ManagerID INT;
    SELECT @ManagerID = manager_id FROM Employee WHERE EmployeeID = @EmployeeID;
    
    IF @ManagerID IS NOT NULL
    BEGIN
        INSERT INTO EmployeeNotification (employee_id, notification_id, delivery_status, delivered_at)
        VALUES (@ManagerID, @NotificationID, 'PENDING', GETDATE());
    END
    
    SELECT 'Shift expiry notification sent successfully.' AS ConfirmationMessage,
           @EmployeeID AS EmployeeID,
           @ShiftAssignmentID AS ShiftAssignmentID,
           @ExpiryDate AS ExpiryDate,
           @DaysUntilExpiry AS DaysRemaining,
           @Urgency AS Urgency;
END;
GO

--------------------------------------------------------------
--19 DefineShortTimeRules (NEW)
--------------------------------------------------------------
IF OBJECT_ID('DefineShortTimeRules', 'P') IS NOT NULL
    DROP PROCEDURE DefineShortTimeRules;
GO

CREATE OR ALTER PROCEDURE DefineShortTimeRules
    @RuleName VARCHAR(50),
    @LateMinutes INT,
    @EarlyLeaveMinutes INT,
    @PenaltyType VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validate rule name is not empty
        IF @RuleName IS NULL OR LTRIM(RTRIM(@RuleName)) = ''
        BEGIN
            RAISERROR('Rule name cannot be empty.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- Validate minutes are non-negative
        IF @LateMinutes < 0 OR @EarlyLeaveMinutes < 0
        BEGIN
            RAISERROR('Minutes cannot be negative.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- Validate penalty type
        IF @PenaltyType NOT IN ('Warning', 'Deduction', 'Half-Day', 'Full-Day', 'None')
        BEGIN
            RAISERROR('Invalid penalty type. Must be: Warning, Deduction, Half-Day, Full-Day, or None.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- Check if rule already exists
        IF EXISTS (SELECT 1 FROM AttendancePolicy WHERE policy_name = @RuleName)
        BEGIN
            RAISERROR('A rule with this name already exists.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- Generate new policy ID
        DECLARE @NewPolicyID INT;
        SET @NewPolicyID = (SELECT ISNULL(MAX(PolicyID), 0) + 1 FROM AttendancePolicy);
        
        -- Insert short time rule
        INSERT INTO AttendancePolicy (PolicyID, policy_name, policy_type, description, parameters, effective_date, status)
        VALUES (
            @NewPolicyID,
            @RuleName,
            'Short Time',
            CONCAT('Late: ', @LateMinutes, ' mins, Early Leave: ', @EarlyLeaveMinutes, ' mins, Penalty: ', @PenaltyType),
            CONCAT('{"late_minutes":', @LateMinutes, ',"early_leave_minutes":', @EarlyLeaveMinutes, ',"penalty_type":"', @PenaltyType, '"}'),
            GETDATE(),
            'Active'
        );
        
        COMMIT TRANSACTION;
        
        SELECT 'Short time rule defined successfully.' AS ConfirmationMessage,
               @NewPolicyID AS PolicyID,
               @RuleName AS RuleName,
               @LateMinutes AS LateMinutes,
               @EarlyLeaveMinutes AS EarlyLeaveMinutes,
               @PenaltyType AS PenaltyType;
               
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END;
GO

--------------------------------------------------------------
--20 SetGracePeriod (NEW)
--------------------------------------------------------------
IF OBJECT_ID('SetGracePeriod', 'P') IS NOT NULL
    DROP PROCEDURE SetGracePeriod;
GO

CREATE OR ALTER PROCEDURE SetGracePeriod
    @Minutes INT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validate minutes
        IF @Minutes < 0
        BEGIN
            RAISERROR('Grace period minutes cannot be negative.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        IF @Minutes > 60
        BEGIN
            RAISERROR('Grace period cannot exceed 60 minutes.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- Check if grace period policy exists
        IF EXISTS (SELECT 1 FROM AttendancePolicy WHERE policy_name = 'Grace Period')
        BEGIN
            -- Update existing grace period
            UPDATE AttendancePolicy
            SET description = CONCAT('Grace period: ', @Minutes, ' minutes'),
                parameters = CONCAT('{"grace_minutes":', @Minutes, '}'),
                effective_date = GETDATE()
            WHERE policy_name = 'Grace Period';
            
            SELECT 'Grace period updated successfully.' AS ConfirmationMessage,
                   @Minutes AS GracePeriodMinutes;
        END
        ELSE
        BEGIN
            -- Create new grace period policy
            DECLARE @NewPolicyID INT;
            SET @NewPolicyID = (SELECT ISNULL(MAX(PolicyID), 0) + 1 FROM AttendancePolicy);
            
            INSERT INTO AttendancePolicy (PolicyID, policy_name, policy_type, description, parameters, effective_date, status)
            VALUES (
                @NewPolicyID,
                'Grace Period',
                'Attendance',
                CONCAT('Grace period: ', @Minutes, ' minutes'),
                CONCAT('{"grace_minutes":', @Minutes, '}'),
                GETDATE(),
                'Active'
            );
            
            SELECT 'Grace period set successfully.' AS ConfirmationMessage,
                   @Minutes AS GracePeriodMinutes,
                   @NewPolicyID AS PolicyID;
        END
        
        COMMIT TRANSACTION;
               
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END;
GO

--------------------------------------------------------------
--21 DefinePenaltyThreshold (NEW)
--------------------------------------------------------------
IF OBJECT_ID('DefinePenaltyThreshold', 'P') IS NOT NULL
    DROP PROCEDURE DefinePenaltyThreshold;
GO

CREATE OR ALTER PROCEDURE DefinePenaltyThreshold
    @LateMinutes INT,
    @DeductionType VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validate minutes
        IF @LateMinutes <= 0
        BEGIN
            RAISERROR('Late minutes must be a positive number.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- Validate deduction type
        IF @DeductionType NOT IN ('Warning', 'Hourly', 'Quarter-Day', 'Half-Day', 'Full-Day')
        BEGIN
            RAISERROR('Invalid deduction type. Must be: Warning, Hourly, Quarter-Day, Half-Day, or Full-Day.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- Generate policy name
        DECLARE @PolicyName VARCHAR(100);
        SET @PolicyName = CONCAT('Penalty Threshold - ', @LateMinutes, ' mins');
        
        -- Check if threshold already exists
        IF EXISTS (SELECT 1 FROM AttendancePolicy WHERE policy_name = @PolicyName)
        BEGIN
            RAISERROR('A penalty threshold for this lateness duration already exists.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- Generate new policy ID
        DECLARE @NewPolicyID INT;
        SET @NewPolicyID = (SELECT ISNULL(MAX(PolicyID), 0) + 1 FROM AttendancePolicy);
        
        -- Insert penalty threshold
        INSERT INTO AttendancePolicy (PolicyID, policy_name, policy_type, description, parameters, effective_date, status)
        VALUES (
            @NewPolicyID,
            @PolicyName,
            'Penalty Threshold',
            CONCAT('Late by ', @LateMinutes, ' minutes = ', @DeductionType, ' deduction'),
            CONCAT('{"late_minutes":', @LateMinutes, ',"deduction_type":"', @DeductionType, '"}'),
            GETDATE(),
            'Active'
        );
        
        COMMIT TRANSACTION;
        
        SELECT 'Penalty threshold defined successfully.' AS ConfirmationMessage,
               @NewPolicyID AS PolicyID,
               @LateMinutes AS LateMinutes,
               @DeductionType AS DeductionType;
               
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END;
GO

--------------------------------------------------------------
--22 DefinePermissionLimits (NEW)
--------------------------------------------------------------
IF OBJECT_ID('DefinePermissionLimits', 'P') IS NOT NULL
    DROP PROCEDURE DefinePermissionLimits;
GO

CREATE OR ALTER PROCEDURE DefinePermissionLimits
    @MinHours INT,
    @MaxHours INT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validate hours
        IF @MinHours < 0 OR @MaxHours < 0
        BEGIN
            RAISERROR('Hours cannot be negative.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        IF @MinHours > @MaxHours
        BEGIN
            RAISERROR('Minimum hours cannot exceed maximum hours.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        IF @MaxHours > 24
        BEGIN
            RAISERROR('Maximum hours cannot exceed 24.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- Check if permission limits policy exists
        IF EXISTS (SELECT 1 FROM AttendancePolicy WHERE policy_name = 'Permission Limits')
        BEGIN
            -- Update existing policy
            UPDATE AttendancePolicy
            SET description = CONCAT('Permission hours: Min ', @MinHours, ' hrs, Max ', @MaxHours, ' hrs'),
                parameters = CONCAT('{"min_hours":', @MinHours, ',"max_hours":', @MaxHours, '}'),
                effective_date = GETDATE()
            WHERE policy_name = 'Permission Limits';
            
            SELECT 'Permission limits updated successfully.' AS ConfirmationMessage,
                   @MinHours AS MinimumHours,
                   @MaxHours AS MaximumHours;
        END
        ELSE
        BEGIN
            -- Create new permission limits policy
            DECLARE @NewPolicyID INT;
            SET @NewPolicyID = (SELECT ISNULL(MAX(PolicyID), 0) + 1 FROM AttendancePolicy);
            
            INSERT INTO AttendancePolicy (PolicyID, policy_name, policy_type, description, parameters, effective_date, status)
            VALUES (
                @NewPolicyID,
                'Permission Limits',
                'Permission',
                CONCAT('Permission hours: Min ', @MinHours, ' hrs, Max ', @MaxHours, ' hrs'),
                CONCAT('{"min_hours":', @MinHours, ',"max_hours":', @MaxHours, '}'),
                GETDATE(),
                'Active'
            );
            
            SELECT 'Permission limits defined successfully.' AS ConfirmationMessage,
                   @MinHours AS MinimumHours,
                   @MaxHours AS MaximumHours,
                   @NewPolicyID AS PolicyID;
        END
        
        COMMIT TRANSACTION;
               
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END;
GO
--------------------------------------------------------------
--23 (NEW) - Escalate pending requests
--------------------------------------------------------------
IF OBJECT_ID('EscalatePendingRequests', 'P') IS NOT NULL
    DROP PROCEDURE EscalatePendingRequests;
GO

CREATE OR ALTER PROCEDURE EscalatePendingRequests
    @Deadline DATETIME
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validate deadline is in the past
    IF @Deadline > GETDATE()
    BEGIN
        RAISERROR('Deadline must be in the past to escalate pending requests.', 16, 1);
        RETURN;
    END
    
    DECLARE @EscalatedCount INT = 0;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Find pending leave requests past deadline
        CREATE TABLE #PendingRequests (
            RequestID INT,
            EmployeeID INT,
            ManagerID INT,
            LeaveType VARCHAR(100),
            RequestDate DATETIME
        );
        
        INSERT INTO #PendingRequests
        SELECT 
            lr.RequestID,
            lr.employee_id,
            e.manager_id,
            l.leave_type,
            lr.approval_timing
        FROM LeaveRequest lr
        INNER JOIN Employee e ON lr.employee_id = e.EmployeeID
        INNER JOIN Leave l ON lr.leave_id = l.LeaveID
        WHERE lr.status = 'PENDING'
        AND lr.approval_timing < @Deadline
        AND e.manager_id IS NOT NULL;
        
        SET @EscalatedCount = @@ROWCOUNT;
        
        -- Create notifications for department heads about escalated requests
        IF @EscalatedCount > 0
        BEGIN
            -- Create notification
            INSERT INTO Notification (mesage_content, timestamp, urgency, read_status, notification_type)
            VALUES (
                CONCAT('ESCALATION: ', @EscalatedCount, ' leave requests pending beyond deadline (', 
                       CONVERT(VARCHAR(20), @Deadline, 120), '). Immediate attention required.'),
                GETDATE(),
                'CRITICAL',
                0,
                'Escalation'
            );
            
            DECLARE @NotificationID INT = SCOPE_IDENTITY();
            
            -- Notify HR Administrators
            INSERT INTO EmployeeNotification (employee_id, notification_id, delivery_status, delivered_at)
            SELECT DISTINCT employee_id, @NotificationID, 'PENDING', GETDATE()
            FROM HRAdministrator;
            
            -- Notify all managers involved
            INSERT INTO EmployeeNotification (employee_id, notification_id, delivery_status, delivered_at)
            SELECT DISTINCT ManagerID, @NotificationID, 'PENDING', GETDATE()
            FROM #PendingRequests
            WHERE ManagerID IS NOT NULL;
        END
        
        -- Clean up
        DROP TABLE #PendingRequests;
        
        COMMIT TRANSACTION;
        
        SELECT CONCAT('Escalated ', @EscalatedCount, ' pending leave requests beyond deadline.') AS ConfirmationMessage,
               @EscalatedCount AS EscalatedCount,
               @Deadline AS Deadline,
               GETDATE() AS EscalatedAt;
               
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END;
GO


--------------------------------------------------------------
--24 LinkVacationToShift (NEW)
--------------------------------------------------------------
IF OBJECT_ID('LinkVacationToShift', 'P') IS NOT NULL
    DROP PROCEDURE LinkVacationToShift;
GO

CREATE OR ALTER PROCEDURE LinkVacationToShift
    @VacationPackageID INT,
    @EmployeeID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validate employee exists
        IF NOT EXISTS (SELECT 1 FROM Employee WHERE EmployeeID = @EmployeeID)
        BEGIN
            RAISERROR('Employee not found.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- Validate vacation package exists (assuming Leave table represents vacation packages)
        IF NOT EXISTS (SELECT 1 FROM Leave WHERE LeaveID = @VacationPackageID AND leave_type = 'Vacation')
        BEGIN
            RAISERROR('Vacation package not found.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- Check if employee has active shift assignment
        IF NOT EXISTS (
            SELECT 1 FROM ShiftAssignment 
            WHERE employee_id = @EmployeeID AND status = 'Active'
        )
        BEGIN
            RAISERROR('Employee does not have an active shift assignment.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- Check if employee has entitlement for this vacation package
        IF NOT EXISTS (
            SELECT 1 FROM LeaveEntitlement 
            WHERE employee_id = @EmployeeID AND leave_type_id = @VacationPackageID
        )
        BEGIN
            -- Create entitlement if it doesn't exist
            INSERT INTO LeaveEntitlement (employee_id, leave_type_id, entitlement)
            VALUES (@EmployeeID, @VacationPackageID, 0);
        END
        
        -- Get vacation package details
        DECLARE @PackageName VARCHAR(100);
        SELECT @PackageName = leave_type FROM Leave WHERE LeaveID = @VacationPackageID;
        
        -- Create notification
        INSERT INTO Notification (mesage_content, timestamp, urgency, read_status, notification_type)
        VALUES (
            CONCAT('Vacation Package Linked: ', @PackageName, 
                   ' (ID: ', @VacationPackageID, ') has been linked to your shift schedule.',
                   'Please ensure your shift timings are updated accordingly.'),
            GETDATE(),
            'MEDIUM',
            0,
            'Vacation Assignment'
        );
        
        DECLARE @NotificationID INT = SCOPE_IDENTITY();
        
        INSERT INTO EmployeeNotification (employee_id, notification_id, delivery_status, delivered_at)
        VALUES (@EmployeeID, @NotificationID, 'PENDING', GETDATE());
        
        COMMIT TRANSACTION;
        
        SELECT 'Vacation package linked to shift successfully.' AS ConfirmationMessage,
               @VacationPackageID AS VacationPackageID,
               @PackageName AS PackageName,
               @EmployeeID AS EmployeeID;
               
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END;
GO


--------------------------------------------------------------
--25 ConfigureLeavePolicies (NEW)
--------------------------------------------------------------
IF OBJECT_ID('ConfigureLeavePolicies', 'P') IS NOT NULL
    DROP PROCEDURE ConfigureLeavePolicies;
GO

CREATE OR ALTER PROCEDURE ConfigureLeavePolicies
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @ConfigCount INT = 0;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Check if base leave policies already exist
        IF EXISTS (SELECT 1 FROM LeavePolicy WHERE name = 'Base Leave Configuration')
        BEGIN
            RAISERROR('Leave policies have already been configured. Use UpdateLeavePolicy to modify existing policies.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- Create base leave policy configuration
        INSERT INTO LeavePolicy (PolicyID, name, purpose, eligibility_rules, notice_period, reset_on_new_year)
        VALUES (
            (SELECT ISNULL(MAX(PolicyID), 0) + 1 FROM LeavePolicy),
            'Base Leave Configuration',
            'Foundation configuration for all leave types',
            'Default eligibility: All active employees with contracts',
            0,
            1
        );
        
        SET @ConfigCount = @ConfigCount + 1;
        
        -- Create standard leave types if they don't exist
        IF NOT EXISTS (SELECT 1 FROM Leave WHERE leave_type = 'Vacation')
        BEGIN
            INSERT INTO Leave (LeaveID, leave_type, leave_description)
            VALUES (
                (SELECT ISNULL(MAX(LeaveID), 0) + 1 FROM Leave),
                'Vacation',
                'Annual vacation leave for all employees'
            );
            
            -- Add vacation leave specific configuration
            DECLARE @VacationLeaveID INT = (SELECT LeaveID FROM Leave WHERE leave_type = 'Vacation');
            
            INSERT INTO VacationLeave (leave_id, carry_over_days, approving_manager)
            VALUES (@VacationLeaveID, 5, 'Line Manager');
            
            SET @ConfigCount = @ConfigCount + 1;
        END
        
        IF NOT EXISTS (SELECT 1 FROM Leave WHERE leave_type = 'Sick')
        BEGIN
            INSERT INTO Leave (LeaveID, leave_type, leave_description)
            VALUES (
                (SELECT ISNULL(MAX(LeaveID), 0) + 1 FROM Leave),
                'Sick',
                'Medical leave for illness or injury'
            );
            
            -- Add sick leave specific configuration
            DECLARE @SickLeaveID INT = (SELECT LeaveID FROM Leave WHERE leave_type = 'Sick');
            
            INSERT INTO SickLeave (leave_id, medical_certificate_required, physician_id)
            VALUES (@SickLeaveID, 1, NULL);
            
            SET @ConfigCount = @ConfigCount + 1;
        END
        
        IF NOT EXISTS (SELECT 1 FROM Leave WHERE leave_type = 'Emergency')
        BEGIN
            INSERT INTO Leave (LeaveID, leave_type, leave_description)
            VALUES (
                (SELECT ISNULL(MAX(LeaveID), 0) + 1 FROM Leave),
                'Emergency',
                'Emergency leave for unforeseen circumstances'
            );
            
            SET @ConfigCount = @ConfigCount + 1;
        END
        
        -- Create default leave policies for each type
        INSERT INTO LeavePolicy (PolicyID, name, purpose, eligibility_rules, notice_period)
        VALUES (
            (SELECT ISNULL(MAX(PolicyID), 0) + 1 FROM LeavePolicy),
            'Vacation Leave Policy',
            'Standard vacation leave rules',
            'Eligible after probation period (3 months)',
            7
        );
        
        INSERT INTO LeavePolicy (PolicyID, name, purpose, eligibility_rules, notice_period)
        VALUES (
            (SELECT ISNULL(MAX(PolicyID), 0) + 1 FROM LeavePolicy),
            'Sick Leave Policy',
            'Medical leave rules',
            'All employees eligible. Medical certificate required for >3 days',
            0
        );
        
        INSERT INTO LeavePolicy (PolicyID, name, purpose, eligibility_rules, notice_period)
        VALUES (
            (SELECT ISNULL(MAX(PolicyID), 0) + 1 FROM LeavePolicy),
            'Emergency Leave Policy',
            'Emergency leave rules',
            'All employees eligible. Approval required within 24 hours',
            0
        );
        
        SET @ConfigCount = @ConfigCount + 3;
        
        -- Create notification for HR Administrators
        INSERT INTO Notification (mesage_content, timestamp, urgency, read_status, notification_type)
        VALUES (
            CONCAT('Leave policies have been initialized. ', @ConfigCount, ' policies configured. ',
                   'Review and customize policies as needed.'),
            GETDATE(),
            'HIGH',
            0,
            'System Configuration'
        );
        
        DECLARE @NotificationID INT = SCOPE_IDENTITY();
        
        -- Notify all HR Administrators
        INSERT INTO EmployeeNotification (employee_id, notification_id, delivery_status, delivered_at)
        SELECT employee_id, @NotificationID, 'PENDING', GETDATE()
        FROM HRAdministrator;
        
        COMMIT TRANSACTION;
        
        SELECT 'Leave policies configured successfully.' AS ConfirmationMessage,
               @ConfigCount AS PoliciesConfigured,
               GETDATE() AS ConfiguredAt;
               
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END;
GO


--------------------------------------------------------------
--26 (NEW) - Authenticate leave admin
--------------------------------------------------------------
IF OBJECT_ID('AuthenticateLeaveAdmin', 'P') IS NOT NULL
    DROP PROCEDURE AuthenticateLeaveAdmin;
GO

CREATE OR ALTER PROCEDURE AuthenticateLeaveAdmin
    @AdminID INT,
    @Password VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validate admin exists
    IF NOT EXISTS (SELECT 1 FROM Employee WHERE EmployeeID = @AdminID)
    BEGIN
        RAISERROR('Admin ID not found.', 16, 1);
        RETURN;
    END
    
    -- Check if admin is HR Administrator
    IF NOT EXISTS (SELECT 1 FROM HRAdministrator WHERE employee_id = @AdminID)
    BEGIN
        RAISERROR('User is not an HR Administrator.', 16, 1);
        RETURN;
    END
    
    -- Validate password (simplified - in production, use hashed passwords)
    -- For this implementation, we'll assume password validation logic exists
    -- Since there's no password column, we'll check authorization level
    DECLARE @ApprovalLevel VARCHAR(50);
    DECLARE @ValidationRights BIT;
    
    SELECT 
        @ApprovalLevel = approval_level,
        @ValidationRights = document_validation_rights
    FROM HRAdministrator
    WHERE employee_id = @AdminID;
    
    -- Check if admin has sufficient privileges for leave management
    IF @ApprovalLevel IS NULL OR @ValidationRights = 0
    BEGIN
        RAISERROR('Admin does not have sufficient privileges for leave management.', 16, 1);
        RETURN;
    END
    
    -- Log authentication attempt
    INSERT INTO Notification (mesage_content, timestamp, urgency, read_status, notification_type)
    VALUES (
        CONCAT('Leave Admin Authentication: Admin ID ', @AdminID, ' authenticated successfully.'),
        GETDATE(),
        'LOW',
        1,
        'Authentication'
    );
    
    SELECT 'Authentication successful. Leave admin privileges granted.' AS ConfirmationMessage,
           @AdminID AS AdminID,
           @ApprovalLevel AS ApprovalLevel,
           GETDATE() AS AuthenticatedAt;
END;
GO


--------------------------------------------------------------
--27 ApplyLeaveConfiguration (NEW)
--------------------------------------------------------------
IF OBJECT_ID('ApplyLeaveConfiguration', 'P') IS NOT NULL
    DROP PROCEDURE ApplyLeaveConfiguration;
GO

CREATE OR ALTER PROCEDURE ApplyLeaveConfiguration
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @EmployeesProcessed INT = 0;
    DECLARE @ErrorCount INT = 0;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validate that leave policies exist
        IF NOT EXISTS (SELECT 1 FROM LeavePolicy)
        BEGIN
            RAISERROR('No leave policies found. Please run ConfigureLeavePolicies first.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- Validate that leave types exist
        IF NOT EXISTS (SELECT 1 FROM Leave)
        BEGIN
            RAISERROR('No leave types found. Please run ConfigureLeavePolicies first.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- Apply leave entitlements to all active employees with contracts
        DECLARE @EmployeeID INT;
        DECLARE @ContractID INT;
        DECLARE @ContractType VARCHAR(50);
        
        -- Cursor to iterate through active employees
        DECLARE employee_cursor CURSOR FOR
        SELECT EmployeeID, contract_id
        FROM Employee
        WHERE is_active = 1
        AND contract_id IS NOT NULL
        AND employment_status = 'Active';
        
        OPEN employee_cursor;
        FETCH NEXT FROM employee_cursor INTO @EmployeeID, @ContractID;
        
        WHILE @@FETCH_STATUS = 0
        BEGIN
            BEGIN TRY
                -- Get contract type
                SELECT @ContractType = type FROM Contract WHERE ContractID = @ContractID;
                
                -- Set entitlements based on contract type
                DECLARE @VacationDays INT;
                DECLARE @SickDays INT;
                DECLARE @EmergencyDays INT;
                
                IF @ContractType = 'Full-Time'
                BEGIN
                    SET @VacationDays = 21;
                    SET @SickDays = 14;
                    SET @EmergencyDays = 3;
                END
                ELSE IF @ContractType = 'Part-Time'
                BEGIN
                    SET @VacationDays = 10;
                    SET @SickDays = 7;
                    SET @EmergencyDays = 2;
                END
                ELSE IF @ContractType = 'Internship'
                BEGIN
                    SET @VacationDays = 5;
                    SET @SickDays = 3;
                    SET @EmergencyDays = 1;
                END
                ELSE
                BEGIN
                    SET @VacationDays = 0;
                    SET @SickDays = 0;
                    SET @EmergencyDays = 0;
                END
                
                -- Get leave type IDs
                DECLARE @VacationLeaveID INT, @SickLeaveID INT, @EmergencyLeaveID INT;
                
                SELECT @VacationLeaveID = LeaveID FROM Leave WHERE leave_type = 'Vacation';
                SELECT @SickLeaveID = LeaveID FROM Leave WHERE leave_type = 'Sick';
                SELECT @EmergencyLeaveID = LeaveID FROM Leave WHERE leave_type = 'Emergency';
                
                -- Insert or update vacation entitlement
                IF @VacationLeaveID IS NOT NULL AND @VacationDays > 0
                BEGIN
                    IF EXISTS (SELECT 1 FROM LeaveEntitlement WHERE employee_id = @EmployeeID AND leave_type_id = @VacationLeaveID)
                    BEGIN
                        UPDATE LeaveEntitlement
                        SET entitlement = @VacationDays
                        WHERE employee_id = @EmployeeID AND leave_type_id = @VacationLeaveID;
                    END
                    ELSE
                    BEGIN
                        INSERT INTO LeaveEntitlement (employee_id, leave_type_id, entitlement)
                        VALUES (@EmployeeID, @VacationLeaveID, @VacationDays);
                    END
                END
                
                -- Insert or update sick leave entitlement
                IF @SickLeaveID IS NOT NULL AND @SickDays > 0
                BEGIN
                    IF EXISTS (SELECT 1 FROM LeaveEntitlement WHERE employee_id = @EmployeeID AND leave_type_id = @SickLeaveID)
                    BEGIN
                        UPDATE LeaveEntitlement
                        SET entitlement = @SickDays
                        WHERE employee_id = @EmployeeID AND leave_type_id = @SickLeaveID;
                    END
                    ELSE
                    BEGIN
                        INSERT INTO LeaveEntitlement (employee_id, leave_type_id, entitlement)
                        VALUES (@EmployeeID, @SickLeaveID, @SickDays);
                    END
                END
                
                -- Insert or update emergency leave entitlement
                IF @EmergencyLeaveID IS NOT NULL AND @EmergencyDays > 0
                BEGIN
                    IF EXISTS (SELECT 1 FROM LeaveEntitlement WHERE employee_id = @EmployeeID AND leave_type_id = @EmergencyLeaveID)
                    BEGIN
                        UPDATE LeaveEntitlement
                        SET entitlement = @EmergencyDays
                        WHERE employee_id = @EmployeeID AND leave_type_id = @EmergencyLeaveID;
                    END
                    ELSE
                    BEGIN
                        INSERT INTO LeaveEntitlement (employee_id, leave_type_id, entitlement)
                        VALUES (@EmployeeID, @EmergencyLeaveID, @EmergencyDays);
                    END
                END
                
                SET @EmployeesProcessed = @EmployeesProcessed + 1;
                
            END TRY
            BEGIN CATCH
                SET @ErrorCount = @ErrorCount + 1;
            END CATCH
            
            FETCH NEXT FROM employee_cursor INTO @EmployeeID, @ContractID;
        END
        
        CLOSE employee_cursor;
        DEALLOCATE employee_cursor;
        
        -- Create notification for HR Administrators
        INSERT INTO Notification (mesage_content, timestamp, urgency, read_status, notification_type)
        VALUES (
            CONCAT('Leave configuration applied to ', @EmployeesProcessed, ' employees. ',
                   'Errors: ', @ErrorCount),
            GETDATE(),
            'HIGH',
            0,
            'System Configuration'
        );
        
        DECLARE @NotificationID INT = SCOPE_IDENTITY();
        
        INSERT INTO EmployeeNotification (employee_id, notification_id, delivery_status, delivered_at)
        SELECT employee_id, @NotificationID, 'PENDING', GETDATE()
        FROM HRAdministrator;
        
        COMMIT TRANSACTION;
        
        SELECT 'Leave configuration applied successfully.' AS ConfirmationMessage,
               @EmployeesProcessed AS EmployeesProcessed,
               @ErrorCount AS ErrorCount,
               GETDATE() AS AppliedAt;
               
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END;
GO


--------------------------------------------------------------
--28 (FIXED) - Update leave entitlements
--------------------------------------------------------------
IF OBJECT_ID('UpdateLeaveEntitlements', 'P') IS NOT NULL
    DROP PROCEDURE UpdateLeaveEntitlements;
GO

CREATE OR ALTER PROCEDURE UpdateLeaveEntitlements
    @EmployeeID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validate employee exists
    IF NOT EXISTS (SELECT 1 FROM Employee WHERE EmployeeID = @EmployeeID)
    BEGIN
        RAISERROR('Employee not found.', 16, 1);
        RETURN;
    END
    
    -- Check if employee has a contract
    DECLARE @ContractID INT;
    DECLARE @ContractType VARCHAR(50);
    
    SELECT @ContractID = contract_id
    FROM Employee
    WHERE EmployeeID = @EmployeeID;
    
    IF @ContractID IS NULL
    BEGIN
        RAISERROR('Employee does not have an active contract.', 16, 1);
        RETURN;
    END
    
    -- Get contract type
    SELECT @ContractType = type
    FROM Contract
    WHERE ContractID = @ContractID;
    
    -- Calculate and update leave entitlements based on contract type
    DECLARE @AnnualLeaveEntitlement INT;
    DECLARE @SickLeaveEntitlement INT;
    
    -- Set entitlements based on contract type
    IF @ContractType = 'Full-Time'
    BEGIN
        SET @AnnualLeaveEntitlement = 21; -- Full-time gets 21 days annual leave
        SET @SickLeaveEntitlement = 14;   -- Full-time gets 14 days sick leave
    END
    ELSE IF @ContractType = 'Part-Time'
    BEGIN
        SET @AnnualLeaveEntitlement = 10; -- Part-time gets pro-rata leave
        SET @SickLeaveEntitlement = 7;
    END
    ELSE IF @ContractType = 'Consultant'
    BEGIN
        SET @AnnualLeaveEntitlement = 0;  -- Consultants typically don't get leave
        SET @SickLeaveEntitlement = 0;
    END
    ELSE IF @ContractType = 'Internship'
    BEGIN
        SET @AnnualLeaveEntitlement = 5;  -- Interns get limited leave
        SET @SickLeaveEntitlement = 3;
    END
    ELSE
    BEGIN
        SET @AnnualLeaveEntitlement = 0;
        SET @SickLeaveEntitlement = 0;
    END
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Get LeaveID for Annual Leave (Vacation)
        DECLARE @AnnualLeaveID INT;
        SELECT TOP 1 @AnnualLeaveID = LeaveID
        FROM Leave
        WHERE leave_type = 'Vacation' OR leave_type = 'Annual';
        
        -- Get LeaveID for Sick Leave
        DECLARE @SickLeaveID INT;
        SELECT TOP 1 @SickLeaveID = LeaveID
        FROM Leave
        WHERE leave_type = 'Sick';
        
        -- Update or insert Annual Leave entitlement
        IF @AnnualLeaveID IS NOT NULL AND @AnnualLeaveEntitlement > 0
        BEGIN
            IF EXISTS (SELECT 1 FROM LeaveEntitlement WHERE employee_id = @EmployeeID AND leave_type_id = @AnnualLeaveID)
            BEGIN
                UPDATE LeaveEntitlement
                SET entitlement = @AnnualLeaveEntitlement
                WHERE employee_id = @EmployeeID AND leave_type_id = @AnnualLeaveID;
            END
            ELSE
            BEGIN
                INSERT INTO LeaveEntitlement (employee_id, leave_type_id, entitlement)
                VALUES (@EmployeeID, @AnnualLeaveID, @AnnualLeaveEntitlement);
            END
        END
        
        -- Update or insert Sick Leave entitlement
        IF @SickLeaveID IS NOT NULL AND @SickLeaveEntitlement > 0
        BEGIN
            IF EXISTS (SELECT 1 FROM LeaveEntitlement WHERE employee_id = @EmployeeID AND leave_type_id = @SickLeaveID)
            BEGIN
                UPDATE LeaveEntitlement
                SET entitlement = @SickLeaveEntitlement
                WHERE employee_id = @EmployeeID AND leave_type_id = @SickLeaveID;
            END
            ELSE
            BEGIN
                INSERT INTO LeaveEntitlement (employee_id, leave_type_id, entitlement)
                VALUES (@EmployeeID, @SickLeaveID, @SickLeaveEntitlement);
            END
        END
        
        COMMIT TRANSACTION;
        
        SELECT 'Leave entitlements updated successfully.' AS ConfirmationMessage,
               @EmployeeID AS EmployeeID,
               @ContractType AS ContractType,
               @AnnualLeaveEntitlement AS AnnualLeaveDays,
               @SickLeaveEntitlement AS SickLeaveDays;
               
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END;
GO


--------------------------------------------------------------
--29 ConfigureLeaveEligibility (NEW)
--------------------------------------------------------------
IF OBJECT_ID('ConfigureLeaveEligibility', 'P') IS NOT NULL
    DROP PROCEDURE ConfigureLeaveEligibility;
GO

CREATE OR ALTER PROCEDURE ConfigureLeaveEligibility
    @LeaveType VARCHAR(50),
    @MinTenure INT,
    @EmployeeType VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validate leave type
        IF @LeaveType IS NULL OR LTRIM(RTRIM(@LeaveType)) = ''
        BEGIN
            RAISERROR('Leave type cannot be empty.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- Validate minimum tenure
        IF @MinTenure < 0
        BEGIN
            RAISERROR('Minimum tenure cannot be negative.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- Validate employee type
        IF @EmployeeType NOT IN ('Full-Time', 'Part-Time', 'Consultant', 'Internship', 'All')
        BEGIN
            RAISERROR('Invalid employee type. Must be: Full-Time, Part-Time, Consultant, Internship, or All.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- Check if leave type exists
        IF NOT EXISTS (SELECT 1 FROM Leave WHERE leave_type = @LeaveType)
        BEGIN
            RAISERROR('Leave type does not exist. Please create the leave type first.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- Create or update eligibility policy
        DECLARE @PolicyName VARCHAR(200);
        SET @PolicyName = CONCAT('Eligibility - ', @LeaveType, ' - ', @EmployeeType);
        
        IF EXISTS (SELECT 1 FROM LeavePolicy WHERE name = @PolicyName)
        BEGIN
            -- Update existing policy
            UPDATE LeavePolicy
            SET eligibility_rules = CONCAT('Min Tenure: ', @MinTenure, ' months, Employee Type: ', @EmployeeType),
                purpose = CONCAT('Eligibility rules for ', @LeaveType, ' leave')
            WHERE name = @PolicyName;
            
            SELECT 'Leave eligibility rules updated successfully.' AS ConfirmationMessage,
                   @PolicyName AS PolicyName,
                   @LeaveType AS LeaveType,
                   @MinTenure AS MinimumTenureMonths,
                   @EmployeeType AS EligibleEmployeeType,
                   'UPDATED' AS Operation;
        END
        ELSE
        BEGIN
            -- Create new eligibility policy
            DECLARE @NewPolicyID INT;
            SET @NewPolicyID = (SELECT ISNULL(MAX(PolicyID), 0) + 1 FROM LeavePolicy);
            
            INSERT INTO LeavePolicy (PolicyID, name, purpose, eligibility_rules, notice_period)
            VALUES (
                @NewPolicyID,
                @PolicyName,
                CONCAT('Eligibility rules for ', @LeaveType, ' leave'),
                CONCAT('Min Tenure: ', @MinTenure, ' months, Employee Type: ', @EmployeeType),
                0
            );
            
            SELECT 'Leave eligibility rules configured successfully.' AS ConfirmationMessage,
                   @PolicyName AS PolicyName,
                   @LeaveType AS LeaveType,
                   @MinTenure AS MinimumTenureMonths,
                   @EmployeeType AS EligibleEmployeeType,
                   @NewPolicyID AS PolicyID;
        END
        
        COMMIT TRANSACTION;
               
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END;
GO

--------------------------------------------------------------
--30 ManageLeaveTypes (NEW)
--------------------------------------------------------------
IF OBJECT_ID('ManageLeaveTypes', 'P') IS NOT NULL
    DROP PROCEDURE ManageLeaveTypes;
GO

CREATE OR ALTER PROCEDURE ManageLeaveTypes
    @LeaveType VARCHAR(50),
    @Description VARCHAR(200)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validate leave type
        IF @LeaveType IS NULL OR LTRIM(RTRIM(@LeaveType)) = ''
        BEGIN
            RAISERROR('Leave type cannot be empty.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- Validate description
        IF @Description IS NULL OR LTRIM(RTRIM(@Description)) = ''
        BEGIN
            RAISERROR('Description cannot be empty.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- Check if leave type already exists
        IF EXISTS (SELECT 1 FROM Leave WHERE leave_type = @LeaveType)
        BEGIN
            -- Update existing leave type
            UPDATE Leave
            SET leave_description = @Description
            WHERE leave_type = @LeaveType;
            
            SELECT 'Leave type updated successfully.' AS ConfirmationMessage,
                   @LeaveType AS LeaveType,
                   @Description AS Description,
                   'UPDATED' AS Operation;
        END
        ELSE
        BEGIN
            -- Create new leave type
            DECLARE @NewLeaveID INT;
            SET @NewLeaveID = (SELECT ISNULL(MAX(LeaveID), 0) + 1 FROM Leave);
            
            INSERT INTO Leave (LeaveID, leave_type, leave_description)
            VALUES (@NewLeaveID, @LeaveType, @Description);
            
            -- Create default policy for new leave type
            DECLARE @NewPolicyID INT;
            SET @NewPolicyID = (SELECT ISNULL(MAX(PolicyID), 0) + 1 FROM LeavePolicy);
            
            INSERT INTO LeavePolicy (PolicyID, name, purpose, eligibility_rules, notice_period)
            VALUES (
                @NewPolicyID,
                CONCAT(@LeaveType, ' Leave Policy'),
                CONCAT('Default policy for ', @LeaveType, ' leave'),
                'Configure eligibility rules as needed',
                7
            );
            
            SELECT 'Leave type created successfully.' AS ConfirmationMessage,
                   @LeaveType AS LeaveType,
                   @Description AS Description,
                   @NewLeaveID AS LeaveID,
                   @NewPolicyID AS PolicyID,
                   'CREATED' AS Operation;
        END
        
        COMMIT TRANSACTION;
               
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END;
GO

--------------------------------------------------------------
--31 AssignLeaveEntitlement (NEW)
--------------------------------------------------------------
IF OBJECT_ID('AssignLeaveEntitlement', 'P') IS NOT NULL
    DROP PROCEDURE AssignLeaveEntitlement;
GO

CREATE OR ALTER PROCEDURE AssignLeaveEntitlement
    @EmployeeID INT,
    @LeaveType VARCHAR(50),
    @Entitlement DECIMAL(5,2)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validate employee exists
        IF NOT EXISTS (SELECT 1 FROM Employee WHERE EmployeeID = @EmployeeID)
        BEGIN
            RAISERROR('Employee not found.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- Validate leave type exists
        DECLARE @LeaveID INT;
        SELECT @LeaveID = LeaveID FROM Leave WHERE leave_type = @LeaveType;
        
        IF @LeaveID IS NULL
        BEGIN
            RAISERROR('Leave type not found.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- Validate entitlement
        IF @Entitlement < 0
        BEGIN
            RAISERROR('Entitlement cannot be negative.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        IF @Entitlement > 999.99
        BEGIN
            RAISERROR('Entitlement cannot exceed 999.99 days.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- Check if entitlement already exists
        IF EXISTS (SELECT 1 FROM LeaveEntitlement WHERE employee_id = @EmployeeID AND leave_type_id = @LeaveID)
        BEGIN
            -- Update existing entitlement
            DECLARE @OldEntitlement DECIMAL(5,2);
            SELECT @OldEntitlement = entitlement 
            FROM LeaveEntitlement 
            WHERE employee_id = @EmployeeID AND leave_type_id = @LeaveID;
            
            UPDATE LeaveEntitlement
            SET entitlement = @Entitlement
            WHERE employee_id = @EmployeeID AND leave_type_id = @LeaveID;
            
            SELECT 'Leave entitlement updated successfully.' AS ConfirmationMessage,
                   @EmployeeID AS EmployeeID,
                   @LeaveType AS LeaveType,
                   @OldEntitlement AS PreviousEntitlement,
                   @Entitlement AS NewEntitlement,
                   'UPDATED' AS Operation;
        END
        ELSE
        BEGIN
            -- Create new entitlement
            INSERT INTO LeaveEntitlement (employee_id, leave_type_id, entitlement)
            VALUES (@EmployeeID, @LeaveID, @Entitlement);
            
            SELECT 'Leave entitlement assigned successfully.' AS ConfirmationMessage,
                   @EmployeeID AS EmployeeID,
                   @LeaveType AS LeaveType,
                   @Entitlement AS Entitlement,
                   'CREATED' AS Operation;
        END
        
        -- Create notification for employee
        INSERT INTO Notification (mesage_content, timestamp, urgency, read_status, notification_type)
        VALUES (
            CONCAT('Your ', @LeaveType, ' leave entitlement has been set to ', 
                   CAST(@Entitlement AS VARCHAR(10)), ' days.'),
            GETDATE(),
            'MEDIUM',
            0,
            'Leave Entitlement'
        );
        
        DECLARE @NotificationID INT = SCOPE_IDENTITY();
        
        INSERT INTO EmployeeNotification (employee_id, notification_id, delivery_status, delivered_at)
        VALUES (@EmployeeID, @NotificationID, 'PENDING', GETDATE());
        
        COMMIT TRANSACTION;
               
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END;
GO

--------------------------------------------------------------
--32 ConfigureLeaveRules (NEW)
--------------------------------------------------------------
IF OBJECT_ID('ConfigureLeaveRules', 'P') IS NOT NULL
    DROP PROCEDURE ConfigureLeaveRules;
GO

CREATE OR ALTER PROCEDURE ConfigureLeaveRules
    @LeaveType VARCHAR(50),
    @MaxDuration INT,
    @NoticePeriod INT,
    @WorkflowType VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validate leave type
        IF @LeaveType IS NULL OR LTRIM(RTRIM(@LeaveType)) = ''
        BEGIN
            RAISERROR('Leave type cannot be empty.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- Validate leave type exists
        IF NOT EXISTS (SELECT 1 FROM Leave WHERE leave_type = @LeaveType)
        BEGIN
            RAISERROR('Leave type not found. Please create the leave type first.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- Validate max duration
        IF @MaxDuration <= 0
        BEGIN
            RAISERROR('Maximum duration must be a positive number.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- Validate notice period
        IF @NoticePeriod < 0
        BEGIN
            RAISERROR('Notice period cannot be negative.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- Validate workflow type
        IF @WorkflowType NOT IN ('Direct Manager', 'HR Approval', 'Two-Level', 'Automatic')
        BEGIN
            RAISERROR('Invalid workflow type. Must be: Direct Manager, HR Approval, Two-Level, or Automatic.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- Create or update leave rules policy
        DECLARE @PolicyName VARCHAR(200);
        SET @PolicyName = CONCAT('Rules - ', @LeaveType, ' Leave');
        
        IF EXISTS (SELECT 1 FROM LeavePolicy WHERE name = @PolicyName)
        BEGIN
            -- Update existing policy
            UPDATE LeavePolicy
            SET purpose = CONCAT('Max Duration: ', @MaxDuration, ' days, Notice: ', @NoticePeriod, ' days, Workflow: ', @WorkflowType),
                eligibility_rules = CONCAT('Maximum duration: ', @MaxDuration, ' days per request'),
                notice_period = @NoticePeriod
            WHERE name = @PolicyName;
            
            SELECT 'Leave rules updated successfully.' AS ConfirmationMessage,
                   @PolicyName AS PolicyName,
                   @LeaveType AS LeaveType,
                   @MaxDuration AS MaxDurationDays,
                   @NoticePeriod AS NoticePeriodDays,
                   @WorkflowType AS WorkflowType,
                   'UPDATED' AS Operation;
        END
        ELSE
        BEGIN
            -- Create new rules policy
            DECLARE @NewPolicyID INT;
            SET @NewPolicyID = (SELECT ISNULL(MAX(PolicyID), 0) + 1 FROM LeavePolicy);
            
            INSERT INTO LeavePolicy (PolicyID, name, purpose, eligibility_rules, notice_period)
            VALUES (
                @NewPolicyID,
                @PolicyName,
                CONCAT('Max Duration: ', @MaxDuration, ' days, Notice: ', @NoticePeriod, ' days, Workflow: ', @WorkflowType),
                CONCAT('Maximum duration: ', @MaxDuration, ' days per request'),
                @NoticePeriod
            );
            
            SELECT 'Leave rules configured successfully.' AS ConfirmationMessage,
                   @PolicyName AS PolicyName,
                   @LeaveType AS LeaveType,
                   @MaxDuration AS MaxDurationDays,
                   @NoticePeriod AS NoticePeriodDays,
                   @WorkflowType AS WorkflowType,
                   @NewPolicyID AS PolicyID,
                   'CREATED' AS Operation;
        END
        
        -- Create notification for HR Administrators
        INSERT INTO Notification (mesage_content, timestamp, urgency, read_status, notification_type)
        VALUES (
            CONCAT('Leave rules for ', @LeaveType, ' have been configured/updated. ',
                   'Max Duration: ', @MaxDuration, ' days, Notice Period: ', @NoticePeriod, ' days, ',
                   'Workflow: ', @WorkflowType),
            GETDATE(),
            'MEDIUM',
            0,
            'Policy Update'
        );
        
        DECLARE @NotificationID INT = SCOPE_IDENTITY();
        
        INSERT INTO EmployeeNotification (employee_id, notification_id, delivery_status, delivered_at)
        SELECT employee_id, @NotificationID, 'PENDING', GETDATE()
        FROM HRAdministrator;
        
        COMMIT TRANSACTION;
               
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END;
GO


--------------------------------------------------------
--33 runs well
CREATE OR ALTER PROCEDURE ConfigureSpecialLeave
    @LeaveType VARCHAR(50),
    @Rules VARCHAR(200)
AS
BEGIN
    SET NOCOUNT ON;

    IF @LeaveType IS NULL OR LTRIM(RTRIM(@LeaveType)) = ''
    BEGIN
        RAISERROR('Error: Leave type cannot be NULL or empty.', 16, 1);
        RETURN;
    END

    IF @Rules IS NULL OR LTRIM(RTRIM(@Rules)) = ''
    BEGIN
        RAISERROR('Error: Rules cannot be NULL or empty.', 16, 1);
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM LeavePolicy WHERE name = @LeaveType)
    BEGIN
        RAISERROR('Error: Special leave type already configured.', 16, 1);
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO LeavePolicy (name, purpose, eligibility_rules, notice_period)
        VALUES (@LeaveType, @Rules, 'Special leave type', 0);

        COMMIT TRANSACTION;

        SELECT 'Special leave type configured successfully.' AS Message,
               @LeaveType AS LeaveType,
               @Rules AS Rules;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('ConfigureSpecialLeave failed: %s', 16, 1, @ErrMsg);
        RETURN;
    END CATCH
END
GO
--------------------------------------------------------------
--34 SetLeaveYearRules                                       runs well
-- Define legal leave year and reset rules.
-- Signature:
-- Name: SetLeaveYearRules.
-- Input: @StartDate date, @EndDate date.
-- Output: Confirmation message.

CREATE OR ALTER PROCEDURE SetLeaveYearRules
    @StartDate DATE,
    @EndDate DATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Validate dates are not NULL
    IF @StartDate IS NULL OR @EndDate IS NULL
    BEGIN
        RAISERROR('Error: StartDate and EndDate cannot be NULL.', 16, 1);
        RETURN;
    END

    -- Validate end date is after start date
    IF @EndDate <= @StartDate
    BEGIN
        RAISERROR('Error: EndDate must be after StartDate.', 16, 1);
        RETURN;
    END

    -- Validate the date range is reasonable (maximum 1 year + 1 month)
    IF DATEDIFF(DAY, @StartDate, @EndDate) > 395
    BEGIN
        RAISERROR('Error: Leave year duration cannot exceed 13 months.', 16, 1);
        RETURN;
    END

    -- Check if a leave year rule already exists
    IF EXISTS (SELECT 1 FROM LeavePolicy WHERE name = 'Leave Year Rule')
    BEGIN
        -- Update existing rule
        UPDATE LeavePolicy
        SET purpose = CONCAT('Leave Year: ', FORMAT(@StartDate, 'yyyy-MM-dd'), ' to ', FORMAT(@EndDate, 'yyyy-MM-dd')),
            eligibility_rules = CONCAT('Start: ', CONVERT(VARCHAR(10), @StartDate, 120), ', End: ', CONVERT(VARCHAR(10), @EndDate, 120))
        WHERE name = 'Leave Year Rule';

        SELECT 'Leave year rule updated successfully.' AS Message,
               @StartDate AS StartDate,
               @EndDate AS EndDate;
    END
    ELSE
    BEGIN
        -- Create new rule
        BEGIN TRY
            BEGIN TRANSACTION;

            INSERT INTO LeavePolicy (name, purpose, eligibility_rules, notice_period, reset_on_new_year)
            VALUES (
                'Leave Year Rule',
                CONCAT('Leave Year: ', FORMAT(@StartDate, 'yyyy-MM-dd'), ' to ', FORMAT(@EndDate, 'yyyy-MM-dd')),
                CONCAT('Start: ', CONVERT(VARCHAR(10), @StartDate, 120), ', End: ', CONVERT(VARCHAR(10), @EndDate, 120)),
                0,
                1
            );

            COMMIT TRANSACTION;

            SELECT 'Leave year rule configured successfully.' AS Message,
                   @StartDate AS StartDate,
                   @EndDate AS EndDate;
        END TRY
        BEGIN CATCH
            IF XACT_STATE() <> 0
                ROLLBACK TRANSACTION;

            DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
            RAISERROR('SetLeaveYearRules failed: %s', 16, 1, @ErrMsg);
            RETURN;
        END CATCH
    END
END
GO
--------------------------------------------------------------
--35              runs
--AdjustLeaveBalance
-- Manually adjust employee leave balances.
-- Signature:
-- Name: AdjustLeaveBalance.
-- Input: @EmployeeID int, @LeaveType varchar(50), @Adjustment decimal(5,2).
-- Output: Confirmation message.
CREATE OR ALTER PROCEDURE AdjustLeaveBalance
    @EmployeeID INT,
    @LeaveType VARCHAR(50),
    @Adjustment DECIMAL(5, 2)
AS
BEGIN
    SET NOCOUNT ON;

    -- Validate employee exists
    IF NOT EXISTS (SELECT 1 FROM dbo.Employee WHERE EmployeeID = @EmployeeID)
    BEGIN
        RAISERROR('Error: Employee with ID %d does not exist.', 16, 1, @EmployeeID);
        RETURN;
    END

    -- Validate leave type exists
    DECLARE @LeaveID INT;
    SELECT @LeaveID = LeaveID
    FROM dbo.[Leave]
    WHERE leave_type = @LeaveType;

    IF @LeaveID IS NULL
    BEGIN
        RAISERROR('Error: Leave type ''%s'' does not exist.', 16, 1, @LeaveType);
        RETURN;
    END

    -- Validate adjustment value is within reasonable bounds
    IF @Adjustment IS NULL
    BEGIN
        RAISERROR('Error: Adjustment value cannot be NULL.', 16, 1);
        RETURN;
    END

    -- Check if employee has entitlement record for this leave type
    DECLARE @CurrentEntitlement DECIMAL(5, 2);
    SELECT @CurrentEntitlement = entitlement
    FROM dbo.LeaveEntitlement
    WHERE employee_id = @EmployeeID AND leave_type_id = @LeaveID;

    IF @CurrentEntitlement IS NULL
    BEGIN
        RAISERROR('Error: No leave entitlement found for this employee and leave type. Create entitlement first.', 16, 1);
        RETURN;
    END

    -- Calculate new balance after adjustment
    DECLARE @NewBalance DECIMAL(5, 2) = @CurrentEntitlement + @Adjustment;

    -- Validate new balance doesn't go negative
    IF @NewBalance < 0
    BEGIN
        DECLARE @NewBalanceStr VARCHAR(20) = CAST(@NewBalance AS VARCHAR(20));
        DECLARE @CurrentEntitlementStr VARCHAR(20) = CAST(@CurrentEntitlement AS VARCHAR(20));
        DECLARE @AdjustmentStr VARCHAR(20) = CAST(@Adjustment AS VARCHAR(20));
        RAISERROR('Error: Adjustment would result in negative leave balance (%s days). Current: %s, Adjustment: %s.', 16, 1, @NewBalanceStr, @CurrentEntitlementStr, @AdjustmentStr);
        RETURN;
    END

    -- Validate new balance doesn't exceed maximum
    IF @NewBalance > 999.99
    BEGIN
        DECLARE @NewBalanceMaxStr VARCHAR(20) = CAST(@NewBalance AS VARCHAR(20));
        RAISERROR('Error: Adjusted balance exceeds maximum allowed (999.99 days). New balance would be: %s.', 16, 1, @NewBalanceMaxStr);
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Update leave entitlement with adjustment
        UPDATE dbo.LeaveEntitlement
        SET entitlement = @NewBalance
        WHERE employee_id = @EmployeeID AND leave_type_id = @LeaveID;

        COMMIT TRANSACTION;

        -- Return confirmation message with details
        SELECT 'Leave balance adjusted successfully.' AS Message,
               @EmployeeID AS EmployeeID,
               @LeaveType AS LeaveType,
               @CurrentEntitlement AS PreviousBalance,
               @Adjustment AS AdjustmentAmount,
               @NewBalance AS NewBalance;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('AdjustLeaveBalance failed: %s', 16, 1, @ErrMsg);
        RETURN;
    END CATCH
END
GO
--------------------------------------------------------------
--36 ManageLeaveRoles                       runs well
-- Manage user roles and permissions for leave actions.
-- Signature:
-- Name: ManageLeaveRoles.
-- Input: @RoleID int, @Permissions varchar(200).
-- Output: Confirmation message.
CREATE OR ALTER PROCEDURE ManageLeaveRoles
    @RoleID INT,
    @Permissions VARCHAR(200)
AS
BEGIN
    SET NOCOUNT ON;

    -- Variable declarations for control flow and messaging
    DECLARE @RoleExists BIT = 0;
    DECLARE @OperationType VARCHAR(50);
    DECLARE @Message NVARCHAR(500);
    DECLARE @RoleName VARCHAR(100);

    -- Validate RoleID parameter
    -- Check that RoleID is a positive integer
    IF @RoleID IS NULL OR @RoleID <= 0
    BEGIN
        RAISERROR('Error: RoleID must be a positive integer.', 16, 1);
        RETURN;
    END

    -- Validate Permissions parameter
    -- Check that Permissions is not NULL and not empty (after trimming whitespace)
    IF @Permissions IS NULL OR LTRIM(RTRIM(@Permissions)) = ''
    BEGIN
        RAISERROR('Error: Permissions cannot be NULL or empty.', 16, 1);
        RETURN;
    END

    -- Validate permissions length does not exceed 200 characters
    IF LEN(@Permissions) > 200
    BEGIN
        RAISERROR('Error: Permissions description cannot exceed 200 characters.', 16, 1);
        RETURN;
    END

    -- Check if role already exists in the LeaveRole table
    -- Set @RoleExists flag to 1 if found, 0 if not found
    IF EXISTS (SELECT 1 FROM LeaveRole WHERE role_id = @RoleID)
    BEGIN
        SET @RoleExists = 1;
        SELECT @RoleName = role_name FROM LeaveRole WHERE role_id = @RoleID;
    END

    -- BEGIN TRANSACTION for data consistency and integrity
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Perform UPSERT operation: either UPDATE or INSERT based on existence
        IF @RoleExists = 1
        BEGIN
            -- UPDATE: Role exists, so update its permissions
            UPDATE LeaveRole
            SET permissions = @Permissions,
                updated_at = GETDATE()
            WHERE role_id = @RoleID;

            -- Set operation type for confirmation message
            SET @OperationType = 'UPDATED';
            SET @Message = 'Role permissions updated successfully.';
        END
        ELSE
        BEGIN
            -- INSERT: Role does not exist, so create a new role
            -- Generate a descriptive role name based on RoleID
            SET @RoleName = CONCAT('LeaveRole_', @RoleID);

            INSERT INTO LeaveRole (role_id, role_name, permissions, created_at, updated_at)
            VALUES (@RoleID, @RoleName, @Permissions, GETDATE(), GETDATE());

            -- Set operation type for confirmation message
            SET @OperationType = 'CREATED';
            SET @Message = 'New leave role created successfully.';
        END

        -- COMMIT TRANSACTION to persist changes to database
        COMMIT TRANSACTION;

        -- Return confirmation message with operation details
        SELECT 
            @Message AS ConfirmationMessage,
            @RoleID AS RoleID,
            @RoleName AS RoleName,
            @Permissions AS Permissions,
            @OperationType AS OperationType,
            GETDATE() AS Timestamp;

    END TRY
    BEGIN CATCH
        -- ROLLBACK TRANSACTION if any error occurs to maintain data integrity
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        -- Capture and return error message for debugging
        DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('ManageLeaveRoles failed: %s', 16, 1, @ErrMsg);
        RETURN;
    END CATCH
END
GO
--------------------------------------------------------------
--37          runs
CREATE OR ALTER PROCEDURE FinalizeLeaveRequest
    @LeaveRequestID INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Variable declarations for holding leave request details
    DECLARE @Status VARCHAR(50);
    DECLARE @EmployeeID INT;
    DECLARE @LeaveTypeID INT;
    DECLARE @Duration INT;
    DECLARE @CurrentEntitlement DECIMAL(5, 2);
    DECLARE @NewEntitlement DECIMAL(5, 2);
    DECLARE @LeaveTypeName VARCHAR(50);

    -- Validate leave request exists
    IF NOT EXISTS (SELECT 1 FROM LeaveRequest WHERE RequestID = @LeaveRequestID)
    BEGIN
        RAISERROR('Error: Leave request with ID %d does not exist.', 16, 1, @LeaveRequestID);
        RETURN;
    END

    -- Retrieve leave request details
    SELECT 
        @Status = status,
        @EmployeeID = employee_id,
        @LeaveTypeID = leave_id,
        @Duration = duration
    FROM LeaveRequest
    WHERE RequestID = @LeaveRequestID;

    -- Validate leave request is approved (not pending, rejected, or already finalized)
    IF @Status != 'APPROVED'
    BEGIN
        RAISERROR('Error: Leave request must be in APPROVED status to finalize. Current status: %s.', 16, 1, @Status);
        RETURN;
    END

    -- Validate employee exists
    IF NOT EXISTS (SELECT 1 FROM Employee WHERE EmployeeID = @EmployeeID)
    BEGIN
        RAISERROR('Error: Employee with ID %d does not exist.', 16, 1, @EmployeeID);
        RETURN;
    END

    -- Validate leave type exists and get leave type name
    IF NOT EXISTS (SELECT 1 FROM [Leave] WHERE LeaveID = @LeaveTypeID)
    BEGIN
        RAISERROR('Error: Leave type with ID %d does not exist.', 16, 1, @LeaveTypeID);
        RETURN;
    END

    SELECT @LeaveTypeName = leave_type
    FROM [Leave]
    WHERE LeaveID = @LeaveTypeID;

    -- Check if employee has leave entitlement for this leave type
    SELECT @CurrentEntitlement = entitlement
    FROM LeaveEntitlement
    WHERE employee_id = @EmployeeID AND leave_type_id = @LeaveTypeID;

    IF @CurrentEntitlement IS NULL
    BEGIN
        RAISERROR('Error: No leave entitlement found for Employee ID %d and Leave Type ID %d.', 16, 1, @EmployeeID, @LeaveTypeID);
        RETURN;
    END

    -- Calculate new entitlement after deduction
    SET @NewEntitlement = @CurrentEntitlement - @Duration;

        -- Validate sufficient leave balance exists
    IF @NewEntitlement < 0
    BEGIN
        DECLARE @NewBalanceStr VARCHAR(20) = CAST(@NewEntitlement AS VARCHAR(20));
        DECLARE @CurrentDaysStr VARCHAR(20) = CAST(@CurrentEntitlement AS VARCHAR(20));
        DECLARE @DurationStr VARCHAR(20) = CAST(@Duration AS VARCHAR(20));
        RAISERROR('Error: Insufficient leave balance. Current: %s days, Required: %d days, Shortfall: %s days.', 16, 1, 
            @CurrentDaysStr, @Duration, @NewBalanceStr);
        RETURN;
    END

    -- Validate new balance doesn't exceed maximum
    IF @NewEntitlement > 999.99
    BEGIN
        DECLARE @NewBalanceMaxStr VARCHAR(20) = CAST(@NewEntitlement AS VARCHAR(20));
        RAISERROR('Error: Adjusted balance exceeds maximum allowed (999.99 days). New balance would be: %s.', 16, 1, @NewBalanceMaxStr);
        RETURN;
    END

    -- Begin transaction for atomic operation
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Update leave request status to FINALIZED
        UPDATE LeaveRequest
        SET status = 'FINALIZED',
            approval_timing = GETDATE()
        WHERE RequestID = @LeaveRequestID;

        -- Deduct leave days from employee entitlement
        UPDATE LeaveEntitlement
        SET entitlement = @NewEntitlement
        WHERE employee_id = @EmployeeID AND leave_type_id = @LeaveTypeID;

        -- Log the finalization in LeavePolicy for audit trail
        INSERT INTO LeavePolicy (name, purpose, eligibility_rules, notice_period)
        VALUES (
            CONCAT('Finalized_LeaveRequest_', @LeaveRequestID),
            CONCAT('Leave request ID: ', @LeaveRequestID, ' finalized for Employee ID: ', @EmployeeID),
            CONCAT('Leave Type: ', @LeaveTypeName, ', Duration: ', @Duration, ' days, Previous Balance: ', 
                   CAST(@CurrentEntitlement AS VARCHAR(10)), ' days, New Balance: ', CAST(@NewEntitlement AS VARCHAR(10)), ' days'),
            0
        );

        -- Commit transaction
        COMMIT TRANSACTION;

        -- Return confirmation message with detailed information
        SELECT 
            'Leave request finalized successfully.' AS ConfirmationMessage,
            @LeaveRequestID AS LeaveRequestID,
            @EmployeeID AS EmployeeID,
            @LeaveTypeName AS LeaveType,
            @Duration AS LeaveDays,
            @CurrentEntitlement AS PreviousBalance,
            @NewEntitlement AS NewBalance,
            GETDATE() AS FinalizedDateTime;

    END TRY
    BEGIN CATCH
        -- Rollback on error to maintain data integrity
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('FinalizeLeaveRequest failed: %s', 16, 1, @ErrMsg);
        RETURN;
    END CATCH
END
GO
--------------------------------------------------------------
--38          runs well
USE MILESTONE2;
GO

CREATE OR ALTER PROCEDURE OverrideLeaveDecision
    @LeaveRequestID INT,
    @Reason VARCHAR(200)
AS
BEGIN
    SET NOCOUNT ON;

    -- Variable declarations for holding leave request details
    DECLARE @CurrentStatus VARCHAR(50);
    DECLARE @EmployeeID INT;
    DECLARE @LeaveTypeID INT;
    DECLARE @Justification VARCHAR(MAX); -- cant use text in procedures, only in tables

    -- Validate leave request exists
    IF NOT EXISTS (SELECT 1 FROM LeaveRequest WHERE RequestID = @LeaveRequestID)
    BEGIN
        RAISERROR('Error: Leave request with ID %d does not exist.', 16, 1, @LeaveRequestID);
        RETURN;
    END

    -- Retrieve leave request details
    SELECT 
        @CurrentStatus = status,
        @EmployeeID = employee_id,
        @LeaveTypeID = leave_id,
        @Justification = justification
    FROM LeaveRequest
    WHERE RequestID = @LeaveRequestID;

    -- Validate leave request has a manager decision (APPROVED or REJECTED)
    IF @CurrentStatus NOT IN ('APPROVED', 'REJECTED')
    BEGIN
        RAISERROR('Error: Leave request must have an existing manager decision (APPROVED or REJECTED) to override. Current status: %s.', 16, 1, @CurrentStatus);
        RETURN;
    END

    -- Validate reason is not NULL or empty
    IF @Reason IS NULL OR LTRIM(RTRIM(@Reason)) = ''
    BEGIN
        RAISERROR('Error: Override reason cannot be NULL or empty.', 16, 1);
        RETURN;
    END

    -- Validate reason length does not exceed 200 characters
    IF LEN(@Reason) > 200
    BEGIN
        RAISERROR('Error: Override reason cannot exceed 200 characters.', 16, 1);
        RETURN;
    END

    -- Validate employee exists
    IF NOT EXISTS (SELECT 1 FROM Employee WHERE EmployeeID = @EmployeeID)
    BEGIN
        RAISERROR('Error: Employee with ID %d does not exist.', 16, 1, @EmployeeID);
        RETURN;
    END

    -- Validate leave type exists
    IF NOT EXISTS (SELECT 1 FROM [Leave] WHERE LeaveID = @LeaveTypeID)
    BEGIN
        RAISERROR('Error: Leave type with ID %d does not exist.', 16, 1, @LeaveTypeID);
        RETURN;
    END

    -- Begin transaction for atomic operation
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Update leave request status to OVERRIDE
        UPDATE LeaveRequest
        SET status = 'OVERRIDE',
            approval_timing = GETDATE()
        WHERE RequestID = @LeaveRequestID;

        -- Log the override action in LeavePolicy for audit trail
        INSERT INTO LeavePolicy (name, purpose, eligibility_rules, notice_period)
        VALUES (
            CONCAT('Override_LeaveRequest_', @LeaveRequestID),
            CONCAT('Leave request ID: ', @LeaveRequestID, ' decision overridden'),
            CONCAT('Employee ID: ', @EmployeeID, 
                   ', Original Status: ', @CurrentStatus, 
                   ', Original Justification: ', ISNULL(@Justification, 'N/A'),
                   ', Override Reason: ', @Reason,
                   ', Override Date: ', CAST(GETDATE() AS VARCHAR(25))),
            0
        );

        -- Commit transaction
        COMMIT TRANSACTION;

        -- Return confirmation message with detailed information
        SELECT 
            'Leave request decision overridden successfully.' AS ConfirmationMessage,
            @LeaveRequestID AS LeaveRequestID,
            @EmployeeID AS EmployeeID,
            @CurrentStatus AS OriginalDecision,
            'OVERRIDE' AS NewStatus,
            @Reason AS OverrideReason,
            GETDATE() AS OverrideDateTime;

    END TRY
    BEGIN CATCH
        -- Rollback on error to maintain data integrity
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('OverrideLeaveDecision failed: %s', 16, 1, @ErrMsg);
        RETURN;
    END CATCH
END
GO
--------------------------------------------------------------
--39  runs
USE MILESTONE2;
GO

CREATE OR ALTER PROCEDURE BulkProcessLeaveRequests
    @LeaveRequestIDs VARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;

    -- Variable declarations for tracking batch processing
    DECLARE @TotalRequests INT = 0;
    DECLARE @SuccessfulRequests INT = 0;
    DECLARE @FailedRequests INT = 0;
    DECLARE @RequestID INT;
    DECLARE @Status VARCHAR(50);
    DECLARE @EmployeeID INT;
    DECLARE @LeaveTypeID INT;
    DECLARE @Duration INT;
    DECLARE @CurrentEntitlement DECIMAL(5, 2);
    DECLARE @NewEntitlement DECIMAL(5, 2);
    DECLARE @LeaveTypeName VARCHAR(50);
    DECLARE @ErrorMessage NVARCHAR(255);

    -- Input validation: Check if LeaveRequestIDs is NULL or empty
    IF @LeaveRequestIDs IS NULL OR LTRIM(RTRIM(@LeaveRequestIDs)) = ''
    BEGIN
        RAISERROR('Error: LeaveRequestIDs cannot be NULL or empty.', 16, 1);
        RETURN;
    END

    -- Create a temporary table to parse comma-separated IDs
    CREATE TABLE #TempRequestIDs (
        RequestID INT,
        Processing_Status VARCHAR(50),
        Error_Details NVARCHAR(255)
    );

    -- Insert parsed request IDs into temporary table using string splitting logic
    DECLARE @Index INT = 1;
    DECLARE @StartIndex INT = 1;
    DECLARE @CommaIndex INT;
    DECLARE @IDString VARCHAR(20);

    WHILE @Index <= LEN(@LeaveRequestIDs)
    BEGIN
        -- Find the next comma position
        SET @CommaIndex = CHARINDEX(',', @LeaveRequestIDs, @StartIndex);

        -- If no comma found, take the rest of the string
        IF @CommaIndex = 0
            SET @CommaIndex = LEN(@LeaveRequestIDs) + 1;

        -- Extract the ID substring
        SET @IDString = LTRIM(RTRIM(SUBSTRING(@LeaveRequestIDs, @StartIndex, @CommaIndex - @StartIndex)));

        -- Validate and insert if it's a valid integer
        IF ISNUMERIC(@IDString) = 1
        BEGIN
            INSERT INTO #TempRequestIDs (RequestID, Processing_Status, Error_Details)
            VALUES (CAST(@IDString AS INT), 'PENDING', NULL);
        END

        -- Move to the next ID
        SET @StartIndex = @CommaIndex + 1;
        SET @Index = @CommaIndex + 1;
    END

    -- Count total requests to process
    SELECT @TotalRequests = COUNT(*) FROM #TempRequestIDs;

    -- Validate that at least one valid request ID was provided
    IF @TotalRequests = 0
    BEGIN
        RAISERROR('Error: No valid leave request IDs found in the provided list.', 16, 1);
        DROP TABLE #TempRequestIDs;
        RETURN;
    END

    -- Create cursor to iterate through each leave request ID
    DECLARE RequestCursor CURSOR FOR
    SELECT RequestID FROM #TempRequestIDs ORDER BY RequestID;

    OPEN RequestCursor;

    -- Fetch the first request ID
    FETCH NEXT FROM RequestCursor INTO @RequestID;

    -- Process each leave request
    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Initialize error message for this request
        SET @ErrorMessage = NULL;

        BEGIN TRY
            -- Validate leave request exists
            IF NOT EXISTS (SELECT 1 FROM LeaveRequest WHERE RequestID = @RequestID)
            BEGIN
                SET @ErrorMessage = 'Leave request not found.';
                THROW 50001, @ErrorMessage, 1;
            END

            -- Retrieve leave request details
            SELECT 
                @Status = status,
                @EmployeeID = employee_id,
                @LeaveTypeID = leave_id,
                @Duration = duration
            FROM LeaveRequest
            WHERE RequestID = @RequestID;

            -- Validate leave request is approved
            IF @Status != 'APPROVED'
            BEGIN
                SET @ErrorMessage = CONCAT('Leave request status is ', @Status, ', not APPROVED.');
                THROW 50002, @ErrorMessage, 1;
            END

            -- Validate employee exists
            IF NOT EXISTS (SELECT 1 FROM Employee WHERE EmployeeID = @EmployeeID)
            BEGIN
                SET @ErrorMessage = 'Employee not found.';
                THROW 50003, @ErrorMessage, 1;
            END

            -- Validate leave type exists and retrieve its name
            IF NOT EXISTS (SELECT 1 FROM [Leave] WHERE LeaveID = @LeaveTypeID)
            BEGIN
                SET @ErrorMessage = 'Leave type not found.';
                THROW 50004, @ErrorMessage, 1;
            END

            SELECT @LeaveTypeName = leave_type FROM [Leave] WHERE LeaveID = @LeaveTypeID;

            -- Retrieve current leave entitlement
            SELECT @CurrentEntitlement = entitlement
            FROM LeaveEntitlement
            WHERE employee_id = @EmployeeID AND leave_type_id = @LeaveTypeID;

            -- Validate entitlement record exists
            IF @CurrentEntitlement IS NULL
            BEGIN
                SET @ErrorMessage = 'Leave entitlement not found for this employee and leave type.';
                THROW 50005, @ErrorMessage, 1;
            END

            -- Calculate new entitlement after deduction
            SET @NewEntitlement = @CurrentEntitlement - @Duration;

            -- Validate sufficient leave balance exists
            IF @NewEntitlement < 0
            BEGIN
                SET @ErrorMessage = CONCAT('Insufficient leave balance. Current: ', CAST(@CurrentEntitlement AS VARCHAR(10)), 
                                            ' days, Required: ', CAST(@Duration AS VARCHAR(10)), ' days.');
                THROW 50006, @ErrorMessage, 1;
            END

            -- Validate new balance doesn't exceed maximum
            IF @NewEntitlement > 999.99
            BEGIN
                SET @ErrorMessage = CONCAT('Adjusted balance exceeds maximum allowed (999.99 days). New balance would be: ', 
                                           CAST(@NewEntitlement AS VARCHAR(10)));
                THROW 50007, @ErrorMessage, 1;
            END

            -- Begin transaction for atomic operation
            BEGIN TRANSACTION;

            -- Update leave request status to FINALIZED
            UPDATE LeaveRequest
            SET status = 'FINALIZED',
                approval_timing = GETDATE()
            WHERE RequestID = @RequestID;

            -- Deduct leave days from employee entitlement
            UPDATE LeaveEntitlement
            SET entitlement = @NewEntitlement
            WHERE employee_id = @EmployeeID AND leave_type_id = @LeaveTypeID;

            -- Log the processing in LeavePolicy for audit trail
            INSERT INTO LeavePolicy (name, purpose, eligibility_rules, notice_period)
            VALUES (
                CONCAT('BulkProcess_LeaveRequest_', @RequestID),
                CONCAT('Bulk processed - Leave request ID: ', @RequestID, ' for Employee ID: ', @EmployeeID),
                CONCAT('Leave Type: ', @LeaveTypeName, ', Duration: ', @Duration, ' days, Previous Balance: ', 
                       CAST(@CurrentEntitlement AS VARCHAR(10)), ' days, New Balance: ', CAST(@NewEntitlement AS VARCHAR(10)), ' days'),
                0
            );

            -- Commit transaction
            COMMIT TRANSACTION;

            -- Update temporary table with success status
            UPDATE #TempRequestIDs
            SET Processing_Status = 'SUCCESS',
                Error_Details = NULL
            WHERE RequestID = @RequestID;

            -- Increment successful counter
            SET @SuccessfulRequests = @SuccessfulRequests + 1;

        END TRY
        BEGIN CATCH
            -- Rollback on error
            IF XACT_STATE() <> 0
                ROLLBACK TRANSACTION;

            -- Update temporary table with failure status and error message
            UPDATE #TempRequestIDs
            SET Processing_Status = 'FAILED',
                Error_Details = ISNULL(@ErrorMessage, ERROR_MESSAGE())
            WHERE RequestID = @RequestID;

            -- Increment failed counter
            SET @FailedRequests = @FailedRequests + 1;
        END CATCH

        -- Fetch next request ID
        FETCH NEXT FROM RequestCursor INTO @RequestID;
    END

    -- Close and deallocate cursor
    CLOSE RequestCursor;
    DEALLOCATE RequestCursor;

    -- Return final results with detailed summary
    SELECT 
        'Bulk leave request processing completed.' AS ConfirmationMessage,
        @TotalRequests AS TotalRequests,
        @SuccessfulRequests AS SuccessfulRequests,
        @FailedRequests AS FailedRequests,
        GETDATE() AS ProcessedDateTime;

    -- Return detailed status for each request
    SELECT 
        RequestID,
        Processing_Status AS Status,
        Error_Details AS ErrorMessage
    FROM #TempRequestIDs
    ORDER BY RequestID;

    -- Clean up temporary table
    DROP TABLE #TempRequestIDs;
END
GO
--------------------------------------------------------------
--40 VerifyMedicalLeave
CREATE OR ALTER PROCEDURE VerifyMedicalLeave
    @LeaveRequestID INT,
    @DocumentID INT
AS
BEGIN
    -- Validate leave request exists
    IF NOT EXISTS (SELECT 1 FROM LeaveRequest WHERE RequestID = @LeaveRequestID)
    BEGIN
        RAISERROR('Leave request not found.', 16, 1);
        RETURN;
    END

    -- Validate document exists
    IF NOT EXISTS (SELECT 1 FROM LeaveDocument WHERE DocumentID = @DocumentID)
    BEGIN
        RAISERROR('Document not found.', 16, 1);
        RETURN;
    END

    -- Verify document belongs to this leave request
    IF NOT EXISTS (
        SELECT 1 FROM LeaveDocument 
        WHERE DocumentID = @DocumentID AND leave_request_id = @LeaveRequestID
    )
    BEGIN
        RAISERROR('Document does not belong to this leave request.', 16, 1);
        RETURN;
    END

    -- Check if it's a sick leave
    DECLARE @LeaveID INT;
    SELECT @LeaveID = leave_id FROM LeaveRequest WHERE RequestID = @LeaveRequestID;

    IF NOT EXISTS (SELECT 1 FROM SickLeave WHERE leave_id = @LeaveID)
    BEGIN
        RAISERROR('This is not a medical/sick leave request.', 16, 1);
        RETURN;
    END

    -- Update leave request status to verified
    UPDATE LeaveRequest
    SET status = 'VERIFIED'
    WHERE RequestID = @LeaveRequestID;

    SELECT 'Medical leave document verified successfully.' AS ConfirmationMessage;
END;
GO

--------------------------------------------------------------
--41 SyncLeaveBalances
CREATE OR ALTER PROCEDURE SyncLeaveBalances
    @LeaveRequestID INT
AS
BEGIN
    -- Validate leave request exists
    IF NOT EXISTS (SELECT 1 FROM LeaveRequest WHERE RequestID = @LeaveRequestID)
    BEGIN
        RAISERROR('Leave request not found.', 16, 1);
        RETURN;
    END

    -- Check if leave is approved
    DECLARE @Status VARCHAR(50), @EmployeeID INT, @LeaveTypeID INT, @Duration INT;
    
    SELECT 
        @Status = status,
        @EmployeeID = employee_id,
        @LeaveTypeID = leave_id,
        @Duration = duration
    FROM LeaveRequest
    WHERE RequestID = @LeaveRequestID;

    IF @Status != 'APPROVED'
    BEGIN
        RAISERROR('Leave request must be approved before syncing balances.', 16, 1);
        RETURN;
    END

    -- Check if employee has sufficient leave balance
    DECLARE @CurrentEntitlement INT;
    SELECT @CurrentEntitlement = entitlement
    FROM LeaveEntitlement
    WHERE employee_id = @EmployeeID AND leave_type_id = @LeaveTypeID;

    IF @CurrentEntitlement IS NULL
    BEGIN
        RAISERROR('No leave entitlement found for this employee and leave type.', 16, 1);
        RETURN;
    END

    IF @CurrentEntitlement < @Duration
    BEGIN
        RAISERROR('Insufficient leave balance.', 16, 1);
        RETURN;
    END

    -- Deduct leave balance
    UPDATE LeaveEntitlement
    SET entitlement = entitlement - @Duration
    WHERE employee_id = @EmployeeID AND leave_type_id = @LeaveTypeID;

    SELECT 'Leave balance synced successfully.' AS ConfirmationMessage;
END;
GO

--------------------------------------------------------------
--42 ProcessLeaveCarryForward
CREATE OR ALTER PROCEDURE ProcessLeaveCarryForward
    @Year INT
AS
BEGIN
    -- Validate year
    IF @Year < 2000 OR @Year > 2100
    BEGIN
        RAISERROR('Invalid year provided.', 16, 1);
        RETURN;
    END

    -- Check if processing for this year already done
    IF EXISTS (
        SELECT 1 FROM LeavePolicy 
        WHERE name = CONCAT('CarryForward_', @Year)
    )
    BEGIN
        RAISERROR('Carry-forward for this year has already been processed.', 16, 1);
        RETURN;
    END

    -- Get vacation leaves that allow carry-over
    DECLARE @ProcessedCount INT = 0;

    -- Update vacation leave entitlements with carry-over
    UPDATE le
    SET le.entitlement = le.entitlement + ISNULL(vl.carry_over_days, 0)
    FROM LeaveEntitlement le
    INNER JOIN Leave l ON le.leave_type_id = l.LeaveID
    INNER JOIN VacationLeave vl ON l.LeaveID = vl.leave_id
    WHERE l.leave_type = 'Vacation' 
    AND vl.carry_over_days > 0;

    SET @ProcessedCount = @ProcessedCount + @@ROWCOUNT;

    -- Log the carry-forward process
    INSERT INTO LeavePolicy (name, purpose, reset_on_new_year)
    VALUES (
        CONCAT('CarryForward_', @Year),
        CONCAT('Year-end carry-forward processed for ', @Year, '. Total records: ', @ProcessedCount),
        1
    );

    SELECT CONCAT('Leave carry-forward processed successfully for year ', @Year, 
                  '. Total records updated: ', @ProcessedCount) AS ConfirmationMessage;
END;
GO

--------------------------------------------------------------
--43 SyncLeaveToAttendance
CREATE OR ALTER PROCEDURE SyncLeaveToAttendance
    @LeaveRequestID INT
AS
BEGIN
    -- Validate leave request exists and is approved
    IF NOT EXISTS (SELECT 1 FROM LeaveRequest WHERE RequestID = @LeaveRequestID)
    BEGIN
        RAISERROR('Leave request not found.', 16, 1);
        RETURN;
    END

    DECLARE @Status VARCHAR(50), @EmployeeID INT, @Duration INT;
    DECLARE @LeaveStartDate DATE, @LeaveEndDate DATE;

    SELECT 
        @Status = status,
        @EmployeeID = employee_id,
        @Duration = duration
    FROM LeaveRequest
    WHERE RequestID = @LeaveRequestID;

    IF @Status != 'APPROVED'
    BEGIN
        RAISERROR('Only approved leave requests can be synced to attendance.', 16, 1);
        RETURN;
    END

    -- Create exception for leave period
    INSERT INTO Exception (name, category, date, status)
    VALUES (
        CONCAT('Leave Exception - Request ID: ', @LeaveRequestID),
        'Leave',
        GETDATE(),
        'ACTIVE'
    );

    DECLARE @ExceptionID INT = SCOPE_IDENTITY();

    -- Link exception to employee
    INSERT INTO EmployeeException (employee_id, exception_id)
    VALUES (@EmployeeID, @ExceptionID);

    -- Create attendance records for leave period (marking as exception)
    DECLARE @CurrentDate DATE = CAST(GETDATE() AS DATE);
    DECLARE @Counter INT = 0;

    WHILE @Counter < @Duration
    BEGIN
        INSERT INTO Attendance (
            employee_id, 
            entry_time, 
            exit_time, 
            duration, 
            login_method, 
            logout_method, 
            exception_id
        )
        VALUES (
            @EmployeeID,
            NULL,
            NULL,
            0,
            'LEAVE',
            'LEAVE',
            @ExceptionID
        );

        SET @Counter = @Counter + 1;
    END

    SELECT 'Leave synced to attendance system successfully.' AS ConfirmationMessage;
END;
GO

--------------------------------------------------------------
--44 UpdateInsuranceBrackets
CREATE OR ALTER PROCEDURE UpdateInsuranceBrackets
    @BracketID INT,
    @NewMinSalary DECIMAL(10,2),
    @NewMaxSalary DECIMAL(10,2),
    @NewEmployeeContribution DECIMAL(5,2),
    @NewEmployerContribution DECIMAL(5,2),
    @UpdatedBy INT
AS
BEGIN
    -- Validate bracket exists
    IF NOT EXISTS (SELECT 1 FROM Insurance WHERE InsuranceID = @BracketID)
    BEGIN
        RAISERROR('Insurance bracket not found.', 16, 1);
        RETURN;
    END

    -- Validate employee exists
    IF NOT EXISTS (SELECT 1 FROM Employee WHERE EmployeeID = @UpdatedBy)
    BEGIN
        RAISERROR('Updater employee not found.', 16, 1);
        RETURN;
    END

    -- Validate salary range
    IF @NewMinSalary < 0 OR @NewMaxSalary <= @NewMinSalary
    BEGIN
        RAISERROR('Invalid salary range. Max must be greater than Min.', 16, 1);
        RETURN;
    END

    -- Validate contribution rates
    IF @NewEmployeeContribution < 0 OR @NewEmployeeContribution > 100
    BEGIN
        RAISERROR('Employee contribution rate must be between 0 and 100.', 16, 1);
        RETURN;
    END

    IF @NewEmployerContribution < 0 OR @NewEmployerContribution > 100
    BEGIN
        RAISERROR('Employer contribution rate must be between 0 and 100.', 16, 1);
        RETURN;
    END

    -- Update insurance bracket
    UPDATE Insurance
    SET contribution_rate = @NewEmployeeContribution,
        coverage = CONCAT('Salary Range: ', @NewMinSalary, '-', @NewMaxSalary, 
                         ', Employer: ', @NewEmployerContribution, '%')
    WHERE InsuranceID = @BracketID;

    -- Create notification for affected employees
    INSERT INTO Notification (mesage_content, timestamp, urgency, read_status, notification_type)
    VALUES (
        CONCAT('Insurance bracket (ID: ', @BracketID, ') has been updated. ',
               'New contribution rate: ', @NewEmployeeContribution, '%. ',
               'Updated by Employee ID: ', @UpdatedBy),
        GETDATE(),
        'HIGH',
        0,
        'Insurance Update'
    );

    DECLARE @NotificationID INT = SCOPE_IDENTITY();

    -- Notify all employees affected by this bracket
    INSERT INTO EmployeeNotification (employee_id, notification_id, delivery_status, delivered_at)
    SELECT DISTINCT e.EmployeeID, @NotificationID, 'PENDING', GETDATE()
    FROM Employee e
    INNER JOIN Contract c ON e.contract_id = c.ContractID
    INNER JOIN FullTimeContract ftc ON c.ContractID = ftc.contract_id
    WHERE ftc.insurance_eligibility = 1;

    SELECT 'Insurance brackets updated and notifications sent.' AS NotificationMessage;
END;
GO

--------------------------------------------------------------
--45 ApprovePolicyUpdate
CREATE OR ALTER PROCEDURE ApprovePolicyUpdate
    @PolicyID INT,
    @ApprovedBy INT
AS
BEGIN
    -- Validate policy exists
    IF NOT EXISTS (SELECT 1 FROM PayrollPolicy WHERE PolicyID = @PolicyID)
    BEGIN
        RAISERROR('Payroll policy not found.', 16, 1);
        RETURN;
    END

    -- Validate approver exists and has authority (HR Administrator)
    IF NOT EXISTS (SELECT 1 FROM Employee WHERE EmployeeID = @ApprovedBy)
    BEGIN
        RAISERROR('Approver not found.', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM HRAdministrator WHERE employee_id = @ApprovedBy)
    BEGIN
        RAISERROR('Approver does not have HR Administrator privileges.', 16, 1);
        RETURN;
    END

    -- Get policy details
    DECLARE @PolicyType VARCHAR(100), @PolicyDescription VARCHAR(150);
    SELECT @PolicyType = type, @PolicyDescription = description
    FROM PayrollPolicy
    WHERE PolicyID = @PolicyID;

    -- Update policy effective date to now (mark as approved)
    UPDATE PayrollPolicy
    SET effective_date = GETDATE()
    WHERE PolicyID = @PolicyID;

    -- Create notification for all payroll specialists and HR
    INSERT INTO Notification (mesage_content, timestamp, urgency, read_status, notification_type)
    VALUES (
        CONCAT('Payroll Policy (ID: ', @PolicyID, ', Type: ', @PolicyType, 
               ') has been approved by HR Admin (ID: ', @ApprovedBy, '). ',
               'Effective immediately. Description: ', @PolicyDescription),
        GETDATE(),
        'HIGH',
        0,
        'Policy Approval'
    );

    DECLARE @NotificationID INT = SCOPE_IDENTITY();

    -- Notify all HR Administrators
    INSERT INTO EmployeeNotification (employee_id, notification_id, delivery_status, delivered_at)
    SELECT employee_id, @NotificationID, 'PENDING', GETDATE()
    FROM HRAdministrator;

    -- Notify all Payroll Specialists
    INSERT INTO EmployeeNotification (employee_id, notification_id, delivery_status, delivered_at)
    SELECT employee_id, @NotificationID, 'PENDING', GETDATE()
    FROM PayrollSpecialist;

    SELECT 'Policy update approved and notifications sent to relevant staff.' AS NotificationMessage;
END;
GO

--Payroll Officer Procedures

USE MILESTONE2;
GO

-- ========================================
-- 1) Generate payroll for a specific pay period
-- ========================================
IF OBJECT_ID('GeneratePayroll', 'P') IS NOT NULL
    DROP PROCEDURE GeneratePayroll;
GO

CREATE PROCEDURE GeneratePayroll
    @StartDate date,
    @EndDate date
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validate date range
    IF @StartDate > @EndDate
    BEGIN
        RAISERROR('Start date cannot be after end date', 16, 1);
        RETURN;
    END
    
    -- Generate payroll records for active employees
    SELECT 
        e.EmployeeID,
        e.full_name,
        e.department_id,
        st.type AS salary_type,
        st.payment_frequency,
        CASE 
            WHEN st.type = 'Monthly' THEN mst.tax_rule
            ELSE NULL
        END AS tax_rule,
        @StartDate AS period_start,
        @EndDate AS period_end,
        CASE 
            WHEN hst.hourly_rate IS NOT NULL THEN hst.hourly_rate * hst.max_monthly_hours
            WHEN cst.contract_value IS NOT NULL THEN cst.contract_value
            ELSE 0
        END AS base_amount,
        0.00 AS adjustments,
        0.00 AS contributions,
        0.00 AS taxes,
        CASE 
            WHEN hst.hourly_rate IS NOT NULL THEN hst.hourly_rate * hst.max_monthly_hours
            WHEN cst.contract_value IS NOT NULL THEN cst.contract_value
            ELSE 0
        END AS net_salary
    FROM Employee e
    INNER JOIN SalaryType st ON e.salary_type_id = st.SalaryTypeID
    LEFT JOIN HourlySalaryType hst ON st.SalaryTypeID = hst.salary_type_id
    LEFT JOIN MonthlySalaryType mst ON st.SalaryTypeID = mst.salary_type_id
    LEFT JOIN ContractSalaryType cst ON st.SalaryTypeID = cst.salary_type_id
    WHERE e.is_active = 1
        AND e.hire_date <= @EndDate
    ORDER BY e.EmployeeID;
END
GO

-- ========================================
-- 2) Add or modify allowances and deductions
-- ========================================
IF OBJECT_ID('AdjustPayrollItem', 'P') IS NOT NULL
    DROP PROCEDURE AdjustPayrollItem;
GO

CREATE PROCEDURE AdjustPayrollItem
    @PayrollID int,
    @Type varchar(50),
    @Amount decimal(18,2),
    @Duration int,
    @Timezone varchar(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validate payroll exists
    IF NOT EXISTS (SELECT 1 FROM Payroll WHERE PayrollID = @PayrollID)
    BEGIN
        RAISERROR('Payroll record not found', 16, 1);
        RETURN;
    END
    
    -- Validate type
    IF @Type NOT IN ('Allowance', 'Deduction')
    BEGIN
        RAISERROR('Type must be either Allowance or Deduction', 16, 1);
        RETURN;
    END
    
    DECLARE @EmployeeID int;
    DECLARE @Currency varchar(10);
    
    -- Get employee and currency from payroll
    SELECT @EmployeeID = employee_id FROM Payroll WHERE PayrollID = @PayrollID;
    SELECT TOP 1 @Currency = currency FROM SalaryType st
    INNER JOIN Employee e ON e.salary_type_id = st.SalaryTypeID
    WHERE e.EmployeeID = @EmployeeID;
    
    -- Insert allowance/deduction record
    DECLARE @NewID int = (SELECT ISNULL(MAX(AllowanceDeductionID), 0) + 1 FROM AllowanceDeduction);
    
    INSERT INTO AllowanceDeduction (AllowanceDeductionID, payroll_id, employee_id, type, amount, currency, duration, timezone)
    VALUES (@NewID, @PayrollID, @EmployeeID, @Type, @Amount, @Currency, @Duration, @Timezone);
    
    -- Update payroll adjustments
    UPDATE Payroll
    SET adjustments = adjustments + (CASE WHEN @Type = 'Allowance' THEN @Amount ELSE -@Amount END),
        net_salary = base_amount + adjustments + (CASE WHEN @Type = 'Allowance' THEN @Amount ELSE -@Amount END) - taxes - contributions
    WHERE PayrollID = @PayrollID;
    
    PRINT 'Payroll item adjusted successfully';
END
GO

-- ========================================
-- 3) Compute net salary for a specific payroll record
-- ========================================
IF OBJECT_ID('CalculateNetSalary', 'P') IS NOT NULL
    DROP PROCEDURE CalculateNetSalary;
GO

CREATE PROCEDURE CalculateNetSalary
    @PayrollID int,
    @NetSalary decimal(18,2) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validate payroll exists
    IF NOT EXISTS (SELECT 1 FROM Payroll WHERE PayrollID = @PayrollID)
    BEGIN
        RAISERROR('Payroll record not found', 16, 1);
        RETURN;
    END
    
    -- Calculate net salary: base + adjustments - taxes - contributions
    SELECT @NetSalary = base_amount + adjustments - taxes - contributions
    FROM Payroll
    WHERE PayrollID = @PayrollID;
    
    -- Update the payroll record
    UPDATE Payroll
    SET net_salary = @NetSalary,
        actual_pay = @NetSalary
    WHERE PayrollID = @PayrollID;
    
    RETURN;
END
GO

-- ========================================
-- 4) Apply payroll policies (bonus, overtime, deductions)
-- ========================================
IF OBJECT_ID('ApplyPayrollPolicy', 'P') IS NOT NULL
    DROP PROCEDURE ApplyPayrollPolicy;
GO

CREATE PROCEDURE ApplyPayrollPolicy
    @PolicyID int,
    @PayrollID int,
    @Type varchar(100),
    @Description text
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validate policy exists
    IF NOT EXISTS (SELECT 1 FROM PayrollPolicy WHERE PolicyID = @PolicyID)
    BEGIN
        RAISERROR('Payroll policy not found', 16, 1);
        RETURN;
    END
    
    -- Validate payroll exists
    IF NOT EXISTS (SELECT 1 FROM Payroll WHERE PayrollID = @PayrollID)
    BEGIN
        RAISERROR('Payroll record not found', 16, 1);
        RETURN;
    END
    
    -- Check if policy already applied
    IF EXISTS (SELECT 1 FROM PayrollPolicyID WHERE payroll_id = @PayrollID AND policy_id = @PolicyID)
    BEGIN
        RAISERROR('Policy already applied to this payroll', 16, 1);
        RETURN;
    END
    
    -- Link policy to payroll
    INSERT INTO PayrollPolicyID (payroll_id, policy_id)
    VALUES (@PayrollID, @PolicyID);
    
    -- Apply policy based on type
    DECLARE @AdjustmentAmount decimal(18,2) = 0;
    DECLARE @EmployeeID int;
    
    SELECT @EmployeeID = employee_id FROM Payroll WHERE PayrollID = @PayrollID;
    
    -- Apply bonus policy
    IF EXISTS (SELECT 1 FROM BonusPolicy WHERE policy_id = @PolicyID)
    BEGIN
        SET @AdjustmentAmount = 500.00; -- Example bonus amount
        UPDATE Payroll
        SET adjustments = adjustments + @AdjustmentAmount,
            net_salary = net_salary + @AdjustmentAmount
        WHERE PayrollID = @PayrollID;
    END
    
    -- Apply deduction policy
    IF EXISTS (SELECT 1 FROM DeductionPolicy WHERE policy_id = @PolicyID)
    BEGIN
        SET @AdjustmentAmount = -200.00; -- Example deduction amount
        UPDATE Payroll
        SET adjustments = adjustments + @AdjustmentAmount,
            net_salary = net_salary + @AdjustmentAmount
        WHERE PayrollID = @PayrollID;
    END
    
    -- Apply overtime policy
    IF EXISTS (SELECT 1 FROM OvertimePolicy WHERE policy_id = @PolicyID)
    BEGIN
        DECLARE @OvertimeRate decimal(5,2);
        SELECT @OvertimeRate = weekday_rate_multiplier FROM OvertimePolicy WHERE policy_id = @PolicyID;
        SET @AdjustmentAmount = 300.00 * @OvertimeRate; -- Example overtime calculation
        UPDATE Payroll
        SET adjustments = adjustments + @AdjustmentAmount,
            net_salary = net_salary + @AdjustmentAmount
        WHERE PayrollID = @PayrollID;
    END
    
    PRINT 'Payroll policy applied successfully';
END
GO

-- ========================================
-- 5) Retrieve payroll summary for a given month
-- ========================================
IF OBJECT_ID('GetMonthlyPayrollSummary', 'P') IS NOT NULL
    DROP PROCEDURE GetMonthlyPayrollSummary;
GO

CREATE PROCEDURE GetMonthlyPayrollSummary
    @Month int,
    @Year int
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validate month
    IF @Month < 1 OR @Month > 12
    BEGIN
        RAISERROR('Month must be between 1 and 12', 16, 1);
        RETURN;
    END
    
    -- Return payroll summary
    SELECT 
        COUNT(DISTINCT employee_id) AS total_employees,
        SUM(base_amount) AS total_base_salary,
        SUM(adjustments) AS total_adjustments,
        SUM(taxes) AS total_taxes,
        SUM(contributions) AS total_contributions,
        SUM(net_salary) AS total_salary_expenditure,
        AVG(net_salary) AS average_net_salary,
        MAX(net_salary) AS max_net_salary,
        MIN(net_salary) AS min_net_salary
    FROM Payroll
    WHERE MONTH(period_start) = @Month 
        AND YEAR(period_start) = @Year;
END
GO

-- ========================================
-- 6) Retrieve payroll history for a specific employee
-- ========================================
IF OBJECT_ID('GetEmployeePayrollHistory', 'P') IS NOT NULL
    DROP PROCEDURE GetEmployeePayrollHistory;
GO

CREATE PROCEDURE GetEmployeePayrollHistory
    @EmployeeID int
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validate employee exists
    IF NOT EXISTS (SELECT 1 FROM Employee WHERE EmployeeID = @EmployeeID)
    BEGIN
        RAISERROR('Employee not found', 16, 1);
        RETURN;
    END
    
    -- Return payroll history
    SELECT 
        p.PayrollID,
        p.period_start,
        p.period_end,
        p.base_amount,
        p.adjustments,
        p.taxes,
        p.contributions,
        p.net_salary,
        p.payment_date,
        COUNT(ad.AllowanceDeductionID) AS allowance_deduction_count
    FROM Payroll p
    LEFT JOIN AllowanceDeduction ad ON p.PayrollID = ad.payroll_id
    WHERE p.employee_id = @EmployeeID
    GROUP BY p.PayrollID, p.period_start, p.period_end, p.base_amount, 
             p.adjustments, p.taxes, p.contributions, p.net_salary, p.payment_date
    ORDER BY p.period_start DESC;
END
GO

--7) Does not exist

-- ========================================
-- 8) Get list of employees eligible for bonuses
-- ========================================
IF OBJECT_ID('GetBonusEligibleEmployees', 'P') IS NOT NULL
    DROP PROCEDURE GetBonusEligibleEmployees;
GO

CREATE PROCEDURE GetBonusEligibleEmployees
    @EligibilityCriteria varchar(200)
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Return employees based on criteria
    -- Criteria examples: 'FullTime', 'HighPerformer', 'TenureGreaterThan1Year'
    
    IF @EligibilityCriteria = 'FullTime'
    BEGIN
        SELECT DISTINCT
            e.EmployeeID,
            e.full_name,
            e.department_id,
            e.position_id,
            e.hire_date,
            st.type AS salary_type
        FROM Employee e
        INNER JOIN Contract c ON e.contract_id = c.ContractID
        INNER JOIN FullTimeContract ftc ON c.ContractID = ftc.contract_id
        INNER JOIN SalaryType st ON e.salary_type_id = st.SalaryTypeID
        WHERE e.is_active = 1;
    END
    ELSE IF @EligibilityCriteria = 'TenureGreaterThan1Year'
    BEGIN
        SELECT 
            e.EmployeeID,
            e.full_name,
            e.department_id,
            e.position_id,
            e.hire_date,
            DATEDIFF(YEAR, e.hire_date, GETDATE()) AS years_of_service
        FROM Employee e
        WHERE e.is_active = 1
            AND DATEDIFF(YEAR, e.hire_date, GETDATE()) > 1;
    END
    ELSE
    BEGIN
        -- Default: return all active employees
        SELECT 
            e.EmployeeID,
            e.full_name,
            e.department_id,
            e.position_id,
            e.hire_date
        FROM Employee e
        WHERE e.is_active = 1;
    END
END
GO

-- ========================================
-- 9) Update the salary type of an employee
-- ========================================
IF OBJECT_ID('UpdateSalaryType', 'P') IS NOT NULL
    DROP PROCEDURE UpdateSalaryType;
GO

CREATE PROCEDURE UpdateSalaryType
    @EmployeeID int,
    @SalaryTypeID int
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validate employee exists
    IF NOT EXISTS (SELECT 1 FROM Employee WHERE EmployeeID = @EmployeeID)
    BEGIN
        RAISERROR('Employee not found', 16, 1);
        RETURN;
    END
    
    -- Validate salary type exists
    IF NOT EXISTS (SELECT 1 FROM SalaryType WHERE SalaryTypeID = @SalaryTypeID)
    BEGIN
        RAISERROR('Salary type not found', 16, 1);
        RETURN;
    END
    
    -- Update employee salary type
    UPDATE Employee
    SET salary_type_id = @SalaryTypeID
    WHERE EmployeeID = @EmployeeID;
    
    PRINT 'Salary type updated successfully for employee ' + CAST(@EmployeeID AS varchar(10));
END
GO

-- ========================================
-- 10) Retrieve payroll summary for a specific department
-- ========================================
IF OBJECT_ID('GetPayrollByDepartment', 'P') IS NOT NULL
    DROP PROCEDURE GetPayrollByDepartment;
GO

CREATE PROCEDURE GetPayrollByDepartment
    @DepartmentID int,
    @Month int,
    @Year int
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validate department exists
    IF NOT EXISTS (SELECT 1 FROM Department WHERE DepartmentID = @DepartmentID)
    BEGIN
        RAISERROR('Department not found', 16, 1);
        RETURN;
    END
    
    -- Validate month
    IF @Month < 1 OR @Month > 12
    BEGIN
        RAISERROR('Month must be between 1 and 12', 16, 1);
        RETURN;
    END
    
    -- Return department payroll summary
    SELECT 
        d.DepartmentID,
        d.department_name,
        COUNT(DISTINCT p.employee_id) AS total_employees,
        SUM(p.base_amount) AS total_base_salary,
        SUM(p.adjustments) AS total_adjustments,
        SUM(p.taxes) AS total_taxes,
        SUM(p.contributions) AS total_contributions,
        SUM(p.net_salary) AS total_department_payroll,
        AVG(p.net_salary) AS average_net_salary
    FROM Department d
    INNER JOIN Employee e ON e.department_id = d.DepartmentID
    INNER JOIN Payroll p ON p.employee_id = e.EmployeeID
    WHERE d.DepartmentID = @DepartmentID
        AND MONTH(p.period_start) = @Month
        AND YEAR(p.period_start) = @Year
    GROUP BY d.DepartmentID, d.department_name;
END
GO

-- ========================================
-- 11) Block payroll processing if missed punches remain unresolved
-- ========================================
IF OBJECT_ID('ValidateAttendanceBeforePayroll', 'P') IS NOT NULL
    DROP PROCEDURE ValidateAttendanceBeforePayroll;
GO

CREATE PROCEDURE ValidateAttendanceBeforePayroll
    @PayrollPeriodID int
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validate payroll period exists
    IF NOT EXISTS (SELECT 1 FROM PayrollPeriod WHERE PayrollPeriodID = @PayrollPeriodID)
    BEGIN
        RAISERROR('Payroll period not found', 16, 1);
        RETURN;
    END
    
    DECLARE @StartDate datetime;
    DECLARE @EndDate datetime;
    
    -- Get period dates
    SELECT @StartDate = start_date, @EndDate = end_date
    FROM PayrollPeriod
    WHERE PayrollPeriodID = @PayrollPeriodID;
    
    -- Find employees with unresolved attendance issues
    SELECT DISTINCT
        e.EmployeeID,
        e.full_name,
        e.department_id,
        COUNT(DISTINCT acr.RequestID) AS pending_correction_requests,
        STRING_AGG(CAST(acr.date AS varchar), ', ') AS dates_with_issues
    FROM Employee e
    LEFT JOIN AttendanceCorrectionRequest acr 
        ON acr.employee_id = e.EmployeeID
        AND acr.status = 'Pending'
        AND acr.date BETWEEN @StartDate AND @EndDate
    WHERE e.is_active = 1
        AND acr.RequestID IS NOT NULL
    GROUP BY e.EmployeeID, e.full_name, e.department_id
    ORDER BY e.EmployeeID;
END
GO

-- ========================================
-- 12) Sync attendance records daily to payroll
-- ========================================
IF OBJECT_ID('SyncAttendanceToPayroll', 'P') IS NOT NULL
    DROP PROCEDURE SyncAttendanceToPayroll;
GO

CREATE PROCEDURE SyncAttendanceToPayroll
    @SyncDate date
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @SyncCount int = 0;
    
    -- Validate date
    IF @SyncDate > GETDATE()
    BEGIN
        RAISERROR('Cannot sync future dates', 16, 1);
        RETURN;
    END
    
    -- Create temporary table for sync results
    CREATE TABLE #AttendanceSync (
        EmployeeID int,
        AttendanceRecords int,
        TotalHours decimal(10,2),
        SyncStatus varchar(50)
    );
    
    -- Process attendance for each employee
    INSERT INTO #AttendanceSync (EmployeeID, AttendanceRecords, TotalHours, SyncStatus)
    SELECT 
        a.employee_id,
        COUNT(*) AS attendance_records,
        SUM(ISNULL(a.duration, 0)) / 60.0 AS total_hours,
        'Synced' AS sync_status
    FROM Attendance a
    WHERE CAST(DATEADD(DAY, DATEDIFF(DAY, 0, GETDATE()), CAST(a.entry_time AS datetime)) AS date) = @SyncDate
        OR EXISTS (
            SELECT 1 FROM AttendanceLog al 
            WHERE al.attendance_id = a.AttendanceID 
            AND CAST(al.timestamp AS date) = @SyncDate
        )
    GROUP BY a.employee_id;
    
    SELECT @SyncCount = COUNT(*) FROM #AttendanceSync;
    
    -- Return sync summary
    SELECT * FROM #AttendanceSync;
    
    DROP TABLE #AttendanceSync;
    
    PRINT 'Attendance synced successfully for ' + CAST(@SyncCount AS varchar(10)) + ' employees on ' + CAST(@SyncDate AS varchar(20));
END
GO

-- ========================================
-- 13) Ensure only accepted permissions affect payroll
-- ========================================
IF OBJECT_ID('SyncApprovedPermissionsToPayroll', 'P') IS NOT NULL
    DROP PROCEDURE SyncApprovedPermissionsToPayroll;
GO

CREATE PROCEDURE SyncApprovedPermissionsToPayroll
    @PayrollPeriodID int
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validate payroll period exists
    IF NOT EXISTS (SELECT 1 FROM PayrollPeriod WHERE PayrollPeriodID = @PayrollPeriodID)
    BEGIN
        RAISERROR('Payroll period not found', 16, 1);
        RETURN;
    END
    
    DECLARE @StartDate datetime;
    DECLARE @EndDate datetime;
    DECLARE @SyncCount int = 0;
    
    -- Get period dates
    SELECT @StartDate = start_date, @EndDate = end_date
    FROM PayrollPeriod
    WHERE PayrollPeriodID = @PayrollPeriodID;
    
    -- Sync approved leave requests that affect payroll
    SELECT 
        lr.employee_id,
        e.full_name,
        lr.leave_id,
        l.leave_type,
        lr.duration,
        lr.status,
        'Leave approved and synced to payroll' AS sync_message
    FROM LeaveRequest lr
    INNER JOIN Employee e ON lr.employee_id = e.EmployeeID
    INNER JOIN Leave l ON lr.leave_id = l.LeaveID
    WHERE lr.status = 'Approved'
        AND lr.approval_timing BETWEEN @StartDate AND @EndDate;
    
    SELECT @SyncCount = @@ROWCOUNT;
    
    PRINT 'Synced ' + CAST(@SyncCount AS varchar(10)) + ' approved permissions to payroll period ' + CAST(@PayrollPeriodID AS varchar(10));
END
GO

-- ========================================
-- 14) Configure pay grades and salary bands
-- ========================================
IF OBJECT_ID('ConfigurePayGrades', 'P') IS NOT NULL
    DROP PROCEDURE ConfigurePayGrades;
GO

CREATE PROCEDURE ConfigurePayGrades
    @GradeName varchar(50),
    @MinSalary decimal(18,2),
    @MaxSalary decimal(18,2)
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validate salary range
    IF @MinSalary >= @MaxSalary
    BEGIN
        RAISERROR('Minimum salary must be less than maximum salary', 16, 1);
        RETURN;
    END
    
    IF @MinSalary < 0 OR @MaxSalary < 0
    BEGIN
        RAISERROR('Salary values must be positive', 16, 1);
        RETURN;
    END
    
    -- Check if grade name already exists
    IF EXISTS (SELECT 1 FROM PayGrade WHERE grade_name = @GradeName)
    BEGIN
        -- Update existing grade
        UPDATE PayGrade
        SET min_salary = @MinSalary,
            max_salary = @MaxSalary
        WHERE grade_name = @GradeName;
        
        PRINT 'Pay grade "' + @GradeName + '" updated successfully';
    END
    ELSE
    BEGIN
        -- Insert new grade
        DECLARE @NewID int = (SELECT ISNULL(MAX(PayGradeID), 0) + 1 FROM PayGrade);
        
        INSERT INTO PayGrade (PayGradeID, grade_name, min_salary, max_salary)
        VALUES (@NewID, @GradeName, @MinSalary, @MaxSalary);
        
        PRINT 'Pay grade "' + @GradeName + '" created successfully';
    END
END
GO

-- ========================================
-- 15) Configure shift differentials and special allowances
-- ========================================
IF OBJECT_ID('ConfigureShiftAllowances', 'P') IS NOT NULL
    DROP PROCEDURE ConfigureShiftAllowances;
GO

CREATE PROCEDURE ConfigureShiftAllowances
    @ShiftType varchar(50),
    @AllowanceName varchar(50),
    @Amount decimal(18,2)
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validate amount
    IF @Amount < 0
    BEGIN
        RAISERROR('Allowance amount must be positive', 16, 1);
        RETURN;
    END
    
    -- Create a policy for the shift allowance
    DECLARE @NewPolicyID int = (SELECT ISNULL(MAX(PolicyID), 0) + 1 FROM PayrollPolicy);
    
    INSERT INTO PayrollPolicy (PolicyID, effective_date, type, description)
    VALUES (@NewPolicyID, GETDATE(), 'Allowance', 
            'Shift: ' + @ShiftType + ' - ' + @AllowanceName + ' - Amount: $' + CAST(@Amount AS varchar(20)));
    
    PRINT 'Shift allowance configured successfully: ' + @ShiftType + ' - ' + @AllowanceName;
END
GO

-- ========================================
-- 16) Enable multi-currency payroll for international employees
-- ========================================
IF OBJECT_ID('EnableMultiCurrencyPayroll', 'P') IS NOT NULL
    DROP PROCEDURE EnableMultiCurrencyPayroll;
GO

CREATE PROCEDURE EnableMultiCurrencyPayroll
    @CurrencyCode varchar(10),
    @ExchangeRate decimal(18,4)
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validate exchange rate
    IF @ExchangeRate <= 0
    BEGIN
        RAISERROR('Exchange rate must be positive', 16, 1);
        RETURN;
    END
    
    -- Check if currency already exists
    IF EXISTS (SELECT 1 FROM Currency WHERE CurrencyCode = @CurrencyCode)
    BEGIN
        -- Update existing currency
        UPDATE Currency
        SET exchange_rate = @ExchangeRate,
            last_updated = GETDATE()
        WHERE CurrencyCode = @CurrencyCode;
        
        PRINT 'Currency ' + @CurrencyCode + ' updated with new exchange rate: ' + CAST(@ExchangeRate AS varchar(20));
    END
    ELSE
    BEGIN
        -- Insert new currency
        INSERT INTO Currency (CurrencyCode, currency_name, exchange_rate, created_date, last_updated)
        VALUES (@CurrencyCode, @CurrencyCode + ' Currency', @ExchangeRate, GETDATE(), GETDATE());
        
        PRINT 'Currency ' + @CurrencyCode + ' enabled with exchange rate: ' + CAST(@ExchangeRate AS varchar(20));
    END
END
GO

-- ========================================
-- 17) Define and update tax rules for payroll compliance
-- ========================================
IF OBJECT_ID('ManageTaxRules', 'P') IS NOT NULL
    DROP PROCEDURE ManageTaxRules;
GO

CREATE PROCEDURE ManageTaxRules
    @TaxRuleName varchar(50),
    @CountryCode varchar(10),
    @Rate decimal(5,2),
    @Exemption decimal(18,2)
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validate rate
    IF @Rate < 0 OR @Rate > 100
    BEGIN
        RAISERROR('Tax rate must be between 0 and 100', 16, 1);
        RETURN;
    END
    
    IF @Exemption < 0
    BEGIN
        RAISERROR('Exemption must be non-negative', 16, 1);
        RETURN;
    END
    
    -- Create or update tax form
    DECLARE @FormContent varchar(max) = 'Tax Rule: ' + @TaxRuleName + 
                                        ' | Country: ' + @CountryCode + 
                                        ' | Rate: ' + CAST(@Rate AS varchar(10)) + '%' +
                                        ' | Exemption: $' + CAST(@Exemption AS varchar(20));
    
    IF EXISTS (SELECT 1 FROM TaxForm WHERE jurisdiction = @CountryCode)
    BEGIN
        -- Update existing tax form
        UPDATE TaxForm
        SET form_content = @FormContent,
            validity_period = DATEADD(YEAR, 1, GETDATE())
        WHERE jurisdiction = @CountryCode;
        
        PRINT 'Tax rule "' + @TaxRuleName + '" updated for ' + @CountryCode;
    END
    ELSE
    BEGIN
        -- Create new tax form
        DECLARE @NewTaxFormID int = (SELECT ISNULL(MAX(TaxFormID), 0) + 1 FROM TaxForm);
        
        INSERT INTO TaxForm (TaxFormID, jurisdiction, validity_period, form_content)
        VALUES (@NewTaxFormID, @CountryCode, DATEADD(YEAR, 1, GETDATE()), @FormContent);
        
        PRINT 'Tax rule "' + @TaxRuleName + '" created for ' + @CountryCode;
    END
END
GO

-- ========================================
-- 18) Approve payroll configuration changes
-- ========================================
IF OBJECT_ID('ApprovePayrollConfigChanges', 'P') IS NOT NULL
    DROP PROCEDURE ApprovePayrollConfigChanges;
GO

CREATE PROCEDURE ApprovePayrollConfigChanges
    @ConfigID int,
    @ApproverID int,
    @Status varchar(20)
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validate approver exists
    IF NOT EXISTS (SELECT 1 FROM Employee WHERE EmployeeID = @ApproverID)
    BEGIN
        RAISERROR('Approver not found', 16, 1);
        RETURN;
    END
    
    -- Validate status
    IF @Status NOT IN ('Approved', 'Rejected', 'Pending')
    BEGIN
        RAISERROR('Status must be Approved, Rejected, or Pending', 16, 1);
        RETURN;
    END
    
    -- Validate config (using ApprovalWorkflow as config table)
    IF NOT EXISTS (SELECT 1 FROM ApprovalWorkflow WHERE WorkflowID = @ConfigID)
    BEGIN
        RAISERROR('Configuration not found', 16, 1);
        RETURN;
    END
    
    -- Update approval workflow status
    UPDATE ApprovalWorkflow
    SET status = @Status
    WHERE WorkflowID = @ConfigID;
    
    -- Log the approval
    DECLARE @NewLogID int = (SELECT ISNULL(MAX(payroll_log_id), 0) + 1 FROM PayrollLog);
    
    INSERT INTO PayrollLog (payroll_log_id, payroll_id, actor, change_date, modification_type)
    VALUES (@NewLogID, NULL, 
            'Approver ID: ' + CAST(@ApproverID AS varchar(10)), 
            GETDATE(), 
            'Config ' + CAST(@ConfigID AS varchar(10)) + ' - Status: ' + @Status);
    
    PRINT 'Configuration change ' + @Status + ' by approver ' + CAST(@ApproverID AS varchar(10));
END
GO

-- ========================================
-- 19) Configure signing bonuses for new hires
-- ========================================
IF OBJECT_ID('ConfigureSigningBonus', 'P') IS NOT NULL
    DROP PROCEDURE ConfigureSigningBonus;
GO

CREATE PROCEDURE ConfigureSigningBonus
    @EmployeeID int,
    @BonusAmount decimal(18,2),
    @EffectiveDate date
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validate employee exists
    IF NOT EXISTS (SELECT 1 FROM Employee WHERE EmployeeID = @EmployeeID)
    BEGIN
        RAISERROR('Employee not found', 16, 1);
        RETURN;
    END
    
    -- Validate bonus amount
    IF @BonusAmount <= 0
    BEGIN
        RAISERROR('Bonus amount must be positive', 16, 1);
        RETURN;
    END
    
    -- Validate effective date
    IF @EffectiveDate < CAST(GETDATE() AS date)
    BEGIN
        RAISERROR('Effective date cannot be in the past', 16, 1);
        RETURN;
    END
    
    -- Get employee currency
    DECLARE @Currency varchar(10);
    SELECT @Currency = st.currency 
    FROM Employee e
    INNER JOIN SalaryType st ON e.salary_type_id = st.SalaryTypeID
    WHERE e.EmployeeID = @EmployeeID;
    
    -- Create a signing bonus policy
    DECLARE @NewPolicyID int = (SELECT ISNULL(MAX(PolicyID), 0) + 1 FROM PayrollPolicy);
    
    INSERT INTO PayrollPolicy (PolicyID, effective_date, type, description)
    VALUES (@NewPolicyID, @EffectiveDate, 'Bonus', 
            'Signing Bonus for Employee ' + CAST(@EmployeeID AS varchar(10)) + ' - Amount: $' + CAST(@BonusAmount AS varchar(20)));
    
    -- Link to bonus policy
    INSERT INTO BonusPolicy (policy_id, bonus_type, eligibility_criteria)
    VALUES (@NewPolicyID, 'Signing Bonus', 'New hire employee ID: ' + CAST(@EmployeeID AS varchar(10)));
    
    PRINT 'Signing bonus of $' + CAST(@BonusAmount AS varchar(20)) + ' configured for employee ' + CAST(@EmployeeID AS varchar(10)) + ' effective ' + CAST(@EffectiveDate AS varchar(20));
END
GO

-- ========================================
-- 20) Configure termination and resignation compensations
-- ========================================
IF OBJECT_ID('ConfigureTerminationBenefits', 'P') IS NOT NULL
    DROP PROCEDURE ConfigureTerminationBenefits;
GO

CREATE PROCEDURE ConfigureTerminationBenefits
    @EmployeeID int,
    @CompensationAmount decimal(18,2),
    @EffectiveDate date,
    @Reason varchar(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validate employee exists
    IF NOT EXISTS (SELECT 1 FROM Employee WHERE EmployeeID = @EmployeeID)
    BEGIN
        RAISERROR('Employee not found', 16, 1);
        RETURN;
    END
    
    -- Validate compensation amount
    IF @CompensationAmount < 0
    BEGIN
        RAISERROR('Compensation amount must be non-negative', 16, 1);
        RETURN;
    END
    
    -- Validate effective date
    IF @EffectiveDate < CAST(GETDATE() AS date)
    BEGIN
        RAISERROR('Effective date cannot be in the past', 16, 1);
        RETURN;
    END
    
    -- Get employee contract
    DECLARE @ContractID int;
    SELECT @ContractID = contract_id FROM Employee WHERE EmployeeID = @EmployeeID;
    
    IF @ContractID IS NULL
    BEGIN
        RAISERROR('Employee has no active contract', 16, 1);
        RETURN;
    END
    
    -- Create termination record
    DECLARE @NewTerminationID int = (SELECT ISNULL(MAX(TerminationID), 0) + 1 FROM Termination);
    
    INSERT INTO Termination (TerminationID, date, reason, contract_id)
    VALUES (@NewTerminationID, @EffectiveDate, @Reason + ' | Compensation: $' + CAST(@CompensationAmount AS varchar(20)), @ContractID);
    
    -- Update employee status
    UPDATE Employee
    SET is_active = 0,
        employment_status = 'Terminated'
    WHERE EmployeeID = @EmployeeID;
    
    PRINT 'Termination benefits configured for employee ' + CAST(@EmployeeID AS varchar(10)) + 
          ' with compensation $' + CAST(@CompensationAmount AS varchar(20)) + ' effective ' + CAST(@EffectiveDate AS varchar(20));
END
GO

-- ========================================
-- 21) Configure insurance brackets with contribution percentages
-- ========================================
IF OBJECT_ID('ConfigureInsuranceBrackets', 'P') IS NOT NULL
    DROP PROCEDURE ConfigureInsuranceBrackets;
GO

CREATE PROCEDURE ConfigureInsuranceBrackets
    @InsuranceType varchar(50),
    @MinSalary decimal(18,2),
    @MaxSalary decimal(18,2),
    @EmployeeContribution decimal(5,2),
    @EmployerContribution decimal(5,2)
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validate salary range
    IF @MinSalary >= @MaxSalary
    BEGIN
        RAISERROR('Minimum salary must be less than maximum salary', 16, 1);
        RETURN;
    END
    
    IF @MinSalary < 0 OR @MaxSalary < 0
    BEGIN
        RAISERROR('Salary values must be non-negative', 16, 1);
        RETURN;
    END
    
    -- Validate contribution percentages
    IF @EmployeeContribution < 0 OR @EmployeeContribution > 100
    BEGIN
        RAISERROR('Employee contribution must be between 0 and 100', 16, 1);
        RETURN;
    END
    
    IF @EmployerContribution < 0 OR @EmployerContribution > 100
    BEGIN
        RAISERROR('Employer contribution must be between 0 and 100', 16, 1);
        RETURN;
    END
    
    -- Calculate total contribution rate
    DECLARE @TotalRate decimal(5,2) = @EmployeeContribution + @EmployerContribution;
    
    -- Create insurance record
    DECLARE @NewInsuranceID int = (SELECT ISNULL(MAX(InsuranceID), 0) + 1 FROM Insurance);
    
    DECLARE @Coverage varchar(max) = 'Salary Bracket: $' + CAST(@MinSalary AS varchar(20)) + ' - $' + CAST(@MaxSalary AS varchar(20)) +
                                     ' | Employee: ' + CAST(@EmployeeContribution AS varchar(10)) + '% | Employer: ' + CAST(@EmployerContribution AS varchar(10)) + '%';
    
    INSERT INTO Insurance (InsuranceID, type, contribution_rate, coverage)
    VALUES (@NewInsuranceID, @InsuranceType, @TotalRate, @Coverage);
    
    PRINT 'Insurance bracket configured: ' + @InsuranceType + ' for salary range $' + CAST(@MinSalary AS varchar(20)) + '-$' + CAST(@MaxSalary AS varchar(20));
END
GO

-- ========================================
-- 22) Update existing insurance brackets
-- ========================================
IF OBJECT_ID('UpdateInsuranceBrackets', 'P') IS NOT NULL
    DROP PROCEDURE UpdateInsuranceBrackets;
GO

CREATE PROCEDURE UpdateInsuranceBrackets
    @BracketID int,
    @MinSalary decimal(18,2),
    @MaxSalary decimal(18,2),
    @EmployeeContribution decimal(5,2),
    @EmployerContribution decimal(5,2)
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validate bracket exists
    IF NOT EXISTS (SELECT 1 FROM Insurance WHERE InsuranceID = @BracketID)
    BEGIN
        RAISERROR('Insurance bracket not found', 16, 1);
        RETURN;
    END
    
    -- Validate salary range
    IF @MinSalary >= @MaxSalary
    BEGIN
        RAISERROR('Minimum salary must be less than maximum salary', 16, 1);
        RETURN;
    END
    
    IF @MinSalary < 0 OR @MaxSalary < 0
    BEGIN
        RAISERROR('Salary values must be non-negative', 16, 1);
        RETURN;
    END
    
    -- Validate contribution percentages
    IF @EmployeeContribution < 0 OR @EmployeeContribution > 100 OR @EmployerContribution < 0 OR @EmployerContribution > 100
    BEGIN
        RAISERROR('Contribution percentages must be between 0 and 100', 16, 1);
        RETURN;
    END
    
    -- Calculate total contribution rate
    DECLARE @TotalRate decimal(5,2) = @EmployeeContribution + @EmployerContribution;
    
    DECLARE @Coverage varchar(max) = 'Salary Bracket: $' + CAST(@MinSalary AS varchar(20)) + ' - $' + CAST(@MaxSalary AS varchar(20)) +
                                     ' | Employee: ' + CAST(@EmployeeContribution AS varchar(10)) + '% | Employer: ' + CAST(@EmployerContribution AS varchar(10)) + '%';
    
    -- Update insurance bracket
    UPDATE Insurance
    SET contribution_rate = @TotalRate,
        coverage = @Coverage
    WHERE InsuranceID = @BracketID;
    
    PRINT 'Insurance bracket ' + CAST(@BracketID AS varchar(10)) + ' updated successfully';
END
GO

-- ========================================
-- 23) Configure payroll rules and structure
-- ========================================
IF OBJECT_ID('ConfigurePayrollPolicies', 'P') IS NOT NULL
    DROP PROCEDURE ConfigurePayrollPolicies;
GO

CREATE PROCEDURE ConfigurePayrollPolicies
    @PolicyType varchar(50),
    @PolicyDetails nvarchar(max),
    @EffectiveDate date
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validate policy type
    IF @PolicyType NOT IN ('Salary', 'Deduction', 'Bonus', 'Overtime', 'Allowance', 'Tax')
    BEGIN
        RAISERROR('Invalid policy type. Must be: Salary, Deduction, Bonus, Overtime, Allowance, or Tax', 16, 1);
        RETURN;
    END
    
    -- Validate effective date
    IF @EffectiveDate < CAST(GETDATE() AS date)
    BEGIN
        RAISERROR('Effective date cannot be in the past', 16, 1);
        RETURN;
    END
    
    -- Create payroll policy
    DECLARE @NewPolicyID int = (SELECT ISNULL(MAX(PolicyID), 0) + 1 FROM PayrollPolicy);
    
    INSERT INTO PayrollPolicy (PolicyID, effective_date, type, description)
    VALUES (@NewPolicyID, @EffectiveDate, @PolicyType, @PolicyDetails);
    
    -- Create specific policy record based on type
    IF @PolicyType = 'Bonus'
    BEGIN
        INSERT INTO BonusPolicy (policy_id, bonus_type, eligibility_criteria)
        VALUES (@NewPolicyID, 'Policy-Based', @PolicyDetails);
    END
    ELSE IF @PolicyType = 'Deduction'
    BEGIN
        INSERT INTO DeductionPolicy (policy_id, deduction_reason, calculation_mode)
        VALUES (@NewPolicyID, 'Policy-Based', 'Automated');
    END
    ELSE IF @PolicyType = 'Overtime'
    BEGIN
        INSERT INTO OvertimePolicy (policy_id, weekday_rate_multiplier, weekend_rate_multiplier, max_hours_per_month)
        VALUES (@NewPolicyID, 1.5, 2.0, 50);
    END
    
    PRINT 'Payroll policy configured: ' + @PolicyType + ' effective ' + CAST(@EffectiveDate AS varchar(20));
END
GO

-- ========================================
-- 24) Define and manage pay grades
-- ========================================
IF OBJECT_ID('DefinePayGrades', 'P') IS NOT NULL
    DROP PROCEDURE DefinePayGrades;
GO

CREATE PROCEDURE DefinePayGrades
    @GradeName varchar(50),
    @MinSalary decimal(18,2),
    @MaxSalary decimal(18,2),
    @CreatedBy int
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validate creator exists
    IF NOT EXISTS (SELECT 1 FROM Employee WHERE EmployeeID = @CreatedBy)
    BEGIN
        RAISERROR('Creator employee not found', 16, 1);
        RETURN;
    END
    
    -- Validate salary range
    IF @MinSalary >= @MaxSalary
    BEGIN
        RAISERROR('Minimum salary must be less than maximum salary', 16, 1);
        RETURN;
    END
    
    IF @MinSalary < 0 OR @MaxSalary < 0
    BEGIN
        RAISERROR('Salary values must be positive', 16, 1);
        RETURN;
    END
    
    -- Check if grade already exists
    IF EXISTS (SELECT 1 FROM PayGrade WHERE grade_name = @GradeName)
    BEGIN
        RAISERROR('Pay grade already exists', 16, 1);
        RETURN;
    END
    
    -- Create pay grade
    DECLARE @NewGradeID int = (SELECT ISNULL(MAX(PayGradeID), 0) + 1 FROM PayGrade);
    
    INSERT INTO PayGrade (PayGradeID, grade_name, min_salary, max_salary)
    VALUES (@NewGradeID, @GradeName, @MinSalary, @MaxSalary);
    
    -- Log the creation
    DECLARE @NewLogID int = (SELECT ISNULL(MAX(payroll_log_id), 0) + 1 FROM PayrollLog);
    
    INSERT INTO PayrollLog (payroll_log_id, payroll_id, actor, change_date, modification_type)
    VALUES (@NewLogID, NULL, 
            'Created by Employee ID: ' + CAST(@CreatedBy AS varchar(10)), 
            GETDATE(), 
            'Pay Grade Created: ' + @GradeName);
    
    PRINT 'Pay grade "' + @GradeName + '" defined successfully by employee ' + CAST(@CreatedBy AS varchar(10));
END
GO

-- ========================================
-- 25) Configure escalation workflows for deductions/overpayments
-- ========================================
IF OBJECT_ID('ConfigureEscalationWorkflow', 'P') IS NOT NULL
    DROP PROCEDURE ConfigureEscalationWorkflow;
GO

CREATE PROCEDURE ConfigureEscalationWorkflow
    @ThresholdAmount decimal(18,2),
    @ApproverRole varchar(50),
    @CreatedBy int
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validate threshold amount
    IF @ThresholdAmount <= 0
    BEGIN
        RAISERROR('Threshold amount must be positive', 16, 1);
        RETURN;
    END
    
    -- Validate creator exists
    IF NOT EXISTS (SELECT 1 FROM Employee WHERE EmployeeID = @CreatedBy)
    BEGIN
        RAISERROR('Creator employee not found', 16, 1);
        RETURN;
    END
    
    -- Validate approver role
    IF @ApproverRole NOT IN ('Manager', 'Director', 'VP', 'CFO', 'CEO')
    BEGIN
        RAISERROR('Invalid approver role. Must be: Manager, Director, VP, CFO, or CEO', 16, 1);
        RETURN;
    END
    
    -- Create escalation workflow
    DECLARE @NewWorkflowID int = (SELECT ISNULL(MAX(WorkflowID), 0) + 1 FROM ApprovalWorkflow);
    
    INSERT INTO ApprovalWorkflow (WorkflowID, workflow_type, threshold_amount, approved_role, created_by, status)
    VALUES (@NewWorkflowID, 'Payroll Escalation', @ThresholdAmount, @ApproverRole, @CreatedBy, 'Active');
    
    PRINT 'Escalation workflow configured: Amounts > $' + CAST(@ThresholdAmount AS varchar(20)) + 
          ' require ' + @ApproverRole + ' approval';
END
GO

-- ========================================
-- 26) Define employee pay types
-- ========================================
IF OBJECT_ID('DefinePayType', 'P') IS NOT NULL
    DROP PROCEDURE DefinePayType;
GO

CREATE PROCEDURE DefinePayType
    @EmployeeID int,
    @PayType varchar(50),
    @EffectiveDate date
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validate employee exists
    IF NOT EXISTS (SELECT 1 FROM Employee WHERE EmployeeID = @EmployeeID)
    BEGIN
        RAISERROR('Employee not found', 16, 1);
        RETURN;
    END
    
    -- Validate pay type
    IF @PayType NOT IN ('Hourly', 'Daily', 'Weekly', 'Monthly', 'Contract')
    BEGIN
        RAISERROR('Invalid pay type. Must be: Hourly, Daily, Weekly, Monthly, or Contract', 16, 1);
        RETURN;
    END
    
    -- Validate effective date
    IF @EffectiveDate < CAST(GETDATE() AS date)
    BEGIN
        RAISERROR('Effective date cannot be in the past', 16, 1);
        RETURN;
    END
    
    -- Get or create salary type
    DECLARE @SalaryTypeID int;
    DECLARE @Currency varchar(10);
    
    -- Get employee's current currency or default to USD
    SELECT @Currency = ISNULL(st.currency, 'USD')
    FROM Employee e
    LEFT JOIN SalaryType st ON e.salary_type_id = st.SalaryTypeID
    WHERE e.EmployeeID = @EmployeeID;
    
    -- Find or create salary type
    SELECT @SalaryTypeID = SalaryTypeID 
    FROM SalaryType 
    WHERE type = @PayType AND currency = @Currency;
    
    IF @SalaryTypeID IS NULL
    BEGIN
        SET @SalaryTypeID = (SELECT ISNULL(MAX(SalaryTypeID), 0) + 1 FROM SalaryType);
        
        INSERT INTO SalaryType (SalaryTypeID, type, payment_frequency, currency)
        VALUES (@SalaryTypeID, @PayType, 
                CASE @PayType 
                    WHEN 'Hourly' THEN 'Weekly'
                    WHEN 'Daily' THEN 'Weekly'
                    WHEN 'Weekly' THEN 'Weekly'
                    WHEN 'Monthly' THEN 'Monthly'
                    WHEN 'Contract' THEN 'Milestone'
                END, @Currency);
    END
    
    -- Update employee salary type
    UPDATE Employee
    SET salary_type_id = @SalaryTypeID
    WHERE EmployeeID = @EmployeeID;
    
    PRINT 'Pay type "' + @PayType + '" defined for employee ' + CAST(@EmployeeID AS varchar(10)) + 
          ' effective ' + CAST(@EffectiveDate AS varchar(20));
END
GO

-- ========================================
-- 27) Configure overtime rules
-- ========================================
IF OBJECT_ID('ConfigureOvertimeRules', 'P') IS NOT NULL
    DROP PROCEDURE ConfigureOvertimeRules;
GO

CREATE PROCEDURE ConfigureOvertimeRules
    @DayType varchar(20),
    @Multiplier decimal(3,2),
    @HoursPerMonth int
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validate day type
    IF @DayType NOT IN ('Weekday', 'Weekend', 'Holiday')
    BEGIN
        RAISERROR('Invalid day type. Must be: Weekday, Weekend, or Holiday', 16, 1);
        RETURN;
    END
    
    -- Validate multiplier
    IF @Multiplier < 1.0 OR @Multiplier > 5.0
    BEGIN
        RAISERROR('Multiplier must be between 1.0 and 5.0', 16, 1);
        RETURN;
    END
    
    -- Validate hours per month
    IF @HoursPerMonth < 0 OR @HoursPerMonth > 200
    BEGIN
        RAISERROR('Hours per month must be between 0 and 200', 16, 1);
        RETURN;
    END
    
    -- Create payroll policy for overtime
    DECLARE @NewPolicyID int = (SELECT ISNULL(MAX(PolicyID), 0) + 1 FROM PayrollPolicy);
    
    INSERT INTO PayrollPolicy (PolicyID, effective_date, type, description)
    VALUES (@NewPolicyID, GETDATE(), 'Overtime', 
            @DayType + ' Overtime: ' + CAST(@Multiplier AS varchar(10)) + 'x rate, max ' + CAST(@HoursPerMonth AS varchar(10)) + ' hours/month');
    
    -- Create overtime policy
    INSERT INTO OvertimePolicy (policy_id, weekday_rate_multiplier, weekend_rate_multiplier, max_hours_per_month)
    VALUES (@NewPolicyID, 
            CASE WHEN @DayType = 'Weekday' THEN @Multiplier ELSE 1.5 END,
            CASE WHEN @DayType IN ('Weekend', 'Holiday') THEN @Multiplier ELSE 2.0 END,
            @HoursPerMonth);
    
    PRINT 'Overtime rule configured for ' + @DayType + ': ' + CAST(@Multiplier AS varchar(10)) + 
          'x multiplier, max ' + CAST(@HoursPerMonth AS varchar(10)) + ' hours/month';
END
GO

-- ========================================
-- 28) Set shift differentials and special condition allowances
-- ========================================
IF OBJECT_ID('ConfigureShiftAllowance', 'P') IS NOT NULL
    DROP PROCEDURE ConfigureShiftAllowance;
GO

CREATE PROCEDURE ConfigureShiftAllowance
    @ShiftType varchar(20),
    @AllowanceAmount decimal(18,2),
    @CreatedBy int
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validate creator exists
    IF NOT EXISTS (SELECT 1 FROM Employee WHERE EmployeeID = @CreatedBy)
    BEGIN
        RAISERROR('Creator employee not found', 16, 1);
        RETURN;
    END
    
    -- Validate shift type
    IF @ShiftType NOT IN ('Night', 'Weekend', 'Holiday', 'Hazard', 'Remote')
    BEGIN
        RAISERROR('Invalid shift type. Must be: Night, Weekend, Holiday, Hazard, or Remote', 16, 1);
        RETURN;
    END
    
    -- Validate allowance amount
    IF @AllowanceAmount <= 0
    BEGIN
        RAISERROR('Allowance amount must be positive', 16, 1);
        RETURN;
    END
    
    -- Create payroll policy for shift allowance
    DECLARE @NewPolicyID int = (SELECT ISNULL(MAX(PolicyID), 0) + 1 FROM PayrollPolicy);
    
    INSERT INTO PayrollPolicy (PolicyID, effective_date, type, description)
    VALUES (@NewPolicyID, GETDATE(), 'Allowance', 
            @ShiftType + ' Shift Allowance: $' + CAST(@AllowanceAmount AS varchar(20)) + ' per period');
    
    -- Log the configuration
    DECLARE @NewLogID int = (SELECT ISNULL(MAX(payroll_log_id), 0) + 1 FROM PayrollLog);
    
    INSERT INTO PayrollLog (payroll_log_id, payroll_id, actor, change_date, modification_type)
    VALUES (@NewLogID, NULL, 
            'Created by Employee ID: ' + CAST(@CreatedBy AS varchar(10)), 
            GETDATE(), 
            'Shift Allowance Created: ' + @ShiftType + ' - $' + CAST(@AllowanceAmount AS varchar(20)));
    
    PRINT @ShiftType + ' shift allowance of $' + CAST(@AllowanceAmount AS varchar(20)) + ' configured successfully by employee ' + CAST(@CreatedBy AS varchar(10));
END
GO

-- ========================================
-- 30) Configure policies for signing bonuses and payroll initiation
-- ========================================
IF OBJECT_ID('ConfigureSigningBonusPolicy', 'P') IS NOT NULL
    DROP PROCEDURE ConfigureSigningBonusPolicy;
GO

CREATE PROCEDURE ConfigureSigningBonusPolicy
    @BonusType varchar(50),
    @Amount decimal(18,2),
    @EligibilityCriteria nvarchar(max)
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validate bonus type
    IF @BonusType NOT IN ('Signing', 'Retention', 'Relocation', 'Performance')
    BEGIN
        RAISERROR('Invalid bonus type. Must be: Signing, Retention, Relocation, or Performance', 16, 1);
        RETURN;
    END
    
    -- Validate amount
    IF @Amount <= 0
    BEGIN
        RAISERROR('Bonus amount must be positive', 16, 1);
        RETURN;
    END
    
    -- Create payroll policy for signing bonus
    DECLARE @NewPolicyID int = (SELECT ISNULL(MAX(PolicyID), 0) + 1 FROM PayrollPolicy);
    
    DECLARE @Description nvarchar(max) = @BonusType + ' Bonus Policy: $' + CAST(@Amount AS varchar(20)) + 
                                         ' | Eligibility: ' + @EligibilityCriteria;
    
    INSERT INTO PayrollPolicy (PolicyID, effective_date, type, description)
    VALUES (@NewPolicyID, GETDATE(), 'Bonus', @Description);
    
    -- Create bonus policy record
    INSERT INTO BonusPolicy (policy_id, bonus_type, eligibility_criteria)
    VALUES (@NewPolicyID, @BonusType + ' Bonus', @EligibilityCriteria);
    
    PRINT @BonusType + ' bonus policy configured: $' + CAST(@Amount AS varchar(20)) + ' for eligible new hires';
END
GO

-- ========================================
-- 32) Generate tax statements for employees annually
-- ========================================
IF OBJECT_ID('GenerateTaxStatement', 'P') IS NOT NULL
    DROP PROCEDURE GenerateTaxStatement;
GO

CREATE PROCEDURE GenerateTaxStatement
    @EmployeeID int,
    @TaxYear int
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validate employee exists
    IF NOT EXISTS (SELECT 1 FROM Employee WHERE EmployeeID = @EmployeeID)
    BEGIN
        RAISERROR('Employee not found', 16, 1);
        RETURN;
    END
    
    -- Validate tax year
    IF @TaxYear < 2000 OR @TaxYear > YEAR(GETDATE()) + 1
    BEGIN
        RAISERROR('Invalid tax year', 16, 1);
        RETURN;
    END
    
    -- Generate tax statement summary
    SELECT 
        e.EmployeeID,
        e.full_name,
        e.national_id,
        @TaxYear AS tax_year,
        tf.jurisdiction,
        CAST(tf.form_content AS varchar(max)) AS tax_form_type,
        COUNT(DISTINCT p.PayrollID) AS pay_periods,
        SUM(p.base_amount) AS total_gross_income,
        SUM(p.adjustments) AS total_adjustments,
        SUM(p.taxes) AS total_taxes_withheld,
        SUM(p.contributions) AS total_contributions,
        SUM(p.net_salary) AS total_net_pay,
        MIN(p.period_start) AS first_pay_period,
        MAX(p.period_end) AS last_pay_period,
        GETDATE() AS statement_generated_date
    FROM Employee e
    LEFT JOIN TaxForm tf ON e.taxform_id = tf.TaxFormID
    LEFT JOIN Payroll p ON e.EmployeeID = p.employee_id 
        AND YEAR(p.period_start) = @TaxYear
    WHERE e.EmployeeID = @EmployeeID
    GROUP BY e.EmployeeID, e.full_name, e.national_id, tf.jurisdiction, CAST(tf.form_content AS varchar(max));
    
    PRINT 'Tax statement generated for employee ' + CAST(@EmployeeID AS varchar(10)) + ' for tax year ' + CAST(@TaxYear AS varchar(4));
END
GO

-- ========================================
-- 33) Approve configuration changes made by Payroll Specialists
-- ========================================
IF OBJECT_ID('ApprovePayrollConfiguration', 'P') IS NOT NULL
    DROP PROCEDURE ApprovePayrollConfiguration;
GO

CREATE PROCEDURE ApprovePayrollConfiguration
    @ConfigID int,
    @ApprovedBy int
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validate approver exists
    IF NOT EXISTS (SELECT 1 FROM Employee WHERE EmployeeID = @ApprovedBy)
    BEGIN
        RAISERROR('Approver employee not found', 16, 1);
        RETURN;
    END
    
    -- Validate configuration exists
    IF NOT EXISTS (SELECT 1 FROM ApprovalWorkflow WHERE WorkflowID = @ConfigID)
    BEGIN
        RAISERROR('Configuration not found', 16, 1);
        RETURN;
    END
    
    -- Check if configuration is in Pending status
    DECLARE @CurrentStatus varchar(50);
    SELECT @CurrentStatus = status FROM ApprovalWorkflow WHERE WorkflowID = @ConfigID;
    
    IF @CurrentStatus <> 'Pending'
    BEGIN
        RAISERROR('Configuration is not in Pending status', 16, 1);
        RETURN;
    END
    
    -- Update workflow status to Approved
    UPDATE ApprovalWorkflow
    SET status = 'Approved'
    WHERE WorkflowID = @ConfigID;
    
    -- Log the approval
    DECLARE @NewLogID int = (SELECT ISNULL(MAX(payroll_log_id), 0) + 1 FROM PayrollLog);
    
    INSERT INTO PayrollLog (payroll_log_id, payroll_id, actor, change_date, modification_type)
    VALUES (@NewLogID, NULL, 
            'Approved by Employee ID: ' + CAST(@ApprovedBy AS varchar(10)), 
            GETDATE(), 
            'Configuration Approved: Config ID ' + CAST(@ConfigID AS varchar(10)));
    
    PRINT 'Configuration ' + CAST(@ConfigID AS varchar(10)) + ' approved successfully by employee ' + CAST(@ApprovedBy AS varchar(10));
END
GO

-- ========================================
-- 34) Modify or correct payroll entries when authorized
-- ========================================
IF OBJECT_ID('ModifyPastPayroll', 'P') IS NOT NULL
    DROP PROCEDURE ModifyPastPayroll;
GO

CREATE PROCEDURE ModifyPastPayroll
    @PayrollRunID int,
    @EmployeeID int,
    @FieldName varchar(50),
    @NewValue decimal(18,2),
    @ModifiedBy int
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validate modifier exists
    IF NOT EXISTS (SELECT 1 FROM Employee WHERE EmployeeID = @ModifiedBy)
    BEGIN
        RAISERROR('Modifier employee not found', 16, 1);
        RETURN;
    END
    
    -- Validate payroll exists
    IF NOT EXISTS (SELECT 1 FROM Payroll WHERE PayrollID = @PayrollRunID AND employee_id = @EmployeeID)
    BEGIN
        RAISERROR('Payroll record not found for specified employee', 16, 1);
        RETURN;
    END
    
    -- Validate field name
    IF @FieldName NOT IN ('base_amount', 'adjustments', 'taxes', 'contributions', 'net_salary')
    BEGIN
        RAISERROR('Invalid field name. Must be: base_amount, adjustments, taxes, contributions, or net_salary', 16, 1);
        RETURN;
    END
    
    -- Store old value for logging
    DECLARE @OldValue decimal(18,2);
    DECLARE @SQL nvarchar(max);
    
    SET @SQL = N'SELECT @OldValue = ' + QUOTENAME(@FieldName) + ' FROM Payroll WHERE PayrollID = @PayrollRunID';
    EXEC sp_executesql @SQL, N'@OldValue decimal(18,2) OUTPUT, @PayrollRunID int', @OldValue OUTPUT, @PayrollRunID;
    
    -- Update the specified field
    IF @FieldName = 'base_amount'
    BEGIN
        UPDATE Payroll SET base_amount = @NewValue WHERE PayrollID = @PayrollRunID AND employee_id = @EmployeeID;
    END
    ELSE IF @FieldName = 'adjustments'
    BEGIN
        UPDATE Payroll SET adjustments = @NewValue WHERE PayrollID = @PayrollRunID AND employee_id = @EmployeeID;
    END
    ELSE IF @FieldName = 'taxes'
    BEGIN
        UPDATE Payroll SET taxes = @NewValue WHERE PayrollID = @PayrollRunID AND employee_id = @EmployeeID;
    END
    ELSE IF @FieldName = 'contributions'
    BEGIN
        UPDATE Payroll SET contributions = @NewValue WHERE PayrollID = @PayrollRunID AND employee_id = @EmployeeID;
    END
    ELSE IF @FieldName = 'net_salary'
    BEGIN
        UPDATE Payroll 
        SET net_salary = @NewValue, 
            actual_pay = @NewValue 
        WHERE PayrollID = @PayrollRunID AND employee_id = @EmployeeID;
    END
    
    -- Recalculate net salary if not directly modified
    IF @FieldName <> 'net_salary'
    BEGIN
        UPDATE Payroll
        SET net_salary = base_amount + adjustments - taxes - contributions,
            actual_pay = base_amount + adjustments - taxes - contributions
        WHERE PayrollID = @PayrollRunID AND employee_id = @EmployeeID;
    END
    
    -- Log the modification
    DECLARE @NewLogID int = (SELECT ISNULL(MAX(payroll_log_id), 0) + 1 FROM PayrollLog);
    
    INSERT INTO PayrollLog (payroll_log_id, payroll_id, actor, change_date, modification_type)
    VALUES (@NewLogID, @PayrollRunID, 
            'Modified by Employee ID: ' + CAST(@ModifiedBy AS varchar(10)), 
            GETDATE(), 
            'Field: ' + @FieldName + ' | Old: $' + CAST(@OldValue AS varchar(20)) + ' | New: $' + CAST(@NewValue AS varchar(20)));
    
    PRINT 'Payroll ' + CAST(@PayrollRunID AS varchar(10)) + ' modified successfully: ' + @FieldName + ' changed from $' + CAST(@OldValue AS varchar(20)) + ' to $' + CAST(@NewValue AS varchar(20));
END
GO
