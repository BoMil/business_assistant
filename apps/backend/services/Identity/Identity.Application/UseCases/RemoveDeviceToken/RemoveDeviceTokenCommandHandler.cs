using FluentResults;
using Identity.Application.Repositories;
using MediatR;

namespace Identity.Application.UseCases.RemoveDeviceToken;

internal sealed class RemoveDeviceTokenCommandHandler(IUnitOfWorkIdentity unitOfWork)
    : IRequestHandler<RemoveDeviceTokenCommand, Result>
{
    public async Task<Result> Handle(RemoveDeviceTokenCommand request, CancellationToken cancellationToken)
    {
        var deviceToken = await unitOfWork.DeviceTokens.GetByTokenAsync(request.Token, cancellationToken);

        // No-op if the token doesn't exist or belongs to another user — idempotent,
        // and doesn't leak whether a given token exists under someone else's account.
        if (deviceToken is not null && deviceToken.UserId == request.UserId)
        {
            unitOfWork.DeviceTokens.Remove(deviceToken);
            await unitOfWork.SaveChangesAsync(cancellationToken);
        }

        return Result.Ok();
    }
}
