using System;
using System.Collections.Generic;

namespace WebAppSystem.Models;

public partial class ContractSalaryType
{
    public int? SalaryTypeId { get; set; }

    public decimal? ContractValue { get; set; }

    public string? InstallementDetails { get; set; }

    public virtual SalaryType? SalaryType { get; set; }
}
