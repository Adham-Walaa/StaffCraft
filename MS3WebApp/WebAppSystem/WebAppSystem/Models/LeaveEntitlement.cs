using System;
using System.Collections.Generic;

namespace WebAppSystem.Models;

public partial class LeaveEntitlement
{
    public int EmployeeId { get; set; }

    public int LeaveTypeId { get; set; }

    public int? Entitlement { get; set; }

    public virtual Employee? Employee { get; set; }

    public virtual Leave? LeaveType { get; set; }
}
