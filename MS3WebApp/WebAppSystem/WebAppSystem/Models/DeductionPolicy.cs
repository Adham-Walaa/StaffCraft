using System;
using System.Collections.Generic;

namespace WebAppSystem.Models;

public partial class DeductionPolicy
{
    public int? PolicyId { get; set; }

    public string? DeductionReason { get; set; }

    public string? CalculationMode { get; set; }

    public virtual PayrollPolicy? Policy { get; set; }
}
