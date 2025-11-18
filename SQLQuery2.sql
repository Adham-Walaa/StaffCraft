--SYSTEM ADMIN PROCEDURES

--1 

-- Procedure: ViewEmployeeInfo
-- Input: @EmployeeID int
-- Output: single row with columns from the Employee table only

IF OBJECT_ID('dbo.ViewEmployeeInfo', 'P') IS NOT NULL
    DROP PROCEDURE dbo.ViewEmployeeInfo;
GO
CREATE PROCEDURE dbo.ViewEmployeeInfo
    @EmployeeID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        EmployeeID,
        first_name,
        last_name,
        full_name,
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
        profile_image,
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
        tax_form_id,
        salary_type_id,
        pay_grade_id
    FROM dbo.Employee
    WHERE EmployeeID = @EmployeeID;
END
GO
