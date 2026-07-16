using Business.Application.UseCases.Common;
using FluentResults;
using Shared.Application.RequestTypes;

namespace Business.Application.UseCases.GetClientTransactions;

public record GetClientTransactionsQuery(Guid ClientId, Guid TenantId) : IQuery<Result<List<TransactionDto>>>;
