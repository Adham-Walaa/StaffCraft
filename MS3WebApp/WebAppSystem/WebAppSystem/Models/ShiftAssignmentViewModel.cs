using System;
using System.Collections.Generic;

namespace WebAppSystem.Models
{
    public class ShiftAssignmentViewModel
    {
        public int ShiftId { get; set; }
        public string? ShiftName { get; set; }
        public string? ShiftType { get; set; }
        public TimeOnly? StartTime { get; set; }
        public TimeOnly? EndTime { get; set; }
        public DateTime? StartDate { get; set; }
        public DateTime? EndDate { get; set; }
        public string? Status { get; set; }
        
        // For individual assignment
        public int? EmployeeId { get; set; }
        public string? EmployeeName { get; set; }
        
        // For department assignment
        public int? DepartmentId { get; set; }
        public string? DepartmentName { get; set; }
        public List<int>? EmployeeIds { get; set; }
    }
}
