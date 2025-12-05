using System;
using System.Collections.Generic;

namespace WebAppSystem.Models;

public partial class RolePermission
{
    public int? RoleId { get; set; }

    public string? PermissionName { get; set; }

    public string? AllowedAction { get; set; }

    public virtual Role? Role { get; set; }
}
