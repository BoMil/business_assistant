using Business.Application.Repositories;
using Business.Domain.Entities;
using FluentResults;
using MediatR;

namespace Business.Application.UseCases.CreateAsset;

internal sealed class CreateAssetCommandHandler(IUnitOfWorkBusiness unitOfWork)
    : IRequestHandler<CreateAssetCommand, Result<Guid>>
{
    public async Task<Result<Guid>> Handle(CreateAssetCommand request, CancellationToken cancellationToken)
    {
        var asset = Asset.Create(request.TenantId, request.Name, request.Category, request.Description, request.SalePrice, request.RentalPrice, request.StockCount);

        await unitOfWork.Assets.AddAsync(asset, cancellationToken);
        await unitOfWork.SaveChangesAsync(cancellationToken);

        return Result.Ok(asset.Id);
    }
}
