# Fix for "account_status" Error When Viewing Team Members

## Problem

When a Line Manager tries to view their team members, they see this error:

```
Error! Error retrieving team: The required column 'account_status' was not present in the results of a 'FromSql' operation.
```

## Root Cause

The `GetTeamByManager` stored procedure in your database is outdated and doesn't include the `account_status` column that the application expects.

## Solution

You need to update the `GetTeamByManager` stored procedure in your database.

### **Option 1: Quick Fix (Recommended - Takes 30 seconds)**

1. Open **SQL Server Management Studio** (SSMS) or **Azure Data Studio**
2. Connect to your SQL Server
3. Open the file `Fix_GetTeamByManager_Procedure.sql` from this repository
4. Make sure you're connected to the **MILESTONE2** database (select it from the dropdown at the top)
5. Click **Execute** (or press F5)
6. You should see: `GetTeamByManager procedure has been updated successfully!`
7. **Restart your web application** (stop and start it again in Visual Studio)
8. Try viewing team members again - the error should be gone!

### **Option 2: Recreate All Procedures (If Option 1 doesn't work)**

If the quick fix doesn't work, you may need to update all stored procedures:

1. Open **SQL Server Management Studio** (SSMS) or **Azure Data Studio**
2. Connect to your SQL Server
3. Open the file `Procedures.sql` from this repository
4. Make sure you're connected to the **MILESTONE2** database
5. Click **Execute** (or press F5) - **This will take 1-2 minutes**
6. Wait for all procedures to be created/updated
7. **Restart your web application**
8. Try viewing team members again

## What This Fix Does

The updated `GetTeamByManager` stored procedure now includes all the columns that the C# application expects, specifically:

- EmployeeID
- FirstName
- LastName
- FullName
- Email
- Phone
- **AccountStatus** ← This was missing!
- EmploymentStatus
- HireDate
- DepartmentId
- PositionId
- IsActive

## Verification

After running the fix:

1. Log in as a **Line Manager** account
2. Navigate to **Employees → View My Team** (or similar menu option)
3. You should now see a list of team members without any errors
4. The page will show employee details like name, email, department, and position

## Why This Happened

When the database was initially created, some stored procedures didn't include all the columns that were later added to the `Employee` table. The `account_status` column was added to the table schema but the `GetTeamByManager` procedure wasn't updated to return it.

## Need Help?

If you're still seeing errors after running the fix:

1. **Check the database name**: Make sure you ran the script on the **MILESTONE2** database, not master or another database
2. **Check for errors**: Look at the messages panel in SSMS after running the script - there should be no red error messages
3. **Restart the web app**: Make sure you stopped and restarted your ASP.NET application after updating the procedure
4. **Check the account_status column exists**: Run this query in SSMS:
   ```sql
   SELECT account_status FROM Employee WHERE EmployeeID = 1;
   ```
   If this fails, the column doesn't exist in your database - you'll need to run `Tables.sql` to recreate the table structure.

## Summary

✅ **Problem**: "account_status" column missing error when viewing team members  
✅ **Cause**: Outdated stored procedure in database  
✅ **Solution**: Run `Fix_GetTeamByManager_Procedure.sql`  
✅ **Time**: 30 seconds  
✅ **Risk**: None - only updates one stored procedure
