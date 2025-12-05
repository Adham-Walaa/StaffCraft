using System;
using System.Collections.Generic;

namespace WebAppSystem.Models;

public partial class Contract
{
    public int ContractId { get; set; }

    public string? Type { get; set; }

    public DateTime? StartDate { get; set; }

    public DateTime? EndDate { get; set; }

    public string? CurrentState { get; set; }

    public virtual ICollection<Employee> Employees { get; set; } = new List<Employee>();

    public virtual ICollection<Termination> Terminations { get; set; } = new List<Termination>();
}
