using Business.Domain.Enums;

namespace Business.Presentation.Endpoints.Transactions;

/// <summary>JSON body for POST /transactions.</summary>
public record CreateTransactionRequest(
    TransactionType Type,
    string Title,
    string? Description,
    DateTime? From,
    DateTime? To,
    string? LocationAddress,
    double? LocationLatitude,
    double? LocationLongitude,
    Guid? ClientId,
    List<TransactionAssetRequest> Assets);
