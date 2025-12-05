using System;
using System.Collections.Generic;

namespace WebAppSystem.Models;

public partial class Department
{
    public int DepartmentId { get; set; }

    public string? DepartmentName { get; set; }

    public string? Purpose { get; set; }

    public int? DepartmentHeadId { get; set; }

    public virtual Employee? DepartmentHead { get; set; }

    public virtual ICollection<Employee> Employees { get; set; } = new List<Employee>();
}
