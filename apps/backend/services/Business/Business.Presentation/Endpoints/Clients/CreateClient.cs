using System.Security.Claims;
using Business.Application.UseCases.CreateClient;
using Business.Presentation.Endpoints.Common;
using Shared.Presentation.ErrorHandling;
using MediatR;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Routing;

namespace Business.Presentation.Endpoints.Clients;

public static class CreateClient
{
    public sealed class Endpoint : IEndpoint
    {
        public void MapEndpoint(IEndpointRouteBuilder app)
        {
            app.MapPost(EndpointGroups.Clients, Handle)
                .WithTags(EndpointTags.Clients)
                .RequireAuthorization();
        }
    }

    public static async Task<Results<Created<Guid>, ProblemHttpResult>> Handle(
        CreateClientRequest request,
        ClaimsPrincipal user,
        ISender sender,
        CancellationToken cancellationToken)
    {
        var command = new CreateClientCommand(
            user.GetTenantId(), request.Name, request.PhoneNumber, request.Email,
            request.LocationAddress, request.LocationLatitude, request.LocationLongitude, request.Description);

        var result = await sender.Send(command, cancellationToken);

        if (result.IsSuccess)
            return TypedResults.Created($"{EndpointGroups.Clients}/{result.Value}", result.Value);

        return CommonHttpErrorHandlers.HandleError(result.Errors[0]);
    }
}
