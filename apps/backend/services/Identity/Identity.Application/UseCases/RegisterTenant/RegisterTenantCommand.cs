using FluentResults;
using FluentValidation;
using Identity.Domain.Enums;
using Shared.Application.RequestTypes;

namespace Identity.Application.UseCases.RegisterTenant;

public record RegisterTenantCommand(
    string TenantName,
    string Slug,
    string PrimaryColor,
    string AccentColor,
    string ErrorColor,
    TenantType Type,
    string OwnerFirstName,
    string OwnerLastName,
    string OwnerEmail,
    string OwnerPhoneNumber,
    string OwnerPassword,
    string Currency = "EUR"
) : ICommand<Result<RegisterTenantResult>>
{
    // LoggingBehavior logs every request via {@Data}, which embeds this record's ToString() —
    // override it so OwnerPassword never reaches the logs.
    public override string ToString() =>
        $"{nameof(RegisterTenantCommand)} {{ TenantName = {TenantName}, Slug = {Slug}, PrimaryColor = {PrimaryColor}, AccentColor = {AccentColor}, ErrorColor = {ErrorColor}, Type = {Type}, OwnerFirstName = {OwnerFirstName}, OwnerLastName = {OwnerLastName}, OwnerEmail = {OwnerEmail}, OwnerPhoneNumber = {OwnerPhoneNumber}, OwnerPassword = [REDACTED], Currency = {Currency} }}";
}

public record RegisterTenantResult(Guid TenantId, Guid OwnerId);

public sealed class RegisterTenantCommandValidator : AbstractValidator<RegisterTenantCommand>
{
    public RegisterTenantCommandValidator()
    {
        RuleFor(x => x.TenantName).NotEmpty().WithMessage("TenantName is required");
        RuleFor(x => x.Slug).NotEmpty().WithMessage("Slug is required");
        RuleFor(x => x.PrimaryColor).NotEmpty().WithMessage("PrimaryColor is required");
        RuleFor(x => x.AccentColor).NotEmpty().WithMessage("AccentColor is required");
        RuleFor(x => x.ErrorColor).NotEmpty().WithMessage("ErrorColor is required");
        RuleFor(x => x.Currency).NotEmpty().WithMessage("Currency is required");
        RuleFor(x => x.OwnerFirstName).NotEmpty().WithMessage("OwnerFirstName is required");
        RuleFor(x => x.OwnerLastName).NotEmpty().WithMessage("OwnerLastName is required");
        RuleFor(x => x.OwnerEmail).NotEmpty().EmailAddress().WithMessage("A valid OwnerEmail is required");
        RuleFor(x => x.OwnerPhoneNumber).NotEmpty().WithMessage("OwnerPhoneNumber is required");
        RuleFor(x => x.OwnerPassword).NotEmpty().MinimumLength(8).WithMessage("OwnerPassword must be at least 8 characters");
    }
}
