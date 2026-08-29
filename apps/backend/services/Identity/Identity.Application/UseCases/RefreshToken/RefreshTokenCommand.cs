using FluentResults;
using FluentValidation;
using Shared.Application.RequestTypes;

namespace Identity.Application.UseCases.RefreshToken;

public record RefreshTokenCommand(string Token) : ICommand<Result<RefreshTokenResult>>
{
    // LoggingBehavior logs every request via {@Data}, which embeds this record's ToString() —
    // override it so the refresh token never reaches the logs.
    public override string ToString() => $"{nameof(RefreshTokenCommand)} {{ Token = [REDACTED] }}";
}

public record RefreshTokenResult(string AccessToken, string RefreshToken);

public sealed class RefreshTokenCommandValidator : AbstractValidator<RefreshTokenCommand>
{
    public RefreshTokenCommandValidator()
    {
        RuleFor(x => x.Token).NotEmpty().WithMessage("Token is required");
    }
}
