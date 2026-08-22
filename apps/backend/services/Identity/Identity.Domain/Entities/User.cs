using Identity.Domain.Enums;
using Shared.Domain.Common;

namespace Identity.Domain.Entities;

public class User : Entity<Guid>
{
    public string FirstName { get; private set; } = string.Empty;
    public string LastName { get; private set; } = string.Empty;
    public string Email { get; private set; } = string.Empty;
    public string PhoneNumber { get; private set; } = string.Empty;
    public string PasswordHash { get; private set; } = string.Empty;
    public UserRole Role { get; private set; }
    public string? ImgUrl { get; private set; }
    public bool IsActive { get; private set; }
    public DateTime CreatedAt { get; private set; }
    public DateTime? UpdatedAt { get; private set; }

    public Guid TenantId { get; private set; }
    public Tenant Tenant { get; private set; } = null!;

    public ICollection<RefreshToken> RefreshTokens { get; private set; } = [];
    public ICollection<DeviceToken> DeviceTokens { get; private set; } = [];

    private User() { }

    public static User Create(string firstName, string lastName, string email, string phoneNumber, string passwordHash, Guid tenantId, UserRole role = UserRole.Member)
    {
        return new User
        {
            Id = Guid.NewGuid(),
            FirstName = firstName,
            LastName = lastName,
            Email = email.ToLowerInvariant(),
            PhoneNumber = phoneNumber,
            PasswordHash = passwordHash,
            TenantId = tenantId,
            Role = role,
            IsActive = true,
            CreatedAt = DateTime.UtcNow
        };
    }

    public void UpdatePassword(string newPasswordHash)
    {
        PasswordHash = newPasswordHash;
        UpdatedAt = DateTime.UtcNow;
    }

    public void UpdateImage(string? imgUrl)
    {
        ImgUrl = imgUrl;
        UpdatedAt = DateTime.UtcNow;
    }

    public void Deactivate() => IsActive = false;
}
