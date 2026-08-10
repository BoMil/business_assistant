using Identity.Domain.Enums;

namespace Identity.Presentation.Endpoints.Tenants.RegisterTenant;

/// <summary>JSON body for POST /tenants/register.</summary>
public record RegisterTenantRequest(
    string TenantName,
    string Slug,
    string PrimaryColor,
    string AccentColor,
    string ErrorColor,
    TenantType Type,
    string OwnerFirstName,
    string OwnerLastName,
    string OwnerEmail,
    string OwnerPhoneNumber,
    string OwnerPassword,
    string Currency = "EUR");
