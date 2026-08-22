using FluentResults;
using FluentValidation;
using Shared.Application.RequestTypes;

namespace Identity.Application.UseCases.RegisterDeviceToken;

public record RegisterDeviceTokenCommand(Guid UserId, string Token) : ICommand<Result>;

public sealed class RegisterDeviceTokenCommandValidator : AbstractValidator<RegisterDeviceTokenCommand>
{
    public RegisterDeviceTokenCommandValidator()
    {
        RuleFor(x => x.Token).NotEmpty().WithMessage("Token is required");
    }
}
