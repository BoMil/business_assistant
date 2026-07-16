using Business.Application.Repositories;
using Shared.Domain.Errors;
using FluentResults;
using MediatR;

namespace Business.Application.UseCases.CancelTransaction;

internal sealed class CancelTransactionCommandHandler(IUnitOfWorkBusiness unitOfWork)
    : IRequestHandler<CancelTransactionCommand, Result>
{
    public async Task<Result> Handle(CancelTransactionCommand request, CancellationToken cancellationToken)
    {
        var transaction = await unitOfWork.Transactions.GetByIdAsync(request.Id, request.TenantId, cancellationToken);
        if (transaction is null)
            return Result.Fail(new NotFoundError($"Transaction '{request.Id}' not found."));

        transaction.Cancel();
        await unitOfWork.SaveChangesAsync(cancellationToken);

        return Result.Ok();
    }
}
