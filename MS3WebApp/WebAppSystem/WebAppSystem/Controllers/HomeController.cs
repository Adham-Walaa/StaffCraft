using System.Diagnostics;
using Microsoft.AspNetCore.Mvc;
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

        public IActionResult Index()
        {
            var userId = HttpContext.Session.GetInt32("UserId");
            
            if (userId.HasValue)
            {
                // Query the database to check if this employee has direct reports
                var hasDirectReports = _context.Employees.Any(e => e.ManagerId == userId.Value);
                ViewBag.HasDirectReports = hasDirectReports;
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
