using System;
using System.Collections.Generic;

namespace WebAppSystem.Models;

public partial class ApprovalWorkflow
{
    public int WorkflowId { get; set; }

    public string? WorkflowType { get; set; }

    public decimal? ThresholdAmount { get; set; }

    public string? ApprovedRole { get; set; }

    public int? CreatedBy { get; set; }

    public string? Status { get; set; }

    public virtual Employee? CreatedByNavigation { get; set; }
}
