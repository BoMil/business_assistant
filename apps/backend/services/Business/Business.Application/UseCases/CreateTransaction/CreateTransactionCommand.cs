using Business.Application.UseCases.Common;
using Business.Domain.Enums;
using FluentResults;
using FluentValidation;
using Shared.Application.RequestTypes;

namespace Business.Application.UseCases.CreateTransaction;

public record CreateTransactionCommand(
    Guid TenantId,
    TransactionType Type,
    string Title,
    string? Description,
    DateTime? From,
    DateTime? To,
    string? LocationAddress,
    double? LocationLatitude,
    double? LocationLongitude,
    Guid? ClientId,
    List<TransactionLineItemInput> LineItems
) : ICommand<Result<Guid>>;

public sealed class CreateTransactionCommandValidator : AbstractValidator<CreateTransactionCommand>
{
    public CreateTransactionCommandValidator()
    {
        RuleFor(x => x.Title).NotEmpty().WithMessage("Title is required");
        RuleFor(x => x.LineItems).NotEmpty().WithMessage("At least one line item is required");
        RuleForEach(x => x.LineItems).ChildRules(item =>
        {
            item.RuleFor(li => li.Quantity).GreaterThan(0).WithMessage("Quantity must be greater than zero");
        });
    }
}
