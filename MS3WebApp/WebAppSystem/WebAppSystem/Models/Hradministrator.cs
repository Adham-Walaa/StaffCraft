using System;
using System.Collections.Generic;

namespace WebAppSystem.Models;

public partial class Hradministrator
{
    public int? EmployeeId { get; set; }

    public string? ApprovalLevel { get; set; }

    public string? RecordAccessScope { get; set; }

    public bool? DocumentValidationRights { get; set; }

    public virtual Employee? Employee { get; set; }
}
