using Shared.Application.RequestTypes;

namespace Identity.Application.UseCases.Login;

public record LoginCommand(string Email, string Password) : ICommand<LoginResult>;

public record LoginResult(
    string AccessToken,
    string RefreshToken,
    TenantConfig TenantConfig);

public record TenantConfig(
    Guid TenantId,
    string Name,
    string? LogoUrl,
    string PrimaryColor,
    string SecondaryColor,
    bool Rental,
    bool Inventory,
    bool Reporting,
    bool Poultry);
