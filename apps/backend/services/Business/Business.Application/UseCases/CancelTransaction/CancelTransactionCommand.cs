using FluentResults;
using Shared.Application.RequestTypes;

namespace Business.Application.UseCases.CancelTransaction;

public record CancelTransactionCommand(Guid Id, Guid TenantId) : ICommand<Result>;
