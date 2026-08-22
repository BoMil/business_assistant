using FluentResults;
using FluentValidation;
using Shared.Application.RequestTypes;

namespace Identity.Application.UseCases.SetTenantFirebaseConfig;

public record SetTenantFirebaseConfigCommand(
    string Slug,
    string AndroidApiKey,
    string AndroidAppId,
    string ProjectId,
    string MessagingSenderId,
    string StorageBucket,
    string ServiceAccountJson) : ICommand<Result>;

public sealed class SetTenantFirebaseConfigCommandValidator : AbstractValidator<SetTenantFirebaseConfigCommand>
{
    public SetTenantFirebaseConfigCommandValidator()
    {
        RuleFor(x => x.AndroidApiKey).NotEmpty().WithMessage("AndroidApiKey is required");
        RuleFor(x => x.AndroidAppId).NotEmpty().WithMessage("AndroidAppId is required");
        RuleFor(x => x.ProjectId).NotEmpty().WithMessage("ProjectId is required");
        RuleFor(x => x.MessagingSenderId).NotEmpty().WithMessage("MessagingSenderId is required");
        RuleFor(x => x.StorageBucket).NotEmpty().WithMessage("StorageBucket is required");
        RuleFor(x => x.ServiceAccountJson).NotEmpty().WithMessage("ServiceAccountJson is required");
    }
}
