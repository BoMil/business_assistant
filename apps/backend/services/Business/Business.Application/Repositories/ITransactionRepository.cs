using Business.Domain.Entities;

namespace Business.Application.Repositories;

public interface ITransactionRepository
{
    Task<Transaction?> GetByIdAsync(Guid id, Guid tenantId, CancellationToken cancellationToken = default);
    Task<List<Transaction>> GetAllAsync(Guid tenantId, CancellationToken cancellationToken = default);
    Task<List<Transaction>> GetByClientAsync(Guid clientId, Guid tenantId, CancellationToken cancellationToken = default);
    Task AddAsync(Transaction transaction, CancellationToken cancellationToken = default);

    /// <summary>
    /// Sum of quantities already reserved for <paramref name="assetId"/> across active
    /// (non-cancelled) Rental transactions whose [From,To] range overlaps [<paramref name="from"/>,
    /// <paramref name="to"/>]. Pass <paramref name="excludeTransactionId"/> when updating an
    /// existing transaction so it doesn't count its own previous reservation against itself.
    /// Used by CreateTransaction/UpdateTransaction to check stock availability before confirming.
    /// </summary>
    Task<int> GetReservedQuantityAsync(Guid assetId, DateTime from, DateTime to, Guid? excludeTransactionId, CancellationToken cancellationToken = default);
}
