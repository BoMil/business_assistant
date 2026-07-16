using Business.Application.Repositories;
using Business.Domain.Entities;

namespace Business.Application.UseCases.Common;

/// <summary>Shared Transaction → TransactionDto mapping, used by GetTransactions, GetTransactionById and GetClientTransactions.</summary>
internal static class TransactionMapper
{
    public static async Task<TransactionDto> ToDtoAsync(Transaction transaction, IAssetRepository assetRepository, Guid tenantId, DateTime now, CancellationToken cancellationToken)
    {
        var lineItems = new List<TransactionLineItemDto>();
        foreach (var lineItem in transaction.LineItems)
        {
            var asset = await assetRepository.GetByIdAsync(lineItem.AssetId, tenantId, cancellationToken);
            lineItems.Add(new TransactionLineItemDto(lineItem.AssetId, asset?.Name ?? string.Empty, lineItem.Quantity, lineItem.Price));
        }

        return new TransactionDto(
            transaction.Id, transaction.Type, transaction.Title, transaction.Description,
            transaction.From, transaction.To,
            transaction.Location?.Address, transaction.Location?.Latitude, transaction.Location?.Longitude,
            transaction.ClientId, transaction.GetStatus(now), lineItems);
    }
}
