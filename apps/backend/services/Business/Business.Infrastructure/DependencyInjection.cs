using System.Text;
using Azure.Storage.Blobs;
using Business.Application.Services;
using Business.Infrastructure.BlobStorage;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.IdentityModel.Tokens;

namespace Business.Infrastructure;

public static class DependencyInjection
{
    /// <summary>
    /// Business is a resource server only — it validates JWTs that Identity issued, it never
    /// issues its own (no IJwtProvider/IPasswordHasher here, those are Identity's job).
    /// Jwt:Secret/Issuer/Audience must match Identity's exactly so tokens validate across services.
    /// </summary>
    public static IServiceCollection SetupInfrastructureLayer(this IServiceCollection services, IConfiguration configuration)
    {
        services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
            .AddJwtBearer(options =>
            {
                options.TokenValidationParameters = new TokenValidationParameters
                {
                    ValidateIssuer = true,
                    ValidateAudience = true,
                    ValidateLifetime = true,
                    ValidateIssuerSigningKey = true,
                    ValidIssuer = configuration["Jwt:Issuer"],
                    ValidAudience = configuration["Jwt:Audience"],
                    IssuerSigningKey = new SymmetricSecurityKey(
                        Encoding.UTF8.GetBytes(configuration["Jwt:Secret"]!))
                };
            });

        services.AddAuthorization();

        // Factory registration (not `new BlobServiceClient(...)` inline) so the connection
        // string is only parsed on first actual use — an unconfigured/invalid value shouldn't
        // crash the whole API at startup for endpoints that have nothing to do with images.
        services.AddSingleton(_ => new BlobServiceClient(configuration["BlobStorage:ConnectionString"]));
        services.AddScoped<IBlobStorageService, AzureBlobStorageService>();

        return services;
    }
}
