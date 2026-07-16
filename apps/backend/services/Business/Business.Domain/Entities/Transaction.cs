using Business.Domain.Enums;
using Business.Domain.ValueObjects;
using Shared.Domain.Common;

namespace Business.Domain.Entities;

/// <summary>
/// A generic "movement of one or more Assets" — deliberately not called "Event" because the
/// same shape serves multiple tenant types without new code:
///   - Rental tenant: <see cref="TransactionType.Rental"/> is the "Event" from the Rental UI —
///     From/To/Location/ClientId are all set, LineItems are the products being rented out.
///   - Farming tenant (future): <see cref="TransactionType.Production"/> (egg collection) and
///     <see cref="TransactionType.Consumption"/> (feed usage) have no ClientId/From/To — they're
///     just a stock adjustment. <see cref="TransactionType.Sale"/> (selling produce) has a
///     ClientId but no From/To.
/// Stock-availability validation (does the Asset have enough free stock for the requested
/// date range) is NOT done here — it needs to compare against other transactions, so it lives
/// in the Application layer's CreateTransaction/UpdateTransaction handlers where a repository
/// is available.
/// </summary>
public class Transaction : Entity<Guid>
{
    public Guid TenantId { get; private set; }
    public TransactionType Type { get; private set; }
    public string Title { get; private set; } = string.Empty;
    public string? Description { get; private set; }
    public DateTime? From { get; private set; }
    public DateTime? To { get; private set; }
    public Location? Location { get; private set; }
    public Guid? ClientId { get; private set; }
    public bool IsCancelled { get; private set; }

    private readonly List<TransactionLineItem> _lineItems = [];
    public IReadOnlyCollection<TransactionLineItem> LineItems => _lineItems;

    private Transaction() { }

    public static Transaction Create(
        Guid tenantId, TransactionType type, string title, string? description,
        DateTime? from, DateTime? to, Location? location, Guid? clientId)
    {
        return new Transaction
        {
            Id = Guid.NewGuid(),
            TenantId = tenantId,
            Type = type,
            Title = title,
            Description = description,
            From = from,
            To = to,
            Location = location,
            ClientId = clientId
        };
    }

    public void Update(string title, string? description, DateTime? from, DateTime? to, Location? location, Guid? clientId)
    {
        Title = title;
        Description = description;
        From = from;
        To = to;
        Location = location;
        ClientId = clientId;
    }

    public void AddLineItem(Guid assetId, int quantity, decimal price) =>
        _lineItems.Add(TransactionLineItem.Create(Id, assetId, quantity, price));

    public void ClearLineItems() => _lineItems.Clear();

    public void Cancel() => IsCancelled = true;

    /// <summary>
    /// Only meaningful for <see cref="TransactionType.Rental"/> (the only type with a From/To
    /// lifecycle) — returns null for instantaneous types (Sale/Consumption/Production).
    /// </summary>
    public TransactionStatus? GetStatus(DateTime now)
    {
        if (IsCancelled) return TransactionStatus.Canceled;
        if (From is null || To is null) return null;
        if (now < From) return TransactionStatus.Pending;
        if (now > To) return TransactionStatus.Finished;
        return TransactionStatus.InProgress;
    }
}
