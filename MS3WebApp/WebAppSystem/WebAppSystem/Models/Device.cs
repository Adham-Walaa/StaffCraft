using System;
using System.Collections.Generic;

namespace WebAppSystem.Models;

public partial class Device
{
    public int DeviceId { get; set; }

    public string? DeviceType { get; set; }

    public string? TerminalId { get; set; }

    public decimal? Latitude { get; set; }

    public decimal? Longitude { get; set; }

    public int? EmployeeId { get; set; }

    public virtual Employee? Employee { get; set; }

    public virtual ICollection<OfflineAttendanceQueue> OfflineAttendanceQueues { get; set; } = new List<OfflineAttendanceQueue>();
}
