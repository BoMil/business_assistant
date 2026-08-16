using Business.Application.Repositories;
using Shared.Domain.Errors;
using FluentResults;
using MediatR;

namespace Business.Application.UseCases.DeleteCategory;

internal sealed class DeleteCategoryCommandHandler(IUnitOfWorkBusiness unitOfWork)
    : IRequestHandler<DeleteCategoryCommand, Result>
{
    public async Task<Result> Handle(DeleteCategoryCommand request, CancellationToken cancellationToken)
    {
        var category = await unitOfWork.Categories.GetByIdAsync(request.Id, request.TenantId, cancellationToken);
        if (category is null)
            return Result.Fail(new NotFoundError($"Category '{request.Id}' not found."));

        unitOfWork.Categories.Remove(category);
        await unitOfWork.SaveChangesAsync(cancellationToken);

        return Result.Ok();
    }
}
