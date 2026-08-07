namespace Business.Presentation.Endpoints.Transactions;

public record TransactionAssetRequest(Guid AssetId, int Quantity, decimal Price);
