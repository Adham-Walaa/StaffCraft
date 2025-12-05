using System;
using System.Collections.Generic;

namespace WebAppSystem.Models;

public partial class VacationLeave
{
    public int? LeaveId { get; set; }

    public int? CarryOverDays { get; set; }

    public string? ApprovingManager { get; set; }

    public virtual Leave? Leave { get; set; }
}
