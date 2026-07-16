using Business.Application.Repositories;
using Business.Application.UseCases.Common;
using FluentResults;
using MediatR;

namespace Business.Application.UseCases.GetClients;

internal sealed class GetClientsQueryHandler(IUnitOfWorkBusiness unitOfWork) : IRequestHandler<GetClientsQuery, Result<List<ClientDto>>>
{
    public async Task<Result<List<ClientDto>>> Handle(GetClientsQuery request, CancellationToken cancellationToken)
    {
        var clients = await unitOfWork.Clients.GetAllAsync(request.TenantId, cancellationToken);

        var dtos = clients
            .Select(c => new ClientDto(c.Id, c.Name, c.PhoneNumber, c.Email, c.Location?.Address, c.Location?.Latitude, c.Location?.Longitude, c.Description))
            .ToList();

        return Result.Ok(dtos);
    }
}
