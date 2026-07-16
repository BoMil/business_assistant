using FluentResults;
using FluentValidation;
using Identity.Application.UseCases.Common;
using Shared.Application.RequestTypes;

namespace Identity.Application.UseCases.Login;

public record LoginCommand(string Email, string Password) : ICommand<Result<LoginResult>>;

public record LoginResult(
    string AccessToken,
    string RefreshToken,
    TenantConfigDto TenantConfig);

public sealed class LoginCommandValidator : AbstractValidator<LoginCommand>
{
    public LoginCommandValidator()
    {
        RuleFor(x => x.Email).NotEmpty().EmailAddress().WithMessage("A valid Email is required");
        RuleFor(x => x.Password).NotEmpty().WithMessage("Password is required");
    }
}
