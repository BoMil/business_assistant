using Business.Domain.Entities;

namespace Business.Application.Repositories;

public interface ITransactionRepository
{
    Task<Transaction?> GetByIdAsync(Guid id, Guid tenantId, CancellationToken cancellationToken = default);
    Task<List<Transaction>> GetByClientAsync(Guid clientId, Guid tenantId, CancellationToken cancellationToken = default);

    /// <summary>
    /// Page of transactions ordered most-recent-first (by From date), optionally filtered by
    /// <paramref name="searchTerm"/> matching Title or the owned Location's Address (case
    /// insensitive — translated to SQL LIKE/Contains by EF). Used by GetTransactions for the
    /// mobile Events list's pagination + search.
    /// </summary>
    Task<(List<Transaction> Items, int TotalCount)> GetPagedAsync(
        Guid tenantId, int page, int pageSize, string? searchTerm, CancellationToken cancellationToken = default);

    Task AddAsync(Transaction transaction, CancellationToken cancellationToken = default);

    /// <summary>
    /// Explicitly marks a Transaction's current Assets/Costs as Added. Needed after an Update
    /// handler's Clear+re-Add replacement of these collections: since the child entities already
    /// have their (client-generated Guid) key set, EF Core's change detection can't tell them apart
    /// from existing rows when it discovers them via navigation fixup, and defaults to Modified —
    /// generating an UPDATE against a row that doesn't exist yet. Create doesn't need this because
    /// AddAsync's own Add() call already cascades Added to the whole graph unconditionally.
    /// </summary>
    void TrackNewChildren(Transaction transaction);

    /// <summary>
    /// Sum of quantities already reserved for <paramref name="assetId"/> across active
    /// (non-cancelled) Rental transactions whose [From,To] range overlaps [<paramref name="from"/>,
    /// <paramref name="to"/>]. Pass <paramref name="excludeTransactionId"/> when updating an
    /// existing transaction so it doesn't count its own previous reservation against itself.
    /// Used by CreateTransaction/UpdateTransaction to check stock availability before confirming.
    /// </summary>
    Task<int> GetReservedQuantityAsync(Guid assetId, DateTime from, DateTime to, Guid? excludeTransactionId, CancellationToken cancellationToken = default);
}
