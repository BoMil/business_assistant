using Business.Application.Services;
using FluentResults;
using MediatR;

namespace Business.Application.UseCases.UploadImage;

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
