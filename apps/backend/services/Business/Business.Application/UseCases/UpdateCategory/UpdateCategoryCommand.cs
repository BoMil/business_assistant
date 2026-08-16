using FluentResults;
using FluentValidation;
using Shared.Application.RequestTypes;

namespace Business.Application.UseCases.UpdateCategory;

public record UpdateCategoryCommand(Guid Id, Guid TenantId, string Name, string? ImgUrl) : ICommand<Result>;

public sealed class UpdateCategoryCommandValidator : AbstractValidator<UpdateCategoryCommand>
{
    public UpdateCategoryCommandValidator()
    {
        RuleFor(x => x.Name).NotEmpty().MaximumLength(200).WithMessage("Name is required");
    }
}
