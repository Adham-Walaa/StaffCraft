# Attendance Policies Setup Instructions

## Overview
This document provides instructions for setting up the Attendance Policies feature in Component 2, which allows viewing grace periods, short-time penalties, and penalty thresholds.

## Prerequisites
- SQL Server Management Studio (SSMS) installed
- Access to the project database
- Procedures.sql file from the project root directory

## Required Stored Procedures
The Attendance Policies feature requires the following stored procedures to be created in your database:

1. **GetGracePeriodSettings** - Retrieves grace period configurations
2. **GetShortTimeRules** - Retrieves short-time penalty rules  
3. **GetPenaltyThresholds** - Retrieves penalty threshold escalation rules
4. **GetAllAttendancePolicies** - Retrieves all active attendance policies

## Installation Steps

### Step 1: Open SQL Server Management Studio
1. Launch SQL Server Management Studio
2. Connect to your database server
3. Select your project database (the one used by the web application)

### Step 2: Locate the SQL Script
1. Navigate to the project root directory
2. Open the `Procedures.sql` file
3. Scroll to lines **12000-12100** (or search for "GetGracePeriodSettings")

### Step 3: Execute the Stored Procedures
**Option A: Execute Specific Section (Recommended)**
1. In Procedures.sql, select lines 12000-12100
2. These lines contain all 4 attendance policy stored procedures:
   - Lines 12000-12030: GetGracePeriodSettings
   - Lines 12030-12060: GetShortTimeRules
   - Lines 12060-12090: GetPenaltyThresholds
   - Lines 12090-12100: GetAllAttendancePolicies
3. Click "Execute" (or press F5)
4. Verify in the Messages pane that all procedures were created successfully

**Option B: Execute Entire Procedures.sql File**
1. Open the entire Procedures.sql file in SSMS
2. Click "Execute" (or press F5)
3. Wait for all procedures to be created
4. This will recreate ALL stored procedures in the database (takes longer)

### Step 4: Verify Installation
1. In SSMS Object Explorer, expand your database
2. Expand "Programmability" → "Stored Procedures"
3. Verify the following procedures exist:
   - `dbo.GetAllAttendancePolicies`
   - `dbo.GetGracePeriodSettings`
   - `dbo.GetPenaltyThresholds`
   - `dbo.GetShortTimeRules`

### Step 5: Test the Feature
1. Open the web application
2. Log in with any role (System Administrator, HR Administrator, Line Manager, or Employee)
3. Navigate to: **Attendance → View Time Rules & Penalties**
4. You should see the Attendance Policies dashboard without errors
5. Click the three card buttons to view:
   - Grace Periods
   - Short-Time Rules
   - Penalty Thresholds

## Troubleshooting

### Error: "Could not find stored procedure 'GetAllAttendancePolicies'"
**Solution:** The stored procedures have not been created in the database. Follow Steps 1-3 above.

### Error: "Invalid object name 'AttendancePolicy'"
**Solution:** The AttendancePolicy table does not exist in your database. You need to run the complete database schema script to create all required tables.

### Procedures appear in SSMS but still get errors
**Solution:** 
1. Ensure you're connected to the correct database
2. Try refreshing the Stored Procedures folder in SSMS Object Explorer
3. Verify the procedures exist in the same database that your web application is connected to

### No data appears in the views
**Solution:** This is expected if no attendance policies have been configured yet. The stored procedures work correctly; you just need to add policy data using the policy configuration procedures:
- `DefineShortTimeRules` (lines 3420-3501 in Procedures.sql)
- `SetGracePeriod` (lines 3507-3580 in Procedures.sql)
- `DefinePenaltyThreshold` (lines 3586-3660 in Procedures.sql)

## Features Enabled After Setup

Once the stored procedures are installed, you can:

1. **View All Policies Dashboard**
   - Navigate to: Attendance → View Time Rules & Penalties
   - See all active policies in one place
   - Access specialized views via card buttons

2. **View Grace Period Settings**
   - See buffer times before employees are marked late
   - Example: 15-minute grace period configuration

3. **View Short-Time Penalty Rules**
   - See penalties for late arrivals and early departures
   - Understand how deductions are calculated

4. **View Penalty Thresholds**
   - See escalation rules based on minutes late
   - Understand threshold levels (Grace → Level 1 → Level 2 → Level 3)

5. **View Individual Policy Details**
   - Click "Details" button on any policy
   - See complete policy information with color-coded badges

## Database Schema Reference

### AttendancePolicy Table Structure
```sql
CREATE TABLE AttendancePolicy (
    PolicyID INT PRIMARY KEY IDENTITY(1,1),
    policy_name NVARCHAR(100) NOT NULL,
    policy_type NVARCHAR(50) NOT NULL,
    description NVARCHAR(500),
    parameters NVARCHAR(MAX),  -- JSON format
    effective_date DATE NOT NULL,
    status NVARCHAR(20) DEFAULT 'Active'
);
```

### Example Policy Data
```sql
-- Grace Period Example
INSERT INTO AttendancePolicy (policy_name, policy_type, description, parameters, effective_date, status)
VALUES ('Grace Period', 'Grace Period', '15-minute buffer before marking late', 
        '{"grace_minutes":15}', '2024-01-01', 'Active');

-- Short-Time Penalty Example
INSERT INTO AttendancePolicy (policy_name, policy_type, description, parameters, effective_date, status)
VALUES ('Late Arrival Penalty', 'Short Time', 'Deduction for arriving late beyond grace period',
        '{"late_threshold_minutes":30, "penalty_type":"Deduction"}', '2024-01-01', 'Active');

-- Penalty Threshold Example
INSERT INTO AttendancePolicy (policy_name, policy_type, description, parameters, effective_date, status)
VALUES ('Level 1 Threshold', 'Penalty Threshold', 'Warning + time deduction for 16-30 min late',
        '{"min_minutes":16, "max_minutes":30, "action":"Warning + Deduction"}', '2024-01-01', 'Active');
```

## Support

If you continue to experience issues after following these instructions:
1. Verify your database connection string in appsettings.json
2. Check that the database user has permissions to execute stored procedures
3. Review the SQL Server error logs for detailed error messages
4. Ensure the web application is targeting the correct database

## Related Files

- **Procedures.sql** (lines 12000-12100) - Stored procedure definitions
- **AttendancePoliciesController.cs** - Controller with error handling
- **Views/AttendancePolicies/*.cshtml** - UI views with error display
- **Models/AttendancePolicy.cs** - Data model
- **Models/Milestone2Context.cs** - Database context configuration

---
**Last Updated:** 2024-12-16
**Component:** 2 - Attendance and Shift Management
**Feature:** Attendance Policies & Time Rules Viewer
