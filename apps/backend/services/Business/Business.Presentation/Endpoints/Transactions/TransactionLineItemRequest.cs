namespace Business.Presentation.Endpoints.Transactions;

public record TransactionLineItemRequest(Guid AssetId, int Quantity, decimal Price);
