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
    public class SalaryTypesController : Controller
    {
        private readonly Milestone2Context _context;

        public SalaryTypesController(Milestone2Context context)
        {
            _context = context;
        }

        // GET: SalaryTypes
        public async Task<IActionResult> Index()
        {
            return View(await _context.SalaryTypes.ToListAsync());
        }

        // GET: SalaryTypes/Details/5
        public async Task<IActionResult> Details(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var salaryType = await _context.SalaryTypes
                .FirstOrDefaultAsync(m => m.SalaryTypeId == id);
            if (salaryType == null)
            {
                return NotFound();
            }

            return View(salaryType);
        }

        // GET: SalaryTypes/Create
        public IActionResult Create()
        {
            return View();
        }

        // POST: SalaryTypes/Create
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Create([Bind("SalaryTypeId,Type,PaymentFrequency,Currency")] SalaryType salaryType)
        {
            if (ModelState.IsValid)
            {
                _context.Add(salaryType);
                await _context.SaveChangesAsync();
                TempData["SuccessMessage"] = "Salary Type created successfully!";
                return RedirectToAction(nameof(Index));
            }
            return View(salaryType);
        }

        // GET: SalaryTypes/Edit/5
        public async Task<IActionResult> Edit(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var salaryType = await _context.SalaryTypes.FindAsync(id);
            if (salaryType == null)
            {
                return NotFound();
            }
            return View(salaryType);
        }

        // POST: SalaryTypes/Edit/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Edit(int id, [Bind("SalaryTypeId,Type,PaymentFrequency,Currency")] SalaryType salaryType)
        {
            if (id != salaryType.SalaryTypeId)
            {
                return NotFound();
            }

            if (ModelState.IsValid)
            {
                try
                {
                    _context.Update(salaryType);
                    await _context.SaveChangesAsync();
                    TempData["SuccessMessage"] = "Salary Type updated successfully!";
                }
                catch (DbUpdateConcurrencyException)
                {
                    if (!SalaryTypeExists(salaryType.SalaryTypeId))
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
            return View(salaryType);
        }

        // GET: SalaryTypes/Delete/5
        public async Task<IActionResult> Delete(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var salaryType = await _context.SalaryTypes
                .FirstOrDefaultAsync(m => m.SalaryTypeId == id);
            if (salaryType == null)
            {
                return NotFound();
            }

            return View(salaryType);
        }

        // POST: SalaryTypes/Delete/5
        [HttpPost, ActionName("Delete")]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> DeleteConfirmed(int id)
        {
            var salaryType = await _context.SalaryTypes.FindAsync(id);
            if (salaryType != null)
            {
                _context.SalaryTypes.Remove(salaryType);
            }

            await _context.SaveChangesAsync();
            TempData["SuccessMessage"] = "Salary Type deleted successfully!";
            return RedirectToAction(nameof(Index));
        }

        private bool SalaryTypeExists(int id)
        {
            return _context.SalaryTypes.Any(e => e.SalaryTypeId == id);
        }
    }
}
