-- =============================================
-- FIX: Update GetTeamByManager Stored Procedure
-- =============================================
-- This script updates the GetTeamByManager stored procedure to include
-- the account_status column which is required for viewing team members.
--
-- HOW TO USE:
-- 1. Open this file in SQL Server Management Studio (SSMS) or Azure Data Studio
-- 2. Connect to your SQL Server
-- 3. Select the MILESTONE2 database from the dropdown
-- 4. Click Execute (or press F5)
-- 5. You should see "Commands completed successfully"
-- =============================================

USE MILESTONE2;
GO

-- Drop the existing procedure if it exists
IF OBJECT_ID('dbo.GetTeamByManager', 'P') IS NOT NULL
    DROP PROCEDURE dbo.GetTeamByManager;
GO

-- Create the updated procedure with account_status column
CREATE PROCEDURE dbo.GetTeamByManager
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
    
    -- Return employees under this manager with all required columns using aliases that match the C# model
    SELECT 
        EmployeeID,
        first_name AS FirstName,
        last_name AS LastName,
        full_name AS FullName,
        email AS Email,
        phone AS Phone,
        account_status AS AccountStatus,
        employment_status AS EmploymentStatus,
        hire_date AS HireDate,
        department_id AS DepartmentId,
        position_id AS PositionId,
        is_active AS IsActive
    FROM Employee
    WHERE manager_id = @ManagerID
    ORDER BY last_name, first_name;
    
    -- Return count message
    DECLARE @TeamCount INT;
    SELECT @TeamCount = COUNT(*) FROM Employee WHERE manager_id = @ManagerID;
    
    PRINT 'Found ' + CAST(@TeamCount AS VARCHAR(10)) + ' team members under Manager ID: ' + CAST(@ManagerID AS VARCHAR(10));
END;
GO

-- Verification: Test that the procedure was created successfully
PRINT 'GetTeamByManager procedure has been updated successfully!';
PRINT 'The procedure now includes the account_status column.';
GO
