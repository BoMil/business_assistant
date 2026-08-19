using Business.Application.UseCases.Common;
using FluentResults;
using Shared.Application.RequestTypes;

namespace Business.Application.UseCases.GetAssetsPaged;

public record GetAssetsPagedQuery(Guid TenantId, int Page, int PageSize, string? SearchTerm)
    : IQuery<Result<PagedResult<AssetDto>>>;
