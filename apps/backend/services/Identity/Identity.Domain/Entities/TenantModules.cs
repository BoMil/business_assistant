using Identity.Domain.Enums;

namespace Identity.Domain.Entities;

/// <summary>
/// Which business modules/pages this tenant has access to — drives the mobile app's
/// bottom navigation. Unlike <see cref="FeatureFlags"/> (generic UX preferences), these
/// are tied to the tenant's business domain and seeded from <see cref="TenantType"/> at
/// creation time; each can still be toggled independently afterwards.
///
/// Only covers modules that actually exist today (Rental's Events/Inventory/Clients,
/// backed by the Business service). Reporting and Poultry are deliberately not modeled
/// yet — add them here once those modules are actually built.
/// </summary>
public class TenantModules
{
    public bool Events { get; set; }
    public bool Inventory { get; set; }
    public bool Clients { get; set; }

    public static TenantModules CreateDefaults(TenantType type) => type switch
    {
        TenantType.Rental => new TenantModules { Events = true, Inventory = true, Clients = true },
        TenantType.Farming => new TenantModules { Inventory = true },
        _ => new TenantModules()
    };
}
