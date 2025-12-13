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
    public class TaxFormsController : Controller
    {
        private readonly Milestone2Context _context;

        public TaxFormsController(Milestone2Context context)
        {
            _context = context;
        }

        // GET: TaxForms
        public async Task<IActionResult> Index()
        {
            return View(await _context.TaxForms.ToListAsync());
        }

        // GET: TaxForms/Details/5
        public async Task<IActionResult> Details(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var taxForm = await _context.TaxForms
                .FirstOrDefaultAsync(m => m.TaxFormId == id);
            if (taxForm == null)
            {
                return NotFound();
            }

            // Get employees with this tax form
            var employees = await _context.Employees
                .Where(e => e.TaxformId == id)
                .Select(e => new { e.EmployeeId, e.FullName, e.Email })
                .ToListAsync();

            ViewBag.AssignedEmployees = employees;

            return View(taxForm);
        }

        // GET: TaxForms/Create
        public IActionResult Create()
        {
            return View();
        }

        // POST: TaxForms/Create
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Create([Bind("Jurisdiction,ValidityPeriod,FormContent")] TaxForm taxForm, int? returnToEmployeeId, string returnToAction)
        {
            // Validate that ValidityPeriod is not in the past
            if (taxForm.ValidityPeriod.HasValue && taxForm.ValidityPeriod.Value < DateTime.Today)
            {
                ModelState.AddModelError("ValidityPeriod", "Validity period cannot be in the past.");
            }
            
            if (ModelState.IsValid)
            {
                _context.Add(taxForm);
                await _context.SaveChangesAsync();
                TempData["SuccessMessage"] = "Tax Form created successfully!";
                
                // If we came from employee management, redirect back
                if (returnToEmployeeId.HasValue && !string.IsNullOrEmpty(returnToAction))
                {
                    return RedirectToAction(returnToAction, "Employees", new { id = returnToEmployeeId.Value });
                }
                
                return RedirectToAction(nameof(Index));
            }
            return View(taxForm);
        }

        // GET: TaxForms/Edit/5
        public async Task<IActionResult> Edit(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var taxForm = await _context.TaxForms.FindAsync(id);
            if (taxForm == null)
            {
                return NotFound();
            }
            return View(taxForm);
        }

        // POST: TaxForms/Edit/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Edit(int id, [Bind("TaxFormId,Jurisdiction,ValidityPeriod,FormContent")] TaxForm taxForm)
        {
            if (id != taxForm.TaxFormId)
            {
                return NotFound();
            }

            // Validate that ValidityPeriod is not in the past
            if (taxForm.ValidityPeriod.HasValue && taxForm.ValidityPeriod.Value < DateTime.Today)
            {
                ModelState.AddModelError("ValidityPeriod", "Validity period cannot be in the past.");
            }

            if (ModelState.IsValid)
            {
                try
                {
                    _context.Update(taxForm);
                    await _context.SaveChangesAsync();
                    TempData["SuccessMessage"] = "Tax Form updated successfully!";
                }
                catch (DbUpdateConcurrencyException)
                {
                    if (!TaxFormExists(taxForm.TaxFormId))
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
            return View(taxForm);
        }

        // GET: TaxForms/Delete/5
        public async Task<IActionResult> Delete(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var taxForm = await _context.TaxForms
                .FirstOrDefaultAsync(m => m.TaxFormId == id);
            if (taxForm == null)
            {
                return NotFound();
            }

            return View(taxForm);
        }

        // POST: TaxForms/Delete/5
        [HttpPost, ActionName("Delete")]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> DeleteConfirmed(int id)
        {
            try
            {
                var taxForm = await _context.TaxForms.FindAsync(id);
                if (taxForm != null)
                {
                    _context.TaxForms.Remove(taxForm);
                    await _context.SaveChangesAsync();
                    TempData["SuccessMessage"] = "Tax Form deleted successfully!";
                }
                return RedirectToAction(nameof(Index));
            }
            catch (DbUpdateException)
            {
                TempData["ErrorMessage"] = "Cannot delete this tax form because it is assigned to one or more employees. Please reassign those employees first.";
                return RedirectToAction(nameof(Index));
            }
        }

        private bool TaxFormExists(int id)
        {
            return _context.TaxForms.Any(e => e.TaxFormId == id);
        }
    }
}
