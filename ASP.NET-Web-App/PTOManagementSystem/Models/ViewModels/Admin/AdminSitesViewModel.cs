namespace PTO_web_application.Models.ViewModels.Admin;

public class AdminSitesViewModel
{
    public string SearchQuery { get; set; } = string.Empty;
    public string ActiveFilter { get; set; } = "All";
    public List<SiteRow> Sites { get; set; } = new();
}

public class SiteRow
{
    public Guid SiteId { get; set; } 
    public string SiteNo { get; set; } = string.Empty;
    public string Settlement { get; set; } = string.Empty;
    public string Size { get; set; } = string.Empty;
    public string Status { get; set; } = "Available";

    public string StatusClass => Status.ToLower() switch
    {
        "active" => "badge-active",       
        "available" => "badge-active",    
        "occupied" => "badge-expiring",   
        _ => "badge-pending"
    };
}