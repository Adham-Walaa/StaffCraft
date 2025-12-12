# Manager Role - Component 2 Testing Guide

## Manager Role Overview

The **Manager** role is a leadership position focused on team management and oversight. Managers can:
- Assign shifts to employees (including team members)
- Assign shifts to entire departments
- View and monitor team attendance
- Approve or reject attendance correction requests from team members
- Edit shift schedules
- Access all shift schedules

## Differences Between Manager and Line Manager

- **Manager**: Higher-level role with broader authority over employees and departments
- **Line Manager**: Direct supervisor role, typically managing a specific team or section

**Both roles are available in Component 2**, but the Manager role has equivalent or enhanced permissions for attendance and shift management.

---

## Manager Role Test Cases

### Prerequisites
1. Register or login with a user account assigned the **Manager** role
2. Ensure there are employees in the database (some should have your Employee ID as their manager_id)
3. Ensure there are departments and shift templates created

---

### 🟢 Test Case M1: Assign Shift to Employee

**Purpose**: Verify that managers can assign shifts to individual employees

**Steps**:
1. Login as Manager
2. Click **"Shifts"** dropdown in navigation
3. Click **"Assign to Employee"**
4. Fill the form:
   - **Employee**: Select an employee from dropdown
   - **Shift Template**: Select from existing templates (or leave empty for custom)
   - **Shift Name**: "Manager Assigned Shift"
   - **Shift Type**: Select "Normal"
   - **Start Time**: 09:00
   - **End Time**: 17:00
   - **Start Date**: Today's date
   - **End Date**: 30 days from today
5. Click **"Assign Shift"** button

**✅ Expected Result**:
- Success message appears: "Shift assigned successfully!"
- Redirected to Shift Schedules list
- New shift visible in the list with "Active" status

---

### 🟢 Test Case M2: Assign Shift to Department (Bulk Assignment)

**Purpose**: Verify that managers can assign shifts to all employees in a department

**Steps**:
1. Login as Manager
2. Click **"Shifts"** → **"Assign to Department"**
3. Fill the form:
   - **Department**: Select a department from dropdown
   - **Shift Template**: Select an existing shift template
   - **Start Date**: Today's date
   - **End Date**: 60 days from today
4. Click **"Assign to Department"** button

**✅ Expected Result**:
- Success message appears: "Shift assigned to X employees in the department successfully!"
- All employees in the selected department now have the shift assigned
- Redirected to Shift Schedules list showing all new assignments

**❌ Error Scenarios**:
- If no department selected: "Please select a department" error
- If no shift template selected: "Please select a shift template" error
- If department has no employees: "No employees found in the selected department" message

---

### 🟢 Test Case M3: Edit Shift Schedule

**Purpose**: Verify that managers can edit existing shift schedules

**Steps**:
1. Login as Manager
2. Click **"Shifts"** → **"All Shift Schedules"**
3. Find any shift schedule and click **"Edit"**
4. Modify the fields using dropdowns and time pickers:
   - **Status**: Change to "Active" or "Inactive"
   - **Shift Type**: Select from dropdown (Normal, Rotational, Custom, Special, Night, Split)
   - **Start Time**: Use time picker to change time
   - **End Time**: Use time picker to change time
   - **Dates**: Modify Start Date or End Date
5. Click **"Save"** button

**✅ Expected Result**:
- Success message appears
- Changes are saved and visible in the list
- All fields use dropdowns/time pickers (no manual typing needed)

**❌ Access Denied**:
- If you see an Access Denied page, it means your account doesn't have Manager role assigned properly

---

### 🟢 Test Case M4: View Team Attendance

**Purpose**: Verify that managers can view their team's attendance records

**Steps**:
1. Login as Manager
2. Click **"Attendance"** → **"Team Attendance"**
3. Review the page content

**✅ Expected Result**:
- **Summary Section**: Shows each team member with:
  - Employee name and ID
  - Today's attendance status
  - Link to view employee profile
- **Detailed Records Section**: Shows table with:
  - All team members' attendance records
  - Entry times, exit times, duration
  - Login/logout methods
  - Exception details (if any)

**❌ Error Scenarios**:
- If no employees have your employee_id as manager_id, you'll see "No team members found" message
- Access denied if Manager role not properly assigned

---

### 🟢 Test Case M5: Approve Attendance Correction Request

**Purpose**: Verify that managers can approve correction requests from employees

**Steps**:
1. First, ensure there's a pending correction request:
   - Login as an Employee
   - Submit a correction request (Attendance → Submit Correction)
   - Logout
2. Login as Manager
3. Click **"Attendance"** → **"All Correction Requests"**
4. Find a request with **Pending** status
5. Click **"Approve"** button (green button in the list)
6. Confirm the action if prompted

**✅ Expected Result**:
- Request status changes from "Pending" to "Approved"
- Your employee ID recorded as the approver
- Request disappears from pending list or shows "Approved" badge

**Note**: Approve/Reject buttons only appear for:
- Managers
- HR Administrators
- Requests with "Pending" status

---

### 🟢 Test Case M6: Reject Attendance Correction Request

**Purpose**: Verify that managers can reject correction requests

**Steps**:
1. Login as Manager
2. Click **"Attendance"** → **"All Correction Requests"**
3. Find a request with **Pending** status
4. Click **"Reject"** button (red button in the list)
5. Confirm the action if prompted

**✅ Expected Result**:
- Request status changes from "Pending" to "Rejected"
- Your employee ID recorded as the rejector
- Request shows "Rejected" badge

---

### 🟢 Test Case M7: View All Shift Schedules

**Purpose**: Verify that managers can view all shift schedules

**Steps**:
1. Login as Manager
2. Click **"Shifts"** → **"All Shift Schedules"**

**✅ Expected Result**:
- Table showing all shift schedules across the organization
- Columns include: Employee, Shift Name, Type, Times, Dates, Status
- **Edit** button visible for each schedule (Manager can edit)
- **Delete** button NOT visible (only System Admin can delete)

---

### 🟢 Test Case M8: Record Own Attendance

**Purpose**: Verify that managers can record their own attendance (same as employees)

**Steps**:
1. Login as Manager
2. Click **"Attendance"** → **"Record Attendance"**
3. Fill the form:
   - **Entry Time**: 09:00 (use time picker)
   - **Exit Time**: 17:30 (use time picker)
   - **Login Method**: Select "Web Portal" from dropdown
   - **Logout Method**: Select "Web Portal" from dropdown
4. Click **"Record Attendance"** button

**✅ Expected Result**:
- Success message: "Attendance recorded successfully!"
- Duration automatically calculated (in minutes)
- Record visible in "My Attendance" page

---

## Manager Role Navigation Menu

When logged in as Manager, you should see:

**Attendance Dropdown:**
- My Attendance
- Record Attendance
- My Correction Requests
- Submit Correction
- **Team Attendance** ← Manager-specific
- (No "All Attendance Records" - that's for System/HR Admin)

**Shifts Dropdown:**
- Assign to Employee ← Manager can do this
- Assign to Department ← Manager can do this
- All Shift Schedules
- (No "Create Shift Type" - that's for System Admin)
- (No "Split Shifts" or "Rotational Shifts" - that's for HR Admin)

---

## Common Issues & Troubleshooting

### ❌ "Access Denied" Error When Editing Shift

**Problem**: You see an Access Denied page when trying to edit a shift

**Solution**:
1. Check your role assignment in database:
   ```sql
   SELECT * FROM EmployeeRole WHERE employee_id = YOUR_ID
   ```
2. Ensure you have Manager role assigned
3. The Access Denied page should show:
   - Clear message: "You do not have permission to edit shift schedules"
   - Allowed roles: "System Administrator or Manager"
   - "Go Back" and "Go to Home" buttons

### ❌ No Confirmation Message After Assigning Shift to Department

**Problem**: After clicking "Assign to Department", nothing happens

**Solution**:
1. Check if you selected both Department and Shift Template
2. Look for validation errors in red text below the form fields
3. Success message should appear at the top of Shift Schedules page
4. If still no message, check browser console for JavaScript errors

### ❌ Approve/Reject Buttons Not Showing

**Problem**: Can't see Approve/Reject buttons for correction requests

**Solution**:
1. Buttons only show for **Pending** requests
2. Check if request status is exactly "Pending" (case-sensitive in database)
3. Refresh the page to see latest status
4. Verify you're logged in as Manager or HR Administrator

### ❌ No Team Members in Team Attendance

**Problem**: "No team members found" message in Team Attendance

**Solution**:
1. Check if any employees have your employee_id as their manager_id:
   ```sql
   SELECT * FROM Employee WHERE manager_id = YOUR_EMPLOYEE_ID
   ```
2. If no employees assigned, ask System Admin to assign employees to you

---

## Manager vs Other Roles - Quick Reference

| Feature | Manager | System Admin | HR Admin | Employee |
|---------|---------|--------------|----------|----------|
| Assign shift to employee | ✅ | ✅ | ❌ | ❌ |
| Assign shift to department | ✅ | ✅ | ❌ | ❌ |
| Create shift types | ❌ | ✅ | ❌ | ❌ |
| Edit shift schedules | ✅ | ✅ | ❌ | ❌ |
| Delete shift schedules | ❌ | ✅ | ❌ | ❌ |
| View team attendance | ✅ | ✅ | ❌ | ❌ |
| Approve/reject corrections | ✅ | ✅ | ✅ | ❌ |
| Configure split shifts | ❌ | ❌ | ✅ | ❌ |
| Configure rotational shifts | ❌ | ❌ | ✅ | ❌ |
| Sync leaves | ❌ | ✅ | ❌ | ❌ |
| Record own attendance | ✅ | ✅ | ✅ | ✅ |
| Submit correction requests | ✅ | ✅ | ✅ | ✅ |

---

## Summary

The Manager role is successfully integrated into Component 2 with:
- ✅ Full shift assignment capabilities
- ✅ Team attendance monitoring
- ✅ Correction request approval/rejection
- ✅ Edit permissions for shift schedules
- ✅ User-friendly dropdowns and time pickers for all forms
- ✅ Clear access control with friendly error messages
- ✅ Available in registration dropdown alongside Line Manager

All test cases should pass successfully after the latest fixes in commit `[COMMIT_HASH]`.
