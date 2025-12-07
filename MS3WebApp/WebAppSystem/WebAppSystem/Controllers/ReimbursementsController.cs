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
    public class ReimbursementsController : Controller
    {
        private readonly Milestone2Context _context;

        public ReimbursementsController(Milestone2Context context)
        {
            _context = context;
        }

        // GET: Reimbursements
        public async Task<IActionResult> Index()
        {
            var milestone2Context = _context.Reimbursements.Include(r => r.Employee);
            return View(await milestone2Context.ToListAsync());
        }

        // GET: Reimbursements/Details/5
        public async Task<IActionResult> Details(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var reimbursement = await _context.Reimbursements
                .Include(r => r.Employee)
                .FirstOrDefaultAsync(m => m.ReimbursementId == id);
            if (reimbursement == null)
            {
                return NotFound();
            }

            return View(reimbursement);
        }

        // GET: Reimbursements/Create
        public IActionResult Create()
        {
            ViewData["EmployeeId"] = new SelectList(_context.Employees, "EmployeeId", "EmployeeId");
            return View();
        }

        // POST: Reimbursements/Create
        // To protect from overposting attacks, enable the specific properties you want to bind to.
        // For more details, see http://go.microsoft.com/fwlink/?LinkId=317598.
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Create([Bind("ReimbursementId,Type,ClaimType,ApprovalDate,CurrentStatus,EmployeeId")] Reimbursement reimbursement)
        {
            if (ModelState.IsValid)
            {
                _context.Add(reimbursement);
                await _context.SaveChangesAsync();
                return RedirectToAction(nameof(Index));
            }
            ViewData["EmployeeId"] = new SelectList(_context.Employees, "EmployeeId", "EmployeeId", reimbursement.EmployeeId);
            return View(reimbursement);
        }

        // GET: Reimbursements/Edit/5
        public async Task<IActionResult> Edit(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var reimbursement = await _context.Reimbursements.FindAsync(id);
            if (reimbursement == null)
            {
                return NotFound();
            }
            ViewData["EmployeeId"] = new SelectList(_context.Employees, "EmployeeId", "EmployeeId", reimbursement.EmployeeId);
            return View(reimbursement);
        }

        // POST: Reimbursements/Edit/5
        // To protect from overposting attacks, enable the specific properties you want to bind to.
        // For more details, see http://go.microsoft.com/fwlink/?LinkId=317598.
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Edit(int id, [Bind("ReimbursementId,Type,ClaimType,ApprovalDate,CurrentStatus,EmployeeId")] Reimbursement reimbursement)
        {
            if (id != reimbursement.ReimbursementId)
            {
                return NotFound();
            }

            if (ModelState.IsValid)
            {
                try
                {
                    _context.Update(reimbursement);
                    await _context.SaveChangesAsync();
                }
                catch (DbUpdateConcurrencyException)
                {
                    if (!ReimbursementExists(reimbursement.ReimbursementId))
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
            ViewData["EmployeeId"] = new SelectList(_context.Employees, "EmployeeId", "EmployeeId", reimbursement.EmployeeId);
            return View(reimbursement);
        }

        // GET: Reimbursements/Delete/5
        public async Task<IActionResult> Delete(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var reimbursement = await _context.Reimbursements
                .Include(r => r.Employee)
                .FirstOrDefaultAsync(m => m.ReimbursementId == id);
            if (reimbursement == null)
            {
                return NotFound();
            }

            return View(reimbursement);
        }

        // POST: Reimbursements/Delete/5
        [HttpPost, ActionName("Delete")]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> DeleteConfirmed(int id)
        {
            var reimbursement = await _context.Reimbursements.FindAsync(id);
            if (reimbursement != null)
            {
                _context.Reimbursements.Remove(reimbursement);
            }

            await _context.SaveChangesAsync();
            return RedirectToAction(nameof(Index));
        }

        private bool ReimbursementExists(int id)
        {
            return _context.Reimbursements.Any(e => e.ReimbursementId == id);
        }
    }
}
