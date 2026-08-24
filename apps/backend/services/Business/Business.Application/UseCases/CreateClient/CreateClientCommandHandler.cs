using Business.Application.Repositories;
using Business.Domain.Entities;
using Business.Domain.ValueObjects;
using FluentResults;
using MassTransit;
using MediatR;
using Microsoft.Extensions.Logging;
using Shared.Queues.Enums;
using Shared.Queues.IntegrationEvents;

namespace Business.Application.UseCases.CreateClient;

internal sealed class CreateClientCommandHandler(
    IUnitOfWorkBusiness unitOfWork, IPublishEndpoint publishEndpoint, ILogger<CreateClientCommandHandler> logger)
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

        try
        {
            await publishEndpoint.Publish(
                new TenantNotificationRequested(
                    request.TenantId, request.UserId, "Нови клијент је додат", client.Name,
                    PushEntityType.Client, PushAction.Created, client.Id),
                cancellationToken);
        }
        catch (Exception ex)
        {
            // Broker being unreachable must not fail the create — the notification is a
            // side effect, not part of this operation's success criteria.
            logger.LogWarning(ex, "Failed to publish TenantNotificationRequested for created client {ClientId}", client.Id);
        }

        return Result.Ok(client.Id);
    }
}
