using Business.Application.UseCases.Common;
using FluentResults;
using Shared.Application.RequestTypes;

namespace Business.Application.UseCases.GetClientById;

public record GetClientByIdQuery(Guid Id, Guid TenantId) : IQuery<Result<ClientDto>>;
