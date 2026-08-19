using Business.Domain.Entities;

namespace Business.Application.Repositories;

public interface IAssetRepository
{
    Task<Asset?> GetByIdAsync(Guid id, Guid tenantId, CancellationToken cancellationToken = default);
    Task<List<Asset>> GetAllAsync(Guid tenantId, CancellationToken cancellationToken = default);
    Task<(List<Asset> Items, int TotalCount)> GetPagedAsync(
        Guid tenantId, int page, int pageSize, string? searchTerm, CancellationToken cancellationToken = default);
    Task AddAsync(Asset asset, CancellationToken cancellationToken = default);
}
