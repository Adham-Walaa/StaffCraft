using System;
using System.Collections.Generic;

namespace WebAppSystem.Models;

public partial class ShiftSchedule
{
    public int ShiftId { get; set; }

    public int? EmployeeId { get; set; }

    public DateTime? StartDate { get; set; }

    public DateTime? EndDate { get; set; }

    public string? Status { get; set; }

    public string? ShiftName { get; set; }

    public string? ShiftType { get; set; }

    public TimeOnly? StartTime { get; set; }

    public TimeOnly? EndTime { get; set; }

    public virtual Employee? Employee { get; set; }
}
