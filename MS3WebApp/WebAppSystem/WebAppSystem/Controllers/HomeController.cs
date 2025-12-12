using System.Diagnostics;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using WebAppSystem.Models;

namespace WebAppSystem.Controllers
{
    public class HomeController : Controller
    {
        private readonly Milestone2Context _context;

        public HomeController(Milestone2Context context)
        {
            _context = context;
        }

        public async Task<IActionResult> Index()
        {
            // Check if user is a line manager and has team members
            var userId = HttpContext.Session.GetInt32("UserId");
            var userRoles = HttpContext.Session.GetString("UserRoles");
            
            if (userId != null && userRoles?.Contains("Line Manager") == true)
            {
                var teamCount = await _context.Employees.CountAsync(e => e.ManagerId == userId.Value);
                ViewBag.HasTeamMembers = teamCount > 0;
            }
            else
            {
                ViewBag.HasTeamMembers = false;
            }
            
            return View();
        }

        public IActionResult Privacy()
        {
            return View();
        }

        [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
        public IActionResult Error()
        {
            return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
        }
    }
}
