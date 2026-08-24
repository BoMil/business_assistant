using System.Security.Claims;
using Business.Application.UseCases.RemoveAsset;
using Business.Presentation.Endpoints.Common;
using Shared.Presentation.ErrorHandling;
using MediatR;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Routing;

namespace Business.Presentation.Endpoints.Assets;

public static class RemoveAsset
{
    public sealed class Endpoint : IEndpoint
    {
        public void MapEndpoint(IEndpointRouteBuilder app)
        {
            app.MapDelete($"{EndpointGroups.Assets}/{{id:guid}}", Handle)
                .WithTags(EndpointTags.Assets)
                .RequireAuthorization();
        }
    }

    public static async Task<Results<NoContent, ProblemHttpResult>> Handle(
        Guid id,
        ClaimsPrincipal user,
        ISender sender,
        CancellationToken cancellationToken)
    {
        var result = await sender.Send(new RemoveAssetCommand(id, user.GetTenantId(), user.GetUserId()), cancellationToken);

        if (result.IsSuccess)
            return TypedResults.NoContent();

        return CommonHttpErrorHandlers.HandleError(result.Errors[0]);
    }
}
