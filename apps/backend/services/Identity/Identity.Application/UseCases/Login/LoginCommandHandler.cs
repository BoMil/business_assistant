using FluentResults;
using Identity.Application.Repositories;
using Identity.Application.Services;
using Identity.Application.UseCases.Common;
using MediatR;
using DomainRefreshToken = Identity.Domain.Entities.RefreshToken;

namespace Identity.Application.UseCases.Login;

internal sealed class LoginCommandHandler(
    IUnitOfWorkIdentity unitOfWork,
    IPasswordHasher passwordHasher,
    IJwtProvider jwtProvider)
    : IRequestHandler<LoginCommand, Result<LoginResult>>
{
    public async Task<Result<LoginResult>> Handle(LoginCommand request, CancellationToken cancellationToken)
    {
        var user = await unitOfWork.Users.GetByEmailAsync(request.Email, cancellationToken);
        if (user is null || !passwordHasher.Verify(request.Password, user.PasswordHash))
            return Result.Fail("Invalid email or password.");

        if (!user.IsActive)
            return Result.Fail("Account is deactivated.");

        var accessToken = jwtProvider.GenerateAccessToken(user);
        var rawRefreshToken = jwtProvider.GenerateRefreshToken();

        var refreshToken = DomainRefreshToken.Create(user.Id, rawRefreshToken);
        await unitOfWork.RefreshTokens.AddAsync(refreshToken, cancellationToken);
        // → EF Core gleda šta je promenio, pravi INSERT/UPDATE SQL naredbe, izvršava ih
        await unitOfWork.SaveChangesAsync(cancellationToken);

        var config = new TenantConfigDto(
            user.Tenant.Id,
            user.Tenant.Name,
            user.Tenant.LogoUrl,
            user.Tenant.PrimaryColor,
            user.Tenant.AccentColor,
            user.Tenant.ErrorColor,
            user.Tenant.Type,
            user.Tenant.Currency,
            user.Tenant.Modules.Events,
            user.Tenant.Modules.Inventory,
            user.Tenant.Modules.Clients,
            user.Tenant.FeatureFlags.ThemeChange,
            user.Tenant.FeatureFlags.Language);

        return Result.Ok(new LoginResult(accessToken, rawRefreshToken, config));
    }
}
