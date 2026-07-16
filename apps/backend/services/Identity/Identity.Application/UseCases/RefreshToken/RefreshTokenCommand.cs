using FluentResults;
using FluentValidation;
using Shared.Application.RequestTypes;

namespace Identity.Application.UseCases.RefreshToken;

public record RefreshTokenCommand(string Token) : ICommand<Result<RefreshTokenResult>>;

public record RefreshTokenResult(string AccessToken, string RefreshToken);

public sealed class RefreshTokenCommandValidator : AbstractValidator<RefreshTokenCommand>
{
    public RefreshTokenCommandValidator()
    {
        RuleFor(x => x.Token).NotEmpty().WithMessage("Token is required");
    }
}
