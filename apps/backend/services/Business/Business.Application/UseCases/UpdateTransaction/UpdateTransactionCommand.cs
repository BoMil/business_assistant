using Business.Application.UseCases.Common;
using FluentResults;
using FluentValidation;
using Shared.Application.RequestTypes;

namespace Business.Application.UseCases.UpdateTransaction;

public record UpdateTransactionCommand(
    Guid Id,
    Guid TenantId,
    string Title,
    string? Description,
    DateTime? From,
    DateTime? To,
    string? LocationAddress,
    double? LocationLatitude,
    double? LocationLongitude,
    Guid? ClientId,
    List<TransactionLineItemInput> LineItems
) : ICommand<Result>;

public sealed class UpdateTransactionCommandValidator : AbstractValidator<UpdateTransactionCommand>
{
    public UpdateTransactionCommandValidator()
    {
        RuleFor(x => x.Title).NotEmpty().WithMessage("Title is required");
        RuleFor(x => x.LineItems).NotEmpty().WithMessage("At least one line item is required");
        RuleForEach(x => x.LineItems).ChildRules(item =>
        {
            item.RuleFor(li => li.Quantity).GreaterThan(0).WithMessage("Quantity must be greater than zero");
        });
    }
}
