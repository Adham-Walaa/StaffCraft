-- ============================================
-- Component 2: Database Setup Script
-- ============================================
-- This script adds the necessary database changes for Component 2
-- Run this script AFTER running Tables.sql and Procedures.sql
-- ============================================

USE MILESTONE2;
GO

-- ============================================
-- STEP 1: Add Manager Role to Role table
-- ============================================
-- Check if Manager role exists, if not insert it
IF NOT EXISTS (SELECT 1 FROM dbo.Role WHERE role_name = 'Manager')
BEGIN
    -- Find the next available RoleID
    DECLARE @NextRoleID INT;
    SELECT @NextRoleID = ISNULL(MAX(RoleID), 0) + 1 FROM dbo.Role;
    
    INSERT INTO dbo.Role (RoleID, role_name, purpose)
    VALUES (@NextRoleID, 'Manager', 'Manager role for Component 2 - can assign shifts, view team attendance, and approve correction requests');
    
    PRINT 'Manager role added successfully with RoleID: ' + CAST(@NextRoleID AS VARCHAR(10));
END
ELSE
BEGIN
    PRINT 'Manager role already exists.';
END
GO

-- ============================================
-- STEP 2: Verify the ManageUserAccounts procedure includes Manager role
-- ============================================
-- This procedure is updated in Procedures.sql line 2025
-- Make sure to run the updated Procedures.sql file

-- Test query to verify Manager role exists
SELECT RoleID, role_name, purpose 
FROM dbo.Role 
WHERE role_name = 'Manager';
GO

-- ============================================
-- STEP 3: Grant Manager role necessary permissions (if using RolePermission table)
-- ============================================
-- Uncomment and modify the following if your system uses RolePermission table

/*
DECLARE @ManagerRoleID INT;
SELECT @ManagerRoleID = RoleID FROM dbo.Role WHERE role_name = 'Manager';

IF @ManagerRoleID IS NOT NULL
BEGIN
    -- Add permissions for Manager role
    INSERT INTO dbo.RolePermission (role_id, permission_name, allowed_action)
    VALUES 
        (@ManagerRoleID, 'Shift Management', 'Assign shifts to employees'),
        (@ManagerRoleID, 'Shift Management', 'Assign shifts to departments'),
        (@ManagerRoleID, 'Shift Management', 'Edit shift schedules'),
        (@ManagerRoleID, 'Shift Management', 'View shift schedules'),
        (@ManagerRoleID, 'Attendance', 'View team attendance'),
        (@ManagerRoleID, 'Attendance', 'Approve correction requests'),
        (@ManagerRoleID, 'Attendance', 'Reject correction requests');
    
    PRINT 'Manager permissions added successfully.';
END
*/

-- ============================================
-- Verification Queries
-- ============================================
PRINT '============================================';
PRINT 'Component 2 Database Setup - Verification';
PRINT '============================================';

-- Check all roles in the system
PRINT 'All Roles in System:';
SELECT RoleID, role_name, purpose FROM dbo.Role ORDER BY RoleID;

-- Check if any employees have Manager role
PRINT '';
PRINT 'Employees with Manager Role:';
SELECT 
    e.EmployeeID,
    e.FullName,
    e.Email,
    r.role_name,
    er.assigned_date
FROM dbo.Employee e
JOIN dbo.EmployeeRole er ON e.EmployeeID = er.employee_id
JOIN dbo.Role r ON er.role_id = r.RoleID
WHERE r.role_name = 'Manager'
ORDER BY e.FullName;

PRINT '';
PRINT '============================================';
PRINT 'Setup Complete!';
PRINT '============================================';
PRINT 'You can now register accounts with the Manager role.';
PRINT 'The ManageUserAccounts procedure has been updated to accept Manager role.';
GO
