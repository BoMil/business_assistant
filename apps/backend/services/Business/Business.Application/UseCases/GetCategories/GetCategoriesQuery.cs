using Business.Application.UseCases.Common;
using FluentResults;
using Shared.Application.RequestTypes;

namespace Business.Application.UseCases.GetCategories;

public record GetCategoriesQuery(Guid TenantId) : IQuery<Result<List<CategoryDto>>>;
