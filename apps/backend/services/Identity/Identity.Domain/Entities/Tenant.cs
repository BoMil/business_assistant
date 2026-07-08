using Shared.Domain.Common;

namespace Identity.Domain.Entities;

public class Tenant : Entity<Guid>
{
    public string Name { get; private set; } = string.Empty;
    public string Slug { get; private set; } = string.Empty;
    public string? LogoUrl { get; private set; }
    public string PrimaryColor { get; private set; } = "#000000";
    public string SecondaryColor { get; private set; } = "#ffffff";
    public bool IsActive { get; private set; }
    public DateTime CreatedAt { get; private set; }
    public FeatureFlags FeatureFlags { get; private set; } = new();

    public ICollection<User> Users { get; private set; } = [];

    private Tenant() { }

    public static Tenant Create(string name, string slug, string primaryColor, string secondaryColor)
    {
        return new Tenant
        {
            Id = Guid.NewGuid(),
            Name = name,
            Slug = slug.ToLowerInvariant(),
            PrimaryColor = primaryColor,
            SecondaryColor = secondaryColor,
            IsActive = true,
            CreatedAt = DateTime.UtcNow
        };
    }

    public void UpdateBranding(string? logoUrl, string primaryColor, string secondaryColor)
    {
        LogoUrl = logoUrl;
        PrimaryColor = primaryColor;
        SecondaryColor = secondaryColor;
    }

    public void Deactivate() => IsActive = false;
}
