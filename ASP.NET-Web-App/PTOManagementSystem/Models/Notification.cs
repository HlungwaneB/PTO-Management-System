using Supabase.Postgrest.Attributes;
using Supabase.Postgrest.Models;

namespace PTO_web_application.Models;

[Table("notifications")]
public class Notification : BaseModel
{
    [PrimaryKey("notification_id", false)]
    public Guid NotificationId { get; set; }

    [Column("user_id")]
    public Guid UserId { get; set; }

    [Column("channel")]
    public string Channel { get; set; } = "in_app";

    [Column("message")]
    public string Message { get; set; } = string.Empty;


    [Column("sent_at")]
    public DateTime SentAt { get; set; }

    [Column("is_read")]
    public bool IsRead { get; set; }
}
