using System;
using System.Collections.Generic;

namespace WebAppSystem.Models;

public partial class SplitShiftConfiguration
{
    public int ConfigId { get; set; }

    public string ShiftName { get; set; } = null!;

    public TimeOnly FirstSlotStart { get; set; }

    public TimeOnly FirstSlotEnd { get; set; }

    public TimeOnly SecondSlotStart { get; set; }

    public TimeOnly SecondSlotEnd { get; set; }

    public decimal? TotalHours { get; set; }

    public int? BreakDurationMinutes { get; set; }

    public DateTime? CreatedDate { get; set; }

    public bool? IsActive { get; set; }
}
