using System.Security.Claims;
using Business.Application.UseCases.Common;
using Business.Application.UseCases.CreateTransaction;
using Business.Presentation.Endpoints.Common;
using Shared.Presentation.ErrorHandling;
using MediatR;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Routing;

namespace Business.Presentation.Endpoints.Transactions;

public static class CreateTransaction
{
    public sealed class Endpoint : IEndpoint
    {
        public void MapEndpoint(IEndpointRouteBuilder app)
        {
            app.MapPost(EndpointGroups.Transactions, Handle)
                .WithTags(EndpointTags.Transactions)
                .RequireAuthorization();
        }
    }

    public static async Task<Results<Created<Guid>, ProblemHttpResult>> Handle(
        CreateTransactionRequest request,
        ClaimsPrincipal user,
        ISender sender,
        CancellationToken cancellationToken)
    {
        var command = new CreateTransactionCommand(
            user.GetTenantId(), request.Type, request.Title, request.Description,
            request.From, request.To, request.LocationAddress, request.LocationLatitude, request.LocationLongitude,
            request.ClientId,
            request.LineItems.Select(li => new TransactionLineItemInput(li.AssetId, li.Quantity, li.Price)).ToList());

        var result = await sender.Send(command, cancellationToken);

        if (result.IsSuccess)
            return TypedResults.Created($"{EndpointGroups.Transactions}/{result.Value}", result.Value);

        return CommonHttpErrorHandlers.HandleError(result.Errors[0]);
    }
}
