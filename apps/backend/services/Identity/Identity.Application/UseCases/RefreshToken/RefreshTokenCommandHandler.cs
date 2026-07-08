using Identity.Application.Repositories;
using Identity.Application.Services;
using MediatR;
using DomainRefreshToken = Identity.Domain.Entities.RefreshToken;
using Shared.Domain.Errors;

namespace Identity.Application.UseCases.RefreshToken;

internal sealed class RefreshTokenCommandHandler(
    IRefreshTokenRepository refreshTokenRepository,
    IUserRepository userRepository,
    IUnitOfWork unitOfWork,
    IJwtProvider jwtProvider)
    : IRequestHandler<RefreshTokenCommand, RefreshTokenResult>
{
    public async Task<RefreshTokenResult> Handle(RefreshTokenCommand request, CancellationToken cancellationToken)
    {
        var existing = await refreshTokenRepository.GetByTokenAsync(request.Token, cancellationToken);
        if (existing is null || !existing.IsValid())
            throw new ValidationException(new ValidationError("Refresh token is invalid or expired."));

        var user = await userRepository.GetByIdAsync(existing.UserId, cancellationToken);
        if (user is null || !user.IsActive)
            throw new ValidationException(new ValidationError("User not found or deactivated."));

        existing.Revoke();

        var newAccessToken = jwtProvider.GenerateAccessToken(user);
        var newRawRefreshToken = jwtProvider.GenerateRefreshToken();
        var newRefreshToken = DomainRefreshToken.Create(user.Id, newRawRefreshToken);

        await refreshTokenRepository.AddAsync(newRefreshToken, cancellationToken);
        await unitOfWork.SaveChangesAsync(cancellationToken);

        return new RefreshTokenResult(newAccessToken, newRawRefreshToken);
    }
}
