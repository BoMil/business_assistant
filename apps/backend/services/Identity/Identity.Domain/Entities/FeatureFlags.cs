namespace Identity.Domain.Entities;

/// <summary>
/// Generic UX preferences — same meaning regardless of tenant type, unlike
/// <see cref="TenantModules"/> which controls which business modules/pages exist.
/// </summary>
public class FeatureFlags
{
    public bool ThemeChange { get; set; } = true;
    public bool Language { get; set; } = true;
}
