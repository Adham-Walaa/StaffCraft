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
    public class AttendanceCorrectionRequestsController : Controller
    {
        private readonly Milestone2Context _context;

        public AttendanceCorrectionRequestsController(Milestone2Context context)
        {
            _context = context;
        }

        // GET: AttendanceCorrectionRequests
        public async Task<IActionResult> Index()
        {
            var milestone2Context = _context.AttendanceCorrectionRequests.Include(a => a.Employee).Include(a => a.RecommendedByNavigation);
            return View(await milestone2Context.ToListAsync());
        }

        // GET: AttendanceCorrectionRequests/Details/5
        public async Task<IActionResult> Details(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var attendanceCorrectionRequest = await _context.AttendanceCorrectionRequests
                .Include(a => a.Employee)
                .Include(a => a.RecommendedByNavigation)
                .FirstOrDefaultAsync(m => m.RequestId == id);
            if (attendanceCorrectionRequest == null)
            {
                return NotFound();
            }

            return View(attendanceCorrectionRequest);
        }

        // GET: AttendanceCorrectionRequests/Create
        public IActionResult Create()
        {
            ViewData["EmployeeId"] = new SelectList(_context.Employees, "EmployeeId", "EmployeeId");
            ViewData["RecommendedBy"] = new SelectList(_context.Employees, "EmployeeId", "EmployeeId");
            return View();
        }

        // POST: AttendanceCorrectionRequests/Create
        // To protect from overposting attacks, enable the specific properties you want to bind to.
        // For more details, see http://go.microsoft.com/fwlink/?LinkId=317598.
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Create([Bind("RequestId,EmployeeId,Date,CorrectionType,Reason,Status,RecommendedBy")] AttendanceCorrectionRequest attendanceCorrectionRequest)
        {
            if (ModelState.IsValid)
            {
                _context.Add(attendanceCorrectionRequest);
                await _context.SaveChangesAsync();
                return RedirectToAction(nameof(Index));
            }
            ViewData["EmployeeId"] = new SelectList(_context.Employees, "EmployeeId", "EmployeeId", attendanceCorrectionRequest.EmployeeId);
            ViewData["RecommendedBy"] = new SelectList(_context.Employees, "EmployeeId", "EmployeeId", attendanceCorrectionRequest.RecommendedBy);
            return View(attendanceCorrectionRequest);
        }

        // GET: AttendanceCorrectionRequests/Edit/5
        public async Task<IActionResult> Edit(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var attendanceCorrectionRequest = await _context.AttendanceCorrectionRequests.FindAsync(id);
            if (attendanceCorrectionRequest == null)
            {
                return NotFound();
            }
            ViewData["EmployeeId"] = new SelectList(_context.Employees, "EmployeeId", "EmployeeId", attendanceCorrectionRequest.EmployeeId);
            ViewData["RecommendedBy"] = new SelectList(_context.Employees, "EmployeeId", "EmployeeId", attendanceCorrectionRequest.RecommendedBy);
            return View(attendanceCorrectionRequest);
        }

        // POST: AttendanceCorrectionRequests/Edit/5
        // To protect from overposting attacks, enable the specific properties you want to bind to.
        // For more details, see http://go.microsoft.com/fwlink/?LinkId=317598.
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Edit(int id, [Bind("RequestId,EmployeeId,Date,CorrectionType,Reason,Status,RecommendedBy")] AttendanceCorrectionRequest attendanceCorrectionRequest)
        {
            if (id != attendanceCorrectionRequest.RequestId)
            {
                return NotFound();
            }

            if (ModelState.IsValid)
            {
                try
                {
                    _context.Update(attendanceCorrectionRequest);
                    await _context.SaveChangesAsync();
                }
                catch (DbUpdateConcurrencyException)
                {
                    if (!AttendanceCorrectionRequestExists(attendanceCorrectionRequest.RequestId))
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
            ViewData["EmployeeId"] = new SelectList(_context.Employees, "EmployeeId", "EmployeeId", attendanceCorrectionRequest.EmployeeId);
            ViewData["RecommendedBy"] = new SelectList(_context.Employees, "EmployeeId", "EmployeeId", attendanceCorrectionRequest.RecommendedBy);
            return View(attendanceCorrectionRequest);
        }

        // GET: AttendanceCorrectionRequests/Delete/5
        public async Task<IActionResult> Delete(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var attendanceCorrectionRequest = await _context.AttendanceCorrectionRequests
                .Include(a => a.Employee)
                .Include(a => a.RecommendedByNavigation)
                .FirstOrDefaultAsync(m => m.RequestId == id);
            if (attendanceCorrectionRequest == null)
            {
                return NotFound();
            }

            return View(attendanceCorrectionRequest);
        }

        // POST: AttendanceCorrectionRequests/Delete/5
        [HttpPost, ActionName("Delete")]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> DeleteConfirmed(int id)
        {
            var attendanceCorrectionRequest = await _context.AttendanceCorrectionRequests.FindAsync(id);
            if (attendanceCorrectionRequest != null)
            {
                _context.AttendanceCorrectionRequests.Remove(attendanceCorrectionRequest);
            }

            await _context.SaveChangesAsync();
            return RedirectToAction(nameof(Index));
        }

        private bool AttendanceCorrectionRequestExists(int id)
        {
            return _context.AttendanceCorrectionRequests.Any(e => e.RequestId == id);
        }

        // GET: AttendanceCorrectionRequests/MyRequests
        // Employee views their own correction requests
        public async Task<IActionResult> MyRequests()
        {
            var userId = HttpContext.Session.GetInt32("UserId");
            if (userId == null)
            {
                return RedirectToAction("Login", "Account");
            }

            var requests = await _context.AttendanceCorrectionRequests
                .Include(a => a.Employee)
                .Include(a => a.RecommendedByNavigation)
                .Where(a => a.EmployeeId == userId)
                .OrderByDescending(a => a.RequestId)
                .ToListAsync();

            return View(requests);
        }

        // GET: AttendanceCorrectionRequests/SubmitRequest
        // Employee submits a new correction request
        public IActionResult SubmitRequest()
        {
            var userId = HttpContext.Session.GetInt32("UserId");
            if (userId == null)
            {
                return RedirectToAction("Login", "Account");
            }

            ViewData["EmployeeId"] = userId;
            return View();
        }

        // POST: AttendanceCorrectionRequests/SubmitRequest
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> SubmitRequest([Bind("Date,CorrectionType,Reason")] AttendanceCorrectionRequest attendanceCorrectionRequest)
        {
            var userId = HttpContext.Session.GetInt32("UserId");
            if (userId == null)
            {
                return RedirectToAction("Login", "Account");
            }

            attendanceCorrectionRequest.EmployeeId = userId.Value;
            attendanceCorrectionRequest.Status = "Pending";

            ModelState.Clear();
            if (TryValidateModel(attendanceCorrectionRequest))
            {
                _context.Add(attendanceCorrectionRequest);
                await _context.SaveChangesAsync();
                TempData["SuccessMessage"] = "Attendance correction request submitted successfully!";
                return RedirectToAction(nameof(MyRequests));
            }

            ViewData["EmployeeId"] = userId;
            return View(attendanceCorrectionRequest);
        }

        // GET: AttendanceCorrectionRequests/Approve/5
        // Manager or HR approves a correction request
        public async Task<IActionResult> Approve(int? id)
        {
            var userRoles = HttpContext.Session.GetString("UserRoles");
            if (string.IsNullOrEmpty(userRoles) || 
                (!userRoles.Contains("Line Manager") && !userRoles.Contains("HR Administrator")))
            {
                return Forbid();
            }

            if (id == null)
            {
                return NotFound();
            }

            var request = await _context.AttendanceCorrectionRequests
                .Include(a => a.Employee)
                .FirstOrDefaultAsync(m => m.RequestId == id);
            
            if (request == null)
            {
                return NotFound();
            }

            return View(request);
        }

        // POST: AttendanceCorrectionRequests/Approve/5
        [HttpPost, ActionName("Approve")]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> ApproveConfirmed(int id)
        {
            var userRoles = HttpContext.Session.GetString("UserRoles");
            var userId = HttpContext.Session.GetInt32("UserId");
            
            if (string.IsNullOrEmpty(userRoles) || 
                (!userRoles.Contains("Line Manager") && !userRoles.Contains("HR Administrator")) ||
                userId == null)
            {
                return Forbid();
            }

            var request = await _context.AttendanceCorrectionRequests.FindAsync(id);
            if (request != null)
            {
                request.Status = "Approved";
                request.RecommendedBy = userId.Value;
                _context.Update(request);
                await _context.SaveChangesAsync();
                TempData["SuccessMessage"] = "Attendance correction request approved successfully!";
            }

            return RedirectToAction(nameof(Index));
        }

        // GET: AttendanceCorrectionRequests/Reject/5
        // Manager or HR rejects a correction request
        public async Task<IActionResult> Reject(int? id)
        {
            var userRoles = HttpContext.Session.GetString("UserRoles");
            if (string.IsNullOrEmpty(userRoles) || 
                (!userRoles.Contains("Line Manager") && !userRoles.Contains("HR Administrator")))
            {
                return Forbid();
            }

            if (id == null)
            {
                return NotFound();
            }

            var request = await _context.AttendanceCorrectionRequests
                .Include(a => a.Employee)
                .FirstOrDefaultAsync(m => m.RequestId == id);
            
            if (request == null)
            {
                return NotFound();
            }

            return View(request);
        }

        // POST: AttendanceCorrectionRequests/Reject/5
        [HttpPost, ActionName("Reject")]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> RejectConfirmed(int id)
        {
            var userRoles = HttpContext.Session.GetString("UserRoles");
            var userId = HttpContext.Session.GetInt32("UserId");
            
            if (string.IsNullOrEmpty(userRoles) || 
                (!userRoles.Contains("Line Manager") && !userRoles.Contains("HR Administrator")) ||
                userId == null)
            {
                return Forbid();
            }

            var request = await _context.AttendanceCorrectionRequests.FindAsync(id);
            if (request != null)
            {
                request.Status = "Rejected";
                request.RecommendedBy = userId.Value;
                _context.Update(request);
                await _context.SaveChangesAsync();
                TempData["SuccessMessage"] = "Attendance correction request rejected.";
            }

            return RedirectToAction(nameof(Index));
        }
    }
}
