using FluentResults;
using MediatR;
using Shared.Application.Services;

namespace Identity.Application.UseCases.UploadImage;

internal sealed class UploadImageCommandHandler(IBlobStorageService blobStorageService)
    : IRequestHandler<UploadImageCommand, Result<string>>
{
    public async Task<Result<string>> Handle(UploadImageCommand request, CancellationToken cancellationToken)
    {
        var url = await blobStorageService.UploadAsync(
            request.TenantId, request.Content, request.FileName, request.ContentType, cancellationToken);

        return Result.Ok(url);
    }
}
