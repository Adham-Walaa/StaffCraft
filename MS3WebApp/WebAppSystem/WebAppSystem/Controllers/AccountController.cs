using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using System.Data;
using WebAppSystem.Models;
using SystemException = System.Exception;

namespace WebAppSystem.Controllers
{
    public class AccountController : Controller
    {
        private readonly Milestone2Context _context;

        public AccountController(Milestone2Context context)
        {
            _context = context;
        }

        // Hash password using BCrypt
        private string HashPassword(string password)
        {
            return BCrypt.Net.BCrypt.HashPassword(password);
        }

        // Verify password
        private bool VerifyPassword(string password, string hash)
        {
            try
            {
                return BCrypt.Net.BCrypt.Verify(password, hash);
            }
            catch
            {
                return false;
            }
        }

        // Set password hash for an employee (extracted method to avoid duplication)
        private async Task SetEmployeePasswordAsync(int employeeId, string password)
        {
            try
            {
                var hashedPassword = HashPassword(password);
                
                // Use stored procedure to set password hash to avoid EF issues
                var parameters = new[]
                {
                    new SqlParameter("@EmployeeID", employeeId),
                    new SqlParameter("@PasswordHash", hashedPassword)
                };
                
                await _context.Database.ExecuteSqlRawAsync(
                    "EXEC dbo.SetEmployeePassword @EmployeeID, @PasswordHash",
                    parameters
                );
            }
            catch (SystemException ex)
            {
                // Log or rethrow with more context
                throw new SystemException($"Failed to set password for employee {employeeId}: {ex.Message}", ex);
            }
        }

        // GET: Account/Login
        public IActionResult Login()
        {
            return View();
        }

        // POST: Account/Login
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Login(LoginViewModel model)
        {
            if (ModelState.IsValid)
            {
                try
                {
                    // Find employee by email
                    var employee = await _context.Employees
                        .Include(e => e.Department)
                        .Include(e => e.Position)
                        .FirstOrDefaultAsync(e => e.Email == model.Email);

                    if (employee != null && employee.IsActive == true)
                    {
                        // Verify password
                        if (string.IsNullOrEmpty(employee.PasswordHash) || !VerifyPassword(model.Password, employee.PasswordHash))
                        {
                            ModelState.AddModelError("", "Invalid email or password.");
                            return View(model);
                        }
                        
                        // Store user information in session
                        HttpContext.Session.SetInt32("UserId", employee.EmployeeId);
                        HttpContext.Session.SetString("UserEmail", employee.Email ?? "");
                        HttpContext.Session.SetString("UserName", employee.FullName ?? "");
                        
                        // Get user roles
                        var roles = await _context.Database
                            .SqlQueryRaw<string>(
                                @"SELECT r.role_name 
                                FROM EmployeeRole er 
                                JOIN Role r ON er.role_id = r.RoleID 
                                WHERE er.employee_id = @p0",
                                employee.EmployeeId)
                            .ToListAsync();
                        
                        if (roles.Any())
                        {
                            HttpContext.Session.SetString("UserRoles", string.Join(",", roles));
                        }

                        TempData["SuccessMessage"] = "Login successful!";
                        return RedirectToAction("Index", "Home");
                    }
                    else
                    {
                        ModelState.AddModelError("", "Invalid email or account is inactive.");
                    }
                }
                catch (SystemException ex)
                {
                    ModelState.AddModelError("", $"Login failed: {ex.Message}");
                }
            }

            return View(model);
        }

        // GET: Account/Register
        public IActionResult Register()
        {
            ViewBag.Roles = new SelectList(new[]
            {
                new { Value = "System Administrator", Text = "System Administrator" },
                new { Value = "HR Administrator", Text = "HR Administrator" },
                new { Value = "Line Manager", Text = "Line Manager" },
                new { Value = "Employee", Text = "Employee" }
            }, "Value", "Text");

            return View();
        }

        // POST: Account/Register
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Register(RegisterViewModel model)
        {
            if (ModelState.IsValid)
            {
                try
                {
                    // Check if email already exists
                    var existingEmployee = await _context.Employees
                        .FirstOrDefaultAsync(e => e.Email == model.Email);

                    if (existingEmployee != null)
                    {
                        ModelState.AddModelError("Email", "This email is already registered.");
                        ViewBag.Roles = GetRolesSelectList();
                        return View(model);
                    }

                    // Construct full name from first and last name
                    string fullName = $"{model.FirstName} {model.LastName}".Trim();

                    // Create employee using AddEmployee stored procedure
                    var parameters = new[]
                    {
                        new SqlParameter("@FullName", fullName),
                        new SqlParameter("@NationalID", DBNull.Value),
                        new SqlParameter("@DateOfBirth", model.DateOfBirth ?? (object)DBNull.Value),
                        new SqlParameter("@CountryOfBirth", DBNull.Value),
                        new SqlParameter("@Phone", model.Phone ?? (object)DBNull.Value),
                        new SqlParameter("@Email", model.Email),
                        new SqlParameter("@Address", model.Address ?? (object)DBNull.Value),
                        new SqlParameter("@EmergencyContactName", DBNull.Value),
                        new SqlParameter("@EmergencyContactPhone", DBNull.Value),
                        new SqlParameter("@Relationship", DBNull.Value),
                        new SqlParameter("@Biography", DBNull.Value),
                        new SqlParameter("@EmploymentProgress", "New Account"),
                        new SqlParameter("@AccountStatus", "ACTIVE"),
                        new SqlParameter("@EmploymentStatus", "Active"),
                        new SqlParameter("@HireDate", DateTime.Now),
                        new SqlParameter("@IsActive", true),
                        new SqlParameter("@ProfileCompletion", 30),
                        new SqlParameter("@DepartmentID", DBNull.Value),
                        new SqlParameter("@PositionID", DBNull.Value),
                        new SqlParameter("@ManagerID", DBNull.Value),
                        new SqlParameter("@ContractID", DBNull.Value),
                        new SqlParameter("@TaxFormID", DBNull.Value),
                        new SqlParameter("@SalaryTypeID", DBNull.Value),
                        new SqlParameter("@PayGrade", DBNull.Value),
                        new SqlParameter("@NewEmployeeID", SqlDbType.Int) { Direction = ParameterDirection.Output }
                    };

                    await _context.Database.ExecuteSqlRawAsync(
                        "EXEC dbo.AddEmployee @FullName, @NationalID, @DateOfBirth, @CountryOfBirth, @Phone, @Email, @Address, " +
                        "@EmergencyContactName, @EmergencyContactPhone, @Relationship, @Biography, @EmploymentProgress, " +
                        "@AccountStatus, @EmploymentStatus, @HireDate, @IsActive, @ProfileCompletion, @DepartmentID, " +
                        "@PositionID, @ManagerID, @ContractID, @TaxFormID, @SalaryTypeID, @PayGrade, @NewEmployeeID OUTPUT",
                        parameters
                    );

                    var newEmployeeId = (int)parameters[parameters.Length - 1].Value;

                    // Set the password hash
                    await SetEmployeePasswordAsync(newEmployeeId, model.Password);

                    // Assign role using ManageUserAccounts stored procedure
                    var roleParams = new[]
                    {
                        new SqlParameter("@UserID", newEmployeeId),
                        new SqlParameter("@Role", model.Role),
                        new SqlParameter("@Action", "ADD")
                    };

                    await _context.Database.ExecuteSqlRawAsync(
                        "EXEC dbo.ManageUserAccounts @UserID, @Role, @Action",
                        roleParams
                    );

                    TempData["SuccessMessage"] = "Account created successfully! You can now login.";
                    return RedirectToAction("Login");
                }
                catch (SystemException ex)
                {
                    ModelState.AddModelError("", $"Registration failed: {ex.Message}");
                }
            }

            ViewBag.Roles = GetRolesSelectList();
            return View(model);
        }

        // GET: Account/CreateEmployee (for System Admins)
        public IActionResult CreateEmployee()
        {
            // Check if user is System Administrator
            var userRoles = HttpContext.Session.GetString("UserRoles");
            if (string.IsNullOrEmpty(userRoles) || !userRoles.Contains("System Administrator"))
            {
                TempData["ErrorMessage"] = "Access denied. Only System Administrators can create employee accounts.";
                return RedirectToAction("Index", "Home");
            }

            ViewBag.Roles = GetRolesSelectList();
            ViewData["DepartmentId"] = new SelectList(_context.Departments, "DepartmentId", "DepartmentName");
            ViewData["PositionId"] = new SelectList(_context.Positions, "PositionId", "PositionTitle");
            ViewData["ManagerId"] = new SelectList(_context.Employees, "EmployeeId", "FullName");

            return View();
        }

        // POST: Account/CreateEmployee
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> CreateEmployee(RegisterViewModel model, int? departmentId, int? positionId, int? managerId)
        {
            // Check if user is System Administrator
            var userRoles = HttpContext.Session.GetString("UserRoles");
            if (string.IsNullOrEmpty(userRoles) || !userRoles.Contains("System Administrator"))
            {
                TempData["ErrorMessage"] = "Access denied. Only System Administrators can create employee accounts.";
                return RedirectToAction("Index", "Home");
            }

            if (ModelState.IsValid)
            {
                try
                {
                    // Check if email already exists
                    var existingEmployee = await _context.Employees
                        .FirstOrDefaultAsync(e => e.Email == model.Email);

                    if (existingEmployee != null)
                    {
                        ModelState.AddModelError("Email", "This email is already registered.");
                        PrepareCreateEmployeeViewData(model, departmentId, positionId, managerId);
                        return View(model);
                    }

                    // Construct full name from first and last name
                    string fullName = $"{model.FirstName} {model.LastName}".Trim();

                    // Create employee using AddEmployee stored procedure
                    var parameters = new[]
                    {
                        new SqlParameter("@FullName", fullName),
                        new SqlParameter("@NationalID", DBNull.Value),
                        new SqlParameter("@DateOfBirth", model.DateOfBirth ?? (object)DBNull.Value),
                        new SqlParameter("@CountryOfBirth", DBNull.Value),
                        new SqlParameter("@Phone", model.Phone ?? (object)DBNull.Value),
                        new SqlParameter("@Email", model.Email),
                        new SqlParameter("@Address", model.Address ?? (object)DBNull.Value),
                        new SqlParameter("@EmergencyContactName", DBNull.Value),
                        new SqlParameter("@EmergencyContactPhone", DBNull.Value),
                        new SqlParameter("@Relationship", DBNull.Value),
                        new SqlParameter("@Biography", DBNull.Value),
                        new SqlParameter("@EmploymentProgress", "New Employee"),
                        new SqlParameter("@AccountStatus", "ACTIVE"),
                        new SqlParameter("@EmploymentStatus", "Active"),
                        new SqlParameter("@HireDate", DateTime.Now),
                        new SqlParameter("@IsActive", true),
                        new SqlParameter("@ProfileCompletion", 40),
                        new SqlParameter("@DepartmentID", departmentId ?? (object)DBNull.Value),
                        new SqlParameter("@PositionID", positionId ?? (object)DBNull.Value),
                        new SqlParameter("@ManagerID", managerId ?? (object)DBNull.Value),
                        new SqlParameter("@ContractID", DBNull.Value),
                        new SqlParameter("@TaxFormID", DBNull.Value),
                        new SqlParameter("@SalaryTypeID", DBNull.Value),
                        new SqlParameter("@PayGrade", DBNull.Value),
                        new SqlParameter("@NewEmployeeID", SqlDbType.Int) { Direction = ParameterDirection.Output }
                    };

                    await _context.Database.ExecuteSqlRawAsync(
                        "EXEC dbo.AddEmployee @FullName, @NationalID, @DateOfBirth, @CountryOfBirth, @Phone, @Email, @Address, " +
                        "@EmergencyContactName, @EmergencyContactPhone, @Relationship, @Biography, @EmploymentProgress, " +
                        "@AccountStatus, @EmploymentStatus, @HireDate, @IsActive, @ProfileCompletion, @DepartmentID, " +
                        "@PositionID, @ManagerID, @ContractID, @TaxFormID, @SalaryTypeID, @PayGrade, @NewEmployeeID OUTPUT",
                        parameters
                    );

                    var newEmployeeId = (int)parameters[parameters.Length - 1].Value;

                    // Set the password hash
                    await SetEmployeePasswordAsync(newEmployeeId, model.Password);

                    // Assign role
                    var roleParams = new[]
                    {
                        new SqlParameter("@UserID", newEmployeeId),
                        new SqlParameter("@Role", model.Role),
                        new SqlParameter("@Action", "ADD")
                    };

                    await _context.Database.ExecuteSqlRawAsync(
                        "EXEC dbo.ManageUserAccounts @UserID, @Role, @Action",
                        roleParams
                    );

                    TempData["SuccessMessage"] = "Employee account created successfully!";
                    return RedirectToAction("Details", "Employees", new { id = newEmployeeId });
                }
                catch (SystemException ex)
                {
                    ModelState.AddModelError("", $"Employee creation failed: {ex.Message}");
                }
            }

            PrepareCreateEmployeeViewData(model, departmentId, positionId, managerId);
            return View(model);
        }

        // GET: Account/Logout
        public IActionResult Logout()
        {
            HttpContext.Session.Clear();
            TempData["SuccessMessage"] = "You have been logged out successfully.";
            return RedirectToAction("Login");
        }

        private SelectList GetRolesSelectList()
        {
            return new SelectList(new[]
            {
                new { Value = "System Administrator", Text = "System Administrator" },
                new { Value = "HR Administrator", Text = "HR Administrator" },
                new { Value = "Line Manager", Text = "Line Manager" },
                new { Value = "Employee", Text = "Employee" }
            }, "Value", "Text");
        }

        private void PrepareCreateEmployeeViewData(RegisterViewModel model, int? departmentId, int? positionId, int? managerId)
        {
            ViewBag.Roles = GetRolesSelectList();
            ViewData["DepartmentId"] = new SelectList(_context.Departments, "DepartmentId", "DepartmentName", departmentId);
            ViewData["PositionId"] = new SelectList(_context.Positions, "PositionId", "PositionTitle", positionId);
            ViewData["ManagerId"] = new SelectList(_context.Employees, "EmployeeId", "FullName", managerId);
        }
    }
}
