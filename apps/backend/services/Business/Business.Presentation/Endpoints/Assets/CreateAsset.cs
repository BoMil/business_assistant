using System.Security.Claims;
using Business.Application.UseCases.CreateAsset;
using Business.Presentation.Endpoints.Common;
using Shared.Presentation.ErrorHandling;
using MediatR;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Routing;

namespace Business.Presentation.Endpoints.Assets;

public static class CreateAsset
{
    public sealed class Endpoint : IEndpoint
    {
        public void MapEndpoint(IEndpointRouteBuilder app)
        {
            app.MapPost(EndpointGroups.Assets, Handle)
                .WithTags(EndpointTags.Assets)
                .RequireAuthorization();
        }
    }

    public static async Task<Results<Created<Guid>, ProblemHttpResult>> Handle(
        CreateAssetRequest request,
        ClaimsPrincipal user,
        ISender sender,
        CancellationToken cancellationToken)
    {
        var command = new CreateAssetCommand(
            user.GetTenantId(), request.Name, request.Category, request.Description,
            request.SalePrice, request.RentalPrice, request.StockCount);

        var result = await sender.Send(command, cancellationToken);

        if (result.IsSuccess)
            return TypedResults.Created($"{EndpointGroups.Assets}/{result.Value}", result.Value);

        return CommonHttpErrorHandlers.HandleError(result.Errors[0]);
    }
}
