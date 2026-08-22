using Shared.Domain.Common;

namespace Identity.Domain.Entities;

public class DeviceToken : Entity<Guid>
{
    public string Token { get; private set; } = string.Empty;
    public DateTime CreatedAt { get; private set; }
    public DateTime LastUsedAt { get; private set; }

    public Guid UserId { get; private set; }
    public User User { get; private set; } = null!;

    private DeviceToken() { }

    public static DeviceToken Create(Guid userId, string token)
    {
        var now = DateTime.UtcNow;
        return new DeviceToken
        {
            Id = Guid.NewGuid(),
            UserId = userId,
            Token = token,
            CreatedAt = now,
            LastUsedAt = now
        };
    }

    public void Touch() => LastUsedAt = DateTime.UtcNow;

    /// <summary>A reinstall or a shared device can re-register a token that's already
    /// tied to a different user — reassigning keeps registration idempotent instead of
    /// requiring the caller to first find and delete the old row.</summary>
    public void ReassignTo(Guid userId)
    {
        UserId = userId;
        Touch();
    }
}
