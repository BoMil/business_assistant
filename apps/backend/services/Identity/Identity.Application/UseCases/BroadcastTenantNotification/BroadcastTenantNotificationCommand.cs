using FluentResults;
using Shared.Application.RequestTypes;
using Shared.Queues.Enums;

namespace Identity.Application.UseCases.BroadcastTenantNotification;

public record BroadcastTenantNotificationCommand(
    Guid TenantId, Guid ExcludeUserId, string Title, string Body,
    PushEntityType EntityType, PushAction Action, Guid EntityId) : ICommand<Result>;
