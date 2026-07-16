using Business.Application.Repositories;
using Business.Application.UseCases.Common;
using Shared.Domain.Errors;
using FluentResults;
using MediatR;

namespace Business.Application.UseCases.GetClientById;

internal sealed class GetClientByIdQueryHandler(IUnitOfWorkBusiness unitOfWork) : IRequestHandler<GetClientByIdQuery, Result<ClientDto>>
{
    public async Task<Result<ClientDto>> Handle(GetClientByIdQuery request, CancellationToken cancellationToken)
    {
        var client = await unitOfWork.Clients.GetByIdAsync(request.Id, request.TenantId, cancellationToken);
        if (client is null)
            return Result.Fail(new NotFoundError($"Client '{request.Id}' not found."));

        return Result.Ok(new ClientDto(client.Id, client.Name, client.PhoneNumber, client.Email, client.Location?.Address, client.Location?.Latitude, client.Location?.Longitude, client.Description));
    }
}
