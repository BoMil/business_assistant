using Business.Application.UseCases.Common;
using FluentResults;
using FluentValidation;
using Shared.Application.RequestTypes;

namespace Business.Application.UseCases.GetTransactionsByDateRange;

public record GetTransactionsByDateRangeQuery(Guid TenantId, DateTime From, DateTime To) : IQuery<Result<List<TransactionDto>>>;

public sealed class GetTransactionsByDateRangeQueryValidator : AbstractValidator<GetTransactionsByDateRangeQuery>
{
    public GetTransactionsByDateRangeQueryValidator()
    {
        RuleFor(x => x.To).GreaterThanOrEqualTo(x => x.From).WithMessage("To must not be before From");
    }
}
