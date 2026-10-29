using System.ComponentModel.DataAnnotations;

namespace PTO_web_application.Models.ViewModels;

public class ApplyReliableViewModel
{
    [Required(ErrorMessage = "Monthly income is required")]
    public string MonthlyIncome { get; set; } = string.Empty;

    [Required(ErrorMessage = "Please select if you are South African")]
    public string IsSouthAfrican { get; set; } = string.Empty;

    [Required(ErrorMessage = "Please select if you are a first time home owner")]
    public string IsFirstTimeHomeOwner { get; set; } = string.Empty;

    [Required(ErrorMessage = "Please select if you are over 21 years old")]
    public string IsOver21 { get; set; } = string.Empty;

    [Required(ErrorMessage = "Please select if this is your first time government subsidy")]
    public string IsFirstTimeGovernmentSubsidy { get; set; } = string.Empty;

    //  These two are completely optional. No [Required] tag.
    public string? IsMilitaryVeteran { get; set; }
    public string? IsElderly { get; set; }

    public IEnumerable<ValidationResult> Validate(ValidationContext validationContext)
    {
        // 1. Check Age
        if (IsOver21 == "No")
        {
            yield return new ValidationResult(
                "You must be over 21 years old to apply.",
                new[] { nameof(IsOver21) });
        }

        // 2. Check Income is a valid number
        if (!decimal.TryParse(MonthlyIncome, out decimal income))
        {
            yield return new ValidationResult(
                "Please enter a valid numerical amount for income.",
                new[] { nameof(MonthlyIncome) });
        }
    }
}
