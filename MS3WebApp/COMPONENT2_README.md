# Component 2: Attendance and Shift Management System

## Overview
Component 2 implements a comprehensive attendance tracking and shift management system for the HR Management application. This component enables efficient workforce scheduling, attendance recording, and compliance with time rules.

## Features Implemented

### Shift Management

#### 1. Shift Type Creation (System Admin)
**Path:** `ShiftSchedules/CreateShiftType`

- System administrators can create predefined shift types (Normal, Rotational, Custom, Special, Night, Split)
- Each shift type includes:
  - Shift name
  - Shift type category
  - Start and end times
  - Description
- Created shift types serve as templates for assignment

**Controller:** `ShiftSchedulesController.CreateShiftType()`
**View:** `Views/ShiftSchedules/CreateShiftType.cshtml`

#### 2. Split Shift Configuration (HR Admin)
**Path:** `SplitShifts/Index`, `SplitShifts/Create`

- HR administrators can configure split shifts with two time slots
- Features:
  - First slot start/end time
  - Second slot start/end time
  - Break duration between slots
  - Automatic total hours calculation
  - Active/Inactive status

**Controller:** `SplitShiftsController`
**Views:** `Views/SplitShifts/Index.cshtml`, `Views/SplitShifts/Create.cshtml`

#### 3. Rotational Shift Configuration (HR Admin)
**Path:** `RotationalShifts/Index`, `RotationalShifts/Create`

- HR administrators can define rotational shift cycles
- Features:
  - Cycle name (e.g., "3-Day Rotation", "Weekly Rotation")
  - Description of rotation pattern
  - Cycle management (create, edit, delete)

**Controller:** `RotationalShiftsController`
**Views:** `Views/RotationalShifts/Index.cshtml`, `Views/RotationalShifts/Create.cshtml`

#### 4. Shift Assignment to Employees
**Path:** `ShiftSchedules/AssignToEmployee`

- System Admins and Line Managers can assign shifts to individual employees
- Features:
  - Select employee from dropdown
  - Choose from shift templates or create custom shift
  - Set start and end dates for assignment
  - Specify shift name, type, and times

**Controller:** `ShiftSchedulesController.AssignToEmployee()`
**View:** `Views/ShiftSchedules/AssignToEmployee.cshtml`

#### 5. Shift Assignment to Departments
**Path:** `ShiftSchedules/AssignToDepartment`

- System Admins and Line Managers can assign shifts to entire departments
- Features:
  - Select department
  - Choose shift template
  - Bulk assignment to all department employees
  - Set start and end dates

**Controller:** `ShiftSchedulesController.AssignToDepartment()`
**View:** `Views/ShiftSchedules/AssignToDepartment.cshtml`

#### 6. Shift Assignment Updates
**Path:** `ShiftSchedules/UpdateShiftAssignment`

- System Admins can update existing shift assignments
- Features:
  - Modify shift details (name, type, times)
  - Update assignment dates
  - Change shift status (Active, Inactive, Expired)

**Controller:** `ShiftSchedulesController.UpdateShiftAssignment()`
**View:** `Views/ShiftSchedules/UpdateShiftAssignment.cshtml`

### Attendance Tracking

#### 1. Employee Attendance Viewing
**Path:** `Attendances/MyAttendance`

- Employees can view their own attendance records
- Features:
  - Chronological list of attendance entries
  - Entry/exit times, duration, and methods
  - Exception information
  - Quick actions (record, sync, submit correction)

**Controller:** `AttendancesController.MyAttendance()`
**View:** `Views/Attendances/MyAttendance.cshtml`

#### 2. Daily Attendance Recording
**Path:** `Attendances/RecordAttendance`

- Employees can manually record their attendance
- Features:
  - Entry time selection
  - Exit time selection
  - Login/logout method (Web Portal, Mobile App, Biometric, Manual)
  - Automatic duration calculation
  - Session-based employee identification

**Controller:** `AttendancesController.RecordAttendance()`
**View:** `Views/Attendances/RecordAttendance.cshtml`

#### 3. Attendance Correction Requests
**Paths:** 
- `AttendanceCorrectionRequests/MyRequests` (Employee view)
- `AttendanceCorrectionRequests/SubmitRequest` (Submit)
- `AttendanceCorrectionRequests/Approve` (Manager/HR)
- `AttendanceCorrectionRequests/Reject` (Manager/HR)

**Employee Features:**
- View all submitted correction requests with status
- Submit new correction requests with:
  - Date of correction
  - Correction type (Missing Entry/Exit, Wrong Time, Forgot to Clock In/Out, Other)
  - Detailed reason
  - Automatic status tracking (Pending, Approved, Rejected)

**Manager/HR Features:**
- View all pending correction requests
- Approve or reject requests
- Automatic tracking of approver

**Controllers:** `AttendanceCorrectionRequestsController.MyRequests()`, `SubmitRequest()`, `Approve()`, `Reject()`
**Views:** `Views/AttendanceCorrectionRequests/MyRequests.cshtml`, `SubmitRequest.cshtml`, `Approve.cshtml`, `Reject.cshtml`

#### 4. Leave Synchronization with Attendance
**Path:** `Attendances/SyncLeaves` (System Admin only)

- System Admins can sync approved leave requests with the attendance system
- Features:
  - Date range selection for sync
  - Automatic creation of attendance records for approved leaves
  - Leave exception marking
  - Bulk synchronization support
  - Prevents duplicate attendance records

**Service:** `LeaveSyncService`
- `SyncApprovedLeaves()` - Syncs multiple leaves within date range
- `SyncLeaveRequest()` - Syncs individual leave request

**Controller:** `AttendancesController.SyncLeaves()`
**View:** `Views/Attendances/SyncLeaves.cshtml`

#### 5. Offline Attendance Synchronization
**Path:** `Attendances/SyncOfflineAttendance`

- Automatically syncs offline attendance logs when employee reconnects
- Features:
  - Retrieves pending offline records from queue
  - Creates or updates attendance records
  - Handles clock IN/OUT from offline devices
  - Automatic duration calculation
  - Error handling with detailed messages
  - Status tracking (Pending, Synced, Failed)

**Controller:** `AttendancesController.SyncOfflineAttendance()`

#### 6. Attendance Time Rules and Grace Periods
**Service:** `AttendanceRulesService`

Implements business rules for attendance:

**Grace Period (Default: 15 minutes)**
- Employees arriving within 15 minutes of shift start are not marked late
- Applies to both entry and exit times

**Lateness Detection:**
- `IsLate()` - Checks if entry time exceeds grace period
- `CalculateLateMinutes()` - Calculates actual late minutes after grace period

**Short-Time Penalties (Default: 30 minutes)**
- Applied when duration is less than expected (< 8 hours)
- Automatic deduction from work duration

**Early Departure Detection:**
- `IsEarlyDeparture()` - Checks if exit is before shift end (minus grace period)
- `CalculateEarlyDepartureMinutes()` - Calculates early departure time

**Time Rules Application:**
- `ApplyTimeRules()` - Applies all rules to attendance record
- Integrates with shift schedule information

#### 7. Manager Team Attendance Summary
**Path:** `Attendances/TeamAttendance`

- Line Managers can view attendance summary for their team
- Features:
  - Summary by employee (status overview)
  - Detailed attendance records for all team members
  - Employee profile links
  - Automatic team member identification based on manager relationship

**Controller:** `AttendancesController.TeamAttendance()`
**View:** `Views/Attendances/TeamAttendance.cshtml`

## Navigation Menu

The navigation menu has been updated to include new Attendance and Shifts dropdowns:

### Attendance Menu
- **For All Employees:**
  - My Attendance
  - Record Attendance
  - My Correction Requests
  - Submit Correction

- **For Line Managers (additional):**
  - Team Attendance

- **For System Admin / HR Admin (additional):**
  - All Attendance Records
  - All Correction Requests

- **For System Admin only:**
  - Sync Leaves

### Shifts Menu
- **For System Admins:**
  - Create Shift Type
  - Assign to Employee
  - Assign to Department

- **For Line Managers:**
  - Assign to Employee
  - Assign to Department

- **For All Users:**
  - All Shift Schedules

- **For HR Admins:**
  - Split Shifts
  - Rotational Shifts

## Data Models

### View Models
- `AttendanceSummaryViewModel` - Used for team attendance summaries
- `ShiftAssignmentViewModel` - Used for shift assignment operations
- `ShiftTypeViewModel` - Used for shift type creation
- `AttendanceRule` - Model for attendance rule configuration

### Services
- `AttendanceRulesService` - Business logic for time rules, grace periods, and penalties
- `LeaveSyncService` - Synchronizes approved leaves with attendance system

## Database Integration

The component leverages existing database tables:
- `Attendance` - Stores attendance records
- `AttendanceCorrectionRequest` - Stores correction requests
- `ShiftSchedule` - Stores shift assignments
- `ShiftCycle` - Stores rotational shift cycles
- `SplitShiftConfiguration` - Stores split shift configurations
- `OfflineAttendanceQueue` - Queues offline attendance logs
- `Exception` - Stores attendance exceptions (including leave)

## Role-Based Access Control

### System Administrator
- Create shift types
- Assign shifts to employees and departments
- Update shift assignments
- Sync leaves with attendance
- View all attendance and correction requests

### HR Administrator
- Configure split shifts
- Configure rotational shifts
- View all attendance and correction requests
- Approve/reject correction requests

### Line Manager
- Assign shifts to employees and departments
- View team attendance
- Approve/reject correction requests

### Employee
- View own attendance
- Record attendance
- Submit correction requests
- Sync offline attendance

## Build and Deployment

The application builds successfully with no errors:
```bash
cd MS3WebApp/WebAppSystem/WebAppSystem
dotnet restore
dotnet build
```

## Testing Recommendations

1. **Shift Management:**
   - Create various shift types
   - Test shift assignment to individual employees
   - Test bulk assignment to departments
   - Verify rotational and split shift configurations

2. **Attendance Recording:**
   - Test manual attendance entry
   - Verify duration calculation
   - Test with different login methods

3. **Correction Requests:**
   - Submit correction requests as employee
   - Approve/reject as manager
   - Verify status updates

4. **Leave Sync:**
   - Create approved leave requests
   - Run leave sync for date range
   - Verify attendance records created with leave exception

5. **Offline Sync:**
   - Create offline attendance queue records
   - Test sync functionality
   - Verify attendance record creation/update

6. **Time Rules:**
   - Test grace period application
   - Verify late detection
   - Test short-time penalty
   - Verify early departure detection

7. **Manager Views:**
   - As manager, view team attendance
   - Verify team member filtering
   - Test correction request approval workflow

## Future Enhancements

1. **Real-time Attendance Dashboard:**
   - Live attendance status for all employees
   - Heat map view of attendance patterns

2. **Automated Shift Rotation:**
   - Automatic application of rotational shift cycles
   - Shift swap requests between employees

3. **Mobile App Integration:**
   - Native mobile app for attendance recording
   - Push notifications for shift assignments

4. **Advanced Analytics:**
   - Attendance trends and insights
   - Predictive analytics for staffing needs

5. **Biometric Integration:**
   - Direct integration with biometric devices
   - Face recognition support

6. **Geofencing:**
   - Location-based attendance recording
   - Verify employees are on-site

## Security Considerations

1. **Role-Based Authorization:**
   - All endpoints check user roles before allowing access
   - Session-based authentication required

2. **Data Validation:**
   - Input validation on all forms
   - CSRF token protection on POST requests

3. **Audit Trail:**
   - Correction requests track approver
   - Leave sync creates traceable attendance records

4. **Error Handling:**
   - Graceful error handling with user-friendly messages
   - Detailed error logging for debugging

## Support

For questions or issues with Component 2 features, please refer to:
- Main README.md for general application information
- QUICKSTART.md for setup instructions
- SECURITY_NOTES.md for security guidelines
