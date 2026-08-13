using FluentResults;
using FluentValidation;
using Shared.Application.RequestTypes;

namespace Business.Application.UseCases.UpdateAsset;

public record UpdateAssetCommand(
    Guid Id,
    Guid TenantId,
    string Name,
    string Category,
    string? Description,
    decimal? SalePrice,
    decimal? RentalPrice,
    int StockCount,
    string? ImgUrl
) : ICommand<Result>;

public sealed class UpdateAssetCommandValidator : AbstractValidator<UpdateAssetCommand>
{
    public UpdateAssetCommandValidator()
    {
        RuleFor(x => x.Name).NotEmpty().WithMessage("Name is required");
        RuleFor(x => x.Category).NotEmpty().WithMessage("Category is required");
        RuleFor(x => x.StockCount).GreaterThanOrEqualTo(0).WithMessage("StockCount cannot be negative");
    }
}
