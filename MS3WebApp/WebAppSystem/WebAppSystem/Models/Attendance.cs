using System;
using System.Collections.Generic;

namespace WebAppSystem.Models;

public partial class Attendance
{
    public int AttendanceId { get; set; }

    public int? EmployeeId { get; set; }

    public TimeOnly? EntryTime { get; set; }

    public TimeOnly? ExitTime { get; set; }

    public int? Duration { get; set; }

    public string? LoginMethod { get; set; }

    public string? LogoutMethod { get; set; }

    public int? ExceptionId { get; set; }

    public virtual ICollection<AttendanceLog> AttendanceLogs { get; set; } = new List<AttendanceLog>();

    public virtual Employee? Employee { get; set; }

    public virtual Exception? Exception { get; set; }
}
