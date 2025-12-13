# ⚠️ CRITICAL: Password Hash Column Fix ⚠️

## 🔴 ERROR: "Invalid column name 'password_hash'"

**If you're seeing this error during registration or login, STOP and read this!**

Your database is missing the `password_hash` column. This happened because an earlier version of `Tables.sql` had a bug (now fixed).

---

## ✅ QUICK FIX (30 seconds - Keeps all your data)

**DO THIS FIRST** - It's the fastest and safest solution:

### Steps:
1. Open **SQL Server Management Studio** or **Azure Data Studio**
2. Connect to your database server
3. Open the file **`Fix_PasswordHash_Column.sql`** from this repository
4. Click **Execute** or press **F5**
5. You should see: `✓ Column added successfully!`

**That's it!** Your database now has the password_hash column and registration/login will work.

---

## 🔄 Alternative: Clean Database Recreation

**Only use this if you want to start fresh** (will delete all data):

### Steps:
1. Open SQL Server Management Studio
2. Run this to delete the old database:
   ```sql
   USE master;
   GO
   DROP DATABASE MILESTONE2;
   GO
   ```
3. Open and execute **`Tables.sql`** to recreate the database
4. Open and execute **`Procedures.sql`** to add the stored procedures

---

## 📋 After Running the Fix

1. **Restart your web application** (if it's running)
2. **Try registering** a new account
3. **Error should be gone!** ✓

---

## ❓ Still Not Working?

### Checklist:
- [ ] Did you execute the SQL script on the **correct database**?
- [ ] Did you **restart the web application** after running the fix?
- [ ] Does the connection string in `appsettings.json` point to the **correct database**?
- [ ] Do you have **permissions to ALTER tables** on the database?

### Verify the Column Exists:
Run this query to check:
```sql
USE MILESTONE2;
GO

SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Employee' 
  AND COLUMN_NAME = 'password_hash';
GO
```

**Expected result:**
```
COLUMN_NAME    DATA_TYPE    IS_NULLABLE
password_hash  varchar      YES
```

If you see **no results**, the column doesn't exist. Run `Fix_PasswordHash_Column.sql` again.

---

## 💡 Why Did This Happen?

An earlier version of `Tables.sql` had the `password_hash` column listed **twice** (lines 24 and 44). This caused SQL Server to reject the table creation, leaving your database without the column.

This bug has been **fixed in commit e16e075**, but existing databases still need the manual fix.

---

## 📞 Need More Help?

If you've tried everything above and still have issues:
1. Check the SQL Server error log for detailed error messages
2. Verify your database connection is working
3. Make sure you're using the latest version of the repository

---

**Remember:** The quickest fix is running `Fix_PasswordHash_Column.sql` - it takes 30 seconds!
