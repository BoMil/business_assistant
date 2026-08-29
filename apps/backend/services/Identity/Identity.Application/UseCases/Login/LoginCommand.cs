using FluentResults;
using FluentValidation;
using Identity.Application.UseCases.Common;
using Shared.Application.RequestTypes;

namespace Identity.Application.UseCases.Login;

public record LoginCommand(string Email, string Password) : ICommand<Result<LoginResult>>
{
    // LoggingBehavior logs every request via {@Data}, which embeds this record's ToString() —
    // override it so Password never reaches the logs.
    public override string ToString() => $"{nameof(LoginCommand)} {{ Email = {Email}, Password = [REDACTED] }}";
}

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
