using Identity.Domain.Enums;

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
    TenantType Type,
    bool Events,
    bool Inventory,
    bool Clients,
    bool ThemeChange,
    bool Language);
