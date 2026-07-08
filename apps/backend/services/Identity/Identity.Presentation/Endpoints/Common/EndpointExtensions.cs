using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Routing;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.DependencyInjection.Extensions;
using System.Reflection;

namespace Identity.Presentation.Endpoints.Common;

/// <summary>
/// Extension methods for automatic endpoint discovery and registration.
/// Pattern from Zepp.WebApp — Shared.Presentation/Endpoints/Common/EndpointExtensions.cs.
/// </summary>
public static class EndpointExtensions
{
    /// <summary>
    /// Scans the given assembly and registers every class that implements IEndpoint
    /// into the DI container as a Transient service.
    /// Called in DependencyInjection.SetupPresentationLayer().
    /// </summary>
    public static IServiceCollection AddEndpoints(this IServiceCollection services, Assembly assembly)
    {
        // Find all non-abstract, non-interface types that implement IEndpoint.
        ServiceDescriptor[] descriptors = assembly
            .DefinedTypes
            .Where(type => type is { IsAbstract: false, IsInterface: false } &&
                           type.IsAssignableTo(typeof(IEndpoint)))
            .Select(type => ServiceDescriptor.Transient(typeof(IEndpoint), type))
            .ToArray();

        // TryAddEnumerable avoids duplicate registrations if this method is called more than once.
        services.TryAddEnumerable(descriptors);
        return services;
    }

    /// <summary>
    /// Resolves all registered IEndpoint implementations from DI and calls MapEndpoint() on each.
    /// Called in DependencyInjection.SetupEndpoints() after app.Build().
    /// </summary>
    public static IApplicationBuilder MapEndpoints(this WebApplication app, RouteGroupBuilder? routeGroupBuilder = null)
    {
        IEnumerable<IEndpoint> endpoints = app.Services.GetRequiredService<IEnumerable<IEndpoint>>();
        IEndpointRouteBuilder builder = routeGroupBuilder is null ? app : routeGroupBuilder;

        foreach (var endpoint in endpoints)
        {
            endpoint.MapEndpoint(builder);
        }

        return app;
    }
}
