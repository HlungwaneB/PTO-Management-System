using System.ComponentModel.DataAnnotations;

namespace PTO_Management_System.Models
{
    public class ApplicationRequest
    {
        [Required]
        public string IdNumber { get; set; }

        [Required]
        public string FullNames { get; set; }

        [Required]
        public string SelectedSite { get; set; }

        [Required]
        [EmailAddress]
        public string Email { get; set; }

        [Required]
        public string PhoneNumber { get; set; }
    }
}
