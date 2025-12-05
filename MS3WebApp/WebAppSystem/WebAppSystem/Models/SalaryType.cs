using System;
using System.Collections.Generic;

namespace WebAppSystem.Models;

public partial class SalaryType
{
    public int SalaryTypeId { get; set; }

    public string? Type { get; set; }

    public string? PaymentFrequency { get; set; }

    public string? Currency { get; set; }

    public virtual Currency? CurrencyNavigation { get; set; }

    public virtual ICollection<Employee> Employees { get; set; } = new List<Employee>();
}
