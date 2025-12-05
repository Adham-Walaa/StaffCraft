using System;
using System.Collections.Generic;

namespace WebAppSystem.Models;

public partial class PayrollPolicyId
{
    public int? PayrollId { get; set; }

    public int? PolicyId { get; set; }

    public virtual Payroll? Payroll { get; set; }

    public virtual PayrollPolicy? Policy { get; set; }
}
