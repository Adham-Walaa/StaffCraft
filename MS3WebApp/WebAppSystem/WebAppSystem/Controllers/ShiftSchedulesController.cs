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
            var userRoles = HttpContext.Session.GetString("UserRoles");
            if (string.IsNullOrEmpty(userRoles) || 
                (!userRoles.Contains("System Administrator") && !userRoles.Contains("Manager")))
            {
                ViewBag.Message = "You do not have permission to perform this action.";
                ViewBag.AllowedRoles = "This action can only be performed by: System Administrator or Manager";
                return View("~/Views/Shared/AccessDenied.cshtml");
            }

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
            var userRoles = HttpContext.Session.GetString("UserRoles");
            if (string.IsNullOrEmpty(userRoles) || 
                (!userRoles.Contains("System Administrator") && !userRoles.Contains("Manager")))
            {
                ViewBag.Message = "You do not have permission to perform this action.";
                ViewBag.AllowedRoles = "This action can only be performed by: System Administrator or Manager";
                return View("~/Views/Shared/AccessDenied.cshtml");
            }

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
            var userRoles = HttpContext.Session.GetString("UserRoles");
            if (string.IsNullOrEmpty(userRoles) || !userRoles.Contains("System Administrator"))
            {
                ViewBag.Message = "You do not have permission to perform this action.";
                ViewBag.AllowedRoles = "This action can only be performed by: System Administrator";
                return View("~/Views/Shared/AccessDenied.cshtml");
            }

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
            var userRoles = HttpContext.Session.GetString("UserRoles");
            if (string.IsNullOrEmpty(userRoles) || !userRoles.Contains("System Administrator"))
            {
                ViewBag.Message = "You do not have permission to perform this action.";
                ViewBag.AllowedRoles = "This action can only be performed by: System Administrator";
                return View("~/Views/Shared/AccessDenied.cshtml");
            }

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

        // GET: ShiftSchedules/CreateShiftType
        // System Admin creates shift types
        public IActionResult CreateShiftType()
        {
            var userRoles = HttpContext.Session.GetString("UserRoles");
            if (string.IsNullOrEmpty(userRoles) || !userRoles.Contains("System Administrator"))
            {
                ViewBag.Message = "You do not have permission to perform this action.";
                ViewBag.AllowedRoles = "This action can only be performed by: System Administrator";
                return View("~/Views/Shared/AccessDenied.cshtml");
            }
            
            return View();
        }

        // POST: ShiftSchedules/CreateShiftType
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> CreateShiftType([Bind("ShiftType,ShiftName,StartTime,EndTime,Description")] ShiftTypeViewModel model)
        {
            var userRoles = HttpContext.Session.GetString("UserRoles");
            if (string.IsNullOrEmpty(userRoles) || !userRoles.Contains("System Administrator"))
            {
                ViewBag.Message = "You do not have permission to perform this action.";
                ViewBag.AllowedRoles = "This action can only be performed by: System Administrator";
                return View("~/Views/Shared/AccessDenied.cshtml");
            }

            if (ModelState.IsValid)
            {
                // Generate new ShiftId
                var maxShiftId = await _context.ShiftSchedules.MaxAsync(s => (int?)s.ShiftId) ?? 0;
                
                // Create a template shift schedule (not assigned to any employee yet)
                var shiftSchedule = new ShiftSchedule
                {
                    ShiftId = maxShiftId + 1,
                    ShiftName = model.ShiftName,
                    ShiftType = model.ShiftType,
                    StartTime = model.StartTime,
                    EndTime = model.EndTime,
                    Status = "Template"
                };

                _context.Add(shiftSchedule);
                await _context.SaveChangesAsync();
                
                TempData["SuccessMessage"] = "Shift type created successfully!";
                return RedirectToAction(nameof(Index));
            }
            
            return View(model);
        }

        // GET: ShiftSchedules/AssignToEmployee
        // System Admin or Manager assigns shift to employee
        public IActionResult AssignToEmployee()
        {
            var userRoles = HttpContext.Session.GetString("UserRoles");
            if (string.IsNullOrEmpty(userRoles) || 
                (!userRoles.Contains("System Administrator") && !userRoles.Contains("Manager")))
            {
                ViewBag.Message = "You do not have permission to perform this action.";
                ViewBag.AllowedRoles = "This action can only be performed by: System Administrator or Manager";
                return View("~/Views/Shared/AccessDenied.cshtml");
            }

            ViewData["EmployeeId"] = new SelectList(_context.Employees, "EmployeeId", "FullName");
            ViewData["ShiftTemplates"] = _context.ShiftSchedules
                .Where(s => s.Status == "Template")
                .Select(s => new { s.ShiftId, Display = $"{s.ShiftName} ({s.ShiftType})" })
                .ToList();
            
            return View();
        }

        // POST: ShiftSchedules/AssignToEmployee
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> AssignToEmployee([Bind("ShiftId,EmployeeId,StartDate,EndDate,ShiftName,ShiftType,StartTime,EndTime")] ShiftAssignmentViewModel model)
        {
            var userRoles = HttpContext.Session.GetString("UserRoles");
            if (string.IsNullOrEmpty(userRoles) || 
                (!userRoles.Contains("System Administrator") && !userRoles.Contains("Manager")))
            {
                ViewBag.Message = "You do not have permission to perform this action.";
                ViewBag.AllowedRoles = "This action can only be performed by: System Administrator or Manager";
                return View("~/Views/Shared/AccessDenied.cshtml");
            }

            if (ModelState.IsValid && model.EmployeeId.HasValue)
            {
                // Get template shift if ShiftId is provided
                ShiftSchedule? template = null;
                if (model.ShiftId.HasValue && model.ShiftId.Value > 0)
                {
                    template = await _context.ShiftSchedules.FindAsync(model.ShiftId.Value);
                }

                // Generate new ShiftId
                var maxShiftId = await _context.ShiftSchedules.MaxAsync(s => (int?)s.ShiftId) ?? 0;
                
                var shiftSchedule = new ShiftSchedule
                {
                    ShiftId = maxShiftId + 1,
                    EmployeeId = model.EmployeeId.Value,
                    ShiftName = template?.ShiftName ?? model.ShiftName,
                    ShiftType = template?.ShiftType ?? model.ShiftType,
                    StartTime = template?.StartTime ?? model.StartTime,
                    EndTime = template?.EndTime ?? model.EndTime,
                    StartDate = model.StartDate,
                    EndDate = model.EndDate,
                    Status = "Active"
                };

                _context.Add(shiftSchedule);
                await _context.SaveChangesAsync();
                
                TempData["SuccessMessage"] = "Shift assigned to employee successfully!";
                return RedirectToAction(nameof(Index));
            }

            ViewData["EmployeeId"] = new SelectList(_context.Employees, "EmployeeId", "FullName", model.EmployeeId);
            ViewData["ShiftTemplates"] = _context.ShiftSchedules
                .Where(s => s.Status == "Template")
                .Select(s => new { s.ShiftId, Display = $"{s.ShiftName} ({s.ShiftType})" })
                .ToList();
            
            return View(model);
        }

        // GET: ShiftSchedules/AssignToDepartment
        // System Admin or Manager assigns shift to department
        public IActionResult AssignToDepartment()
        {
            var userRoles = HttpContext.Session.GetString("UserRoles");
            if (string.IsNullOrEmpty(userRoles) || 
                (!userRoles.Contains("System Administrator") && !userRoles.Contains("Manager")))
            {
                ViewBag.Message = "You do not have permission to perform this action.";
                ViewBag.AllowedRoles = "This action can only be performed by: System Administrator or Manager";
                return View("~/Views/Shared/AccessDenied.cshtml");
            }

            ViewData["DepartmentId"] = new SelectList(_context.Departments, "DepartmentId", "DepartmentName");
            ViewData["ShiftTemplates"] = _context.ShiftSchedules
                .Where(s => s.Status == "Template")
                .Select(s => new { s.ShiftId, Display = $"{s.ShiftName} ({s.ShiftType})" })
                .ToList();
            
            return View();
        }

        // POST: ShiftSchedules/AssignToDepartment
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> AssignToDepartment([Bind("ShiftId,DepartmentId,StartDate,EndDate")] ShiftAssignmentViewModel model)
        {
            var userRoles = HttpContext.Session.GetString("UserRoles");
            if (string.IsNullOrEmpty(userRoles) || 
                (!userRoles.Contains("System Administrator") && !userRoles.Contains("Manager")))
            {
                ViewBag.Message = "You do not have permission to perform this action.";
                ViewBag.AllowedRoles = "This action can only be performed by: System Administrator or Manager";
                return View("~/Views/Shared/AccessDenied.cshtml");
            }

            // Validate inputs
            if (!model.DepartmentId.HasValue || model.DepartmentId.Value == 0)
            {
                ModelState.AddModelError("DepartmentId", "Please select a department.");
            }
            
            if (!model.ShiftId.HasValue || model.ShiftId.Value == 0)
            {
                ModelState.AddModelError("ShiftId", "Please select a shift template.");
            }
            
            if (ModelState.IsValid && model.DepartmentId.HasValue && model.DepartmentId.Value > 0 && model.ShiftId.HasValue && model.ShiftId.Value > 0)
            {
                // Get template shift
                var template = await _context.ShiftSchedules.FindAsync(model.ShiftId.Value);
                if (template == null)
                {
                    TempData["ErrorMessage"] = "Invalid shift template selected.";
                    ViewData["DepartmentId"] = new SelectList(_context.Departments, "DepartmentId", "DepartmentName", model.DepartmentId);
                    ViewData["ShiftTemplates"] = _context.ShiftSchedules
                        .Where(s => s.Status == "Template")
                        .Select(s => new { s.ShiftId, Display = $"{s.ShiftName} ({s.ShiftType})" })
                        .ToList();
                    return View(model);
                }

                // Get all employees in the department
                var employees = await _context.Employees
                    .Where(e => e.DepartmentId == model.DepartmentId.Value)
                    .ToListAsync();

                if (employees.Count == 0)
                {
                    TempData["ErrorMessage"] = "No employees found in the selected department.";
                    ViewData["DepartmentId"] = new SelectList(_context.Departments, "DepartmentId", "DepartmentName", model.DepartmentId);
                    ViewData["ShiftTemplates"] = _context.ShiftSchedules
                        .Where(s => s.Status == "Template")
                        .Select(s => new { s.ShiftId, Display = $"{s.ShiftName} ({s.ShiftType})" })
                        .ToList();
                    return View(model);
                }

                // Get the max ShiftId to generate new IDs
                var maxShiftId = await _context.ShiftSchedules.MaxAsync(s => (int?)s.ShiftId) ?? 0;
                int assignedCount = 0;
                
                foreach (var employee in employees)
                {
                    var shiftSchedule = new ShiftSchedule
                    {
                        ShiftId = maxShiftId + assignedCount + 1,
                        EmployeeId = employee.EmployeeId,
                        ShiftName = template.ShiftName,
                        ShiftType = template.ShiftType,
                        StartTime = template.StartTime,
                        EndTime = template.EndTime,
                        StartDate = model.StartDate,
                        EndDate = model.EndDate,
                        Status = "Active"
                    };

                    _context.Add(shiftSchedule);
                    assignedCount++;
                }

                await _context.SaveChangesAsync();
                
                TempData["SuccessMessage"] = $"Shift assigned to {assignedCount} employees in the department successfully!";
                return RedirectToAction(nameof(Index));
            }

            // If we got here, something failed - show validation errors
            ViewData["DepartmentId"] = new SelectList(_context.Departments, "DepartmentId", "DepartmentName", model.DepartmentId);
            ViewData["ShiftTemplates"] = _context.ShiftSchedules
                .Where(s => s.Status == "Template")
                .Select(s => new { s.ShiftId, Display = $"{s.ShiftName} ({s.ShiftType})" })
                .ToList();
            
            return View(model);
        }

        // GET: ShiftSchedules/UpdateShiftAssignment/5
        // System Admin updates shift assignment
        public async Task<IActionResult> UpdateShiftAssignment(int? id)
        {
            var userRoles = HttpContext.Session.GetString("UserRoles");
            if (string.IsNullOrEmpty(userRoles) || !userRoles.Contains("System Administrator"))
            {
                ViewBag.Message = "You do not have permission to perform this action.";
                ViewBag.AllowedRoles = "This action can only be performed by: System Administrator";
                return View("~/Views/Shared/AccessDenied.cshtml");
            }

            if (id == null)
            {
                return NotFound();
            }

            var shiftSchedule = await _context.ShiftSchedules.FindAsync(id);
            if (shiftSchedule == null)
            {
                return NotFound();
            }

            ViewData["EmployeeId"] = new SelectList(_context.Employees, "EmployeeId", "FullName", shiftSchedule.EmployeeId);
            return View(shiftSchedule);
        }

        // POST: ShiftSchedules/UpdateShiftAssignment/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> UpdateShiftAssignment(int id, [Bind("ShiftId,EmployeeId,StartDate,EndDate,Status,ShiftName,ShiftType,StartTime,EndTime")] ShiftSchedule shiftSchedule)
        {
            var userRoles = HttpContext.Session.GetString("UserRoles");
            if (string.IsNullOrEmpty(userRoles) || !userRoles.Contains("System Administrator"))
            {
                ViewBag.Message = "You do not have permission to perform this action.";
                ViewBag.AllowedRoles = "This action can only be performed by: System Administrator";
                return View("~/Views/Shared/AccessDenied.cshtml");
            }

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
                    TempData["SuccessMessage"] = "Shift assignment updated successfully!";
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
            
            ViewData["EmployeeId"] = new SelectList(_context.Employees, "EmployeeId", "FullName", shiftSchedule.EmployeeId);
            return View(shiftSchedule);
        }
    }
}
