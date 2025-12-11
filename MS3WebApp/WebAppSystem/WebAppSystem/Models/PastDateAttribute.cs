using System;
using System.ComponentModel.DataAnnotations;

namespace WebAppSystem.Models
{
    public class PastDateAttribute : ValidationAttribute
    {
        public PastDateAttribute()
        {
            ErrorMessage = "Date must be in the past";
        }

        public override bool IsValid(object? value)
        {
            if (value == null)
                return true; // Allow null for optional fields

            if (value is DateTime dateTime)
            {
                return dateTime.Date < DateTime.Today;
            }

            return false;
        }
    }
}
