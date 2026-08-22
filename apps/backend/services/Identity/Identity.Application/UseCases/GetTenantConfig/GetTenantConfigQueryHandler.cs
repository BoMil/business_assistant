using FluentResults;
using Identity.Application.Repositories;
using Identity.Application.UseCases.Common;
using MediatR;
using Shared.Domain.Errors;

namespace Identity.Application.UseCases.GetTenantConfig;

internal sealed class GetTenantConfigQueryHandler(IUnitOfWorkIdentity unitOfWork)
    : IRequestHandler<GetTenantConfigQuery, Result<TenantConfigDto>>
{
    public async Task<Result<TenantConfigDto>> Handle(GetTenantConfigQuery request, CancellationToken cancellationToken)
    {
        var tenant = await unitOfWork.Tenants.GetBySlugAsync(request.Slug, cancellationToken);
        if (tenant is null || !tenant.IsActive)
            return Result.Fail(new NotFoundError($"Tenant '{request.Slug}' not found."));

        return Result.Ok(new TenantConfigDto(
            tenant.Id,
            tenant.Name,
            tenant.LogoUrl,
            tenant.PrimaryColor,
            tenant.AccentColor,
            tenant.ErrorColor,
            tenant.Type,
            tenant.Currency,
            tenant.Modules.Events,
            tenant.Modules.Inventory,
            tenant.Modules.Clients,
            tenant.FeatureFlags.ThemeChange,
            tenant.FeatureFlags.Language,
            tenant.FirebaseConfig.AndroidApiKey,
            tenant.FirebaseConfig.AndroidAppId,
            tenant.FirebaseConfig.ProjectId,
            tenant.FirebaseConfig.MessagingSenderId,
            tenant.FirebaseConfig.StorageBucket));
    }
}
