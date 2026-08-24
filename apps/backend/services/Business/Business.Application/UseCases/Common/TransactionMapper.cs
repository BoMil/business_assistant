using Business.Application.Repositories;
using Business.Domain.Entities;

namespace Business.Application.UseCases.Common;

/// <summary>Shared Transaction → TransactionDto mapping, used by GetTransactions, GetTransactionById and GetClientTransactions.</summary>
internal static class TransactionMapper
{
    public static async Task<TransactionDto> ToDtoAsync(Transaction transaction, IAssetRepository assetRepository, Guid tenantId, DateTime now, CancellationToken cancellationToken)
    {
        var assetDtos = new List<TransactionAssetDto>();
        foreach (var transactionAsset in transaction.Assets)
        {
            var asset = await assetRepository.GetByIdAsync(transactionAsset.AssetId, tenantId, cancellationToken);
            assetDtos.Add(new TransactionAssetDto(transactionAsset.AssetId, asset?.Name ?? string.Empty, transactionAsset.Quantity, transactionAsset.Price));
        }

        var costDtos = transaction.Costs
            .Select(cost => new TransactionCostDto(cost.Id, cost.Title, cost.Cost, cost.IsIncludedInTotalCost))
            .ToList();

        var assetsTotal = transaction.Assets.Sum(a => a.Quantity * a.Price);
        var includedCostsTotal = transaction.Costs.Where(c => c.IsIncludedInTotalCost).Sum(c => c.Cost);
        var allCostsTotal = transaction.Costs.Sum(c => c.Cost);
        var chargedTotal = assetsTotal + includedCostsTotal;
        var netBalance = chargedTotal - allCostsTotal;

        return new TransactionDto(
            transaction.Id, transaction.Type, transaction.Title, transaction.Description,
            transaction.From, transaction.To,
            transaction.Location?.Address, transaction.Location?.Latitude, transaction.Location?.Longitude,
            transaction.ClientId, transaction.GetStatus(now), assetDtos, costDtos, chargedTotal, netBalance);
    }
}
