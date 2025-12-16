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
    public class LeavePoliciesController : Controller
    {
        private readonly Milestone2Context _context;

        public LeavePoliciesController(Milestone2Context context)
        {
            _context = context;
        }

        // GET: LeavePolicies
        public async Task<IActionResult> Index()
        {
            var userRoles = HttpContext.Session.GetString("UserRoles");
            if (string.IsNullOrEmpty(userRoles) || !userRoles.Contains("HR Administrator"))
            {
                TempData["ErrorMessage"] = "Access denied. Only HR Administrators can manage leave policies and eligibility rules.";
                return RedirectToAction("Index", "Home");
            }

            return View(await _context.LeavePolicies.ToListAsync());
        }

        // GET: LeavePolicies/Details/5
        public async Task<IActionResult> Details(int? id)
        {
            var userRoles = HttpContext.Session.GetString("UserRoles");
            if (string.IsNullOrEmpty(userRoles) || !userRoles.Contains("HR Administrator"))
            {
                TempData["ErrorMessage"] = "Access denied.";
                return RedirectToAction("Index", "Home");
            }

            if (id == null)
            {
                return NotFound();
            }

            var leavePolicy = await _context.LeavePolicies
                .FirstOrDefaultAsync(m => m.PolicyId == id);
            if (leavePolicy == null)
            {
                return NotFound();
            }

            return View(leavePolicy);
        }

        // GET: LeavePolicies/Create
        public IActionResult Create()
        {
            var userRoles = HttpContext.Session.GetString("UserRoles");
            if (string.IsNullOrEmpty(userRoles) || !userRoles.Contains("HR Administrator"))
            {
                TempData["ErrorMessage"] = "Access denied.";
                return RedirectToAction("Index", "Home");
            }

            return View();
        }

        // POST: LeavePolicies/Create
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Create([Bind("PolicyId,Name,Purpose,EligibilityRules,NoticePeriod,SpecialLeaveType,ResetOnNewYear")] LeavePolicy leavePolicy)
        {
            var userRoles = HttpContext.Session.GetString("UserRoles");
            if (string.IsNullOrEmpty(userRoles) || !userRoles.Contains("HR Administrator"))
            {
                TempData["ErrorMessage"] = "Access denied.";
                return RedirectToAction("Index", "Home");
            }

            if (ModelState.IsValid)
            {
                _context.Add(leavePolicy);
                await _context.SaveChangesAsync();
                TempData["SuccessMessage"] = "Leave policy created successfully!";
                return RedirectToAction(nameof(Index));
            }
            return View(leavePolicy);
        }

        // GET: LeavePolicies/Edit/5
        public async Task<IActionResult> Edit(int? id)
        {
            var userRoles = HttpContext.Session.GetString("UserRoles");
            if (string.IsNullOrEmpty(userRoles) || !userRoles.Contains("HR Administrator"))
            {
                TempData["ErrorMessage"] = "Access denied.";
                return RedirectToAction("Index", "Home");
            }

            if (id == null)
            {
                return NotFound();
            }

            var leavePolicy = await _context.LeavePolicies.FindAsync(id);
            if (leavePolicy == null)
            {
                return NotFound();
            }
            return View(leavePolicy);
        }

        // POST: LeavePolicies/Edit/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Edit(int id, [Bind("PolicyId,Name,Purpose,EligibilityRules,NoticePeriod,SpecialLeaveType,ResetOnNewYear")] LeavePolicy leavePolicy)
        {
            var userRoles = HttpContext.Session.GetString("UserRoles");
            if (string.IsNullOrEmpty(userRoles) || !userRoles.Contains("HR Administrator"))
            {
                TempData["ErrorMessage"] = "Access denied.";
                return RedirectToAction("Index", "Home");
            }

            if (id != leavePolicy.PolicyId)
            {
                return NotFound();
            }

            if (ModelState.IsValid)
            {
                try
                {
                    _context.Update(leavePolicy);
                    await _context.SaveChangesAsync();
                    TempData["SuccessMessage"] = "Leave policy updated successfully!";
                }
                catch (DbUpdateConcurrencyException)
                {
                    if (!LeavePolicyExists(leavePolicy.PolicyId))
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
            return View(leavePolicy);
        }

        // GET: LeavePolicies/Delete/5
        public async Task<IActionResult> Delete(int? id)
        {
            var userRoles = HttpContext.Session.GetString("UserRoles");
            if (string.IsNullOrEmpty(userRoles) || !userRoles.Contains("HR Administrator"))
            {
                TempData["ErrorMessage"] = "Access denied.";
                return RedirectToAction("Index", "Home");
            }

            if (id == null)
            {
                return NotFound();
            }

            var leavePolicy = await _context.LeavePolicies
                .FirstOrDefaultAsync(m => m.PolicyId == id);
            if (leavePolicy == null)
            {
                return NotFound();
            }

            return View(leavePolicy);
        }

        // POST: LeavePolicies/Delete/5
        [HttpPost, ActionName("Delete")]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> DeleteConfirmed(int id)
        {
            var userRoles = HttpContext.Session.GetString("UserRoles");
            if (string.IsNullOrEmpty(userRoles) || !userRoles.Contains("HR Administrator"))
            {
                TempData["ErrorMessage"] = "Access denied.";
                return RedirectToAction("Index", "Home");
            }

            var leavePolicy = await _context.LeavePolicies.FindAsync(id);
            if (leavePolicy != null)
            {
                _context.LeavePolicies.Remove(leavePolicy);
            }

            await _context.SaveChangesAsync();
            TempData["SuccessMessage"] = "Leave policy deleted successfully!";
            return RedirectToAction(nameof(Index));
        }

        private bool LeavePolicyExists(int id)
        {
            return _context.LeavePolicies.Any(e => e.PolicyId == id);
        }
    }
}
