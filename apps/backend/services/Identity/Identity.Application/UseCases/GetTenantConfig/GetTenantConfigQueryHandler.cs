using Identity.Application.Repositories;
using Identity.Application.UseCases.Common;
using MediatR;
using Shared.Domain.Errors;

namespace Identity.Application.UseCases.GetTenantConfig;

internal sealed class GetTenantConfigQueryHandler(ITenantRepository tenantRepository)
    : IRequestHandler<GetTenantConfigQuery, TenantConfigDto>
{
    public async Task<TenantConfigDto> Handle(GetTenantConfigQuery request, CancellationToken cancellationToken)
    {
        var tenant = await tenantRepository.GetBySlugAsync(request.Slug, cancellationToken);
        if (tenant is null || !tenant.IsActive)
            throw new NotFoundException(new NotFoundError($"Tenant '{request.Slug}' not found."));

        return new TenantConfigDto(
            tenant.Id,
            tenant.Name,
            tenant.LogoUrl,
            tenant.PrimaryColor,
            tenant.AccentColor,
            tenant.ErrorColor,
            tenant.FeatureFlags.Rental,
            tenant.FeatureFlags.Inventory,
            tenant.FeatureFlags.Reporting,
            tenant.FeatureFlags.Poultry,
            tenant.FeatureFlags.ThemeChange,
            tenant.FeatureFlags.Language);
    }
}
