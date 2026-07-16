using System.Security.Claims;
using Business.Application.UseCases.Common;
using Business.Application.UseCases.GetClientById;
using Business.Presentation.Endpoints.Common;
using Shared.Presentation.ErrorHandling;
using MediatR;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Routing;

namespace Business.Presentation.Endpoints.Clients;

public static class GetClientById
{
    public sealed class Endpoint : IEndpoint
    {
        public void MapEndpoint(IEndpointRouteBuilder app)
        {
            app.MapGet($"{EndpointGroups.Clients}/{{id:guid}}", Handle)
                .WithTags(EndpointTags.Clients)
                .RequireAuthorization();
        }
    }

    public static async Task<Results<Ok<ClientDto>, ProblemHttpResult>> Handle(
        Guid id,
        ClaimsPrincipal user,
        ISender sender,
        CancellationToken cancellationToken)
    {
        var result = await sender.Send(new GetClientByIdQuery(id, user.GetTenantId()), cancellationToken);

        if (result.IsSuccess)
            return TypedResults.Ok(result.Value);

        return CommonHttpErrorHandlers.HandleError(result.Errors[0]);
    }
}
