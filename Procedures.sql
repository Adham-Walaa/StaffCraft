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

