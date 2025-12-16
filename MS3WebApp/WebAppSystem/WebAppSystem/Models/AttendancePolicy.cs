using System;
using System.ComponentModel.DataAnnotations;

namespace WebAppSystem.Models
{
    public class AttendancePolicy
    {
        [Key]
        public int PolicyID { get; set; }

        [Required]
        [Display(Name = "Policy Name")]
        public string PolicyName { get; set; }

        [Required]
        [Display(Name = "Policy Type")]
        public string PolicyType { get; set; }

        [Display(Name = "Description")]
        public string Description { get; set; }

        [Display(Name = "Parameters")]
        public string Parameters { get; set; }

        [Display(Name = "Effective Date")]
        [DataType(DataType.Date)]
        public DateTime EffectiveDate { get; set; }

        [Display(Name = "Status")]
        public string Status { get; set; }
    }
}
