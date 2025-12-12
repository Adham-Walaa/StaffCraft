# Manager Role Setup Guide

## Issue
When trying to register an account with "Manager" role, you get this error:
```
Registration failed: Invalid role. Valid roles are: System Administrator, HR Administrator, Payroll Officer, Payroll Specialist, Line Manager, Employee.
```

## Root Cause
The database stored procedure `ManageUserAccounts` only accepts specific roles, and "Manager" was not included in the original list. Component 2 requires the "Manager" role for testing.

## Solution

### Step 1: Update the Stored Procedure
The `Procedures.sql` file has been updated to include "Manager" in the valid roles list (line 2025).

**Run the updated Procedures.sql file:**

1. Open SQL Server Management Studio (SSMS)
2. Connect to your database server
3. Open the file: `Procedures.sql`
4. Execute the entire file (or just the `ManageUserAccounts` procedure)

The updated procedure now accepts these roles:
- System Administrator
- HR Administrator  
- Payroll Officer
- Payroll Specialist
- Line Manager
- **Manager** ← **NEW**
- Employee

### Step 2: Add Manager Role to Database

Run the `COMPONENT2_DATABASE_SETUP.sql` script to add the Manager role to the Role table:

1. Open SQL Server Management Studio (SSMS)
2. Connect to your database server
3. Open the file: `COMPONENT2_DATABASE_SETUP.sql`
4. Execute the script
5. Verify the output shows: "Manager role added successfully"

### Step 3: Verify the Setup

**Option A: Using SQL Query**
```sql
-- Check if Manager role exists
SELECT RoleID, role_name, purpose 
FROM dbo.Role 
WHERE role_name = 'Manager';
```

**Option B: Try registering a Manager account**
1. Run your web application
2. Go to Register page
3. Select "Manager" from the Role dropdown
4. Fill in all required fields
5. Click Register
6. Should see success message: "Account created successfully! You can now login."

### Step 4: Test Manager Role Features

Once registered, login with the Manager account and test these features:

1. **Assign Shift to Employee** - Shifts → Assign to Employee
2. **Assign Shift to Department** - Shifts → Assign to Department  
3. **Edit Shift Schedule** - Shifts → All Shift Schedules → Edit
4. **View Team Attendance** - Attendance → Team Attendance
5. **Approve Correction Requests** - Attendance → All Correction Requests → Approve
6. **Reject Correction Requests** - Attendance → All Correction Requests → Reject

Refer to `MANAGER_ROLE_COMPLETE_TESTING_GUIDE.md` for detailed test cases.

## Alternative: Command Line Setup

If you prefer command line, use `sqlcmd`:

```bash
# Update the stored procedure
sqlcmd -S your_server -d MILESTONE2 -i Procedures.sql

# Add Manager role to database
sqlcmd -S your_server -d MILESTONE2 -i COMPONENT2_DATABASE_SETUP.sql
```

## Troubleshooting

### Issue: "Manager role already exists"
This is fine! It means the role was already added. You can proceed with registration.

### Issue: Still getting "Invalid role" error
1. Verify you ran the updated `Procedures.sql` file
2. Check the file timestamp - should be recent
3. In SSMS, run: `sp_helptext 'ManageUserAccounts'` to verify the procedure includes 'Manager'
4. Look for line: `IF @Role NOT IN ('System Administrator', 'HR Administrator', ..., 'Manager', 'Employee')`

### Issue: Registration works but can't login
1. Check that the Manager role exists in the Role table
2. Verify your employee was assigned the role:
```sql
SELECT e.FullName, r.role_name
FROM Employee e
JOIN EmployeeRole er ON e.EmployeeID = er.employee_id  
JOIN Role r ON er.role_id = r.RoleID
WHERE e.Email = 'your_email@example.com';
```

## Files Changed in Component 2

1. **Procedures.sql** (line 2025) - Added 'Manager' to valid roles list
2. **COMPONENT2_DATABASE_SETUP.sql** (NEW) - Script to add Manager role to database
3. **AccountController.cs** (lines 120-127) - Manager already in dropdown
4. **Controllers** - All Component 2 controllers support Manager role

## Summary

✅ **Procedures.sql** - Updated ManageUserAccounts procedure
✅ **COMPONENT2_DATABASE_SETUP.sql** - Adds Manager role to Role table  
✅ **AccountController.cs** - Already has Manager in registration dropdown
✅ **All Component 2 Controllers** - Support Manager role permissions

After running the database scripts, you can successfully register and use Manager accounts for Component 2 testing!
