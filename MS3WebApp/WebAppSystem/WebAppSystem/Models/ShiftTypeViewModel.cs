using System;

namespace WebAppSystem.Models
{
    public class ShiftTypeViewModel
    {
        public string? ShiftType { get; set; }
        public string? ShiftName { get; set; }
        public TimeOnly? StartTime { get; set; }
        public TimeOnly? EndTime { get; set; }
        public decimal? TotalHours { get; set; }
        public string? Description { get; set; }
        public bool IsActive { get; set; }
    }
}
