using Shared.Domain.Common;

namespace Business.Domain.Entities;

/// <summary>
/// One Asset line within a Transaction (e.g. "5x Tiffany Stolice @ 50 each" on a Rental event).
/// A single Transaction can carry multiple line items — this is what lets an Event on the
/// Rental UI include several products at once.
/// </summary>
public class TransactionAsset : Entity<Guid>
{
    public Guid TransactionId { get; private set; }
    public Guid AssetId { get; private set; }
    public int Quantity { get; private set; }
    public decimal Price { get; private set; }

    private TransactionAsset() { }

    public static TransactionAsset Create(Guid transactionId, Guid assetId, int quantity, decimal price) =>
        new()
        {
            Id = Guid.NewGuid(),
            TransactionId = transactionId,
            AssetId = assetId,
            Quantity = quantity,
            Price = price
        };
}
