using System;
using System.Collections.Generic;

namespace WebAppSystem.Models;

public partial class LineManager
{
    public int? EmployeeId { get; set; }

    public int? TeamSize { get; set; }

    public string? SupervisedDepartments { get; set; }

    public decimal? ApprovalLimit { get; set; }

    public virtual Employee? Employee { get; set; }
}
