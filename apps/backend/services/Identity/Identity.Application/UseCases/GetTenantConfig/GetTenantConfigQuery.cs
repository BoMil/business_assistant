using Identity.Application.UseCases.Common;
using Shared.Application.RequestTypes;

namespace Identity.Application.UseCases.GetTenantConfig;

public record GetTenantConfigQuery(string Slug) : IQuery<TenantConfigDto>;
