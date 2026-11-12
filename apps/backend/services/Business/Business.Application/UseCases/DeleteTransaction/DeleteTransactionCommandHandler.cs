using Business.Application.Repositories;
using Shared.Domain.Errors;
using FluentResults;
using MediatR;
using MassTransit;
using Microsoft.Extensions.Logging;
using Shared.Queues.Enums;
using Shared.Queues.IntegrationEvents;

namespace Business.Application.UseCases.DeleteTransaction;

internal sealed class DeleteTransactionCommandHandler(IUnitOfWorkBusiness unitOfWork, IPublishEndpoint publishEndpoint, ILogger<DeleteTransactionCommandHandler> logger)
    : IRequestHandler<DeleteTransactionCommand, Result>
{
    public async Task<Result> Handle(DeleteTransactionCommand request, CancellationToken cancellationToken)
    {
        var transaction = await unitOfWork.Transactions.GetByIdAsync(request.Id, request.TenantId, cancellationToken);
        if (transaction is null)
            return Result.Fail(new NotFoundError($"Transaction '{request.Id}' not found."));

        unitOfWork.Transactions.Remove(transaction);
        await unitOfWork.SaveChangesAsync(cancellationToken);

        // Send push notifications to other users
        try
        {
            await publishEndpoint.Publish(
                new TenantNotificationRequested(
                    request.TenantId, request.UserId, "Догађај је обрисан", transaction.Title,
                    PushEntityType.Transaction, PushAction.Deleted, transaction.Id),
                cancellationToken);
        }
        catch (Exception ex)
        {
            // Broker being unreachable must not fail the delete — the notification is a
            // side effect, not part of this operation's success criteria.
            logger.LogWarning(ex, "Failed to publish TenantNotificationRequested for deleted transaction {TransactionId}", transaction.Id);
        }
        return Result.Ok();
    }
}
