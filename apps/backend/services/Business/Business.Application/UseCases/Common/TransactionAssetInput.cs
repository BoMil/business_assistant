namespace Business.Application.UseCases.Common;

public record TransactionAssetInput(Guid AssetId, int Quantity, decimal Price);
