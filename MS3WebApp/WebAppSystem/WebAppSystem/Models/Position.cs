using System;
using System.Collections.Generic;

namespace WebAppSystem.Models;

public partial class Position
{
    public int PositionId { get; set; }

    public string? PositionTitle { get; set; }

    public string? Responsibilities { get; set; }

    public string? Status { get; set; }

    public virtual ICollection<Employee> Employees { get; set; } = new List<Employee>();
}
