using Shared.Domain.Common;

namespace Business.Domain.Entities;

/// <summary>
/// An additional cost on a Transaction beyond its line-item Assets (e.g. delivery fee, cleaning
/// cost). <see cref="IsIncludedInTotalCost"/> controls whether it's folded into the customer-facing
/// total or kept as a hidden cost only visible when computing net profit.
/// </summary>
public class TransactionCost : Entity<Guid>
{
    public Guid TransactionId { get; private set; }
    public string Title { get; private set; } = string.Empty;
    public decimal Cost { get; private set; }
    public bool IsIncludedInTotalCost { get; private set; }

    private TransactionCost() { }

    public static TransactionCost Create(Guid transactionId, string title, decimal cost, bool isIncludedInTotalCost) =>
        new()
        {
            Id = Guid.NewGuid(),
            TransactionId = transactionId,
            Title = title,
            Cost = cost,
            IsIncludedInTotalCost = isIncludedInTotalCost
        };
}
