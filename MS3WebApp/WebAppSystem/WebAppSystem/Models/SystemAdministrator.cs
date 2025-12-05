using System;
using System.Collections.Generic;

namespace WebAppSystem.Models;

public partial class SystemAdministrator
{
    public int? EmployeeId { get; set; }

    public string? SystemPrivilegeLevel { get; set; }

    public string? ConfigurableFields { get; set; }

    public string? AuditVisibilityScope { get; set; }

    public virtual Employee? Employee { get; set; }
}
