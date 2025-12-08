# Testing Guide for Implemented Changes

This guide provides step-by-step instructions to test all the implemented changes.

## Prerequisites

1. Run the database migration script first:
   ```sql
   -- Execute migration_add_password_hash.sql in SQL Server Management Studio or Azure Data Studio
   USE MILESTONE2;
   GO
   
   ALTER TABLE Employee
   ADD password_hash varchar(255) NULL;
   GO
   ```

2. Ensure your connection string in `appsettings.json` is correct

3. Build and run the application:
   ```bash
   cd MS3WebApp/WebAppSystem/WebAppSystem
   dotnet build
   dotnet run
   ```

## Test 1: Password Authentication

### 1.1 Create a New Account
1. Navigate to the application homepage
2. Click "Register" or "Register Now"
3. Fill in the registration form:
   - Full Name: "Test User"
   - Email: "test@example.com"
   - Password: "TestPass123!"
   - Confirm Password: "TestPass123!"
   - Role: "Employee"
   - Phone: (optional)
   - Date of Birth: (optional)
   - Address: (optional)
4. Click "Register"
5. **Expected Result**: Account created successfully, redirected to login page

### 1.2 Test Login with Correct Password
1. On the login page, enter:
   - Email: "test@example.com"
   - Password: "TestPass123!"
2. Click "Login"
3. **Expected Result**: Successfully logged in, redirected to homepage showing "Welcome, Test User!"

### 1.3 Test Login with Incorrect Password
1. Log out (if logged in)
2. On the login page, enter:
   - Email: "test@example.com"
   - Password: "WrongPassword"
3. Click "Login"
4. **Expected Result**: Login fails with error message "Invalid email or password."

### 1.4 Test Login without Password
1. On the login page, enter:
   - Email: "test@example.com"
   - Password: (leave empty)
2. Click "Login"
3. **Expected Result**: Validation error: "Password is required"

### 1.5 Verify Password Security
The password is now:
- ✅ Hashed using BCrypt (not stored in plain text)
- ✅ Salted automatically (each password has unique hash even if same password)
- ✅ Protected against brute-force attacks (BCrypt is computationally expensive)
- ✅ Resistant to rainbow table attacks

## Test 2: Contract Deletion

### 2.1 Setup - Create Contract and Assign to Employee
1. Log in as HR Administrator
2. Navigate to Contracts → Create New Contract
3. Fill in:
   - Employee: Select an employee
   - Type: "Full-time"
   - Start Date: Today
   - End Date: 1 year from today
4. Click "Create"
5. Verify the contract is created and assigned to the employee

### 2.2 Test Contract Deletion
1. Navigate to Contracts → Index (list all contracts)
2. Find the contract you just created
3. Click "Delete"
4. Confirm deletion
5. **Expected Result**: 
   - Success message: "Contract deleted successfully!"
   - Contract is removed from the list
   - No database error occurs

### 2.3 Verify Employee Reference is Cleaned Up
1. Navigate to Employees → Index
2. Find the employee who had the contract
3. Click "Details"
4. **Expected Result**: The employee's contract field should be empty (NULL)

### 2.4 Test the Bug Fix
Previously, this would have resulted in:
```
DbUpdateException: The DELETE statement conflicted with the REFERENCE constraint "FK_Employee_Contract"
```

Now it works correctly because:
- Employee's `contract_id` is set to NULL first
- Then the contract is deleted
- All in a single database transaction

## Test 3: UI Improvements

### 3.1 Verify Home Page Changes
1. Log in with any user account
2. View the homepage
3. **Expected Result**: 
   - Header shows: "Welcome, [Your Name]!"
   - Subtitle shows: "HR Management System - Employee Profiles & Contracts Management"
   - ❌ Should NOT show: "Component 1" in the subtitle

### 3.2 Verify Create Employee Form
1. Log in as System Administrator
2. Navigate to Account → Create Employee
3. **Expected Result**:
   - Form shows: "Profile picture can be added later via profile editing"
   - ❌ No profile image upload field in the form
   - Only essential fields are shown:
     - Full Name, Email, Password, Confirm Password
     - Phone, Date of Birth, Address
     - Role, Department, Position, Manager

## Test 4: System Integration

### 4.1 Test Complete Employee Lifecycle
1. **Create**: Create new employee with password
2. **Login**: Log in with that employee's credentials
3. **Update**: Update personal details via "My Profile"
4. **Contract**: (As HR Admin) Create and assign a contract
5. **Delete Contract**: Delete the contract successfully
6. **Verify**: Check employee still exists with NULL contract

### 4.2 Test Role-Based Access
1. Create employees with different roles:
   - System Administrator
   - HR Administrator
   - Line Manager
   - Employee
2. Test that each role can only access appropriate features:
   - System Admin: Can create employees, manage roles
   - HR Admin: Can create/renew/delete contracts
   - Line Manager: Can view team details
   - Employee: Can view own profile

## Expected Behavior Summary

| Feature | Before Fix | After Fix |
|---------|-----------|-----------|
| Login with any password | ✅ Allowed | ❌ Blocked |
| Login with correct password | ✅ Allowed | ✅ Allowed |
| Password storage | ❌ Not stored | ✅ BCrypt hash stored |
| Delete contract with employee reference | ❌ Database error | ✅ Works correctly |
| Home page subtitle | Shows "Component 1" | Shows clean subtitle |
| Create employee form | N/A | Clean, no profile image field |

## Troubleshooting

### Issue: Cannot log in with old accounts
**Cause**: Old accounts don't have password hashes (password_hash is NULL)

**Solution**: 
1. Either create new accounts after migration
2. Or manually set passwords for existing accounts:
   ```csharp
   // In AccountController, create a temporary endpoint to reset passwords
   // Or directly update password_hash in database with BCrypt hash
   ```

### Issue: "password_hash column doesn't exist" error
**Cause**: Migration script not run

**Solution**: Run `migration_add_password_hash.sql` on your database

### Issue: Contract deletion still fails
**Cause**: Old code might be cached

**Solution**: 
1. Stop the application
2. Clean and rebuild: `dotnet clean && dotnet build`
3. Run again: `dotnet run`

## Security Testing

### Recommended Security Tests:
1. ✅ SQL Injection: Form inputs are parameterized
2. ✅ CSRF Protection: Anti-forgery tokens are used
3. ✅ Password Security: BCrypt hashing implemented
4. ⚠️ Not Implemented (Recommended for Production):
   - Account lockout after failed attempts
   - Password complexity validation
   - Session timeout
   - HTTPS enforcement
   - Two-factor authentication

## Performance Testing

Test contract deletion performance:
1. Create 100 contracts
2. Assign them to employees
3. Time how long it takes to delete each one
4. **Expected**: Should be fast due to single transaction optimization

## Success Criteria

All tests pass if:
- ✅ Cannot log in without correct password
- ✅ Passwords are securely hashed with BCrypt
- ✅ Contracts can be deleted without FK constraint errors
- ✅ Employee contract references are properly cleaned up
- ✅ UI shows clean, professional interface without "Component 1"
- ✅ Employee creation is streamlined and user-friendly
- ✅ All role-based access controls work correctly

## Reporting Issues

If you encounter any issues:
1. Check the browser console for JavaScript errors
2. Check the application logs for exceptions
3. Verify database connection string
4. Ensure migration script was run successfully
5. Check SQL Server logs for database errors

## Next Steps After Testing

Once all tests pass:
1. ✅ Deploy to production environment
2. ✅ Train users on new authentication system
3. ⚠️ Consider implementing additional security features:
   - Password reset functionality
   - Email verification
   - Account lockout
   - Two-factor authentication
