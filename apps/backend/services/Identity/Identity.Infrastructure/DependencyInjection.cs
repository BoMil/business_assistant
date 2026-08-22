using System.Text;
using Identity.Application.Services;
using Identity.Infrastructure.PushNotifications;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.IdentityModel.Tokens;
using Shared.Infrastructure.BlobStorage;

namespace Identity.Infrastructure;

public static class DependencyInjection
{
    /// <summary>
    /// Registers infrastructure services and configures JWT Bearer authentication.
    /// Called from Identity.API's Program.cs alongside the other layer setup methods.
    /// </summary>
    public static IServiceCollection SetupInfrastructureLayer(this IServiceCollection services, IConfiguration configuration)
    {
        // Register concrete implementations for the interfaces defined in Identity.Application.
        // Scoped = one instance per HTTP request.
        services.AddScoped<IPasswordHasher, PasswordHasher>();
        services.AddScoped<IJwtProvider, JwtProvider>();

        // Configure ASP.NET Core to validate incoming JWT tokens on protected endpoints.
        // This middleware runs before the controller/endpoint and rejects requests with invalid tokens.
        services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
            .AddJwtBearer(options =>
            {
                options.TokenValidationParameters = new TokenValidationParameters
                {
                    ValidateIssuer = true,
                    ValidateAudience = true,
                    ValidateLifetime = true,          // rejects expired tokens
                    ValidateIssuerSigningKey = true,  // verifies the signature with our secret
                    ValidIssuer = configuration["Jwt:Issuer"],
                    ValidAudience = configuration["Jwt:Audience"],
                    IssuerSigningKey = new SymmetricSecurityKey(
                        Encoding.UTF8.GetBytes(configuration["Jwt:Secret"]!))
                };
            });

        // Required for UseAuthorization() middleware in Program.cs.
        // Without this, the app throws InvalidOperationException on startup.
        services.AddAuthorization();

        services.SetupBlobStorage(configuration);

        services.AddDataProtection();
        services.AddSingleton<FirebaseAppCache>();
        services.AddScoped<IFirebaseCredentialProtector, FirebaseCredentialProtector>();
        services.AddScoped<IPushNotificationService, FirebasePushNotificationService>();

        return services;
    }
}
