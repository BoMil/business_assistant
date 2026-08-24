using System.Security.Claims;

namespace Business.Presentation.Endpoints.Common;

/// <summary>
/// Business never issues JWTs itself (see Business.Infrastructure), it only validates the ones
/// Identity issued — "tenantId" is a custom claim Identity's JwtProvider embeds in every token.
/// Every endpoint uses this to scope its query/command to the caller's own tenant.
/// </summary>
public static class ClaimsPrincipalExtensions
{
    public static Guid GetTenantId(this ClaimsPrincipal user)
    {
        var value = user.FindFirst("tenantId")?.Value
            ?? throw new InvalidOperationException("JWT is missing the 'tenantId' claim.");

        return Guid.Parse(value);
    }

    /// <summary>
    /// JwtProvider embeds the user's id under the standard "sub" claim, but ASP.NET's JWT
    /// bearer handler remaps "sub" to ClaimTypes.NameIdentifier by default before the endpoint
    /// ever sees the ClaimsPrincipal — unlike "tenantId" (a non-standard claim name, passes
    /// through unmapped). Reading FindFirst("sub") here would always return null.
    /// </summary>
    public static Guid GetUserId(this ClaimsPrincipal user)
    {
        var value = user.FindFirstValue(ClaimTypes.NameIdentifier)
            ?? throw new InvalidOperationException("JWT is missing the 'sub' claim.");

        return Guid.Parse(value);
    }
}
