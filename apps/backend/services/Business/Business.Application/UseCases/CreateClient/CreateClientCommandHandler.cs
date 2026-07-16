using Business.Application.Repositories;
using Business.Domain.Entities;
using Business.Domain.ValueObjects;
using FluentResults;
using MediatR;

namespace Business.Application.UseCases.CreateClient;

internal sealed class CreateClientCommandHandler(IUnitOfWorkBusiness unitOfWork)
    : IRequestHandler<CreateClientCommand, Result<Guid>>
{
    public async Task<Result<Guid>> Handle(CreateClientCommand request, CancellationToken cancellationToken)
    {
        var location = request.LocationAddress is null || request.LocationLatitude is null || request.LocationLongitude is null
            ? null
            : Location.Create(request.LocationAddress, request.LocationLatitude.Value, request.LocationLongitude.Value);

        var client = Client.Create(request.TenantId, request.Name, request.PhoneNumber, request.Email, location, request.Description);

        await unitOfWork.Clients.AddAsync(client, cancellationToken);
        await unitOfWork.SaveChangesAsync(cancellationToken);

        return Result.Ok(client.Id);
    }
}
