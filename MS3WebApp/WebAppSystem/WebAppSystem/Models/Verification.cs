using System;
using System.Collections.Generic;

namespace WebAppSystem.Models;

public partial class Verification
{
    public int VerificationId { get; set; }

    public string? VerificationType { get; set; }

    public string? Issuer { get; set; }

    public DateOnly? IssueDate { get; set; }

    public DateOnly? ExpiryPeriod { get; set; }
}
