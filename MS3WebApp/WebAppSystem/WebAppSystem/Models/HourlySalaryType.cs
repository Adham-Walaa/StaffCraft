using System;
using System.Collections.Generic;

namespace WebAppSystem.Models;

public partial class HourlySalaryType
{
    public int? SalaryTypeId { get; set; }

    public decimal? HourlyRate { get; set; }

    public int? MaxMonthlyHours { get; set; }

    public virtual SalaryType? SalaryType { get; set; }
}
