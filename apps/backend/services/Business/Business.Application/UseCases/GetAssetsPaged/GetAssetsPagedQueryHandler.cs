using Business.Application.Repositories;
using Business.Application.UseCases.Common;
using FluentResults;
using MediatR;

namespace Business.Application.UseCases.GetAssetsPaged;

internal sealed class GetAssetsPagedQueryHandler(IUnitOfWorkBusiness unitOfWork)
    : IRequestHandler<GetAssetsPagedQuery, Result<PagedResult<AssetDto>>>
{
    public async Task<Result<PagedResult<AssetDto>>> Handle(GetAssetsPagedQuery request, CancellationToken cancellationToken)
    {
        var page = Math.Max(1, request.Page);
        var pageSize = Math.Clamp(request.PageSize, 1, 100);

        var (assets, totalCount) = await unitOfWork.Assets.GetPagedAsync(
            request.TenantId, page, pageSize, request.SearchTerm, cancellationToken);

        var dtos = assets
            .Select(a => new AssetDto(a.Id, a.Name, a.CategoryId, a.Category?.Name, a.Description, a.SalePrice, a.RentalPrice, a.StockCount, a.ImgUrl))
            .ToList();

        return Result.Ok(PagedResult<AssetDto>.Create(dtos, page, pageSize, totalCount));
    }
}
