using System;
using System.Collections.Generic;

namespace WebAppSystem.Models;

public partial class PayrollPolicy
{
    public int PolicyId { get; set; }

    public DateTime? EffectiveDate { get; set; }

    public string? Type { get; set; }

    public string? Description { get; set; }
}
