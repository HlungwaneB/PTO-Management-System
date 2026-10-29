using System.ComponentModel.DataAnnotations;

namespace PTO_web_application.Models.ViewModels;

public class ApplyDependentViewModel
{
    //  NEW: Relationship field
    [Required(ErrorMessage = "Relationship is required")]
    public string Relationship { get; set; } = string.Empty;

    //  RESTORED: Old fields
    [Required(ErrorMessage = "Dependent's Surname is required")]
    public string Surname { get; set; } = string.Empty;

    [Required(ErrorMessage = "Dependent's Initials are required")]
    public string Initials { get; set; } = string.Empty;

    [Required(ErrorMessage = "Dependent's First name(s) are required")]
    public string FirstNames { get; set; } = string.Empty;

    [Required(ErrorMessage = "ID Number is required")]
    [RegularExpression(@"^\d{13}$", ErrorMessage = "ID Number must be exactly 13 digits.")]
    public string IdNumber { get; set; } = string.Empty;

    [Required(ErrorMessage = "Cellphone is required")]
    public string Cellphone { get; set; } = string.Empty;

    public string? EmailAddress { get; set; }
}
