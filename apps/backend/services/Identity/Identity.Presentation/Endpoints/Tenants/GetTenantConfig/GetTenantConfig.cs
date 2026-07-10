using Identity.Application.UseCases.Common;
using Identity.Application.UseCases.GetTenantConfig;
using Identity.Presentation.Endpoints.Common;
using Identity.Presentation.Filters;
using MediatR;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Routing;

namespace Identity.Presentation.Endpoints.Tenants.GetTenantConfig;

/// <summary>
/// GET /tenants/{slug}/config
/// Returns a tenant's branding (colors, logo) and feature flags.
///
/// Used by the mobile CI/CD pipeline to fetch fresh tenant config from the
/// database at build time, instead of relying only on locally checked-in
/// .env files. Protected by an API key (not JWT) since the caller is a CI
/// job, not an authenticated end user.
/// </summary>
public static class GetTenantConfig
{
    public sealed class Endpoint : IEndpoint
    {
        public void MapEndpoint(IEndpointRouteBuilder app)
        {
            app.MapGet($"{EndpointGroups.Tenants}/{{slug}}/config", Handle)
                .WithTags(EndpointTags.Tenants)
                .AddEndpointFilter<ApiKeyEndpointFilter>()
                .AllowAnonymous();
        }
    }

    public static async Task<Ok<TenantConfigDto>> Handle(
        string slug,
        ISender sender,
        CancellationToken cancellationToken)
    {
        var result = await sender.Send(new GetTenantConfigQuery(slug), cancellationToken);
        return TypedResults.Ok(result);
    }
}
