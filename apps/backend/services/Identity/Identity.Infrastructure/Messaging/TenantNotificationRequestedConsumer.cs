using Identity.Application.UseCases.BroadcastTenantNotification;
using MassTransit;
using MediatR;
using Shared.Queues.IntegrationEvents;

namespace Identity.Infrastructure.Messaging;

/// <summary>
/// Bridges the bus to the CQRS pipeline — Business (or any future publisher) never calls
/// Identity directly, it only publishes TenantNotificationRequested onto the bus.
/// </summary>
internal sealed class TenantNotificationRequestedConsumer(ISender sender) : IConsumer<TenantNotificationRequested>
{
    public Task Consume(ConsumeContext<TenantNotificationRequested> context) =>
        sender.Send(
            new BroadcastTenantNotificationCommand(
                context.Message.TenantId, context.Message.ExcludeUserId, context.Message.Title, context.Message.Body,
                context.Message.EntityType, context.Message.Action, context.Message.EntityId),
            context.CancellationToken);
}
