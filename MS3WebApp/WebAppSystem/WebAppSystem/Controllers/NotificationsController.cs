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
    }
}
