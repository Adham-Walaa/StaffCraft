# 🚨 URGENT: FIX MANAGER ROLE REGISTRATION ERROR 🚨

## The Problem

You're getting this error when trying to register a Manager account:
```
Registration failed: Invalid role. Valid roles are: System Administrator, HR Administrator, Payroll Officer, Payroll Specialist, Line Manager, Employee.
```

## Why This Happens

The **database stored procedure** needs to be updated to accept "Manager" as a valid role. The code files have been updated, but your **SQL Server database** hasn't been updated yet.

---

## ⚡ QUICK FIX (5 Minutes)

### Step 1: Find Your Database Name

1. Open **SQL Server Management Studio (SSMS)**
2. Connect to your SQL Server
3. Look in Object Explorer - your database name is under "Databases"
4. **Write it down** - you'll need it in Step 3

### Step 2: Open the Fix Script

1. In your project folder, find the file: **`FIX_MANAGER_ROLE_NOW.sql`**
2. Open it in any text editor (Notepad, VS Code, etc.)
3. **Select ALL the text** (Ctrl+A)
4. **Copy it** (Ctrl+C)

### Step 3: Run the Fix Script

1. Go back to **SQL Server Management Studio (SSMS)**
2. Click **New Query** (or press Ctrl+N)
3. **IMPORTANT:** In the first line of the copied script, change this:
   ```sql
   USE [Your_Database_Name_Here];  -- IMPORTANT: Change this!
   ```
   To this (with YOUR actual database name):
   ```sql
   USE [YourActualDatabaseName];  -- For example: USE [HRDatabase];
   ```
4. **Paste** the entire script (Ctrl+V)
5. Click **Execute** (or press F5)

### Step 4: Check Results

Look at the Messages tab at the bottom. You should see:
```
================================================
SUCCESS: Manager role added to Role table with RoleID = X
SUCCESS: ManageUserAccounts procedure updated
PASS: Manager role exists with RoleID = X
PASS: ManageUserAccounts procedure includes Manager role
Fix Complete! You can now register Manager accounts.
================================================
```

### Step 5: Try Registration Again

1. Go back to your web application
2. Go to the Register page
3. Select "Manager" from the Role dropdown
4. Fill in all the fields
5. Click Register

**It should work now!** ✅

---

## 🆘 If It STILL Doesn't Work

### Option A: Manual Method (If Script Fails)

**1. Add Manager Role Manually:**
```sql
USE [YourDatabaseName];
GO

-- Find the highest RoleID
SELECT MAX(RoleID) FROM Role;

-- Add 1 to that number and use it below
INSERT INTO Role (RoleID, RoleName, Purpose)
VALUES (7, 'Manager', 'Manages team attendance and shifts');  -- Use next available ID
GO
```

**2. Update the Stored Procedure Manually:**
- In SSMS, expand your database
- Expand "Programmability"
- Expand "Stored Procedures"
- Find "dbo.ManageUserAccounts"
- Right-click → Modify
- Find this line (around line 25):
  ```sql
  IF @Role NOT IN ('System Administrator', 'HR Administrator', 'Payroll Officer', 'Payroll Specialist', 'Line Manager', 'Employee')
  ```
- Change it to:
  ```sql
  IF @Role NOT IN ('System Administrator', 'HR Administrator', 'Payroll Officer', 'Payroll Specialist', 'Line Manager', 'Manager', 'Employee')
  ```
- Also update the error message on the next line to include "Manager"
- Click **Execute** to save

### Option B: Recreate Everything

If nothing works, run these scripts in order:
1. `Tables.sql` - Recreates all tables
2. `Procedures.sql` - Recreates all procedures (includes the fix)
3. `COMPONENT2_DATABASE_SETUP.sql` - Adds Manager role

⚠️ **WARNING:** This will delete all your test data!

---

## 📞 Verification Commands

Run these in SSMS to check if the fix worked:

```sql
-- Check if Manager role exists
SELECT * FROM Role WHERE RoleName = 'Manager';

-- Check if procedure includes Manager
SELECT OBJECT_DEFINITION(OBJECT_ID('dbo.ManageUserAccounts'));
-- Look for 'Manager' in the output
```

---

## ✅ Success Checklist

- [ ] Opened SSMS and connected to database
- [ ] Found my database name
- [ ] Opened `FIX_MANAGER_ROLE_NOW.sql`
- [ ] Changed `[Your_Database_Name_Here]` to my actual database name
- [ ] Copied the entire script
- [ ] Pasted into SSMS and executed (F5)
- [ ] Saw "SUCCESS" messages in the output
- [ ] Tried registering a Manager account
- [ ] Registration worked! ✅

---

## 🎯 After Fix is Complete

Once you can successfully register a Manager account, follow the testing guide:
- `MANAGER_ROLE_COMPLETE_TESTING_GUIDE.md`

This guide has 8 test cases to verify all Manager features work correctly.

---

## Still Having Issues?

If you're still getting the error after following these steps:

1. **Check which database the web app is using:**
   - Open `appsettings.json` in your web project
   - Look for the connection string
   - Make sure it matches the database you updated

2. **Make sure the web app is restarted:**
   - Stop the application (if running)
   - Start it again with `dotnet run`

3. **Clear your browser cache:**
   - Sometimes old error messages get cached
   - Try Ctrl+Shift+R to hard refresh

---

**Need More Help?** 

Check `MANAGER_ROLE_SETUP_GUIDE.md` for detailed troubleshooting steps.
