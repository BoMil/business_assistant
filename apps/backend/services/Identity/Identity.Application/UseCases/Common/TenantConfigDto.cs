namespace Identity.Application.UseCases.Common;

/// <summary>
/// Tenant branding + feature flags, shared by LoginResult and GetTenantConfig —
/// both need the exact same shape, so it lives here instead of being duplicated.
/// </summary>
public record TenantConfigDto(
    Guid TenantId,
    string Name,
    string? LogoUrl,
    string PrimaryColor,
    string AccentColor,
    string ErrorColor,
    bool Rental,
    bool Inventory,
    bool Reporting,
    bool Poultry,
    bool ThemeChange,
    bool Language);
