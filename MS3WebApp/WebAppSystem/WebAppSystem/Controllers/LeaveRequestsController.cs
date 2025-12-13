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

            leaveRequest.EmployeeId = userId.Value;
            leaveRequest.Status = "Pending";
            leaveRequest.ApprovalTiming = null;

            // Generate new RequestId
            var maxRequestId = await _context.LeaveRequests.MaxAsync(lr => (int?)lr.RequestId) ?? 0;
            leaveRequest.RequestId = maxRequestId + 1;

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

            leaveRequest.Status = "Approved";
            leaveRequest.ApprovalTiming = DateTime.Now;

            // Deduct from leave balance
            var entitlement = await _context.LeaveEntitlements
                .FirstOrDefaultAsync(e => e.EmployeeId == leaveRequest.EmployeeId && e.LeaveTypeId == leaveRequest.LeaveId);
            
            if (entitlement != null && entitlement.Entitlement.HasValue)
            {
                entitlement.Entitlement -= leaveRequest.Duration;
            }

            await _context.SaveChangesAsync();
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
    }
}
