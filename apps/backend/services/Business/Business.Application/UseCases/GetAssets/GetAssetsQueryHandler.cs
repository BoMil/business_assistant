using Business.Application.Repositories;
using Business.Application.UseCases.Common;
using FluentResults;
using MediatR;

namespace Business.Application.UseCases.GetAssets;

internal sealed class GetAssetsQueryHandler(IUnitOfWorkBusiness unitOfWork) : IRequestHandler<GetAssetsQuery, Result<List<AssetDto>>>
{
    public async Task<Result<List<AssetDto>>> Handle(GetAssetsQuery request, CancellationToken cancellationToken)
    {
        var assets = await unitOfWork.Assets.GetAllAsync(request.TenantId, cancellationToken);

        var dtos = assets
            .Where(a => a.IsActive)
            .Select(a => new AssetDto(a.Id, a.Name, a.Category, a.Description, a.SalePrice, a.RentalPrice, a.StockCount, a.ImgUrl))
            .ToList();

        return Result.Ok(dtos);
    }
}
