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
}
