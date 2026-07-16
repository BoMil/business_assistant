using Identity.Application.UseCases.Login;
using Identity.Presentation.Endpoints.Common;
using MediatR;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Routing;
using Shared.Presentation.ErrorHandling;

namespace Identity.Presentation.Endpoints.Auth.Login;

/// <summary>
/// POST /auth/login
/// Authenticates a user with email and password.
/// Returns an access token (short-lived JWT), a refresh token, and the tenant's branding config.
/// This endpoint is public — no JWT required.
/// </summary>
public static class Login
{
    /// <summary>
    /// Inner class that implements IEndpoint — this is the piece the DI container discovers
    /// and calls MapEndpoint() on during app startup.
    /// </summary>
    public sealed class Endpoint : IEndpoint
    {
        public void MapEndpoint(IEndpointRouteBuilder app)
        {
            app.MapPost($"{EndpointGroups.Auth}/login", Handle)
                .WithTags(EndpointTags.Auth)
                .AllowAnonymous();
        }
    }

    /// <summary>
    /// Static handler method — separated from the endpoint registration so it can be unit-tested
    /// without spinning up the full HTTP pipeline.
    ///
    /// Return type is a union: either Ok with the result, or a Problem (error) response.
    /// Errors (wrong password, deactivated account) are returned as a failed Result from the
    /// Application layer and translated to a Problem response here.
    /// </summary>
    public static async Task<Results<Ok<LoginResult>, ProblemHttpResult>> Handle(
        LoginRequest request,
        ISender sender,
        CancellationToken cancellationToken)
    {
        var command = new LoginCommand(request.Email, request.Password);
        var result = await sender.Send(command, cancellationToken);

        if (result.IsSuccess)
            return TypedResults.Ok(result.Value);

        return CommonHttpErrorHandlers.HandleError(result.Errors[0]);
    }
}
