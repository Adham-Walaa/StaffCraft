# HR Management System - Component 1 Implementation Guide

## Overview
This ASP.NET Core MVC web application implements **Component 1 (Employee Profiles & Contracts Management)** and the **General Component (Bonus)** as specified in Milestone 3 requirements.

> ⚠️ **IMPORTANT**: This is an educational prototype. See [SECURITY_NOTES.md](SECURITY_NOTES.md) for security limitations and production requirements.

## Features Implemented

### General Component (Bonus)
- ✅ User Authentication & Registration
  - Login system with email and password
  - Registration for System Admins, HR Admins, Line Managers, and Employees
  - Session-based authentication
  - Role-based access control

- ✅ Account Management
  - System Admins can create employee accounts with department, position, and manager assignment
  - HR Admins can edit any employee profile
  - All employees can log in using their credentials

### Component 1 - Employee Profile Management
- ✅ Profile Viewing & Editing
  - Admins and Managers can view full employee profiles
  - Employees can update their personal details (phone, email, address)
  - Employees can manage emergency contact information
  - Personal biography section

- ✅ Role Management (System Administrators)
  - Assign system roles (Employee, HR Admin, Manager, System Admin)
  - View all employees across all departments
  - Manage role assignments through stored procedures

- ✅ Team Management (Line Managers)
  - View team details using `GetTeamByManager` stored procedure
  - Access team members' profiles
  - Monitor team structure

- ✅ Profile Completeness (HR Administrators)
  - Track and manage employee profile completion percentage
  - Visual progress indicators
  - Update completion status

### Component 1 - Contract Management
- ✅ Contract Creation (HR Administrators)
  - Create employment contracts using `CreateContract` stored procedure
  - Support for Full-Time, Part-Time, Consultant, and Internship contracts
  - Automatic contract validation

- ✅ Contract Renewal (HR Administrators)
  - Renew or extend expiring contracts using `RenewContract` stored procedure
  - Update end dates with validation

- ✅ Contract Monitoring
  - View all active contracts using `getActiveContracts` stored procedure
  - Track expiring contracts using `GetExpiringContracts` stored procedure
  - Configurable expiry alerts (7, 14, 30, 60, 90 days)
  - Visual warnings for urgent contract renewals

## Prerequisites

### Software Requirements
- **Visual Studio 2022** (Community, Professional, or Enterprise)
- **.NET 8.0 SDK** or later
- **SQL Server 2019** or later (or SQL Server Express/LocalDB)

### Database Setup
1. Ensure SQL Server is running
2. The database name should be: `MILESTONE2`
3. Run the SQL scripts in this order:
   - `Tables.sql` - Creates all database tables
   - `Procedures.sql` - Creates stored procedures
   - `Procedures_Tests.sql` (optional) - Tests stored procedures

## How to Run the Application in Visual Studio

### Step 1: Open the Solution
1. Launch **Visual Studio 2022**
2. Click **File → Open → Project/Solution**
3. Navigate to: `MS3WebApp/WebAppSystem/`
4. Open `WebAppSystem.slnx` or `WebAppSystem.csproj`

### Step 2: Configure Database Connection
1. Open `appsettings.json`
2. Update the connection string if needed:
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=(localdb)\\MSSQLLocalDB;Database=MILESTONE2;Trusted_Connection=True;"
  }
}
```

For SQL Server instead of LocalDB:
```json
"DefaultConnection": "Server=YOUR_SERVER_NAME;Database=MILESTONE2;Trusted_Connection=True;"
```

### Step 3: Restore NuGet Packages
1. Right-click on the solution in **Solution Explorer**
2. Select **Restore NuGet Packages**
3. Wait for packages to download

### Step 4: Build the Solution
1. Press **Ctrl+Shift+B** or
2. Click **Build → Build Solution**
3. Ensure build succeeds with 0 errors (warnings are okay)

### Step 5: Run the Application
1. Press **F5** to run with debugging, or **Ctrl+F5** to run without debugging
2. The browser will automatically open to the home page
3. Default URL: `https://localhost:7XXX` or `http://localhost:5XXX`

## Using the Application

### First-Time Setup

#### 1. Register Your First Account
- Navigate to the home page
- Click **"Register"** button
- Fill in the registration form:
  - Full Name
  - Email (will be used for login)
  - Password
  - Select Role (System Administrator, HR Administrator, Line Manager, or Employee)
  - Optional: Phone, Date of Birth, Address
- Click **"Register"**

#### 2. Login
- After registration, you'll be redirected to the Login page
- Enter your email and password
- Click **"Login"**

### Role-Based Features

#### System Administrator
After logging in as System Admin, you can:
- **Create Employee Accounts**
  - Navigate: Top menu → User dropdown → "Create Employee"
  - Fill in employee details including department, position, and manager
  - Assign initial role
  
- **Manage Roles**
  - Navigate: Employees → View any employee → "Manage Roles"
  - Add or remove system roles
  - Roles: System Administrator, HR Administrator, Line Manager, Payroll Officer, Payroll Specialist, Employee

- **View All Employees**
  - Navigate: Top menu → Employees → "All Employees"
  - See complete employee directory

#### HR Administrator
After logging in as HR Admin, you can:
- **Create Employment Contracts**
  - Navigate: Contracts → "Create Contract"
  - Select employee (without active contract)
  - Choose contract type: Full-Time, Part-Time, Consultant, or Internship
  - Set start and end dates
  
- **View Active Contracts**
  - Navigate: Contracts → "Active Contracts"
  - See all currently active employment contracts
  - Monitor days remaining
  
- **Track Expiring Contracts**
  - Navigate: Contracts → "Expiring Contracts"
  - Filter by days before expiry (7, 14, 30, 60, 90 days)
  - Color-coded alerts:
    - Red: Expiring within 7 days (URGENT)
    - Yellow: Expiring within 8-30 days
    - Blue: Expiring beyond 30 days
  
- **Renew Contracts**
  - From Active or Expiring Contracts view, click "Renew"
  - Set new end date
  - System validates and updates contract
  
- **Manage Profile Completion**
  - Navigate: Employees → View employee → "Update Profile Completion"
  - Adjust completion percentage (0-100%)
  - Guidelines provided for scoring

- **Edit Employee Profiles**
  - Navigate to any employee's profile
  - Click "Edit"
  - Update any profile information

#### Line Manager
After logging in as Line Manager, you can:
- **View Your Team**
  - Navigate: Top menu → Employees → "My Team"
  - See all direct reports
  - Access team members' profiles
  
- **View Team Details**
  - Employee ID, Full Name, Email, Phone
  - Department and Position
  - Hire Date and Employment Status

#### Employee (All Users)
All logged-in users can:
- **View Personal Profile**
  - Navigate: User dropdown → "My Profile"
  - See all personal and employment information
  - View profile completion percentage
  
- **Edit Personal Details**
  - From "My Profile", click "Edit Profile"
  - Update:
    - Contact information (Email, Phone, Address)
    - Emergency contacts (Name, Phone, Relationship)
    - Biography

### Navigation

#### Top Menu Structure
```
Home | Employees ▼ | Contracts ▼ | [User Name] ▼
```

**Employees Dropdown:**
- All Employees
- Create Employee (System Admin only)
- Manage Roles (System Admin only)
- My Team (Line Manager only)

**Contracts Dropdown:**
- All Contracts
- Create Contract (HR Admin only)
- Active Contracts (HR Admin only)
- Expiring Contracts (HR Admin only)

**User Dropdown:**
- My Profile
- Logout

## Stored Procedures Used

The application integrates with the following stored procedures from `Procedures.sql`:

### Employee Management
- `ViewEmployeeInfo` - View employee details
- `AddEmployee` - Create new employee
- `UpdateEmployeeInfo` - Update employee contact information
- `ManageUserAccounts` - Manage user roles and accounts
- `GetTeamByManager` - Retrieve manager's team members

### Contract Management
- `CreateContract` - Create new employment contract
- `RenewContract` - Renew/extend existing contract
- `getActiveContracts` - List all active contracts
- `GetExpiringContracts` - Find contracts expiring soon

## Troubleshooting

### Database Connection Issues
**Problem:** Cannot connect to database
**Solution:**
1. Verify SQL Server is running
2. Check connection string in `appsettings.json`
3. Ensure database `MILESTONE2` exists
4. Run Tables.sql and Procedures.sql scripts

### Login Issues
**Problem:** Cannot login after registration
**Solution:**
1. Verify email and password are correct
2. Check that employee record was created in database
3. Ensure `is_active` is set to 1 in Employee table

### Role-Based Features Not Showing
**Problem:** Menu items or features are missing
**Solution:**
1. Verify role was assigned during registration
2. Check EmployeeRole table in database
3. Logout and login again to refresh session

### Build Errors
**Problem:** Project doesn't build
**Solution:**
1. Restore NuGet packages: Right-click solution → Restore NuGet Packages
2. Clean solution: Build → Clean Solution
3. Rebuild: Build → Rebuild Solution

### Runtime Errors
**Problem:** Stored procedure errors
**Solution:**
1. Verify all stored procedures exist in database
2. Run Procedures.sql script
3. Check procedure signatures match controller calls

## Project Structure

```
MS3WebApp/WebAppSystem/WebAppSystem/
├── Controllers/
│   ├── AccountController.cs        # Authentication & user management
│   ├── EmployeesController.cs      # Employee profile management
│   ├── ContractsController.cs      # Contract management
│   └── HomeController.cs           # Home page
├── Models/
│   ├── Employee.cs                 # Employee entity
│   ├── Contract.cs                 # Contract entity
│   ├── LoginViewModel.cs           # Login form model
│   ├── RegisterViewModel.cs        # Registration form model
│   └── Milestone2Context.cs        # Database context
├── Views/
│   ├── Account/                    # Login, Register, CreateEmployee
│   ├── Employees/                  # Profile views, MyTeam, ManageRoles
│   ├── Contracts/                  # Contract CRUD, Active, Expiring
│   ├── Home/                       # Home page
│   └── Shared/                     # Layout, navigation
├── wwwroot/                        # Static files (CSS, JS, images)
├── Program.cs                      # Application startup
└── appsettings.json               # Configuration
```

## Key Technologies

- **ASP.NET Core 8.0** - Web framework
- **Entity Framework Core** - ORM for database access
- **SQL Server** - Database
- **Bootstrap 5** - UI framework
- **Razor Pages** - View engine
- **Session State** - Authentication

## Success Notifications

The application provides user feedback for all actions:
- ✅ **Green Success Messages** - Operation completed successfully
- ❌ **Red Error Messages** - Operation failed with reason
- ℹ️ **Blue Info Messages** - Informational updates

## Security Features

- Session-based authentication
- Role-based access control
- SQL injection protection (parameterized queries)
- CSRF protection (anti-forgery tokens)
- Password validation (minimum 6 characters)

## Testing Workflow

### Test Employee Profile Management
1. Register as System Admin
2. Create an employee account
3. Assign roles to the employee
4. Login as the employee
5. Update personal profile and emergency contacts
6. Verify changes persist

### Test Contract Management
1. Login as HR Admin
2. Create a new contract for an employee
3. View active contracts list
4. Check expiring contracts (set future dates close to today)
5. Renew a contract
6. Verify contract end date updated

### Test Team Management
1. Create manager and employee accounts
2. Assign manager_id to employees
3. Login as the manager
4. View "My Team"
5. Verify team members appear

## Additional Notes

### Profile Completion Guidelines
- **0-30%**: Basic information only (Name, Email)
- **31-60%**: Contact details and emergency contacts added
- **61-80%**: Employment details, department, and position assigned
- **81-100%**: All information complete including contract, biography, and documents

### Contract Types
- **Full-Time**: Standard employment (40 hours/week, benefits, 20 days leave)
- **Part-Time**: Reduced hours with hourly rate
- **Consultant**: Project-based with defined scope and fees
- **Internship**: Training period with mentoring and evaluation

## Support

For issues or questions:
1. Check this README
2. Review stored procedures in Procedures.sql
3. Check application logs in Visual Studio Output window
4. Verify database schema matches Tables.sql

## Next Steps

After implementing Component 1, consider:
- Component 2: Attendance & Shift Management
- Component 3: Leave Management System
- Component 4: Mission & Task Management
- Component 5: Notifications, Analytics & Hierarchy Dashboard

---

**Project:** Database Project - Milestone 3
**Component:** Component 1 + General Component (Bonus)
**Technology Stack:** ASP.NET Core MVC, SQL Server, Entity Framework Core
**Status:** ✅ Implemented and tested
