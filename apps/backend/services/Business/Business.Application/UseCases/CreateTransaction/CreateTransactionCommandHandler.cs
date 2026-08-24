using Business.Application.Repositories;
using Business.Application.UseCases.Common;
using Business.Domain.Entities;
using Business.Domain.Enums;
using Business.Domain.ValueObjects;
using FluentResults;
using MassTransit;
using MediatR;
using Microsoft.Extensions.Logging;
using Shared.Queues.Enums;
using Shared.Queues.IntegrationEvents;

namespace Business.Application.UseCases.CreateTransaction;

internal sealed class CreateTransactionCommandHandler(
    IUnitOfWorkBusiness unitOfWork, IPublishEndpoint publishEndpoint, ILogger<CreateTransactionCommandHandler> logger)
    : IRequestHandler<CreateTransactionCommand, Result<Guid>>
{
    public async Task<Result<Guid>> Handle(CreateTransactionCommand request, CancellationToken cancellationToken)
    {
        var location = request.LocationAddress is null || request.LocationLatitude is null || request.LocationLongitude is null
            ? null
            : Location.Create(request.LocationAddress, request.LocationLatitude.Value, request.LocationLongitude.Value);

        // Only Rental has a date range to check stock availability against — Sale/Consumption/
        // Production are instantaneous and don't reserve stock over time.
        if (request.Type == TransactionType.Rental && request.From is not null && request.To is not null)
        {
            var availability = await StockAvailabilityChecker.EnsureAvailableAsync(
                unitOfWork.Assets, unitOfWork.Transactions, request.TenantId,
                request.From.Value, request.To.Value, request.Assets, excludeTransactionId: null, cancellationToken);

            if (availability.IsFailed)
                return availability.ToResult<Guid>();
        }

        var transaction = Transaction.Create(request.TenantId, request.Type, request.Title, request.Description, request.From, request.To, location, request.ClientId);
        foreach (var item in request.Assets)
            transaction.AddAsset(item.AssetId, item.Quantity, item.Price);

        await unitOfWork.Transactions.AddAsync(transaction, cancellationToken);
        await unitOfWork.SaveChangesAsync(cancellationToken);

        try
        {
            await publishEndpoint.Publish(
                new TenantNotificationRequested(
                    request.TenantId, request.UserId, "Нови догађај је додат", transaction.Title,
                    PushEntityType.Transaction, PushAction.Created, transaction.Id),
                cancellationToken);
        }
        catch (Exception ex)
        {
            // Broker being unreachable must not fail the create — the notification is a
            // side effect, not part of this operation's success criteria.xs
            logger.LogWarning(ex, "Failed to publish TenantNotificationRequested for created transaction {TransactionId}", transaction.Id);
        }

        return Result.Ok(transaction.Id);
    }
}
