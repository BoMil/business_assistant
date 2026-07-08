using Shared.Application.RequestTypes;

namespace Identity.Application.UseCases.RegisterTenant;

public record RegisterTenantCommand(
    string TenantName,
    string Slug,
    string PrimaryColor,
    string SecondaryColor,
    string OwnerFirstName,
    string OwnerLastName,
    string OwnerEmail,
    string OwnerPhoneNumber,
    string OwnerPassword
) : ICommand<RegisterTenantResult>;

public record RegisterTenantResult(Guid TenantId, Guid OwnerId);
