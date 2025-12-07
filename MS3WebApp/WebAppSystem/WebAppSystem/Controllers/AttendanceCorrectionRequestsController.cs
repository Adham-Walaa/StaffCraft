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
    }
}
