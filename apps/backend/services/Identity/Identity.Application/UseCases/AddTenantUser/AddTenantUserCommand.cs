using FluentResults;
using FluentValidation;
using Identity.Domain.Enums;
using Shared.Application.RequestTypes;

namespace Identity.Application.UseCases.AddTenantUser;

public record AddTenantUserCommand(
    Guid TenantId,
    string FirstName,
    string LastName,
    string Email,
    string PhoneNumber,
    string Password,
    UserRole Role
) : ICommand<Result<Guid>>
{
    // LoggingBehavior logs every request via {@Data}, which embeds this record's ToString() —
    // override it so Password never reaches the logs.
    public override string ToString() =>
        $"{nameof(AddTenantUserCommand)} {{ TenantId = {TenantId}, FirstName = {FirstName}, LastName = {LastName}, Email = {Email}, PhoneNumber = {PhoneNumber}, Password = [REDACTED], Role = {Role} }}";
}

public sealed class AddTenantUserCommandValidator : AbstractValidator<AddTenantUserCommand>
{
    public AddTenantUserCommandValidator()
    {
        RuleFor(x => x.FirstName).NotEmpty().WithMessage("FirstName is required");
        RuleFor(x => x.LastName).NotEmpty().WithMessage("LastName is required");
        RuleFor(x => x.Email).NotEmpty().EmailAddress().WithMessage("A valid Email is required");
        RuleFor(x => x.PhoneNumber).NotEmpty().WithMessage("PhoneNumber is required");
        RuleFor(x => x.Password).NotEmpty().MinimumLength(8).WithMessage("Password must be at least 8 characters");
    }
}
