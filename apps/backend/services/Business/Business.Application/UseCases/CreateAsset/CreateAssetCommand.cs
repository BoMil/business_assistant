using FluentResults;
using FluentValidation;
using Shared.Application.RequestTypes;

namespace Business.Application.UseCases.CreateAsset;

public record CreateAssetCommand(
    Guid TenantId,
    string Name,
    string Category,
    string? Description,
    decimal? SalePrice,
    decimal? RentalPrice,
    int StockCount
) : ICommand<Result<Guid>>;

public sealed class CreateAssetCommandValidator : AbstractValidator<CreateAssetCommand>
{
    public CreateAssetCommandValidator()
    {
        RuleFor(x => x.Name).NotEmpty().WithMessage("Name is required");
        RuleFor(x => x.Category).NotEmpty().WithMessage("Category is required");
        RuleFor(x => x.StockCount).GreaterThanOrEqualTo(0).WithMessage("StockCount cannot be negative");
    }
}
