using System;
using System.Collections.Generic;

namespace WebAppSystem.Models;

public partial class AttendanceSource
{
    public int? AttendanceId { get; set; }

    public int? DeviceId { get; set; }

    public string? SourceType { get; set; }

    public decimal? Latitude { get; set; }

    public decimal? Longitude { get; set; }

    public DateTime? RecordedAt { get; set; }

    public virtual Attendance? Attendance { get; set; }

    public virtual Device? Device { get; set; }
}
