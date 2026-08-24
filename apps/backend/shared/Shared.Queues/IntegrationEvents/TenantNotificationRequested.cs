using Shared.Queues.Enums;

namespace Shared.Queues.IntegrationEvents;

/// <summary>
/// Published by any service when a tenant-scoped entity changes and every other user
/// of that tenant should be pushed a notification, regardless of their login state.
/// Consumed by Identity (the only service that owns DeviceTokens/FirebaseConfig) — the
/// publisher never needs to know Identity exists, only that this event goes on the bus.
/// EntityType/Action/EntityId let a future mobile tap-handler route to the right screen.
/// </summary>
public record TenantNotificationRequested(
    Guid TenantId, Guid ExcludeUserId, string Title, string Body,
    PushEntityType EntityType, PushAction Action, Guid EntityId);
