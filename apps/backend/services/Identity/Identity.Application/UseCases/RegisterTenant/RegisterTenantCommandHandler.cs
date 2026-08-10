using FluentResults;
using Identity.Application.Repositories;
using Identity.Application.Services;
using Identity.Domain.Entities;
using Identity.Domain.Enums;
using MediatR;

namespace Identity.Application.UseCases.RegisterTenant;

internal sealed class RegisterTenantCommandHandler(
    IUnitOfWorkIdentity unitOfWork,
    IPasswordHasher passwordHasher)
    : IRequestHandler<RegisterTenantCommand, Result<RegisterTenantResult>>
{
    public async Task<Result<RegisterTenantResult>> Handle(RegisterTenantCommand request, CancellationToken cancellationToken)
    {
        var slugTaken = await unitOfWork.Tenants.ExistsBySlugAsync(request.Slug, cancellationToken);
        if (slugTaken)
            return Result.Fail($"Slug '{request.Slug}' is already taken.");

        var emailTaken = await unitOfWork.Users.ExistsByEmailAsync(request.OwnerEmail, cancellationToken);
        if (emailTaken)
            return Result.Fail($"Email '{request.OwnerEmail}' is already registered.");

        var tenant = Tenant.Create(request.TenantName, request.Slug, request.PrimaryColor, request.AccentColor, request.ErrorColor, request.Type, request.Currency);

        var passwordHash = passwordHasher.Hash(request.OwnerPassword);
        var owner = User.Create(request.OwnerFirstName, request.OwnerLastName, request.OwnerEmail, request.OwnerPhoneNumber, passwordHash, tenant.Id, UserRole.Owner);

        await unitOfWork.Tenants.AddAsync(tenant, cancellationToken);
        await unitOfWork.Users.AddAsync(owner, cancellationToken);
        await unitOfWork.SaveChangesAsync(cancellationToken);

        return Result.Ok(new RegisterTenantResult(tenant.Id, owner.Id));
    }
}
