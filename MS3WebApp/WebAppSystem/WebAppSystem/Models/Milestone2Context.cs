using System;
using System.Collections.Generic;
using Microsoft.EntityFrameworkCore;

namespace WebAppSystem.Models;

public partial class Milestone2Context : DbContext
{
    public Milestone2Context()
    {
    }

    public Milestone2Context(DbContextOptions<Milestone2Context> options)
        : base(options)
    {
    }

    public virtual DbSet<AllowanceDeduction> AllowanceDeductions { get; set; }

    public virtual DbSet<ApprovalWorkflow> ApprovalWorkflows { get; set; }

    public virtual DbSet<ApprovalWorkflowStep> ApprovalWorkflowSteps { get; set; }

    public virtual DbSet<Attendance> Attendances { get; set; }

    public virtual DbSet<AttendanceCorrectionRequest> AttendanceCorrectionRequests { get; set; }

    public virtual DbSet<AttendanceLog> AttendanceLogs { get; set; }

    public virtual DbSet<AttendanceSource> AttendanceSources { get; set; }

    public virtual DbSet<BonusPolicy> BonusPolicies { get; set; }

    public virtual DbSet<ConsultantContract> ConsultantContracts { get; set; }

    public virtual DbSet<Contract> Contracts { get; set; }

    public virtual DbSet<ContractSalaryType> ContractSalaryTypes { get; set; }

    public virtual DbSet<Currency> Currencies { get; set; }

    public virtual DbSet<DeductionPolicy> DeductionPolicies { get; set; }

    public virtual DbSet<Department> Departments { get; set; }

    public virtual DbSet<Device> Devices { get; set; }

    public virtual DbSet<Employee> Employees { get; set; }

    public virtual DbSet<EmployeeException> EmployeeExceptions { get; set; }

    public virtual DbSet<EmployeeHierarchy> EmployeeHierarchies { get; set; }

    public virtual DbSet<EmployeeNotification> EmployeeNotifications { get; set; }

    public virtual DbSet<EmployeeRole> EmployeeRoles { get; set; }

    public virtual DbSet<EmployeeSkill> EmployeeSkills { get; set; }

    public virtual DbSet<EmployeeVerification> EmployeeVerifications { get; set; }

    public virtual DbSet<Exception> Exceptions { get; set; }

    public virtual DbSet<FullTimeContract> FullTimeContracts { get; set; }

    public virtual DbSet<HolidayLeave> HolidayLeaves { get; set; }

    public virtual DbSet<HourlySalaryType> HourlySalaryTypes { get; set; }

    public virtual DbSet<Hradministrator> Hradministrators { get; set; }

    public virtual DbSet<Insurance> Insurances { get; set; }

    public virtual DbSet<InternshipContract> InternshipContracts { get; set; }

    public virtual DbSet<LatenessPolicy> LatenessPolicies { get; set; }

    public virtual DbSet<Leave> Leaves { get; set; }

    public virtual DbSet<LeaveDocument> LeaveDocuments { get; set; }

    public virtual DbSet<LeaveEntitlement> LeaveEntitlements { get; set; }

    public virtual DbSet<LeavePolicy> LeavePolicies { get; set; }

    public virtual DbSet<LeaveRequest> LeaveRequests { get; set; }

    public virtual DbSet<LineManager> LineManagers { get; set; }

    public virtual DbSet<ManagerNote> ManagerNotes { get; set; }

    public virtual DbSet<Mission> Missions { get; set; }

    public virtual DbSet<MonthlySalaryType> MonthlySalaryTypes { get; set; }

    public virtual DbSet<Notification> Notifications { get; set; }

    public virtual DbSet<OfflineAttendanceQueue> OfflineAttendanceQueues { get; set; }

    public virtual DbSet<OvertimePolicy> OvertimePolicies { get; set; }

    public virtual DbSet<PartTimeContract> PartTimeContracts { get; set; }

    public virtual DbSet<PayGrade> PayGrades { get; set; }

    public virtual DbSet<Payroll> Payrolls { get; set; }

    public virtual DbSet<PayrollLog> PayrollLogs { get; set; }

    public virtual DbSet<PayrollPeriod> PayrollPeriods { get; set; }

    public virtual DbSet<PayrollPolicy> PayrollPolicies { get; set; }

    public virtual DbSet<PayrollPolicyId> PayrollPolicyIds { get; set; }

    public virtual DbSet<PayrollSpecialist> PayrollSpecialists { get; set; }

    public virtual DbSet<Position> Positions { get; set; }

    public virtual DbSet<ProbationLeave> ProbationLeaves { get; set; }

    public virtual DbSet<Reimbursement> Reimbursements { get; set; }

    public virtual DbSet<Role> Roles { get; set; }

    public virtual DbSet<RolePermission> RolePermissions { get; set; }

    public virtual DbSet<SalaryType> SalaryTypes { get; set; }

    public virtual DbSet<ShiftCycle> ShiftCycles { get; set; }

    public virtual DbSet<ShiftCycleAssignment> ShiftCycleAssignments { get; set; }

    public virtual DbSet<ShiftSchedule> ShiftSchedules { get; set; }

    public virtual DbSet<SickLeave> SickLeaves { get; set; }

    public virtual DbSet<Skill> Skills { get; set; }

    public virtual DbSet<SplitShiftConfiguration> SplitShiftConfigurations { get; set; }

    public virtual DbSet<SystemAdministrator> SystemAdministrators { get; set; }

    public virtual DbSet<SystemConfiguration> SystemConfigurations { get; set; }

    public virtual DbSet<TaxForm> TaxForms { get; set; }

    public virtual DbSet<Termination> Terminations { get; set; }

    public virtual DbSet<VacationLeave> VacationLeaves { get; set; }

    public virtual DbSet<Verification> Verifications { get; set; }

    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
#warning To protect potentially sensitive information in your connection string, you should move it out of source code. You can avoid scaffolding the connection string by using the Name= syntax to read it from configuration - see https://go.microsoft.com/fwlink/?linkid=2131148. For more guidance on storing connection strings, see https://go.microsoft.com/fwlink/?LinkId=723263.
        => optionsBuilder.UseSqlServer("Server=(localdb)\\MSSQLLocalDB;Database=MILESTONE2;Trusted_Connection=True;");

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<AllowanceDeduction>(entity =>
        {
            entity.HasKey(e => e.AllowanceDeductionId).HasName("PK__Allowanc__871DED5BE63E4D26");

            entity.ToTable("AllowanceDeduction");

            entity.Property(e => e.AllowanceDeductionId)
                .ValueGeneratedNever()
                .HasColumnName("AllowanceDeductionID");
            entity.Property(e => e.Amount)
                .HasColumnType("decimal(18, 2)")
                .HasColumnName("amount");
            entity.Property(e => e.Currency)
                .HasMaxLength(10)
                .IsUnicode(false)
                .HasColumnName("currency");
            entity.Property(e => e.Duration).HasColumnName("duration");
            entity.Property(e => e.EmployeeId).HasColumnName("employee_id");
            entity.Property(e => e.PayrollId).HasColumnName("payroll_id");
            entity.Property(e => e.Timezone)
                .HasMaxLength(50)
                .IsUnicode(false)
                .HasColumnName("timezone");
            entity.Property(e => e.Type)
                .HasMaxLength(50)
                .IsUnicode(false)
                .HasColumnName("type");

            entity.HasOne(d => d.CurrencyNavigation).WithMany(p => p.AllowanceDeductions)
                .HasForeignKey(d => d.Currency)
                .HasConstraintName("FK_AllowanceDeduction_Currency");

            entity.HasOne(d => d.Employee).WithMany(p => p.AllowanceDeductions)
                .HasForeignKey(d => d.EmployeeId)
                .HasConstraintName("FK_AllowanceDeduction_Employee");

            entity.HasOne(d => d.Payroll).WithMany(p => p.AllowanceDeductions)
                .HasForeignKey(d => d.PayrollId)
                .HasConstraintName("FK_AllowanceDeduction_Payroll");
        });

        modelBuilder.Entity<ApprovalWorkflow>(entity =>
        {
            entity.HasKey(e => e.WorkflowId).HasName("PK__Approval__5704A64A188E702B");

            entity.ToTable("ApprovalWorkflow");

            entity.Property(e => e.WorkflowId)
                .ValueGeneratedNever()
                .HasColumnName("WorkflowID");
            entity.Property(e => e.ApprovedRole)
                .HasMaxLength(100)
                .IsUnicode(false)
                .HasColumnName("approved_role");
            entity.Property(e => e.CreatedBy).HasColumnName("created_by");
            entity.Property(e => e.Status)
                .HasMaxLength(50)
                .IsUnicode(false)
                .HasColumnName("status");
            entity.Property(e => e.ThresholdAmount)
                .HasColumnType("decimal(18, 2)")
                .HasColumnName("threshold_amount");
            entity.Property(e => e.WorkflowType)
                .HasMaxLength(100)
                .IsUnicode(false)
                .HasColumnName("workflow_type");

            entity.HasOne(d => d.CreatedByNavigation).WithMany(p => p.ApprovalWorkflows)
                .HasForeignKey(d => d.CreatedBy)
                .HasConstraintName("FK_ApprovalWorkflow_CreatedBy");
        });

        modelBuilder.Entity<ApprovalWorkflowStep>(entity =>
        {
            entity
                .HasNoKey()
                .ToTable("ApprovalWorkflowStep");

            entity.Property(e => e.ActionRequired)
                .HasMaxLength(100)
                .IsUnicode(false)
                .HasColumnName("action_required");
            entity.Property(e => e.RoleId).HasColumnName("role_id");
            entity.Property(e => e.StepNumber).HasColumnName("step_number");
            entity.Property(e => e.WorkflowId).HasColumnName("workflow_id");

            entity.HasOne(d => d.Role).WithMany()
                .HasForeignKey(d => d.RoleId)
                .HasConstraintName("FK_ApprovalWorkflowStep_Role");

            entity.HasOne(d => d.Workflow).WithMany()
                .HasForeignKey(d => d.WorkflowId)
                .HasConstraintName("FK_ApprovalWorkflowStep_Workflow");
        });

        modelBuilder.Entity<Attendance>(entity =>
        {
            entity.HasKey(e => e.AttendanceId).HasName("PK__Attendan__8B69263C4437956B");

            entity.ToTable("Attendance");

            entity.Property(e => e.AttendanceId)
                .ValueGeneratedNever()
                .HasColumnName("AttendanceID");
            entity.Property(e => e.Duration).HasColumnName("duration");
            entity.Property(e => e.EmployeeId).HasColumnName("employee_id");
            entity.Property(e => e.EntryTime).HasColumnName("entry_time");
            entity.Property(e => e.ExceptionId).HasColumnName("exception_id");
            entity.Property(e => e.ExitTime).HasColumnName("exit_time");
            entity.Property(e => e.LoginMethod)
                .HasMaxLength(50)
                .IsUnicode(false)
                .HasColumnName("login_method");
            entity.Property(e => e.LogoutMethod)
                .HasMaxLength(50)
                .IsUnicode(false)
                .HasColumnName("logout_method");

            entity.HasOne(d => d.Employee).WithMany(p => p.Attendances)
                .HasForeignKey(d => d.EmployeeId)
                .HasConstraintName("FK_Attendance_Employee");

            entity.HasOne(d => d.Exception).WithMany(p => p.Attendances)
                .HasForeignKey(d => d.ExceptionId)
                .HasConstraintName("FK_Attendance_Exception");
        });

        modelBuilder.Entity<AttendanceCorrectionRequest>(entity =>
        {
            entity.HasKey(e => e.RequestId).HasName("PK__Attendan__33A8519AB479CE90");

            entity.ToTable("AttendanceCorrectionRequest");

            entity.Property(e => e.RequestId)
                .ValueGeneratedNever()
                .HasColumnName("RequestID");
            entity.Property(e => e.CorrectionType)
                .HasMaxLength(100)
                .IsUnicode(false)
                .HasColumnName("correction_type");
            entity.Property(e => e.Date).HasColumnName("date");
            entity.Property(e => e.EmployeeId).HasColumnName("employee_id");
            entity.Property(e => e.Reason)
                .HasColumnType("text")
                .HasColumnName("reason");
            entity.Property(e => e.RecommendedBy).HasColumnName("recommended_by");
            entity.Property(e => e.Status)
                .HasMaxLength(50)
                .IsUnicode(false)
                .HasColumnName("status");

            entity.HasOne(d => d.Employee).WithMany(p => p.AttendanceCorrectionRequestEmployees)
                .HasForeignKey(d => d.EmployeeId)
                .HasConstraintName("FK_AttendanceCorrectionRequest_Employee");

            entity.HasOne(d => d.RecommendedByNavigation).WithMany(p => p.AttendanceCorrectionRequestRecommendedByNavigations)
                .HasForeignKey(d => d.RecommendedBy)
                .HasConstraintName("FK_AttendanceCorrectionRequest_RecommendedBy");
        });

        modelBuilder.Entity<AttendanceLog>(entity =>
        {
            entity.HasKey(e => e.AttendanceLogId).HasName("PK__Attendan__6E3D7064A5DBE0DF");

            entity.ToTable("AttendanceLog");

            entity.Property(e => e.AttendanceLogId)
                .ValueGeneratedNever()
                .HasColumnName("AttendanceLogID");
            entity.Property(e => e.Actor)
                .HasMaxLength(100)
                .IsUnicode(false)
                .HasColumnName("actor");
            entity.Property(e => e.AttendanceId).HasColumnName("attendance_id");
            entity.Property(e => e.Reason)
                .HasColumnType("text")
                .HasColumnName("reason");
            entity.Property(e => e.Timestamp)
                .HasColumnType("datetime")
                .HasColumnName("timestamp");

            entity.HasOne(d => d.Attendance).WithMany(p => p.AttendanceLogs)
                .HasForeignKey(d => d.AttendanceId)
                .HasConstraintName("FK_AttendanceLog_Attendance");
        });

        modelBuilder.Entity<AttendanceSource>(entity =>
        {
            entity
                .HasNoKey()
                .ToTable("AttendanceSource");

            entity.Property(e => e.AttendanceId).HasColumnName("attendance_id");
            entity.Property(e => e.DeviceId).HasColumnName("device_id");
            entity.Property(e => e.Latitude)
                .HasColumnType("decimal(9, 6)")
                .HasColumnName("latitude");
            entity.Property(e => e.Longitude)
                .HasColumnType("decimal(9, 6)")
                .HasColumnName("longitude");
            entity.Property(e => e.RecordedAt)
                .HasColumnType("datetime")
                .HasColumnName("recorded_at");
            entity.Property(e => e.SourceType)
                .HasMaxLength(100)
                .IsUnicode(false)
                .HasColumnName("source_type");

            entity.HasOne(d => d.Attendance).WithMany()
                .HasForeignKey(d => d.AttendanceId)
                .HasConstraintName("FK_AttendanceSource_Attendance");

            entity.HasOne(d => d.Device).WithMany()
                .HasForeignKey(d => d.DeviceId)
                .HasConstraintName("FK_AttendanceSource_Device");
        });

        modelBuilder.Entity<BonusPolicy>(entity =>
        {
            entity
                .HasNoKey()
                .ToTable("BonusPolicy");

            entity.Property(e => e.BonusType)
                .HasMaxLength(100)
                .IsUnicode(false)
                .HasColumnName("bonus_type");
            entity.Property(e => e.EligibilityCriteria)
                .HasColumnType("text")
                .HasColumnName("eligibility_criteria");
            entity.Property(e => e.PolicyId).HasColumnName("policy_id");

            entity.HasOne(d => d.Policy).WithMany()
                .HasForeignKey(d => d.PolicyId)
                .HasConstraintName("FK_BonusPolicy_PayrollPolicy");
        });

        modelBuilder.Entity<ConsultantContract>(entity =>
        {
            entity
                .HasNoKey()
                .ToTable("ConsultantContract");

            entity.Property(e => e.ContractId).HasColumnName("contract_id");
            entity.Property(e => e.Fees)
                .HasColumnType("decimal(18, 2)")
                .HasColumnName("fees");
            entity.Property(e => e.PaymentSchedule)
                .HasMaxLength(100)
                .IsUnicode(false)
                .HasColumnName("payment_schedule");
            entity.Property(e => e.ProjectScope)
                .HasColumnType("text")
                .HasColumnName("project_scope");

            entity.HasOne(d => d.Contract).WithMany()
                .HasForeignKey(d => d.ContractId)
                .HasConstraintName("FK_ConsultantContract_Contract");
        });

        modelBuilder.Entity<Contract>(entity =>
        {
            entity.HasKey(e => e.ContractId).HasName("PK__Contract__C90D340962715157");

            entity.ToTable("Contract");

            entity.Property(e => e.ContractId)
                .ValueGeneratedNever()
                .HasColumnName("ContractID");
            entity.Property(e => e.CurrentState)
                .HasMaxLength(50)
                .IsUnicode(false)
                .HasColumnName("current_state");
            entity.Property(e => e.EndDate)
                .HasColumnType("datetime")
                .HasColumnName("end_date");
            entity.Property(e => e.StartDate)
                .HasColumnType("datetime")
                .HasColumnName("start_date");
            entity.Property(e => e.Type)
                .HasMaxLength(100)
                .IsUnicode(false)
                .HasColumnName("type");
        });

        modelBuilder.Entity<ContractSalaryType>(entity =>
        {
            entity
                .HasNoKey()
                .ToTable("ContractSalaryType");

            entity.Property(e => e.ContractValue)
                .HasColumnType("decimal(18, 2)")
                .HasColumnName("contract_value");
            entity.Property(e => e.InstallementDetails)
                .HasMaxLength(200)
                .IsUnicode(false)
                .HasColumnName("installement_details");
            entity.Property(e => e.SalaryTypeId).HasColumnName("salary_type_id");

            entity.HasOne(d => d.SalaryType).WithMany()
                .HasForeignKey(d => d.SalaryTypeId)
                .HasConstraintName("FK_ContractSalaryType_SalaryType");
        });

        modelBuilder.Entity<Currency>(entity =>
        {
            entity.HasKey(e => e.CurrencyCode).HasName("PK__Currency__408426BE471D1977");

            entity.ToTable("Currency");

            entity.Property(e => e.CurrencyCode)
                .HasMaxLength(10)
                .IsUnicode(false);
            entity.Property(e => e.CreatedDate)
                .HasColumnType("datetime")
                .HasColumnName("created_date");
            entity.Property(e => e.CurrencyName)
                .HasMaxLength(50)
                .IsUnicode(false)
                .HasColumnName("currency_name");
            entity.Property(e => e.ExchangeRate)
                .HasColumnType("decimal(18, 4)")
                .HasColumnName("exchange_rate");
            entity.Property(e => e.LastUpdated)
                .HasColumnType("datetime")
                .HasColumnName("last_updated");
        });

        modelBuilder.Entity<DeductionPolicy>(entity =>
        {
            entity
                .HasNoKey()
                .ToTable("DeductionPolicy");

            entity.Property(e => e.CalculationMode)
                .HasMaxLength(100)
                .IsUnicode(false)
                .HasColumnName("calculation_mode");
            entity.Property(e => e.DeductionReason)
                .HasMaxLength(100)
                .IsUnicode(false)
                .HasColumnName("deduction_reason");
            entity.Property(e => e.PolicyId).HasColumnName("policy_id");

            entity.HasOne(d => d.Policy).WithMany()
                .HasForeignKey(d => d.PolicyId)
                .HasConstraintName("FK_DeductionPolicy_PayrollPolicy");
        });

        modelBuilder.Entity<Department>(entity =>
        {
            entity.HasKey(e => e.DepartmentId).HasName("PK__Departme__B2079BCD5FC97460");

            entity.ToTable("Department");

            entity.Property(e => e.DepartmentId)
                .ValueGeneratedNever()
                .HasColumnName("DepartmentID");
            entity.Property(e => e.DepartmentHeadId).HasColumnName("department_head_id");
            entity.Property(e => e.DepartmentName)
                .HasMaxLength(100)
                .IsUnicode(false)
                .HasColumnName("department_name");
            entity.Property(e => e.Purpose)
                .HasColumnType("text")
                .HasColumnName("purpose");

            entity.HasOne(d => d.DepartmentHead).WithMany(p => p.Departments)
                .HasForeignKey(d => d.DepartmentHeadId)
                .HasConstraintName("FK_Department_Employee");
        });

        modelBuilder.Entity<Device>(entity =>
        {
            entity.HasKey(e => e.DeviceId).HasName("PK__Device__49E12331EB3A8F76");

            entity.ToTable("Device");

            entity.HasIndex(e => e.TerminalId, "UQ__Device__A7A7EB4055ED79D8").IsUnique();

            entity.Property(e => e.DeviceId)
                .ValueGeneratedNever()
                .HasColumnName("DeviceID");
            entity.Property(e => e.DeviceType)
                .HasMaxLength(100)
                .IsUnicode(false)
                .HasColumnName("device_type");
            entity.Property(e => e.EmployeeId).HasColumnName("employee_id");
            entity.Property(e => e.Latitude)
                .HasColumnType("decimal(9, 6)")
                .HasColumnName("latitude");
            entity.Property(e => e.Longitude)
                .HasColumnType("decimal(9, 6)")
                .HasColumnName("longitude");
            entity.Property(e => e.TerminalId)
                .HasMaxLength(100)
                .IsUnicode(false)
                .HasColumnName("terminal_id");

            entity.HasOne(d => d.Employee).WithMany(p => p.Devices)
                .HasForeignKey(d => d.EmployeeId)
                .HasConstraintName("FK_Device_Employee");
        });

        modelBuilder.Entity<Employee>(entity =>
        {
            entity.HasKey(e => e.EmployeeId).HasName("PK__Employee__7AD04FF123BC3560");

            entity.ToTable("Employee");

            entity.Property(e => e.EmployeeId)
                .ValueGeneratedNever()
                .HasColumnName("EmployeeID");
            entity.Property(e => e.AccountStatus)
                .HasMaxLength(50)
                .IsUnicode(false)
                .HasColumnName("account_status");
            entity.Property(e => e.Address)
                .HasMaxLength(200)
                .IsUnicode(false)
                .HasColumnName("address");
            entity.Property(e => e.Biography)
                .HasColumnType("text")
                .HasColumnName("biography");
            entity.Property(e => e.ContractId).HasColumnName("contract_id");
            entity.Property(e => e.CountryOfBirth)
                .HasMaxLength(50)
                .IsUnicode(false)
                .HasColumnName("country_of_birth");
            entity.Property(e => e.DateOfBirth)
                .HasColumnType("datetime")
                .HasColumnName("date_of_birth");
            entity.Property(e => e.DepartmentId).HasColumnName("department_id");
            entity.Property(e => e.Email)
                .HasMaxLength(100)
                .IsUnicode(false)
                .HasColumnName("email");
            entity.Property(e => e.EmergencyContactName)
                .HasMaxLength(100)
                .IsUnicode(false)
                .HasColumnName("emergency_contact_name");
            entity.Property(e => e.EmergencyContactPhone)
                .HasMaxLength(15)
                .IsUnicode(false)
                .HasColumnName("emergency_contact_phone");
            entity.Property(e => e.EmploymentProgress)
                .HasMaxLength(100)
                .IsUnicode(false)
                .HasColumnName("employment_progress");
            entity.Property(e => e.EmploymentStatus)
                .HasMaxLength(50)
                .IsUnicode(false)
                .HasColumnName("employment_status");
            entity.Property(e => e.FirstName)
                .HasMaxLength(50)
                .IsUnicode(false)
                .HasColumnName("first_name");
            entity.Property(e => e.FullName)
                .HasMaxLength(101)
                .IsUnicode(false)
                .HasComputedColumnSql("(([first_name]+' ')+[last_name])", true)
                .HasColumnName("full_name");
            entity.Property(e => e.HireDate)
                .HasColumnType("datetime")
                .HasColumnName("hire_date");
            entity.Property(e => e.IsActive)
                .HasDefaultValue(true)
                .HasColumnName("is_active");
            entity.Property(e => e.LastName)
                .HasMaxLength(50)
                .IsUnicode(false)
                .HasColumnName("last_name");
            entity.Property(e => e.ManagerId).HasColumnName("manager_id");
            entity.Property(e => e.NationalId)
                .HasMaxLength(20)
                .IsUnicode(false)
                .HasColumnName("national_id");
            entity.Property(e => e.PaygradeId).HasColumnName("paygrade_id");
            entity.Property(e => e.Phone)
                .HasMaxLength(15)
                .IsUnicode(false)
                .HasColumnName("phone");
            entity.Property(e => e.PositionId).HasColumnName("position_id");
            entity.Property(e => e.ProfileCompletionPercentage).HasColumnName("profile_completion_percentage");
            entity.Property(e => e.ProfileImage).HasColumnName("profile_image");
            entity.Property(e => e.Relationship)
                .HasMaxLength(50)
                .IsUnicode(false)
                .HasColumnName("relationship");
            entity.Property(e => e.SalaryTypeId).HasColumnName("salary_type_id");
            entity.Property(e => e.TaxformId).HasColumnName("taxform_id");

            entity.HasOne(d => d.Contract).WithMany(p => p.Employees)
                .HasForeignKey(d => d.ContractId)
                .HasConstraintName("FK_Employee_Contract");

            entity.HasOne(d => d.Department).WithMany(p => p.Employees)
                .HasForeignKey(d => d.DepartmentId)
                .HasConstraintName("FK_Employee_Department");

            entity.HasOne(d => d.Manager).WithMany(p => p.InverseManager)
                .HasForeignKey(d => d.ManagerId)
                .HasConstraintName("FK_Employee_Manager");

            entity.HasOne(d => d.Paygrade).WithMany(p => p.Employees)
                .HasForeignKey(d => d.PaygradeId)
                .HasConstraintName("FK_Employee_PayGrade");

            entity.HasOne(d => d.Position).WithMany(p => p.Employees)
                .HasForeignKey(d => d.PositionId)
                .HasConstraintName("FK_Employee_Position");

            entity.HasOne(d => d.SalaryType).WithMany(p => p.Employees)
                .HasForeignKey(d => d.SalaryTypeId)
                .HasConstraintName("FK_Employee_SalaryType");

            entity.HasOne(d => d.Taxform).WithMany(p => p.Employees)
                .HasForeignKey(d => d.TaxformId)
                .HasConstraintName("FK_Employee_TaxForm");
        });

        modelBuilder.Entity<EmployeeException>(entity =>
        {
            entity
                .HasNoKey()
                .ToTable("EmployeeException");

            entity.Property(e => e.EmployeeId).HasColumnName("employee_id");
            entity.Property(e => e.ExceptionId).HasColumnName("exception_id");

            entity.HasOne(d => d.Employee).WithMany()
                .HasForeignKey(d => d.EmployeeId)
                .HasConstraintName("FK_EmployeeException_Employee");

            entity.HasOne(d => d.Exception).WithMany()
                .HasForeignKey(d => d.ExceptionId)
                .HasConstraintName("FK_EmployeeException_Exception");
        });

        modelBuilder.Entity<EmployeeHierarchy>(entity =>
        {
            entity
                .HasNoKey()
                .ToTable("EmployeeHierarchy");

            entity.Property(e => e.EmployeeId).HasColumnName("employee_id");
            entity.Property(e => e.HierarchyLevel).HasColumnName("hierarchy_level");
            entity.Property(e => e.ManagerId).HasColumnName("manager_id");

            entity.HasOne(d => d.Employee).WithMany()
                .HasForeignKey(d => d.EmployeeId)
                .HasConstraintName("FK_EmployeeHierarchy_Employee");

            entity.HasOne(d => d.Manager).WithMany()
                .HasForeignKey(d => d.ManagerId)
                .HasConstraintName("FK_EmployeeHierarchy_Manager");
        });

        modelBuilder.Entity<EmployeeNotification>(entity =>
        {
            entity
                .HasNoKey()
                .ToTable("EmployeeNotification");

            entity.Property(e => e.DeliveredAt)
                .HasColumnType("datetime")
                .HasColumnName("delivered_at");
            entity.Property(e => e.DeliveryStatus)
                .HasMaxLength(50)
                .IsUnicode(false)
                .HasColumnName("delivery_status");
            entity.Property(e => e.EmployeeId).HasColumnName("employee_id");
            entity.Property(e => e.NotificationId).HasColumnName("notification_id");

            entity.HasOne(d => d.Employee).WithMany()
                .HasForeignKey(d => d.EmployeeId)
                .HasConstraintName("FK_EmployeeNotification_Employee");

            entity.HasOne(d => d.Notification).WithMany()
                .HasForeignKey(d => d.NotificationId)
                .HasConstraintName("FK_EmployeeNotification_Notification");
        });

        modelBuilder.Entity<EmployeeRole>(entity =>
        {
            entity
                .HasNoKey()
                .ToTable("EmployeeRole");

            entity.Property(e => e.AssignedDate)
                .HasColumnType("datetime")
                .HasColumnName("assigned_date");
            entity.Property(e => e.EmployeeId).HasColumnName("employee_id");
            entity.Property(e => e.RoleId).HasColumnName("role_id");

            entity.HasOne(d => d.Employee).WithMany()
                .HasForeignKey(d => d.EmployeeId)
                .HasConstraintName("FK_EmployeeRole_Employee");

            entity.HasOne(d => d.Role).WithMany()
                .HasForeignKey(d => d.RoleId)
                .HasConstraintName("FK_EmployeeRole_Role");
        });

        modelBuilder.Entity<EmployeeSkill>(entity =>
        {
            entity
                .HasNoKey()
                .ToTable("EmployeeSkill");

            entity.Property(e => e.EmployeeId).HasColumnName("employee_id");
            entity.Property(e => e.ProficiencyLevel)
                .HasMaxLength(50)
                .IsUnicode(false)
                .HasColumnName("proficiency_level");
            entity.Property(e => e.SkillId).HasColumnName("skill_id");

            entity.HasOne(d => d.Employee).WithMany()
                .HasForeignKey(d => d.EmployeeId)
                .HasConstraintName("FK_EmployeeSkill_Employee");

            entity.HasOne(d => d.Skill).WithMany()
                .HasForeignKey(d => d.SkillId)
                .HasConstraintName("FK_EmployeeSkill_Skill");
        });

        modelBuilder.Entity<EmployeeVerification>(entity =>
        {
            entity
                .HasNoKey()
                .ToTable("EmployeeVerification");

            entity.Property(e => e.EmployeeId).HasColumnName("employee_id");
            entity.Property(e => e.VerificationId).HasColumnName("verification_id");

            entity.HasOne(d => d.Employee).WithMany()
                .HasForeignKey(d => d.EmployeeId)
                .HasConstraintName("FK_EmployeeVerification_Employee");

            entity.HasOne(d => d.Verification).WithMany()
                .HasForeignKey(d => d.VerificationId)
                .HasConstraintName("FK_EmployeeVerification_Verification");
        });

        modelBuilder.Entity<Exception>(entity =>
        {
            entity.HasKey(e => e.ExceptionId).HasName("PK__Exceptio__26981DA80EBABC93");

            entity.ToTable("Exception");

            entity.Property(e => e.ExceptionId)
                .ValueGeneratedNever()
                .HasColumnName("ExceptionID");
            entity.Property(e => e.Category)
                .HasMaxLength(100)
                .IsUnicode(false)
                .HasColumnName("category");
            entity.Property(e => e.Date)
                .HasColumnType("datetime")
                .HasColumnName("date");
            entity.Property(e => e.Name)
                .HasMaxLength(100)
                .IsUnicode(false)
                .HasColumnName("name");
            entity.Property(e => e.Status)
                .HasMaxLength(50)
                .IsUnicode(false)
                .HasColumnName("status");
        });

        modelBuilder.Entity<FullTimeContract>(entity =>
        {
            entity
                .HasNoKey()
                .ToTable("FullTimeContract");

            entity.Property(e => e.ContractId).HasColumnName("contract_id");
            entity.Property(e => e.InsuranceEligibility).HasColumnName("insurance_eligibility");
            entity.Property(e => e.LeaveEntitlement).HasColumnName("leave_entitlement");
            entity.Property(e => e.WeeklyWorkingHours).HasColumnName("weekly_working_hours");

            entity.HasOne(d => d.Contract).WithMany()
                .HasForeignKey(d => d.ContractId)
                .HasConstraintName("FK_FullTimeContract_Contract");
        });

        modelBuilder.Entity<HolidayLeave>(entity =>
        {
            entity
                .HasNoKey()
                .ToTable("HolidayLeave");

            entity.Property(e => e.HolidayName)
                .HasMaxLength(100)
                .IsUnicode(false)
                .HasColumnName("holiday_name");
            entity.Property(e => e.LeaveId).HasColumnName("leave_id");
            entity.Property(e => e.OfficialRecognition).HasColumnName("official_recognition");
            entity.Property(e => e.RegionalScope)
                .HasMaxLength(100)
                .IsUnicode(false)
                .HasColumnName("regional_scope");

            entity.HasOne(d => d.Leave).WithMany()
                .HasForeignKey(d => d.LeaveId)
                .HasConstraintName("FK_HolidayLeave_Leave");
        });

        modelBuilder.Entity<HourlySalaryType>(entity =>
        {
            entity
                .HasNoKey()
                .ToTable("HourlySalaryType");

            entity.Property(e => e.HourlyRate)
                .HasColumnType("decimal(18, 2)")
                .HasColumnName("hourly_rate");
            entity.Property(e => e.MaxMonthlyHours).HasColumnName("max_monthly_hours");
            entity.Property(e => e.SalaryTypeId).HasColumnName("salary_type_id");

            entity.HasOne(d => d.SalaryType).WithMany()
                .HasForeignKey(d => d.SalaryTypeId)
                .HasConstraintName("FK_HourlySalaryType_SalaryType");
        });

        modelBuilder.Entity<Hradministrator>(entity =>
        {
            entity
                .HasNoKey()
                .ToTable("HRAdministrator");

            entity.Property(e => e.ApprovalLevel)
                .HasMaxLength(50)
                .IsUnicode(false)
                .HasColumnName("approval_level");
            entity.Property(e => e.DocumentValidationRights).HasColumnName("document_validation_rights");
            entity.Property(e => e.EmployeeId).HasColumnName("employee_id");
            entity.Property(e => e.RecordAccessScope)
                .HasMaxLength(100)
                .IsUnicode(false)
                .HasColumnName("record_access_scope");

            entity.HasOne(d => d.Employee).WithMany()
                .HasForeignKey(d => d.EmployeeId)
                .HasConstraintName("FK_HRAdministrator_Employee");
        });

        modelBuilder.Entity<Insurance>(entity =>
        {
            entity.HasKey(e => e.InsuranceId).HasName("PK__Insuranc__74231BC4E030D089");

            entity.ToTable("Insurance");

            entity.Property(e => e.InsuranceId)
                .ValueGeneratedNever()
                .HasColumnName("InsuranceID");
            entity.Property(e => e.ContributionRate)
                .HasColumnType("decimal(5, 2)")
                .HasColumnName("contribution_rate");
            entity.Property(e => e.Coverage)
                .HasColumnType("text")
                .HasColumnName("coverage");
            entity.Property(e => e.Type)
                .HasMaxLength(100)
                .IsUnicode(false)
                .HasColumnName("type");
        });

        modelBuilder.Entity<InternshipContract>(entity =>
        {
            entity
                .HasNoKey()
                .ToTable("InternshipContract");

            entity.Property(e => e.ContractId).HasColumnName("contract_id");
            entity.Property(e => e.Evaluation)
                .HasColumnType("text")
                .HasColumnName("evaluation");
            entity.Property(e => e.Mentoring)
                .HasMaxLength(200)
                .IsUnicode(false)
                .HasColumnName("mentoring");
            entity.Property(e => e.StipendRelated)
                .HasColumnType("decimal(18, 2)")
                .HasColumnName("stipend_related");

            entity.HasOne(d => d.Contract).WithMany()
                .HasForeignKey(d => d.ContractId)
                .HasConstraintName("FK_InternshipContract_Contract");
        });

        modelBuilder.Entity<LatenessPolicy>(entity =>
        {
            entity
                .HasNoKey()
                .ToTable("LatenessPolicy");

            entity.Property(e => e.DeductionRate)
                .HasColumnType("decimal(5, 2)")
                .HasColumnName("deduction_rate");
            entity.Property(e => e.GracePeriodMinutes).HasColumnName("grace_period_minutes");
            entity.Property(e => e.PolicyId).HasColumnName("policy_id");

            entity.HasOne(d => d.Policy).WithMany()
                .HasForeignKey(d => d.PolicyId)
                .HasConstraintName("FK_LatenessPolicy_PayrollPolicy");
        });

        modelBuilder.Entity<Leave>(entity =>
        {
            entity.HasKey(e => e.LeaveId).HasName("PK__Leave__796DB979A1D5D5BC");

            entity.ToTable("Leave");

            entity.Property(e => e.LeaveId)
                .ValueGeneratedNever()
                .HasColumnName("LeaveID");
            entity.Property(e => e.LeaveDescription)
                .HasColumnType("text")
                .HasColumnName("leave_description");
            entity.Property(e => e.LeaveType)
                .HasMaxLength(100)
                .IsUnicode(false)
                .HasColumnName("leave_type");
        });

        modelBuilder.Entity<LeaveDocument>(entity =>
        {
            entity.HasKey(e => e.DocumentId).HasName("PK__LeaveDoc__1ABEEF6FED3E37D7");

            entity.ToTable("LeaveDocument");

            entity.Property(e => e.DocumentId)
                .ValueGeneratedNever()
                .HasColumnName("DocumentID");
            entity.Property(e => e.FilePath)
                .HasMaxLength(200)
                .IsUnicode(false)
                .HasColumnName("file_path");
            entity.Property(e => e.LeaveRequestId).HasColumnName("leave_request_id");
            entity.Property(e => e.UploadedAt)
                .HasColumnType("datetime")
                .HasColumnName("uploaded_at");

            entity.HasOne(d => d.LeaveRequest).WithMany(p => p.LeaveDocuments)
                .HasForeignKey(d => d.LeaveRequestId)
                .HasConstraintName("FK_LeaveDocument_LeaveRequest");
        });

        modelBuilder.Entity<LeaveEntitlement>(entity =>
        {
            entity
                .HasNoKey()
                .ToTable("LeaveEntitlement");

            entity.Property(e => e.EmployeeId).HasColumnName("employee_id");
            entity.Property(e => e.Entitlement).HasColumnName("entitlement");
            entity.Property(e => e.LeaveTypeId).HasColumnName("leave_type_id");

            entity.HasOne(d => d.Employee).WithMany()
                .HasForeignKey(d => d.EmployeeId)
                .HasConstraintName("FK_LeaveEntitlement_Employee");

            entity.HasOne(d => d.LeaveType).WithMany()
                .HasForeignKey(d => d.LeaveTypeId)
                .HasConstraintName("FK_LeaveEntitlement_Leave");
        });

        modelBuilder.Entity<LeavePolicy>(entity =>
        {
            entity.HasKey(e => e.PolicyId).HasName("PK__LeavePol__2E133944564C07C2");

            entity.ToTable("LeavePolicy");

            entity.Property(e => e.PolicyId)
                .ValueGeneratedNever()
                .HasColumnName("PolicyID");
            entity.Property(e => e.EligibilityRules)
                .HasColumnType("text")
                .HasColumnName("eligibility_rules");
            entity.Property(e => e.Name)
                .HasMaxLength(100)
                .IsUnicode(false)
                .HasColumnName("name");
            entity.Property(e => e.NoticePeriod)
                .HasColumnType("datetime")
                .HasColumnName("notice_period");
            entity.Property(e => e.Purpose)
                .HasColumnType("text")
                .HasColumnName("purpose");
            entity.Property(e => e.ResetOnNewYear).HasColumnName("reset_on_new_year");
            entity.Property(e => e.SpecialLeaveType)
                .HasMaxLength(100)
                .IsUnicode(false)
                .HasColumnName("special_leave_type");
        });

        modelBuilder.Entity<LeaveRequest>(entity =>
        {
            entity.HasKey(e => e.RequestId).HasName("PK__LeaveReq__33A8519AFFEF6314");

            entity.ToTable("LeaveRequest");

            entity.Property(e => e.RequestId)
                .ValueGeneratedNever()
                .HasColumnName("RequestID");
            entity.Property(e => e.ApprovalTiming)
                .HasColumnType("datetime")
                .HasColumnName("approval_timing");
            entity.Property(e => e.Duration).HasColumnName("duration");
            entity.Property(e => e.EmployeeId).HasColumnName("employee_id");
            entity.Property(e => e.Justification)
                .HasColumnType("text")
                .HasColumnName("justification");
            entity.Property(e => e.LeaveId).HasColumnName("leave_id");
            entity.Property(e => e.Status)
                .HasMaxLength(50)
                .IsUnicode(false)
                .HasColumnName("status");

            entity.HasOne(d => d.Employee).WithMany(p => p.LeaveRequests)
                .HasForeignKey(d => d.EmployeeId)
                .HasConstraintName("FK_LeaveRequest_Employee");

            entity.HasOne(d => d.Leave).WithMany(p => p.LeaveRequests)
                .HasForeignKey(d => d.LeaveId)
                .HasConstraintName("FK_LeaveRequest_Leave");
        });

        modelBuilder.Entity<LineManager>(entity =>
        {
            entity
                .HasNoKey()
                .ToTable("LineManager");

            entity.Property(e => e.ApprovalLimit)
                .HasColumnType("decimal(18, 2)")
                .HasColumnName("approval_limit");
            entity.Property(e => e.EmployeeId).HasColumnName("employee_id");
            entity.Property(e => e.SupervisedDepartments)
                .HasMaxLength(200)
                .IsUnicode(false)
                .HasColumnName("supervised_departments");
            entity.Property(e => e.TeamSize).HasColumnName("team_size");

            entity.HasOne(d => d.Employee).WithMany()
                .HasForeignKey(d => d.EmployeeId)
                .HasConstraintName("FK_LineManager_Employee");
        });

        modelBuilder.Entity<ManagerNote>(entity =>
        {
            entity.HasKey(e => e.NoteId).HasName("PK__ManagerN__EACE357FE9D95A41");

            entity.Property(e => e.NoteId)
                .ValueGeneratedNever()
                .HasColumnName("NoteID");
            entity.Property(e => e.CreatedAt)
                .HasColumnType("datetime")
                .HasColumnName("created_at");
            entity.Property(e => e.EmployeeId).HasColumnName("employee_id");
            entity.Property(e => e.ManagerId).HasColumnName("manager_id");
            entity.Property(e => e.NoteContent)
                .HasColumnType("text")
                .HasColumnName("note_content");

            entity.HasOne(d => d.Employee).WithMany(p => p.ManagerNoteEmployees)
                .HasForeignKey(d => d.EmployeeId)
                .HasConstraintName("FK_ManagerNotes_Employee");

            entity.HasOne(d => d.Manager).WithMany(p => p.ManagerNoteManagers)
                .HasForeignKey(d => d.ManagerId)
                .HasConstraintName("FK_ManagerNotes_Manager");
        });

        modelBuilder.Entity<Mission>(entity =>
        {
            entity.HasKey(e => e.MissionId).HasName("PK__Mission__66DFB8541D6A3331");

            entity.ToTable("Mission");

            entity.Property(e => e.MissionId)
                .ValueGeneratedNever()
                .HasColumnName("MissionID");
            entity.Property(e => e.Destination)
                .HasMaxLength(100)
                .IsUnicode(false)
                .HasColumnName("destination");
            entity.Property(e => e.EmployeeId).HasColumnName("employee_id");
            entity.Property(e => e.EndDate)
                .HasColumnType("datetime")
                .HasColumnName("end_date");
            entity.Property(e => e.ManagerId).HasColumnName("manager_id");
            entity.Property(e => e.StartDate)
                .HasColumnType("datetime")
                .HasColumnName("start_date");
            entity.Property(e => e.Status)
                .HasMaxLength(50)
                .IsUnicode(false)
                .HasColumnName("status");

            entity.HasOne(d => d.Employee).WithMany(p => p.MissionEmployees)
                .HasForeignKey(d => d.EmployeeId)
                .HasConstraintName("FK_Mission_Employee");

            entity.HasOne(d => d.Manager).WithMany(p => p.MissionManagers)
                .HasForeignKey(d => d.ManagerId)
                .HasConstraintName("FK_Mission_Manager");
        });

        modelBuilder.Entity<MonthlySalaryType>(entity =>
        {
            entity
                .HasNoKey()
                .ToTable("MonthlySalaryType");

            entity.Property(e => e.ContributionScheme)
                .HasMaxLength(100)
                .IsUnicode(false)
                .HasColumnName("contribution_scheme");
            entity.Property(e => e.SalaryTypeId).HasColumnName("salary_type_id");
            entity.Property(e => e.TaxRule)
                .HasMaxLength(100)
                .IsUnicode(false)
                .HasColumnName("tax_rule");

            entity.HasOne(d => d.SalaryType).WithMany()
                .HasForeignKey(d => d.SalaryTypeId)
                .HasConstraintName("FK_MonthlySalaryType_SalaryType");
        });

        modelBuilder.Entity<Notification>(entity =>
        {
            entity.HasKey(e => e.NotificationId).HasName("PK__Notifica__20CF2E32AE8C9E87");

            entity.ToTable("Notification");

            entity.Property(e => e.NotificationId)
                .ValueGeneratedNever()
                .HasColumnName("NotificationID");
            entity.Property(e => e.MesageContent)
                .HasColumnType("text")
                .HasColumnName("mesage_content");
            entity.Property(e => e.NotificationType)
                .HasMaxLength(100)
                .IsUnicode(false)
                .HasColumnName("notification_type");
            entity.Property(e => e.ReadStatus).HasColumnName("read_status");
            entity.Property(e => e.Timestamp)
                .HasColumnType("datetime")
                .HasColumnName("timestamp");
            entity.Property(e => e.Urgency)
                .HasMaxLength(50)
                .IsUnicode(false)
                .HasColumnName("urgency");
        });

        modelBuilder.Entity<OfflineAttendanceQueue>(entity =>
        {
            entity.HasKey(e => e.QueueId).HasName("PK__OfflineA__8324E8F5FED1EF9B");

            entity.ToTable("OfflineAttendanceQueue");

            entity.Property(e => e.QueueId).HasColumnName("QueueID");
            entity.Property(e => e.AttendanceId).HasColumnName("attendance_id");
            entity.Property(e => e.ClockTime)
                .HasColumnType("datetime")
                .HasColumnName("clock_time");
            entity.Property(e => e.ClockType)
                .HasMaxLength(10)
                .IsUnicode(false)
                .HasColumnName("clock_type");
            entity.Property(e => e.CreatedAt)
                .HasDefaultValueSql("(getdate())")
                .HasColumnType("datetime")
                .HasColumnName("created_at");
            entity.Property(e => e.DeviceId).HasColumnName("device_id");
            entity.Property(e => e.EmployeeId).HasColumnName("employee_id");
            entity.Property(e => e.ErrorMessage)
                .HasMaxLength(500)
                .IsUnicode(false)
                .HasColumnName("error_message");
            entity.Property(e => e.SyncStatus)
                .HasMaxLength(20)
                .IsUnicode(false)
                .HasDefaultValue("PENDING")
                .HasColumnName("sync_status");
            entity.Property(e => e.SyncedAt)
                .HasColumnType("datetime")
                .HasColumnName("synced_at");

            entity.HasOne(d => d.Device).WithMany(p => p.OfflineAttendanceQueues)
                .HasForeignKey(d => d.DeviceId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_OfflineQueue_Device");

            entity.HasOne(d => d.Employee).WithMany(p => p.OfflineAttendanceQueues)
                .HasForeignKey(d => d.EmployeeId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_OfflineQueue_Employee");
        });

        modelBuilder.Entity<OvertimePolicy>(entity =>
        {
            entity
                .HasNoKey()
                .ToTable("OvertimePolicy");

            entity.Property(e => e.MaxHoursPerMonth).HasColumnName("max_hours_per_month");
            entity.Property(e => e.PolicyId).HasColumnName("policy_id");
            entity.Property(e => e.WeekdayRateMultiplier)
                .HasColumnType("decimal(5, 2)")
                .HasColumnName("weekday_rate_multiplier");
            entity.Property(e => e.WeekendRateMultiplier)
                .HasColumnType("decimal(5, 2)")
                .HasColumnName("weekend_rate_multiplier");

            entity.HasOne(d => d.Policy).WithMany()
                .HasForeignKey(d => d.PolicyId)
                .HasConstraintName("FK_OvertimePolicy_PayrollPolicy");
        });

        modelBuilder.Entity<PartTimeContract>(entity =>
        {
            entity
                .HasNoKey()
                .ToTable("PartTimeContract");

            entity.Property(e => e.ContractId).HasColumnName("contract_id");
            entity.Property(e => e.HourlyRate)
                .HasColumnType("decimal(18, 2)")
                .HasColumnName("hourly_rate");
            entity.Property(e => e.WorkingHours).HasColumnName("working_hours");

            entity.HasOne(d => d.Contract).WithMany()
                .HasForeignKey(d => d.ContractId)
                .HasConstraintName("FK_PartTimeContract_Contract");
        });

        modelBuilder.Entity<PayGrade>(entity =>
        {
            entity.HasKey(e => e.PayGradeId).HasName("PK__PayGrade__6A12DAD19DB4DBD6");

            entity.ToTable("PayGrade");

            entity.Property(e => e.PayGradeId)
                .ValueGeneratedNever()
                .HasColumnName("PayGradeID");
            entity.Property(e => e.GradeName)
                .HasMaxLength(50)
                .IsUnicode(false)
                .HasColumnName("grade_name");
            entity.Property(e => e.MaxSalary)
                .HasColumnType("decimal(18, 2)")
                .HasColumnName("max_salary");
            entity.Property(e => e.MinSalary)
                .HasColumnType("decimal(18, 2)")
                .HasColumnName("min_salary");
        });

        modelBuilder.Entity<Payroll>(entity =>
        {
            entity.HasKey(e => e.PayrollId).HasName("PK__Payroll__99DFC69278BAD9BD");

            entity.ToTable("Payroll");

            entity.Property(e => e.PayrollId)
                .ValueGeneratedNever()
                .HasColumnName("PayrollID");
            entity.Property(e => e.ActualPay)
                .HasColumnType("decimal(18, 2)")
                .HasColumnName("actual_pay");
            entity.Property(e => e.Adjustments)
                .HasColumnType("decimal(18, 2)")
                .HasColumnName("adjustments");
            entity.Property(e => e.BaseAmount)
                .HasColumnType("decimal(18, 2)")
                .HasColumnName("base_amount");
            entity.Property(e => e.Contributions)
                .HasColumnType("decimal(18, 2)")
                .HasColumnName("contributions");
            entity.Property(e => e.EmployeeId).HasColumnName("employee_id");
            entity.Property(e => e.NetSalary)
                .HasColumnType("decimal(18, 2)")
                .HasColumnName("net_salary");
            entity.Property(e => e.PaymentDate)
                .HasColumnType("datetime")
                .HasColumnName("payment_date");
            entity.Property(e => e.PeriodEnd)
                .HasColumnType("datetime")
                .HasColumnName("period_end");
            entity.Property(e => e.PeriodStart)
                .HasColumnType("datetime")
                .HasColumnName("period_start");
            entity.Property(e => e.Taxes)
                .HasColumnType("decimal(18, 2)")
                .HasColumnName("taxes");

            entity.HasOne(d => d.Employee).WithMany(p => p.Payrolls)
                .HasForeignKey(d => d.EmployeeId)
                .HasConstraintName("FK_Payroll_Employee");
        });

        modelBuilder.Entity<PayrollLog>(entity =>
        {
            entity.HasKey(e => e.PayrollLogId).HasName("PK__PayrollL__7B69DA7A96433F55");

            entity.ToTable("PayrollLog");

            entity.Property(e => e.PayrollLogId)
                .ValueGeneratedNever()
                .HasColumnName("payroll_log_id");
            entity.Property(e => e.Actor)
                .HasMaxLength(100)
                .IsUnicode(false)
                .HasColumnName("actor");
            entity.Property(e => e.ChangeDate)
                .HasColumnType("datetime")
                .HasColumnName("change_date");
            entity.Property(e => e.ModificationType)
                .HasMaxLength(100)
                .IsUnicode(false)
                .HasColumnName("modification_type");
            entity.Property(e => e.PayrollId).HasColumnName("payroll_id");

            entity.HasOne(d => d.Payroll).WithMany(p => p.PayrollLogs)
                .HasForeignKey(d => d.PayrollId)
                .HasConstraintName("FK_PayrollLog_Payroll");
        });

        modelBuilder.Entity<PayrollPeriod>(entity =>
        {
            entity.HasKey(e => e.PayrollPeriodId).HasName("PK__PayrollP__06190D56D99781A2");

            entity.ToTable("PayrollPeriod");

            entity.Property(e => e.PayrollPeriodId)
                .ValueGeneratedNever()
                .HasColumnName("PayrollPeriodID");
            entity.Property(e => e.EndDate)
                .HasColumnType("datetime")
                .HasColumnName("end_date");
            entity.Property(e => e.PayrollId).HasColumnName("payroll_id");
            entity.Property(e => e.StartDate)
                .HasColumnType("datetime")
                .HasColumnName("start_date");
            entity.Property(e => e.Status)
                .HasMaxLength(50)
                .IsUnicode(false)
                .HasColumnName("status");

            entity.HasOne(d => d.Payroll).WithMany(p => p.PayrollPeriods)
                .HasForeignKey(d => d.PayrollId)
                .HasConstraintName("FK_PayrollPeriod_Payroll");
        });

        modelBuilder.Entity<PayrollPolicy>(entity =>
        {
            entity.HasKey(e => e.PolicyId).HasName("PK__PayrollP__2E1339440B47E32B");

            entity.ToTable("PayrollPolicy");

            entity.Property(e => e.PolicyId)
                .ValueGeneratedNever()
                .HasColumnName("PolicyID");
            entity.Property(e => e.Description)
                .HasColumnType("text")
                .HasColumnName("description");
            entity.Property(e => e.EffectiveDate)
                .HasColumnType("datetime")
                .HasColumnName("effective_date");
            entity.Property(e => e.Type)
                .HasMaxLength(100)
                .IsUnicode(false)
                .HasColumnName("type");
        });

        modelBuilder.Entity<PayrollPolicyId>(entity =>
        {
            entity
                .HasNoKey()
                .ToTable("PayrollPolicyID");

            entity.Property(e => e.PayrollId).HasColumnName("payroll_id");
            entity.Property(e => e.PolicyId).HasColumnName("policy_id");

            entity.HasOne(d => d.Payroll).WithMany()
                .HasForeignKey(d => d.PayrollId)
                .HasConstraintName("FK_PayrollPolicyID_Payroll");

            entity.HasOne(d => d.Policy).WithMany()
                .HasForeignKey(d => d.PolicyId)
                .HasConstraintName("FK_PayrollPolicyID_PayrollPolicy");
        });

        modelBuilder.Entity<PayrollSpecialist>(entity =>
        {
            entity
                .HasNoKey()
                .ToTable("PayrollSpecialist");

            entity.Property(e => e.AssignedRegion)
                .HasMaxLength(100)
                .IsUnicode(false)
                .HasColumnName("assigned_region");
            entity.Property(e => e.EmployeeId).HasColumnName("employee_id");
            entity.Property(e => e.LastProcessedPeriod)
                .HasColumnType("datetime")
                .HasColumnName("last_processed_period");
            entity.Property(e => e.ProcessingFrequency)
                .HasMaxLength(50)
                .IsUnicode(false)
                .HasColumnName("processing_frequency");

            entity.HasOne(d => d.Employee).WithMany()
                .HasForeignKey(d => d.EmployeeId)
                .HasConstraintName("FK_PayrollSpecialist_Employee");
        });

        modelBuilder.Entity<Position>(entity =>
        {
            entity.HasKey(e => e.PositionId).HasName("PK__Position__60BB9A59CCD8D57C");

            entity.ToTable("Position");

            entity.Property(e => e.PositionId)
                .ValueGeneratedNever()
                .HasColumnName("PositionID");
            entity.Property(e => e.PositionTitle)
                .HasMaxLength(100)
                .IsUnicode(false)
                .HasColumnName("position_title");
            entity.Property(e => e.Responsibilities)
                .HasColumnType("text")
                .HasColumnName("responsibilities");
            entity.Property(e => e.Status)
                .HasMaxLength(50)
                .IsUnicode(false)
                .HasColumnName("status");
        });

        modelBuilder.Entity<ProbationLeave>(entity =>
        {
            entity
                .HasNoKey()
                .ToTable("ProbationLeave");

            entity.Property(e => e.EligibilityStartDate)
                .HasColumnType("datetime")
                .HasColumnName("eligibility_start_date");
            entity.Property(e => e.LeaveId).HasColumnName("leave_id");
            entity.Property(e => e.ProbationPeriod).HasColumnName("probation_period");

            entity.HasOne(d => d.Leave).WithMany()
                .HasForeignKey(d => d.LeaveId)
                .HasConstraintName("FK_ProbationLeave_Leave");
        });

        modelBuilder.Entity<Reimbursement>(entity =>
        {
            entity.HasKey(e => e.ReimbursementId).HasName("PK__Reimburs__FD1BC7A038367B09");

            entity.ToTable("Reimbursement");

            entity.Property(e => e.ReimbursementId)
                .ValueGeneratedNever()
                .HasColumnName("ReimbursementID");
            entity.Property(e => e.ApprovalDate)
                .HasColumnType("datetime")
                .HasColumnName("approval_date");
            entity.Property(e => e.ClaimType)
                .HasMaxLength(100)
                .IsUnicode(false)
                .HasColumnName("claim_type");
            entity.Property(e => e.CurrentStatus)
                .HasMaxLength(50)
                .IsUnicode(false)
                .HasColumnName("current_status");
            entity.Property(e => e.EmployeeId).HasColumnName("employee_id");
            entity.Property(e => e.Type)
                .HasMaxLength(100)
                .IsUnicode(false)
                .HasColumnName("type");

            entity.HasOne(d => d.Employee).WithMany(p => p.Reimbursements)
                .HasForeignKey(d => d.EmployeeId)
                .HasConstraintName("FK_Reimbursement_Employee");
        });

        modelBuilder.Entity<Role>(entity =>
        {
            entity.HasKey(e => e.RoleId).HasName("PK__Role__8AFACE3AAC761116");

            entity.ToTable("Role");

            entity.Property(e => e.RoleId)
                .ValueGeneratedNever()
                .HasColumnName("RoleID");
            entity.Property(e => e.Purpose)
                .HasColumnType("text")
                .HasColumnName("purpose");
            entity.Property(e => e.RoleName)
                .HasMaxLength(100)
                .IsUnicode(false)
                .HasColumnName("role_name");
        });

        modelBuilder.Entity<RolePermission>(entity =>
        {
            entity
                .HasNoKey()
                .ToTable("RolePermission");

            entity.Property(e => e.AllowedAction)
                .HasMaxLength(100)
                .IsUnicode(false)
                .HasColumnName("allowed_action");
            entity.Property(e => e.PermissionName)
                .HasMaxLength(100)
                .IsUnicode(false)
                .HasColumnName("permission_name");
            entity.Property(e => e.RoleId).HasColumnName("role_id");

            entity.HasOne(d => d.Role).WithMany()
                .HasForeignKey(d => d.RoleId)
                .HasConstraintName("FK_RolePermission_Role");
        });

        modelBuilder.Entity<SalaryType>(entity =>
        {
            entity.HasKey(e => e.SalaryTypeId).HasName("PK__SalaryTy__6784C0932E4D01CD");

            entity.ToTable("SalaryType");

            entity.Property(e => e.SalaryTypeId)
                .ValueGeneratedNever()
                .HasColumnName("SalaryTypeID");
            entity.Property(e => e.Currency)
                .HasMaxLength(10)
                .IsUnicode(false)
                .HasColumnName("currency");
            entity.Property(e => e.PaymentFrequency)
                .HasMaxLength(50)
                .IsUnicode(false)
                .HasColumnName("payment_frequency");
            entity.Property(e => e.Type)
                .HasMaxLength(100)
                .IsUnicode(false)
                .HasColumnName("type");

            entity.HasOne(d => d.CurrencyNavigation).WithMany(p => p.SalaryTypes)
                .HasForeignKey(d => d.Currency)
                .HasConstraintName("FK_SalaryType_Currency");
        });

        modelBuilder.Entity<ShiftCycle>(entity =>
        {
            entity.HasKey(e => e.CycleId).HasName("PK__ShiftCyc__077B24D97B175B88");

            entity.ToTable("ShiftCycle");

            entity.Property(e => e.CycleId)
                .ValueGeneratedNever()
                .HasColumnName("CycleID");
            entity.Property(e => e.CycleName)
                .HasMaxLength(100)
                .IsUnicode(false)
                .HasColumnName("cycle_name");
            entity.Property(e => e.Description)
                .HasColumnType("text")
                .HasColumnName("description");
        });

        modelBuilder.Entity<ShiftCycleAssignment>(entity =>
        {
            entity
                .HasNoKey()
                .ToTable("ShiftCycleAssignment");

            entity.Property(e => e.CycleId).HasColumnName("cycle_id");
            entity.Property(e => e.OrderNumber).HasColumnName("order_number");
            entity.Property(e => e.ShiftId).HasColumnName("shift_id");

            entity.HasOne(d => d.Cycle).WithMany()
                .HasForeignKey(d => d.CycleId)
                .HasConstraintName("FK_ShiftCycleAssignment_ShiftCycle");

            entity.HasOne(d => d.Shift).WithMany()
                .HasForeignKey(d => d.ShiftId)
                .HasConstraintName("FK_ShiftCycleAssignment_ShiftSchedule");
        });

        modelBuilder.Entity<ShiftSchedule>(entity =>
        {
            entity.HasKey(e => e.ShiftId).HasName("PK__ShiftSch__C0A838E1F73A7BB4");

            entity.ToTable("ShiftSchedule");

            entity.Property(e => e.ShiftId)
                .ValueGeneratedNever()
                .HasColumnName("ShiftID");
            entity.Property(e => e.EmployeeId).HasColumnName("employee_id");
            entity.Property(e => e.EndDate)
                .HasColumnType("datetime")
                .HasColumnName("end_date");
            entity.Property(e => e.EndTime).HasColumnName("end_time");
            entity.Property(e => e.ShiftName)
                .HasMaxLength(50)
                .IsUnicode(false)
                .HasColumnName("shift_name");
            entity.Property(e => e.ShiftType)
                .HasMaxLength(50)
                .IsUnicode(false)
                .HasColumnName("shift_type");
            entity.Property(e => e.StartDate)
                .HasColumnType("datetime")
                .HasColumnName("start_date");
            entity.Property(e => e.StartTime).HasColumnName("start_time");
            entity.Property(e => e.Status)
                .HasMaxLength(50)
                .IsUnicode(false)
                .HasColumnName("status");

            entity.HasOne(d => d.Employee).WithMany(p => p.ShiftSchedules)
                .HasForeignKey(d => d.EmployeeId)
                .HasConstraintName("FK_ShiftSchedule_Employee");
        });

        modelBuilder.Entity<SickLeave>(entity =>
        {
            entity
                .HasNoKey()
                .ToTable("SickLeave");

            entity.Property(e => e.LeaveId).HasColumnName("leave_id");
            entity.Property(e => e.MedicalCertificateRequired).HasColumnName("medical_certificate_required");
            entity.Property(e => e.PhysicianId).HasColumnName("physician_id");

            entity.HasOne(d => d.Leave).WithMany()
                .HasForeignKey(d => d.LeaveId)
                .HasConstraintName("FK_SickLeave_Leave");
        });

        modelBuilder.Entity<Skill>(entity =>
        {
            entity.HasKey(e => e.SkillId).HasName("PK__Skill__DFA091E74140E0D8");

            entity.ToTable("Skill");

            entity.Property(e => e.SkillId)
                .ValueGeneratedNever()
                .HasColumnName("SkillID");
            entity.Property(e => e.Description)
                .HasColumnType("text")
                .HasColumnName("description");
            entity.Property(e => e.SkillName)
                .HasMaxLength(100)
                .IsUnicode(false)
                .HasColumnName("skill_name");
        });

        modelBuilder.Entity<SplitShiftConfiguration>(entity =>
        {
            entity.HasKey(e => e.ConfigId).HasName("PK__SplitShi__C3BC333C122932C4");

            entity.ToTable("SplitShiftConfiguration");

            entity.Property(e => e.ConfigId)
                .ValueGeneratedNever()
                .HasColumnName("ConfigID");
            entity.Property(e => e.BreakDurationMinutes).HasColumnName("break_duration_minutes");
            entity.Property(e => e.CreatedDate)
                .HasDefaultValueSql("(getdate())")
                .HasColumnType("datetime")
                .HasColumnName("created_date");
            entity.Property(e => e.FirstSlotEnd).HasColumnName("first_slot_end");
            entity.Property(e => e.FirstSlotStart).HasColumnName("first_slot_start");
            entity.Property(e => e.IsActive)
                .HasDefaultValue(true)
                .HasColumnName("is_active");
            entity.Property(e => e.SecondSlotEnd).HasColumnName("second_slot_end");
            entity.Property(e => e.SecondSlotStart).HasColumnName("second_slot_start");
            entity.Property(e => e.ShiftName)
                .HasMaxLength(50)
                .IsUnicode(false)
                .HasColumnName("shift_name");
            entity.Property(e => e.TotalHours)
                .HasColumnType("decimal(5, 2)")
                .HasColumnName("total_hours");
        });

        modelBuilder.Entity<SystemAdministrator>(entity =>
        {
            entity
                .HasNoKey()
                .ToTable("SystemAdministrator");

            entity.Property(e => e.AuditVisibilityScope)
                .HasMaxLength(100)
                .IsUnicode(false)
                .HasColumnName("audit_visibility_scope");
            entity.Property(e => e.ConfigurableFields)
                .HasColumnType("text")
                .HasColumnName("configurable_fields");
            entity.Property(e => e.EmployeeId).HasColumnName("employee_id");
            entity.Property(e => e.SystemPrivilegeLevel)
                .HasMaxLength(50)
                .IsUnicode(false)
                .HasColumnName("system_privilege_level");

            entity.HasOne(d => d.Employee).WithMany()
                .HasForeignKey(d => d.EmployeeId)
                .HasConstraintName("FK_SystemAdministrator_Employee");
        });

        modelBuilder.Entity<SystemConfiguration>(entity =>
        {
            entity.HasKey(e => e.ConfigKey).HasName("PK__SystemCo__4A3067859ACDF906");

            entity.ToTable("SystemConfiguration");

            entity.Property(e => e.ConfigKey)
                .HasMaxLength(100)
                .IsUnicode(false);
            entity.Property(e => e.ConfigValue)
                .HasMaxLength(500)
                .IsUnicode(false);
            entity.Property(e => e.Description).HasColumnType("text");
            entity.Property(e => e.LastModified)
                .HasDefaultValueSql("(getdate())")
                .HasColumnType("datetime");
            entity.Property(e => e.ModifiedBy)
                .HasMaxLength(100)
                .IsUnicode(false);
        });

        modelBuilder.Entity<TaxForm>(entity =>
        {
            entity.HasKey(e => e.TaxFormId).HasName("PK__TaxForm__FB7E18A86C29534E");

            entity.ToTable("TaxForm");

            entity.Property(e => e.TaxFormId)
                .ValueGeneratedNever()
                .HasColumnName("TaxFormID");
            entity.Property(e => e.FormContent)
                .HasColumnType("text")
                .HasColumnName("form_content");
            entity.Property(e => e.Jurisdiction)
                .HasMaxLength(100)
                .IsUnicode(false)
                .HasColumnName("jurisdiction");
            entity.Property(e => e.ValidityPeriod)
                .HasColumnType("datetime")
                .HasColumnName("validity_period");
        });

        modelBuilder.Entity<Termination>(entity =>
        {
            entity.HasKey(e => e.TerminationId).HasName("PK__Terminat__16FEA24FA93EAD7D");

            entity.ToTable("Termination");

            entity.Property(e => e.TerminationId)
                .ValueGeneratedNever()
                .HasColumnName("TerminationID");
            entity.Property(e => e.ContractId).HasColumnName("contract_id");
            entity.Property(e => e.Date).HasColumnName("date");
            entity.Property(e => e.Reason)
                .HasColumnType("text")
                .HasColumnName("reason");

            entity.HasOne(d => d.Contract).WithMany(p => p.Terminations)
                .HasForeignKey(d => d.ContractId)
                .HasConstraintName("FK_Termination_Contract");
        });

        modelBuilder.Entity<VacationLeave>(entity =>
        {
            entity
                .HasNoKey()
                .ToTable("VacationLeave");

            entity.Property(e => e.ApprovingManager)
                .HasMaxLength(100)
                .IsUnicode(false)
                .HasColumnName("approving_manager");
            entity.Property(e => e.CarryOverDays).HasColumnName("carry_over_days");
            entity.Property(e => e.LeaveId).HasColumnName("leave_id");

            entity.HasOne(d => d.Leave).WithMany()
                .HasForeignKey(d => d.LeaveId)
                .HasConstraintName("FK_VacationLeave_Leave");
        });

        modelBuilder.Entity<Verification>(entity =>
        {
            entity.HasKey(e => e.VerificationId).HasName("PK__Verifica__306D4927F976E8ED");

            entity.ToTable("Verification");

            entity.Property(e => e.VerificationId)
                .ValueGeneratedNever()
                .HasColumnName("VerificationID");
            entity.Property(e => e.ExpiryPeriod).HasColumnName("expiry_period");
            entity.Property(e => e.IssueDate).HasColumnName("issue_date");
            entity.Property(e => e.Issuer)
                .HasMaxLength(100)
                .IsUnicode(false)
                .HasColumnName("issuer");
            entity.Property(e => e.VerificationType)
                .HasMaxLength(100)
                .IsUnicode(false)
                .HasColumnName("verification_type");
        });

        OnModelCreatingPartial(modelBuilder);
    }

    partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
}
