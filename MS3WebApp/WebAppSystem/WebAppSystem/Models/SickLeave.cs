using System;
using System.Collections.Generic;

namespace WebAppSystem.Models;

public partial class SickLeave
{
    public int? LeaveId { get; set; }

    public bool? MedicalCertificateRequired { get; set; }

    public int? PhysicianId { get; set; }

    public virtual Leave? Leave { get; set; }
}
