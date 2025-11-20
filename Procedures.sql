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

    IF @EmployeeID IS NULL OR @NewManagerID IS NULL
    BEGIN
        RAISERROR('Both EmployeeID and NewManagerID are required.', 16, 1);
        RETURN;
    END

    IF @EmployeeID = @NewManagerID
    BEGIN
        RAISERROR('Employee cannot be their own manager.', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM dbo.Employee WHERE EmployeeID = @EmployeeID)
    BEGIN
        RAISERROR('Employee with the specified EmployeeID does not exist.', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM dbo.Employee WHERE EmployeeID = @NewManagerID)
    BEGIN
        RAISERROR('Employee with the specified NewManagerID does not exist.', 16, 1);
        RETURN;
    END

    -- Prevent cycles: ensure @NewManagerID is not a subordinate of @EmployeeID
    DECLARE @current INT = @NewManagerID;
    WHILE @current IS NOT NULL
    BEGIN
        IF @current = @EmployeeID
        BEGIN
            RAISERROR('Cannot assign a subordinate as manager (would create a cycle).', 16, 1);
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

    IF @EmployeeID IS NULL
    BEGIN
        RAISERROR('EmployeeID is required.', 16, 1);
        RETURN;
    END

    IF @NewDepartmentID IS NULL AND @NewManagerID IS NULL
    BEGIN
        RAISERROR('Either NewDepartmentID or NewManagerID must be provided.', 16, 1);
        RETURN;
    END

    -- validate employee exists
    IF NOT EXISTS (SELECT 1 FROM dbo.Employee WHERE EmployeeID = @EmployeeID)
    BEGIN
        RAISERROR('Employee with the specified EmployeeID does not exist.', 16, 1);
        RETURN;
    END

    -- validate department if provided
    IF @NewDepartmentID IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.Department WHERE DepartmentID = @NewDepartmentID)
    BEGIN
        RAISERROR('Department with the specified NewDepartmentID does not exist.', 16, 1);
        RETURN;
    END

    -- validate new manager if provided
    IF @NewManagerID IS NOT NULL
    BEGIN
        IF @NewManagerID = @EmployeeID
        BEGIN
            RAISERROR('Employee cannot be their own manager.', 16, 1);
            RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM dbo.Employee WHERE EmployeeID = @NewManagerID)
        BEGIN
            RAISERROR('Employee with the specified NewManagerID does not exist.', 16, 1);
            RETURN;
        END

        -- Prevent cycles: ensure @NewManagerID is not a subordinate of @EmployeeID
        DECLARE @current INT = @NewManagerID;
        WHILE @current IS NOT NULL
        BEGIN
            IF @current = @EmployeeID
            BEGIN
                RAISERROR('Cannot assign a subordinate as manager (would create a cycle).', 16, 1);
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

        SELECT 'Hierarchy reassigned' AS Message, @EmployeeID AS EmployeeID,
               @NewDepartmentID AS NewDepartmentID, @NewManagerID AS NewManagerID;
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
-- Procedure: NotifyStructureChangey
-- Input: @AffectedEmployees varchar(500) -- comma-separated EmployeeIDs
--        @Message varchar(200)
-- Output: Confirmation message

CREATE OR ALTER PROCEDURE dbo.NotifyStructureChange
(
    @AffectedEmployees VARCHAR(500),
    @Message            VARCHAR(200)
)
AS
BEGIN
    SET NOCOUNT ON;

    IF @AffectedEmployees IS NULL OR LTRIM(RTRIM(@AffectedEmployees)) = ''
    BEGIN
        RAISERROR('AffectedEmployees is required (comma-separated EmployeeIDs).', 16, 1);
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Generate NotificationID
        DECLARE @NotificationID INT;
        SELECT @NotificationID = ISNULL(MAX(NotificationID), 0) + 1
        FROM dbo.Notification WITH (TABLOCKX, HOLDLOCK);

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
            'Normal',
            0,
            'StructureChange'
        );

        -- parse affected employees into table variable
        DECLARE @Ids TABLE (EmployeeID INT PRIMARY KEY);
        INSERT INTO @Ids (EmployeeID)
        SELECT DISTINCT TRY_CAST(LTRIM(RTRIM([value])) AS INT)
        FROM STRING_SPLIT(@AffectedEmployees, ',')
        WHERE TRY_CAST(LTRIM(RTRIM([value])) AS INT) IS NOT NULL;

        -- Insert EmployeeNotification entries only for existing employees
        INSERT INTO dbo.EmployeeNotification (employee_id, notification_id, delivery_status, delivered_at)
        SELECT e.EmployeeID, @NotificationID, 'Pending', NULL
        FROM @Ids i
        INNER JOIN dbo.Employee e ON e.EmployeeID = i.EmployeeID;

        COMMIT TRANSACTION;

        DECLARE @InsertedCount INT = (SELECT COUNT(*) FROM dbo.EmployeeNotification WHERE notification_id = @NotificationID);
        SELECT 'Notifications created' AS Message, @NotificationID AS NotificationID, @InsertedCount AS NotifiedEmployees;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('NotifyStructureChange failed: %s', 16, 1, @ErrMsg);
        RETURN;
    END CATCH
END
GO

--9
-- Procedure: ViewOrgHierarchy
-- Input: @AffectedEmployees varchar(500) (optional filter: comma-separated EmployeeIDs)
--        @Message varchar(200) (optional, unused but accepted per signature)
-- Output: Table showing employee names, managers, departments, positions, and hierarchy levels.

CREATE OR ALTER PROCEDURE dbo.ViewOrgHierarchy
(
    @AffectedEmployees VARCHAR(500) = NULL,
    @Message            VARCHAR(200) = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    -- optional filter parsing
    DECLARE @Filter TABLE (EmployeeID INT PRIMARY KEY);
    IF @AffectedEmployees IS NOT NULL AND LTRIM(RTRIM(@AffectedEmployees)) <> ''
    BEGIN
        INSERT INTO @Filter (EmployeeID)
        SELECT DISTINCT TRY_CAST(LTRIM(RTRIM([value])) AS INT)
        FROM STRING_SPLIT(@AffectedEmployees, ',')
        WHERE TRY_CAST(LTRIM(RTRIM([value])) AS INT) IS NOT NULL;
    END

    ;WITH OrgCTE AS
    (
        -- root nodes (top-level managers)
        SELECT
            e.EmployeeID,
            (e.first_name + CASE WHEN e.last_name IS NULL OR e.last_name = '' THEN '' ELSE ' ' + e.last_name END) AS FullName,
            e.manager_id,
            e.department_id,
            e.position_id,
            0 AS HierarchyLevel
        FROM dbo.Employee e
        WHERE e.manager_id IS NULL

        UNION ALL

        -- recursive step
        SELECT
            e.EmployeeID,
            (e.first_name + CASE WHEN e.last_name IS NULL OR e.last_name = '' THEN '' ELSE ' ' + e.last_name END) AS FullName,
            e.manager_id,
            e.department_id,
            e.position_id,
            c.HierarchyLevel + 1
        FROM dbo.Employee e
        INNER JOIN OrgCTE c ON e.manager_id = c.EmployeeID
    )
    SELECT
        o.EmployeeID,
        o.FullName AS EmployeeName,
        o.manager_id AS ManagerID,
        (mgr.first_name + CASE WHEN mgr.last_name IS NULL OR mgr.last_name = '' THEN '' ELSE ' ' + mgr.last_name END) AS ManagerName,
        o.department_id AS DepartmentID,
        d.department_name AS DepartmentName,
        o.position_id AS PositionID,
        p.position_title AS PositionTitle,
        o.HierarchyLevel
    FROM OrgCTE o
    LEFT JOIN dbo.Employee mgr ON o.manager_id = mgr.EmployeeID
    LEFT JOIN dbo.Department d ON o.department_id = d.DepartmentID
    LEFT JOIN dbo.Position p ON o.position_id = p.PositionID
    WHERE
        -- apply optional filter if provided; otherwise return full hierarchy
        (NOT EXISTS (SELECT 1 FROM @Filter) OR o.EmployeeID IN (SELECT EmployeeID FROM @Filter))
    ORDER BY o.HierarchyLevel, o.FullName;
END
GO

--10
-- Procedure: AssignShiftToEmployee
-- Input: @EmployeeID int, @ShiftID int, @StartDate date, @EndDate date
-- Output: Confirmation message

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

    IF @EmployeeID IS NULL
    BEGIN
        RAISERROR('EmployeeID is required.', 16, 1);
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

    IF NOT EXISTS (SELECT 1 FROM dbo.Employee WHERE EmployeeID = @EmployeeID)
    BEGIN
        RAISERROR('Employee with the specified ID does not exist.', 16, 1);
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        -- prevent overlapping assignments for the same employee
        IF EXISTS (
            SELECT 1 FROM dbo.ShiftSchedule ss
            WHERE ss.employee_id = @EmployeeID
              AND NOT (ss.end_date < @StartDate OR ss.start_date > @EndDate)
              AND ISNULL(ss.status, '') <> 'Cancelled'
        )
        BEGIN
            RAISERROR('Employee has an overlapping shift assignment for the specified term.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- generate new ShiftSchedule primary key (ShiftID)
        DECLARE @NewShiftScheduleID INT;
        SELECT @NewShiftScheduleID = ISNULL(MAX(ShiftID), 0) + 1
        FROM dbo.ShiftSchedule WITH (TABLOCKX, HOLDLOCK);

        INSERT INTO dbo.ShiftSchedule
        (
            ShiftID,
            employee_id,
            shift_id,
            start_date,
            end_date,
            status
        )
        VALUES
        (
            @NewShiftScheduleID,
            @EmployeeID,
            @ShiftID,
            @StartDate,
            @EndDate,
            'Active'
        );

        COMMIT TRANSACTION;

        SELECT 'Shift assigned' AS Message, @NewShiftScheduleID AS ShiftScheduleID, @EmployeeID AS EmployeeID, @ShiftID AS ShiftID, @StartDate AS StartDate, @EndDate AS EndDate;
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

