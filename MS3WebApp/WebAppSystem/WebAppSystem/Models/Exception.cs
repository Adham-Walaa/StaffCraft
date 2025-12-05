using System;
using System.Collections.Generic;

namespace WebAppSystem.Models;

public partial class Exception
{
    public int ExceptionId { get; set; }

    public string? Name { get; set; }

    public string? Category { get; set; }

    public DateTime? Date { get; set; }

    public string? Status { get; set; }

    public virtual ICollection<Attendance> Attendances { get; set; } = new List<Attendance>();
}
