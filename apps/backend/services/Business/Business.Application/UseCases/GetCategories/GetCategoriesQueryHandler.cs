using Business.Application.Repositories;
using Business.Application.UseCases.Common;
using FluentResults;
using MediatR;

namespace Business.Application.UseCases.GetCategories;

internal sealed class GetCategoriesQueryHandler(IUnitOfWorkBusiness unitOfWork)
    : IRequestHandler<GetCategoriesQuery, Result<List<CategoryDto>>>
{
    public async Task<Result<List<CategoryDto>>> Handle(GetCategoriesQuery request, CancellationToken cancellationToken)
    {
        var categories = await unitOfWork.Categories.GetAllAsync(request.TenantId, cancellationToken);

        var dtos = categories
            .OrderBy(c => c.Name)
            .Select(c => new CategoryDto(c.Id, c.Name, c.ImgUrl))
            .ToList();

        return Result.Ok(dtos);
    }
}
