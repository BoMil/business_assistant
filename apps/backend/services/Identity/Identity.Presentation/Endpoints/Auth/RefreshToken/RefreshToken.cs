using Identity.Application.UseCases.RefreshToken;
using Identity.Presentation.Endpoints.Common;
using MediatR;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Routing;

namespace Identity.Presentation.Endpoints.Auth.RefreshToken;

/// <summary>
/// POST /auth/refresh-token
/// Accepts a valid refresh token and returns a new access token + new refresh token.
/// The old refresh token is revoked immediately (rotation pattern — each token can only be used once).
/// This endpoint is public — no JWT required (the refresh token itself is the credential).
/// </summary>
public static class RefreshToken
{
    public sealed class Endpoint : IEndpoint
    {
        public void MapEndpoint(IEndpointRouteBuilder app)
        {
            app.MapPost($"{EndpointGroups.Auth}/refresh-token", Handle)
                .WithTags(EndpointTags.Auth)
                .AllowAnonymous();
        }
    }

    public static async Task<Ok<RefreshTokenResult>> Handle(
        RefreshTokenRequest request,
        ISender sender,
        CancellationToken cancellationToken)
    {
        var command = new RefreshTokenCommand(request.Token);
        var result = await sender.Send(command, cancellationToken);
        return TypedResults.Ok(result);
    }
}
