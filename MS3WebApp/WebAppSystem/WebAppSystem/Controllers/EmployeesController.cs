using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;
using Microsoft.EntityFrameworkCore;
using Microsoft.Data.SqlClient;
using System.Data;  // Added for SqlDbType and ParameterDirection
using WebAppSystem.Models;
using SystemException = System.Exception;

namespace WebAppSystem.Controllers
{
    public class EmployeesController : Controller
    {
        private readonly Milestone2Context _context;

        public EmployeesController(Milestone2Context context)
        {
            _context = context;
        }

        // GET: Employees
        public async Task<IActionResult> Index()
        {
            var milestone2Context = _context.Employees.Include(e => e.Contract).Include(e => e.Department).Include(e => e.Manager).Include(e => e.Paygrade).Include(e => e.Position).Include(e => e.SalaryType).Include(e => e.Taxform);
            return View(await milestone2Context.ToListAsync());
        }

        // GET: Employees/ViewEmployeeInfo/5
        // Uses the ViewEmployeeInfo stored procedure
        public async Task<IActionResult> ViewEmployeeInfo(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var employees = await _context.Employees
                .FromSqlRaw("EXEC dbo.ViewEmployeeInfo @EmployeeID", new SqlParameter("@EmployeeID", id.Value))
                .AsNoTracking()
                .ToListAsync();

            var employee = employees.FirstOrDefault();

            if (employee == null)
            {
                return NotFound();
            }

            return View(employee);
        }

        // GET: Employees/Details/5
        public async Task<IActionResult> Details(int? id)
        {
            // Check if user is authorized to view full employee details (System Admin, HR Admin, or Line Manager)
            var userRoles = HttpContext.Session.GetString("UserRoles");
            var userId = HttpContext.Session.GetInt32("UserId");
            
            if (string.IsNullOrEmpty(userRoles) || userId == null)
            {
                TempData["ErrorMessage"] = "Please login to view employee details.";
                return RedirectToAction("Login", "Account");
            }

            // Allow System Admin, HR Admin, and Line Manager to view any employee
            // Allow employees to view their own profile
            bool isAuthorized = userRoles.Contains("System Administrator") || 
                              userRoles.Contains("HR Administrator") || 
                              userRoles.Contains("Line Manager") ||
                              (id.HasValue && id.Value == userId.Value);

            if (!isAuthorized)
            {
                TempData["ErrorMessage"] = "Access denied. Only administrators and managers can view full employee details.";
                return RedirectToAction("MyProfile");
            }

            if (id == null)
            {
                return NotFound();
            }

            var employee = await _context.Employees
                .Include(e => e.Contract)
                .Include(e => e.Department)
                .Include(e => e.Manager)
                .Include(e => e.Paygrade)
                .Include(e => e.Position)
                .Include(e => e.SalaryType)
                .Include(e => e.Taxform)
                .FirstOrDefaultAsync(m => m.EmployeeId == id);
            if (employee == null)
            {
                return NotFound();
            }

            return View(employee);
        }

        // GET: Employees/Create
        public IActionResult Create()
        {
            ViewData["ContractId"] = new SelectList(_context.Contracts, "ContractId", "ContractId");
            ViewData["DepartmentId"] = new SelectList(_context.Departments, "DepartmentId", "DepartmentId");
            ViewData["ManagerId"] = new SelectList(_context.Employees, "EmployeeId", "EmployeeId");
            ViewData["PaygradeId"] = new SelectList(_context.PayGrades, "PayGradeId", "PayGradeId");
            ViewData["PositionId"] = new SelectList(_context.Positions, "PositionId", "PositionId");
            ViewData["SalaryTypeId"] = new SelectList(_context.SalaryTypes, "SalaryTypeId", "SalaryTypeId");
            ViewData["TaxformId"] = new SelectList(_context.TaxForms, "TaxFormId", "TaxFormId");
            return View();
        }

        // POST: Employees/Create
        // To protect from overposting attacks, enable the specific properties you want to bind to.
        // For more details, see http://go.microsoft.com/fwlink/?LinkId=317598.
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Create([Bind("EmployeeId,FirstName,LastName,FullName,NationalId,DateOfBirth,CountryOfBirth,Phone,Email,Address,EmergencyContactName,EmergencyContactPhone,Relationship,Biography,EmploymentProgress,AccountStatus,EmploymentStatus,HireDate,IsActive,DepartmentId,PositionId,PaygradeId,TaxformId,ManagerId,SalaryTypeId,ContractId,ProfileCompletionPercentage")] Employee employee)
        {
            if (ModelState.IsValid)
            {
                try
                {
                    // Construct FullName from FirstName and LastName (required by SP)
                    string fullName = $"{employee.FirstName ?? ""} {employee.LastName ?? ""}".Trim();
                    if (string.IsNullOrEmpty(fullName))
                    {
                        ModelState.AddModelError("", "Full name is required.");
                        return View(employee);
                    }

                    // Prepare SP parameters (map Employee model to SP inputs)
                    var parameters = new[]
                    {
                        new SqlParameter("@FullName", fullName),
                        new SqlParameter("@NationalID", employee.NationalId ?? (object)DBNull.Value),
                        new SqlParameter("@DateOfBirth", employee.DateOfBirth ?? (object)DBNull.Value),
                        new SqlParameter("@CountryOfBirth", employee.CountryOfBirth ?? (object)DBNull.Value),
                        new SqlParameter("@Phone", employee.Phone ?? (object)DBNull.Value),
                        new SqlParameter("@Email", employee.Email ?? (object)DBNull.Value),  // Required
                        new SqlParameter("@Address", employee.Address ?? (object)DBNull.Value),
                        new SqlParameter("@EmergencyContactName", employee.EmergencyContactName ?? (object)DBNull.Value),
                        new SqlParameter("@EmergencyContactPhone", employee.EmergencyContactPhone ?? (object)DBNull.Value),
                        new SqlParameter("@Relationship", employee.Relationship ?? (object)DBNull.Value),
                        new SqlParameter("@Biography", employee.Biography ?? (object)DBNull.Value),
                        new SqlParameter("@EmploymentProgress", employee.EmploymentProgress ?? (object)DBNull.Value),
                        new SqlParameter("@AccountStatus", employee.AccountStatus ?? (object)DBNull.Value),
                        new SqlParameter("@EmploymentStatus", employee.EmploymentStatus ?? (object)DBNull.Value),
                        new SqlParameter("@HireDate", employee.HireDate ?? (object)DBNull.Value),
                        new SqlParameter("@IsActive", employee.IsActive ?? true),  // Default to 1 if null
                        new SqlParameter("@ProfileCompletion", employee.ProfileCompletionPercentage ?? (object)DBNull.Value),
                        new SqlParameter("@DepartmentID", employee.DepartmentId ?? (object)DBNull.Value),
                        new SqlParameter("@PositionID", employee.PositionId ?? (object)DBNull.Value),
                        new SqlParameter("@ManagerID", employee.ManagerId ?? (object)DBNull.Value),
                        new SqlParameter("@ContractID", employee.ContractId ?? (object)DBNull.Value),
                        new SqlParameter("@TaxFormID", employee.TaxformId ?? (object)DBNull.Value),
                        new SqlParameter("@SalaryTypeID", employee.SalaryTypeId ?? (object)DBNull.Value),
                        new SqlParameter("@PayGrade", employee.Paygrade?.GradeName ?? (object)DBNull.Value),  // Assuming PayGrade has GradeName
                        new SqlParameter("@NewEmployeeID", SqlDbType.Int) { Direction = ParameterDirection.Output }
                    };

                    // Execute the stored procedure
                    await _context.Database.ExecuteSqlRawAsync(
                        "EXEC dbo.AddEmployee @FullName, @NationalID, @DateOfBirth, @CountryOfBirth, @Phone, @Email, @Address, " +
                        "@EmergencyContactName, @EmergencyContactPhone, @Relationship, @Biography, @EmploymentProgress, " +
                        "@AccountStatus, @EmploymentStatus, @HireDate, @IsActive, @ProfileCompletion, @DepartmentID, " +
                        "@PositionID, @ManagerID, @ContractID, @TaxFormID, @SalaryTypeID, @PayGrade, @NewEmployeeID OUTPUT",
                        parameters
                    );

                    // Retrieve the new EmployeeID from output parameter
                    var newEmployeeId = (int)parameters[parameters.Length - 1].Value;

                    // Redirect to Details view for the new employee
                    return RedirectToAction("Details", new { id = newEmployeeId });
                }
                catch (System.Exception ex)
                {
                    // Handle SP errors (e.g., validation failures)
                    ModelState.AddModelError("", $"Error creating employee: {ex.Message}");
                }
            }

            // Repopulate ViewData for dropdowns if validation fails
            ViewData["ContractId"] = new SelectList(_context.Contracts, "ContractId", "ContractId", employee.ContractId);
            ViewData["DepartmentId"] = new SelectList(_context.Departments, "DepartmentId", "DepartmentId", employee.DepartmentId);
            ViewData["ManagerId"] = new SelectList(_context.Employees, "EmployeeId", "EmployeeId", employee.ManagerId);
            ViewData["PaygradeId"] = new SelectList(_context.PayGrades, "PayGradeId", "PayGradeId", employee.PaygradeId);
            ViewData["PositionId"] = new SelectList(_context.Positions, "PositionId", "PositionId", employee.PositionId);
            ViewData["SalaryTypeId"] = new SelectList(_context.SalaryTypes, "SalaryTypeId", "SalaryTypeId", employee.SalaryTypeId);
            ViewData["TaxformId"] = new SelectList(_context.TaxForms, "TaxFormId", "TaxFormId", employee.TaxformId);
            return View(employee);
        }

        // GET: Employees/Edit/5
        public async Task<IActionResult> Edit(int? id)
        {
            // Check if user is HR Administrator
            var userRoles = HttpContext.Session.GetString("UserRoles");
            if (string.IsNullOrEmpty(userRoles) || !userRoles.Contains("HR Administrator"))
            {
                TempData["ErrorMessage"] = "Access denied. Only HR Administrators can edit employee details.";
                return RedirectToAction("Index", "Home");
            }

            if (id == null)
            {
                return NotFound();
            }

            var employee = await _context.Employees.FindAsync(id);
            if (employee == null)
            {
                return NotFound();
            }
            ViewData["ContractId"] = new SelectList(_context.Contracts, "ContractId", "ContractId", employee.ContractId);
            ViewData["DepartmentId"] = new SelectList(_context.Departments, "DepartmentId", "DepartmentId", employee.DepartmentId);
            ViewData["ManagerId"] = new SelectList(_context.Employees, "EmployeeId", "EmployeeId", employee.ManagerId);
            ViewData["PaygradeId"] = new SelectList(_context.PayGrades, "PayGradeId", "PayGradeId", employee.PaygradeId);
            ViewData["PositionId"] = new SelectList(_context.Positions, "PositionId", "PositionId", employee.PositionId);
            ViewData["SalaryTypeId"] = new SelectList(_context.SalaryTypes, "SalaryTypeId", "SalaryTypeId", employee.SalaryTypeId);
            ViewData["TaxformId"] = new SelectList(_context.TaxForms, "TaxFormId", "TaxFormId", employee.TaxformId);
            return View(employee);
        }

        // POST: Employees/Edit/5
        // To protect from overposting attacks, enable the specific properties you want to bind to.
        // For more details, see http://go.microsoft.com/fwlink/?LinkId=317598.
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Edit(int id, [Bind("EmployeeId,FirstName,LastName,FullName,NationalId,DateOfBirth,CountryOfBirth,Phone,Email,Address,EmergencyContactName,EmergencyContactPhone,Relationship,Biography,EmploymentProgress,AccountStatus,EmploymentStatus,HireDate,IsActive,DepartmentId,PositionId,PaygradeId,TaxformId,ManagerId,SalaryTypeId,ContractId,ProfileCompletionPercentage")] Employee employee)
        {
            // Check if user is HR Administrator
            var userRoles = HttpContext.Session.GetString("UserRoles");
            if (string.IsNullOrEmpty(userRoles) || !userRoles.Contains("HR Administrator"))
            {
                TempData["ErrorMessage"] = "Access denied. Only HR Administrators can edit employee details.";
                return RedirectToAction("Index", "Home");
            }

            if (id != employee.EmployeeId)
            {
                return NotFound();
            }

            if (ModelState.IsValid)
            {
                try
                {
                    _context.Update(employee);
                    await _context.SaveChangesAsync();
                }
                catch (DbUpdateConcurrencyException)
                {
                    if (!EmployeeExists(employee.EmployeeId))
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
            ViewData["ContractId"] = new SelectList(_context.Contracts, "ContractId", "ContractId", employee.ContractId);
            ViewData["DepartmentId"] = new SelectList(_context.Departments, "DepartmentId", "DepartmentId", employee.DepartmentId);
            ViewData["ManagerId"] = new SelectList(_context.Employees, "EmployeeId", "EmployeeId", employee.ManagerId);
            ViewData["PaygradeId"] = new SelectList(_context.PayGrades, "PayGradeId", "PayGradeId", employee.PaygradeId);
            ViewData["PositionId"] = new SelectList(_context.Positions, "PositionId", "PositionId", employee.PositionId);
            ViewData["SalaryTypeId"] = new SelectList(_context.SalaryTypes, "SalaryTypeId", "SalaryTypeId", employee.SalaryTypeId);
            ViewData["TaxformId"] = new SelectList(_context.TaxForms, "TaxFormId", "TaxFormId", employee.TaxformId);
            return View(employee);
        }

        // GET: Employees/Delete/5
        public async Task<IActionResult> Delete(int? id)
        {
            // Check if user is HR Administrator
            var userRoles = HttpContext.Session.GetString("UserRoles");
            if (string.IsNullOrEmpty(userRoles) || !userRoles.Contains("HR Administrator"))
            {
                TempData["ErrorMessage"] = "Access denied. Only HR Administrators can delete employees.";
                return RedirectToAction("Index", "Home");
            }

            if (id == null)
            {
                return NotFound();
            }

            var employee = await _context.Employees
                .Include(e => e.Contract)
                .Include(e => e.Department)
                .Include(e => e.Manager)
                .Include(e => e.Paygrade)
                .Include(e => e.Position)
                .Include(e => e.SalaryType)
                .Include(e => e.Taxform)
                .FirstOrDefaultAsync(m => m.EmployeeId == id);
            if (employee == null)
            {
                return NotFound();
            }

            return View(employee);
        }

        // POST: Employees/Delete/5
        [HttpPost, ActionName("Delete")]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> DeleteConfirmed(int id)
        {
            // Check if user is HR Administrator
            var userRoles = HttpContext.Session.GetString("UserRoles");
            if (string.IsNullOrEmpty(userRoles) || !userRoles.Contains("HR Administrator"))
            {
                TempData["ErrorMessage"] = "Access denied. Only HR Administrators can delete employees.";
                return RedirectToAction("Index", "Home");
            }

            try
            {
                var employee = await _context.Employees.FindAsync(id);
                if (employee != null)
                {
                    // Instead of deleting, deactivate the employee to avoid foreign key constraint issues
                    employee.IsActive = false;
                    employee.AccountStatus = "INACTIVE";
                    employee.EmploymentStatus = "Terminated";
                    await _context.SaveChangesAsync();
                    TempData["SuccessMessage"] = "Employee deactivated successfully!";
                }
                else
                {
                    TempData["ErrorMessage"] = "Employee not found.";
                }
            }
            catch (SystemException ex)
            {
                TempData["ErrorMessage"] = $"Error deactivating employee: {ex.Message}";
            }

            return RedirectToAction(nameof(Index));
        }

        private bool EmployeeExists(int id)
        {
            return _context.Employees.Any(e => e.EmployeeId == id);
        }

        // GET: Employees/MyProfile
        public async Task<IActionResult> MyProfile()
        {
            var userId = HttpContext.Session.GetInt32("UserId");
            if (userId == null)
            {
                TempData["ErrorMessage"] = "Please login to view your profile.";
                return RedirectToAction("Login", "Account");
            }

            var employee = await _context.Employees
                .Include(e => e.Contract)
                .Include(e => e.Department)
                .Include(e => e.Manager)
                .Include(e => e.Paygrade)
                .Include(e => e.Position)
                .Include(e => e.SalaryType)
                .Include(e => e.Taxform)
                .FirstOrDefaultAsync(m => m.EmployeeId == userId.Value);

            if (employee == null)
            {
                return NotFound();
            }

            return View(employee);
        }

        // GET: Employees/EditProfile
        public async Task<IActionResult> EditProfile()
        {
            var userId = HttpContext.Session.GetInt32("UserId");
            if (userId == null)
            {
                TempData["ErrorMessage"] = "Please login to edit your profile.";
                return RedirectToAction("Login", "Account");
            }

            var employee = await _context.Employees.FindAsync(userId.Value);
            if (employee == null)
            {
                return NotFound();
            }

            return View(employee);
        }

        // POST: Employees/EditProfile
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> EditProfile([Bind("EmployeeId,Phone,Email,Address,EmergencyContactName,EmergencyContactPhone,Relationship,Biography,CountryOfBirth,NationalId")] Employee employee, IFormFile ProfileImageFile)
        {
            var userId = HttpContext.Session.GetInt32("UserId");
            if (userId == null || userId.Value != employee.EmployeeId)
            {
                TempData["ErrorMessage"] = "You can only edit your own profile.";
                return RedirectToAction("Login", "Account");
            }

            try
            {
                // Use UpdateEmployeeInfo stored procedure
                var parameters = new[]
                {
                    new SqlParameter("@EmployeeID", employee.EmployeeId),
                    new SqlParameter("@Email", employee.Email ?? (object)DBNull.Value),
                    new SqlParameter("@Phone", employee.Phone ?? (object)DBNull.Value),
                    new SqlParameter("@Address", employee.Address ?? (object)DBNull.Value)
                };

                await _context.Database.ExecuteSqlRawAsync(
                    "EXEC dbo.UpdateEmployeeInfo @EmployeeID, NULL, @Email, @Phone, @Address",
                    parameters
                );

                // Update emergency contact information, biography, and profile image directly
                var existingEmployee = await _context.Employees.FindAsync(employee.EmployeeId);
                if (existingEmployee != null)
                {
                    existingEmployee.EmergencyContactName = employee.EmergencyContactName;
                    existingEmployee.EmergencyContactPhone = employee.EmergencyContactPhone;
                    existingEmployee.Relationship = employee.Relationship;
                    existingEmployee.Biography = employee.Biography;
                    existingEmployee.CountryOfBirth = employee.CountryOfBirth;
                    existingEmployee.NationalId = employee.NationalId;
                    
                    // Handle profile image upload
                    if (ProfileImageFile != null && ProfileImageFile.Length > 0)
                    {
                        // Validate file size (2MB max)
                        if (ProfileImageFile.Length > 2 * 1024 * 1024)
                        {
                            ModelState.AddModelError("", "Profile image must be less than 2MB.");
                            return View(employee);
                        }

                        // Validate file type
                        var allowedExtensions = new[] { ".jpg", ".jpeg", ".png", ".gif" };
                        var extension = Path.GetExtension(ProfileImageFile.FileName).ToLowerInvariant();
                        if (!allowedExtensions.Contains(extension))
                        {
                            ModelState.AddModelError("", "Only JPG, PNG, and GIF images are allowed.");
                            return View(employee);
                        }

                        // Convert file to byte array
                        using (var memoryStream = new MemoryStream())
                        {
                            await ProfileImageFile.CopyToAsync(memoryStream);
                            existingEmployee.ProfileImage = memoryStream.ToArray();
                        }
                    }
                    
                    // Calculate profile completion percentage
                    int completedFields = 0;
                    int totalFields = 8;
                    
                    if (!string.IsNullOrWhiteSpace(existingEmployee.Email)) completedFields++;
                    if (!string.IsNullOrWhiteSpace(existingEmployee.Phone)) completedFields++;
                    if (!string.IsNullOrWhiteSpace(existingEmployee.Address)) completedFields++;
                    if (!string.IsNullOrWhiteSpace(existingEmployee.EmergencyContactName)) completedFields++;
                    if (!string.IsNullOrWhiteSpace(existingEmployee.EmergencyContactPhone)) completedFields++;
                    if (!string.IsNullOrWhiteSpace(existingEmployee.Relationship)) completedFields++;
                    if (!string.IsNullOrWhiteSpace(existingEmployee.Biography)) completedFields++;
                    if (existingEmployee.ProfileImage != null && existingEmployee.ProfileImage.Length > 0) completedFields++;
                    
                    existingEmployee.ProfileCompletionPercentage = (int)Math.Round((completedFields / (double)totalFields) * 100);
                    
                    await _context.SaveChangesAsync();
                }

                TempData["SuccessMessage"] = "Profile updated successfully!";
                return RedirectToAction(nameof(MyProfile));
            }
            catch (SystemException ex)
            {
                ModelState.AddModelError("", $"Error updating profile: {ex.Message}");
            }

            return View(employee);
        }

        // GET: Employees/MyTeam (For Line Managers)
        public async Task<IActionResult> MyTeam()
        {
            var userId = HttpContext.Session.GetInt32("UserId");
            var userRoles = HttpContext.Session.GetString("UserRoles");

            if (userId == null)
            {
                TempData["ErrorMessage"] = "Please login to view your team.";
                return RedirectToAction("Login", "Account");
            }

            if (string.IsNullOrEmpty(userRoles) || !userRoles.Contains("Line Manager"))
            {
                TempData["ErrorMessage"] = "Access denied. Only Line Managers can view team details.";
                return RedirectToAction("Index", "Home");
            }

            try
            {
                // Use GetTeamByManager stored procedure
                var teamMembers = await _context.Employees
                    .FromSqlRaw("EXEC dbo.GetTeamByManager @ManagerID", new SqlParameter("@ManagerID", userId.Value))
                    .ToListAsync();

                // Load related data separately to avoid composability issues
                var departmentIds = teamMembers.Where(e => e.DepartmentId.HasValue).Select(e => e.DepartmentId.Value).Distinct().ToList();
                var positionIds = teamMembers.Where(e => e.PositionId.HasValue).Select(e => e.PositionId.Value).Distinct().ToList();
                
                // Load all required departments in a single query
                var departments = await _context.Departments
                    .Where(d => departmentIds.Contains(d.DepartmentId))
                    .ToListAsync();
                
                // Load all required positions in a single query
                var positions = await _context.Positions
                    .Where(p => positionIds.Contains(p.PositionId))
                    .ToListAsync();

                // Create lookup dictionaries for efficient matching
                var departmentLookup = departments.ToDictionary(d => d.DepartmentId);
                var positionLookup = positions.ToDictionary(p => p.PositionId);

                // Manually set navigation properties
                foreach (var employee in teamMembers)
                {
                    if (employee.DepartmentId.HasValue && departmentLookup.ContainsKey(employee.DepartmentId.Value))
                    {
                        employee.Department = departmentLookup[employee.DepartmentId.Value];
                    }
                    if (employee.PositionId.HasValue && positionLookup.ContainsKey(employee.PositionId.Value))
                    {
                        employee.Position = positionLookup[employee.PositionId.Value];
                    }
                }

                ViewBag.ManagerName = HttpContext.Session.GetString("UserName");
                return View(teamMembers);
            }
            catch (SystemException ex)
            {
                TempData["ErrorMessage"] = $"Error retrieving team: {ex.Message}";
                return RedirectToAction("Index", "Home");
            }
        }

        // GET: Employees/ManageRoles (For System Administrators)
        public async Task<IActionResult> ManageRoles(int? id)
        {
            var userRoles = HttpContext.Session.GetString("UserRoles");
            if (string.IsNullOrEmpty(userRoles) || !userRoles.Contains("System Administrator"))
            {
                TempData["ErrorMessage"] = "Access denied. Only System Administrators can manage roles.";
                return RedirectToAction("Index", "Home");
            }

            if (id == null)
            {
                return NotFound();
            }

            var employee = await _context.Employees
                .Include(e => e.Department)
                .Include(e => e.Position)
                .FirstOrDefaultAsync(m => m.EmployeeId == id);

            if (employee == null)
            {
                return NotFound();
            }

            // Get current roles
            var currentRoles = await _context.Database
                .SqlQueryRaw<string>(
                    @"SELECT r.role_name 
                    FROM EmployeeRole er 
                    JOIN Role r ON er.role_id = r.RoleID 
                    WHERE er.employee_id = @p0",
                    id.Value)
                .ToListAsync();

            ViewBag.CurrentRoles = currentRoles;
            ViewBag.AvailableRoles = new SelectList(new[]
            {
                "System Administrator",
                "HR Administrator",
                "Line Manager",
                "Payroll Specialist",
                "Employee"
            });

            return View(employee);
        }

        // POST: Employees/AssignRole
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> AssignRole(int employeeId, string role, string action)
        {
            var userRoles = HttpContext.Session.GetString("UserRoles");
            if (string.IsNullOrEmpty(userRoles) || !userRoles.Contains("System Administrator"))
            {
                TempData["ErrorMessage"] = "Access denied. Only System Administrators can manage roles.";
                return RedirectToAction("Index", "Home");
            }

            try
            {
                var parameters = new[]
                {
                    new SqlParameter("@UserID", employeeId),
                    new SqlParameter("@Role", role),
                    new SqlParameter("@Action", action)
                };

                await _context.Database.ExecuteSqlRawAsync(
                    "EXEC dbo.ManageUserAccounts @UserID, @Role, @Action",
                    parameters
                );

                TempData["SuccessMessage"] = $"Role {action.ToLower()}ed successfully!";
            }
            catch (SystemException ex)
            {
                TempData["ErrorMessage"] = $"Error managing role: {ex.Message}";
            }

            return RedirectToAction(nameof(ManageRoles), new { id = employeeId });
        }

        // GET: Employees/UpdateProfileCompletion (For HR Admins)
        public async Task<IActionResult> UpdateProfileCompletion(int? id)
        {
            var userRoles = HttpContext.Session.GetString("UserRoles");
            if (string.IsNullOrEmpty(userRoles) || !userRoles.Contains("HR Administrator"))
            {
                TempData["ErrorMessage"] = "Access denied. Only HR Administrators can manage profile completion.";
                return RedirectToAction("Index", "Home");
            }

            if (id == null)
            {
                return NotFound();
            }

            var employee = await _context.Employees
                .Include(e => e.Department)
                .Include(e => e.Position)
                .FirstOrDefaultAsync(m => m.EmployeeId == id);

            if (employee == null)
            {
                return NotFound();
            }

            return View(employee);
        }

        // POST: Employees/UpdateProfileCompletion
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> UpdateProfileCompletion(int id, int profileCompletionPercentage)
        {
            var userRoles = HttpContext.Session.GetString("UserRoles");
            if (string.IsNullOrEmpty(userRoles) || !userRoles.Contains("HR Administrator"))
            {
                TempData["ErrorMessage"] = "Access denied. Only HR Administrators can manage profile completion.";
                return RedirectToAction("Index", "Home");
            }

            try
            {
                var employee = await _context.Employees.FindAsync(id);
                if (employee != null)
                {
                    employee.ProfileCompletionPercentage = profileCompletionPercentage;
                    await _context.SaveChangesAsync();
                    TempData["SuccessMessage"] = "Profile completion updated successfully!";
                }
                else
                {
                    TempData["ErrorMessage"] = "Employee not found.";
                }
            }
            catch (SystemException ex)
            {
                TempData["ErrorMessage"] = $"Error updating profile completion: {ex.Message}";
            }

            return RedirectToAction(nameof(Details), new { id });
        }

        // GET: Employees/AssignTeamMember (For Line Managers)
        public async Task<IActionResult> AssignTeamMember()
        {
            var userRoles = HttpContext.Session.GetString("UserRoles");
            if (string.IsNullOrEmpty(userRoles) || !userRoles.Contains("Line Manager"))
            {
                TempData["ErrorMessage"] = "Access denied. Only Line Managers can assign team members.";
                return RedirectToAction("Index", "Home");
            }

            var userId = HttpContext.Session.GetInt32("UserId");
            if (userId == null)
            {
                TempData["ErrorMessage"] = "Please login to assign team members.";
                return RedirectToAction("Login", "Account");
            }

            // Get list of employees not currently assigned to any manager or assigned to this manager
            var availableEmployees = await _context.Employees
                .Where(e => e.IsActive == true && e.EmployeeId != userId.Value)
                .Select(e => new { e.EmployeeId, e.FullName, e.ManagerId })
                .ToListAsync();

            ViewData["EmployeeId"] = new SelectList(
                availableEmployees.Select(e => new { e.EmployeeId, DisplayText = $"{e.FullName} (ID: {e.EmployeeId})" + (e.ManagerId.HasValue ? " - Already assigned" : " - Unassigned") }),
                "EmployeeId", 
                "DisplayText");

            // Get list of all active employees who can be managers
            // Note: We cannot exclude the selected employee here since it's not chosen yet
            // Self-assignment prevention is handled in the POST action
            var managers = await _context.Employees
                .Where(e => e.IsActive == true)
                .OrderBy(e => e.FullName)
                .Select(e => new { e.EmployeeId, e.FullName })
                .ToListAsync();

            // Default selection is the current user (most common use case for line managers)
            ViewData["ManagerId"] = new SelectList(
                managers.Select(m => new { m.EmployeeId, DisplayText = $"{m.FullName} (ID: {m.EmployeeId})" }),
                "EmployeeId", 
                "DisplayText", 
                userId.Value);

            return View();
        }

        // POST: Employees/AssignTeamMember
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> AssignTeamMember(int employeeId, int managerId)
        {
            var userRoles = HttpContext.Session.GetString("UserRoles");
            if (string.IsNullOrEmpty(userRoles) || !userRoles.Contains("Line Manager"))
            {
                TempData["ErrorMessage"] = "Access denied. Only Line Managers can assign team members.";
                return RedirectToAction("Index", "Home");
            }

            var userId = HttpContext.Session.GetInt32("UserId");
            if (userId == null)
            {
                TempData["ErrorMessage"] = "Please login to assign team members.";
                return RedirectToAction("Login", "Account");
            }

            try
            {
                var employee = await _context.Employees.FindAsync(employeeId);
                if (employee != null)
                {
                    // Verify the manager exists and is active
                    var manager = await _context.Employees.FindAsync(managerId);
                    if (manager == null || manager.IsActive != true)
                    {
                        TempData["ErrorMessage"] = "The selected manager does not exist or is not active.";
                        return RedirectToAction(nameof(AssignTeamMember));
                    }

                    // Prevent self-assignment
                    if (employeeId == managerId)
                    {
                        TempData["ErrorMessage"] = "An employee cannot be assigned to themselves as their own manager.";
                        return RedirectToAction(nameof(AssignTeamMember));
                    }

                    // Update the employee's manager
                    employee.ManagerId = managerId;
                    await _context.SaveChangesAsync();

                    TempData["SuccessMessage"] = $"Success! Employee {employee.FullName} has been assigned to the selected manager.";
                    return RedirectToAction(nameof(MyTeam));
                }
                else
                {
                    TempData["ErrorMessage"] = "Employee not found.";
                }
            }
            catch (SystemException ex)
            {
                TempData["ErrorMessage"] = $"Error assigning team member: {ex.Message}";
            }

            return RedirectToAction(nameof(AssignTeamMember));
        }

        // POST: Employees/RemoveTeamMember (For Line Managers)
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> RemoveTeamMember(int employeeId)
        {
            var userRoles = HttpContext.Session.GetString("UserRoles");
            var userId = HttpContext.Session.GetInt32("UserId");

            if (string.IsNullOrEmpty(userRoles) || !userRoles.Contains("Line Manager") || userId == null)
            {
                TempData["ErrorMessage"] = "Access denied. Only Line Managers can remove team members.";
                return RedirectToAction("Index", "Home");
            }

            try
            {
                var employee = await _context.Employees.FindAsync(employeeId);
                if (employee != null)
                {
                    // Verify that this employee is under the current manager
                    if (employee.ManagerId == userId.Value)
                    {
                        employee.ManagerId = null;
                        await _context.SaveChangesAsync();
                        TempData["SuccessMessage"] = $"Employee {employee.FullName} has been removed from your team.";
                    }
                    else
                    {
                        TempData["ErrorMessage"] = "You can only remove employees from your own team.";
                    }
                }
                else
                {
                    TempData["ErrorMessage"] = "Employee not found.";
                }
            }
            catch (SystemException ex)
            {
                TempData["ErrorMessage"] = $"Error removing team member: {ex.Message}";
            }

            return RedirectToAction(nameof(MyTeam));
        }
    }
}
