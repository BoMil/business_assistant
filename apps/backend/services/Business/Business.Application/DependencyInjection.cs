using FluentValidation;
using Microsoft.Extensions.DependencyInjection;
using Shared.Application.Behaviors.Logging;
using Shared.Application.Behaviors.Validation;

namespace Business.Application;

public static class DependencyInjection
{
    public static IServiceCollection SetupApplicationLayer(this IServiceCollection services)
    {
        services.AddMediatR(cfg =>
        {
            cfg.Lifetime = ServiceLifetime.Scoped;
            cfg.RegisterServicesFromAssembly(typeof(DependencyInjection).Assembly)
                .AddOpenBehavior(typeof(LoggingBehavior<,>), ServiceLifetime.Scoped)
                .AddOpenBehavior(typeof(ValidationBehavior<,>), ServiceLifetime.Scoped);
        });

        services.AddValidatorsFromAssembly(typeof(DependencyInjection).Assembly, ServiceLifetime.Singleton);

        return services;
    }
}
