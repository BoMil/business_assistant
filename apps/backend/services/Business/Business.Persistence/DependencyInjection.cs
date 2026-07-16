using Business.Application.Repositories;
using Business.Persistence.Repositories;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

namespace Business.Persistence;

public static class DependencyInjection
{
    public static IServiceCollection SetupPersistenceLayer(this IServiceCollection services, IConfiguration configuration)
    {
        services.AddDbContext<BusinessDbContext>(options =>
            options.UseSqlServer(configuration.GetConnectionString("BusinessDb")));

        // Repositories are no longer registered individually — IUnitOfWorkBusiness
        // instantiates them itself (lazily, per-property) the way Zepp's fat UoW does.
        services.AddScoped<IUnitOfWorkBusiness, UnitOfWorkBusiness>();

        return services;
    }
}
