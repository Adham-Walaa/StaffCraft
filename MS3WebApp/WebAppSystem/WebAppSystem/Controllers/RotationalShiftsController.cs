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
    public class RotationalShiftsController : Controller
    {
        private readonly Milestone2Context _context;

        public RotationalShiftsController(Milestone2Context context)
        {
            _context = context;
        }

        // GET: RotationalShifts
        public async Task<IActionResult> Index()
        {
            var userRoles = HttpContext.Session.GetString("UserRoles");
            if (string.IsNullOrEmpty(userRoles) || 
                (!userRoles.Contains("System Administrator") && !userRoles.Contains("HR Administrator")))
            {
                return Forbid();
            }

            return View(await _context.ShiftCycles.ToListAsync());
        }

        // GET: RotationalShifts/Details/5
        public async Task<IActionResult> Details(int? id)
        {
            var userRoles = HttpContext.Session.GetString("UserRoles");
            if (string.IsNullOrEmpty(userRoles) || 
                (!userRoles.Contains("System Administrator") && !userRoles.Contains("HR Administrator")))
            {
                return Forbid();
            }

            if (id == null)
            {
                return NotFound();
            }

            var shiftCycle = await _context.ShiftCycles
                .FirstOrDefaultAsync(m => m.CycleId == id);
            if (shiftCycle == null)
            {
                return NotFound();
            }

            return View(shiftCycle);
        }

        // GET: RotationalShifts/Create
        public IActionResult Create()
        {
            var userRoles = HttpContext.Session.GetString("UserRoles");
            if (string.IsNullOrEmpty(userRoles) || !userRoles.Contains("HR Administrator"))
            {
                return Forbid();
            }

            return View();
        }

        // POST: RotationalShifts/Create
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Create([Bind("CycleId,CycleName,Description")] ShiftCycle shiftCycle)
        {
            var userRoles = HttpContext.Session.GetString("UserRoles");
            if (string.IsNullOrEmpty(userRoles) || !userRoles.Contains("HR Administrator"))
            {
                return Forbid();
            }

            if (ModelState.IsValid)
            {
                _context.Add(shiftCycle);
                await _context.SaveChangesAsync();
                TempData["SuccessMessage"] = "Rotational shift cycle created successfully!";
                return RedirectToAction(nameof(Index));
            }
            return View(shiftCycle);
        }

        // GET: RotationalShifts/Edit/5
        public async Task<IActionResult> Edit(int? id)
        {
            var userRoles = HttpContext.Session.GetString("UserRoles");
            if (string.IsNullOrEmpty(userRoles) || !userRoles.Contains("HR Administrator"))
            {
                return Forbid();
            }

            if (id == null)
            {
                return NotFound();
            }

            var shiftCycle = await _context.ShiftCycles.FindAsync(id);
            if (shiftCycle == null)
            {
                return NotFound();
            }
            return View(shiftCycle);
        }

        // POST: RotationalShifts/Edit/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Edit(int id, [Bind("CycleId,CycleName,Description")] ShiftCycle shiftCycle)
        {
            var userRoles = HttpContext.Session.GetString("UserRoles");
            if (string.IsNullOrEmpty(userRoles) || !userRoles.Contains("HR Administrator"))
            {
                return Forbid();
            }

            if (id != shiftCycle.CycleId)
            {
                return NotFound();
            }

            if (ModelState.IsValid)
            {
                try
                {
                    _context.Update(shiftCycle);
                    await _context.SaveChangesAsync();
                    TempData["SuccessMessage"] = "Rotational shift cycle updated successfully!";
                }
                catch (DbUpdateConcurrencyException)
                {
                    if (!ShiftCycleExists(shiftCycle.CycleId))
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
            return View(shiftCycle);
        }

        // GET: RotationalShifts/Delete/5
        public async Task<IActionResult> Delete(int? id)
        {
            var userRoles = HttpContext.Session.GetString("UserRoles");
            if (string.IsNullOrEmpty(userRoles) || !userRoles.Contains("HR Administrator"))
            {
                return Forbid();
            }

            if (id == null)
            {
                return NotFound();
            }

            var shiftCycle = await _context.ShiftCycles
                .FirstOrDefaultAsync(m => m.CycleId == id);
            if (shiftCycle == null)
            {
                return NotFound();
            }

            return View(shiftCycle);
        }

        // POST: RotationalShifts/Delete/5
        [HttpPost, ActionName("Delete")]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> DeleteConfirmed(int id)
        {
            var userRoles = HttpContext.Session.GetString("UserRoles");
            if (string.IsNullOrEmpty(userRoles) || !userRoles.Contains("HR Administrator"))
            {
                return Forbid();
            }

            var shiftCycle = await _context.ShiftCycles.FindAsync(id);
            if (shiftCycle != null)
            {
                _context.ShiftCycles.Remove(shiftCycle);
            }

            await _context.SaveChangesAsync();
            TempData["SuccessMessage"] = "Rotational shift cycle deleted successfully!";
            return RedirectToAction(nameof(Index));
        }

        private bool ShiftCycleExists(int id)
        {
            return _context.ShiftCycles.Any(e => e.CycleId == id);
        }
    }
}
