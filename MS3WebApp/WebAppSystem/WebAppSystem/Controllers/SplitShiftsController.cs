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

            // Calculate total hours
            var firstSlotMinutes = (splitShiftConfiguration.FirstSlotEnd.Hour * 60 + splitShiftConfiguration.FirstSlotEnd.Minute) - 
                                  (splitShiftConfiguration.FirstSlotStart.Hour * 60 + splitShiftConfiguration.FirstSlotStart.Minute);
            var secondSlotMinutes = (splitShiftConfiguration.SecondSlotEnd.Hour * 60 + splitShiftConfiguration.SecondSlotEnd.Minute) - 
                                   (splitShiftConfiguration.SecondSlotStart.Hour * 60 + splitShiftConfiguration.SecondSlotStart.Minute);
            
            splitShiftConfiguration.TotalHours = (firstSlotMinutes + secondSlotMinutes) / 60.0m;
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

            // Recalculate total hours
            var firstSlotMinutes = (splitShiftConfiguration.FirstSlotEnd.Hour * 60 + splitShiftConfiguration.FirstSlotEnd.Minute) - 
                                  (splitShiftConfiguration.FirstSlotStart.Hour * 60 + splitShiftConfiguration.FirstSlotStart.Minute);
            var secondSlotMinutes = (splitShiftConfiguration.SecondSlotEnd.Hour * 60 + splitShiftConfiguration.SecondSlotEnd.Minute) - 
                                   (splitShiftConfiguration.SecondSlotStart.Hour * 60 + splitShiftConfiguration.SecondSlotStart.Minute);
            
            splitShiftConfiguration.TotalHours = (firstSlotMinutes + secondSlotMinutes) / 60.0m;

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
    }
}
