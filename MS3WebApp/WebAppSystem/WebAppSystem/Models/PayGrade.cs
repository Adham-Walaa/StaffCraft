using System;
using System.Collections.Generic;

namespace WebAppSystem.Models;

public partial class PayGrade
{
    public int PayGradeId { get; set; }

    public string? GradeName { get; set; }

    public decimal? MinSalary { get; set; }

    public decimal? MaxSalary { get; set; }

    public virtual ICollection<Employee> Employees { get; set; } = new List<Employee>();
}
