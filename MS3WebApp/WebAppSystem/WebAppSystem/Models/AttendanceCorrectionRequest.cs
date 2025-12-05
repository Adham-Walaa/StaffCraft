using System;
using System.Collections.Generic;

namespace WebAppSystem.Models;

public partial class AttendanceCorrectionRequest
{
    public int RequestId { get; set; }

    public int? EmployeeId { get; set; }

    public DateOnly? Date { get; set; }

    public string? CorrectionType { get; set; }

    public string? Reason { get; set; }

    public string? Status { get; set; }

    public int? RecommendedBy { get; set; }

    public virtual Employee? Employee { get; set; }

    public virtual Employee? RecommendedByNavigation { get; set; }
}
