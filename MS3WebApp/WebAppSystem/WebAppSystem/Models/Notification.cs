using System;
using System.Collections.Generic;

namespace WebAppSystem.Models;

public partial class Notification
{
    public int NotificationId { get; set; }

    public string? MesageContent { get; set; }

    public DateTime? Timestamp { get; set; }

    public string? Urgency { get; set; }

    public bool? ReadStatus { get; set; }

    public string? NotificationType { get; set; }
}
