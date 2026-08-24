using Business.Application.Repositories;
using Business.Domain.Entities;
using FluentResults;
using MassTransit;
using MediatR;
using Microsoft.Extensions.Logging;
using Shared.Queues.Enums;
using Shared.Queues.IntegrationEvents;

namespace Business.Application.UseCases.CreateAsset;

internal sealed class CreateAssetCommandHandler(
    IUnitOfWorkBusiness unitOfWork, IPublishEndpoint publishEndpoint, ILogger<CreateAssetCommandHandler> logger)
    : IRequestHandler<CreateAssetCommand, Result<Guid>>
{
    public async Task<Result<Guid>> Handle(CreateAssetCommand request, CancellationToken cancellationToken)
    {
        var asset = Asset.Create(request.TenantId, request.Name, request.CategoryId, request.Description, request.SalePrice, request.RentalPrice, request.StockCount, request.ImgUrl);

        await unitOfWork.Assets.AddAsync(asset, cancellationToken);
        await unitOfWork.SaveChangesAsync(cancellationToken);

        try
        {
            await publishEndpoint.Publish(
                new TenantNotificationRequested(
                    request.TenantId, request.UserId, "Нови производ је додат", asset.Name,
                    PushEntityType.Asset, PushAction.Created, asset.Id),
                cancellationToken);
        }
        catch (Exception ex)
        {
            // Broker being unreachable must not fail the create — the notification is a
            // side effect, not part of this operation's success criteria.
            logger.LogWarning(ex, "Failed to publish TenantNotificationRequested for created asset {AssetId}", asset.Id);
        }

        return Result.Ok(asset.Id);
    }
}
