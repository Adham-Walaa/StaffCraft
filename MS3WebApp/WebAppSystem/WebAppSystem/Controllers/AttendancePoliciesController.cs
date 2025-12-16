using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using WebAppSystem.Models;

namespace WebAppSystem.Controllers
{
    public class AttendancePoliciesController : Controller
    {
        private readonly Milestone2Context _context;

        public AttendancePoliciesController(Milestone2Context context)
        {
            _context = context;
        }

        // GET: AttendancePolicies
        public async Task<IActionResult> Index()
        {
            try
            {
                var policies = await _context.AttendancePolicies
                    .FromSqlRaw("EXECUTE GetAllAttendancePolicies")
                    .AsNoTracking()
                    .ToListAsync();

                return View(policies);
            }
            catch (SqlException ex) when (ex.Message.Contains("Could not find stored procedure"))
            {
                ViewBag.ErrorMessage = "Database stored procedures not found. Please execute the Procedures.sql file in SQL Server Management Studio to create the required stored procedures: GetAllAttendancePolicies, GetGracePeriodSettings, GetShortTimeRules, GetPenaltyThresholds.";
                ViewBag.SqlFile = "Location: Procedures.sql (lines 12000-12100)";
                return View(new List<AttendancePolicy>());
            }
            catch (System.Exception ex)
            {
                ViewBag.ErrorMessage = $"Error loading attendance policies: {ex.Message}";
                return View(new List<AttendancePolicy>());
            }
        }

        // GET: AttendancePolicies/GracePeriods
        public async Task<IActionResult> GracePeriods()
        {
            try
            {
                var gracePeriods = await _context.AttendancePolicies
                    .FromSqlRaw("EXECUTE GetGracePeriodSettings")
                    .AsNoTracking()
                    .ToListAsync();

                return View(gracePeriods);
            }
            catch (SqlException ex) when (ex.Message.Contains("Could not find stored procedure"))
            {
                ViewBag.ErrorMessage = "Database stored procedure 'GetGracePeriodSettings' not found. Please execute the Procedures.sql file in SQL Server Management Studio to create the required stored procedures.";
                ViewBag.SqlFile = "Location: Procedures.sql (lines 12000-12030)";
                return View(new List<AttendancePolicy>());
            }
            catch (System.Exception ex)
            {
                ViewBag.ErrorMessage = $"Error loading grace period settings: {ex.Message}";
                return View(new List<AttendancePolicy>());
            }
        }

        // GET: AttendancePolicies/ShortTimeRules
        public async Task<IActionResult> ShortTimeRules()
        {
            try
            {
                var shortTimeRules = await _context.AttendancePolicies
                    .FromSqlRaw("EXECUTE GetShortTimeRules")
                    .AsNoTracking()
                    .ToListAsync();

                return View(shortTimeRules);
            }
            catch (SqlException ex) when (ex.Message.Contains("Could not find stored procedure"))
            {
                ViewBag.ErrorMessage = "Database stored procedure 'GetShortTimeRules' not found. Please execute the Procedures.sql file in SQL Server Management Studio to create the required stored procedures.";
                ViewBag.SqlFile = "Location: Procedures.sql (lines 12030-12060)";
                return View(new List<AttendancePolicy>());
            }
            catch (System.Exception ex)
            {
                ViewBag.ErrorMessage = $"Error loading short-time penalty rules: {ex.Message}";
                return View(new List<AttendancePolicy>());
            }
        }

        // GET: AttendancePolicies/PenaltyThresholds
        public async Task<IActionResult> PenaltyThresholds()
        {
            try
            {
                var penaltyThresholds = await _context.AttendancePolicies
                    .FromSqlRaw("EXECUTE GetPenaltyThresholds")
                    .AsNoTracking()
                    .ToListAsync();

                return View(penaltyThresholds);
            }
            catch (SqlException ex) when (ex.Message.Contains("Could not find stored procedure"))
            {
                ViewBag.ErrorMessage = "Database stored procedure 'GetPenaltyThresholds' not found. Please execute the Procedures.sql file in SQL Server Management Studio to create the required stored procedures.";
                ViewBag.SqlFile = "Location: Procedures.sql (lines 12060-12090)";
                return View(new List<AttendancePolicy>());
            }
            catch (System.Exception ex)
            {
                ViewBag.ErrorMessage = $"Error loading penalty thresholds: {ex.Message}";
                return View(new List<AttendancePolicy>());
            }
        }

        // GET: AttendancePolicies/Details/5
        public async Task<IActionResult> Details(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var policy = await _context.AttendancePolicies
                .FirstOrDefaultAsync(m => m.PolicyID == id);

            if (policy == null)
            {
                return NotFound();
            }

            return View(policy);
        }
    }
}
