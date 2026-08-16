using Business.Domain.Entities;

namespace Business.Application.Repositories;

public interface ICategoryRepository
{
    // CancellationToken is threaded through so a caller can cancel the DB call early
    // (e.g. if the HTTP request is aborted) — not read/checked here, just passed on.
    Task<Category?> GetByIdAsync(Guid id, Guid tenantId, CancellationToken cancellationToken = default);
    Task<List<Category>> GetAllAsync(Guid tenantId, CancellationToken cancellationToken = default);
    Task<bool> ExistsByNameAsync(Guid tenantId, string name, CancellationToken cancellationToken = default);
    Task AddAsync(Category category, CancellationToken cancellationToken = default);
    void Remove(Category category);
}