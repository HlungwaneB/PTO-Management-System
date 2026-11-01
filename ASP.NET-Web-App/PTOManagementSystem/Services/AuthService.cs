using Supabase;
using Supabase.Gotrue;

namespace PTO_web_application.Services;

public class AuthService
{
    private readonly Supabase.Client _supabase;

    public AuthService(Supabase.Client supabase)
    {
        _supabase = supabase;
    }

    public async Task<Session?> LoginAsync(string idNumber, string password)
    {
        try
        {
            var email = $"{idNumber.Trim()}@pto.local";
            return await _supabase.Auth.SignIn(email, password);
        }
        catch
        {
            return null;
        }
    }

    public async Task<bool> CreatePasswordAsync(string idNumber, string password)
    {
        try
        {
            var email = $"{idNumber.Trim()}@pto.local";
            await _supabase.Auth.SignUp(email, password);
            return true;
        }
        catch (Exception ex)
        {
            Console.WriteLine($"SignUp failed: {ex.Message}");
            return false;
        }
    }

    public async Task LogoutAsync()
    {
        await _supabase.Auth.SignOut();
    }
}