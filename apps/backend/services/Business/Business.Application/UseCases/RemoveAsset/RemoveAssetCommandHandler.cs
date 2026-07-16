using Business.Application.Repositories;
using Shared.Domain.Errors;
using FluentResults;
using MediatR;

namespace Business.Application.UseCases.RemoveAsset;

internal sealed class RemoveAssetCommandHandler(IUnitOfWorkBusiness unitOfWork)
    : IRequestHandler<RemoveAssetCommand, Result>
{
    public async Task<Result> Handle(RemoveAssetCommand request, CancellationToken cancellationToken)
    {
        var asset = await unitOfWork.Assets.GetByIdAsync(request.Id, request.TenantId, cancellationToken);
        if (asset is null)
            return Result.Fail(new NotFoundError($"Asset '{request.Id}' not found."));

        asset.Remove();
        await unitOfWork.SaveChangesAsync(cancellationToken);

        return Result.Ok();
    }
}
