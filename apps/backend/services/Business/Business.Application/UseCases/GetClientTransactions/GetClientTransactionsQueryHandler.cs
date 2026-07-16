using Business.Application.Repositories;
using Business.Application.UseCases.Common;
using FluentResults;
using MediatR;

namespace Business.Application.UseCases.GetClientTransactions;

internal sealed class GetClientTransactionsQueryHandler(IUnitOfWorkBusiness unitOfWork)
    : IRequestHandler<GetClientTransactionsQuery, Result<List<TransactionDto>>>
{
    public async Task<Result<List<TransactionDto>>> Handle(GetClientTransactionsQuery request, CancellationToken cancellationToken)
    {
        var transactions = await unitOfWork.Transactions.GetByClientAsync(request.ClientId, request.TenantId, cancellationToken);
        var now = DateTime.UtcNow;

        var dtos = new List<TransactionDto>();
        foreach (var transaction in transactions)
            dtos.Add(await TransactionMapper.ToDtoAsync(transaction, unitOfWork.Assets, request.TenantId, now, cancellationToken));

        return Result.Ok(dtos);
    }
}
