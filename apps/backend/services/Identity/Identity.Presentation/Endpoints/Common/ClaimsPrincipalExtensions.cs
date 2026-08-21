using System.Security.Claims;

namespace Identity.Presentation.Endpoints.Common;

public static class ClaimsPrincipalExtensions
{
    /// <summary>"tenantId" is a custom claim Identity's JwtProvider embeds in every token —
    /// it passes through unmapped, so it can be read back by its exact claim name.</summary>
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
