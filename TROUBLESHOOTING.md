# Troubleshooting "Invalid column name 'password_hash'" Error

## Quick Diagnostic

If you're still experiencing the "Invalid column name 'password_hash'" error after manually deleting one of the duplicate columns, follow these steps:

### Step 1: Run the Diagnostic Script

1. Open **SQL Server Management Studio** or **Azure Data Studio**
2. Open the file `Diagnose_Employee_Table.sql`
3. Execute the script (press F5)
4. Review the output carefully

The diagnostic will tell you:
- ✓ How many `password_hash` columns exist (should be exactly 1)
- ✓ If the column is missing entirely
- ✓ If there are still duplicates
- ✓ The exact schema of your Employee table

### Step 2: Interpret the Results

**If you see "No password_hash column found":**
- You accidentally deleted BOTH columns
- **Solution:** Run `Fix_Password_Hash_Column.sql` to restore the table

**If you see "Multiple password_hash columns found":**
- The manual deletion didn't work or wasn't saved
- **Solution:** Run `Fix_Password_Hash_Column.sql` to fix properly

**If you see "Exactly one password_hash column exists ✓":**
- The database schema is correct!
- The error is coming from somewhere else (see Step 3)

### Step 3: If Schema is Correct But Error Persists

The error might be related to:

#### A. Entity Framework Cache Issue
Your application might have cached the old model. **Solutions:**

1. **Rebuild the application:**
   - In Visual Studio: Build → Rebuild Solution
   - Or press Ctrl+Shift+B

2. **Clear bin/obj folders:**
   ```bash
   cd MS3WebApp/WebAppSystem/WebAppSystem
   rm -rf bin obj
   dotnet build
   ```

3. **Restart the application:**
   - Stop the running app (if any)
   - Press F5 to start fresh

#### B. Wrong Database Connection
Your app might be connecting to a different database. **Solution:**

1. Check `appsettings.json`:
   ```json
   {
     "ConnectionStrings": {
       "DefaultConnection": "Server=YOUR_SERVER;Database=MILESTONE2;..."
     }
   }
   ```

2. Verify it says `Database=MILESTONE2` (not MILESTONE, MILESTONE3, etc.)

3. In SQL Server, run:
   ```sql
   SELECT DB_NAME();  -- Should return 'MILESTONE2'
   ```

#### C. Stored Procedure Issue
The error might be coming from the `AddEmployee` stored procedure. **Solution:**

1. Re-run `Procedures.sql` to update all stored procedures
2. The procedures reference `password_hash` and need to be in sync

### Step 4: Check Application Logs

When you try to register, look at the **exact error message** in Visual Studio:

1. In Visual Studio, open **Output** window (View → Output)
2. Select "Show output from: Debug"
3. Try to register an account
4. Look for the full error message and stack trace

**Common error variations:**

- `Invalid column name 'password_hash'` → Database schema issue
- `Cannot insert NULL into column 'password_hash'` → Different issue (constraint)
- `Object reference not set` → Application code issue

### Step 5: Complete Fresh Start (Last Resort)

If nothing else works, here's how to completely reset:

```sql
-- In SQL Server Management Studio:
USE master;
GO
DROP DATABASE MILESTONE2;
GO

-- Then run these in order:
-- 1. Tables.sql (creates fresh database and tables)
-- 2. Procedures.sql (creates stored procedures)
```

Then restart your application.

## Still Having Issues?

Share the following information:

1. **Output from Diagnose_Employee_Table.sql**
2. **Exact error message from Visual Studio Output window**
3. **Connection string from appsettings.json** (remove passwords!)
4. **Which step you tried and what happened**

---

## Why Manual Deletion Might Not Work

SQL Server's schema is complex. Simply deleting a column definition from `Tables.sql` doesn't change your existing database - you'd need to execute `ALTER TABLE` commands. That's why the migration script (`Fix_Password_Hash_Column.sql`) exists - it safely handles:

- Dropping foreign key constraints
- Recreating the table with correct schema
- Copying all data
- Restoring foreign keys

Manual changes can leave your database in an inconsistent state.
