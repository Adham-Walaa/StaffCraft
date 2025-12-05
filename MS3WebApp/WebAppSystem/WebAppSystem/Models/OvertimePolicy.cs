using System;
using System.Collections.Generic;

namespace WebAppSystem.Models;

public partial class OvertimePolicy
{
    public int? PolicyId { get; set; }

    public decimal? WeekdayRateMultiplier { get; set; }

    public decimal? WeekendRateMultiplier { get; set; }

    public int? MaxHoursPerMonth { get; set; }

    public virtual PayrollPolicy? Policy { get; set; }
}
