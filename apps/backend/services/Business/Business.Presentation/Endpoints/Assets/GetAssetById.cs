using System.Security.Claims;
using Business.Application.UseCases.Common;
using Business.Application.UseCases.GetAssetById;
using Business.Presentation.Endpoints.Common;
using Shared.Presentation.ErrorHandling;
using MediatR;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Routing;

namespace Business.Presentation.Endpoints.Assets;

public static class GetAssetById
{
    public sealed class Endpoint : IEndpoint
    {
        public void MapEndpoint(IEndpointRouteBuilder app)
        {
            app.MapGet($"{EndpointGroups.Assets}/{{id:guid}}", Handle)
                .WithTags(EndpointTags.Assets)
                .RequireAuthorization();
        }
    }

    public static async Task<Results<Ok<AssetDetailDto>, ProblemHttpResult>> Handle(
        Guid id,
        ClaimsPrincipal user,
        ISender sender,
        CancellationToken cancellationToken)
    {
        var result = await sender.Send(new GetAssetByIdQuery(id, user.GetTenantId()), cancellationToken);

        if (result.IsSuccess)
            return TypedResults.Ok(result.Value);

        return CommonHttpErrorHandlers.HandleError(result.Errors[0]);
    }
}
