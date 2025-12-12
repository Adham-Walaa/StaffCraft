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

namespace WebAppSystem.Controllers
{
    public class HierarchyController : Controller
    {
        private readonly Milestone2Context _context;

        public HierarchyController(Milestone2Context context)
        {
            _context = context;
        }

        // GET: Hierarchy
        public async Task<IActionResult> Index()
        {
            var userId = HttpContext.Session.GetInt32("UserId");
            if (userId == null)
            {
                TempData["ErrorMessage"] = "Please login to view the organizational hierarchy.";
                return RedirectToAction("Login", "Account");
            }

            try
            {
                // Call the ViewOrgHierarchy stored procedure
                using (var connection = _context.Database.GetDbConnection())
                {
                    await connection.OpenAsync();
                    using (var command = connection.CreateCommand())
                    {
                        command.CommandText = "EXEC dbo.ViewOrgHierarchy";
                        using (var reader = await command.ExecuteReaderAsync())
                        {
                            var hierarchyData = new List<OrgHierarchyViewModel>();
                            while (await reader.ReadAsync())
                            {
                                hierarchyData.Add(new OrgHierarchyViewModel
                                {
                                    EmployeeId = reader.IsDBNull(0) ? null : reader.GetInt32(0),
                                    FirstName = reader.IsDBNull(1) ? null : reader.GetString(1),
                                    LastName = reader.IsDBNull(2) ? null : reader.GetString(2),
                                    ManagerId = reader.IsDBNull(3) ? null : reader.GetInt32(3),
                                    ManagerName = reader.IsDBNull(4) ? null : reader.GetString(4),
                                    DepartmentId = reader.IsDBNull(5) ? null : reader.GetInt32(5),
                                    DepartmentName = reader.IsDBNull(6) ? null : reader.GetString(6),
                                    PositionId = reader.IsDBNull(7) ? null : reader.GetInt32(7),
                                    PositionTitle = reader.IsDBNull(8) ? null : reader.GetString(8),
                                    HierarchyLevel = reader.IsDBNull(9) ? null : reader.GetInt32(9),
                                    HierarchyPath = reader.IsDBNull(10) ? null : reader.GetString(10)
                                });
                            }
                            
                            // Set EmployeeName for each item
                            foreach (var item in hierarchyData)
                            {
                                item.EmployeeName = $"{item.FirstName} {item.LastName}".Trim();
                            }
                            
                            return View(hierarchyData);
                        }
                    }
                }
            }
            catch (System.Exception ex)
            {
                TempData["ErrorMessage"] = $"Error loading hierarchy: {ex.Message}";
                return View(new List<OrgHierarchyViewModel>());
            }
        }

        // GET: Hierarchy/ReassignEmployee
        public async Task<IActionResult> ReassignEmployee(int? id)
        {
            var userRoles = HttpContext.Session.GetString("UserRoles");
            var userId = HttpContext.Session.GetInt32("UserId");

            if (string.IsNullOrEmpty(userRoles) || userId == null)
            {
                TempData["ErrorMessage"] = "Please login to reassign employees.";
                return RedirectToAction("Login", "Account");
            }

            // Only System Admins can reassign employees
            if (!userRoles.Contains("System Administrator"))
            {
                TempData["ErrorMessage"] = "Only System Administrators can reassign employees.";
                return RedirectToAction("Index");
            }

            if (id == null)
            {
                TempData["ErrorMessage"] = "Employee ID is required.";
                return RedirectToAction("Index");
            }

            var employee = await _context.Employees
                .Include(e => e.Department)
                .Include(e => e.Manager)
                .Include(e => e.Position)
                .FirstOrDefaultAsync(e => e.EmployeeId == id);

            if (employee == null)
            {
                TempData["ErrorMessage"] = "Employee not found.";
                return RedirectToAction("Index");
            }

            // Populate dropdowns
            ViewData["Departments"] = new SelectList(_context.Departments, "DepartmentId", "DepartmentName", employee.DepartmentId);
            ViewData["Managers"] = new SelectList(
                _context.Employees.Where(e => e.EmployeeId != id), 
                "EmployeeId", 
                "FullName", 
                employee.ManagerId);

            return View(employee);
        }

        // POST: Hierarchy/ReassignEmployee
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> ReassignEmployee(int id, int? newDepartmentId, int? newManagerId)
        {
            var userRoles = HttpContext.Session.GetString("UserRoles");
            var userId = HttpContext.Session.GetInt32("UserId");

            if (string.IsNullOrEmpty(userRoles) || userId == null)
            {
                TempData["ErrorMessage"] = "Please login to reassign employees.";
                return RedirectToAction("Login", "Account");
            }

            if (!userRoles.Contains("System Administrator"))
            {
                TempData["ErrorMessage"] = "Only System Administrators can reassign employees.";
                return RedirectToAction("Index");
            }

            if (newDepartmentId == null && newManagerId == null)
            {
                TempData["ErrorMessage"] = "Please select at least a new department or a new manager.";
                return RedirectToAction("ReassignEmployee", new { id });
            }

            try
            {
                // Call the ReassignHierarchy stored procedure
                var employeeIdParam = new SqlParameter("@EmployeeID", id);
                var deptParam = new SqlParameter("@NewDepartmentID", (object)newDepartmentId ?? DBNull.Value);
                var managerParam = new SqlParameter("@NewManagerID", (object)newManagerId ?? DBNull.Value);

                await _context.Database.ExecuteSqlRawAsync(
                    "EXEC dbo.ReassignHierarchy @EmployeeID, @NewDepartmentID, @NewManagerID",
                    employeeIdParam, deptParam, managerParam);

                TempData["SuccessMessage"] = "Employee reassigned successfully.";
                return RedirectToAction("Index");
            }
            catch (SqlException ex)
            {
                TempData["ErrorMessage"] = $"Error reassigning employee: {ex.Message}";
                return RedirectToAction("ReassignEmployee", new { id });
            }
        }

        // API endpoint to get hierarchy data as JSON
        public async Task<IActionResult> GetHierarchyData()
        {
            try
            {
                using (var connection = _context.Database.GetDbConnection())
                {
                    await connection.OpenAsync();
                    using (var command = connection.CreateCommand())
                    {
                        command.CommandText = "EXEC dbo.ViewOrgHierarchy";
                        using (var reader = await command.ExecuteReaderAsync())
                        {
                            var hierarchyData = new List<OrgHierarchyViewModel>();
                            while (await reader.ReadAsync())
                            {
                                hierarchyData.Add(new OrgHierarchyViewModel
                                {
                                    EmployeeId = reader.IsDBNull(0) ? null : reader.GetInt32(0),
                                    FirstName = reader.IsDBNull(1) ? null : reader.GetString(1),
                                    LastName = reader.IsDBNull(2) ? null : reader.GetString(2),
                                    ManagerId = reader.IsDBNull(3) ? null : reader.GetInt32(3),
                                    ManagerName = reader.IsDBNull(4) ? null : reader.GetString(4),
                                    DepartmentId = reader.IsDBNull(5) ? null : reader.GetInt32(5),
                                    DepartmentName = reader.IsDBNull(6) ? null : reader.GetString(6),
                                    PositionId = reader.IsDBNull(7) ? null : reader.GetInt32(7),
                                    PositionTitle = reader.IsDBNull(8) ? null : reader.GetString(8),
                                    HierarchyLevel = reader.IsDBNull(9) ? null : reader.GetInt32(9),
                                    HierarchyPath = reader.IsDBNull(10) ? null : reader.GetString(10)
                                });
                            }
                            
                            // Set EmployeeName for each item
                            foreach (var item in hierarchyData)
                            {
                                item.EmployeeName = $"{item.FirstName} {item.LastName}".Trim();
                            }

                            // Transform data for visualization
                            var treeData = BuildHierarchyTree(hierarchyData);
                            return Json(treeData);
                        }
                    }
                }
            }
            catch (System.Exception ex)
            {
                return Json(new { error = ex.Message });
            }
        }

        private List<object> BuildHierarchyTree(List<OrgHierarchyViewModel> data)
        {
            var rootNodes = new List<object>();

            foreach (var item in data.Where(x => x.ManagerId == null))
            {
                rootNodes.Add(BuildNode(item, data));
            }

            return rootNodes;
        }

        private object BuildNode(OrgHierarchyViewModel item, List<OrgHierarchyViewModel> allData)
        {
            var children = allData.Where(x => x.ManagerId == item.EmployeeId)
                                  .Select(child => BuildNode(child, allData))
                                  .ToList();

            return new
            {
                id = item.EmployeeId,
                name = item.EmployeeName,
                firstName = item.FirstName,
                lastName = item.LastName,
                departmentId = item.DepartmentId,
                positionId = item.PositionId,
                level = item.HierarchyLevel,
                children = children.Any() ? children : null
            };
        }
    }
}
