using System.Security.Claims;
using Identity.Application.UseCases.RemoveDeviceToken;
using Identity.Presentation.Endpoints.Common;
using MediatR;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Routing;
using Shared.Presentation.ErrorHandling;

namespace Identity.Presentation.Endpoints.Users;

public static class RemoveDeviceToken
{
    public sealed class Endpoint : IEndpoint
    {
        public void MapEndpoint(IEndpointRouteBuilder app)
        {
            app.MapDelete($"{EndpointGroups.Users}/me/device-tokens", Handle)
                .WithTags(EndpointTags.Users)
                .RequireAuthorization();
        }
    }

    public static async Task<Results<NoContent, ProblemHttpResult>> Handle(
        [FromBody] RemoveDeviceTokenRequest request,
        ClaimsPrincipal user,
        ISender sender,
        CancellationToken cancellationToken)
    {
        var result = await sender.Send(new RemoveDeviceTokenCommand(user.GetUserId(), request.Token), cancellationToken);

        if (result.IsSuccess)
            return TypedResults.NoContent();

        return CommonHttpErrorHandlers.HandleError(result.Errors[0]);
    }
}
