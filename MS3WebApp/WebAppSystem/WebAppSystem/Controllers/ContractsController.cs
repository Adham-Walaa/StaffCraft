using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;
using Microsoft.EntityFrameworkCore;
using Microsoft.Data.SqlClient;
using System.Data;
using WebAppSystem.Models;
using SystemException = System.Exception;

namespace WebAppSystem.Controllers
{
    public class ContractsController : Controller
    {
        private readonly Milestone2Context _context;

        public ContractsController(Milestone2Context context)
        {
            _context = context;
        }

        // GET: Contracts
        public async Task<IActionResult> Index()
        {
            try
            {
                // Update expired contracts directly
                var expiredContracts = await _context.Contracts
                    .Where(c => c.CurrentState == "Active" && c.EndDate < DateTime.Today)
                    .ToListAsync();
                
                foreach (var contract in expiredContracts)
                {
                    contract.CurrentState = "Expired";
                }
                
                if (expiredContracts.Any())
                {
                    await _context.SaveChangesAsync();
                }
            }
            catch (SystemException)
            {
                // Continue even if update fails
            }

            var contracts = await _context.Contracts
                .Include(c => c.Employees)
                .ToListAsync();
            
            return View(contracts);
        }

        // GET: Contracts/Details/5
        public async Task<IActionResult> Details(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var contract = await _context.Contracts
                .Include(c => c.Employees)
                .FirstOrDefaultAsync(m => m.ContractId == id);
            if (contract == null)
            {
                return NotFound();
            }

            return View(contract);
        }

        // GET: Contracts/Create
        public IActionResult Create()
        {
            // Check if user is HR Administrator
            var userRoles = HttpContext.Session.GetString("UserRoles");
            if (string.IsNullOrEmpty(userRoles) || !userRoles.Contains("HR Administrator"))
            {
                TempData["ErrorMessage"] = "Access denied. Only HR Administrators can create contracts.";
                return RedirectToAction("Index", "Home");
            }

            ViewData["EmployeeId"] = new SelectList(_context.Employees
                .Where(e => e.ContractId == null || e.Contract.CurrentState != "Active")
                .Select(e => new { e.EmployeeId, e.FullName }), 
                "EmployeeId", "FullName");
            
            return View();
        }

        // POST: Contracts/Create
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Create(int employeeId, string type, DateTime startDate, DateTime endDate)
        {
            // Check if user is HR Administrator
            var userRoles = HttpContext.Session.GetString("UserRoles");
            if (string.IsNullOrEmpty(userRoles) || !userRoles.Contains("HR Administrator"))
            {
                TempData["ErrorMessage"] = "Access denied. Only HR Administrators can create contracts.";
                return RedirectToAction("Index", "Home");
            }

            try
            {
                // Use CreateContract stored procedure
                var parameters = new[]
                {
                    new SqlParameter("@EmployeeID", employeeId),
                    new SqlParameter("@Type", type),
                    new SqlParameter("@StartDate", startDate),
                    new SqlParameter("@EndDate", endDate)
                };

                await _context.Database.ExecuteSqlRawAsync(
                    "EXEC dbo.CreateContract @EmployeeID, @Type, @StartDate, @EndDate",
                    parameters
                );

                TempData["SuccessMessage"] = "Contract created successfully!";
                return RedirectToAction(nameof(Index));
            }
            catch (SystemException ex)
            {
                ModelState.AddModelError("", $"Error creating contract: {ex.Message}");
            }

            ViewData["EmployeeId"] = new SelectList(_context.Employees
                .Where(e => e.ContractId == null || e.Contract.CurrentState != "Active")
                .Select(e => new { e.EmployeeId, e.FullName }), 
                "EmployeeId", "FullName", employeeId);
            
            return View();
        }

        // GET: Contracts/Edit/5
        public async Task<IActionResult> Edit(int? id)
        {
            // Check if user is HR Administrator
            var userRoles = HttpContext.Session.GetString("UserRoles");
            if (string.IsNullOrEmpty(userRoles) || !userRoles.Contains("HR Administrator"))
            {
                TempData["ErrorMessage"] = "Access denied. Only HR Administrators can edit contracts.";
                return RedirectToAction("Index", "Home");
            }

            if (id == null)
            {
                return NotFound();
            }

            var contract = await _context.Contracts.FindAsync(id);
            if (contract == null)
            {
                return NotFound();
            }
            return View(contract);
        }

        // POST: Contracts/Edit/5
        // To protect from overposting attacks, enable the specific properties you want to bind to.
        // For more details, see http://go.microsoft.com/fwlink/?LinkId=317598.
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Edit(int id, [Bind("ContractId,Type,StartDate,EndDate,CurrentState")] Contract contract)
        {
            // Check if user is HR Administrator
            var userRoles = HttpContext.Session.GetString("UserRoles");
            if (string.IsNullOrEmpty(userRoles) || !userRoles.Contains("HR Administrator"))
            {
                TempData["ErrorMessage"] = "Access denied. Only HR Administrators can edit contracts.";
                return RedirectToAction("Index", "Home");
            }

            if (id != contract.ContractId)
            {
                return NotFound();
            }

            if (ModelState.IsValid)
            {
                try
                {
                    _context.Update(contract);
                    await _context.SaveChangesAsync();
                    TempData["SuccessMessage"] = "Contract updated successfully!";
                }
                catch (DbUpdateConcurrencyException)
                {
                    if (!ContractExists(contract.ContractId))
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
            return View(contract);
        }

        // GET: Contracts/Delete/5
        public async Task<IActionResult> Delete(int? id)
        {
            // Check if user is HR Administrator
            var userRoles = HttpContext.Session.GetString("UserRoles");
            if (string.IsNullOrEmpty(userRoles) || !userRoles.Contains("HR Administrator"))
            {
                TempData["ErrorMessage"] = "Access denied. Only HR Administrators can delete contracts.";
                return RedirectToAction("Index", "Home");
            }

            if (id == null)
            {
                return NotFound();
            }

            var contract = await _context.Contracts
                .FirstOrDefaultAsync(m => m.ContractId == id);
            if (contract == null)
            {
                return NotFound();
            }

            return View(contract);
        }

        // POST: Contracts/Delete/5
        [HttpPost, ActionName("Delete")]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> DeleteConfirmed(int id)
        {
            // Check if user is HR Administrator
            var userRoles = HttpContext.Session.GetString("UserRoles");
            if (string.IsNullOrEmpty(userRoles) || !userRoles.Contains("HR Administrator"))
            {
                TempData["ErrorMessage"] = "Access denied. Only HR Administrators can delete contracts.";
                return RedirectToAction("Index", "Home");
            }

            try
            {
                var contract = await _context.Contracts.FindAsync(id);
                if (contract != null)
                {
                    // Instead of deleting, terminate the contract to avoid foreign key constraint issues
                    contract.CurrentState = "Terminated";
                    
                    // Also nullify employee references if needed
                    var employeesWithContract = await _context.Employees
                        .Where(e => e.ContractId == id)
                        .ToListAsync();

                    foreach (var employee in employeesWithContract)
                    {
                        employee.ContractId = null;
                    }

                    await _context.SaveChangesAsync();
                    TempData["SuccessMessage"] = "Contract terminated successfully!";
                }
                else
                {
                    TempData["ErrorMessage"] = "Contract not found.";
                }
            }
            catch (SystemException ex)
            {
                TempData["ErrorMessage"] = $"Error terminating contract: {ex.Message}";
            }

            return RedirectToAction(nameof(Index));
        }

        private bool ContractExists(int id)
        {
            return _context.Contracts.Any(e => e.ContractId == id);
        }

        // GET: Contracts/RenewContract
        public async Task<IActionResult> RenewContract(int? id)
        {
            // Check if user is HR Administrator
            var userRoles = HttpContext.Session.GetString("UserRoles");
            if (string.IsNullOrEmpty(userRoles) || !userRoles.Contains("HR Administrator"))
            {
                TempData["ErrorMessage"] = "Access denied. Only HR Administrators can renew contracts.";
                return RedirectToAction("Index", "Home");
            }

            if (id == null)
            {
                return NotFound();
            }

            var contract = await _context.Contracts
                .Include(c => c.Employees)
                .FirstOrDefaultAsync(m => m.ContractId == id);

            if (contract == null)
            {
                return NotFound();
            }

            return View(contract);
        }

        // POST: Contracts/RenewContract
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> RenewContract(int id, DateTime newEndDate)
        {
            // Check if user is HR Administrator
            var userRoles = HttpContext.Session.GetString("UserRoles");
            if (string.IsNullOrEmpty(userRoles) || !userRoles.Contains("HR Administrator"))
            {
                TempData["ErrorMessage"] = "Access denied. Only HR Administrators can renew contracts.";
                return RedirectToAction("Index", "Home");
            }

            try
            {
                // Use RenewContract stored procedure
                var parameters = new[]
                {
                    new SqlParameter("@ContractID", id),
                    new SqlParameter("@EndDate", newEndDate)
                };

                await _context.Database.ExecuteSqlRawAsync(
                    "EXEC dbo.RenewContract @ContractID, @EndDate",
                    parameters
                );

                TempData["SuccessMessage"] = "Contract renewed successfully!";
                return RedirectToAction(nameof(Details), new { id });
            }
            catch (SystemException ex)
            {
                TempData["ErrorMessage"] = $"Error renewing contract: {ex.Message}";
                return RedirectToAction(nameof(RenewContract), new { id });
            }
        }

        // GET: Contracts/ActiveContracts
        public async Task<IActionResult> ActiveContracts()
        {
            // Check if user is HR Administrator
            var userRoles = HttpContext.Session.GetString("UserRoles");
            if (string.IsNullOrEmpty(userRoles) || !userRoles.Contains("HR Administrator"))
            {
                TempData["ErrorMessage"] = "Access denied. Only HR Administrators can view active contracts.";
                return RedirectToAction("Index", "Home");
            }

            try
            {
                // Update expired contracts directly
                var expiredContracts = await _context.Contracts
                    .Where(c => c.CurrentState == "Active" && c.EndDate < DateTime.Today)
                    .ToListAsync();
                
                foreach (var contract in expiredContracts)
                {
                    contract.CurrentState = "Expired";
                }
                
                if (expiredContracts.Any())
                {
                    await _context.SaveChangesAsync();
                }
                
                // Get active contracts
                var activeContracts = await _context.Contracts
                    .Where(c => c.CurrentState == "Active")
                    .AsNoTracking()
                    .ToListAsync();

                return View(activeContracts);
            }
            catch (SystemException ex)
            {
                TempData["ErrorMessage"] = $"Error retrieving active contracts: {ex.Message}";
                return RedirectToAction(nameof(Index));
            }
        }

        // GET: Contracts/ExpiringContracts
        public async Task<IActionResult> ExpiringContracts(int daysBefore = 30)
        {
            // Check if user is HR Administrator
            var userRoles = HttpContext.Session.GetString("UserRoles");
            if (string.IsNullOrEmpty(userRoles) || !userRoles.Contains("HR Administrator"))
            {
                TempData["ErrorMessage"] = "Access denied. Only HR Administrators can view expiring contracts.";
                return RedirectToAction("Index", "Home");
            }

            try
            {
                // Update expired contracts directly
                var expiredContracts = await _context.Contracts
                    .Where(c => c.CurrentState == "Active" && c.EndDate < DateTime.Today)
                    .ToListAsync();
                
                foreach (var contract in expiredContracts)
                {
                    contract.CurrentState = "Expired";
                }
                
                if (expiredContracts.Any())
                {
                    await _context.SaveChangesAsync();
                }
                
                // Get expiring contracts
                var targetDate = DateTime.Today.AddDays(daysBefore);
                var expiringContracts = await _context.Contracts
                    .Where(c => c.CurrentState == "Active" && 
                               c.EndDate >= DateTime.Today && 
                               c.EndDate <= targetDate)
                    .Include(c => c.Employees)
                    .ToListAsync();

                ViewBag.DaysBefore = daysBefore;
                return View(expiringContracts);
            }
            catch (SystemException ex)
            {
                TempData["ErrorMessage"] = $"Error retrieving expiring contracts: {ex.Message}";
                return RedirectToAction(nameof(Index));
            }
        }
    }

    // ViewModel for expiring contracts
    public class ExpiringContractViewModel
    {
        public int ContractID { get; set; }
        public int EmployeeID { get; set; }
        public string EmployeeName { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string ContractType { get; set; } = string.Empty;
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
        public int DaysUntilExpiry { get; set; }
        public string CurrentState { get; set; } = string.Empty;
    }
}
