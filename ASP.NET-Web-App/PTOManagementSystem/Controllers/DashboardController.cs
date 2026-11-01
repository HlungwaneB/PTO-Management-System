
using Microsoft.AspNetCore.Mvc;
using PTO_web_application.Extensions;
using PTO_web_application.Models;
using PTO_web_application.Models.ViewModels.Apply;
using PTO_web_application.Models.ViewModels.Dashboard;
using PTO_web_application.Services;
using QuestPDF.Fluent;
using QuestPDF.Helpers;
using QuestPDF.Infrastructure;

namespace PTO_web_application.Controllers;

public class DashboardController : Controller
{
    private readonly ApplicationService _applicationService;
    private readonly SiteService _siteService;
    private readonly AuthService _authService;
    private readonly Supabase.Client _supabase;
    private readonly IConfiguration _config; 


    public DashboardController(
        ApplicationService applicationService,
        SiteService siteService,
        AuthService authService,
        Supabase.Client supabase)

    {
        _applicationService = applicationService;
        _siteService = siteService;
        _authService = authService;
        _supabase = supabase;
        IConfiguration config; 
    }

    
    //DASHBOARD
  
    public async Task<IActionResult> Index()
    {
        var idNumber = HttpContext.Session.GetString("sb-id-number");
        if (string.IsNullOrEmpty(idNumber))
        {
            return RedirectToAction("Login", "Auth");
        }

        var application = await _applicationService.GetMyApplicationAsync(idNumber);

        Site? site = null;
        if (application != null)
        {
            site = await _siteService.GetSiteByIdAsync(application.SiteId);
        }

        ViewData["HasApplication"] = application != null;

        var model = new DashboardViewModel
        {
            FullName = application?.FullName ?? HttpContext.Session.GetString("sb-full-name") ?? "User",
            IdNumber = idNumber,
            CurrentApplication = application,
            CurrentSite = site
        };

        var parts = model.FullName.Split(' ', StringSplitOptions.RemoveEmptyEntries);
        model.Initials = parts.Length >= 2
            ? $"{parts[0][0]}{parts[1][0]}".ToUpper()
            : model.FullName.Substring(0, Math.Min(2, model.FullName.Length)).ToUpper();

        return View(model);
    }

    // TRACKING TIMELINE
    
    [HttpGet]
    public async Task<IActionResult> Tracking()
    {
        var idNumber = HttpContext.Session.GetString("sb-id-number");
        if (string.IsNullOrEmpty(idNumber)) return RedirectToAction("Login", "Auth");

        var application = await _applicationService.GetMyApplicationAsync(idNumber);
        ViewData["HasApplication"] = application != null;

        //Check if renewed
        var forcedStatus = HttpContext.Session.GetString("forced_status");

        if (!string.IsNullOrEmpty(forcedStatus))
        {
           
            ViewBag.CurrentStatus = forcedStatus;
            HttpContext.Session.Remove("forced_status");
        }
        else
        {
            ViewBag.CurrentStatus = application?.CurrentStatus ?? "Submitted";
        }

        return View();
    }


    // DELETE APPLICATION
   
    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> DeleteApplication(string password)
    {
        var idNumber = HttpContext.Session.GetString("sb-id-number");
        if (string.IsNullOrEmpty(idNumber))
        {
            return RedirectToAction("Login", "Auth");
        }

        //Verify password
        var session = await _authService.LoginAsync(idNumber, password);
        if (session == null)
        {
            TempData["ErrorMessage"] = "Incorrect password. Could not delete application.";
            return RedirectToAction("Index");
        }

        try
        {
            //Delete the application row
            var application = await _applicationService.GetMyApplicationAsync(idNumber);
            if (application != null)
            {
                await _supabase.From<Application>()
                    .Where(a => a.ApplicationId == application.ApplicationId)
                    .Delete();
            }

            // Call the Supabase Database Function to delete the Auth User
            await _supabase.Rpc("delete_user_account", null);

          
            HttpContext.Session.Clear();
            TempData["SuccessMessage"] = "Your account and application have been permanently deleted.";
            return RedirectToAction("Index", "Home");
        }
        catch (Exception ex)
        {
            TempData["ErrorMessage"] = $"Error deleting account: {ex.Message}";
            return RedirectToAction("Index");
        }
    }

    // DOWNLOAD LEASE AGREEMENT PDF
   
    [HttpGet]
    public async Task<IActionResult> DownloadLeaseAgreement()
    {
        var idNumber = HttpContext.Session.GetString("sb-id-number");
        if (string.IsNullOrEmpty(idNumber))
        {
            return RedirectToAction("Login", "Auth");
        }

        var application = await _applicationService.GetMyApplicationAsync(idNumber);

        if (application == null)
        {
            TempData["ErrorMessage"] = "No application found to generate lease.";
            return RedirectToAction("Index");
        }

        //Only allow download if Approved
        if (application.CurrentStatus != "Approved")
        {
            TempData["ErrorMessage"] = "Your lease agreement is only available once your application has been approved.";
            return RedirectToAction("Index");
        }

        var site = await _siteService.GetSiteByIdAsync(application.SiteId);
        var dependent = HttpContext.Session.GetObject<ApplyDependentViewModel>("apply_dependent");

        string logoPath = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "images", "logo.png");

        var document = QuestPDF.Fluent.Document.Create(container =>
        {
            container.Page(page =>
            {
                page.Size(PageSizes.A4);
                page.Margin(2, Unit.Centimetre);
                page.PageColor(Colors.White);
                page.DefaultTextStyle(x => x.FontSize(12).FontFamily("Lato"));

               
                page.Header().Column(header =>
                {
                    header.Item().Row(row =>
                    {
                        row.RelativeItem().Text("PERMIT TO OCCUPY (PTO)").FontSize(24).Bold().FontColor(Colors.Orange.Medium);

                        if (System.IO.File.Exists(logoPath))
                        {
                            row.ConstantItem(100).Height(50).Image(logoPath).FitArea();
                        }
                    });
                    header.Item().PaddingTop(10).Text("Official Lease Agreement").FontSize(16).SemiBold().FontColor(Colors.Grey.Darken2);
                    header.Item().PaddingBottom(20).LineHorizontal(2).LineColor(Colors.Orange.Medium);
                });

                // Content
                page.Content().PaddingVertical(1, Unit.Centimetre).Column(col =>
                {
                    //Applicant Details
                    col.Item().Text(" Applicant Details").FontSize(14).Bold().FontColor(Colors.Black);
                    col.Item().PaddingBottom(10).Table(table =>
                    {
                        table.ColumnsDefinition(columns =>
                        {
                            columns.ConstantColumn(150);
                            columns.RelativeColumn();
                        });

                        table.Cell().Text("Full Name:").SemiBold();
                        table.Cell().Text(application.FullName);

                        table.Cell().Text("ID Number:").SemiBold();
                        table.Cell().Text(application.IdNumber);

                        table.Cell().Text("Contact Number:").SemiBold();
                        table.Cell().Text(application.PhoneNumber);

                        table.Cell().Text("Email Address:").SemiBold();
                        table.Cell().Text(application.Email);
                    });

                    //Site Details
                    col.Item().PaddingTop(10).Text(" Site Details").FontSize(14).Bold().FontColor(Colors.Black);
                    col.Item().PaddingBottom(10).Table(table =>
                    {
                        table.ColumnsDefinition(columns =>
                        {
                            columns.ConstantColumn(150);
                            columns.RelativeColumn();
                        });

                        table.Cell().Text("Site Name:").SemiBold();
                        table.Cell().Text(site?.SiteName ?? "N/A");

                        table.Cell().Text("Location:").SemiBold();
                        table.Cell().Text(site?.Location ?? "N/A");

                        table.Cell().Text("Size Details:").SemiBold();
                        table.Cell().Text(site?.SizeDetails ?? "N/A");
                    });

                    //Dependent Details 
                    if (dependent != null && !string.IsNullOrEmpty(dependent.FirstNames))
                    {
                        col.Item().PaddingTop(10).Text(" Dependent Details").FontSize(14).Bold().FontColor(Colors.Black);
                        col.Item().PaddingBottom(10).Table(table =>
                        {
                            table.ColumnsDefinition(columns =>
                            {
                                columns.ConstantColumn(150);
                                columns.RelativeColumn();
                            });

                            table.Cell().Text("Relationship:").SemiBold();
                            table.Cell().Text(dependent.Relationship);

                            table.Cell().Text("Dependent Name:").SemiBold();
                            table.Cell().Text($"{dependent.FirstNames} {dependent.Surname}");

                            table.Cell().Text("ID Number:").SemiBold();
                            table.Cell().Text(dependent.IdNumber);
                        });
                    }

                    //Lease Period
                    col.Item().PaddingTop(20).Text(" Lease Period").FontSize(14).Bold().FontColor(Colors.Black);
                    col.Item().PaddingBottom(10).Row(row =>
                    {
                        row.RelativeItem().Border(1).BorderColor(Colors.Grey.Lighten2).Padding(10).Column(c =>
                        {
                            c.Item().Text("Start Date:").SemiBold().FontSize(10);
                            c.Item().Text(application.StartDate.ToString("dd MMMM yyyy")).FontSize(14).Bold();
                        });
                        row.ConstantItem(20);
                        row.RelativeItem().Border(1).BorderColor(Colors.Grey.Lighten2).Padding(10).Column(c =>
                        {
                            c.Item().Text("End Date:").SemiBold().FontSize(10);
                            c.Item().Text(application.EndDate.ToString("dd MMMM yyyy")).FontSize(14).Bold();
                        });
                    });

                    // Terms & Conditions
                    col.Item().PaddingTop(40).Text("By accepting this lease, the applicant agrees to comply with all municipal regulations and conditions of occupation.").FontSize(10).Italic().FontColor(Colors.Grey.Darken2);
                });

                // Footer
                page.Footer().AlignCenter().Column(c =>
                {
                    c.Item().LineHorizontal(1).LineColor(Colors.Grey.Lighten2);
                    c.Item().PaddingTop(10).Text(x =>
                    {
                        x.DefaultTextStyle(y => y.FontSize(9).FontColor(Colors.Grey.Darken1));

                        x.Span("Generated on: ");
                        x.Span(DateTime.Now.ToString("dd MMM yyyy HH:mm")).SemiBold();
                        x.Span("  |  Page ");
                        x.CurrentPageNumber();
                        x.Span(" / ");
                        x.TotalPages();
                    });
                });
            });
        });

        var pdfBytes = document.GeneratePdf();
        return File(pdfBytes, "application/pdf", $"PTO_Lease_{application.IdNumber}.pdf");
    }
}