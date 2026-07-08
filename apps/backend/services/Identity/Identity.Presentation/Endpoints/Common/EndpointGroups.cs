namespace Identity.Presentation.Endpoints.Common;

/// <summary>
/// Route prefixes for endpoint groups.
/// Used as the first segment of every endpoint path — e.g. "auth" → POST /auth/login.
/// Pattern from Zepp.WebApp — each service has its own EndpointGroups constants file.
/// </summary>
public static class EndpointGroups
{
    public const string Auth = "auth";
    public const string Tenants = "tenants";
}

/// <summary>
/// Swagger tag names — group endpoints in the Swagger UI under a named section.
/// </summary>
public static class EndpointTags
{
    public const string Auth = "Auth";
    public const string Tenants = "Tenants";
}
