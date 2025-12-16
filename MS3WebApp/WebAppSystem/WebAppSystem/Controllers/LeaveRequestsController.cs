using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;
using Microsoft.EntityFrameworkCore;
using WebAppSystem.Models;

namespace WebAppSystem.Controllers
{
    public class LeaveRequestsController : Controller
    {
        private readonly Milestone2Context _context;

        public LeaveRequestsController(Milestone2Context context)
        {
            _context = context;
        }

        // GET: LeaveRequests
        public async Task<IActionResult> Index()
        {
            var milestone2Context = _context.LeaveRequests.Include(l => l.Employee).Include(l => l.Leave);
            return View(await milestone2Context.ToListAsync());
        }

        // GET: LeaveRequests/Details/5
        public async Task<IActionResult> Details(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var leaveRequest = await _context.LeaveRequests
                .Include(l => l.Employee)
                .Include(l => l.Leave)
                .FirstOrDefaultAsync(m => m.RequestId == id);
            if (leaveRequest == null)
            {
                return NotFound();
            }

            return View(leaveRequest);
        }

        // GET: LeaveRequests/Create
        public IActionResult Create()
        {
            ViewData["EmployeeId"] = new SelectList(_context.Employees, "EmployeeId", "EmployeeId");
            ViewData["LeaveId"] = new SelectList(_context.Leaves, "LeaveId", "LeaveId");
            return View();
        }

        // POST: LeaveRequests/Create
        // To protect from overposting attacks, enable the specific properties you want to bind to.
        // For more details, see http://go.microsoft.com/fwlink/?LinkId=317598.
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Create([Bind("RequestId,EmployeeId,LeaveId,Justification,Duration,ApprovalTiming,Status")] LeaveRequest leaveRequest)
        {
            if (ModelState.IsValid)
            {
                _context.Add(leaveRequest);
                await _context.SaveChangesAsync();
                return RedirectToAction(nameof(Index));
            }
            ViewData["EmployeeId"] = new SelectList(_context.Employees, "EmployeeId", "EmployeeId", leaveRequest.EmployeeId);
            ViewData["LeaveId"] = new SelectList(_context.Leaves, "LeaveId", "LeaveId", leaveRequest.LeaveId);
            return View(leaveRequest);
        }

        // GET: LeaveRequests/Edit/5
        public async Task<IActionResult> Edit(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var leaveRequest = await _context.LeaveRequests.FindAsync(id);
            if (leaveRequest == null)
            {
                return NotFound();
            }
            ViewData["EmployeeId"] = new SelectList(_context.Employees, "EmployeeId", "EmployeeId", leaveRequest.EmployeeId);
            ViewData["LeaveId"] = new SelectList(_context.Leaves, "LeaveId", "LeaveId", leaveRequest.LeaveId);
            return View(leaveRequest);
        }

        // POST: LeaveRequests/Edit/5
        // To protect from overposting attacks, enable the specific properties you want to bind to.
        // For more details, see http://go.microsoft.com/fwlink/?LinkId=317598.
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Edit(int id, [Bind("RequestId,EmployeeId,LeaveId,Justification,Duration,ApprovalTiming,Status")] LeaveRequest leaveRequest)
        {
            if (id != leaveRequest.RequestId)
            {
                return NotFound();
            }

            if (ModelState.IsValid)
            {
                try
                {
                    _context.Update(leaveRequest);
                    await _context.SaveChangesAsync();
                }
                catch (DbUpdateConcurrencyException)
                {
                    if (!LeaveRequestExists(leaveRequest.RequestId))
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
            ViewData["EmployeeId"] = new SelectList(_context.Employees, "EmployeeId", "EmployeeId", leaveRequest.EmployeeId);
            ViewData["LeaveId"] = new SelectList(_context.Leaves, "LeaveId", "LeaveId", leaveRequest.LeaveId);
            return View(leaveRequest);
        }

        // GET: LeaveRequests/Delete/5
        public async Task<IActionResult> Delete(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var leaveRequest = await _context.LeaveRequests
                .Include(l => l.Employee)
                .Include(l => l.Leave)
                .FirstOrDefaultAsync(m => m.RequestId == id);
            if (leaveRequest == null)
            {
                return NotFound();
            }

            return View(leaveRequest);
        }

        // POST: LeaveRequests/Delete/5
        [HttpPost, ActionName("Delete")]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> DeleteConfirmed(int id)
        {
            var leaveRequest = await _context.LeaveRequests.FindAsync(id);
            if (leaveRequest != null)
            {
                _context.LeaveRequests.Remove(leaveRequest);
            }

            await _context.SaveChangesAsync();
            return RedirectToAction(nameof(Index));
        }

        private bool LeaveRequestExists(int id)
        {
            return _context.LeaveRequests.Any(e => e.RequestId == id);
        }

        // GET: LeaveRequests/SubmitLeaveRequest
        public IActionResult SubmitLeaveRequest()
        {
            ViewData["LeaveId"] = new SelectList(_context.Leaves, "LeaveId", "LeaveType");
            return View();
        }

        // POST: LeaveRequests/SubmitLeaveRequest
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> SubmitLeaveRequest([Bind("LeaveId,Justification,Duration")] LeaveRequest leaveRequest, IFormFile? attachment)
        {
            var userId = HttpContext.Session.GetInt32("UserId");
            if (userId == null)
            {
                return RedirectToAction("Login", "Account");
            }

            // Server-side validation for duration
            if (leaveRequest.Duration <= 0)
            {
                ModelState.AddModelError("Duration", "Duration must be at least 1 day.");
            }

            if (leaveRequest.Duration > 365)
            {
                ModelState.AddModelError("Duration", "Duration cannot exceed 365 days.");
            }

            leaveRequest.EmployeeId = userId.Value;
            leaveRequest.Status = "Pending";
            leaveRequest.ApprovalTiming = null;

            // Generate new RequestId
            var maxRequestId = await _context.LeaveRequests.MaxAsync(lr => (int?)lr.RequestId) ?? 0;
            leaveRequest.RequestId = maxRequestId + 1;

            // Validate file if uploaded
            if (attachment != null && attachment.Length > 0)
            {
                // File size validation (10MB max)
                if (attachment.Length > 10 * 1024 * 1024)
                {
                    ModelState.AddModelError("attachment", "File size must not exceed 10MB.");
                }

                // File type validation
                var allowedExtensions = new[] { ".pdf", ".jpg", ".jpeg", ".png", ".doc", ".docx" };
                var fileExtension = Path.GetExtension(attachment.FileName).ToLowerInvariant();
                
                if (!allowedExtensions.Contains(fileExtension))
                {
                    ModelState.AddModelError("attachment", "Only PDF, JPG, PNG, DOC, and DOCX files are allowed.");
                }
            }

            if (ModelState.IsValid)
            {
                _context.Add(leaveRequest);
                await _context.SaveChangesAsync();

                // Handle file attachment
                if (attachment != null && attachment.Length > 0)
                {
                    var uploadsFolder = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "uploads", "leave-documents");
                    Directory.CreateDirectory(uploadsFolder);
                    
                    var uniqueFileName = $"{leaveRequest.RequestId}_{Guid.NewGuid()}_{attachment.FileName}";
                    var filePath = Path.Combine(uploadsFolder, uniqueFileName);
                    
                    using (var fileStream = new FileStream(filePath, FileMode.Create))
                    {
                        await attachment.CopyToAsync(fileStream);
                    }

                    var maxDocId = await _context.LeaveDocuments.MaxAsync(ld => (int?)ld.DocumentId) ?? 0;
                    var leaveDocument = new LeaveDocument
                    {
                        DocumentId = maxDocId + 1,
                        LeaveRequestId = leaveRequest.RequestId,
                        FilePath = $"/uploads/leave-documents/{uniqueFileName}",
                        UploadedAt = DateTime.Now
                    };
                    _context.LeaveDocuments.Add(leaveDocument);
                    await _context.SaveChangesAsync();
                }

                TempData["SuccessMessage"] = "Leave request submitted successfully!";
                return RedirectToAction(nameof(LeaveHistory));
            }
            
            ViewData["LeaveId"] = new SelectList(_context.Leaves, "LeaveId", "LeaveType", leaveRequest.LeaveId);
            return View(leaveRequest);
        }

        // GET: LeaveRequests/HRLeaveRequests
        public async Task<IActionResult> HRLeaveRequests()
        {
            var userRoles = HttpContext.Session.GetString("UserRoles");
            if (string.IsNullOrEmpty(userRoles) || !userRoles.Contains("HR Administrator"))
            {
                TempData["ErrorMessage"] = "Access denied. Only HR Administrators can view this page.";
                return RedirectToAction("Index", "Home");
            }

            var pendingRequests = await _context.LeaveRequests
                .Include(l => l.Employee)
                .Include(l => l.Leave)
                .Include(l => l.LeaveDocuments)
                .Where(l => l.Status == "Pending")
                .OrderBy(l => l.RequestId)
                .ToListAsync();

            return View(pendingRequests);
        }

        // POST: LeaveRequests/ApproveLeaveRequest
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> ApproveLeaveRequest(int id)
        {
            var userRoles = HttpContext.Session.GetString("UserRoles");
            if (string.IsNullOrEmpty(userRoles) || !userRoles.Contains("HR Administrator"))
            {
                TempData["ErrorMessage"] = "Access denied.";
                return RedirectToAction("Index", "Home");
            }

            var leaveRequest = await _context.LeaveRequests.FindAsync(id);
            if (leaveRequest == null)
            {
                return NotFound();
            }

            // Check if employee has sufficient leave balance
            var entitlement = await _context.LeaveEntitlements
                .FirstOrDefaultAsync(e => e.EmployeeId == leaveRequest.EmployeeId && e.LeaveTypeId == leaveRequest.LeaveId);
            
            // If no entitlement exists, initialize with default balance
            if (entitlement == null)
            {
                entitlement = new LeaveEntitlement
                {
                    EmployeeId = leaveRequest.EmployeeId.Value,
                    LeaveTypeId = leaveRequest.LeaveId.Value,
                    Entitlement = 3 // Default 3 leaves per month
                };
                _context.LeaveEntitlements.Add(entitlement);
                await _context.SaveChangesAsync();
            }
            
            // Check if entitlement value is null
            if (!entitlement.Entitlement.HasValue)
            {
                entitlement.Entitlement = 3; // Set default if null
            }
            
            // Check if sufficient balance
            if (entitlement.Entitlement < leaveRequest.Duration)
            {
                TempData["ErrorMessage"] = $"Cannot approve: Employee only has {entitlement.Entitlement} days remaining but requested {leaveRequest.Duration} days.";
                return RedirectToAction(nameof(HRLeaveRequests));
            }
            
            // Deduct from balance
            entitlement.Entitlement -= leaveRequest.Duration;

            leaveRequest.Status = "Approved";
            leaveRequest.ApprovalTiming = DateTime.Now;

            await _context.SaveChangesAsync();
            
            // Sync with attendance (placeholder for future implementation)
            await SyncLeaveWithAttendance(leaveRequest);
            
            TempData["SuccessMessage"] = "Leave request approved successfully!";
            return RedirectToAction(nameof(HRLeaveRequests));
        }

        // POST: LeaveRequests/RejectLeaveRequest
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> RejectLeaveRequest(int id)
        {
            var userRoles = HttpContext.Session.GetString("UserRoles");
            if (string.IsNullOrEmpty(userRoles) || !userRoles.Contains("HR Administrator"))
            {
                TempData["ErrorMessage"] = "Access denied.";
                return RedirectToAction("Index", "Home");
            }

            var leaveRequest = await _context.LeaveRequests.FindAsync(id);
            if (leaveRequest == null)
            {
                return NotFound();
            }

            leaveRequest.Status = "Rejected";
            leaveRequest.ApprovalTiming = DateTime.Now;

            await _context.SaveChangesAsync();
            TempData["SuccessMessage"] = "Leave request rejected.";
            return RedirectToAction(nameof(HRLeaveRequests));
        }

        // POST: LeaveRequests/OverrideApproveRequest
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> OverrideApproveRequest(int id, string overrideReason)
        {
            var userRoles = HttpContext.Session.GetString("UserRoles");
            if (string.IsNullOrEmpty(userRoles) || !userRoles.Contains("HR Administrator"))
            {
                TempData["ErrorMessage"] = "Access denied.";
                return RedirectToAction("Index", "Home");
            }

            var leaveRequest = await _context.LeaveRequests
                .Include(l => l.Employee)
                .Include(l => l.Leave)
                .FirstOrDefaultAsync(l => l.RequestId == id);
                
            if (leaveRequest == null)
            {
                return NotFound();
            }

            // Get or create entitlement
            var entitlement = await _context.LeaveEntitlements
                .FirstOrDefaultAsync(e => e.EmployeeId == leaveRequest.EmployeeId && e.LeaveTypeId == leaveRequest.LeaveId);
            
            if (entitlement == null)
            {
                entitlement = new LeaveEntitlement
                {
                    EmployeeId = leaveRequest.EmployeeId.Value,
                    LeaveTypeId = leaveRequest.LeaveId.Value,
                    Entitlement = 3
                };
                _context.LeaveEntitlements.Add(entitlement);
                await _context.SaveChangesAsync();
            }
            
            if (!entitlement.Entitlement.HasValue)
            {
                entitlement.Entitlement = 3;
            }
            
            // Override - deduct from balance even if insufficient (can go negative)
            entitlement.Entitlement -= leaveRequest.Duration;

            leaveRequest.Status = "Approved";
            leaveRequest.ApprovalTiming = DateTime.Now;
            
            // Add override note to justification
            var overrideNote = $"\n\n[OVERRIDE APPROVAL by HR on {DateTime.Now:yyyy-MM-dd HH:mm}]: {(string.IsNullOrWhiteSpace(overrideReason) ? "No reason provided" : overrideReason.Trim())}";
            leaveRequest.Justification = (leaveRequest.Justification ?? "") + overrideNote;

            await _context.SaveChangesAsync();
            
            // Sync with attendance (placeholder for future implementation)
            await SyncLeaveWithAttendance(leaveRequest);
            
            TempData["SuccessMessage"] = "Leave request approved via override!";
            return RedirectToAction(nameof(HRLeaveRequests));
        }

        // POST: LeaveRequests/OverrideRejectRequest
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> OverrideRejectRequest(int id, string overrideReason)
        {
            var userRoles = HttpContext.Session.GetString("UserRoles");
            if (string.IsNullOrEmpty(userRoles) || !userRoles.Contains("HR Administrator"))
            {
                TempData["ErrorMessage"] = "Access denied.";
                return RedirectToAction("Index", "Home");
            }

            var leaveRequest = await _context.LeaveRequests.FindAsync(id);
            if (leaveRequest == null)
            {
                return NotFound();
            }

            leaveRequest.Status = "Rejected";
            leaveRequest.ApprovalTiming = DateTime.Now;
            
            // Add override note to justification
            var overrideNote = $"\n\n[OVERRIDE REJECTION by HR on {DateTime.Now:yyyy-MM-dd HH:mm}]: {(string.IsNullOrWhiteSpace(overrideReason) ? "No reason provided" : overrideReason.Trim())}";
            leaveRequest.Justification = (leaveRequest.Justification ?? "") + overrideNote;

            await _context.SaveChangesAsync();
            TempData["SuccessMessage"] = "Leave request rejected via override.";
            return RedirectToAction(nameof(HRLeaveRequests));
        }

        // Helper method to sync leave approval with attendance records
        private async Task SyncLeaveWithAttendance(LeaveRequest leaveRequest)
        {
            // Note: The current schema doesn't have date-based leave tracking in LeaveRequest
            // and Attendance table doesn't have Status/Remarks fields.
            // This method is a placeholder for future attendance integration.
            // When the schema is updated to include leave start/end dates,
            // this method will create attendance records for the leave period.
            
            // For now, we'll just log that the leave was approved
            // The attendance sync will be fully functional once the schema includes:
            // 1. StartDate and EndDate in LeaveRequest table
            // 2. AttendanceDate, Status, and Remarks in Attendance table
            
            await Task.CompletedTask;
        }

        // GET: LeaveRequests/LeaveHistory
        public async Task<IActionResult> LeaveHistory()
        {
            var userId = HttpContext.Session.GetInt32("UserId");
            if (userId == null)
            {
                return RedirectToAction("Login", "Account");
            }

            var leaveHistory = await _context.LeaveRequests
                .Include(l => l.Leave)
                .Include(l => l.LeaveDocuments)
                .Where(l => l.EmployeeId == userId.Value)
                .OrderByDescending(l => l.RequestId)
                .ToListAsync();

            return View(leaveHistory);
        }

        // GET: LeaveRequests/LeaveBalance
        public async Task<IActionResult> LeaveBalance()
        {
            var userId = HttpContext.Session.GetInt32("UserId");
            if (userId == null)
            {
                return RedirectToAction("Login", "Account");
            }

            var leaveBalances = await _context.LeaveEntitlements
                .Include(e => e.LeaveType)
                .Where(e => e.EmployeeId == userId.Value)
                .ToListAsync();

            // Initialize default balance if no entitlements exist
            if (!leaveBalances.Any())
            {
                var leaveTypes = await _context.Leaves.ToListAsync();
                foreach (var leaveType in leaveTypes)
                {
                    var entitlement = new LeaveEntitlement
                    {
                        EmployeeId = userId.Value,
                        LeaveTypeId = leaveType.LeaveId,
                        Entitlement = 3 // Default 3 leaves per month
                    };
                    _context.LeaveEntitlements.Add(entitlement);
                }
                await _context.SaveChangesAsync();
                
                leaveBalances = await _context.LeaveEntitlements
                    .Include(e => e.LeaveType)
                    .Where(e => e.EmployeeId == userId.Value)
                    .ToListAsync();
            }

            return View(leaveBalances);
        }

        // GET: LeaveRequests/AdjustLeaveBalance
        public async Task<IActionResult> AdjustLeaveBalance(int? employeeId)
        {
            var userRoles = HttpContext.Session.GetString("UserRoles");
            if (string.IsNullOrEmpty(userRoles) || !userRoles.Contains("HR Administrator"))
            {
                TempData["ErrorMessage"] = "Access denied. Only HR Administrators can adjust leave balances.";
                return RedirectToAction("Index", "Home");
            }

            ViewData["EmployeeId"] = new SelectList(_context.Employees, "EmployeeId", "FullName", employeeId);
            
            if (employeeId.HasValue)
            {
                var leaveBalances = await _context.LeaveEntitlements
                    .Include(e => e.LeaveType)
                    .Where(e => e.EmployeeId == employeeId.Value)
                    .ToListAsync();
                
                ViewBag.LeaveBalances = leaveBalances;
                ViewBag.SelectedEmployeeId = employeeId.Value;
            }

            return View();
        }

        // POST: LeaveRequests/UpdateLeaveBalance
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> UpdateLeaveBalance(int employeeId, int leaveTypeId, int newBalance)
        {
            var userRoles = HttpContext.Session.GetString("UserRoles");
            if (string.IsNullOrEmpty(userRoles) || !userRoles.Contains("HR Administrator"))
            {
                TempData["ErrorMessage"] = "Access denied.";
                return RedirectToAction("Index", "Home");
            }

            var entitlement = await _context.LeaveEntitlements
                .FirstOrDefaultAsync(e => e.EmployeeId == employeeId && e.LeaveTypeId == leaveTypeId);

            if (entitlement == null)
            {
                entitlement = new LeaveEntitlement
                {
                    EmployeeId = employeeId,
                    LeaveTypeId = leaveTypeId,
                    Entitlement = newBalance
                };
                _context.LeaveEntitlements.Add(entitlement);
            }
            else
            {
                entitlement.Entitlement = newBalance;
            }

            await _context.SaveChangesAsync();
            TempData["SuccessMessage"] = "Leave balance updated successfully!";
            return RedirectToAction(nameof(AdjustLeaveBalance), new { employeeId = employeeId });
        }

        // GET: LeaveRequests/ManagerLeaveRequests
        public async Task<IActionResult> ManagerLeaveRequests()
        {
            var userId = HttpContext.Session.GetInt32("UserId");
            if (userId == null)
            {
                return RedirectToAction("Login", "Account");
            }

            var userRoles = HttpContext.Session.GetString("UserRoles");
            if (string.IsNullOrEmpty(userRoles) || !userRoles.Contains("Line Manager"))
            {
                TempData["ErrorMessage"] = "Access denied. Only Line Managers can view this page.";
                return RedirectToAction("Index", "Home");
            }

            // Get all pending leave requests from employees who report to this manager
            var teamLeaveRequests = await _context.LeaveRequests
                .Include(l => l.Employee)
                .Include(l => l.Leave)
                .Include(l => l.LeaveDocuments)
                .Where(l => l.Employee.ManagerId == userId.Value && l.Status == "Pending")
                .OrderBy(l => l.RequestId)
                .ToListAsync();

            return View(teamLeaveRequests);
        }

        // POST: LeaveRequests/ManagerApproveLeaveRequest
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> ManagerApproveLeaveRequest(int id)
        {
            var userId = HttpContext.Session.GetInt32("UserId");
            if (userId == null)
            {
                return RedirectToAction("Login", "Account");
            }

            var userRoles = HttpContext.Session.GetString("UserRoles");
            if (string.IsNullOrEmpty(userRoles) || !userRoles.Contains("Line Manager"))
            {
                TempData["ErrorMessage"] = "Access denied.";
                return RedirectToAction("Index", "Home");
            }

            var leaveRequest = await _context.LeaveRequests
                .Include(l => l.Employee)
                .FirstOrDefaultAsync(l => l.RequestId == id);
                
            if (leaveRequest == null)
            {
                return NotFound();
            }

            // Verify the employee reports to this manager
            if (leaveRequest.Employee.ManagerId != userId.Value)
            {
                TempData["ErrorMessage"] = "You can only approve leave requests from your direct reports.";
                return RedirectToAction(nameof(ManagerLeaveRequests));
            }

            // Check if employee has sufficient leave balance
            var entitlement = await _context.LeaveEntitlements
                .FirstOrDefaultAsync(e => e.EmployeeId == leaveRequest.EmployeeId && e.LeaveTypeId == leaveRequest.LeaveId);
            
            // If no entitlement exists, initialize with default balance
            if (entitlement == null)
            {
                entitlement = new LeaveEntitlement
                {
                    EmployeeId = leaveRequest.EmployeeId.Value,
                    LeaveTypeId = leaveRequest.LeaveId.Value,
                    Entitlement = 3 // Default 3 leaves per month
                };
                _context.LeaveEntitlements.Add(entitlement);
                await _context.SaveChangesAsync();
            }
            
            // Check if entitlement value is null
            if (!entitlement.Entitlement.HasValue)
            {
                entitlement.Entitlement = 3; // Set default if null
            }
            
            // Check if sufficient balance
            if (entitlement.Entitlement < leaveRequest.Duration)
            {
                TempData["ErrorMessage"] = $"Cannot approve: Employee only has {entitlement.Entitlement} days remaining but requested {leaveRequest.Duration} days.";
                return RedirectToAction(nameof(ManagerLeaveRequests));
            }
            
            // Deduct from balance
            entitlement.Entitlement -= leaveRequest.Duration;

            leaveRequest.Status = "Approved";
            leaveRequest.ApprovalTiming = DateTime.Now;

            await _context.SaveChangesAsync();
            
            // Sync with attendance (placeholder for future implementation)
            await SyncLeaveWithAttendance(leaveRequest);
            
            TempData["SuccessMessage"] = "Leave request approved successfully!";
            return RedirectToAction(nameof(ManagerLeaveRequests));
        }

        // POST: LeaveRequests/ManagerRejectLeaveRequest
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> ManagerRejectLeaveRequest(int id)
        {
            var userId = HttpContext.Session.GetInt32("UserId");
            if (userId == null)
            {
                return RedirectToAction("Login", "Account");
            }

            var userRoles = HttpContext.Session.GetString("UserRoles");
            if (string.IsNullOrEmpty(userRoles) || !userRoles.Contains("Line Manager"))
            {
                TempData["ErrorMessage"] = "Access denied.";
                return RedirectToAction("Index", "Home");
            }

            var leaveRequest = await _context.LeaveRequests
                .Include(l => l.Employee)
                .FirstOrDefaultAsync(l => l.RequestId == id);
                
            if (leaveRequest == null)
            {
                return NotFound();
            }

            // Verify the employee reports to this manager
            if (leaveRequest.Employee.ManagerId != userId.Value)
            {
                TempData["ErrorMessage"] = "You can only reject leave requests from your direct reports.";
                return RedirectToAction(nameof(ManagerLeaveRequests));
            }

            leaveRequest.Status = "Rejected";
            leaveRequest.ApprovalTiming = DateTime.Now;

            await _context.SaveChangesAsync();
            TempData["SuccessMessage"] = "Leave request rejected.";
            return RedirectToAction(nameof(ManagerLeaveRequests));
        }

        // POST: LeaveRequests/FlagIrregularPattern
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> FlagIrregularPattern(int id, string patternNotes)
        {
            var userId = HttpContext.Session.GetInt32("UserId");
            if (userId == null)
            {
                return RedirectToAction("Login", "Account");
            }

            var userRoles = HttpContext.Session.GetString("UserRoles");
            if (string.IsNullOrEmpty(userRoles) || !userRoles.Contains("Line Manager"))
            {
                TempData["ErrorMessage"] = "Access denied.";
                return RedirectToAction("Index", "Home");
            }

            // Validate pattern notes
            if (string.IsNullOrWhiteSpace(patternNotes))
            {
                TempData["ErrorMessage"] = "Pattern notes are required.";
                return RedirectToAction(nameof(ManagerLeaveRequests));
            }

            if (patternNotes.Length > 500)
            {
                TempData["ErrorMessage"] = "Pattern notes must not exceed 500 characters.";
                return RedirectToAction(nameof(ManagerLeaveRequests));
            }

            var leaveRequest = await _context.LeaveRequests
                .Include(l => l.Employee)
                .FirstOrDefaultAsync(l => l.RequestId == id);
                
            if (leaveRequest == null)
            {
                return NotFound();
            }

            // Verify the employee reports to this manager
            if (leaveRequest.Employee.ManagerId != userId.Value)
            {
                TempData["ErrorMessage"] = "You can only flag leave requests from your direct reports.";
                return RedirectToAction(nameof(ManagerLeaveRequests));
            }

            // Add a note to the justification indicating irregular pattern
            var sanitizedNotes = patternNotes.Trim();
            var flagNote = $"\n\n[FLAGGED BY MANAGER on {DateTime.Now:yyyy-MM-dd HH:mm}]: {sanitizedNotes}";
            leaveRequest.Justification = (leaveRequest.Justification ?? "") + flagNote;

            await _context.SaveChangesAsync();
            TempData["SuccessMessage"] = "Leave request flagged for irregular pattern.";
            return RedirectToAction(nameof(ManagerLeaveRequests));
        }
    }
}
