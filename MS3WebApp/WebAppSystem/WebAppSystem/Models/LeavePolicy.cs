using System;
using System.Collections.Generic;

namespace WebAppSystem.Models;

public partial class LeavePolicy
{
    public int PolicyId { get; set; }

    public string? Name { get; set; }

    public string? Purpose { get; set; }

    public string? EligibilityRules { get; set; }

    public DateTime? NoticePeriod { get; set; }

    public string? SpecialLeaveType { get; set; }

    public bool? ResetOnNewYear { get; set; }
}
