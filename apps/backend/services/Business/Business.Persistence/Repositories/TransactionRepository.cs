using Business.Application.Repositories;
using Business.Domain.Entities;
using Business.Domain.Enums;
using Microsoft.EntityFrameworkCore;

namespace Business.Persistence.Repositories;

internal sealed class TransactionRepository(BusinessDbContext context) : ITransactionRepository
{
    public Task<Transaction?> GetByIdAsync(Guid id, Guid tenantId, CancellationToken cancellationToken = default) =>
        context.Transactions
            .Include(t => t.LineItems)
            .FirstOrDefaultAsync(t => t.Id == id && t.TenantId == tenantId, cancellationToken);

    public Task<List<Transaction>> GetAllAsync(Guid tenantId, CancellationToken cancellationToken = default) =>
        context.Transactions
            .Include(t => t.LineItems)
            .Where(t => t.TenantId == tenantId)
            .ToListAsync(cancellationToken);

    public Task<List<Transaction>> GetByClientAsync(Guid clientId, Guid tenantId, CancellationToken cancellationToken = default) =>
        context.Transactions
            .Include(t => t.LineItems)
            .Where(t => t.TenantId == tenantId && t.ClientId == clientId)
            .ToListAsync(cancellationToken);

    public async Task AddAsync(Transaction transaction, CancellationToken cancellationToken = default) =>
        await context.Transactions.AddAsync(transaction, cancellationToken);

    public Task<int> GetReservedQuantityAsync(Guid assetId, DateTime from, DateTime to, Guid? excludeTransactionId, CancellationToken cancellationToken = default)
    {
        // Standard interval-overlap check: two ranges [From,To] and [from,to] overlap
        // whenever From <= to && To >= from.
        var query = context.Transactions
            .Where(t => t.Type == TransactionType.Rental && !t.IsCancelled && t.From != null && t.To != null)
            .Where(t => t.From <= to && t.To >= from);

        if (excludeTransactionId is not null)
            query = query.Where(t => t.Id != excludeTransactionId);

        return query
            .SelectMany(t => t.LineItems)
            .Where(li => li.AssetId == assetId)
            .SumAsync(li => (int?)li.Quantity, cancellationToken)
            .ContinueWith(t => t.Result ?? 0, cancellationToken);
    }
}
