# Password Hash Column Fix

## Problem

If you're getting the error **"Invalid column name 'password_hash'"** during registration or login, it means your database is missing the `password_hash` column in the Employee table.

## Cause

This issue occurred because:
1. An earlier version of `Tables.sql` had a duplicate `password_hash` column definition
2. SQL Server may have rejected the duplicate, causing the column not to be created
3. The duplicate has now been fixed, but existing databases don't have the column

## Solution Options

You have **two options** to fix this issue:

### Option 1: Add the Missing Column (Quick Fix)

If you want to keep your existing data, run the `Fix_PasswordHash_Column.sql` script:

1. Open SQL Server Management Studio (SSMS) or Azure Data Studio
2. Connect to your database server
3. Open the file `Fix_PasswordHash_Column.sql`
4. Execute the script

This will add the missing column without affecting your existing data.

### Option 2: Recreate the Database (Clean Start)

If you want a clean database with the latest schema:

1. **Drop the existing database:**
   ```sql
   USE master;
   GO
   DROP DATABASE MILESTONE2;
   GO
   ```

2. **Run the Tables.sql script to create the database:**
   - Open `Tables.sql` in SSMS or Azure Data Studio
   - Execute the entire script

3. **Run the Procedures.sql script to create stored procedures:**
   - Open `Procedures.sql`
   - Execute the entire script

## Verification

After running either fix, verify the column exists:

```sql
USE MILESTONE2;
GO

SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Employee' AND COLUMN_NAME = 'password_hash';
GO
```

You should see:
```
COLUMN_NAME    DATA_TYPE    CHARACTER_MAXIMUM_LENGTH    IS_NULLABLE
password_hash  varchar      255                         YES
```

## After the Fix

Once the column exists:
1. Restart your web application if it's running
2. Try registering a new account
3. The error should be gone!

## Need Help?

If you still encounter issues after trying both options:
1. Check that you're connected to the correct database
2. Verify you have permissions to ALTER tables
3. Review any error messages from SQL Server
4. Make sure the web application's connection string points to the correct database

---

**Note:** The database schema has been corrected in commit `e16e075`. Any new databases created from the latest `Tables.sql` will have the column correctly defined.
