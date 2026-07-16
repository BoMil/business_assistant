using System.Security.Claims;
using Business.Application.UseCases.UpdateAsset;
using Business.Presentation.Endpoints.Common;
using Shared.Presentation.ErrorHandling;
using MediatR;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Routing;

namespace Business.Presentation.Endpoints.Assets;

public static class UpdateAsset
{
    public sealed class Endpoint : IEndpoint
    {
        public void MapEndpoint(IEndpointRouteBuilder app)
        {
            app.MapPut($"{EndpointGroups.Assets}/{{id:guid}}", Handle)
                .WithTags(EndpointTags.Assets)
                .RequireAuthorization();
        }
    }

    public static async Task<Results<NoContent, ProblemHttpResult>> Handle(
        Guid id,
        UpdateAssetRequest request,
        ClaimsPrincipal user,
        ISender sender,
        CancellationToken cancellationToken)
    {
        var command = new UpdateAssetCommand(
            id, user.GetTenantId(), request.Name, request.Category, request.Description,
            request.SalePrice, request.RentalPrice, request.StockCount);

        var result = await sender.Send(command, cancellationToken);

        if (result.IsSuccess)
            return TypedResults.NoContent();

        return CommonHttpErrorHandlers.HandleError(result.Errors[0]);
    }
}
