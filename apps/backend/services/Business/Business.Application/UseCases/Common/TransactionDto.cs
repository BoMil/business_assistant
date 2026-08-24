using Business.Domain.Enums;

namespace Business.Application.UseCases.Common;

public record TransactionAssetDto(Guid AssetId, string AssetName, int Quantity, decimal Price);

public record TransactionCostDto(Guid Id, string Title, decimal Cost, bool IsIncludedInTotalCost);

/// <summary>
/// <see cref="Status"/>, <see cref="ChargedTotal"/> and <see cref="NetBalance"/> are all derived
/// at query time (Transaction.GetStatus / TransactionMapper), never persisted — Status is null for
/// instantaneous transaction types (Sale/Consumption/Production), which have no From/To lifecycle.
/// ChargedTotal is the assets total plus costs marked IsIncludedInTotalCost (what the client is
/// billed); NetBalance is ChargedTotal minus ALL costs, included or not (the actual profit/loss).
/// </summary>
public record TransactionDto(
    Guid Id,
    TransactionType Type,
    string Title,
    string? Description,
    DateTime? From,
    DateTime? To,
    string? LocationAddress,
    double? LocationLatitude,
    double? LocationLongitude,
    Guid? ClientId,
    TransactionStatus? Status,
    List<TransactionAssetDto> Assets,
    List<TransactionCostDto> Costs,
    decimal ChargedTotal,
    decimal NetBalance);
