using System;
using System.Collections.Generic;

namespace WebAppSystem.Models;

public partial class EmployeeNotification
{
    public int? EmployeeId { get; set; }

    public int? NotificationId { get; set; }

    public string? DeliveryStatus { get; set; }

    public DateTime? DeliveredAt { get; set; }

    public virtual Employee? Employee { get; set; }

    public virtual Notification? Notification { get; set; }
}
