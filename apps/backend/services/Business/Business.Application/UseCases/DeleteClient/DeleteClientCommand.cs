using FluentResults;
using Shared.Application.RequestTypes;

namespace Business.Application.UseCases.DeleteClient;

public record DeleteClientCommand(Guid Id, Guid TenantId) : ICommand<Result>;
