using System.Security.Claims;
using Business.Application.UseCases.Common;
using Business.Application.UseCases.GetCategories;
using Business.Presentation.Endpoints.Common;
using Shared.Presentation.ErrorHandling;
using MediatR;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Routing;

namespace Business.Presentation.Endpoints.Categories;

public static class GetCategories
{
    public sealed class Endpoint : IEndpoint
    {
        public void MapEndpoint(IEndpointRouteBuilder app)
        {
            app.MapGet(EndpointGroups.Categories, Handle)
                .WithTags(EndpointTags.Categories)
                .RequireAuthorization();
        }
    }

    public static async Task<Results<Ok<List<CategoryDto>>, ProblemHttpResult>> Handle(
        ClaimsPrincipal user,
        ISender sender,
        CancellationToken cancellationToken)
    {
        var result = await sender.Send(new GetCategoriesQuery(user.GetTenantId()), cancellationToken);

        if (result.IsSuccess)
            return TypedResults.Ok(result.Value);

        return CommonHttpErrorHandlers.HandleError(result.Errors[0]);
    }
}
