using Identity.Application.Repositories;
using Identity.Persistence.Repositories;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

namespace Identity.Persistence;

public static class DependencyInjection
{
    /// <summary>
    /// Registers EF Core DbContext, all repository implementations, and UnitOfWork.
    /// Connection string is read from "ConnectionStrings:IdentityDb" in appsettings.json.
    /// </summary>
    public static IServiceCollection SetupPersistenceLayer(this IServiceCollection services, IConfiguration configuration)
    {
        services.AddDbContext<IdentityDbContext>(options =>
            options.UseSqlServer(configuration.GetConnectionString("IdentityDb")));

        services.AddScoped<IUserRepository, UserRepository>();
        services.AddScoped<ITenantRepository, TenantRepository>();
        services.AddScoped<IRefreshTokenRepository, RefreshTokenRepository>();
        services.AddScoped<IUnitOfWork, UnitOfWork>();

        return services;
    }
}
