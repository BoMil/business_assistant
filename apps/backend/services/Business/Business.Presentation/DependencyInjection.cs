using Business.Presentation.Endpoints.Common;
using Microsoft.AspNetCore.Builder;
using Microsoft.Extensions.DependencyInjection;

namespace Business.Presentation;

public static class DependencyInjection
{
    public static IServiceCollection SetupPresentationLayer(this IServiceCollection services)
    {
        services.AddEndpoints(typeof(DependencyInjection).Assembly);
        return services;
    }

    public static WebApplication SetupEndpoints(this WebApplication app)
    {
        app.MapEndpoints();
        return app;
    }
}
