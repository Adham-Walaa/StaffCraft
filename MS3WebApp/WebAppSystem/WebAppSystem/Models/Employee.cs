using System;
using System.Collections.Generic;

namespace WebAppSystem.Models;

public partial class Employee
{
    public int EmployeeId { get; set; }

    public string? FirstName { get; set; }

    public string? LastName { get; set; }

    public string? FullName { get; set; }

    public string? NationalId { get; set; }

    public DateTime? DateOfBirth { get; set; }

    public string? CountryOfBirth { get; set; }

    public string? Phone { get; set; }

    public string? Email { get; set; }

    public string? Address { get; set; }

    public string? EmergencyContactName { get; set; }

    public string? EmergencyContactPhone { get; set; }

    public string? Relationship { get; set; }

    public string? Biography { get; set; }

    public byte[]? ProfileImage { get; set; }

    public string? EmploymentProgress { get; set; }

    public string? AccountStatus { get; set; }

    public string? EmploymentStatus { get; set; }

    public DateTime? HireDate { get; set; }

    public bool? IsActive { get; set; }

    public int? DepartmentId { get; set; }

    public int? PositionId { get; set; }

    public int? PaygradeId { get; set; }

    public int? TaxformId { get; set; }

    public int? ManagerId { get; set; }

    public int? SalaryTypeId { get; set; }

    public int? ContractId { get; set; }

    public int? ProfileCompletionPercentage { get; set; }

    public virtual ICollection<AllowanceDeduction> AllowanceDeductions { get; set; } = new List<AllowanceDeduction>();

    public virtual ICollection<ApprovalWorkflow> ApprovalWorkflows { get; set; } = new List<ApprovalWorkflow>();

    public virtual ICollection<AttendanceCorrectionRequest> AttendanceCorrectionRequestEmployees { get; set; } = new List<AttendanceCorrectionRequest>();

    public virtual ICollection<AttendanceCorrectionRequest> AttendanceCorrectionRequestRecommendedByNavigations { get; set; } = new List<AttendanceCorrectionRequest>();

    public virtual ICollection<Attendance> Attendances { get; set; } = new List<Attendance>();

    public virtual Contract? Contract { get; set; }

    public virtual Department? Department { get; set; }

    public virtual ICollection<Department> Departments { get; set; } = new List<Department>();

    public virtual ICollection<Device> Devices { get; set; } = new List<Device>();

    public virtual ICollection<Employee> InverseManager { get; set; } = new List<Employee>();

    public virtual ICollection<LeaveRequest> LeaveRequests { get; set; } = new List<LeaveRequest>();

    public virtual Employee? Manager { get; set; }

    public virtual ICollection<ManagerNote> ManagerNoteEmployees { get; set; } = new List<ManagerNote>();

    public virtual ICollection<ManagerNote> ManagerNoteManagers { get; set; } = new List<ManagerNote>();

    public virtual ICollection<Mission> MissionEmployees { get; set; } = new List<Mission>();

    public virtual ICollection<Mission> MissionManagers { get; set; } = new List<Mission>();

    public virtual ICollection<OfflineAttendanceQueue> OfflineAttendanceQueues { get; set; } = new List<OfflineAttendanceQueue>();

    public virtual PayGrade? Paygrade { get; set; }

    public virtual ICollection<Payroll> Payrolls { get; set; } = new List<Payroll>();

    public virtual Position? Position { get; set; }

    public virtual ICollection<Reimbursement> Reimbursements { get; set; } = new List<Reimbursement>();

    public virtual SalaryType? SalaryType { get; set; }

    public virtual ICollection<ShiftSchedule> ShiftSchedules { get; set; } = new List<ShiftSchedule>();

    public virtual TaxForm? Taxform { get; set; }
}
