# StaffCraft HR Management System

StaffCraft is a full-stack HR management platform built for organizations to manage their workforce operations. It supports employee profiling, contract tracking, attendance, leave administration, shift scheduling, missions, and analytics — all within a role-based multi-user system.

## Features
- Role-based authentication for System Admins, HR Admins, Line Managers, and Employees
- Employee profile and contract lifecycle management
- Attendance tracking with shift scheduling and exception handling
- Leave request submission, approval, and policy enforcement
- Mission assignment and approval workflows
- Notifications for contract expirations, leave updates, and shift changes
- Analytics and compliance reporting for HR Admins
- Organizational hierarchy visualization

## Tech Stack
- **Framework:** ASP.NET Core MVC
- **Database:** Microsoft SQL Server
- **ORM / Data Access:** ADO.NET / Stored Procedures
- **Frontend:** Razor Views, HTML, CSS, JavaScript
- **Auth:** Session-based authentication with role-based access control

## Project Structure
```text
.
├── Tables.sql
├── Procedures.sql
├── MS3WebApp/
│   └── WebAppSystem/
│       ├── Controllers/
│       ├── Models/
│       ├── Views/
│       └── wwwroot/
```

## Setup
### Prerequisites
- .NET 8.0 SDK
- SQL Server 2019 or later
- Visual Studio 2022 or VS Code

### Database
1. Open SQL Server Management Studio
2. Run `Tables.sql` to create the schema
3. Run `Procedures.sql` to create stored procedures

### Application
1. Update the connection string in `appsettings.json`
2. Run the app:
```bash
cd MS3WebApp/WebAppSystem/WebAppSystem
dotnet build
dotnet run
```
3. Open `https://localhost:5001` in your browser

## Notes
This project was built as a university databases project at GIU (Winter 2025).
