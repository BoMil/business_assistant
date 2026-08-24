using Business.Domain.Enums;

namespace Business.Application.UseCases.Common;

public record TransactionAssetDto(Guid AssetId, string AssetName, int Quantity, decimal Price);

public record TransactionCostDto(Guid Id, string Title, decimal Cost, bool IsIncludedInTotalCost);

/// <summary>
/// <see cref="Status"/> is derived at query time (Transaction.GetStatus in the Domain project) —
/// null for instantaneous transaction types (Sale/Consumption/Production), which have no
/// From/To lifecycle.
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
    List<TransactionCostDto> Costs);
