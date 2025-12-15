-- Migration Script: Update AssignMission stored procedure
-- Date: 2025-12-15
-- Purpose: Update AssignMission procedure to include title and description parameters

USE MILESTONE2;
GO

-- Drop the old version if it exists
IF OBJECT_ID('dbo.AssignMission', 'P') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.AssignMission;
    PRINT 'Old AssignMission procedure dropped.';
END
GO

-- Create the updated version with title and description
CREATE PROCEDURE AssignMission
    @EmployeeID INT,
    @ManagerID INT,
    @Title VARCHAR(200),
    @Description TEXT,
    @Destination VARCHAR(50),
    @StartDate DATE,
    @EndDate DATE
AS
BEGIN
    DECLARE @NextMissionID INT;
    
    -- Get the next available MissionID
    SELECT @NextMissionID = ISNULL(MAX(MissionID), 0) + 1 FROM Mission;
    
    INSERT INTO Mission (MissionID, title, description, destination, start_date, end_date, status, employee_id, manager_id)
    VALUES (@NextMissionID, @Title, @Description, @Destination, @StartDate, @EndDate, 'Pending', @EmployeeID, @ManagerID);
    
    PRINT 'Mission assigned successfully to employee ';
END;
GO

PRINT 'AssignMission procedure updated successfully with title and description parameters.';
