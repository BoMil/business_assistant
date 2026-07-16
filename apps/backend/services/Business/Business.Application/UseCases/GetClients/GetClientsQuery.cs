using Business.Application.UseCases.Common;
using FluentResults;
using Shared.Application.RequestTypes;

namespace Business.Application.UseCases.GetClients;

public record GetClientsQuery(Guid TenantId) : IQuery<Result<List<ClientDto>>>;
