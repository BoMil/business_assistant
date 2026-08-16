using Business.Application.Repositories;
using Shared.Domain.Errors;
using FluentResults;
using MediatR;

namespace Business.Application.UseCases.UpdateAsset;

internal sealed class UpdateAssetCommandHandler(IUnitOfWorkBusiness unitOfWork)
    : IRequestHandler<UpdateAssetCommand, Result>
{
    public async Task<Result> Handle(UpdateAssetCommand request, CancellationToken cancellationToken)
    {
        var asset = await unitOfWork.Assets.GetByIdAsync(request.Id, request.TenantId, cancellationToken);
        if (asset is null)
            return Result.Fail(new NotFoundError($"Asset '{request.Id}' not found."));

        asset.Update(request.Name, request.CategoryId, request.Description, request.SalePrice, request.RentalPrice, request.StockCount, request.ImgUrl);
        await unitOfWork.SaveChangesAsync(cancellationToken);

        return Result.Ok();
    }
}
