using System;
using System.Net.Http;
using System.Net.Http.Json;
using System.Threading.Tasks;
using Microsoft.Extensions.Configuration;

namespace PTO_Management_System.Services
{
    public class TextBeeService
    {
        private readonly HttpClient _httpClient;
        private readonly string _apiKey;
        private readonly string _deviceId;

        public TextBeeService(HttpClient httpClient, IConfiguration config)
        {
            _httpClient = httpClient;
            _apiKey = config["TextBee:ApiKey"];
            _deviceId = config["TextBee:DeviceId"];

            _httpClient.BaseAddress = new Uri("https://api.textbee.dev/api/v1/");
            _httpClient.DefaultRequestHeaders.Add("x-api-key", _apiKey);
        }

        public async Task<bool> SendSmsAsync(string phoneNumber, string message)
        {
            var payload = new
            {
                recipients = new[] { phoneNumber },
                message = message
            };

            var response = await _httpClient.PostAsJsonAsync($"gateway/devices/{_deviceId}/send-sms", payload);

            if (response.IsSuccessStatusCode)
            {
                return true;
            }

            var errorDetails = await response.Content.ReadAsStringAsync();
            Console.WriteLine($"Failed to send SMS: {errorDetails}");
            return false;
        }
    }
}