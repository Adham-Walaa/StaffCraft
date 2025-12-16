using System;

namespace WebAppSystem.Models
{
    public class AttendanceSummaryViewModel
    {
        public int EmployeeId { get; set; }
        public string? EmployeeName { get; set; }
        public DateTime? Date { get; set; }
        public TimeOnly? EntryTime { get; set; }
        public TimeOnly? ExitTime { get; set; }
        public int? Duration { get; set; }
        public string? Status { get; set; }
        public string? ExceptionName { get; set; }
        public bool IsLate { get; set; }
        public int? LateMinutes { get; set; }
    }
}
