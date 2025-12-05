using System;
using System.Collections.Generic;

namespace WebAppSystem.Models;

public partial class PayrollPeriod
{
    public int PayrollPeriodId { get; set; }

    public int? PayrollId { get; set; }

    public DateTime? StartDate { get; set; }

    public DateTime? EndDate { get; set; }

    public string? Status { get; set; }

    public virtual Payroll? Payroll { get; set; }
}
