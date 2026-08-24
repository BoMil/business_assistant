using Business.Application.Repositories;
using Business.Application.UseCases.Common;
using Business.Domain.Enums;
using Shared.Domain.Errors;
using Business.Domain.ValueObjects;
using FluentResults;
using MassTransit;
using MediatR;
using Microsoft.Extensions.Logging;
using Shared.Queues.Enums;
using Shared.Queues.IntegrationEvents;

namespace Business.Application.UseCases.UpdateTransaction;

internal sealed class UpdateTransactionCommandHandler(
    IUnitOfWorkBusiness unitOfWork, IPublishEndpoint publishEndpoint, ILogger<UpdateTransactionCommandHandler> logger)
    : IRequestHandler<UpdateTransactionCommand, Result>
{
    public async Task<Result> Handle(UpdateTransactionCommand request, CancellationToken cancellationToken)
    {
        var transaction = await unitOfWork.Transactions.GetByIdAsync(request.Id, request.TenantId, cancellationToken);
        if (transaction is null)
            return Result.Fail(new NotFoundError($"Transaction '{request.Id}' not found."));

        if (transaction.IsCancelled)
            return Result.Fail("A cancelled transaction cannot be edited.");

        if (transaction.Type == TransactionType.Rental && request.From is not null && request.To is not null)
        {
            // Exclude this transaction's own current reservation, since we're about to replace it.
            var availability = await StockAvailabilityChecker.EnsureAvailableAsync(
                unitOfWork.Assets, unitOfWork.Transactions, request.TenantId,
                request.From.Value, request.To.Value, request.Assets, excludeTransactionId: transaction.Id, cancellationToken);

            if (availability.IsFailed)
                return availability;
        }

        var location = request.LocationAddress is null || request.LocationLatitude is null || request.LocationLongitude is null
            ? null
            : Location.Create(request.LocationAddress, request.LocationLatitude.Value, request.LocationLongitude.Value);

        transaction.Update(request.Title, request.Description, request.From, request.To, location, request.ClientId);

        transaction.ClearAssets();
        foreach (var item in request.Assets)
            transaction.AddAsset(item.AssetId, item.Quantity, item.Price);

        transaction.ClearCosts();
        foreach (var item in request.Costs)
            transaction.AddCost(item.Title, item.Cost, item.IsIncludedInTotalCost);

        unitOfWork.Transactions.TrackNewChildren(transaction);

        await unitOfWork.SaveChangesAsync(cancellationToken);

        try
        {
            await publishEndpoint.Publish(
                new TenantNotificationRequested(
                    request.TenantId, request.UserId, "Догађај је ажуриран", transaction.Title,
                    PushEntityType.Transaction, PushAction.Updated, transaction.Id),
                cancellationToken);
        }
        catch (Exception ex)
        {
            // Broker being unreachable must not fail the update — the notification is a
            // side effect, not part of this operation's success criteria.
            logger.LogWarning(ex, "Failed to publish TenantNotificationRequested for updated transaction {TransactionId}", transaction.Id);
        }

        return Result.Ok();
    }
}
