namespace Business.Application.UseCases.Common;

public record TransactionLineItemInput(Guid AssetId, int Quantity, decimal Price);
