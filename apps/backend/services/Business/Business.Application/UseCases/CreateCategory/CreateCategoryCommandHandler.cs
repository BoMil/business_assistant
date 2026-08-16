using Business.Application.Repositories;
using Business.Domain.Entities;
using FluentResults;
using MediatR;

namespace Business.Application.UseCases.CreateCategory;

internal sealed class CreateCategoryCommandHandler(IUnitOfWorkBusiness unitOfWork)
    : IRequestHandler<CreateCategoryCommand, Result<Guid>>
{
    public async Task<Result<Guid>> Handle(CreateCategoryCommand request, CancellationToken cancellationToken)
    {
        var nameTaken = await unitOfWork.Categories.ExistsByNameAsync(request.TenantId, request.Name, cancellationToken);
        if (nameTaken)
            return Result.Fail($"Category '{request.Name}' already exists.");

        var category = Category.Create(request.TenantId, request.Name, request.ImgUrl);

        await unitOfWork.Categories.AddAsync(category, cancellationToken);
        await unitOfWork.SaveChangesAsync(cancellationToken);

        return Result.Ok(category.Id);
    }
}
