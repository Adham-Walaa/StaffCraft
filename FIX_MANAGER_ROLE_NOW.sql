-- =============================================
-- EMERGENCY FIX FOR MANAGER ROLE REGISTRATION
-- =============================================
-- Copy this ENTIRE script and paste it into SQL Server Management Studio (SSMS)
-- Then press F5 or click Execute
-- This will fix the "Invalid role" error when registering Manager accounts
-- =============================================

USE [Your_Database_Name_Here];  -- IMPORTANT: Change this to your actual database name!
GO

PRINT '================================================';
PRINT 'Starting Manager Role Fix...';
PRINT '================================================';
PRINT '';

-- Step 1: Add Manager role to Role table if it doesn't exist
PRINT 'Step 1: Adding Manager role to Role table...';
GO

IF NOT EXISTS (SELECT 1 FROM Role WHERE RoleName = 'Manager')
BEGIN
    DECLARE @MaxRoleID INT;
    SELECT @MaxRoleID = ISNULL(MAX(RoleID), 0) FROM Role;
    
    INSERT INTO Role (RoleID, RoleName, Purpose)
    VALUES (@MaxRoleID + 1, 'Manager', 'Manages team attendance, assigns shifts, approves correction requests');
    
    PRINT 'SUCCESS: Manager role added to Role table with RoleID = ' + CAST(@MaxRoleID + 1 AS VARCHAR(10));
END
ELSE
BEGIN
    PRINT 'INFO: Manager role already exists in Role table - skipping';
END
PRINT '';
GO

-- Step 2: Update the ManageUserAccounts stored procedure
PRINT 'Step 2: Updating ManageUserAccounts stored procedure...';
GO

ALTER PROCEDURE [dbo].[ManageUserAccounts]
    @Action VARCHAR(20),
    @Email VARCHAR(100),
    @Password VARCHAR(255) = NULL,
    @Role VARCHAR(50) = NULL,
    @FirstName VARCHAR(50) = NULL,
    @LastName VARCHAR(50) = NULL,
    @DOB DATE = NULL,
    @PhoneNumber VARCHAR(20) = NULL,
    @Address VARCHAR(255) = NULL,
    @City VARCHAR(100) = NULL,
    @Country VARCHAR(100) = NULL,
    @GoverningCity VARCHAR(100) = NULL,
    @Salary DECIMAL(10, 2) = NULL,
    @HireDate DATE = NULL,
    @Department VARCHAR(100) = NULL,
    @Position VARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Validate role
    IF @Role NOT IN ('System Administrator', 'HR Administrator', 'Payroll Officer', 'Payroll Specialist', 'Line Manager', 'Manager', 'Employee')
    BEGIN
        RAISERROR('Invalid role. Valid roles are: System Administrator, HR Administrator, Payroll Officer, Payroll Specialist, Line Manager, Manager, Employee.', 16, 1);
        RETURN;
    END

    -- Handle different actions
    IF @Action = 'Register'
    BEGIN
        -- Check if user already exists
        IF EXISTS (SELECT 1 FROM Login WHERE Email = @Email)
        BEGIN
            RAISERROR('User with this email already exists.', 16, 1);
            RETURN;
        END

        -- Get the RoleID
        DECLARE @RoleID INT;
        SELECT @RoleID = RoleID FROM Role WHERE RoleName = @Role;

        IF @RoleID IS NULL
        BEGIN
            RAISERROR('Role not found in database.', 16, 1);
            RETURN;
        END

        -- Insert into Employee table
        DECLARE @EmployeeID INT;
        SELECT @EmployeeID = ISNULL(MAX(EmployeeID), 0) + 1 FROM Employee;

        INSERT INTO Employee (EmployeeID, FirstName, LastName, DateOfBirth, Email, PhoneNumber, [Address], City, Country, GoverningCity, Salary, HireDate)
        VALUES (@EmployeeID, @FirstName, @LastName, @DOB, @Email, @PhoneNumber, @Address, @City, @Country, @GoverningCity, @Salary, @HireDate);

        -- Insert into Login table
        INSERT INTO Login (Email, [Password])
        VALUES (@Email, @Password);

        -- Insert into EmployeeRole table
        INSERT INTO EmployeeRole (EmployeeID, RoleID)
        VALUES (@EmployeeID, @RoleID);

        PRINT 'User registered successfully.';
    END
    ELSE IF @Action = 'Login'
    BEGIN
        -- Verify credentials
        IF EXISTS (SELECT 1 FROM Login WHERE Email = @Email AND [Password] = @Password)
        BEGIN
            PRINT 'Login successful.';
        END
        ELSE
        BEGIN
            RAISERROR('Invalid email or password.', 16, 1);
        END
    END
    ELSE
    BEGIN
        RAISERROR('Invalid action. Valid actions are: Register, Login.', 16, 1);
    END
END
GO

PRINT 'SUCCESS: ManageUserAccounts procedure updated';
PRINT '';
GO

-- Step 3: Verify the fix
PRINT '================================================';
PRINT 'Verification:';
PRINT '================================================';

-- Check if Manager role exists
IF EXISTS (SELECT 1 FROM Role WHERE RoleName = 'Manager')
BEGIN
    DECLARE @ManagerRoleID INT;
    SELECT @ManagerRoleID = RoleID FROM Role WHERE RoleName = 'Manager';
    PRINT 'PASS: Manager role exists with RoleID = ' + CAST(@ManagerRoleID AS VARCHAR(10));
END
ELSE
BEGIN
    PRINT 'FAIL: Manager role does NOT exist in Role table';
END

-- Check if procedure was updated
IF EXISTS (
    SELECT 1 FROM sys.procedures 
    WHERE name = 'ManageUserAccounts' 
    AND OBJECT_DEFINITION(object_id) LIKE '%Manager%'
)
BEGIN
    PRINT 'PASS: ManageUserAccounts procedure includes Manager role';
END
ELSE
BEGIN
    PRINT 'FAIL: ManageUserAccounts procedure does NOT include Manager role';
END

PRINT '';
PRINT '================================================';
PRINT 'Fix Complete! You can now register Manager accounts.';
PRINT '================================================';
GO
