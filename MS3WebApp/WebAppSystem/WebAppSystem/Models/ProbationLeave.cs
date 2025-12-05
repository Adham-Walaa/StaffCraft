using System;
using System.Collections.Generic;

namespace WebAppSystem.Models;

public partial class ProbationLeave
{
    public int? LeaveId { get; set; }

    public DateTime? EligibilityStartDate { get; set; }

    public int? ProbationPeriod { get; set; }

    public virtual Leave? Leave { get; set; }
}
