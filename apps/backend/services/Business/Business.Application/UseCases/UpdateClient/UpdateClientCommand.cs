using FluentResults;
using FluentValidation;
using Shared.Application.RequestTypes;

namespace Business.Application.UseCases.UpdateClient;

public record UpdateClientCommand(
    Guid Id,
    Guid TenantId,
    string Name,
    string PhoneNumber,
    string Email,
    string? LocationAddress,
    double? LocationLatitude,
    double? LocationLongitude,
    string? Description
) : ICommand<Result>;

public sealed class UpdateClientCommandValidator : AbstractValidator<UpdateClientCommand>
{
    public UpdateClientCommandValidator()
    {
        RuleFor(x => x.Name).NotEmpty().WithMessage("Name is required");
        RuleFor(x => x.PhoneNumber).NotEmpty().WithMessage("PhoneNumber is required");
        RuleFor(x => x.Email).NotEmpty().EmailAddress().WithMessage("A valid Email is required");
    }
}
