namespace Identity.Application.Repositories;

/// <summary>
/// Mirrors Zepp.WebApp's fat aggregate UnitOfWork shape (e.g. IUnitOfWorkCustomers) — one
/// UoW per service exposing every repository as a property, instead of injecting each
/// repository separately into handlers.
/// </summary>
public interface IUnitOfWorkIdentity
{
    IUserRepository Users { get; }
    ITenantRepository Tenants { get; }
    IRefreshTokenRepository RefreshTokens { get; }
    IDeviceTokenRepository DeviceTokens { get; }

    Task<int> SaveChangesAsync(CancellationToken cancellationToken = default);
}
