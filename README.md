Database Project - HR Management System

🔴 IMPORTANT: Getting “Invalid column name ‘password_hash’” Error?

READ THIS FIRST: If you’re getting password_hash errors when trying to register or login:
👉 Click here for the fix: PASSWORD_HASH_FIX.md 👈
Quick Fix (30 seconds):

	1.	Open SQL Server Management Studio
	2.	Run the Fix_PasswordHash_Column.sql script
	3.	Done! Registration and login will now work.

About This Project

This is a comprehensive HR Management System built with ASP.NET Core MVC and SQL Server.

Features

	•	Employee Management - Create, view, and manage employee records
	•	Contract Management - Track employment contracts and renewals
	•	Notifications System - Alert users about important events
	•	Analytics & Reporting - Department statistics, compliance, and diversity reports
	•	Organizational Hierarchy - Visual representation of company structure
	•	Role-Based Access Control - Different permissions for different user types

User Roles

	•	System Administrator - Full system access, user management
	•	HR Administrator - Employee records, analytics, compliance reports
	•	Line Manager - Team management, notifications
	•	Employee - View personal information and notifications

Setup Instructions

Prerequisites

	•	SQL Server 2019 or later (or SQL Server LocalDB)
	•	.NET 8.0 SDK
	•	Visual Studio 2022 or VS Code

Database Setup

	1.	Create the database:
	•	Open SQL Server Management Studio
	•	Execute Tables.sql to create the database and tables
	•	Execute Procedures.sql to create stored procedures
	2.	Fix for existing databases:
	•	If you have an existing database with errors, run Fix_PasswordHash_Column.sql

Application Setup

	1.	Update connection string:
	•	Open MS3WebApp/WebAppSystem/WebAppSystem/appsettings.json
	•	Update the connection string to match your SQL Server instance
	2.	Build and run:

cd MS3WebApp/WebAppSystem/WebAppSystem
dotnet build
dotnet run


	3.	Access the application:
	•	Open browser to https://localhost:5001 (or the URL shown in console)
	•	Register a new account or login

Troubleshooting

“Invalid column name ‘password_hash’” Error

See PASSWORD_HASH_FIX.md for detailed instructions.

Database Connection Errors

	1.	Check your connection string in appsettings.json
	2.	Verify SQL Server is running
	3.	Check that you have permissions to access the database

Build Errors

	1.	Make sure .NET 8.0 SDK is installed: dotnet --version
	2.	Restore packages: dotnet restore
	3.	Clean and rebuild: dotnet clean && dotnet build

Documentation

	•	COMPONENT5_IMPLEMENTATION.md - Technical implementation guide
	•	PASSWORD_HASH_FIX.md - Fix for password_hash errors
	•	Tables.sql - Database schema
	•	Procedures.sql - Stored procedures

Project Structure

Database-Project/
├── Tables.sql                      # Database schema
├── Procedures.sql                  # Stored procedures
├── Fix_PasswordHash_Column.sql     # Quick fix for password_hash issue
├── PASSWORD_HASH_FIX.md            # Troubleshooting guide
└── MS3WebApp/
    └── WebAppSystem/
        └── WebAppSystem/
            ├── Controllers/        # MVC Controllers
            ├── Models/            # Data models
            ├── Views/             # Razor views
            └── wwwroot/           # Static files


Contributing

When making changes to the database:

	1.	Update Tables.sql with schema changes
	2.	Update Procedures.sql with stored procedure changes
	3.	Test thoroughly before committing
	4.	Update documentation

License

This project is for educational purposes.