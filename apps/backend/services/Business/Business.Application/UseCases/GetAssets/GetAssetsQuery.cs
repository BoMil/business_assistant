using Business.Application.UseCases.Common;
using FluentResults;
using Shared.Application.RequestTypes;

namespace Business.Application.UseCases.GetAssets;

public record GetAssetsQuery(Guid TenantId) : IQuery<Result<List<AssetDto>>>;
