using FluentResults;
using Identity.Application.Repositories;
using Identity.Application.Services;
using MediatR;
using DomainRefreshToken = Identity.Domain.Entities.RefreshToken;

namespace Identity.Application.UseCases.RefreshToken;

internal sealed class RefreshTokenCommandHandler(
    IUnitOfWorkIdentity unitOfWork,
    IJwtProvider jwtProvider)
    : IRequestHandler<RefreshTokenCommand, Result<RefreshTokenResult>>
{
    public async Task<Result<RefreshTokenResult>> Handle(RefreshTokenCommand request, CancellationToken cancellationToken)
    {
        var existing = await unitOfWork.RefreshTokens.GetByTokenAsync(request.Token, cancellationToken);
        if (existing is null || !existing.IsValid())
            return Result.Fail("Refresh token is invalid or expired.");

        var user = await unitOfWork.Users.GetByIdAsync(existing.UserId, cancellationToken);
        if (user is null || !user.IsActive)
            return Result.Fail("User not found or deactivated.");

        existing.Revoke();

        var newAccessToken = jwtProvider.GenerateAccessToken(user);
        var newRawRefreshToken = jwtProvider.GenerateRefreshToken();
        var newRefreshToken = DomainRefreshToken.Create(user.Id, newRawRefreshToken);

        await unitOfWork.RefreshTokens.AddAsync(newRefreshToken, cancellationToken);
        await unitOfWork.SaveChangesAsync(cancellationToken);

        return Result.Ok(new RefreshTokenResult(newAccessToken, newRawRefreshToken));
    }
}
