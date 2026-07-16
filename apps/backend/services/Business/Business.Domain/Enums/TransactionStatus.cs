namespace Business.Domain.Enums;

/// <summary>
/// Derived (never persisted) lifecycle status of a Rental-type transaction, computed from
/// From/To against "now" — see <see cref="Entities.Transaction.GetStatus"/>. Only meaningful
/// for <see cref="TransactionType.Rental"/>; other transaction types are instantaneous and
/// have no lifecycle.
/// </summary>
public enum TransactionStatus
{
    Pending,
    InProgress,
    Finished,
    Canceled
}
