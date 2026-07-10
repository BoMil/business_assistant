using Identity.Application.Repositories;
using Identity.Application.Services;
using Identity.Domain.Entities;
using Identity.Domain.Enums;
using MediatR;
using Shared.Domain.Errors;

namespace Identity.Application.UseCases.RegisterTenant;

internal sealed class RegisterTenantCommandHandler(
    ITenantRepository tenantRepository,
    IUserRepository userRepository,
    IUnitOfWork unitOfWork,
    IPasswordHasher passwordHasher)
    : IRequestHandler<RegisterTenantCommand, RegisterTenantResult>
{
    public async Task<RegisterTenantResult> Handle(RegisterTenantCommand request, CancellationToken cancellationToken)
    {
        var slugTaken = await tenantRepository.ExistsBySlugAsync(request.Slug, cancellationToken);
        if (slugTaken)
            throw new ConflictException(new ConflictError($"Slug '{request.Slug}' is already taken."));

        var emailTaken = await userRepository.ExistsByEmailAsync(request.OwnerEmail, cancellationToken);
        if (emailTaken)
            throw new ConflictException(new ConflictError($"Email '{request.OwnerEmail}' is already registered."));

        var tenant = Tenant.Create(request.TenantName, request.Slug, request.PrimaryColor, request.AccentColor, request.ErrorColor);

        var passwordHash = passwordHasher.Hash(request.OwnerPassword);
        var owner = User.Create(request.OwnerFirstName, request.OwnerLastName, request.OwnerEmail, request.OwnerPhoneNumber, passwordHash, tenant.Id, UserRole.Owner);

        await tenantRepository.AddAsync(tenant, cancellationToken);
        await userRepository.AddAsync(owner, cancellationToken);
        await unitOfWork.SaveChangesAsync(cancellationToken);

        return new RegisterTenantResult(tenant.Id, owner.Id);
    }
}
