using System.Security.Authentication;
using System.Text;
using MassTransit;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.IdentityModel.Tokens;
using Shared.Infrastructure.BlobStorage;

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

        services.SetupBlobStorage(configuration);

        // Business only publishes (TenantNotificationRequested) — it never consumes, so no
        // AddConsumer<> calls here. Identity is the one that reacts to what's published.
        services.AddMassTransit(x =>
        {
            x.UsingRabbitMq((context, cfg) =>
            {
                var useSsl = bool.TryParse(configuration["RabbitMq:UseSsl"], out var parsedUseSsl) && parsedUseSsl;
                var port = (ushort)(useSsl ? 5671 : 5672);

                cfg.Host(configuration["RabbitMq:Host"], port, configuration["RabbitMq:VirtualHost"] ?? "/", h =>
                {
                    h.Username(configuration["RabbitMq:Username"]!);
                    h.Password(configuration["RabbitMq:Password"]!);

                    // CloudAMQP (used in Staging/Production) requires TLS on port 5671; local RabbitMQ container stays on plain 5672.
                    if (useSsl)
                    {
                        h.UseSsl(s => s.Protocol = SslProtocols.Tls12);
                    }
                });
            });
        });

        return services;
    }
}
