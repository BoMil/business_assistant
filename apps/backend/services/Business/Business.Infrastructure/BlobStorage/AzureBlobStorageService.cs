using Azure.Storage.Blobs;
using Azure.Storage.Blobs.Models;
using Business.Application.Services;

namespace Business.Infrastructure.BlobStorage;

/// Containers are scoped per-tenant ("tenant-{tenantId}") so each client's images are
/// isolated from every other client's, rather than sharing one container.
internal sealed class AzureBlobStorageService(BlobServiceClient blobServiceClient) : IBlobStorageService
{
    public async Task<string> UploadAsync(Guid tenantId, Stream content, string fileName, string contentType, CancellationToken cancellationToken = default)
    {
        var containerClient = blobServiceClient.GetBlobContainerClient($"tenant-{tenantId}");
        await containerClient.CreateIfNotExistsAsync(PublicAccessType.Blob, cancellationToken: cancellationToken);

        var blobClient = containerClient.GetBlobClient($"{Guid.NewGuid()}{Path.GetExtension(fileName)}");
        await blobClient.UploadAsync(content, new BlobUploadOptions
        {
            HttpHeaders = new BlobHttpHeaders { ContentType = contentType }
        }, cancellationToken);

        return blobClient.Uri.ToString();
    }
}
