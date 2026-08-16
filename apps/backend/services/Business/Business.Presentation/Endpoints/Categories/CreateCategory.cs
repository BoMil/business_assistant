using System.Security.Claims;
using Business.Application.UseCases.CreateCategory;
using Business.Presentation.Endpoints.Common;
using Shared.Presentation.ErrorHandling;
using MediatR;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Routing;

namespace Business.Presentation.Endpoints.Categories;

public static class CreateCategory
{
    public sealed class Endpoint : IEndpoint
    {
        public void MapEndpoint(IEndpointRouteBuilder app)
        {
            app.MapPost(EndpointGroups.Categories, Handle)
                .WithTags(EndpointTags.Categories)
                .RequireAuthorization();
        }
    }

    public static async Task<Results<Created<Guid>, ProblemHttpResult>> Handle(
        CreateCategoryRequest request,
        ClaimsPrincipal user,
        ISender sender,
        CancellationToken cancellationToken)
    {
        var command = new CreateCategoryCommand(user.GetTenantId(), request.Name, request.ImgUrl);

        var result = await sender.Send(command, cancellationToken);

        if (result.IsSuccess)
            return TypedResults.Created($"{EndpointGroups.Categories}/{result.Value}", result.Value);

        return CommonHttpErrorHandlers.HandleError(result.Errors[0]);
    }
}
