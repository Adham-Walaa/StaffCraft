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
                    .FromSqlRaw("SELECT PolicyID AS PolicyID, policy_name AS PolicyName, policy_type AS PolicyType, description AS Description, parameters AS Parameters, effective_date AS EffectiveDate, status AS Status FROM AttendancePolicy WHERE status = 'Active' ORDER BY effective_date DESC")
                    .AsNoTracking()
                    .ToListAsync();

                return View(policies);
            }
            catch (SqlException ex) when (ex.Message.Contains("Could not find stored procedure") || ex.Message.Contains("Invalid column name") || ex.Message.Contains("Invalid object name 'AttendancePolicy'"))
            {
                ViewBag.ErrorMessage = "Database table 'AttendancePolicy' not found or not configured. Please create the table and execute the stored procedures in SQL Server Management Studio.";
                ViewBag.SqlFile = "Location: Create the AttendancePolicy table first, then execute Procedures.sql (lines 12000-12100)";
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
                    .FromSqlRaw("SELECT PolicyID AS PolicyID, policy_name AS PolicyName, policy_type AS PolicyType, description AS Description, parameters AS Parameters, effective_date AS EffectiveDate, status AS Status FROM AttendancePolicy WHERE policy_type = 'Grace Period' AND status = 'Active' ORDER BY effective_date DESC")
                    .AsNoTracking()
                    .ToListAsync();

                return View(gracePeriods);
            }
            catch (SqlException ex) when (ex.Message.Contains("Could not find stored procedure") || ex.Message.Contains("Invalid column name") || ex.Message.Contains("Invalid object name 'AttendancePolicy'"))
            {
                ViewBag.ErrorMessage = "Database table 'AttendancePolicy' not found or not configured. Please create the table first.";
                ViewBag.SqlFile = "Location: Create the AttendancePolicy table first";
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
                    .FromSqlRaw("SELECT PolicyID AS PolicyID, policy_name AS PolicyName, policy_type AS PolicyType, description AS Description, parameters AS Parameters, effective_date AS EffectiveDate, status AS Status FROM AttendancePolicy WHERE policy_type = 'Short Time Penalty' AND status = 'Active' ORDER BY effective_date DESC")
                    .AsNoTracking()
                    .ToListAsync();

                return View(shortTimeRules);
            }
            catch (SqlException ex) when (ex.Message.Contains("Could not find stored procedure") || ex.Message.Contains("Invalid column name") || ex.Message.Contains("Invalid object name 'AttendancePolicy'"))
            {
                ViewBag.ErrorMessage = "Database table 'AttendancePolicy' not found or not configured. Please create the table first.";
                ViewBag.SqlFile = "Location: Create the AttendancePolicy table first";
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
                    .FromSqlRaw("SELECT PolicyID AS PolicyID, policy_name AS PolicyName, policy_type AS PolicyType, description AS Description, parameters AS Parameters, effective_date AS EffectiveDate, status AS Status FROM AttendancePolicy WHERE policy_type = 'Penalty Threshold' AND status = 'Active' ORDER BY effective_date DESC")
                    .AsNoTracking()
                    .ToListAsync();

                return View(penaltyThresholds);
            }
            catch (SqlException ex) when (ex.Message.Contains("Could not find stored procedure") || ex.Message.Contains("Invalid column name") || ex.Message.Contains("Invalid object name 'AttendancePolicy'"))
            {
                ViewBag.ErrorMessage = "Database table 'AttendancePolicy' not found or not configured. Please create the table first.";
                ViewBag.SqlFile = "Location: Create the AttendancePolicy table first";
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
