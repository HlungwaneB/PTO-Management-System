namespace PTO_web_application.Models.ViewModels.Dashboard;

public class TrackResultViewModel
{
    public string IdNumber { get; set; } = string.Empty;
    public string Title { get; set; } = string.Empty;
    public string Initials { get; set; } = string.Empty;
    public string Name { get; set; } = string.Empty;
    public string Surname { get; set; } = string.Empty;
    public string Year { get; set; } = string.Empty;
    public string SiteName { get; set; } = string.Empty;
    public string Status { get; set; } = string.Empty;

    
    public string StatusClass => Status.ToLower() switch
    {
        "approved" => "status-approved",   
        "rejected" => "status-rejected",   
        "verifying" => "status-verifying", 
        "pending" => "status-pending",     
        _ => "status-pending"
    };
}