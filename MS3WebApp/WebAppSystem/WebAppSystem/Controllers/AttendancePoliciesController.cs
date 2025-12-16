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
            var policies = await _context.AttendancePolicies
                .FromSqlRaw("EXEC GetAllAttendancePolicies")
                .ToListAsync();

            return View(policies);
        }

        // GET: AttendancePolicies/GracePeriods
        public async Task<IActionResult> GracePeriods()
        {
            var gracePeriods = await _context.AttendancePolicies
                .FromSqlRaw("EXEC GetGracePeriodSettings")
                .ToListAsync();

            return View(gracePeriods);
        }

        // GET: AttendancePolicies/ShortTimeRules
        public async Task<IActionResult> ShortTimeRules()
        {
            var shortTimeRules = await _context.AttendancePolicies
                .FromSqlRaw("EXEC GetShortTimeRules")
                .ToListAsync();

            return View(shortTimeRules);
        }

        // GET: AttendancePolicies/PenaltyThresholds
        public async Task<IActionResult> PenaltyThresholds()
        {
            var penaltyThresholds = await _context.AttendancePolicies
                .FromSqlRaw("EXEC GetPenaltyThresholds")
                .ToListAsync();

            return View(penaltyThresholds);
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
