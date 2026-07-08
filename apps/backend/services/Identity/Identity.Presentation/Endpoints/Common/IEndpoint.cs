using Microsoft.AspNetCore.Routing;

namespace Identity.Presentation.Endpoints.Common;

/// <summary>
/// Marker interface for Minimal API endpoints.
/// Every class that implements this interface is automatically discovered
/// and registered via reflection in DependencyInjection.SetupPresentationLayer().
///
/// Pattern from Zepp.WebApp — Shared.Presentation/Endpoints/Common/IEndpoint.cs.
/// When a second microservice is added, this interface should be moved to Shared.Presentation.
/// </summary>
public interface IEndpoint
{
    void MapEndpoint(IEndpointRouteBuilder app);
}
