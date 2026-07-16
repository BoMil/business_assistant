namespace Business.Domain.Enums;

/// <summary>
/// What kind of movement a <see cref="Entities.Transaction"/> represents. Maps to concrete
/// concepts differently per tenant type:
///   - Rental: <see cref="Rental"/> is the "Event" shown in the Rental UI (has From/To/Location/Client).
///   - Farming (future): <see cref="Production"/> = egg collection (increases Asset stock, no client, no dates),
///     <see cref="Consumption"/> = feed usage (decreases Asset stock, no client, no dates),
///     <see cref="Sale"/> = selling produce (decreases Asset stock, has a client, no From/To).
/// </summary>
public enum TransactionType
{
    Rental = 1,
    Sale = 2,
    Consumption = 3,
    Production = 4
}
