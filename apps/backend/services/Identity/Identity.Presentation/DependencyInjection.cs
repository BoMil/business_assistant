using Identity.Presentation.Endpoints.Common;
using Microsoft.AspNetCore.Builder;
using Microsoft.Extensions.DependencyInjection;

namespace Identity.Presentation;

/// <summary>
/// Wires up the Presentation layer — endpoint discovery.
/// Pattern from Zepp.WebApp: DependencyInjection has two separate methods:
///   SetupPresentationLayer() — called on builder.Services before app.Build()
///   SetupEndpoints()         — called on the built WebApplication after app.Build()
///
/// Note: Swagger setup lives in Identity.API, not here, because only the API entry point
/// knows what documentation config it needs (title, security schemes, etc.).
/// </summary>
public static class DependencyInjection
{
    /// <summary>
    /// Scans this assembly to discover all IEndpoint implementations and registers them in DI.
    /// Each IEndpoint class is registered as Transient and resolved by MapEndpoints() after app.Build().
    /// </summary>
    public static IServiceCollection SetupPresentationLayer(this IServiceCollection services)
    {
        // Scans this assembly and registers every class implementing IEndpoint.
        // No need to manually register new endpoints — just add a class that implements IEndpoint.
        services.AddEndpoints(typeof(DependencyInjection).Assembly);

        return services;
    }

    /// <summary>
    /// Maps all registered IEndpoint routes onto the running application.
    /// Called after app.Build() in Program.cs — this is when routes become active.
    /// </summary>
    public static WebApplication SetupEndpoints(this WebApplication app)
    {
        app.MapEndpoints();
        return app;
    }
}
