using Business.Application.Repositories;
using Business.Application.UseCases.Common;
using FluentResults;
using MediatR;

namespace Business.Application.UseCases.GetTransactions;

internal sealed class GetTransactionsQueryHandler(IUnitOfWorkBusiness unitOfWork)
    : IRequestHandler<GetTransactionsQuery, Result<List<TransactionDto>>>
{
    public async Task<Result<List<TransactionDto>>> Handle(GetTransactionsQuery request, CancellationToken cancellationToken)
    {
        var transactions = await unitOfWork.Transactions.GetAllAsync(request.TenantId, cancellationToken);
        var now = DateTime.UtcNow;

        var dtos = new List<TransactionDto>();
        foreach (var transaction in transactions)
            dtos.Add(await TransactionMapper.ToDtoAsync(transaction, unitOfWork.Assets, request.TenantId, now, cancellationToken));

        return Result.Ok(dtos);
    }
}
