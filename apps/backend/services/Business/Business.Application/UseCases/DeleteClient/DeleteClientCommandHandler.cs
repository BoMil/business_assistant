using Business.Application.Repositories;
using Shared.Domain.Errors;
using FluentResults;
using MediatR;

namespace Business.Application.UseCases.DeleteClient;

internal sealed class DeleteClientCommandHandler(IUnitOfWorkBusiness unitOfWork)
    : IRequestHandler<DeleteClientCommand, Result>
{
    public async Task<Result> Handle(DeleteClientCommand request, CancellationToken cancellationToken)
    {
        var client = await unitOfWork.Clients.GetByIdAsync(request.Id, request.TenantId, cancellationToken);
        if (client is null)
            return Result.Fail(new NotFoundError($"Client '{request.Id}' not found."));

        unitOfWork.Clients.Remove(client);
        await unitOfWork.SaveChangesAsync(cancellationToken);

        return Result.Ok();
    }
}
