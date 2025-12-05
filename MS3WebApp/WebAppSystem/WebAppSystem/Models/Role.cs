using System;
using System.Collections.Generic;

namespace WebAppSystem.Models;

public partial class Role
{
    public int RoleId { get; set; }

    public string? RoleName { get; set; }

    public string? Purpose { get; set; }
}
