namespace Business.Presentation.Endpoints.Transactions;

/// <summary>JSON body for PUT /transactions/{id}.</summary>
public record UpdateTransactionRequest(
    string Title,
    string? Description,
    DateTime? From,
    DateTime? To,
    string? LocationAddress,
    double? LocationLatitude,
    double? LocationLongitude,
    Guid? ClientId,
    List<TransactionLineItemRequest> LineItems);
