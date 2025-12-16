# Component 2 - Verification Guide

This guide helps you verify that all fixes are present in your local copy.

## ⚠️ IMPORTANT: Pull Latest Changes First

If you're not seeing the changes, you need to pull the latest code:

### Option 1: Visual Studio
1. Go to **View** → **Git Changes**
2. Click **Fetch** button
3. Click **Pull** button
4. Wait for files to sync

### Option 2: Command Line
```bash
git fetch origin
git pull origin copilot/implement-attendance-shift-management
```

---

## ✅ Verification Checklist

### 1. Line Manager Role in Registration

**File to Check:** `MS3WebApp/WebAppSystem/WebAppSystem/Controllers/AccountController.cs`

**What to Look For:** Search for "GetRolesSelectList" method (around line 351)

**Should contain:**
```csharp
new { Value = "Line Manager", Text = "Line Manager" },
new { Value = "Manager", Text = "Manager" },
```

**How to Verify:**
1. Open the Register page
2. Look at the Role dropdown
3. Should show both "Line Manager" AND "Manager"

---

### 2. AssignToDepartment Confirmation Message

**File to Check:** `MS3WebApp/WebAppSystem/WebAppSystem/Controllers/ShiftSchedulesController.cs`

**What to Look For:** Search for "AssignToDepartment" POST method (around line 431)

**Should contain:**
```csharp
TempData["SuccessMessage"] = $"Shift assigned to {assignedCount} employees in the department successfully!";
return RedirectToAction(nameof(Index));
```

**File to Check:** `MS3WebApp/WebAppSystem/WebAppSystem/Views/ShiftSchedules/Index.cshtml`

**What to Look For:** Lines 9-15 at the top

**Should contain:**
```cshtml
@if (TempData["SuccessMessage"] != null)
{
    <div class="alert alert-success alert-dismissible fade show" role="alert">
        @TempData["SuccessMessage"]
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
    </div>
}
```

**How to Verify:**
1. Login as System Admin
2. Go to Shifts → Assign to Department
3. Select a department with employees
4. Select a shift template
5. Click "Assign to Department"
6. Should redirect to Index page with GREEN success message at top

---

### 3. Friendly Access Denied Page (No Exception Pages)

**File to Check:** `MS3WebApp/WebAppSystem/WebAppSystem/Views/Shared/AccessDenied.cshtml`

**File Should Exist:** This is a NEW file created in commit acc0158

**Should contain:**
```cshtml
<h4 class="alert-heading"><i class="bi bi-exclamation-triangle-fill"></i> Access Denied</h4>
<p>@ViewBag.Message</p>
<hr>
<p class="mb-0">@ViewBag.AllowedRoles</p>
```

**Controllers Updated:** All Component 2 controllers now use:
```csharp
ViewBag.Message = "You do not have permission to perform this action.";
ViewBag.AllowedRoles = "This action can only be performed by: [roles]";
return View("~/Views/Shared/AccessDenied.cshtml");
```

**How to Verify:**
1. Login as Employee
2. Try to go to Shifts → Create Shift Type (System Admin only)
3. Should see professional error page saying "Access Denied" with role info
4. Should NOT see ugly exception with stack traces

---

### 4. Split Shift Checkbox Fixed

**File to Check:** `MS3WebApp/WebAppSystem/WebAppSystem/Views/SplitShifts/Create.cshtml`

**What to Look For:** Search for "IsActive" (around line 49)

**Should contain:**
```cshtml
<input type="checkbox" id="IsActive" name="IsActive" value="true" checked />
```

**Should NOT contain:**
```cshtml
<input asp-for="IsActive" class="form-check-input" />
```

**How to Verify:**
1. Login as HR Administrator
2. Go to Shifts → Split Shifts → Create New Split Shift
3. Page should load WITHOUT any exception
4. Should NOT see: `System.InvalidOperationException: 'Unexpected 'asp-for' expression result type`

---

## 🔍 Common Issues

### Issue: "I don't see Line Manager in dropdown"
**Solution:** 
- Pull latest code (git pull)
- Check AccountController.cs GetRolesSelectList method
- Restart the application (dotnet run)
- Clear browser cache (Ctrl+F5)

### Issue: "No confirmation message for AssignToDepartment"
**Solution:**
- Check that you're selecting BOTH department and shift template
- Check that the department has employees (not empty)
- Look at top of Shift Schedules page after clicking button
- Check browser console for JavaScript errors

### Issue: "Still seeing exception pages"
**Solution:**
- Pull latest code (commit acc0158 must be present)
- Check that AccessDenied.cshtml exists in Views/Shared/
- Restart application
- Try action that should be denied

### Issue: "Split Shift create still shows exception"
**Solution:**
- Pull latest code
- Check SplitShifts/Create.cshtml line 49 for plain HTML checkbox
- NOT asp-for checkbox
- Restart application

---

## 📊 Build Verification

Run from project directory:
```bash
cd MS3WebApp/WebAppSystem/WebAppSystem
dotnet build
```

**Expected Output:**
- 0 Errors
- 57 Warnings (all pre-existing, none from Component 2)
- Build succeeded

---

## 📝 Latest Commit Info

**Commit Hash:** acc0158
**Commit Message:** "Fix SplitShift checkbox error, improve AssignToDepartment validation, add friendly access denied messages, restore Line Manager role, and add Manager role testing guide"

**Files Changed in acc0158:**
1. AccountController.cs - Line Manager added to GetRolesSelectList
2. ShiftSchedulesController.cs - AssignToDepartment uses AccessDenied view
3. AttendancesController.cs - All auth failures use AccessDenied view
4. SplitShiftsController.cs - Checkbox fix + AccessDenied view
5. RotationalShiftsController.cs - AccessDenied view
6. AttendanceCorrectionRequestsController.cs - AccessDenied view
7. SplitShifts/Create.cshtml - Plain HTML checkbox for IsActive
8. ShiftSchedules/AssignToDepartment.cshtml - Validation error display
9. Shared/AccessDenied.cshtml - NEW professional error page
10. MANAGER_ROLE_TESTING_GUIDE.md - NEW testing documentation

---

## 🎯 Quick Test

To quickly verify all fixes:

1. **Pull code** → `git pull origin copilot/implement-attendance-shift-management`
2. **Build** → `dotnet build` (should succeed)
3. **Run** → `dotnet run`
4. **Test Registration** → Should see both Line Manager and Manager in dropdown
5. **Test Access Denied** → Login as Employee, try to create shift type, should see friendly error
6. **Test AssignToDepartment** → Login as System Admin, assign to department, should see success message
7. **Test Split Shift** → Login as HR Admin, create split shift, page should load without exception

If any of these fail, the code was not pulled successfully. Try `git fetch` then `git pull` again.
