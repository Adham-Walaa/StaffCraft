using System;
using System.Collections.Generic;

namespace WebAppSystem.Models;

public partial class LatenessPolicy
{
    public int? PolicyId { get; set; }

    public int? GracePeriodMinutes { get; set; }

    public decimal? DeductionRate { get; set; }

    public virtual PayrollPolicy? Policy { get; set; }
}
