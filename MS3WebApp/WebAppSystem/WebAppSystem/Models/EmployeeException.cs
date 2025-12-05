using System;
using System.Collections.Generic;

namespace WebAppSystem.Models;

public partial class EmployeeException
{
    public int? EmployeeId { get; set; }

    public int? ExceptionId { get; set; }

    public virtual Employee? Employee { get; set; }

    public virtual Exception? Exception { get; set; }
}
