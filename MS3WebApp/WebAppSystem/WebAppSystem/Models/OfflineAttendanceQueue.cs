using System;
using System.Collections.Generic;

namespace WebAppSystem.Models;

public partial class OfflineAttendanceQueue
{
    public int QueueId { get; set; }

    public int DeviceId { get; set; }

    public int EmployeeId { get; set; }

    public DateTime ClockTime { get; set; }

    public string ClockType { get; set; } = null!;

    public string? SyncStatus { get; set; }

    public DateTime? CreatedAt { get; set; }

    public DateTime? SyncedAt { get; set; }

    public int? AttendanceId { get; set; }

    public string? ErrorMessage { get; set; }

    public virtual Device Device { get; set; } = null!;

    public virtual Employee Employee { get; set; } = null!;
}
