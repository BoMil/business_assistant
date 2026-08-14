namespace Business.Application.Services;

public interface IBlobStorageService
{
    Task<string> UploadAsync(Guid tenantId, Stream content, string fileName, string contentType, CancellationToken cancellationToken = default);
}
