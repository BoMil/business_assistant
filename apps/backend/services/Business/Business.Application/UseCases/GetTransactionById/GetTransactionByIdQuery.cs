using Business.Application.UseCases.Common;
using FluentResults;
using Shared.Application.RequestTypes;

namespace Business.Application.UseCases.GetTransactionById;

public record GetTransactionByIdQuery(Guid Id, Guid TenantId) : IQuery<Result<TransactionDto>>;
