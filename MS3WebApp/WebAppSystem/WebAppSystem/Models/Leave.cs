using System;
using System.Collections.Generic;

namespace WebAppSystem.Models;

public partial class Leave
{
    public int LeaveId { get; set; }

    public string? LeaveType { get; set; }

    public string? LeaveDescription { get; set; }

    public virtual ICollection<LeaveRequest> LeaveRequests { get; set; } = new List<LeaveRequest>();
}
