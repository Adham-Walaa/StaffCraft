using System;
using System.Collections.Generic;

namespace WebAppSystem.Models;

public partial class SystemConfiguration
{
    public string ConfigKey { get; set; } = null!;

    public string? ConfigValue { get; set; }

    public string? Description { get; set; }

    public DateTime? LastModified { get; set; }

    public string? ModifiedBy { get; set; }
}
