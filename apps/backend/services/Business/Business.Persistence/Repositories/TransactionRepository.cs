using Business.Application.Repositories;
using Business.Domain.Entities;
using Business.Domain.Enums;
using Microsoft.EntityFrameworkCore;

namespace Business.Persistence.Repositories;

internal sealed class TransactionRepository(BusinessDbContext context) : ITransactionRepository
{
    public Task<Transaction?> GetByIdAsync(Guid id, Guid tenantId, CancellationToken cancellationToken = default) =>
        context.Transactions
            .Include(t => t.Assets)
            .Include(t => t.Costs)
            .FirstOrDefaultAsync(t => t.Id == id && t.TenantId == tenantId, cancellationToken);

    public Task<List<Transaction>> GetByClientAsync(Guid clientId, Guid tenantId, CancellationToken cancellationToken = default) =>
        context.Transactions
            .Include(t => t.Assets)
            .Include(t => t.Costs)
            .Where(t => t.TenantId == tenantId && t.ClientId == clientId)
            .ToListAsync(cancellationToken);

    public async Task<(List<Transaction> Items, int TotalCount)> GetPagedAsync(
        Guid tenantId, int page, int pageSize, string? searchTerm, CancellationToken cancellationToken = default)
    {
        var query = context.Transactions
            .Include(t => t.Assets)
            .Include(t => t.Costs)
            .Where(t => t.TenantId == tenantId);

        if (!string.IsNullOrWhiteSpace(searchTerm))
        {
            query = query.Where(t =>
                t.Title.Contains(searchTerm) ||
                (t.Location != null && t.Location.Address.Contains(searchTerm)));
        }

        var totalCount = await query.CountAsync(cancellationToken);

        // Two-tier default sort: active (Pending/InProgress) events on top, ascending by From
        // (soonest-upcoming/already-started first); Finished/Canceled events below, descending
        // by To (most-recently-finished first). The null-padded ThenBy keys let each tier's
        // ordering compose without disturbing the other (they're null for rows outside that tier).
        var now = DateTime.UtcNow;
        var items = await query
            .OrderBy(t => t.IsCancelled || (t.To.HasValue && t.To < now) ? 1 : 0)
            .ThenBy(t => t.IsCancelled || (t.To.HasValue && t.To < now) ? (DateTime?)null : t.From)
            .ThenByDescending(t => t.IsCancelled || (t.To.HasValue && t.To < now) ? t.To : (DateTime?)null)
            .ThenByDescending(t => t.Id)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .ToListAsync(cancellationToken);

        return (items, totalCount);
    }

    public Task<List<Transaction>> GetByDateRangeAsync(
        Guid tenantId, DateTime from, DateTime to, CancellationToken cancellationToken = default) =>
        context.Transactions
            .Include(t => t.Assets)
            .Include(t => t.Costs)
            .Where(t => t.TenantId == tenantId && t.From != null && t.To != null)
            .Where(t => t.From <= to && t.To >= from)
            .ToListAsync(cancellationToken);

    public async Task AddAsync(Transaction transaction, CancellationToken cancellationToken = default) =>
        await context.Transactions.AddAsync(transaction, cancellationToken);

    public void TrackNewChildren(Transaction transaction)
    {
        context.TransactionAssets.AddRange(transaction.Assets);
        context.TransactionCosts.AddRange(transaction.Costs);
    }

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
            .SelectMany(t => t.Assets)
            .Where(asset => asset.AssetId == assetId)
            .SumAsync(asset => (int?)asset.Quantity, cancellationToken)
            .ContinueWith(t => t.Result ?? 0, cancellationToken);
    }
}
