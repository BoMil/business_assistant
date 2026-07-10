using Identity.Application.UseCases.Common;
using Shared.Application.RequestTypes;

namespace Identity.Application.UseCases.Login;

public record LoginCommand(string Email, string Password) : ICommand<LoginResult>;

public record LoginResult(
    string AccessToken,
    string RefreshToken,
    TenantConfigDto TenantConfig);
