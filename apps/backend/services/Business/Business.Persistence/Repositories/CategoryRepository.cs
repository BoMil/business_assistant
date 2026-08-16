
using Business.Application.Repositories;
using Business.Domain.Entities;
using Microsoft.EntityFrameworkCore;

namespace Business.Persistence.Repositories;

internal sealed class CategoryRepository(BusinessDbContext context) : ICategoryRepository
{
    public Task<Category?> GetByIdAsync(Guid id, Guid tenantId, CancellationToken cancellationToken = default) =>
        context.Categories.FirstOrDefaultAsync(c => c.Id == id && c.TenantId == tenantId, cancellationToken);

    public Task<List<Category>> GetAllAsync(Guid tenantId, CancellationToken cancellationToken = default) =>
        context.Categories.Where(c => c.TenantId == tenantId).ToListAsync(cancellationToken);

    public Task<bool> ExistsByNameAsync(Guid tenantId, string name, CancellationToken cancellationToken = default) =>
        context.Categories.AnyAsync(c => c.TenantId == tenantId && c.Name == name, cancellationToken);

    public async Task AddAsync(Category category, CancellationToken cancellationToken = default) =>
        await context.Categories.AddAsync(category, cancellationToken);

    public void Remove(Category category) =>
        context.Categories.Remove(category);

}