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
    public class NotificationsController : Controller
    {
        private readonly Milestone2Context _context;

        public NotificationsController(Milestone2Context context)
        {
            _context = context;
        }

        // GET: Notifications
        public async Task<IActionResult> Index()
        {
            var userId = HttpContext.Session.GetInt32("UserId");
            if (userId == null)
            {
                TempData["ErrorMessage"] = "Please login to view notifications.";
                return RedirectToAction("Login", "Account");
            }

            // Check for expiring contracts and set warning message
            await CheckExpiringContracts(userId.Value);

            // Get all notifications for the logged-in user
            var notifications = await _context.EmployeeNotifications
                .Include(en => en.Notification)
                .Where(en => en.EmployeeId == userId.Value)
                .OrderByDescending(en => en.Notification.Timestamp)
                .ToListAsync();

            return View(notifications);
        }

        // GET: Notifications/SendTeamNotification
        public IActionResult SendTeamNotification()
        {
            var userRoles = HttpContext.Session.GetString("UserRoles");
            var userId = HttpContext.Session.GetInt32("UserId");

            if (string.IsNullOrEmpty(userRoles) || userId == null)
            {
                TempData["ErrorMessage"] = "Please login to send notifications.";
                return RedirectToAction("Login", "Account");
            }

            // Only Line Managers can send team notifications
            if (!userRoles.Contains("Line Manager"))
            {
                TempData["ErrorMessage"] = "Only Line Managers can send team notifications.";
                return RedirectToAction("Index");
            }

            return View();
        }

        // POST: Notifications/SendTeamNotification
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> SendTeamNotification(string messageContent, string urgencyLevel)
        {
            var userRoles = HttpContext.Session.GetString("UserRoles");
            var userId = HttpContext.Session.GetInt32("UserId");

            if (string.IsNullOrEmpty(userRoles) || userId == null)
            {
                TempData["ErrorMessage"] = "Please login to send notifications.";
                return RedirectToAction("Login", "Account");
            }

            if (!userRoles.Contains("Line Manager"))
            {
                TempData["ErrorMessage"] = "Only Line Managers can send team notifications.";
                return RedirectToAction("Index");
            }

            if (string.IsNullOrWhiteSpace(messageContent))
            {
                TempData["ErrorMessage"] = "Message content is required.";
                return View();
            }

            if (string.IsNullOrWhiteSpace(urgencyLevel))
            {
                TempData["ErrorMessage"] = "Urgency level is required.";
                return View();
            }

            try
            {
                // Call the stored procedure to send team notification
                var managerIdParam = new SqlParameter("@ManagerID", userId.Value);
                var messageParam = new SqlParameter("@MessageContent", messageContent);
                var urgencyParam = new SqlParameter("@UrgencyLevel", urgencyLevel);

                await _context.Database.ExecuteSqlRawAsync(
                    "EXEC dbo.SendTeamNotification @ManagerID, @MessageContent, @UrgencyLevel",
                    managerIdParam, messageParam, urgencyParam);

                TempData["SuccessMessage"] = "Notification sent successfully to your team members.";
                return RedirectToAction("Index");
            }
            catch (SqlException ex)
            {
                TempData["ErrorMessage"] = $"Error sending notification: {ex.Message}";
                return View();
            }
        }

        // POST: Notifications/MarkAsRead/5
        [HttpPost]
        public async Task<IActionResult> MarkAsRead(int? employeeId, int? notificationId)
        {
            var userId = HttpContext.Session.GetInt32("UserId");
            if (userId == null)
            {
                return Json(new { success = false, message = "Not authenticated" });
            }

            if (employeeId == null || notificationId == null)
            {
                return Json(new { success = false, message = "Invalid parameters" });
            }

            // Verify the notification belongs to the current user
            if (employeeId.Value != userId.Value)
            {
                return Json(new { success = false, message = "Unauthorized" });
            }

            try
            {
                var employeeNotification = await _context.EmployeeNotifications
                    .Include(en => en.Notification)
                    .FirstOrDefaultAsync(en => en.EmployeeId == employeeId && en.NotificationId == notificationId);

                if (employeeNotification != null && employeeNotification.Notification != null)
                {
                    // Prevent contract expiration notifications from being marked as read
                    if (employeeNotification.Notification.NotificationType == "ContractExpiration")
                    {
                        return Json(new { success = false, message = "Contract expiration notifications cannot be dismissed. Please contact HR regarding your contract renewal." });
                    }

                    employeeNotification.Notification.ReadStatus = true;
                    employeeNotification.DeliveryStatus = "READ";
                    employeeNotification.DeliveredAt = DateTime.Now;
                    await _context.SaveChangesAsync();

                    return Json(new { success = true });
                }

                return Json(new { success = false, message = "Notification not found" });
            }
            catch (System.Exception ex)
            {
                return Json(new { success = false, message = ex.Message });
            }
        }

        // Private helper method to check for expiring contracts and create notifications
        private async Task CheckExpiringContracts(int employeeId)
        {
            try
            {
                // Get the employee's contract information
                var employee = await _context.Employees
                    .Include(e => e.Contract)
                    .FirstOrDefaultAsync(e => e.EmployeeId == employeeId);

                if (employee == null || employee.Contract == null)
                {
                    // Try fallback if contract navigation didn't load
                    if (employee != null && employee.ContractId.HasValue)
                    {
                        var contract = await _context.Contracts.FindAsync(employee.ContractId.Value);
                        if (contract != null)
                        {
                            employee.Contract = contract;
                        }
                    }
                }

                if (employee?.Contract == null)
                {
                    return; // No contract to check
                }

                var contractInfo = employee.Contract;

                // Check if contract has an end date
                if (!contractInfo.EndDate.HasValue)
                {
                    return; // No end date, nothing to warn about
                }

                // Check if contract is active (case-insensitive check)
                var currentState = contractInfo.CurrentState?.Trim().ToLower();
                if (currentState != "active")
                {
                    return; // Only check active contracts
                }

                // Calculate days until expiry using Date to avoid time component issues
                var today = DateTime.Today;
                var endDate = contractInfo.EndDate.Value.Date;
                var daysUntilExpiry = (endDate - today).Days;

                // Check if contract expires in 30 days or less
                if (daysUntilExpiry >= 0 && daysUntilExpiry <= 30)
                {
                    var urgency = daysUntilExpiry <= 7 ? "High" : daysUntilExpiry <= 14 ? "Medium" : "Low";
                    var contractType = string.IsNullOrEmpty(contractInfo.Type) ? "employment" : contractInfo.Type;
                    var contractDescription = contractInfo.Type ?? "Contract";
                    
                    // Set ViewBag properties for the alert banner
                    ViewBag.ContractExpirationWarning = true;
                    ViewBag.ContractExpirationDays = daysUntilExpiry;
                    ViewBag.ContractExpirationDate = contractInfo.EndDate.Value.ToString("MMMM dd, yyyy");
                    ViewBag.ContractType = contractDescription;
                    ViewBag.ContractUrgency = urgency;
                    
                    // Create message based on number of contracts (checking if employee might have multiple)
                    var contractCount = await _context.Contracts
                        .Where(c => c.Employees.Any(e => e.EmployeeId == employeeId) && c.CurrentState.ToLower() == "active")
                        .CountAsync();
                    
                    if (contractCount > 1)
                    {
                        ViewBag.ContractExpirationMessage = $"⚠️ URGENT: One of your contracts ({contractDescription}) is expiring in {daysUntilExpiry} day{(daysUntilExpiry != 1 ? "s" : "")} (on {ViewBag.ContractExpirationDate}). Unless your contract is renewed by an HR Administrator, it will expire. Please contact HR immediately to request contract renewal.";
                    }
                    else
                    {
                        ViewBag.ContractExpirationMessage = $"⚠️ URGENT: Your {contractType} contract is expiring in {daysUntilExpiry} day{(daysUntilExpiry != 1 ? "s" : "")} (on {ViewBag.ContractExpirationDate}). Unless your contract is renewed by an HR Administrator, it will expire. Please contact HR immediately to request contract renewal.";
                    }
                }
            }
            catch (System.Exception ex)
            {
                // Silently fail - don't disrupt the page if contract check fails
                System.Diagnostics.Debug.WriteLine($"Contract expiration check error: {ex.Message}");
            }
        }
    }
}
