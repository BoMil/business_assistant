using Identity.Application.UseCases.SetTenantFirebaseConfig;
using Identity.Presentation.Endpoints.Common;
using Identity.Presentation.Filters;
using MediatR;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Routing;
using Shared.Presentation.ErrorHandling;

namespace Identity.Presentation.Endpoints.Tenants;

/// <summary>
/// PUT /tenants/{slug}/firebase-config
/// Sets a tenant's Firebase project config (client fields + Admin SDK service-account
/// credential, encrypted before storage). Called once, by hand, by whoever manually
/// created the tenant's Firebase project in the Firebase console — that provisioning
/// step is inherently manual/external. Same trust tier as GetTenantConfig: API-key
/// guarded, not JWT, since there's no admin-auth system in this repo yet.
/// </summary>
public static class SetTenantFirebaseConfig
{
    public sealed class Endpoint : IEndpoint
    {
        public void MapEndpoint(IEndpointRouteBuilder app)
        {
            app.MapPut($"{EndpointGroups.Tenants}/{{slug}}/firebase-config", Handle)
                .WithTags(EndpointTags.Tenants)
                .AddEndpointFilter<ApiKeyEndpointFilter>()
                .AllowAnonymous();
        }
    }

    public static async Task<Results<NoContent, ProblemHttpResult>> Handle(
        string slug,
        SetTenantFirebaseConfigRequest request,
        // Unused here on purpose — ApiKeyEndpointFilter reads the header itself from
        // HttpContext. This parameter exists only so Swashbuckle documents it as an
        // input field in Swagger UI (it has no other way to know the filter needs it).
        [FromHeader(Name = "X-Api-Key")] string apiKey,
        ISender sender,
        CancellationToken cancellationToken)
    {
        var command = new SetTenantFirebaseConfigCommand(
            slug,
            request.AndroidApiKey,
            request.AndroidAppId,
            request.ProjectId,
            request.MessagingSenderId,
            request.StorageBucket,
            request.ServiceAccountJson);

        var result = await sender.Send(command, cancellationToken);

        if (result.IsSuccess)
            return TypedResults.NoContent();

        return CommonHttpErrorHandlers.HandleError(result.Errors[0]);
    }
}
