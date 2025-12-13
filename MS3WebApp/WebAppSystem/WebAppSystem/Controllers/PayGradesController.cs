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
    public class PayGradesController : Controller
    {
        private readonly Milestone2Context _context;

        public PayGradesController(Milestone2Context context)
        {
            _context = context;
        }

        // GET: PayGrades
        public async Task<IActionResult> Index()
        {
            return View(await _context.PayGrades.ToListAsync());
        }

        // GET: PayGrades/Details/5
        public async Task<IActionResult> Details(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var payGrade = await _context.PayGrades
                .FirstOrDefaultAsync(m => m.PayGradeId == id);
            if (payGrade == null)
            {
                return NotFound();
            }

            return View(payGrade);
        }

        // GET: PayGrades/Create
        public IActionResult Create()
        {
            return View();
        }

        // POST: PayGrades/Create
        // To protect from overposting attacks, enable the specific properties you want to bind to.
        // For more details, see http://go.microsoft.com/fwlink/?LinkId=317598.
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Create([Bind("GradeName,MinSalary,MaxSalary")] PayGrade payGrade, int? returnToEmployeeId, string returnToAction)
        {
            if (ModelState.IsValid)
            {
                _context.Add(payGrade);
                await _context.SaveChangesAsync();
                TempData["SuccessMessage"] = "Pay Grade created successfully!";
                
                // If we came from employee management, redirect back
                if (returnToEmployeeId.HasValue && !string.IsNullOrEmpty(returnToAction))
                {
                    return RedirectToAction(returnToAction, "Employees", new { id = returnToEmployeeId.Value });
                }
                
                return RedirectToAction(nameof(Index));
            }
            return View(payGrade);
        }

        // GET: PayGrades/Edit/5
        public async Task<IActionResult> Edit(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var payGrade = await _context.PayGrades.FindAsync(id);
            if (payGrade == null)
            {
                return NotFound();
            }
            return View(payGrade);
        }

        // POST: PayGrades/Edit/5
        // To protect from overposting attacks, enable the specific properties you want to bind to.
        // For more details, see http://go.microsoft.com/fwlink/?LinkId=317598.
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Edit(int id, [Bind("PayGradeId,GradeName,MinSalary,MaxSalary")] PayGrade payGrade)
        {
            if (id != payGrade.PayGradeId)
            {
                return NotFound();
            }

            if (ModelState.IsValid)
            {
                try
                {
                    _context.Update(payGrade);
                    await _context.SaveChangesAsync();
                }
                catch (DbUpdateConcurrencyException)
                {
                    if (!PayGradeExists(payGrade.PayGradeId))
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
            return View(payGrade);
        }

        // GET: PayGrades/Delete/5
        public async Task<IActionResult> Delete(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var payGrade = await _context.PayGrades
                .FirstOrDefaultAsync(m => m.PayGradeId == id);
            if (payGrade == null)
            {
                return NotFound();
            }

            return View(payGrade);
        }

        // POST: PayGrades/Delete/5
        [HttpPost, ActionName("Delete")]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> DeleteConfirmed(int id)
        {
            try
            {
                var payGrade = await _context.PayGrades.FindAsync(id);
                if (payGrade != null)
                {
                    _context.PayGrades.Remove(payGrade);
                    await _context.SaveChangesAsync();
                    TempData["SuccessMessage"] = "Pay Grade deleted successfully!";
                }
                return RedirectToAction(nameof(Index));
            }
            catch (DbUpdateException)
            {
                TempData["ErrorMessage"] = "Cannot delete this pay grade because it is assigned to one or more employees. Please reassign those employees first.";
                return RedirectToAction(nameof(Index));
            }
        }

        private bool PayGradeExists(int id)
        {
            return _context.PayGrades.Any(e => e.PayGradeId == id);
        }
    }
}
