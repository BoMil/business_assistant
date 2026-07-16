namespace Identity.Domain.Enums;

/// <summary>
/// Classifies what kind of business a tenant runs. Used only at tenant-creation time
/// to seed sensible <see cref="Entities.FeatureFlags"/> defaults (see
/// <see cref="Entities.FeatureFlags.CreateDefaults"/>) — after creation, flags can be
/// toggled independently of this value, so this is not read anywhere else.
/// </summary>
public enum TenantType
{
    Rental = 1,
    Farming = 2
}
