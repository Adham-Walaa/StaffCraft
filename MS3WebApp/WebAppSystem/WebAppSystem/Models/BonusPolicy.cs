using System;
using System.Collections.Generic;

namespace WebAppSystem.Models;

public partial class BonusPolicy
{
    public int? PolicyId { get; set; }

    public string? BonusType { get; set; }

    public string? EligibilityCriteria { get; set; }

    public virtual PayrollPolicy? Policy { get; set; }
}
