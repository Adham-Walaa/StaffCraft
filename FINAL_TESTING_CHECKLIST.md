# ✅ Component 2: Final Testing Checklist

## 🚀 Before You Start Testing

### Step 1: Fix Manager Role Registration (REQUIRED)
**If you get "Invalid role" error when registering Manager:**

1. Open **`FIX_MANAGER_ROLE_NOW.sql`**
2. Change line 9: `USE [Your_Database_Name_Here];` to your actual database name
3. Open SQL Server Management Studio (SSMS)
4. Paste the entire script
5. Press F5 to execute
6. Look for "SUCCESS" messages
7. ✅ Manager registration should work now

**Detailed instructions:** See `URGENT_READ_THIS_FIRST.md`

### Step 2: Pull Latest Changes
```bash
git fetch origin
git pull origin copilot/implement-attendance-shift-management
```

### Step 3: Build and Run
```bash
cd MS3WebApp/WebAppSystem/WebAppSystem
dotnet restore
dotnet build
dotnet run
```

---

## 📋 Testing by Role

### 🔴 System Administrator Testing

**Test Case 1A: Create Shift Type**
- [ ] Navigate to: Shifts → Create Shift Type
- [ ] Fill: Name="Morning", Type="Normal", Start=09:00, End=17:00
- [ ] Click "Create"
- [ ] ✅ See success message and redirected to list

**Test Case 1B: Assign Shift to Employee**
- [ ] Navigate to: Shifts → Assign to Employee
- [ ] Select an employee
- [ ] Select a shift template (the one you just created)
- [ ] Set dates: Today to 1 month from today
- [ ] Click "Assign Shift"
- [ ] ✅ See success message

**Test Case 1C: Assign Shift to Department**
- [ ] Navigate to: Shifts → Assign to Department
- [ ] Select a department (must have employees!)
- [ ] Select a shift template
- [ ] Set dates
- [ ] Click "Assign to Department"
- [ ] ✅ See "Shift assigned to X employees" message

**Test Case 1D: Sync Leaves**
- [ ] Navigate to: Attendance → Sync Leaves
- [ ] Set date range
- [ ] Click "Sync Leaves"
- [ ] ✅ See sync count message

**Test Case 1E: Edit Shift**
- [ ] Navigate to: Shifts → All Shift Schedules
- [ ] Click "Edit" on any shift
- [ ] Use dropdowns to change Status, Type, Times
- [ ] Click "Save"
- [ ] ✅ Changes saved successfully

### 🟠 HR Administrator Testing

**Test Case 2A: Create Split Shift**
- [ ] Navigate to: Shifts → Split Shifts
- [ ] Click "Create New Split Shift"
- [ ] Fill: Name, First Slot (08:00-12:00), Second Slot (16:00-20:00), Break=60
- [ ] Check "Active"
- [ ] Click "Create"
- [ ] ✅ See success, total hours calculated (8.0)

**Test Case 2B: Create Rotational Shift**
- [ ] Navigate to: Shifts → Rotational Shifts
- [ ] Click "Create New Rotational Shift"
- [ ] Fill: Name="3-Day Rotation", Description
- [ ] Click "Create"
- [ ] ✅ See success message

**Test Case 2C: Approve Correction Request**
- [ ] Navigate to: Attendance → All Correction Requests
- [ ] Find a Pending request
- [ ] Click green "Approve" button
- [ ] ✅ Status changes to Approved

**Test Case 2D: Reject Correction Request**
- [ ] Find another Pending request
- [ ] Click red "Reject" button
- [ ] ✅ Status changes to Rejected

### 🟢 Manager Testing

**See MANAGER_ROLE_COMPLETE_TESTING_GUIDE.md for detailed steps**

**Quick Checklist:**
- [ ] M1: Assign shift to employee ✅
- [ ] M2: Assign shift to department ✅
- [ ] M3: Edit shift schedule ✅
- [ ] M4: View team attendance ✅
- [ ] M5: Approve correction request ✅
- [ ] M6: Reject correction request ✅
- [ ] M7: View all shifts (read-only) ✅
- [ ] M8: Access denied for restricted actions ✅

### 🔵 Employee Testing

**Test Case 4A: Record Attendance**
- [ ] Navigate to: Attendance → Record Attendance
- [ ] Set Entry Time: 09:15
- [ ] Set Exit Time: 17:30
- [ ] Select Login Method: "Web Portal"
- [ ] Select Logout Method: "Web Portal"
- [ ] Click "Record Attendance"
- [ ] ✅ See success, duration calculated

**Test Case 4B: View My Attendance**
- [ ] Navigate to: Attendance → My Attendance
- [ ] ✅ See table with your attendance records

**Test Case 4C: Submit Correction Request**
- [ ] Navigate to: Attendance → Submit Correction
- [ ] Select date (yesterday)
- [ ] Select type: "Missing Entry Time"
- [ ] Enter reason
- [ ] Click "Submit Request"
- [ ] ✅ See success, status=Pending

**Test Case 4D: View My Requests**
- [ ] Navigate to: Attendance → My Correction Requests
- [ ] ✅ See your requests with colored badges

---

## 🔒 Permission Testing

### Things Employees CANNOT Do (Should See Access Denied Page)
- [ ] Try: Shifts → Create Shift Type ❌
- [ ] Try: Shifts → Split Shifts ❌
- [ ] Try: Shifts → Edit any shift ❌
- [ ] Try: Attendance → Sync Leaves ❌
- [ ] ✅ All show friendly "Access Denied" page (not exception)

### Things HR Admin CANNOT Do
- [ ] Try: Shifts → Edit shift schedule ❌
- [ ] Try: Shifts → Delete shift ❌
- [ ] ✅ Shows "Access Denied" page

### Things Manager CAN Do
- [ ] Shifts → Assign to Employee ✅
- [ ] Shifts → Assign to Department ✅
- [ ] Shifts → Edit shift ✅
- [ ] Attendance → Team Attendance ✅
- [ ] Attendance → Approve/Reject corrections ✅

---

## 🎯 Success Criteria

### Navigation Menu
- [ ] "Attendance" dropdown visible with role-appropriate items
- [ ] "Shifts" dropdown visible with role-appropriate items
- [ ] Items hidden for unauthorized roles

### Data Validation
- [ ] Form validation shows clear error messages
- [ ] Success messages appear after operations
- [ ] Dropdowns work correctly (no manual typing needed)
- [ ] Time pickers work for entry/exit times
- [ ] Dates can be selected with date picker

### Role-Based Access
- [ ] Each role can only access authorized features
- [ ] Unauthorized access shows friendly error page
- [ ] No ugly exception stack traces
- [ ] "Go Back" and "Go Home" buttons work

### Database Operations
- [ ] Records save successfully
- [ ] IDs generate correctly (no more exceptions)
- [ ] Bulk operations work (assign to department)
- [ ] Offline sync processes queued records

---

## 🐛 Known Issues (Pre-Existing)

These are **NOT** Component 2 issues:
- 57 compiler warnings (existed before Component 2)
- Plain text passwords (existing system design)
- Some database tables may be empty (need test data)

---

## 📚 Documentation Reference

**For Detailed Testing:**
- `MANAGER_ROLE_COMPLETE_TESTING_GUIDE.md` - 8 detailed test cases for Manager
- `COMPONENT2_README.md` - Feature descriptions and API reference

**For Setup Issues:**
- `URGENT_READ_THIS_FIRST.md` - Fix Manager registration error
- `MANAGER_ROLE_SETUP_GUIDE.md` - Technical setup guide
- `VERIFICATION_GUIDE.md` - Verify fixes are present

**For Technical Details:**
- `IMPLEMENTATION_SUMMARY.md` - Architecture and file changes
- `Procedures.sql` - Updated stored procedures (line 2025)
- `COMPONENT2_DATABASE_SETUP.sql` - Database configuration

---

## ✅ Final Verification

After testing all roles:
- [ ] All System Admin features work
- [ ] All HR Admin features work
- [ ] All Manager features work
- [ ] All Employee features work
- [ ] Permission checks work correctly
- [ ] UI is consistent and user-friendly
- [ ] No unexpected exceptions or crashes
- [ ] Success/error messages display properly

**If all checked:** Component 2 is complete! 🎉

---

## 🆘 Need Help?

**Manager Registration Error:**
→ Run `FIX_MANAGER_ROLE_NOW.sql` in SSMS

**Template Selection Error:**
→ Already fixed in commit 2443294, pull latest

**Exception Pages:**
→ Already fixed in commit acc0158, pull latest

**Other Issues:**
→ Check documentation files listed above
