using System.Security.Claims;
using Business.Application.UseCases.Common;
using Business.Application.UseCases.GetTransactions;
using Business.Presentation.Endpoints.Common;
using Shared.Presentation.ErrorHandling;
using MediatR;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Routing;

namespace Business.Presentation.Endpoints.Transactions;

public static class GetTransactions
{
    public sealed class Endpoint : IEndpoint
    {
        public void MapEndpoint(IEndpointRouteBuilder app)
        {
            app.MapGet(EndpointGroups.Transactions, Handle)
                .WithTags(EndpointTags.Transactions)
                .RequireAuthorization();
        }
    }

    public static async Task<Results<Ok<PagedResult<TransactionDto>>, ProblemHttpResult>> Handle(
        ClaimsPrincipal user,
        ISender sender,
        CancellationToken cancellationToken,
        int page = 1,
        int pageSize = 20,
        string? search = null)
    {
        var result = await sender.Send(new GetTransactionsQuery(user.GetTenantId(), page, pageSize, search), cancellationToken);

        if (result.IsSuccess)
            return TypedResults.Ok(result.Value);

        return CommonHttpErrorHandlers.HandleError(result.Errors[0]);
    }
}
