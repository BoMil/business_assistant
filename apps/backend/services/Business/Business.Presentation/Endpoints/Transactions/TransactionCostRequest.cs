namespace Business.Presentation.Endpoints.Transactions;

public record TransactionCostRequest(string Title, decimal Cost, bool IsIncludedInTotalCost);
