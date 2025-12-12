using System;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using WebAppSystem.Models;
using SystemException = System.Exception;

namespace WebAppSystem.Services
{
    public class LeaveSyncService
    {
        private readonly Milestone2Context _context;

        public LeaveSyncService(Milestone2Context context)
        {
            _context = context;
        }

        // Sync approved leave requests with attendance system
        public async Task<int> SyncApprovedLeaves(DateTime startDate, DateTime endDate)
        {
            // Get all approved leave requests within the date range
            var approvedLeaves = await _context.LeaveRequests
                .Include(lr => lr.Employee)
                .Include(lr => lr.Leave)
                .Where(lr => lr.Status == "Approved" &&
                            lr.ApprovalTiming >= startDate &&
                            lr.ApprovalTiming <= endDate)
                .ToListAsync();

            int syncedCount = 0;

            foreach (var leaveRequest in approvedLeaves)
            {
                if (leaveRequest.EmployeeId.HasValue && leaveRequest.ApprovalTiming.HasValue)
                {
                    // Check if attendance already exists for this date
                    var existingAttendance = await _context.Attendances
                        .FirstOrDefaultAsync(a => a.EmployeeId == leaveRequest.EmployeeId);

                    if (existingAttendance == null)
                    {
                        // Create attendance record with leave exception
                        var leaveException = await _context.Exceptions
                            .FirstOrDefaultAsync(e => e.Category == "Leave" || e.Name == "On Leave");

                        if (leaveException == null)
                        {
                            // Generate new ExceptionId
                            var maxExceptionId = await _context.Exceptions.MaxAsync(e => (int?)e.ExceptionId) ?? 0;
                            
                            // Create leave exception if it doesn't exist
                            leaveException = new Models.Exception
                            {
                                ExceptionId = maxExceptionId + 1,
                                Name = "On Leave",
                                Category = "Leave",
                                Status = "Active",
                                Date = leaveRequest.ApprovalTiming
                            };
                            _context.Exceptions.Add(leaveException);
                            await _context.SaveChangesAsync();
                        }

                        // Generate new AttendanceId
                        var maxAttendanceId = await _context.Attendances.MaxAsync(a => (int?)a.AttendanceId) ?? 0;
                        
                        var attendance = new Attendance
                        {
                            AttendanceId = maxAttendanceId + syncedCount + 1,
                            EmployeeId = leaveRequest.EmployeeId.Value,
                            EntryTime = null,
                            ExitTime = null,
                            Duration = 0,
                            LoginMethod = "Leave Sync",
                            LogoutMethod = "Leave Sync",
                            ExceptionId = leaveException.ExceptionId
                        };

                        _context.Attendances.Add(attendance);
                        syncedCount++;
                    }
                }
            }

            await _context.SaveChangesAsync();
            return syncedCount;
        }

        // Sync individual leave request
        public async Task<bool> SyncLeaveRequest(int leaveRequestId)
        {
            var leaveRequest = await _context.LeaveRequests
                .Include(lr => lr.Employee)
                .FirstOrDefaultAsync(lr => lr.RequestId == leaveRequestId && lr.Status == "Approved");

            if (leaveRequest == null || !leaveRequest.EmployeeId.HasValue || !leaveRequest.ApprovalTiming.HasValue)
                return false;

            // Get or create leave exception
            var leaveException = await _context.Exceptions
                .FirstOrDefaultAsync(e => e.Category == "Leave");

            if (leaveException == null)
            {
                // Generate new ExceptionId
                var maxExceptionId = await _context.Exceptions.MaxAsync(e => (int?)e.ExceptionId) ?? 0;
                
                leaveException = new Models.Exception
                {
                    ExceptionId = maxExceptionId + 1,
                    Name = "On Leave",
                    Category = "Leave",
                    Status = "Active",
                    Date = leaveRequest.ApprovalTiming
                };
                _context.Exceptions.Add(leaveException);
                await _context.SaveChangesAsync();
            }

            // Generate new AttendanceId
            var maxAttendanceId = await _context.Attendances.MaxAsync(a => (int?)a.AttendanceId) ?? 0;
            
            // Create attendance record
            var attendance = new Attendance
            {
                AttendanceId = maxAttendanceId + 1,
                EmployeeId = leaveRequest.EmployeeId.Value,
                EntryTime = null,
                ExitTime = null,
                Duration = 0,
                LoginMethod = "Leave Sync",
                LogoutMethod = "Leave Sync",
                ExceptionId = leaveException.ExceptionId
            };

            _context.Attendances.Add(attendance);
            await _context.SaveChangesAsync();

            return true;
        }
    }
}
