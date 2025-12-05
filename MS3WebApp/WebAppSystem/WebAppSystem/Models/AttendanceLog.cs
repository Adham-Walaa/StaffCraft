using System;
using System.Collections.Generic;

namespace WebAppSystem.Models;

public partial class AttendanceLog
{
    public int AttendanceLogId { get; set; }

    public int? AttendanceId { get; set; }

    public string? Actor { get; set; }

    public DateTime? Timestamp { get; set; }

    public string? Reason { get; set; }

    public virtual Attendance? Attendance { get; set; }
}
