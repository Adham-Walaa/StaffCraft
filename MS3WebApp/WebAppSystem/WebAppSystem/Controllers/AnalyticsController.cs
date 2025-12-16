using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Data.SqlClient;
using System.Data;
using WebAppSystem.Models;

namespace WebAppSystem.Controllers
{
    public class AnalyticsController : Controller
    {
        private readonly Milestone2Context _context;

        public AnalyticsController(Milestone2Context context)
        {
            _context = context;
        }

        // GET: Analytics
        public IActionResult Index()
        {
            var userRoles = HttpContext.Session.GetString("UserRoles");
            var userId = HttpContext.Session.GetInt32("UserId");

            if (string.IsNullOrEmpty(userRoles) || userId == null)
            {
                TempData["ErrorMessage"] = "Please login to view analytics.";
                return RedirectToAction("Login", "Account");
            }

            // Only HR Admins and System Admins can access analytics
            if (!userRoles.Contains("HR Administrator") && !userRoles.Contains("System Administrator"))
            {
                TempData["ErrorMessage"] = "Only HR Administrators and System Administrators can access analytics.";
                return RedirectToAction("Index", "Home");
            }

            return View();
        }

        // GET: Analytics/DepartmentStatistics
        public async Task<IActionResult> DepartmentStatistics()
        {
            var userRoles = HttpContext.Session.GetString("UserRoles");
            var userId = HttpContext.Session.GetInt32("UserId");

            if (string.IsNullOrEmpty(userRoles) || userId == null)
            {
                TempData["ErrorMessage"] = "Please login to view department statistics.";
                return RedirectToAction("Login", "Account");
            }

            if (!userRoles.Contains("HR Administrator") && !userRoles.Contains("System Administrator"))
            {
                TempData["ErrorMessage"] = "Only HR Administrators can view department statistics.";
                return RedirectToAction("Index");
            }

            // Get department-wise employee statistics
            var departmentStats = await _context.Departments
                .Include(d => d.Employees)
                .Include(d => d.DepartmentHead)
                .Select(d => new
                {
                    Department = d,
                    EmployeeCount = d.Employees.Count,
                    ActiveEmployees = d.Employees.Count(e => e.IsActive == true),
                    InactiveEmployees = d.Employees.Count(e => e.IsActive == false || e.IsActive == null)
                })
                .ToListAsync();

            ViewBag.DepartmentStats = departmentStats;
            ViewBag.TotalEmployees = await _context.Employees.CountAsync();
            ViewBag.TotalDepartments = await _context.Departments.CountAsync();
            ViewBag.ActiveEmployees = await _context.Employees.CountAsync(e => e.IsActive == true);

            return View();
        }

        // GET: Analytics/ComplianceReport
        public async Task<IActionResult> ComplianceReport(string searchTerm = "", string filterType = "all")
        {
            var userRoles = HttpContext.Session.GetString("UserRoles");
            var userId = HttpContext.Session.GetInt32("UserId");

            if (string.IsNullOrEmpty(userRoles) || userId == null)
            {
                TempData["ErrorMessage"] = "Please login to view compliance reports.";
                return RedirectToAction("Login", "Account");
            }

            if (!userRoles.Contains("HR Administrator") && !userRoles.Contains("System Administrator"))
            {
                TempData["ErrorMessage"] = "Only HR Administrators can view compliance reports.";
                return RedirectToAction("Index");
            }

            IQueryable<Employee> query = _context.Employees
                .Include(e => e.Contract)
                .Include(e => e.Department)
                .Include(e => e.Position)
                .Include(e => e.Taxform);

            // Apply search filter (case-insensitive)
            if (!string.IsNullOrWhiteSpace(searchTerm))
            {
                var searchLower = searchTerm.ToLower();
                query = query.Where(e => 
                    (e.FullName != null && e.FullName.ToLower().Contains(searchLower)) ||
                    (e.Email != null && e.Email.ToLower().Contains(searchLower)) ||
                    (e.NationalId != null && e.NationalId.ToLower().Contains(searchLower)));
            }

            // Apply filter type
            switch (filterType.ToLower())
            {
                case "nocontract":
                    query = query.Where(e => e.ContractId == null);
                    ViewBag.FilterDescription = "Employees without contracts";
                    break;
                case "notaxform":
                    query = query.Where(e => e.TaxformId == null);
                    ViewBag.FilterDescription = "Employees without tax forms";
                    break;
                case "incomplete":
                    query = query.Where(e => e.ProfileCompletionPercentage < 100 || e.ProfileCompletionPercentage == null);
                    ViewBag.FilterDescription = "Employees with incomplete profiles";
                    break;
                case "inactive":
                    query = query.Where(e => e.IsActive == false || e.IsActive == null);
                    ViewBag.FilterDescription = "Inactive employees";
                    break;
                default:
                    ViewBag.FilterDescription = "All employees";
                    break;
            }

            var employees = await query.ToListAsync();

            ViewBag.SearchTerm = searchTerm;
            ViewBag.FilterType = filterType;
            ViewBag.ComplianceIssues = new
            {
                NoContract = await _context.Employees.CountAsync(e => e.ContractId == null),
                NoTaxForm = await _context.Employees.CountAsync(e => e.TaxformId == null),
                IncompleteProfile = await _context.Employees.CountAsync(e => e.ProfileCompletionPercentage < 100 || e.ProfileCompletionPercentage == null),
                Inactive = await _context.Employees.CountAsync(e => e.IsActive == false || e.IsActive == null)
            };

            return View(employees);
        }

        // GET: Analytics/DiversityReport
        public async Task<IActionResult> DiversityReport()
        {
            var userRoles = HttpContext.Session.GetString("UserRoles");
            var userId = HttpContext.Session.GetInt32("UserId");

            if (string.IsNullOrEmpty(userRoles) || userId == null)
            {
                TempData["ErrorMessage"] = "Please login to view diversity reports.";
                return RedirectToAction("Login", "Account");
            }

            if (!userRoles.Contains("HR Administrator") && !userRoles.Contains("System Administrator"))
            {
                TempData["ErrorMessage"] = "Only HR Administrators can view diversity reports.";
                return RedirectToAction("Index");
            }

            // Get diversity statistics
            var employeesByCountry = await _context.Employees
                .Where(e => e.CountryOfBirth != null)
                .GroupBy(e => e.CountryOfBirth)
                .Select(g => new { Country = g.Key, Count = g.Count() })
                .OrderByDescending(x => x.Count)
                .ToListAsync();

            var employeesByDepartment = await _context.Employees
                .Include(e => e.Department)
                .Where(e => e.DepartmentId != null)
                .GroupBy(e => e.Department.DepartmentName)
                .Select(g => new { Department = g.Key, Count = g.Count() })
                .OrderByDescending(x => x.Count)
                .ToListAsync();

            var employeesByStatus = await _context.Employees
                .GroupBy(e => e.EmploymentStatus ?? "Unknown")
                .Select(g => new { Status = g.Key, Count = g.Count() })
                .ToListAsync();

            ViewBag.EmployeesByCountry = employeesByCountry;
            ViewBag.EmployeesByDepartment = employeesByDepartment;
            ViewBag.EmployeesByStatus = employeesByStatus;
            ViewBag.TotalEmployees = await _context.Employees.CountAsync();

            return View();
        }

        // GET: Analytics/ViewTables
        public async Task<IActionResult> ViewTables()
        {
            var userId = HttpContext.Session.GetInt32("UserId");

            if (userId == null)
            {
                TempData["ErrorMessage"] = "Please login to view tables.";
                return RedirectToAction("Login", "Account");
            }

            // All logged-in users can access this view
            // Get all data for tables
            var departments = await _context.Departments
                .Include(d => d.DepartmentHead)
                .Include(d => d.Employees)
                .OrderBy(d => d.DepartmentId)
                .ToListAsync();

            var positions = await _context.Positions
                .Include(p => p.Employees)
                .OrderBy(p => p.PositionId)
                .ToListAsync();

            // Get roles directly from the Role table to avoid TEXT column comparison issues
            var roles = await _context.Roles
                .OrderBy(r => r.RoleId)
                .ToListAsync();

            // Get managers (employees who have other employees reporting to them)
            var managers = await _context.Employees
                .Include(e => e.Department)
                .Include(e => e.Position)
                .Include(e => e.InverseManager) // Employees who report to this manager
                .Where(e => e.InverseManager.Any())
                .OrderBy(e => e.EmployeeId)
                .ToListAsync();

            // Get teams organized by manager
            var teams = await _context.Employees
                .Include(e => e.Manager)
                .Include(e => e.Department)
                .Include(e => e.Position)
                .Where(e => e.ManagerId != null)
                .GroupBy(e => e.Manager)
                .Select(g => new
                {
                    Manager = g.Key,
                    TeamMembers = g.ToList()
                })
                .ToListAsync();

            ViewBag.Departments = departments;
            ViewBag.Positions = positions;
            ViewBag.Roles = roles;
            ViewBag.Managers = managers;
            ViewBag.Teams = teams;

            return View();
        }

        // GET: Analytics/TeamDetails
        public async Task<IActionResult> TeamDetails(int? managerId)
        {
            var userId = HttpContext.Session.GetInt32("UserId");

            if (userId == null)
            {
                TempData["ErrorMessage"] = "Please login to view team details.";
                return RedirectToAction("Login", "Account");
            }

            if (managerId == null)
            {
                TempData["ErrorMessage"] = "Manager ID is required.";
                return RedirectToAction("ViewTables");
            }

            var manager = await _context.Employees
                .Include(e => e.Department)
                .Include(e => e.Position)
                .Include(e => e.InverseManager)
                    .ThenInclude(tm => tm.Department)
                .Include(e => e.InverseManager)
                    .ThenInclude(tm => tm.Position)
                .FirstOrDefaultAsync(e => e.EmployeeId == managerId);

            if (manager == null)
            {
                TempData["ErrorMessage"] = "Manager not found.";
                return RedirectToAction("ViewTables");
            }

            return View(manager);
        }
    }
}
