using System;
using System.Collections.Generic;

namespace WebAppSystem.Models;

public partial class TaxForm
{
    public int TaxFormId { get; set; }

    public string? Jurisdiction { get; set; }

    public DateTime? ValidityPeriod { get; set; }

    public string? FormContent { get; set; }

    public virtual ICollection<Employee> Employees { get; set; } = new List<Employee>();
}
