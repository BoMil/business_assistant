using FluentResults;
using Identity.Application.Repositories;
using Identity.Application.Services;
using MediatR;

namespace Identity.Application.UseCases.BroadcastTenantNotification;

internal sealed class BroadcastTenantNotificationCommandHandler(IUnitOfWorkIdentity unitOfWork, IPushNotificationService pushNotificationService)
    : IRequestHandler<BroadcastTenantNotificationCommand, Result>
{
    public async Task<Result> Handle(BroadcastTenantNotificationCommand request, CancellationToken cancellationToken)
    {
        var deviceTokens = await unitOfWork.DeviceTokens.GetByTenantIdAsync(request.TenantId, request.ExcludeUserId, cancellationToken);

        var data = new Dictionary<string, string>
        {
            ["entityType"] = request.EntityType.ToString(),
            ["action"] = request.Action.ToString(),
            ["entityId"] = request.EntityId.ToString()
        };

        foreach (var deviceToken in deviceTokens)
            await pushNotificationService.SendAsync(request.TenantId, deviceToken.Token, request.Title, request.Body, data, cancellationToken);

        return Result.Ok();
    }
}
