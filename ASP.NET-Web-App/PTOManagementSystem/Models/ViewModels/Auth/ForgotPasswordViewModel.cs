using System.ComponentModel.DataAnnotations;

namespace PTO_web_application.Models.ViewModels.Auth;

public class ForgotPasswordViewModel
{
    [Required(ErrorMessage = "Please enter your ID Number")]
    [Display(Name = "ID Number")]
    public string IdNumber { get; set; } = string.Empty;
}