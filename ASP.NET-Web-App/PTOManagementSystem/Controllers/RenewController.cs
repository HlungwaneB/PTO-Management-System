using Microsoft.AspNetCore.Mvc;
using PTO_web_application.Models.ViewModels.Dashboard;
using PTO_web_application.Services;

namespace PTO_web_application.Controllers;

public class RenewController : Controller
{
    private readonly ApplicationService _applicationService;
    private readonly Supabase.Client _supabase;

    public RenewController(ApplicationService applicationService, Supabase.Client supabase)
    {
        _applicationService = applicationService;
        _supabase = supabase;
    }

    // GET:Renew
    [HttpGet]
    public async Task<IActionResult> Index()
    {
        var idNumber = HttpContext.Session.GetString("sb-id-number");
        if (string.IsNullOrEmpty(idNumber)) return RedirectToAction("Login", "Auth");

        var application = await _applicationService.GetMyApplicationAsync(idNumber);

        if (application == null || application.CurrentStatus != "Approved")
        {
            TempData["ErrorMessage"] = "You can only renew an approved application.";
            return RedirectToAction("Index", "Dashboard");
        }

        var model = new RenewPtoViewModel
        {
            ExpiryDate = application.EndDate
        };

        return View(model);
    }

    // POST/Renew
    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> Index(RenewPtoViewModel model)
    {
        var idNumber = HttpContext.Session.GetString("sb-id-number");
        if (string.IsNullOrEmpty(idNumber)) return RedirectToAction("Login", "Auth");

        try
        {
            var application = await _applicationService.GetMyApplicationAsync(idNumber);

            if (application != null)
            {
                // 1. Reset the dates
                application.StartDate = DateTime.UtcNow;
                application.EndDate = DateTime.UtcNow.AddMonths(6);
                application.CurrentStatus = "Submitted";

                // Update the  timestamp so the SQL timer resets
                application.UpdatedAt = DateTime.UtcNow;

                // 3. Update income
                if (model.ChangeInIncome == "Yes" && !string.IsNullOrEmpty(model.NewMonthlyIncome))
                {
                    application.MonthlyIncome = model.NewMonthlyIncome;
                }

                await _applicationService.UpdateApplicationAsync(application);

                //update for UI
                HttpContext.Session.SetString("app_reference", idNumber);
                HttpContext.Session.SetString("forced_status", "Submitted");
            }

            return RedirectToAction("Submitted", "Apply");
        }
        catch (Exception ex)
        {
            TempData["ErrorMessage"] = $"Error processing renewal: {ex.Message}";
            return RedirectToAction("Index");
        }
    }
}