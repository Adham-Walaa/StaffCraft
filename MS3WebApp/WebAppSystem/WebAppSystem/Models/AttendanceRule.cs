using System;

namespace WebAppSystem.Models
{
    public class AttendanceRule
    {
        public int RuleId { get; set; }
        public string? RuleName { get; set; }
        public string? RuleType { get; set; } // "GracePeriod", "LatenessDeduction", "EarlyDeparture"
        public int? GracePeriodMinutes { get; set; }
        public decimal? PenaltyAmount { get; set; }
        public int? PenaltyMinutes { get; set; }
        public bool IsActive { get; set; }
        public DateTime? CreatedDate { get; set; }
        public string? Description { get; set; }
    }
}
