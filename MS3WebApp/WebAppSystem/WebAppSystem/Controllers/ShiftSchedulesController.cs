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
    public class ShiftSchedulesController : Controller
    {
        private readonly Milestone2Context _context;

        public ShiftSchedulesController(Milestone2Context context)
        {
            _context = context;
        }

        // GET: ShiftSchedules
        public async Task<IActionResult> Index()
        {
            var milestone2Context = _context.ShiftSchedules.Include(s => s.Employee);
            return View(await milestone2Context.ToListAsync());
        }

        // GET: ShiftSchedules/Details/5
        public async Task<IActionResult> Details(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var shiftSchedule = await _context.ShiftSchedules
                .Include(s => s.Employee)
                .FirstOrDefaultAsync(m => m.ShiftId == id);
            if (shiftSchedule == null)
            {
                return NotFound();
            }

            return View(shiftSchedule);
        }

        // GET: ShiftSchedules/Create
        public IActionResult Create()
        {
            ViewData["EmployeeId"] = new SelectList(_context.Employees, "EmployeeId", "EmployeeId");
            return View();
        }

        // POST: ShiftSchedules/Create
        // To protect from overposting attacks, enable the specific properties you want to bind to.
        // For more details, see http://go.microsoft.com/fwlink/?LinkId=317598.
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Create([Bind("ShiftId,EmployeeId,StartDate,EndDate,Status,ShiftName,ShiftType,StartTime,EndTime")] ShiftSchedule shiftSchedule)
        {
            if (ModelState.IsValid)
            {
                _context.Add(shiftSchedule);
                await _context.SaveChangesAsync();
                return RedirectToAction(nameof(Index));
            }
            ViewData["EmployeeId"] = new SelectList(_context.Employees, "EmployeeId", "EmployeeId", shiftSchedule.EmployeeId);
            return View(shiftSchedule);
        }

        // GET: ShiftSchedules/Edit/5
        public async Task<IActionResult> Edit(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var shiftSchedule = await _context.ShiftSchedules.FindAsync(id);
            if (shiftSchedule == null)
            {
                return NotFound();
            }
            ViewData["EmployeeId"] = new SelectList(_context.Employees, "EmployeeId", "EmployeeId", shiftSchedule.EmployeeId);
            return View(shiftSchedule);
        }

        // POST: ShiftSchedules/Edit/5
        // To protect from overposting attacks, enable the specific properties you want to bind to.
        // For more details, see http://go.microsoft.com/fwlink/?LinkId=317598.
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Edit(int id, [Bind("ShiftId,EmployeeId,StartDate,EndDate,Status,ShiftName,ShiftType,StartTime,EndTime")] ShiftSchedule shiftSchedule)
        {
            if (id != shiftSchedule.ShiftId)
            {
                return NotFound();
            }

            if (ModelState.IsValid)
            {
                try
                {
                    _context.Update(shiftSchedule);
                    await _context.SaveChangesAsync();
                }
                catch (DbUpdateConcurrencyException)
                {
                    if (!ShiftScheduleExists(shiftSchedule.ShiftId))
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
            ViewData["EmployeeId"] = new SelectList(_context.Employees, "EmployeeId", "EmployeeId", shiftSchedule.EmployeeId);
            return View(shiftSchedule);
        }

        // GET: ShiftSchedules/Delete/5
        public async Task<IActionResult> Delete(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var shiftSchedule = await _context.ShiftSchedules
                .Include(s => s.Employee)
                .FirstOrDefaultAsync(m => m.ShiftId == id);
            if (shiftSchedule == null)
            {
                return NotFound();
            }

            return View(shiftSchedule);
        }

        // POST: ShiftSchedules/Delete/5
        [HttpPost, ActionName("Delete")]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> DeleteConfirmed(int id)
        {
            var shiftSchedule = await _context.ShiftSchedules.FindAsync(id);
            if (shiftSchedule != null)
            {
                _context.ShiftSchedules.Remove(shiftSchedule);
            }

            await _context.SaveChangesAsync();
            return RedirectToAction(nameof(Index));
        }

        private bool ShiftScheduleExists(int id)
        {
            return _context.ShiftSchedules.Any(e => e.ShiftId == id);
        }
    }
}
