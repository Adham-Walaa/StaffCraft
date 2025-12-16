# ⚠️ IMPORTANT: Database Migration Required

## Mission Management - Database Updates

### ❗ Critical Setup Steps
**Before using the Mission Management features, you MUST run BOTH database migration scripts in order.**

### Common Errors and Solutions

#### Error 1: Invalid column name 'description' or 'title'
```
Microsoft.Data.SqlClient.SqlException
Invalid column name 'description'.
Invalid column name 'title'.
```

**Cause:** Your Mission table is missing the `title` and `description` columns.

**Solution:** Run `Migration_AddMissionTitleDescription.sql` (see Step 1 below)

#### Error 2: Procedure has too many arguments specified
```
Error assigning mission: Procedure or function AssignMission has too many arguments specified.
```

**Cause:** Your database has the old version of the `AssignMission` stored procedure that doesn't accept `title` and `description` parameters.

**Solution:** Run `Migration_UpdateAssignMissionProcedure.sql` (see Step 2 below)

### ✅ Complete Migration Process

**Step 1: Add Title and Description Columns**

1. Open SQL Server Management Studio (SSMS) or Azure Data Studio
2. Connect to your database server (the one running MILESTONE2 database)
3. Open the file: `Migration_AddMissionTitleDescription.sql` from this repository
4. Execute the script (Press F5 or click Execute)
5. Verify you see success messages:
```
Column title added to Mission table.
Column description added to Mission table.
Migration completed successfully.
```

**Step 2: Update AssignMission Stored Procedure**

1. In the same SSMS or Azure Data Studio window
2. Open the file: `Migration_UpdateAssignMissionProcedure.sql` from this repository
3. Execute the script (Press F5 or click Execute)
4. Verify you see success messages:
```
Old AssignMission procedure dropped.
AssignMission procedure updated successfully with title and description parameters.
```

**Step 3: Restart Your Application**

After running both migration scripts, restart your web application for the changes to take effect.

### What the Migrations Do

**Migration 1 (Table):**
- Adds `title` column (varchar(200)) to the Mission table
- Adds `description` column (text) to the Mission table
- Checks if columns already exist before adding them (safe to run multiple times)
- Will not affect existing Mission data

**Migration 2 (Stored Procedure):**
- Updates the `AssignMission` stored procedure to accept `title` and `description` parameters
- Ensures the procedure inserts data into the new columns
- Safe to run multiple times

### Alternative: Recreate Database (Development Only)
If you're in a development environment and don't have important data:
1. Drop the existing MILESTONE2 database
2. Run `Tables.sql` to create all tables with the updated schema
3. Run `Procedures.sql` to create all stored procedures

### Verification
After running both migrations, verify the changes:

**Verify Table Columns:**
```sql
USE MILESTONE2;
GO

SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Mission'
ORDER BY ORDINAL_POSITION;
```

You should see output including:
- `MissionID` (int)
- `title` (varchar, 200)
- `description` (text)
- `destination` (varchar, 100)
- `start_date` (datetime)
- `end_date` (datetime)
- `status` (varchar, 50)
- `employee_id` (int)
- `manager_id` (int)

**Verify Stored Procedure:**
```sql
USE MILESTONE2;
GO

-- Check the procedure parameters
SELECT 
    PARAMETER_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.PARAMETERS
WHERE SPECIFIC_NAME = 'AssignMission'
ORDER BY ORDINAL_POSITION;
```

You should see 7 parameters including `@Title` and `@Description`.

You should see output including:
- `MissionID` (int)
- `title` (varchar, 200)
- `description` (text)
- `destination` (varchar, 100)
- `start_date` (datetime)
- `end_date` (datetime)
- `status` (varchar, 50)
- `employee_id` (int)
- `manager_id` (int)

### Troubleshooting
- **Error: Database 'MILESTONE2' does not exist**: Make sure you're connected to the correct server and the database exists
- **Error: Permission denied**: You need ALTER TABLE permissions on the database
- **Columns already exist**: The script is safe to run multiple times, it will skip existing columns
