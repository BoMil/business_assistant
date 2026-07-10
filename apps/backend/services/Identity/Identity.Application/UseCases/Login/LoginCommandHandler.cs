using Identity.Application.Repositories;
using Identity.Application.Services;
using Identity.Application.UseCases.Common;
using Identity.Domain.Entities;
using MediatR;
using DomainRefreshToken = Identity.Domain.Entities.RefreshToken;
using Shared.Domain.Errors;

namespace Identity.Application.UseCases.Login;

internal sealed class LoginCommandHandler(
    IUserRepository userRepository,
    IRefreshTokenRepository refreshTokenRepository,
    IUnitOfWork unitOfWork,
    IPasswordHasher passwordHasher,
    IJwtProvider jwtProvider)
    : IRequestHandler<LoginCommand, LoginResult>
{
    public async Task<LoginResult> Handle(LoginCommand request, CancellationToken cancellationToken)
    {
        var user = await userRepository.GetByEmailAsync(request.Email, cancellationToken);
        if (user is null || !passwordHasher.Verify(request.Password, user.PasswordHash))
            throw new ValidationException(new ValidationError("Invalid email or password."));

        if (!user.IsActive)
            throw new ValidationException(new ValidationError("Account is deactivated."));

        var accessToken = jwtProvider.GenerateAccessToken(user);
        var rawRefreshToken = jwtProvider.GenerateRefreshToken();

        var refreshToken = DomainRefreshToken.Create(user.Id, rawRefreshToken);
        await refreshTokenRepository.AddAsync(refreshToken, cancellationToken);
        // → EF Core gleda šta je promenio, pravi INSERT/UPDATE SQL naredbe, izvršava ih
        await unitOfWork.SaveChangesAsync(cancellationToken);

        var config = new TenantConfigDto(
            user.Tenant.Id,
            user.Tenant.Name,
            user.Tenant.LogoUrl,
            user.Tenant.PrimaryColor,
            user.Tenant.AccentColor,
            user.Tenant.ErrorColor,
            user.Tenant.FeatureFlags.Rental,
            user.Tenant.FeatureFlags.Inventory,
            user.Tenant.FeatureFlags.Reporting,
            user.Tenant.FeatureFlags.Poultry,
            user.Tenant.FeatureFlags.ThemeChange,
            user.Tenant.FeatureFlags.Language);

        return new LoginResult(accessToken, rawRefreshToken, config);
    }
}
