using Business.Application.Repositories;
using Business.Application.UseCases.Common;
using Shared.Domain.Errors;
using FluentResults;
using MediatR;

namespace Business.Application.UseCases.GetTransactionById;

internal sealed class GetTransactionByIdQueryHandler(IUnitOfWorkBusiness unitOfWork)
    : IRequestHandler<GetTransactionByIdQuery, Result<TransactionDto>>
{
    public async Task<Result<TransactionDto>> Handle(GetTransactionByIdQuery request, CancellationToken cancellationToken)
    {
        var transaction = await unitOfWork.Transactions.GetByIdAsync(request.Id, request.TenantId, cancellationToken);
        if (transaction is null)
            return Result.Fail(new NotFoundError($"Transaction '{request.Id}' not found."));

        var dto = await TransactionMapper.ToDtoAsync(transaction, unitOfWork.Assets, request.TenantId, DateTime.UtcNow, cancellationToken);
        return Result.Ok(dto);
    }
}
