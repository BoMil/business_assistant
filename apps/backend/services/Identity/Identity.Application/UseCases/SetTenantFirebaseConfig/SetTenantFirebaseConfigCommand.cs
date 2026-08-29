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
    string ServiceAccountJson) : ICommand<Result>
{
    // LoggingBehavior logs every request via {@Data}, which embeds this record's ToString() —
    // override it so the service-account private key never reaches the logs.
    public override string ToString() =>
        $"{nameof(SetTenantFirebaseConfigCommand)} {{ Slug = {Slug}, AndroidApiKey = {AndroidApiKey}, AndroidAppId = {AndroidAppId}, ProjectId = {ProjectId}, MessagingSenderId = {MessagingSenderId}, StorageBucket = {StorageBucket}, ServiceAccountJson = [REDACTED] }}";
}

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
