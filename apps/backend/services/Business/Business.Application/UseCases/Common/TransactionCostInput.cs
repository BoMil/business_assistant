namespace Business.Application.UseCases.Common;

public record TransactionCostInput(string Title, decimal Cost, bool IsIncludedInTotalCost);
