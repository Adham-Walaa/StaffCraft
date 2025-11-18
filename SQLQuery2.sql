--SYSTEM ADMIN PROCEDURES

--1 

-- Procedure: ViewEmployeeInfo
-- Input: @EmployeeID int
-- Output: single row with columns from the Employee table only

IF OBJECT_ID('dbo.ViewEmployeeInfo', 'P') IS NOT NULL
    DROP PROCEDURE dbo.ViewEmployeeInfo;
GO
USE MILESTONE2;
GO

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
