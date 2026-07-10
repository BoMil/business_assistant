using Shared.Domain.Common;

namespace Identity.Domain.Entities;

public class Tenant : Entity<Guid>
{
    public string Name { get; private set; } = string.Empty;
    public string Slug { get; private set; } = string.Empty;
    public string? LogoUrl { get; private set; }
    public string PrimaryColor { get; private set; } = "#000000";
    public string AccentColor { get; private set; } = "#ffffff";
    public string ErrorColor { get; private set; } = "#eb2e25";
    public bool IsActive { get; private set; }
    public DateTime CreatedAt { get; private set; }
    public FeatureFlags FeatureFlags { get; private set; } = new();

    public ICollection<User> Users { get; private set; } = [];

    private Tenant() { }

    public static Tenant Create(string name, string slug, string primaryColor, string accentColor, string errorColor)
    {
        return new Tenant
        {
            Id = Guid.NewGuid(),
            Name = name,
            Slug = slug.ToLowerInvariant(),
            PrimaryColor = primaryColor,
            AccentColor = accentColor,
            ErrorColor = errorColor,
            IsActive = true,
            CreatedAt = DateTime.UtcNow
        };
    }

    public void UpdateBranding(string? logoUrl, string primaryColor, string accentColor, string errorColor)
    {
        LogoUrl = logoUrl;
        PrimaryColor = primaryColor;
        AccentColor = accentColor;
        ErrorColor = errorColor;
    }

    public void Deactivate() => IsActive = false;
}
