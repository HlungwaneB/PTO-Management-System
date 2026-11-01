namespace PTO_web_application.Models.ViewModels.Dashboard;

public class RenewPtoViewModel
{
    public DateTime? ExpiryDate { get; set; }

    // calculate days left
    public int DaysLeft => ExpiryDate.HasValue
        ? (ExpiryDate.Value - DateTime.Today).Days
        : 0;

   
    public string ExpiryText => ExpiryDate.HasValue
        ? $"{ExpiryDate.Value:dd MMM yyyy} — {DaysLeft} days left"
        : "No active PTO found";

    public string StillLivingAtSite { get; set; } = "Yes";
    public string ChangeInIncome { get; set; } = "No";
    public string? NewMonthlyIncome { get; set; }
    public string Notes { get; set; } = string.Empty;
}