# Database Migration Instructions

## Mission Table - Add Title and Description Columns

### Problem
If you encounter the error:
```
Microsoft.Data.SqlClient.SqlException
Invalid column name 'Description'.
Invalid column name 'Title'.
```

This means your existing database doesn't have the new `title` and `description` columns that were added to the Mission table.

### Solution
Run the migration script to add these columns to your existing database:

1. Open SQL Server Management Studio (SSMS) or Azure Data Studio
2. Connect to your database server
3. Open the file: `Migration_AddMissionTitleDescription.sql`
4. Execute the script

### What the Migration Does
- Adds `title` column (varchar(200)) to the Mission table
- Adds `description` column (text) to the Mission table
- Checks if columns already exist before adding them (safe to run multiple times)

### Alternative: Recreate Database
If you're in a development environment and don't have important data:
1. Drop the existing database
2. Run `Tables.sql` to create all tables with the updated schema
3. Run `Procedures.sql` to create all stored procedures

### Verification
After running the migration, verify the columns exist:
```sql
SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Mission'
ORDER BY ORDINAL_POSITION;
```

You should see `title` and `description` in the list of columns.
