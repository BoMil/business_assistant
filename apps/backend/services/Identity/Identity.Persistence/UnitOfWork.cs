using Identity.Application.Repositories;

namespace Identity.Persistence;

/// <summary>
/// Wraps DbContext.SaveChangesAsync so that application handlers never depend directly on EF Core.
/// All changes tracked during a request are committed in a single database round-trip.
/// </summary>
internal sealed class UnitOfWork(IdentityDbContext context) : IUnitOfWork
{
    public Task<int> SaveChangesAsync(CancellationToken cancellationToken = default) =>
        context.SaveChangesAsync(cancellationToken);
}
