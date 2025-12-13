# Complete Registration Fix - Step-by-Step Guide

## The Solution

The registration issue has been completely fixed with a two-part solution:

1. **Fixed the database schema** - Removed the duplicate `password_hash` column definition
2. **Updated the code** - Changed from using Entity Framework to using a stored procedure for setting passwords

## How to Apply the Fix

### Step 1: Update Your Database Schema

**Option A: If you have an existing database with data you want to keep:**
1. Open SQL Server Management Studio or Azure Data Studio
2. Execute `Fix_Password_Hash_Column.sql` from the project root
3. This will safely fix your Employee table schema without losing data

**Option B: If you can recreate your database:**
1. Drop the old database:
   ```sql
   USE master;
   GO
   DROP DATABASE MILESTONE2;
   GO
   ```
2. Run `Tables.sql` to create the database with the correct schema

### Step 2: Update Stored Procedures

**Important:** This step is required for everyone, regardless of which option you chose above.

1. Open SQL Server Management Studio or Azure Data Studio
2. Execute the updated `Procedures.sql` file from the project root
3. This adds the new `SetEmployeePassword` stored procedure

### Step 3: Rebuild Your Application

1. Open Visual Studio
2. Open the solution from `MS3WebApp/WebAppSystem/`
3. **Build → Rebuild Solution** (or press Ctrl+Shift+B)
4. Wait for the build to complete

### Step 4: Test Registration

1. Press **F5** to run the application
2. Navigate to the registration page
3. Fill in the form:
   - First Name: Test
   - Last Name: User
   - Email: test@example.com
   - Password: Test123!
   - Role: Employee
4. Click "Register"
5. You should see: "Account created successfully! You can now login."

## What Changed?

### Database Schema Fix (Tables.sql)
- Removed duplicate `password_hash varchar(255)` from line 24
- Kept only one definition at the end of the column list

### New Stored Procedure (Procedures.sql)
Added `SetEmployeePassword`:
```sql
CREATE OR ALTER PROCEDURE dbo.SetEmployeePassword
    @EmployeeID INT,
    @PasswordHash VARCHAR(255)
AS
BEGIN
    -- Validates employee exists
    -- Updates password_hash column
    -- Returns success message
END;
```

### Code Changes (AccountController.cs)
Changed from using Entity Framework's `SaveChangesAsync()` to calling the stored procedure directly:

**Before:**
```csharp
var employee = await _context.Employees.FindAsync(employeeId);
employee.PasswordHash = HashPassword(password);
await _context.SaveChangesAsync();  // This could fail with schema issues
```

**After:**
```csharp
var hashedPassword = HashPassword(password);
await _context.Database.ExecuteSqlRawAsync(
    "EXEC dbo.SetEmployeePassword @EmployeeID, @PasswordHash",
    parameters
);
```

## Why This Works

### The Root Cause
The error "Invalid column name 'password_hash'" was caused by:
1. Database schema had duplicate column definitions
2. Entity Framework tried to generate UPDATE statements
3. SQL Server couldn't resolve which column to update

### The Solution
By using a stored procedure:
- We bypass Entity Framework's SQL generation
- The stored procedure directly updates the correct `password_hash` column
- No ambiguity, no schema confusion
- Works even if the database schema isn't perfectly in sync

## Verification

To verify everything is working:

### 1. Check Database Schema
Run `Diagnose_Employee_Table.sql` - should show exactly one `password_hash` column

### 2. Check Stored Procedure Exists
```sql
USE MILESTONE2;
GO

SELECT ROUTINE_NAME 
FROM INFORMATION_SCHEMA.ROUTINES 
WHERE ROUTINE_NAME = 'SetEmployeePassword' AND ROUTINE_TYPE = 'PROCEDURE';
GO
```

Should return one row with `SetEmployeePassword`

### 3. Test Registration
Try creating a new account - should succeed with no errors

### 4. Test Login
Try logging in with the account you just created - should work

## Troubleshooting

### "Stored procedure 'SetEmployeePassword' not found"
**Solution:** Run the updated `Procedures.sql` file

### Still Getting "Invalid column name 'password_hash'"
**Solutions:**
1. Run `Diagnose_Employee_Table.sql` to check your schema
2. Run `Fix_Password_Hash_Column.sql` to fix the schema
3. Rebuild your application in Visual Studio
4. Restart your application

### "Employee with ID X does not exist"
**This is a different error!** It means:
- The `AddEmployee` stored procedure failed
- Check the exact error message for the real cause
- Common causes: invalid foreign key references, email already exists

### Build Errors
**Solutions:**
1. Right-click solution → Restore NuGet Packages
2. Build → Clean Solution
3. Build → Rebuild Solution

## Files Updated

| File | Description |
|------|-------------|
| `Tables.sql` | Fixed duplicate column definition |
| `Procedures.sql` | Added `SetEmployeePassword` procedure |
| `AccountController.cs` | Uses stored procedure instead of EF |
| `Fix_Password_Hash_Column.sql` | Migration script for existing databases |
| `Diagnose_Employee_Table.sql` | Diagnostic tool |
| `TROUBLESHOOTING.md` | Detailed troubleshooting guide |
| `DATABASE_FIX_README.md` | Database fix instructions |

## Support

If you're still having issues:
1. Run `Diagnose_Employee_Table.sql` and share the output
2. Check Visual Studio's Output window for the exact error message
3. Verify you ran both `Fix_Password_Hash_Column.sql` AND the updated `Procedures.sql`

---

**Commit:** 28125a0
