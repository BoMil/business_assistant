using FluentResults;
using FluentValidation;
using Shared.Application.RequestTypes;

namespace Business.Application.UseCases.UploadImage;

public sealed record UploadImageCommand(Guid TenantId, Stream Content, string FileName, string ContentType, long Length) : ICommand<Result<string>>;

public sealed class UploadImageCommandValidator : AbstractValidator<UploadImageCommand>
{
    private static readonly string[] AllowedContentTypes = ["image/jpeg", "image/png", "image/webp"];
    private const long MaxSizeBytes = 5 * 1024 * 1024;

    public UploadImageCommandValidator()
    {
        RuleFor(x => x.ContentType).Must(AllowedContentTypes.Contains).WithMessage("Only JPEG, PNG or WEBP images are allowed.");
        RuleFor(x => x.Length).LessThanOrEqualTo(MaxSizeBytes).WithMessage("Image must be 5MB or smaller.");
    }
}
