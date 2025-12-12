# Manager Role - Complete Testing Guide for Component 2

## Overview
The **Manager** role in Component 2 has specific permissions for shift management and team attendance monitoring. This guide provides step-by-step instructions for testing all Manager-specific features.

---

## Prerequisites

### 1. Setup Database
Ensure you have:
- Employees table with data
- At least one department with employees
- At least one employee with `manager_id` pointing to your Manager's `employee_id`
- Proper role assignment in `EmployeeRole` table

### 2. Run the Application
```bash
cd MS3WebApp/WebAppSystem/WebAppSystem
dotnet restore
dotnet build
dotnet run
```

### 3. Create Manager Account
1. Open browser to `https://localhost:XXXX`
2. Click **Register**
3. Fill in registration form
4. For **Role**, select **"Manager"** from dropdown
5. Complete registration
6. Login with your Manager credentials

---

## Manager Permissions (Component 2 Specification)

According to Component 2 requirements, **Manager** can:
- ✅ Assign shifts to employees
- ✅ Assign shifts to departments (bulk assignment)
- ✅ Edit shift schedules
- ✅ View team attendance summary
- ✅ Approve/reject attendance correction requests from their team

**Manager CANNOT:**
- ❌ Create shift types (System Admin only)
- ❌ Delete shift schedules (System Admin only)
- ❌ Configure split shifts (HR Admin only)
- ❌ Configure rotational shifts (HR Admin only)
- ❌ Sync leaves with attendance (System Admin only)

---

## Test Cases for Manager Role

### 🟢 TEST CASE M1: Assign Shift to Employee

**Purpose:** Verify Manager can assign a shift to an individual employee

**Steps:**
1. Login as **Manager**
2. In the top navigation menu, click **"Shifts"** dropdown
3. Click **"Assign to Employee"**
4. **Expected:** AssignToEmployee page loads successfully
5. Fill in the form:
   - **Employee:** Select an employee from the dropdown
   - **Shift Template:** Select an existing template (if available)
   - OR enter custom shift details:
     - **Shift Name:** "Morning Shift"
     - **Shift Type:** Select "Normal" from dropdown
     - **Start Time:** 09:00
     - **End Time:** 17:00
   - **Start Date:** Select today's date
   - **End Date:** Select date 1 month from today
6. Click **"Assign Shift"** button
7. **Expected Results:**
   - ✅ Success message appears: "Shift assigned successfully!"
   - ✅ Redirected to Shift Schedules list
   - ✅ New shift appears in the list with "Active" status

**What to Check:**
- Employee name displayed correctly
- Start/End times match what you entered
- Status shows "Active"

---

### 🟢 TEST CASE M2: Assign Shift to Department (Bulk Assignment)

**Purpose:** Verify Manager can assign shifts to all employees in a department

**Steps:**
1. Login as **Manager**
2. Click **"Shifts"** → **"Assign to Department"**
3. **Expected:** AssignToDepartment page loads with info alert
4. Fill in the form:
   - **Department:** Select a department from dropdown (e.g., "IT Department")
   - **Shift Template:** Select a shift template (e.g., "Morning Shift (Normal)")
   - **Start Date:** Select today's date
   - **End Date:** Select date 3 months from today
5. Click **"Assign to Department"** button
6. **Expected Results:**
   - ✅ Success message appears: "Shift assigned to X employees in the department successfully!"
   - ✅ X = number of employees in that department
   - ✅ Redirected to Shift Schedules list
   - ✅ Multiple new shift records appear (one per employee in department)

**What to Check:**
- Count of assigned shifts matches department employee count
- All shifts have the same template details
- All shifts show "Active" status

**Troubleshooting:**
- If error says "Please select a shift template": Make sure you selected an option, not the "-- Select Shift Template --" placeholder
- If error says "No employees found": Check that the department has employees in the database
- If nothing happens: Ensure both Department and Template are selected

---

### 🟢 TEST CASE M3: Edit Shift Schedule

**Purpose:** Verify Manager can modify existing shift assignments

**Steps:**
1. Login as **Manager**
2. Click **"Shifts"** → **"All Shift Schedules"**
3. **Expected:** List of all shift schedules appears
4. Find any shift and click the **"Edit"** button
   - **Note:** Only System Admin and Manager can see Edit button
5. **Expected:** Edit page loads with dropdown fields
6. Modify the shift:
   - **Shift Name:** Change to "Afternoon Shift"
   - **Shift Type:** Select "Custom" from dropdown
   - **Status:** Select "Active" from dropdown
   - **Start Time:** Use time picker to select 13:00
   - **End Time:** Use time picker to select 21:00
   - **Start Date/End Date:** Update if needed
7. Click **"Save"** or **"Update"** button
8. **Expected Results:**
   - ✅ Success message appears
   - ✅ Redirected to Shift Schedules list
   - ✅ Modified shift shows updated values

**What to Check:**
- Dropdown fields provide easy selection (no manual typing)
- Time pickers show properly formatted times
- Changes are saved correctly

---

### 🟢 TEST CASE M4: View Team Attendance Summary

**Purpose:** Verify Manager can see attendance records for their team members

**Setup Required:**
- In database, ensure some employees have `manager_id` = your Manager's `employee_id`
- Those employees should have some attendance records

**Steps:**
1. Login as **Manager**
2. In the top navigation menu, click **"Attendance"** dropdown
3. Click **"Team Attendance"**
4. **Expected:** Team Attendance page loads
5. **Expected Results:**
   - ✅ **Summary Section** displays:
     - Each team member's name
     - Status (e.g., "Present", "Absent", "On Leave")
     - Recent attendance info
   - ✅ **Detailed Records Section** shows:
     - Table with all attendance entries
     - Columns: Employee Name, Date, Entry Time, Exit Time, Duration, Status
     - Links to view employee profiles
   - ✅ Only YOUR team members appear (based on manager_id)

**What to Check:**
- No attendance from employees NOT in your team
- All your team members are listed
- Attendance data displays correctly

**Troubleshooting:**
- If empty: Assign yourself as manager_id for some employees in database
- If showing all employees: Check session data has correct employee_id

---

### 🟢 TEST CASE M5: Approve Attendance Correction Request

**Purpose:** Verify Manager can approve correction requests from team members

**Setup Required:**
- A team member (employee with your manager_id) must have submitted a correction request
- The request status must be "Pending"

**Steps:**
1. Login as **Manager**
2. Click **"Attendance"** → **"All Correction Requests"**
3. **Expected:** List of correction requests appears
4. Find a request with status **"Pending"** (yellow badge)
5. **Option A - Direct Approval (Quickest):**
   - Click the **"Approve"** button (green, small) directly in the list
   - **Expected:** Status changes to "Approved" (green badge)
6. **Option B - Via Details Page:**
   - Click **"Details"** link
   - On the details page, click **"Approve"** button
   - Confirm approval if prompted
   - **Expected:** Status changes to "Approved"

**Expected Results:**
- ✅ Status badge changes from yellow "Pending" to green "Approved"
- ✅ Your name recorded as approver
- ✅ Approval timestamp recorded

**What to Check:**
- Approve button only appears for Pending requests
- Manager name shown as approved_by
- Original request details preserved

---

### 🟢 TEST CASE M6: Reject Attendance Correction Request

**Purpose:** Verify Manager can reject correction requests from team members

**Steps:**
1. Login as **Manager**
2. Click **"Attendance"** → **"All Correction Requests"**
3. Find a **"Pending"** correction request
4. **Option A - Direct Rejection:**
   - Click the **"Reject"** button (red, small) directly in the list
   - **Expected:** Status changes to "Rejected" (red badge)
5. **Option B - Via Details Page:**
   - Click **"Details"** link
   - Click **"Reject"** button
   - Confirm rejection if prompted
   - **Expected:** Status changes to "Rejected"

**Expected Results:**
- ✅ Status badge changes to red "Rejected"
- ✅ Your name recorded as reviewer
- ✅ Rejection timestamp recorded

**What to Check:**
- Reject button only appears for Pending requests
- Employee can see rejection status in their "My Correction Requests" page

---

### 🟢 TEST CASE M7: View All Shift Schedules (Read-Only for Others)

**Purpose:** Verify Manager can view all shifts but only edit their assignments

**Steps:**
1. Login as **Manager**
2. Click **"Shifts"** → **"All Shift Schedules"**
3. **Expected:** List of all shift schedules appears
4. Observe the action buttons:
   - ✅ **Edit** button: Should appear for shifts you can manage
   - ✅ **Details** button: Should appear for all shifts
   - ❌ **Delete** button: Should NOT appear (System Admin only)
5. Try clicking **Details** on any shift
6. **Expected:** Read-only view of shift details

**What to Check:**
- Can view all shifts (not just your team's)
- Edit permission enforced correctly
- Delete option not visible

---

### 🟢 TEST CASE M8: Access Denied - Try Restricted Actions

**Purpose:** Verify Manager is properly blocked from unauthorized actions

**Test 8A - Try to Create Shift Type:**
1. Try to access: `https://localhost:XXXX/ShiftSchedules/CreateShiftType`
2. **Expected:** Friendly AccessDenied page appears
3. **Expected Message:** "You do not have permission to create shift types"
4. **Expected:** Shows which roles CAN do this: "System Administrator"
5. Buttons: "Go Back" and "Go to Home"

**Test 8B - Try to Access Split Shifts:**
1. Try to access: `https://localhost:XXXX/SplitShifts`
2. **Expected:** Friendly AccessDenied page appears
3. **Expected Message:** "You do not have permission to manage split shifts"
4. **Expected:** Shows "HR Administrator" can do this

**Test 8C - Try to Sync Leaves:**
1. Try to access: `https://localhost:XXXX/Attendances/SyncLeaves`
2. **Expected:** Friendly AccessDenied page appears
3. **Expected Message:** Indicates System Administrator permission required

**What to Check:**
- ❌ NO ugly exception pages with stack traces
- ✅ Professional access denied page with Bootstrap styling
- ✅ Clear message about which role can perform action
- ✅ Easy navigation back to home

---

## Navigation Menu Verification

### Manager Should See:

**Shifts Dropdown:**
- ✅ Assign to Employee
- ✅ Assign to Department
- ✅ All Shift Schedules
- ❌ Create Shift Type (not visible)
- ❌ Split Shifts (not visible)
- ❌ Rotational Shifts (not visible)

**Attendance Dropdown:**
- ✅ My Attendance
- ✅ Record Attendance
- ✅ Team Attendance
- ✅ My Correction Requests
- ✅ Submit Correction
- ✅ All Correction Requests
- ❌ Sync Leaves (not visible)

**Other Menus:**
- All employee-level features (profile, etc.)

---

## Common Issues & Solutions

### Issue 1: "Please select a shift template" error when template IS selected
**Solution:** 
- Make sure the dropdown shows actual shift names, not "-- Select Shift Template --"
- Ensure shift templates exist in database with Status = "Template"
- This was fixed in the latest commit

### Issue 2: Team Attendance page is empty
**Solution:**
- Check database: SELECT * FROM Employee WHERE manager_id = [your_employee_id]
- Ensure employees have your ID as their manager
- Add attendance records for those employees

### Issue 3: Can't see Approve/Reject buttons
**Solution:**
- Buttons only appear for "Pending" requests
- Check request status in database (must be "Pending", not "pending")
- Case-insensitive comparison implemented in latest version

### Issue 4: Navigation menu doesn't show Manager-specific items
**Solution:**
- Verify session: Check HttpContext.Session.GetString("UserRoles") contains "Manager"
- Check database EmployeeRole table for correct role assignment
- Log out and log back in to refresh session

---

## Database Verification Queries

```sql
-- Check your Manager role assignment
SELECT e.employee_id, e.first_name, e.last_name, r.role_name
FROM Employee e
JOIN EmployeeRole er ON e.employee_id = er.employee_id
JOIN Role r ON er.role_id = r.role_id
WHERE e.email = 'your.manager.email@example.com';

-- Check who reports to you
SELECT employee_id, first_name, last_name, manager_id
FROM Employee
WHERE manager_id = [your_employee_id];

-- Check shift templates available
SELECT ShiftId, ShiftName, ShiftType, Status
FROM ShiftSchedules
WHERE Status = 'Template';

-- Check correction requests for your team
SELECT cr.*, e.first_name, e.last_name
FROM AttendanceCorrectionRequest cr
JOIN Employee e ON cr.employee_id = e.employee_id
WHERE e.manager_id = [your_employee_id]
ORDER BY cr.submission_date DESC;
```

---

## Quick Test Checklist

✅ **M1:** Assign shift to individual employee  
✅ **M2:** Assign shift to entire department  
✅ **M3:** Edit existing shift schedule  
✅ **M4:** View team attendance summary  
✅ **M5:** Approve correction request  
✅ **M6:** Reject correction request  
✅ **M7:** View all shifts (read-only for others)  
✅ **M8:** Access denied pages work correctly  

---

## Success Criteria

All tests pass when:
1. Manager can perform all allowed actions without errors
2. Success messages appear after each action
3. Data saves correctly to database
4. Access denied pages appear (not exceptions) for restricted actions
5. Navigation menu shows correct items for Manager role
6. UI remains consistent with Bootstrap styling throughout

---

## Need Help?

**If tests fail:**
1. Check VERIFICATION_GUIDE.md to ensure latest code pulled
2. Run `dotnet build` and check for errors
3. Verify database has required data (employees, roles, departments)
4. Check browser console for JavaScript errors
5. Review commit `acc0158` for all Manager role changes

**For Component 2 specification:**
- See: Component 2 problem statement (original requirements)
- See: COMPONENT2_README.md for feature documentation
- See: IMPLEMENTATION_SUMMARY.md for technical details
