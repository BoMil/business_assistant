using Business.Application.Repositories;
using Shared.Domain.Errors;
using Business.Domain.ValueObjects;
using FluentResults;
using MediatR;

namespace Business.Application.UseCases.UpdateClient;

internal sealed class UpdateClientCommandHandler(IUnitOfWorkBusiness unitOfWork)
    : IRequestHandler<UpdateClientCommand, Result>
{
    public async Task<Result> Handle(UpdateClientCommand request, CancellationToken cancellationToken)
    {
        var client = await unitOfWork.Clients.GetByIdAsync(request.Id, request.TenantId, cancellationToken);
        if (client is null)
            return Result.Fail(new NotFoundError($"Client '{request.Id}' not found."));

        var location = request.LocationAddress is null || request.LocationLatitude is null || request.LocationLongitude is null
            ? null
            : Location.Create(request.LocationAddress, request.LocationLatitude.Value, request.LocationLongitude.Value);

        client.Update(request.Name, request.PhoneNumber, request.Email, location, request.Description);
        await unitOfWork.SaveChangesAsync(cancellationToken);

        return Result.Ok();
    }
}
