using System.Text;
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

        return services;
    }
}
