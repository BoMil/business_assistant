using FluentResults;
using Shared.Application.RequestTypes;

namespace Business.Application.UseCases.DeleteTransaction;

public record DeleteTransactionCommand(Guid Id, Guid TenantId, Guid UserId) : ICommand<Result>;
