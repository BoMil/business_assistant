using FluentResults;
using Shared.Application.RequestTypes;

namespace Business.Application.UseCases.DeleteCategory;

public record DeleteCategoryCommand(Guid Id, Guid TenantId) : ICommand<Result>;
