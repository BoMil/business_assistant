using System.Security.Claims;
using Business.Application.UseCases.Common;
using Business.Application.UseCases.GetAssets;
using Business.Presentation.Endpoints.Common;
using Shared.Presentation.ErrorHandling;
using MediatR;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Routing;

namespace Business.Presentation.Endpoints.Assets;

public static class GetAssets
{
    public sealed class Endpoint : IEndpoint
    {
        public void MapEndpoint(IEndpointRouteBuilder app)
        {
            app.MapGet(EndpointGroups.Assets, Handle)
                .WithTags(EndpointTags.Assets)
                .RequireAuthorization();
        }
    }

    public static async Task<Results<Ok<List<AssetDto>>, ProblemHttpResult>> Handle(
        ClaimsPrincipal user,
        ISender sender,
        CancellationToken cancellationToken)
    {
        var result = await sender.Send(new GetAssetsQuery(user.GetTenantId()), cancellationToken);

        if (result.IsSuccess)
            return TypedResults.Ok(result.Value);

        return CommonHttpErrorHandlers.HandleError(result.Errors[0]);
    }
}
