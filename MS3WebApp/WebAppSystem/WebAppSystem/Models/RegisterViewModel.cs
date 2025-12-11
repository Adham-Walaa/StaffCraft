using System.ComponentModel.DataAnnotations;

namespace WebAppSystem.Models
{
    public class RegisterViewModel
    {
        [Required(ErrorMessage = "First Name is required")]
        [Display(Name = "First Name")]
        public string FirstName { get; set; } = string.Empty;

        [Required(ErrorMessage = "Last Name is required")]
        [Display(Name = "Last Name")]
        public string LastName { get; set; } = string.Empty;

        [Required(ErrorMessage = "Email is required")]
        [EmailAddress(ErrorMessage = "Invalid email address")]
        public string Email { get; set; } = string.Empty;

        [Required(ErrorMessage = "Password is required")]
        [StringLength(100, ErrorMessage = "Password must be at least {2} characters long", MinimumLength = 6)]
        [DataType(DataType.Password)]
        public string Password { get; set; } = string.Empty;

        [DataType(DataType.Password)]
        [Display(Name = "Confirm Password")]
        [Compare("Password", ErrorMessage = "Password and confirmation password do not match")]
        public string ConfirmPassword { get; set; } = string.Empty;

        [Required(ErrorMessage = "Role is required")]
        [Display(Name = "Role")]
        public string Role { get; set; } = string.Empty;

        [Phone]
        [Display(Name = "Phone Number")]
        public string? Phone { get; set; }

        [Display(Name = "Address")]
        public string? Address { get; set; }

        [Display(Name = "Date of Birth")]
        [DataType(DataType.Date)]
        [PastDate(ErrorMessage = "Date of Birth must be in the past")]
        public DateTime? DateOfBirth { get; set; }
    }
}
