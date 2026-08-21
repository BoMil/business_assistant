using Identity.Domain.Enums;

namespace Identity.Application.UseCases.Common;

public record UserDto(Guid Id, Guid TenantId, string FirstName, string LastName, string Email, UserRole Role, string? ImgUrl);
