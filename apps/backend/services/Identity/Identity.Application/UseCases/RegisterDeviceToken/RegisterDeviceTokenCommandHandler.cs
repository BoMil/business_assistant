using FluentResults;
using Identity.Application.Repositories;
using Identity.Domain.Entities;
using MediatR;

namespace Identity.Application.UseCases.RegisterDeviceToken;

internal sealed class RegisterDeviceTokenCommandHandler(IUnitOfWorkIdentity unitOfWork)
    : IRequestHandler<RegisterDeviceTokenCommand, Result>
{
    public async Task<Result> Handle(RegisterDeviceTokenCommand request, CancellationToken cancellationToken)
    {
        var existing = await unitOfWork.DeviceTokens.GetByTokenAsync(request.Token, cancellationToken);
        if (existing is not null)
        {
            existing.ReassignTo(request.UserId);
        }
        else
        {
            var deviceToken = DeviceToken.Create(request.UserId, request.Token);
            await unitOfWork.DeviceTokens.AddAsync(deviceToken, cancellationToken);
        }

        await unitOfWork.SaveChangesAsync(cancellationToken);
        return Result.Ok();
    }
}
