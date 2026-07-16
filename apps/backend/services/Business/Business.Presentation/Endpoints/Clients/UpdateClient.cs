using System.Security.Claims;
using Business.Application.UseCases.UpdateClient;
using Business.Presentation.Endpoints.Common;
using Shared.Presentation.ErrorHandling;
using MediatR;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Routing;

namespace Business.Presentation.Endpoints.Clients;

public static class UpdateClient
{
    public sealed class Endpoint : IEndpoint
    {
        public void MapEndpoint(IEndpointRouteBuilder app)
        {
            app.MapPut($"{EndpointGroups.Clients}/{{id:guid}}", Handle)
                .WithTags(EndpointTags.Clients)
                .RequireAuthorization();
        }
    }

    public static async Task<Results<NoContent, ProblemHttpResult>> Handle(
        Guid id,
        UpdateClientRequest request,
        ClaimsPrincipal user,
        ISender sender,
        CancellationToken cancellationToken)
    {
        var command = new UpdateClientCommand(
            id, user.GetTenantId(), request.Name, request.PhoneNumber, request.Email,
            request.LocationAddress, request.LocationLatitude, request.LocationLongitude, request.Description);

        var result = await sender.Send(command, cancellationToken);

        if (result.IsSuccess)
            return TypedResults.NoContent();

        return CommonHttpErrorHandlers.HandleError(result.Errors[0]);
    }
}
