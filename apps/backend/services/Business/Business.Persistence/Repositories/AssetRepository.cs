using Business.Application.Repositories;
using Business.Domain.Entities;
using Microsoft.EntityFrameworkCore;

namespace Business.Persistence.Repositories;

internal sealed class AssetRepository(BusinessDbContext context) : IAssetRepository
{
    public Task<Asset?> GetByIdAsync(Guid id, Guid tenantId, CancellationToken cancellationToken = default) =>
        context.Assets.Include(a => a.Category).FirstOrDefaultAsync(a => a.Id == id && a.TenantId == tenantId, cancellationToken);

    public Task<List<Asset>> GetAllAsync(Guid tenantId, CancellationToken cancellationToken = default) =>
        context.Assets.Include(a => a.Category).Where(a => a.TenantId == tenantId).ToListAsync(cancellationToken);

    public async Task AddAsync(Asset asset, CancellationToken cancellationToken = default) =>
        await context.Assets.AddAsync(asset, cancellationToken);
}
