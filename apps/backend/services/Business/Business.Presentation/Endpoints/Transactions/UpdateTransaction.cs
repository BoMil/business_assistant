using System.Security.Claims;
using Business.Application.UseCases.Common;
using Business.Application.UseCases.UpdateTransaction;
using Business.Presentation.Endpoints.Common;
using Shared.Presentation.ErrorHandling;
using MediatR;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Routing;

namespace Business.Presentation.Endpoints.Transactions;

public static class UpdateTransaction
{
    public sealed class Endpoint : IEndpoint
    {
        public void MapEndpoint(IEndpointRouteBuilder app)
        {
            app.MapPut($"{EndpointGroups.Transactions}/{{id:guid}}", Handle)
                .WithTags(EndpointTags.Transactions)
                .RequireAuthorization();
        }
    }

    public static async Task<Results<NoContent, ProblemHttpResult>> Handle(
        Guid id,
        UpdateTransactionRequest request,
        ClaimsPrincipal user,
        ISender sender,
        CancellationToken cancellationToken)
    {
        var command = new UpdateTransactionCommand(
            id, user.GetTenantId(), request.Title, request.Description,
            request.From, request.To, request.LocationAddress, request.LocationLatitude, request.LocationLongitude,
            request.ClientId,
            request.Assets.Select(asset => new TransactionAssetInput(asset.AssetId, asset.Quantity, asset.Price)).ToList());

        var result = await sender.Send(command, cancellationToken);

        if (result.IsSuccess)
            return TypedResults.NoContent();

        return CommonHttpErrorHandlers.HandleError(result.Errors[0]);
    }
}
