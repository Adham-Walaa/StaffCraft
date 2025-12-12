using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;
using Microsoft.EntityFrameworkCore;
using WebAppSystem.Models;

namespace WebAppSystem.Controllers
{
    public class AttendancesController : Controller
    {
        private readonly Milestone2Context _context;

        public AttendancesController(Milestone2Context context)
        {
            _context = context;
        }

        // GET: Attendances
        public async Task<IActionResult> Index()
        {
            var milestone2Context = _context.Attendances.Include(a => a.Employee).Include(a => a.Exception);
            return View(await milestone2Context.ToListAsync());
        }

        // GET: Attendances/Details/5
        public async Task<IActionResult> Details(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var attendance = await _context.Attendances
                .Include(a => a.Employee)
                .Include(a => a.Exception)
                .FirstOrDefaultAsync(m => m.AttendanceId == id);
            if (attendance == null)
            {
                return NotFound();
            }

            return View(attendance);
        }

        // GET: Attendances/Create
        public IActionResult Create()
        {
            ViewData["EmployeeId"] = new SelectList(_context.Employees, "EmployeeId", "EmployeeId");
            ViewData["ExceptionId"] = new SelectList(_context.Exceptions, "ExceptionId", "ExceptionId");
            return View();
        }

        // POST: Attendances/Create
        // To protect from overposting attacks, enable the specific properties you want to bind to.
        // For more details, see http://go.microsoft.com/fwlink/?LinkId=317598.
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Create([Bind("AttendanceId,EmployeeId,EntryTime,ExitTime,Duration,LoginMethod,LogoutMethod,ExceptionId")] Attendance attendance)
        {
            if (ModelState.IsValid)
            {
                _context.Add(attendance);
                await _context.SaveChangesAsync();
                return RedirectToAction(nameof(Index));
            }
            ViewData["EmployeeId"] = new SelectList(_context.Employees, "EmployeeId", "EmployeeId", attendance.EmployeeId);
            ViewData["ExceptionId"] = new SelectList(_context.Exceptions, "ExceptionId", "ExceptionId", attendance.ExceptionId);
            return View(attendance);
        }

        // GET: Attendances/Edit/5
        public async Task<IActionResult> Edit(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var attendance = await _context.Attendances.FindAsync(id);
            if (attendance == null)
            {
                return NotFound();
            }
            ViewData["EmployeeId"] = new SelectList(_context.Employees, "EmployeeId", "EmployeeId", attendance.EmployeeId);
            ViewData["ExceptionId"] = new SelectList(_context.Exceptions, "ExceptionId", "ExceptionId", attendance.ExceptionId);
            return View(attendance);
        }

        // POST: Attendances/Edit/5
        // To protect from overposting attacks, enable the specific properties you want to bind to.
        // For more details, see http://go.microsoft.com/fwlink/?LinkId=317598.
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Edit(int id, [Bind("AttendanceId,EmployeeId,EntryTime,ExitTime,Duration,LoginMethod,LogoutMethod,ExceptionId")] Attendance attendance)
        {
            if (id != attendance.AttendanceId)
            {
                return NotFound();
            }

            if (ModelState.IsValid)
            {
                try
                {
                    _context.Update(attendance);
                    await _context.SaveChangesAsync();
                }
                catch (DbUpdateConcurrencyException)
                {
                    if (!AttendanceExists(attendance.AttendanceId))
                    {
                        return NotFound();
                    }
                    else
                    {
                        throw;
                    }
                }
                return RedirectToAction(nameof(Index));
            }
            ViewData["EmployeeId"] = new SelectList(_context.Employees, "EmployeeId", "EmployeeId", attendance.EmployeeId);
            ViewData["ExceptionId"] = new SelectList(_context.Exceptions, "ExceptionId", "ExceptionId", attendance.ExceptionId);
            return View(attendance);
        }

        // GET: Attendances/Delete/5
        public async Task<IActionResult> Delete(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var attendance = await _context.Attendances
                .Include(a => a.Employee)
                .Include(a => a.Exception)
                .FirstOrDefaultAsync(m => m.AttendanceId == id);
            if (attendance == null)
            {
                return NotFound();
            }

            return View(attendance);
        }

        // POST: Attendances/Delete/5
        [HttpPost, ActionName("Delete")]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> DeleteConfirmed(int id)
        {
            var attendance = await _context.Attendances.FindAsync(id);
            if (attendance != null)
            {
                _context.Attendances.Remove(attendance);
            }

            await _context.SaveChangesAsync();
            return RedirectToAction(nameof(Index));
        }

        private bool AttendanceExists(int id)
        {
            return _context.Attendances.Any(e => e.AttendanceId == id);
        }

        // GET: Attendances/MyAttendance
        // Employee view their own attendance
        public async Task<IActionResult> MyAttendance()
        {
            var userId = HttpContext.Session.GetInt32("UserId");
            if (userId == null)
            {
                return RedirectToAction("Login", "Account");
            }

            var attendances = await _context.Attendances
                .Include(a => a.Employee)
                .Include(a => a.Exception)
                .Where(a => a.EmployeeId == userId)
                .OrderByDescending(a => a.AttendanceId)
                .ToListAsync();

            return View(attendances);
        }

        // GET: Attendances/RecordAttendance
        // Employee records their attendance
        public IActionResult RecordAttendance()
        {
            var userId = HttpContext.Session.GetInt32("UserId");
            if (userId == null)
            {
                return RedirectToAction("Login", "Account");
            }

            ViewData["EmployeeId"] = userId;
            return View();
        }

        // POST: Attendances/RecordAttendance
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> RecordAttendance([Bind("EntryTime,ExitTime,LoginMethod,LogoutMethod")] Attendance attendance)
        {
            var userId = HttpContext.Session.GetInt32("UserId");
            if (userId == null)
            {
                return RedirectToAction("Login", "Account");
            }

            attendance.EmployeeId = userId.Value;
            
            // Calculate duration if both entry and exit times are provided
            if (attendance.EntryTime.HasValue && attendance.ExitTime.HasValue)
            {
                var entryMinutes = attendance.EntryTime.Value.Hour * 60 + attendance.EntryTime.Value.Minute;
                var exitMinutes = attendance.ExitTime.Value.Hour * 60 + attendance.ExitTime.Value.Minute;
                attendance.Duration = exitMinutes - entryMinutes;
            }

            // Generate new AttendanceId
            var maxAttendanceId = await _context.Attendances.MaxAsync(a => (int?)a.AttendanceId) ?? 0;
            attendance.AttendanceId = maxAttendanceId + 1;

            ModelState.Clear();
            if (TryValidateModel(attendance))
            {
                _context.Add(attendance);
                await _context.SaveChangesAsync();
                TempData["SuccessMessage"] = "Attendance recorded successfully!";
                return RedirectToAction(nameof(MyAttendance));
            }

            ViewData["EmployeeId"] = userId;
            return View(attendance);
        }

        // GET: Attendances/TeamAttendance
        // Manager views team attendance
        public async Task<IActionResult> TeamAttendance()
        {
            var userId = HttpContext.Session.GetInt32("UserId");
            if (userId == null)
            {
                return RedirectToAction("Login", "Account");
            }

            // Get employees who report to this manager
            var teamMembers = await _context.Employees
                .Where(e => e.ManagerId == userId)
                .Select(e => e.EmployeeId)
                .ToListAsync();

            var attendances = await _context.Attendances
                .Include(a => a.Employee)
                .Include(a => a.Exception)
                .Where(a => teamMembers.Contains(a.EmployeeId.Value))
                .OrderByDescending(a => a.AttendanceId)
                .ToListAsync();

            // Group by employee for summary
            var summary = attendances
                .GroupBy(a => a.Employee)
                .Select(g => new AttendanceSummaryViewModel
                {
                    EmployeeId = g.Key.EmployeeId,
                    EmployeeName = g.Key.FullName,
                    Date = DateTime.Now,
                    Status = "Present"
                })
                .ToList();

            ViewData["TeamAttendances"] = attendances;
            return View(summary);
        }

        // GET: Attendances/SyncLeaves
        // System Admin syncs approved leaves with attendance
        public IActionResult SyncLeaves()
        {
            var userRoles = HttpContext.Session.GetString("UserRoles");
            if (string.IsNullOrEmpty(userRoles) || !userRoles.Contains("System Administrator"))
            {
                ViewBag.Message = "You do not have permission to perform this action.";
                ViewBag.AllowedRoles = "This action can only be performed by: System Administrator";
                return View("~/Views/Shared/AccessDenied.cshtml");
            }

            return View();
        }

        // POST: Attendances/SyncLeaves
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> SyncLeaves(DateTime startDate, DateTime endDate)
        {
            var userRoles = HttpContext.Session.GetString("UserRoles");
            if (string.IsNullOrEmpty(userRoles) || !userRoles.Contains("System Administrator"))
            {
                ViewBag.Message = "You do not have permission to perform this action.";
                ViewBag.AllowedRoles = "This action can only be performed by: System Administrator";
                return View("~/Views/Shared/AccessDenied.cshtml");
            }

            var leaveSyncService = new Services.LeaveSyncService(_context);
            var syncedCount = await leaveSyncService.SyncApprovedLeaves(startDate, endDate);

            TempData["SuccessMessage"] = $"Successfully synced {syncedCount} leave records with attendance system.";
            return RedirectToAction(nameof(Index));
        }

        // GET: Attendances/SyncOfflineAttendance
        // Sync offline attendance logs
        public async Task<IActionResult> SyncOfflineAttendance()
        {
            var userId = HttpContext.Session.GetInt32("UserId");
            if (userId == null)
            {
                return RedirectToAction("Login", "Account");
            }

            // Get pending offline attendance records
            var offlineRecords = await _context.OfflineAttendanceQueues
                .Where(q => q.EmployeeId == userId.Value && q.SyncStatus == "Pending")
                .OrderBy(q => q.ClockTime)
                .ToListAsync();

            int syncedCount = 0;
            foreach (var record in offlineRecords)
            {
                try
                {
                    // Find or create attendance record for the day
                    var attendanceDate = DateOnly.FromDateTime(record.ClockTime.Date);
                    
                    var attendance = await _context.Attendances
                        .FirstOrDefaultAsync(a => a.EmployeeId == record.EmployeeId && 
                                                 a.AttendanceId == record.AttendanceId);
                    
                    if (attendance == null)
                    {
                        attendance = new Attendance
                        {
                            EmployeeId = record.EmployeeId,
                            LoginMethod = "Offline Sync",
                            LogoutMethod = "Offline Sync"
                        };
                    }

                    // Update entry or exit time based on clock type
                    if (record.ClockType == "IN" || record.ClockType == "Entry")
                    {
                        attendance.EntryTime = TimeOnly.FromDateTime(record.ClockTime);
                    }
                    else if (record.ClockType == "OUT" || record.ClockType == "Exit")
                    {
                        attendance.ExitTime = TimeOnly.FromDateTime(record.ClockTime);
                    }

                    // Calculate duration if both times are set
                    if (attendance.EntryTime.HasValue && attendance.ExitTime.HasValue)
                    {
                        var entryMinutes = attendance.EntryTime.Value.Hour * 60 + attendance.EntryTime.Value.Minute;
                        var exitMinutes = attendance.ExitTime.Value.Hour * 60 + attendance.ExitTime.Value.Minute;
                        attendance.Duration = exitMinutes - entryMinutes;
                    }

                    if (attendance.AttendanceId == 0)
                    {
                        _context.Attendances.Add(attendance);
                        await _context.SaveChangesAsync();
                        record.AttendanceId = attendance.AttendanceId;
                    }
                    else
                    {
                        _context.Attendances.Update(attendance);
                    }

                    // Mark as synced
                    record.SyncStatus = "Synced";
                    record.SyncedAt = DateTime.Now;
                    _context.OfflineAttendanceQueues.Update(record);
                    
                    syncedCount++;
                }
                catch (DbUpdateException ex)
                {
                    record.SyncStatus = "Failed";
                    record.ErrorMessage = $"Database error: {ex.InnerException?.Message ?? ex.Message}";
                    _context.OfflineAttendanceQueues.Update(record);
                }
                catch (InvalidOperationException ex)
                {
                    record.SyncStatus = "Failed";
                    record.ErrorMessage = $"Operation error: {ex.Message}";
                    _context.OfflineAttendanceQueues.Update(record);
                }
            }

            await _context.SaveChangesAsync();
            TempData["SuccessMessage"] = $"Successfully synced {syncedCount} offline attendance records.";
            return RedirectToAction(nameof(MyAttendance));
        }
    }
}
