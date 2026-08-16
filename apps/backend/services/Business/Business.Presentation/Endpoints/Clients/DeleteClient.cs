using System.Security.Claims;
using Business.Application.UseCases.DeleteClient;
using Business.Presentation.Endpoints.Common;
using Shared.Presentation.ErrorHandling;
using MediatR;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Routing;

namespace Business.Presentation.Endpoints.Clients;

public static class DeleteClient
{
    public sealed class Endpoint : IEndpoint
    {
        public void MapEndpoint(IEndpointRouteBuilder app)
        {
            app.MapDelete($"{EndpointGroups.Clients}/{{id:guid}}", Handle)
                .WithTags(EndpointTags.Clients)
                .RequireAuthorization();
        }
    }

    public static async Task<Results<NoContent, ProblemHttpResult>> Handle(
        Guid id,
        ClaimsPrincipal user,
        ISender sender,
        CancellationToken cancellationToken)
    {
        var result = await sender.Send(new DeleteClientCommand(id, user.GetTenantId()), cancellationToken);

        if (result.IsSuccess)
            return TypedResults.NoContent();

        return CommonHttpErrorHandlers.HandleError(result.Errors[0]);
    }
}
