using FluentResults;
using FluentValidation;
using Shared.Application.RequestTypes;

namespace Business.Application.UseCases.CreateClient;

public record CreateClientCommand(
    Guid TenantId,
    Guid UserId,
    string Name,
    string PhoneNumber,
    string Email,
    string? LocationAddress,
    double? LocationLatitude,
    double? LocationLongitude,
    string? Description
) : ICommand<Result<Guid>>;

public sealed class CreateClientCommandValidator : AbstractValidator<CreateClientCommand>
{
    public CreateClientCommandValidator()
    {
        RuleFor(x => x.Name).NotEmpty().WithMessage("Name is required");
        RuleFor(x => x.PhoneNumber).NotEmpty().WithMessage("PhoneNumber is required");
        RuleFor(x => x.Email).NotEmpty().EmailAddress().WithMessage("A valid Email is required");
    }
}
