using Business.Application.Repositories;
using Shared.Domain.Errors;
using FluentResults;

namespace Business.Application.UseCases.Common;

/// <summary>Shared by CreateTransaction and UpdateTransaction — the same check applies to both.</summary>
internal static class StockAvailabilityChecker
{
    public static async Task<Result> EnsureAvailableAsync(
        IAssetRepository assetRepository, ITransactionRepository transactionRepository,
        Guid tenantId, DateTime from, DateTime to,
        List<TransactionAssetInput> assets, Guid? excludeTransactionId, CancellationToken cancellationToken)
    {
        foreach (var item in assets)
        {
            var asset = await assetRepository.GetByIdAsync(item.AssetId, tenantId, cancellationToken);
            if (asset is null)
                return Result.Fail(new NotFoundError($"Asset '{item.AssetId}' not found."));

            var alreadyReserved = await transactionRepository.GetReservedQuantityAsync(item.AssetId, from, to, excludeTransactionId, cancellationToken);
            if (alreadyReserved + item.Quantity > asset.StockCount)
                return Result.Fail($"Not enough stock for '{asset.Name}' in the selected date range.");
        }

        return Result.Ok();
    }
}
