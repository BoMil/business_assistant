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

    public async Task<(List<Asset> Items, int TotalCount)> GetPagedAsync(
        Guid tenantId, int page, int pageSize, string? searchTerm, CancellationToken cancellationToken = default)
    {
        var query = context.Assets
            .Include(a => a.Category)
            .Where(a => a.TenantId == tenantId && a.IsActive);

        if (!string.IsNullOrWhiteSpace(searchTerm))
        {
            query = query.Where(a =>
                a.Name.Contains(searchTerm) ||
                (a.Category != null && a.Category.Name.Contains(searchTerm)));
        }

        var totalCount = await query.CountAsync(cancellationToken);

        var items = await query
            .OrderBy(a => a.Name)
            .ThenBy(a => a.Id)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .ToListAsync(cancellationToken);

        return (items, totalCount);
    }

    public async Task AddAsync(Asset asset, CancellationToken cancellationToken = default) =>
        await context.Assets.AddAsync(asset, cancellationToken);
}
