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
    public class MissionsController : Controller
    {
        private readonly Milestone2Context _context;

        public MissionsController(Milestone2Context context)
        {
            _context = context;
        }

        // GET: Missions (All missions - filtered by role)
        public async Task<IActionResult> Index()
        {
            var userId = HttpContext.Session.GetInt32("UserId");
            var userRoles = HttpContext.Session.GetString("UserRoles");

            if (userId == null)
            {
                TempData["ErrorMessage"] = "Please login to view missions.";
                return RedirectToAction("Login", "Account");
            }

            IQueryable<Mission> missionsQuery = _context.Missions
                .Include(m => m.Employee)
                .Include(m => m.Manager);

            // Filter missions based on role
            if (userRoles?.Contains("HR Administrator") == true)
            {
                // HR can see all missions
            }
            else if (userRoles?.Contains("Line Manager") == true)
            {
                // Managers see missions they manage
                missionsQuery = missionsQuery.Where(m => m.ManagerId == userId.Value);
            }
            else
            {
                // Regular employees see their own missions
                missionsQuery = missionsQuery.Where(m => m.EmployeeId == userId.Value);
            }

            var missions = await missionsQuery.OrderByDescending(m => m.StartDate).ToListAsync();
            ViewBag.UserRoles = userRoles;
            return View(missions);
        }

        // GET: Missions/MyMissions (For employees to view their assigned missions)
        public async Task<IActionResult> MyMissions()
        {
            var userId = HttpContext.Session.GetInt32("UserId");
            if (userId == null)
            {
                TempData["ErrorMessage"] = "Please login to view your missions.";
                return RedirectToAction("Login", "Account");
            }

            var missions = await _context.Missions
                .Include(m => m.Employee)
                .Include(m => m.Manager)
                .Where(m => m.EmployeeId == userId.Value)
                .OrderByDescending(m => m.StartDate)
                .ToListAsync();

            return View(missions);
        }

        // GET: Missions/PendingApprovals (For managers to approve/reject missions)
        public async Task<IActionResult> PendingApprovals()
        {
            var userId = HttpContext.Session.GetInt32("UserId");
            var userRoles = HttpContext.Session.GetString("UserRoles");

            if (userId == null || userRoles?.Contains("Line Manager") != true)
            {
                TempData["ErrorMessage"] = "Access denied. Only managers can view pending approvals.";
                return RedirectToAction("Index", "Home");
            }

            var pendingMissions = await _context.Missions
                .Include(m => m.Employee)
                .Include(m => m.Manager)
                .Where(m => m.ManagerId == userId.Value && m.Status == "Pending")
                .OrderBy(m => m.StartDate)
                .ToListAsync();

            return View(pendingMissions);
        }

        // POST: Missions/ApproveMission
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> ApproveMission(int id)
        {
            var userId = HttpContext.Session.GetInt32("UserId");
            var userRoles = HttpContext.Session.GetString("UserRoles");

            if (userId == null || userRoles?.Contains("Line Manager") != true)
            {
                TempData["ErrorMessage"] = "Access denied. Only managers can approve missions.";
                return RedirectToAction("Index", "Home");
            }

            var mission = await _context.Missions.FindAsync(id);
            if (mission == null)
            {
                TempData["ErrorMessage"] = "Mission not found.";
                return RedirectToAction(nameof(PendingApprovals));
            }

            if (mission.ManagerId != userId.Value)
            {
                TempData["ErrorMessage"] = "You are not authorized to approve this mission.";
                return RedirectToAction(nameof(PendingApprovals));
            }

            mission.Status = "Approved";
            await _context.SaveChangesAsync();

            TempData["SuccessMessage"] = "Mission approved successfully!";
            return RedirectToAction(nameof(PendingApprovals));
        }

        // POST: Missions/RejectMission
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> RejectMission(int id)
        {
            var userId = HttpContext.Session.GetInt32("UserId");
            var userRoles = HttpContext.Session.GetString("UserRoles");

            if (userId == null || userRoles?.Contains("Line Manager") != true)
            {
                TempData["ErrorMessage"] = "Access denied. Only managers can reject missions.";
                return RedirectToAction("Index", "Home");
            }

            var mission = await _context.Missions.FindAsync(id);
            if (mission == null)
            {
                TempData["ErrorMessage"] = "Mission not found.";
                return RedirectToAction(nameof(PendingApprovals));
            }

            if (mission.ManagerId != userId.Value)
            {
                TempData["ErrorMessage"] = "You are not authorized to reject this mission.";
                return RedirectToAction(nameof(PendingApprovals));
            }

            mission.Status = "Rejected";
            await _context.SaveChangesAsync();

            TempData["SuccessMessage"] = "Mission rejected.";
            return RedirectToAction(nameof(PendingApprovals));
        }

        // GET: Missions/AssignMission (For HR to assign missions to managers)
        public async Task<IActionResult> AssignMission()
        {
            var userRoles = HttpContext.Session.GetString("UserRoles");
            if (userRoles?.Contains("HR Administrator") != true)
            {
                TempData["ErrorMessage"] = "Access denied. Only HR Administrators can assign missions.";
                return RedirectToAction("Index", "Home");
            }

            // Get all managers (employees with Line Manager role)
            var managerRoleId = await _context.Roles
                .Where(r => r.RoleName == "Line Manager")
                .Select(r => r.RoleId)
                .FirstOrDefaultAsync();

            var managerEmployeeIds = await _context.EmployeeRoles
                .Where(er => er.RoleId == managerRoleId)
                .Select(er => er.EmployeeId)
                .ToListAsync();

            var managers = await _context.Employees
                .Where(e => managerEmployeeIds.Contains(e.EmployeeId))
                .Select(e => new { e.EmployeeId, e.FullName })
                .ToListAsync();

            ViewData["ManagerId"] = new SelectList(managers, "EmployeeId", "FullName");
            return View();
        }

        // POST: Missions/AssignMission
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> AssignMission([Bind("Title,Description,Destination,StartDate,EndDate,ManagerId")] Mission mission)
        {
            var userRoles = HttpContext.Session.GetString("UserRoles");
            if (userRoles?.Contains("HR Administrator") != true)
            {
                TempData["ErrorMessage"] = "Access denied. Only HR Administrators can assign missions.";
                return RedirectToAction("Index", "Home");
            }

            if (ModelState.IsValid)
            {
                // Get the next MissionID
                var maxMissionId = await _context.Missions.AnyAsync() 
                    ? await _context.Missions.MaxAsync(m => m.MissionId) 
                    : 0;
                mission.MissionId = maxMissionId + 1;
                
                mission.Status = "Pending";
                mission.EmployeeId = mission.ManagerId; // Initially assign to manager
                
                _context.Add(mission);
                await _context.SaveChangesAsync();
                
                TempData["SuccessMessage"] = "Mission request sent to manager successfully!";
                return RedirectToAction(nameof(Index));
            }

            // If we got here, something failed, reload the form
            var managerRoleId = await _context.Roles
                .Where(r => r.RoleName == "Line Manager")
                .Select(r => r.RoleId)
                .FirstOrDefaultAsync();

            var managerEmployeeIds = await _context.EmployeeRoles
                .Where(er => er.RoleId == managerRoleId)
                .Select(er => er.EmployeeId)
                .ToListAsync();

            var managers = await _context.Employees
                .Where(e => managerEmployeeIds.Contains(e.EmployeeId))
                .Select(e => new { e.EmployeeId, e.FullName })
                .ToListAsync();

            ViewData["ManagerId"] = new SelectList(managers, "EmployeeId", "FullName", mission.ManagerId);
            return View(mission);
        }

        // GET: Missions/Details/5
        public async Task<IActionResult> Details(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var mission = await _context.Missions
                .Include(m => m.Employee)
                .Include(m => m.Manager)
                .FirstOrDefaultAsync(m => m.MissionId == id);
            if (mission == null)
            {
                return NotFound();
            }

            return View(mission);
        }

        // GET: Missions/Create
        public IActionResult Create()
        {
            ViewData["EmployeeId"] = new SelectList(_context.Employees, "EmployeeId", "FullName");
            ViewData["ManagerId"] = new SelectList(_context.Employees, "EmployeeId", "FullName");
            return View();
        }

        // POST: Missions/Create
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Create([Bind("MissionId,Title,Description,Destination,StartDate,EndDate,Status,EmployeeId,ManagerId")] Mission mission)
        {
            if (ModelState.IsValid)
            {
                _context.Add(mission);
                await _context.SaveChangesAsync();
                return RedirectToAction(nameof(Index));
            }
            ViewData["EmployeeId"] = new SelectList(_context.Employees, "EmployeeId", "FullName", mission.EmployeeId);
            ViewData["ManagerId"] = new SelectList(_context.Employees, "EmployeeId", "FullName", mission.ManagerId);
            return View(mission);
        }

        // GET: Missions/Edit/5
        public async Task<IActionResult> Edit(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var mission = await _context.Missions.FindAsync(id);
            if (mission == null)
            {
                return NotFound();
            }
            ViewData["EmployeeId"] = new SelectList(_context.Employees, "EmployeeId", "FullName", mission.EmployeeId);
            ViewData["ManagerId"] = new SelectList(_context.Employees, "EmployeeId", "FullName", mission.ManagerId);
            return View(mission);
        }

        // POST: Missions/Edit/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Edit(int id, [Bind("MissionId,Title,Description,Destination,StartDate,EndDate,Status,EmployeeId,ManagerId")] Mission mission)
        {
            if (id != mission.MissionId)
            {
                return NotFound();
            }

            if (ModelState.IsValid)
            {
                try
                {
                    _context.Update(mission);
                    await _context.SaveChangesAsync();
                }
                catch (DbUpdateConcurrencyException)
                {
                    if (!MissionExists(mission.MissionId))
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
            ViewData["EmployeeId"] = new SelectList(_context.Employees, "EmployeeId", "FullName", mission.EmployeeId);
            ViewData["ManagerId"] = new SelectList(_context.Employees, "EmployeeId", "FullName", mission.ManagerId);
            return View(mission);
        }

        // GET: Missions/Delete/5
        public async Task<IActionResult> Delete(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var mission = await _context.Missions
                .Include(m => m.Employee)
                .Include(m => m.Manager)
                .FirstOrDefaultAsync(m => m.MissionId == id);
            if (mission == null)
            {
                return NotFound();
            }

            return View(mission);
        }

        // POST: Missions/Delete/5
        [HttpPost, ActionName("Delete")]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> DeleteConfirmed(int id)
        {
            var mission = await _context.Missions.FindAsync(id);
            if (mission != null)
            {
                _context.Missions.Remove(mission);
            }

            await _context.SaveChangesAsync();
            return RedirectToAction(nameof(Index));
        }

        private bool MissionExists(int id)
        {
            return _context.Missions.Any(e => e.MissionId == id);
        }
    }
}
