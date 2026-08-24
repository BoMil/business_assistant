using Business.Application.UseCases.Common;
using FluentResults;
using FluentValidation;
using Shared.Application.RequestTypes;

namespace Business.Application.UseCases.UpdateTransaction;

public record UpdateTransactionCommand(
    Guid Id,
    Guid TenantId,
    Guid UserId,
    string Title,
    string? Description,
    DateTime? From,
    DateTime? To,
    string? LocationAddress,
    double? LocationLatitude,
    double? LocationLongitude,
    Guid? ClientId,
    List<TransactionAssetInput> Assets
) : ICommand<Result>;

public sealed class UpdateTransactionCommandValidator : AbstractValidator<UpdateTransactionCommand>
{
    public UpdateTransactionCommandValidator()
    {
        RuleFor(x => x.Title).NotEmpty().WithMessage("Title is required");
        RuleFor(x => x.Assets).NotEmpty().WithMessage("At least one line item is required");
        RuleForEach(x => x.Assets).ChildRules(item =>
        {
            item.RuleFor(asset => asset.Quantity).GreaterThan(0).WithMessage("Quantity must be greater than zero");
        });
    }
}
