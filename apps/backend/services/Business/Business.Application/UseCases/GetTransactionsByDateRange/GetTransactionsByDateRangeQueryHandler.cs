using Business.Application.Repositories;
using Business.Application.UseCases.Common;
using FluentResults;
using MediatR;

namespace Business.Application.UseCases.GetTransactionsByDateRange;

internal sealed class GetTransactionsByDateRangeQueryHandler(IUnitOfWorkBusiness unitOfWork)
    : IRequestHandler<GetTransactionsByDateRangeQuery, Result<List<TransactionDto>>>
{
    public async Task<Result<List<TransactionDto>>> Handle(GetTransactionsByDateRangeQuery request, CancellationToken cancellationToken)
    {
        var transactions = await unitOfWork.Transactions.GetByDateRangeAsync(request.TenantId, request.From, request.To, cancellationToken);
        var now = DateTime.UtcNow;

        var dtos = new List<TransactionDto>();
        foreach (var transaction in transactions)
            dtos.Add(await TransactionMapper.ToDtoAsync(transaction, unitOfWork.Assets, request.TenantId, now, cancellationToken));

        return Result.Ok(dtos);
    }
}
