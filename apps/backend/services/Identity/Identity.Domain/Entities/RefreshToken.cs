using Shared.Domain.Common;

namespace Identity.Domain.Entities;

public class RefreshToken : Entity<Guid>
{
    public string Token { get; private set; } = string.Empty;
    public DateTime ExpiresAt { get; private set; }
    public bool IsRevoked { get; private set; }
    public DateTime CreatedAt { get; private set; }

    public Guid UserId { get; private set; }
    public User User { get; private set; } = null!;

    private RefreshToken() { }

    public static RefreshToken Create(Guid userId, string token, int expiryDays = 7)
    {
        return new RefreshToken
        {
            Id = Guid.NewGuid(),
            UserId = userId,
            Token = token,
            ExpiresAt = DateTime.UtcNow.AddDays(expiryDays),
            IsRevoked = false,
            CreatedAt = DateTime.UtcNow
        };
    }

    public bool IsExpired() => DateTime.UtcNow >= ExpiresAt;

    public bool IsValid() => !IsRevoked && !IsExpired();

    public void Revoke() => IsRevoked = true;
}
