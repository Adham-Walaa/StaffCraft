using System;
using System.Collections.Generic;

namespace WebAppSystem.Models;

public partial class ShiftCycle
{
    public int CycleId { get; set; }

    public string? CycleName { get; set; }

    public string? Description { get; set; }
}
