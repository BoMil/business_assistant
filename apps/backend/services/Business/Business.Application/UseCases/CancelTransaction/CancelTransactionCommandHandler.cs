using Business.Application.Repositories;
using Shared.Domain.Errors;
using FluentResults;
using MassTransit;
using MediatR;
using Microsoft.Extensions.Logging;
using Shared.Queues.Enums;
using Shared.Queues.IntegrationEvents;

namespace Business.Application.UseCases.CancelTransaction;

internal sealed class CancelTransactionCommandHandler(
    IUnitOfWorkBusiness unitOfWork, IPublishEndpoint publishEndpoint, ILogger<CancelTransactionCommandHandler> logger)
    : IRequestHandler<CancelTransactionCommand, Result>
{
    public async Task<Result> Handle(CancelTransactionCommand request, CancellationToken cancellationToken)
    {
        var transaction = await unitOfWork.Transactions.GetByIdAsync(request.Id, request.TenantId, cancellationToken);
        if (transaction is null)
            return Result.Fail(new NotFoundError($"Transaction '{request.Id}' not found."));

        transaction.Cancel();
        await unitOfWork.SaveChangesAsync(cancellationToken);

        try
        {
            await publishEndpoint.Publish(
                new TenantNotificationRequested(
                    request.TenantId, request.UserId, "Догађај је отказан", transaction.Title,
                    PushEntityType.Transaction, PushAction.Deleted, transaction.Id),
                cancellationToken);
        }
        catch (Exception ex)
        {
            // Broker being unreachable must not fail the cancel — the notification is a
            // side effect, not part of this operation's success criteria.
            logger.LogWarning(ex, "Failed to publish TenantNotificationRequested for cancelled transaction {TransactionId}", transaction.Id);
        }

        return Result.Ok();
    }
}
