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
    public class SplitShiftsController : Controller
    {
        private readonly Milestone2Context _context;

        public SplitShiftsController(Milestone2Context context)
        {
            _context = context;
        }

        // GET: SplitShifts
        public async Task<IActionResult> Index()
        {
            var userRoles = HttpContext.Session.GetString("UserRoles");
            if (string.IsNullOrEmpty(userRoles) || 
                (!userRoles.Contains("System Administrator") && !userRoles.Contains("HR Administrator")))
            {
                return Forbid();
            }

            return View(await _context.SplitShiftConfigurations.ToListAsync());
        }

        // GET: SplitShifts/Details/5
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

            var splitShiftConfiguration = await _context.SplitShiftConfigurations
                .FirstOrDefaultAsync(m => m.ConfigId == id);
            if (splitShiftConfiguration == null)
            {
                return NotFound();
            }

            return View(splitShiftConfiguration);
        }

        // GET: SplitShifts/Create
        public IActionResult Create()
        {
            var userRoles = HttpContext.Session.GetString("UserRoles");
            if (string.IsNullOrEmpty(userRoles) || !userRoles.Contains("HR Administrator"))
            {
                return Forbid();
            }

            return View();
        }

        // POST: SplitShifts/Create
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Create([Bind("ConfigId,ShiftName,FirstSlotStart,FirstSlotEnd,SecondSlotStart,SecondSlotEnd,TotalHours,BreakDurationMinutes,IsActive")] SplitShiftConfiguration splitShiftConfiguration)
        {
            var userRoles = HttpContext.Session.GetString("UserRoles");
            if (string.IsNullOrEmpty(userRoles) || !userRoles.Contains("HR Administrator"))
            {
                return Forbid();
            }

            // Generate new ConfigId
            var maxConfigId = _context.SplitShiftConfigurations.Any() 
                ? await _context.SplitShiftConfigurations.MaxAsync(s => s.ConfigId) 
                : 0;
            splitShiftConfiguration.ConfigId = maxConfigId + 1;
            
            // Calculate total hours using helper method
            splitShiftConfiguration.TotalHours = CalculateTotalHours(
                splitShiftConfiguration.FirstSlotStart,
                splitShiftConfiguration.FirstSlotEnd,
                splitShiftConfiguration.SecondSlotStart,
                splitShiftConfiguration.SecondSlotEnd
            );
            splitShiftConfiguration.CreatedDate = DateTime.Now;

            if (ModelState.IsValid)
            {
                _context.Add(splitShiftConfiguration);
                await _context.SaveChangesAsync();
                TempData["SuccessMessage"] = "Split shift configuration created successfully!";
                return RedirectToAction(nameof(Index));
            }
            return View(splitShiftConfiguration);
        }

        // GET: SplitShifts/Edit/5
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

            var splitShiftConfiguration = await _context.SplitShiftConfigurations.FindAsync(id);
            if (splitShiftConfiguration == null)
            {
                return NotFound();
            }
            return View(splitShiftConfiguration);
        }

        // POST: SplitShifts/Edit/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Edit(int id, [Bind("ConfigId,ShiftName,FirstSlotStart,FirstSlotEnd,SecondSlotStart,SecondSlotEnd,TotalHours,BreakDurationMinutes,CreatedDate,IsActive")] SplitShiftConfiguration splitShiftConfiguration)
        {
            var userRoles = HttpContext.Session.GetString("UserRoles");
            if (string.IsNullOrEmpty(userRoles) || !userRoles.Contains("HR Administrator"))
            {
                return Forbid();
            }

            if (id != splitShiftConfiguration.ConfigId)
            {
                return NotFound();
            }

            // Recalculate total hours using helper method
            splitShiftConfiguration.TotalHours = CalculateTotalHours(
                splitShiftConfiguration.FirstSlotStart,
                splitShiftConfiguration.FirstSlotEnd,
                splitShiftConfiguration.SecondSlotStart,
                splitShiftConfiguration.SecondSlotEnd
            );

            if (ModelState.IsValid)
            {
                try
                {
                    _context.Update(splitShiftConfiguration);
                    await _context.SaveChangesAsync();
                    TempData["SuccessMessage"] = "Split shift configuration updated successfully!";
                }
                catch (DbUpdateConcurrencyException)
                {
                    if (!SplitShiftConfigurationExists(splitShiftConfiguration.ConfigId))
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
            return View(splitShiftConfiguration);
        }

        // GET: SplitShifts/Delete/5
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

            var splitShiftConfiguration = await _context.SplitShiftConfigurations
                .FirstOrDefaultAsync(m => m.ConfigId == id);
            if (splitShiftConfiguration == null)
            {
                return NotFound();
            }

            return View(splitShiftConfiguration);
        }

        // POST: SplitShifts/Delete/5
        [HttpPost, ActionName("Delete")]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> DeleteConfirmed(int id)
        {
            var userRoles = HttpContext.Session.GetString("UserRoles");
            if (string.IsNullOrEmpty(userRoles) || !userRoles.Contains("HR Administrator"))
            {
                return Forbid();
            }

            var splitShiftConfiguration = await _context.SplitShiftConfigurations.FindAsync(id);
            if (splitShiftConfiguration != null)
            {
                _context.SplitShiftConfigurations.Remove(splitShiftConfiguration);
            }

            await _context.SaveChangesAsync();
            TempData["SuccessMessage"] = "Split shift configuration deleted successfully!";
            return RedirectToAction(nameof(Index));
        }

        private bool SplitShiftConfigurationExists(int id)
        {
            return _context.SplitShiftConfigurations.Any(e => e.ConfigId == id);
        }

        // Helper method to calculate duration in minutes between two times
        private int CalculateDurationInMinutes(TimeOnly start, TimeOnly end)
        {
            return (end.Hour * 60 + end.Minute) - (start.Hour * 60 + start.Minute);
        }

        // Helper method to calculate total hours for split shift
        private decimal CalculateTotalHours(TimeOnly firstStart, TimeOnly firstEnd, TimeOnly secondStart, TimeOnly secondEnd)
        {
            var firstSlotMinutes = CalculateDurationInMinutes(firstStart, firstEnd);
            var secondSlotMinutes = CalculateDurationInMinutes(secondStart, secondEnd);
            return (firstSlotMinutes + secondSlotMinutes) / 60.0m;
        }
    }
}
