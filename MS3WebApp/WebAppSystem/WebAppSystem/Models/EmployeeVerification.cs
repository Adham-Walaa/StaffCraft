using System;
using System.Collections.Generic;

namespace WebAppSystem.Models;

public partial class EmployeeVerification
{
    public int? EmployeeId { get; set; }

    public int? VerificationId { get; set; }

    public virtual Employee? Employee { get; set; }

    public virtual Verification? Verification { get; set; }
}
