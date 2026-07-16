using Business.Application.UseCases.Common;
using FluentResults;
using Shared.Application.RequestTypes;

namespace Business.Application.UseCases.GetAssetById;

public record GetAssetByIdQuery(Guid Id, Guid TenantId) : IQuery<Result<AssetDetailDto>>;
