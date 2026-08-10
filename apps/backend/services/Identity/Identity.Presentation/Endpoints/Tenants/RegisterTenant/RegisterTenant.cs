using Identity.Application.UseCases.RegisterTenant;
using Identity.Presentation.Endpoints.Common;
using MediatR;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Routing;
using Shared.Presentation.ErrorHandling;

namespace Identity.Presentation.Endpoints.Tenants.RegisterTenant;

/// <summary>
/// POST /tenants/register
/// Creates a new tenant and its Owner user in a single database transaction.
/// Returns 201 Created with the new TenantId and OwnerId.
///
/// Note: in production this should be protected by an admin-only authorization policy.
/// For now it is open for development and testing purposes.
/// </summary>
public static class RegisterTenant
{
    public sealed class Endpoint : IEndpoint
    {
        public void MapEndpoint(IEndpointRouteBuilder app)
        {
            app.MapPost($"{EndpointGroups.Tenants}/register", Handle)
                .WithTags(EndpointTags.Tenants)
                .AllowAnonymous();
        }
    }

    public static async Task<Results<Created<RegisterTenantResult>, ProblemHttpResult>> Handle(
        RegisterTenantRequest request,
        ISender sender,
        CancellationToken cancellationToken)
    {
        var command = new RegisterTenantCommand(
            request.TenantName,
            request.Slug,
            request.PrimaryColor,
            request.AccentColor,
            request.ErrorColor,
            request.Type,
            request.OwnerFirstName,
            request.OwnerLastName,
            request.OwnerEmail,
            request.OwnerPhoneNumber,
            request.OwnerPassword,
            request.Currency);

        var result = await sender.Send(command, cancellationToken);

        if (result.IsSuccess)
            // 201 Created — a new resource was created.
            // The null here is the Location header (URL to the new resource).
            // We'll fill this in once we have a GET /tenants/{id} endpoint.
            return TypedResults.Created((string?)null, result.Value);

        return CommonHttpErrorHandlers.HandleError(result.Errors[0]);
    }
}
