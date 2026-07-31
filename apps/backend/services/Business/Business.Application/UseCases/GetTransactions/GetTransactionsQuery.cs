using Business.Application.UseCases.Common;
using FluentResults;
using Shared.Application.RequestTypes;

namespace Business.Application.UseCases.GetTransactions;

public record GetTransactionsQuery(Guid TenantId, int Page, int PageSize, string? SearchTerm)
    : IQuery<Result<PagedResult<TransactionDto>>>;
