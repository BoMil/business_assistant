using Business.Application.Repositories;
using Business.Application.UseCases.Common;
using FluentResults;
using MediatR;

namespace Business.Application.UseCases.GetTransactions;

internal sealed class GetTransactionsQueryHandler(IUnitOfWorkBusiness unitOfWork)
    : IRequestHandler<GetTransactionsQuery, Result<PagedResult<TransactionDto>>>
{
    public async Task<Result<PagedResult<TransactionDto>>> Handle(GetTransactionsQuery request, CancellationToken cancellationToken)
    {
        var page = Math.Max(1, request.Page);
        var pageSize = Math.Clamp(request.PageSize, 1, 100);

        var (transactions, totalCount) = await unitOfWork.Transactions.GetPagedAsync(
            request.TenantId, page, pageSize, request.SearchTerm, cancellationToken);
        var now = DateTime.UtcNow;

        var dtos = new List<TransactionDto>();
        foreach (var transaction in transactions)
            dtos.Add(await TransactionMapper.ToDtoAsync(transaction, unitOfWork.Assets, request.TenantId, now, cancellationToken));

        return Result.Ok(PagedResult<TransactionDto>.Create(dtos, page, pageSize, totalCount));
    }
}
