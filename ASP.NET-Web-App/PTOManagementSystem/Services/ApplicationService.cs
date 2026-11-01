using PTO_web_application.Models;
using Supabase;
using static Supabase.Postgrest.Constants;

namespace PTO_web_application.Services;

public class ApplicationService
{
    private readonly Supabase.Client _supabase;

    public ApplicationService(Supabase.Client supabase)
    {
        _supabase = supabase;
    }

  
    /// Submit a new application.before login.
   
    public async Task<Application?> SubmitAsync(Application application)
    {
        try
        {
            var response = await _supabase
                .From<Application>()
                .Insert(application);

            return response.Models.FirstOrDefault();
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Submit failed: {ex.Message}");
            throw; // Let the controller catch the duplicate rule error
        }
    }

    
    /// Get the current user's application by ID number.
    /// Requires an authenticated session.
  
    public async Task<Application?> GetMyApplicationAsync(string idNumber)
    {
        try
        {
            
            var response = await _supabase
                .From<Application>()
                .Where(a => a.IdNumber == idNumber.Trim())
                .Get();

            
            return response.Models.OrderByDescending(a => a.StartDate).FirstOrDefault();
        }
        catch (Exception ex)
        {
            Console.WriteLine($"GetMyApplication failed: {ex.Message}");
            return null;
        }
    }

   
    /// Fetches ALL applications from the database.For the Admin Dashboard.
   
    public async Task UpdateApplicationAsync(Application application)
    {
        if (application.ApplicationId == Guid.Empty)
        {
            throw new Exception("Application ID is missing. Cannot update.");
        }

        await _supabase.From<Application>().Update(application);
    }
    public async Task<List<Application>> GetAllApplicationsAsync()
    {
        try
        {
         
            var response = await _supabase
                .From<Application>()
                .Order(a => a.StartDate, Ordering.Descending)
                .Get();

            return response.Models;
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Error fetching all applications: {ex.Message}");
            return new List<Application>();
        }
    }
}