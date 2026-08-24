using FluentResults;
using FluentValidation;
using Shared.Application.RequestTypes;

namespace Business.Application.UseCases.CreateAsset;

public record CreateAssetCommand(
    Guid TenantId,
    Guid UserId,
    string Name,
    Guid? CategoryId,
    string? Description,
    decimal? SalePrice,
    decimal? RentalPrice,
    int StockCount,
    string? ImgUrl
) : ICommand<Result<Guid>>;

public sealed class CreateAssetCommandValidator : AbstractValidator<CreateAssetCommand>
{
    public CreateAssetCommandValidator()
    {
        RuleFor(x => x.Name).NotEmpty().WithMessage("Name is required");
        RuleFor(x => x.StockCount).GreaterThanOrEqualTo(0).WithMessage("StockCount cannot be negative");
    }
}
