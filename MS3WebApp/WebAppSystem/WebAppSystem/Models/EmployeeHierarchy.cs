using System;
using System.Collections.Generic;

namespace WebAppSystem.Models;

public partial class EmployeeHierarchy
{
    public int? EmployeeId { get; set; }

    public int? ManagerId { get; set; }

    public int? HierarchyLevel { get; set; }

    public virtual Employee? Employee { get; set; }

    public virtual Employee? Manager { get; set; }
}
