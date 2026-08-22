using FluentResults;
using Identity.Application.Repositories;
using Identity.Application.Services;
using MediatR;
using Shared.Domain.Errors;

namespace Identity.Application.UseCases.SetTenantFirebaseConfig;

internal sealed class SetTenantFirebaseConfigCommandHandler(IUnitOfWorkIdentity unitOfWork, IFirebaseCredentialProtector protector)
    : IRequestHandler<SetTenantFirebaseConfigCommand, Result>
{
    public async Task<Result> Handle(SetTenantFirebaseConfigCommand request, CancellationToken cancellationToken)
    {
        var tenant = await unitOfWork.Tenants.GetBySlugAsync(request.Slug, cancellationToken);
        if (tenant is null)
            return Result.Fail(new NotFoundError($"Tenant '{request.Slug}' not found."));

        var encryptedServiceAccountJson = protector.Protect(request.ServiceAccountJson);
        tenant.SetFirebaseConfig(
            request.AndroidApiKey,
            request.AndroidAppId,
            request.ProjectId,
            request.MessagingSenderId,
            request.StorageBucket,
            encryptedServiceAccountJson);

        await unitOfWork.SaveChangesAsync(cancellationToken);
        return Result.Ok();
    }
}
