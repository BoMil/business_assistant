using Identity.Application.UseCases.Common;
using Identity.Application.UseCases.GetTenantConfig;
using Identity.Presentation.Endpoints.Common;
using Identity.Presentation.Filters;
using MediatR;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Routing;
using Shared.Presentation.ErrorHandling;

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

    public static async Task<Results<Ok<TenantConfigDto>, ProblemHttpResult>> Handle(
        string slug,
        // Unused here on purpose — ApiKeyEndpointFilter reads the header itself from
        // HttpContext. This parameter exists only so Swashbuckle documents it as an
        // input field in Swagger UI (it has no other way to know the filter needs it).
        [FromHeader(Name = "X-Api-Key")] string apiKey,
        ISender sender,
        CancellationToken cancellationToken)
    {
        var result = await sender.Send(new GetTenantConfigQuery(slug), cancellationToken);

        if (result.IsSuccess)
            return TypedResults.Ok(result.Value);

        return CommonHttpErrorHandlers.HandleError(result.Errors[0]);
    }
}
