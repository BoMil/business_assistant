using System.Security.Claims;
using Business.Application.UseCases.Common;
using Business.Application.UseCases.GetTransactionsByDateRange;
using Business.Presentation.Endpoints.Common;
using Shared.Presentation.ErrorHandling;
using MediatR;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Routing;

namespace Business.Presentation.Endpoints.Transactions;

public static class GetTransactionsByDateRange
{
    public sealed class Endpoint : IEndpoint
    {
        public void MapEndpoint(IEndpointRouteBuilder app)
        {
            app.MapGet($"{EndpointGroups.Transactions}/by-date-range", Handle)
                .WithTags(EndpointTags.Transactions)
                .RequireAuthorization();
        }
    }

    public static async Task<Results<Ok<List<TransactionDto>>, ProblemHttpResult>> Handle(
        ClaimsPrincipal user, ISender sender, CancellationToken cancellationToken, DateTime from, DateTime to)
    {
        var result = await sender.Send(new GetTransactionsByDateRangeQuery(user.GetTenantId(), from, to), cancellationToken);

        if (result.IsSuccess)
            return TypedResults.Ok(result.Value);

        return CommonHttpErrorHandlers.HandleError(result.Errors[0]);
    }
}
