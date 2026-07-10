using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Configuration;

namespace Identity.Presentation.Filters;

/// <summary>
/// Lightweight shared-secret auth for endpoints called by CI/CD rather than
/// an authenticated end user (e.g. GET /tenants/{slug}/config). Checks the
/// "X-Api-Key" header against Configuration["CiApiKey"].
///
/// Not JWT-based on purpose — there's no logged-in user in this flow, just a CI job.
/// </summary>
public sealed class ApiKeyEndpointFilter(IConfiguration configuration) : IEndpointFilter
{
    public async ValueTask<object?> InvokeAsync(EndpointFilterInvocationContext context, EndpointFilterDelegate next)
    {
        var expectedKey = configuration["CiApiKey"];
        var providedKey = context.HttpContext.Request.Headers["X-Api-Key"].ToString();

        if (string.IsNullOrEmpty(expectedKey) || providedKey != expectedKey)
            return Results.Unauthorized();

        return await next(context);
    }
}
