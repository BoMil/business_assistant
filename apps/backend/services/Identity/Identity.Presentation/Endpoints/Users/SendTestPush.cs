using System.Security.Claims;
using Identity.Application.UseCases.SendTestPush;
using Identity.Presentation.Endpoints.Common;
using MediatR;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Routing;
using Shared.Presentation.ErrorHandling;

namespace Identity.Presentation.Endpoints.Users;

/// <summary>
/// POST /users/me/test-push — sends a hardcoded test push to every device token
/// registered to the current user. Pipeline-verification tool for the infra-only v1
/// (no business-event triggers exist yet) — not a messaging feature.
/// </summary>
public static class SendTestPush
{
    public sealed class Endpoint : IEndpoint
    {
        public void MapEndpoint(IEndpointRouteBuilder app)
        {
            app.MapPost($"{EndpointGroups.Users}/me/test-push", Handle)
                .WithTags(EndpointTags.Users)
                .RequireAuthorization();
        }
    }

    public static async Task<Results<Ok<SendTestPushResult>, ProblemHttpResult>> Handle(
        ClaimsPrincipal user,
        ISender sender,
        CancellationToken cancellationToken)
    {
        var result = await sender.Send(new SendTestPushCommand(user.GetUserId()), cancellationToken);

        if (result.IsSuccess)
            return TypedResults.Ok(result.Value);

        return CommonHttpErrorHandlers.HandleError(result.Errors[0]);
    }
}
