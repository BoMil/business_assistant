using FluentResults;
using Identity.Application.Repositories;
using Identity.Application.Services;
using MediatR;
using Shared.Domain.Errors;

namespace Identity.Application.UseCases.SendTestPush;

internal sealed class SendTestPushCommandHandler(IUnitOfWorkIdentity unitOfWork, IPushNotificationService pushNotificationService)
    : IRequestHandler<SendTestPushCommand, Result<SendTestPushResult>>
{
    public async Task<Result<SendTestPushResult>> Handle(SendTestPushCommand request, CancellationToken cancellationToken)
    {
        var user = await unitOfWork.Users.GetByIdAsync(request.UserId, cancellationToken);
        if (user is null)
            return Result.Fail(new NotFoundError($"User '{request.UserId}' not found."));

        var deviceTokens = await unitOfWork.DeviceTokens.GetByUserIdAsync(request.UserId, cancellationToken);
        if (deviceTokens.Count == 0)
            return Result.Fail(new NotFoundError("No device tokens registered for this user."));

        var sentCount = 0;
        var failedCount = 0;

        foreach (var deviceToken in deviceTokens)
        {
            var sent = await pushNotificationService.SendAsync(
                user.TenantId,
                deviceToken.Token,
                "Test notification",
                "If you can see this, push notifications are working.",
                cancellationToken: cancellationToken);

            if (sent)
                sentCount++;
            else
                failedCount++;
        }

        return Result.Ok(new SendTestPushResult(deviceTokens.Count, sentCount, failedCount));
    }
}
