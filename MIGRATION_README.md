# ⚠️ IMPORTANT: Database Migration Required

## Mission Table - Add Title and Description Columns

### ❗ Critical Setup Step
**Before using the Mission Management features, you MUST run the database migration script.**

### Problem
If you encounter these errors:
```
Microsoft.Data.SqlClient.SqlException
Invalid column name 'description'.
Invalid column name 'title'.
```
OR
```
Microsoft.Data.SqlClient.SqlException
Invalid column name 'Description'.
Invalid column name 'Title'.
```

This means your existing database doesn't have the new `title` and `description` columns that were added to the Mission table.

### ✅ Solution - Run Migration Script

**Step 1:** Open SQL Server Management Studio (SSMS) or Azure Data Studio

**Step 2:** Connect to your database server (the one running MILESTONE2 database)

**Step 3:** Open the file: `Migration_AddMissionTitleDescription.sql` from this repository

**Step 4:** Execute the script (Press F5 or click Execute)

**Step 5:** Verify you see success messages:
```
Column title added to Mission table.
Column description added to Mission table.
Migration completed successfully.
```

### What the Migration Does
- Adds `title` column (varchar(200)) to the Mission table
- Adds `description` column (text) to the Mission table
- Checks if columns already exist before adding them (safe to run multiple times)
- Will not affect existing Mission data

### Alternative: Recreate Database (Development Only)
If you're in a development environment and don't have important data:
1. Drop the existing MILESTONE2 database
2. Run `Tables.sql` to create all tables with the updated schema
3. Run `Procedures.sql` to create all stored procedures

### Verification
After running the migration, verify the columns exist:
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

### Troubleshooting
- **Error: Database 'MILESTONE2' does not exist**: Make sure you're connected to the correct server and the database exists
- **Error: Permission denied**: You need ALTER TABLE permissions on the database
- **Columns already exist**: The script is safe to run multiple times, it will skip existing columns
