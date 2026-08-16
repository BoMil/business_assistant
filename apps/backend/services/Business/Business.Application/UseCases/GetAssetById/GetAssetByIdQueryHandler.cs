using Business.Application.Repositories;
using Business.Application.UseCases.Common;
using Shared.Domain.Errors;
using FluentResults;
using MediatR;

namespace Business.Application.UseCases.GetAssetById;

internal sealed class GetAssetByIdQueryHandler(IUnitOfWorkBusiness unitOfWork)
    : IRequestHandler<GetAssetByIdQuery, Result<AssetDetailDto>>
{
    public async Task<Result<AssetDetailDto>> Handle(GetAssetByIdQuery request, CancellationToken cancellationToken)
    {
        var asset = await unitOfWork.Assets.GetByIdAsync(request.Id, request.TenantId, cancellationToken);
        if (asset is null)
            return Result.Fail(new NotFoundError($"Asset '{request.Id}' not found."));

        // "Right now" reservation = overlap window collapsed to a single instant.
        var now = DateTime.UtcNow;
        var currentlyReserved = await unitOfWork.Transactions.GetReservedQuantityAsync(asset.Id, now, now, excludeTransactionId: null, cancellationToken);

        return Result.Ok(new AssetDetailDto(asset.Id, asset.Name, asset.CategoryId, asset.Category?.Name, asset.Description, asset.SalePrice, asset.RentalPrice, asset.StockCount, currentlyReserved, asset.ImgUrl));
    }
}
