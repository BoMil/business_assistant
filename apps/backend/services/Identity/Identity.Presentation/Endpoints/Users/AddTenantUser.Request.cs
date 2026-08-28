using Identity.Domain.Enums;

namespace Identity.Presentation.Endpoints.Users;

/// <summary>JSON body for POST /users.</summary>
public record AddTenantUserRequest(
    string FirstName,
    string LastName,
    string Email,
    string PhoneNumber,
    string Password,
    UserRole Role = UserRole.Member);
