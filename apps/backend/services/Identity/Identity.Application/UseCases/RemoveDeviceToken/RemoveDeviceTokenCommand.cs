using FluentResults;
using FluentValidation;
using Shared.Application.RequestTypes;

namespace Identity.Application.UseCases.RemoveDeviceToken;

public record RemoveDeviceTokenCommand(Guid UserId, string Token) : ICommand<Result>;

public sealed class RemoveDeviceTokenCommandValidator : AbstractValidator<RemoveDeviceTokenCommand>
{
    public RemoveDeviceTokenCommandValidator()
    {
        RuleFor(x => x.Token).NotEmpty().WithMessage("Token is required");
    }
}
