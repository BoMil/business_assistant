using Identity.Application.Repositories;
using Identity.Domain.Entities;
using Microsoft.EntityFrameworkCore;

namespace Identity.Persistence.Repositories;

internal sealed class TenantRepository(IdentityDbContext context) : ITenantRepository
{
    public Task<Tenant?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default) =>
        context.Tenants.FirstOrDefaultAsync(t => t.Id == id, cancellationToken);

    public Task<Tenant?> GetBySlugAsync(string slug, CancellationToken cancellationToken = default) =>
        context.Tenants.FirstOrDefaultAsync(t => t.Slug == slug, cancellationToken);

    public Task<bool> ExistsBySlugAsync(string slug, CancellationToken cancellationToken = default) =>
        context.Tenants.AnyAsync(t => t.Slug == slug, cancellationToken);

    public async Task AddAsync(Tenant tenant, CancellationToken cancellationToken = default) =>
        await context.Tenants.AddAsync(tenant, cancellationToken);
}
