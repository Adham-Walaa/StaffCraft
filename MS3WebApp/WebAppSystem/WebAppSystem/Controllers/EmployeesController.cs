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
            var employee = await _context.Employees.FindAsync(id);
            if (employee != null)
            {
                _context.Employees.Remove(employee);
            }

            await _context.SaveChangesAsync();
            return RedirectToAction(nameof(Index));
        }

        private bool EmployeeExists(int id)
        {
            return _context.Employees.Any(e => e.EmployeeId == id);
        }
    }
}
