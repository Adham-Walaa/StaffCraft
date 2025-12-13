# Database Schema Fix - Password Hash Column

## Problem
If you're experiencing the error: **"Registration failed: Invalid column name 'password_hash'"**, this means your existing database was created with an older version of `Tables.sql` that had a duplicate `password_hash` column definition.

## Solution

You have **two options** to fix this issue:

### Option 1: Run the Migration Script (Recommended - Preserves Data)

This option keeps all your existing data.

1. Open **SQL Server Management Studio** or **Azure Data Studio**
2. Connect to your SQL Server instance
3. Open the file `Fix_Password_Hash_Column.sql` (located in the project root)
4. Execute the script by pressing **F5** or clicking **Execute**
5. You should see messages indicating the fix was successful
6. Try registering a new account again

**What this script does:**
- Safely migrates your Employee table data to a new table with the correct schema
- Preserves all existing employee records and passwords
- Recreates all foreign key relationships
- No data loss

### Option 2: Recreate the Database from Scratch (Clean Start)

This option requires recreating all data.

1. Open **SQL Server Management Studio** or **Azure Data Studio**
2. Delete the existing database:
   ```sql
   USE master;
   GO
   DROP DATABASE MILESTONE2;
   GO
   ```
3. Run the updated scripts in order:
   - `Tables.sql` - Creates all database tables (now fixed)
   - `Procedures.sql` - Creates stored procedures
   - (Optional) `Procedures_Tests.sql` - Tests stored procedures
4. Try registering a new account again

**Warning:** This will delete all existing data!

## Verification

After applying either fix, verify the schema is correct:

```sql
USE MILESTONE2;
GO

-- Check Employee table columns
SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Employee' AND COLUMN_NAME = 'password_hash';
GO
```

You should see **only ONE row** returned with:
- COLUMN_NAME: `password_hash`
- DATA_TYPE: `varchar`
- CHARACTER_MAXIMUM_LENGTH: `255`
- IS_NULLABLE: `YES`

## Testing the Fix

1. Open your web application
2. Navigate to the registration page
3. Fill in the registration form:
   - First Name: Test
   - Last Name: User
   - Email: test@example.com
   - Password: Test123
   - Role: System Administrator
4. Click "Register"
5. You should see: **"Account created successfully! You can now login."**

If registration works, the fix is successful! ✅

## Why Did This Happen?

The original `Tables.sql` file had the `password_hash` column defined twice in the Employee table:
```sql
CREATE TABLE Employee
(
    ...
    email varchar(100),
    password_hash varchar(255),      -- First definition (removed in the fix)
    address varchar(200),
    ...
    password_hash varchar(255) NULL  -- Second definition (kept in the fix) - DUPLICATE!
);
```

The first duplicate has now been removed. SQL Server doesn't allow duplicate column names, which caused the error during registration when the application tried to update the password_hash field.

## Need Help?

If you continue to experience issues:
1. Check that SQL Server is running
2. Verify the connection string in `appsettings.json`
3. Make sure you ran the correct migration script for your database
4. Check the SQL Server error log for detailed error messages

---

**Fixed in commit:** ce1ac06
