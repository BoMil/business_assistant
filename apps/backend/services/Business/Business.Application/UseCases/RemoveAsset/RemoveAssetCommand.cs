using FluentResults;
using Shared.Application.RequestTypes;

namespace Business.Application.UseCases.RemoveAsset;

public record RemoveAssetCommand(Guid Id, Guid TenantId) : ICommand<Result>;
