using Microsoft.AspNetCore.Mvc;
using PTO_web_application.Models.ViewModels.Dashboard;
using PTO_web_application.Services;

namespace PTO_web_application.Controllers;

public class TrackController : Controller
{
    private readonly ApplicationService _applicationService;
    private readonly SiteService _siteService;

    public TrackController(ApplicationService applicationService, SiteService siteService)
    {
        _applicationService = applicationService;
        _siteService = siteService;
    }

    // GET Track
    [HttpGet]
    public IActionResult Index()
    {
        return View(new TrackViewModel());
    }

    // POST Track
    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> Index(TrackViewModel model)
    {
        if (string.IsNullOrWhiteSpace(model.IdNumber))
        {
            ModelState.AddModelError(nameof(model.IdNumber), "Please enter an ID number");
            return View(model);
        }

        var idNumber = model.IdNumber.Trim();

        //Get the application from Supabase
        var application = await _applicationService.GetMyApplicationAsync(idNumber);

        if (application == null)
        {
            //Not Found: Show the "Not Found" screen
            var nfModel = new TrackNotFoundViewModel { IdNumber = idNumber };
            return View("NotFound", nfModel);
        }

        // if Found get the Site name
        var site = await _siteService.GetSiteByIdAsync(application.SiteId);

        
        var nameParts = application.FullName.Split(' ', StringSplitOptions.RemoveEmptyEntries);
        string firstName = nameParts.Length > 0 ? nameParts[0] : "";
        string lastName = nameParts.Length > 1 ? nameParts[nameParts.Length - 1] : "";

        // 5. Build the Result Model
        var resultModel = new TrackResultViewModel
        {
            IdNumber = application.IdNumber,
            Title = application.Title ?? "Applicant",
            Initials = application.Initials ?? "",
            Name = firstName,
            Surname = lastName,
            Year = application.EndDate.Year.ToString(),
            SiteName = site?.SiteName ?? "Unknown Site",
            Status = application.CurrentStatus
        };

        return View("Result", resultModel);
    }
}