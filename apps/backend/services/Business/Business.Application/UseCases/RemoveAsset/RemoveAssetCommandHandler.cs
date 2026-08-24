using Business.Application.Repositories;
using Shared.Domain.Errors;
using FluentResults;
using MassTransit;
using MediatR;
using Microsoft.Extensions.Logging;
using Shared.Queues.Enums;
using Shared.Queues.IntegrationEvents;

namespace Business.Application.UseCases.RemoveAsset;

internal sealed class RemoveAssetCommandHandler(
    IUnitOfWorkBusiness unitOfWork, IPublishEndpoint publishEndpoint, ILogger<RemoveAssetCommandHandler> logger)
    : IRequestHandler<RemoveAssetCommand, Result>
{
    public async Task<Result> Handle(RemoveAssetCommand request, CancellationToken cancellationToken)
    {
        var asset = await unitOfWork.Assets.GetByIdAsync(request.Id, request.TenantId, cancellationToken);
        if (asset is null)
            return Result.Fail(new NotFoundError($"Asset '{request.Id}' not found."));

        asset.Remove();
        await unitOfWork.SaveChangesAsync(cancellationToken);

        try
        {
            await publishEndpoint.Publish(
                new TenantNotificationRequested(
                    request.TenantId, request.UserId, "Производ је уклоњен", asset.Name,
                    PushEntityType.Asset, PushAction.Deleted, asset.Id),
                cancellationToken);
        }
        catch (Exception ex)
        {
            // Broker being unreachable must not fail the remove — the notification is a
            // side effect, not part of this operation's success criteria.
            logger.LogWarning(ex, "Failed to publish TenantNotificationRequested for removed asset {AssetId}", asset.Id);
        }

        return Result.Ok();
    }
}
