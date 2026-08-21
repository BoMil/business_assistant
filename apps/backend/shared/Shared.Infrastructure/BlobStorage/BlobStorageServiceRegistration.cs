using Azure.Storage.Blobs;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Shared.Application.Services;

namespace Shared.Infrastructure.BlobStorage;

public static class BlobStorageServiceRegistration
{
    /// <summary>
    /// Registers blob storage for any microservice that needs it. Called from each
    /// service's own SetupInfrastructureLayer, alongside its other infrastructure setup.
    /// </summary>
    public static IServiceCollection SetupBlobStorage(this IServiceCollection services, IConfiguration configuration)
    {
        // Factory registration (not `new BlobServiceClient(...)` inline) so the connection
        // string is only parsed on first actual use — an unconfigured/invalid value shouldn't
        // crash the whole API at startup for endpoints that have nothing to do with images.
        services.AddSingleton(_ => new BlobServiceClient(configuration["BlobStorage:ConnectionString"]));
        services.AddScoped<IBlobStorageService, AzureBlobStorageService>();

        return services;
    }
}
