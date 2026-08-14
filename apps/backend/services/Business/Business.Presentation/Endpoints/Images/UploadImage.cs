using System.Security.Claims;
using Business.Application.UseCases.UploadImage;
using Business.Presentation.Endpoints.Common;
using Shared.Presentation.ErrorHandling;
using MediatR;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Routing;

namespace Business.Presentation.Endpoints.Images;

public static class UploadImage
{
    public sealed class Endpoint : IEndpoint
    {
        public void MapEndpoint(IEndpointRouteBuilder app)
        {
            app.MapPost(EndpointGroups.Images, Handle)
                .WithTags(EndpointTags.Images)
                .RequireAuthorization()
                // Minimal APIs auto-require antiforgery (CSRF) validation for any endpoint
                // binding IFormFile — that protection is for cookie-based browser auth.
                // We use Bearer JWT, not cookies, so CSRF doesn't apply here.
                .DisableAntiforgery();
        }
    }

    public static async Task<Results<Ok<string>, ProblemHttpResult>> Handle(
        IFormFile file,
        ClaimsPrincipal user,
        ISender sender,
        CancellationToken cancellationToken)
    {
        await using var stream = file.OpenReadStream();

        var command = new UploadImageCommand(user.GetTenantId(), stream, file.FileName, file.ContentType, file.Length);
        var result = await sender.Send(command, cancellationToken);

        if (result.IsSuccess)
            return TypedResults.Ok(result.Value);

        return CommonHttpErrorHandlers.HandleError(result.Errors[0]);
    }
}
