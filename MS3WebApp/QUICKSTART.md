# Quick Start Guide - Component 1 Implementation

## 5-Minute Setup

### 1. Database Setup (2 minutes)
```sql
-- In SQL Server Management Studio or Azure Data Studio:
-- 1. Create database
CREATE DATABASE MILESTONE2;

-- 2. Run these scripts in order:
-- a. Tables.sql (from project root)
-- b. Procedures.sql (from project root)
```

### 2. Open in Visual Studio (1 minute)
1. Open Visual Studio 2022
2. File → Open → Project/Solution
3. Navigate to `MS3WebApp/WebAppSystem/WebAppSystem.csproj`
4. Click Open

### 3. Update Connection String (30 seconds)
In `appsettings.json`:
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=YOUR_SERVER;Database=MILESTONE2;Trusted_Connection=True;"
  }
}
```

### 4. Run Application (30 seconds)
- Press **F5** or click the green play button
- Browser opens automatically

### 5. First Login (1 minute)
1. Click **"Register"**
2. Fill form:
   - Full Name: Your Name
   - Email: your@email.com
   - Password: Password123
   - Role: System Administrator
3. Click **"Register"**
4. Login with your credentials

## Quick Test Scenarios

### Test 1: Create Employee (System Admin)
1. Top menu → User dropdown → "Create Employee"
2. Fill employee details
3. Assign role
4. Click Create

### Test 2: Create Contract (HR Admin)
1. Register as HR Admin (or assign HR Admin role)
2. Contracts → "Create Contract"
3. Select employee
4. Choose contract type
5. Set dates
6. Click Create

### Test 3: View Team (Manager)
1. Assign Line Manager role to your account
2. Create employees with your ID as manager_id
3. Top menu → Employees → "My Team"
4. See your team members

### Test 4: Update Profile (Any User)
1. User dropdown → "My Profile"
2. Click "Edit Profile"
3. Update contact info
4. Click Save

## Common URLs

- **Home:** https://localhost:7XXX/
- **Login:** https://localhost:7XXX/Account/Login
- **Register:** https://localhost:7XXX/Account/Register
- **Employees:** https://localhost:7XXX/Employees
- **Contracts:** https://localhost:7XXX/Contracts

## Default Roles Available

- **System Administrator** - Full access, create employees, manage roles
- **HR Administrator** - Manage contracts, edit profiles, track completeness
- **Line Manager** - View team, access team member profiles
- **Employee** - View/edit own profile

## Key Features Checklist

### General Component ✓
- ✅ User registration and login
- ✅ System Admin creates employee accounts
- ✅ HR Admin edits profiles
- ✅ Session-based authentication
- ✅ Role-based access control

### Component 1 - Employee Profiles ✓
- ✅ View full employee profiles
- ✅ Update personal details
- ✅ Update emergency contacts
- ✅ System Admin assigns roles
- ✅ View all employees
- ✅ Manager views team
- ✅ HR Admin manages profile completion

### Component 1 - Contract Management ✓
- ✅ HR Admin creates contracts
- ✅ HR Admin renews contracts
- ✅ View active contracts
- ✅ Track expiring contracts
- ✅ Contract type support (Full-Time, Part-Time, Consultant, Internship)

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Can't connect to DB | Check SQL Server is running, verify connection string |
| Can't login | Verify email/password, check account is active |
| Menu items missing | Logout and login again, verify role assignment |
| Build errors | Restore NuGet packages, rebuild solution |
| Stored procedure errors | Run Procedures.sql script again |

## Need More Help?

See the full **README.md** in the MS3WebApp folder for:
- Detailed feature descriptions
- Complete troubleshooting guide
- Project structure
- Testing workflows
- Security features

---

**Quick Reference:**
- Press **F5** to run with debugging
- Press **Ctrl+F5** to run without debugging
- Press **Ctrl+Shift+B** to build solution
- Press **Ctrl+Alt+L** to open Solution Explorer
