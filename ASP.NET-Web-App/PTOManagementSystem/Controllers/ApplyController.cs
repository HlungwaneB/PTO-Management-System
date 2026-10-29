using Microsoft.AspNetCore.Mvc;
using PTO_web_application.Extensions;
using PTO_web_application.Models.ViewModels;
using PTO_web_application.Services;
using Microsoft.AspNetCore.Mvc.Rendering;
using System.Net.Http;
using System.Text;
using System.Text.Json;

namespace PTO_web_application.Controllers;

public class ApplyController : Controller
{
    private readonly ApplicationService _applicationService;
    private readonly AuthService _authService;
    private readonly SiteService _siteService;
    private readonly Supabase.Client _supabase;
    private readonly IConfiguration _config;

    // Use a static HttpClient for external API calls (best practice)
    private static readonly HttpClient _httpClient = new HttpClient();

    public ApplyController(
        ApplicationService applicationService,
        AuthService authService,
        SiteService siteService,
        Supabase.Client supabase,
        IConfiguration config)
    {
        _applicationService = applicationService;
        _authService = authService;
        _siteService = siteService;
        _supabase = supabase;
        _config = config;
    }

    // GET: /Apply  → redirect to first step
    [HttpGet]
    public IActionResult Index()
    {
        return RedirectToAction("Reliable");
    }

    
    // STEP 1: RELIABLE INFORMATION
    
    [HttpGet]
    public IActionResult Reliable()
    {
        var saved = HttpContext.Session.GetObject<ApplyReliableViewModel>("apply_reliable")
                    ?? new ApplyReliableViewModel();
        return View(saved);
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public IActionResult Reliable(ApplyReliableViewModel model)
    {
        if (!ModelState.IsValid) return View(model);

        // Rule: Must be over 21
        if (model.IsOver21 == "No")
        {
            ModelState.AddModelError("IsOver21", "You must be over 21 years old to apply.");
            return View(model);
        }

        // Default optional fields to "No" if left blank
        if (string.IsNullOrEmpty(model.IsMilitaryVeteran)) model.IsMilitaryVeteran = "No";
        if (string.IsNullOrEmpty(model.IsElderly)) model.IsElderly = "No";

        HttpContext.Session.SetObject("apply_reliable", model);
        return RedirectToAction("Personal");
    }

    
    // STEP 2: PERSONAL INFORMATION
    
    [HttpGet]
    public IActionResult Personal()
    {
        var saved = HttpContext.Session.GetObject<ApplyPersonalViewModel>("apply_personal")
                    ?? new ApplyPersonalViewModel();
        return View(saved);
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public IActionResult Personal(ApplyPersonalViewModel model)
    {
        if (!ModelState.IsValid) return View(model);

        if (!string.IsNullOrEmpty(model.IdNumber) && model.IdNumber.Length == 13 && model.DateOfBirth.HasValue)
        {
            try
            {
                string yy = model.IdNumber.Substring(0, 2);
                string mm = model.IdNumber.Substring(2, 2);
                string dd = model.IdNumber.Substring(4, 2);

                int yearShort = int.Parse(yy);
                int yearFull = yearShort <= 25 ? 2000 + yearShort : 1900 + yearShort;

                var dobFromId = new DateTime(yearFull, int.Parse(mm), int.Parse(dd)).Date;

                // 1. Check Date of Birth Matches
                if (model.DateOfBirth.Value.Date != dobFromId)
                {
                    ModelState.AddModelError("DateOfBirth", $"Date of Birth does not match the ID Number (Expected: {dobFromId:yyyy-MM-dd}).");
                }

                // 2. Check Gender Matches (Digits 7-10 >= 5000 is Male)
                string genderSequence = model.IdNumber.Substring(6, 4);
                int genderNumber = int.Parse(genderSequence);
                string genderFromId = genderNumber >= 5000 ? "Male" : "Female";

                if (!string.IsNullOrEmpty(model.Gender) && model.Gender != genderFromId)
                {
                    ModelState.AddModelError("Gender", $"Gender does not match the ID Number (ID indicates {genderFromId}).");
                }

                // 3. Check Age is 21+
                var today = DateTime.Today;
                var age = today.Year - dobFromId.Year;
                if (dobFromId.Date > today.AddYears(-age)) age--;

                if (age < 21)
                {
                    ModelState.AddModelError("DateOfBirth", $"You must be 21 or older to apply. (You are {age} years old).");
                }
            }
            catch
            {
                ModelState.AddModelError("IdNumber", "Invalid ID Number format.");
            }
        }

        if (!ModelState.IsValid) return View(model);

        HttpContext.Session.SetObject("apply_personal", model);
        return RedirectToAction("Contact");
    }

    
    // STEP 3: CONTACT INFORMATION & SITE SELECTION
    
    [HttpGet]
    public async Task<IActionResult> Contact()
    {
        var saved = HttpContext.Session.GetObject<ApplyContactViewModel>("apply_contact")
                    ?? new ApplyContactViewModel();

        var sites = await _siteService.GetAvailableSitesAsync();
        saved.AvailableSites = sites.Select(s => new SelectListItem
        {
            Value = s.SiteId.ToString(),
            Text = $"{s.SiteName} - {s.Location}"
        }).ToList();

        return View(saved);
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> Contact(ApplyContactViewModel model)
    {
        var sites = await _siteService.GetAvailableSitesAsync();
        model.AvailableSites = sites.Select(s => new SelectListItem
        {
            Value = s.SiteId.ToString(),
            Text = $"{s.SiteName} - {s.Location}"
        }).ToList();

        if (!ModelState.IsValid) return View(model);

        if (!System.Text.RegularExpressions.Regex.IsMatch(model.Cellphone, @"^0\d{9}$"))
            ModelState.AddModelError("Cellphone", "Please enter a valid 10-digit SA cellphone number.");

        if (model.Cellphone != model.ConfirmCellphone)
            ModelState.AddModelError("ConfirmCellphone", "Cellphone numbers do not match.");

        if (model.EmailAddress != model.ConfirmEmailAddress)
            ModelState.AddModelError("ConfirmEmailAddress", "Email addresses do not match.");

        if (!ModelState.IsValid) return View(model);

        HttpContext.Session.SetObject("available_sites", model.AvailableSites);
        HttpContext.Session.SetObject("apply_contact", model);

        if (model.IsDependant == "Yes")
        {
            return RedirectToAction("Dependent");
        }
        else
        {
            HttpContext.Session.Remove("apply_dependent");
            return RedirectToAction("Documents");
        }
    }

    
    // STEP 4: DEPENDENT INFORMATION
    
    [HttpGet]
    public IActionResult Dependent()
    {
        var contactData = HttpContext.Session.GetObject<ApplyContactViewModel>("apply_contact");

        if (contactData != null && contactData.IsDependant != "Yes")
        {
            return RedirectToAction("Documents");
        }

        var saved = HttpContext.Session.GetObject<ApplyDependentViewModel>("apply_dependent")
                    ?? new ApplyDependentViewModel();
        return View(saved);
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public IActionResult Dependent(ApplyDependentViewModel model)
    {
        if (!ModelState.IsValid) return View(model);

        if (string.IsNullOrEmpty(model.IdNumber) || !System.Text.RegularExpressions.Regex.IsMatch(model.IdNumber, @"^\d{13}$"))
            ModelState.AddModelError("IdNumber", "ID Number must be exactly 13 digits.");

        if (string.IsNullOrEmpty(model.Cellphone) || !System.Text.RegularExpressions.Regex.IsMatch(model.Cellphone, @"^0\d{9}$"))
            ModelState.AddModelError("Cellphone", "Cellphone must be a valid 10-digit number.");

        if (!ModelState.IsValid) return View(model);

        HttpContext.Session.SetObject("apply_dependent", model);
        return RedirectToAction("Documents");
    }

  
    // STEP 5: DOCUMENTS
    
    [HttpGet]
    public IActionResult Documents()
    {
        return View(new ApplyDocumentsViewModel());
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> Documents(ApplyDocumentsViewModel model)
    {
        if (!ModelState.IsValid) return View(model);

        var allowedExtensions = new[] { ".pdf", ".jpg", ".jpeg", ".png" };
        const long maxFileSize = 5 * 1024 * 1024;

        foreach (var file in new[] { model.CertifiedId, model.ProofOfIncome, model.DependentId })
        {
            if (file != null && file.Length > 0)
            {
                var ext = Path.GetExtension(file.FileName).ToLowerInvariant();
                if (!allowedExtensions.Contains(ext))
                    ModelState.AddModelError(string.Empty, $"File type not allowed for {file.FileName}.");
                if (file.Length > maxFileSize)
                    ModelState.AddModelError(string.Empty, $"File {file.FileName} is too large (Max 5MB).");
            }
        }

        if (!ModelState.IsValid) return View(model);

        async Task<string> UploadToSupabaseAsync(IFormFile file)
        {
            if (file == null || file.Length == 0) return string.Empty;
            try
            {
                using var ms = new MemoryStream();
                await file.CopyToAsync(ms);
                var fileBytes = ms.ToArray();
                var fileName = $"{Guid.NewGuid()}{Path.GetExtension(file.FileName)}";

                await _supabase.Storage.From("pto-documents").Upload(fileBytes, fileName);
                return _supabase.Storage.From("pto-documents").GetPublicUrl(fileName);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"SUPABASE UPLOAD ERROR: {ex.Message}");
                return "upload-failed";
            }
        }

        var idUrl = await UploadToSupabaseAsync(model.CertifiedId);
        var incomeUrl = await UploadToSupabaseAsync(model.ProofOfIncome);
        var depUrl = await UploadToSupabaseAsync(model.DependentId);

        HttpContext.Session.SetString("doc_certified_id_url", idUrl);
        HttpContext.Session.SetString("doc_proof_income_url", incomeUrl);
        HttpContext.Session.SetString("doc_dependent_id_url", depUrl);

        return RedirectToAction("CreatePassword");
    }
    
    // STEP 6: CREATE PASSWORD
    
    [HttpGet]
    public IActionResult CreatePassword()
    {
        return View(new ApplyCreatePasswordViewModel());
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public IActionResult CreatePassword(ApplyCreatePasswordViewModel model)
    {
        if (!ModelState.IsValid) return View(model);

        if (model.Password != model.ConfirmPassword)
        {
            ModelState.AddModelError("ConfirmPassword", "Passwords do not match.");
            return View(model);
        }

        HttpContext.Session.SetObject("apply_password", model);
        return RedirectToAction("Review");
    }

    
    // REVIEW
    
    [HttpGet]
    public IActionResult Review()
    {
        return View(BuildReviewModel());
    }

    
    // SUBMIT (Saves to DB, Creates User, Sends SMS & Email, Saves Notification)
    
    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> Submit()
    {
        var personal = HttpContext.Session.GetObject<ApplyPersonalViewModel>("apply_personal");
        var contact = HttpContext.Session.GetObject<ApplyContactViewModel>("apply_contact");
        var passwordStep = HttpContext.Session.GetObject<ApplyCreatePasswordViewModel>("apply_password");
        var reliable = HttpContext.Session.GetObject<ApplyReliableViewModel>("apply_reliable");

        var idUrl = HttpContext.Session.GetString("doc_certified_id_url");
        var incomeUrl = HttpContext.Session.GetString("doc_proof_income_url");
        var depUrl = HttpContext.Session.GetString("doc_dependent_id_url");

        if (personal == null || contact == null || passwordStep == null)
        {
            ViewData["ErrorMessage"] = "Session expired. Please fill out the form again.";
            return View("Review", BuildReviewModel());
        }

        try
        {
            // 1. Create Auth User
            var authSuccess = await _authService.CreatePasswordAsync(personal.IdNumber, passwordStep.Password);
            if (!authSuccess) throw new Exception("Could not create user. This ID Number might already be registered.");

            // 2. Map to DB Model
            var newApplication = new Models.Application
            {
                IdNumber = personal.IdNumber,
                FullName = $"{personal.FirstNames} {personal.Surname}",
                Title = personal.Title,
                Initials = personal.Initials,
                PhoneNumber = contact.Cellphone,
                Email = contact.EmailAddress,
                SiteId = Guid.Parse(contact.SelectedSiteId),
                PtoType = "Residential",
                StartDate = DateTime.UtcNow,
                EndDate = DateTime.UtcNow.AddMonths(6),
                CurrentStatus = "Submitted",
                IsActive = true,
                UpdatedAt = DateTime.UtcNow,
                MonthlyIncome = reliable?.MonthlyIncome,
                CertifiedIdUrl = idUrl,
                ProofOfIncomeUrl = incomeUrl,
                DependentIdUrl = depUrl
            };

            // 3. Save to DB
            var savedApp = await _applicationService.SubmitAsync(newApplication);
            if (savedApp == null) throw new Exception("Failed to insert into the database.");

            //  4. SEND SMS VIA TEXTBEE
           
            //  5. Create the Notification in the Database
            try
            {
                var currentUser = _supabase.Auth.CurrentUser;
                var userId = currentUser != null ? Guid.Parse(currentUser.Id) : Guid.Empty;

                if (userId != Guid.Empty)
                {
                    var newNotif = new Models.Notification
                    {
                        NotificationId = Guid.NewGuid(),
                        UserId = userId,
                        Channel = "in_app",
                        Message = $"Welcome! Your PTO application (Ref: {personal.IdNumber}) has been submitted successfully.",
                        SentAt = DateTime.UtcNow,
                        IsRead = false
                    };

                    await _supabase.From<Models.Notification>().Insert(newNotif);
                }
            }
            catch (Exception ex) { Console.WriteLine($"NOTIFICATION ERROR: {ex.Message}"); }

            // 6. Success Redirect
            HttpContext.Session.Clear();
            HttpContext.Session.SetString("app_reference", personal.IdNumber);
            return RedirectToAction("Submitted");
        }
        catch (Exception ex)
        {
            ViewData["ErrorMessage"] = $"Database Error: {ex.Message}";
            return View("Review", BuildReviewModel());
        }
    }

    
    // SUBMITTED (Success Screen)
    
    [HttpGet]
    public IActionResult Submitted()
    {
        var reference = HttpContext.Session.GetString("app_reference");
        if (string.IsNullOrEmpty(reference)) return RedirectToAction("Index", "Home");

        var model = new ApplicationSubmittedViewModel { ReferenceNumber = reference };
        return View(model);
    }

    // Helper method to rebuild the Review model if an error occurs
    private ApplyReviewViewModel BuildReviewModel()
    {
        var personal = HttpContext.Session.GetObject<ApplyPersonalViewModel>("apply_personal");
        var contact = HttpContext.Session.GetObject<ApplyContactViewModel>("apply_contact");

        string siteName = "Not selected";
        if (contact != null && !string.IsNullOrEmpty(contact.SelectedSiteId))
        {
            var sites = HttpContext.Session.GetObject<List<Microsoft.AspNetCore.Mvc.Rendering.SelectListItem>>("available_sites");
            if (sites != null)
            {
                var selectedSite = sites.FirstOrDefault(s => s.Value == contact.SelectedSiteId);
                if (selectedSite != null)
                {
                    siteName = selectedSite.Text ?? "Unknown Site";
                }
            }
        }

        return new ApplyReviewViewModel
        {
            IdNumber = personal?.IdNumber ?? "",
            Title = personal?.Title ?? "",
            Initials = personal?.Initials ?? "",
            Surname = personal?.Surname ?? "",
            Cellphone = contact?.Cellphone ?? "",
            Email = contact?.EmailAddress ?? "",
            SiteName = siteName
        };
    }
}
