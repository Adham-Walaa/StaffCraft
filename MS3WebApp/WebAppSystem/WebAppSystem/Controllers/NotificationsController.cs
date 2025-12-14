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

            // Check for expiring contracts and create notifications
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

                if (employee == null)
                {
                    return; // Employee not found
                }

                // If employee doesn't have a contract linked, try to find it
                if (employee.Contract == null && employee.ContractId.HasValue)
                {
                    var employeeContract = await _context.Contracts.FindAsync(employee.ContractId.Value);
                    if (employeeContract != null)
                    {
                        employee.Contract = employeeContract;
                    }
                }

                if (employee.Contract == null)
                {
                    return; // No contract to check
                }

                var contract = employee.Contract;

                // Check if contract has an end date
                if (!contract.EndDate.HasValue)
                {
                    return; // No end date, nothing to check
                }

                // Check if contract is active (case-insensitive check)
                var currentState = contract.CurrentState?.Trim().ToLower();
                if (currentState != "active")
                {
                    return; // Only check active contracts
                }

                // Calculate days until expiry using Date (not DateTime) to avoid time component issues
                var today = DateTime.Today;
                var endDate = contract.EndDate.Value.Date;
                var daysUntilExpiry = (endDate - today).Days;

                // Check if contract expires in 30 days or less
                if (daysUntilExpiry >= 0 && daysUntilExpiry <= 30)
                {
                    // Check if we already have a permanent contract expiration notification for this employee
                    var existingNotification = await _context.EmployeeNotifications
                        .Include(en => en.Notification)
                        .Where(en => en.EmployeeId == employeeId 
                            && en.Notification != null
                            && en.Notification.NotificationType == "ContractExpiration"
                            && en.Notification.ReadStatus == false) // Only look for unread ones
                        .FirstOrDefaultAsync();

                    // Only create if there isn't already an active expiration notification
                    if (existingNotification == null)
                    {
                        // Create a new permanent notification
                        var notificationId = await _context.Notifications.AnyAsync() 
                            ? await _context.Notifications.MaxAsync(n => n.NotificationId) + 1 
                            : 1;

                        var urgency = daysUntilExpiry <= 7 ? "High" : daysUntilExpiry <= 14 ? "Medium" : "Low";
                        
                        var contractType = string.IsNullOrEmpty(contract.Type) ? "employment" : contract.Type;
                        
                        var notification = new Notification
                        {
                            NotificationId = notificationId,
                            MesageContent = $"URGENT: Your {contractType} contract will expire in {daysUntilExpiry} day{(daysUntilExpiry > 1 ? "s" : "")} (on {contract.EndDate.Value:MMM dd, yyyy}). If your contract is not renewed within the following days, it will expire. Please contact HR immediately to discuss renewal options.",
                            Timestamp = DateTime.Now,
                            Urgency = urgency,
                            ReadStatus = false,
                            NotificationType = "ContractExpiration" // Special type that cannot be dismissed
                        };

                        _context.Notifications.Add(notification);
                        await _context.SaveChangesAsync();

                        // Link notification to employee
                        var employeeNotification = new EmployeeNotification
                        {
                            EmployeeId = employeeId,
                            NotificationId = notificationId,
                            DeliveryStatus = "PERMANENT", // Special status indicating this is permanent
                            DeliveredAt = DateTime.Now
                        };

                        _context.EmployeeNotifications.Add(employeeNotification);
                        await _context.SaveChangesAsync();
                    }
                    else if (existingNotification.Notification != null)
                    {
                        // Update existing notification with current days count
                        var contractType = string.IsNullOrEmpty(contract.Type) ? "employment" : contract.Type;
                        var urgency = daysUntilExpiry <= 7 ? "High" : daysUntilExpiry <= 14 ? "Medium" : "Low";
                        
                        existingNotification.Notification.MesageContent = $"URGENT: Your {contractType} contract will expire in {daysUntilExpiry} day{(daysUntilExpiry > 1 ? "s" : "")} (on {contract.EndDate.Value:MMM dd, yyyy}). If your contract is not renewed within the following days, it will expire. Please contact HR immediately to discuss renewal options.";
                        existingNotification.Notification.Urgency = urgency;
                        existingNotification.Notification.Timestamp = DateTime.Now;
                        
                        await _context.SaveChangesAsync();
                    }
                }
                else if (daysUntilExpiry > 30)
                {
                    // If more than 30 days away, remove any existing contract expiration notification
                    var existingNotifications = await _context.EmployeeNotifications
                        .Include(en => en.Notification)
                        .Where(en => en.EmployeeId == employeeId 
                            && en.Notification != null
                            && en.Notification.NotificationType == "ContractExpiration")
                        .ToListAsync();

                    if (existingNotifications.Any())
                    {
                        foreach (var en in existingNotifications)
                        {
                            if (en.Notification != null)
                            {
                                _context.Notifications.Remove(en.Notification);
                            }
                            _context.EmployeeNotifications.Remove(en);
                        }
                        await _context.SaveChangesAsync();
                    }
                }
            }
            catch (System.Exception)
            {
                // Silently fail - don't break the notifications page if contract check fails
                // In production, you might want to log this error
            }
        }
    }
}
