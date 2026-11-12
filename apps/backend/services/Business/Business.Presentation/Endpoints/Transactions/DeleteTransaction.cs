using System.Security.Claims;
using Business.Application.UseCases.DeleteTransaction;
using Business.Presentation.Endpoints.Common;
using Shared.Presentation.ErrorHandling;
using MediatR;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Routing;

namespace Business.Presentation.Endpoints.Transactions;

public static class DeleteTransaction
{
    public sealed class Endpoint : IEndpoint
    {
        public void MapEndpoint(IEndpointRouteBuilder app)
        {
            app.MapDelete($"{EndpointGroups.Transactions}/{{id:guid}}", Handle)
                .WithTags(EndpointTags.Transactions)
                .RequireAuthorization();
        }
    }

    public static async Task<Results<NoContent, ProblemHttpResult>> Handle(
        Guid id,
        ClaimsPrincipal user,
        ISender sender,
        CancellationToken cancellationToken)
    {
        var result = await sender.Send(new DeleteTransactionCommand(id, user.GetTenantId(), user.GetUserId()), cancellationToken);

        if (result.IsSuccess)
            return TypedResults.NoContent();

        return CommonHttpErrorHandlers.HandleError(result.Errors[0]);
    }
}
