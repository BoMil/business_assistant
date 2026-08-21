using FluentResults;
using Shared.Application.RequestTypes;

namespace Identity.Application.UseCases.UpdateUserImage;

public record UpdateUserImageCommand(Guid UserId, string? ImgUrl) : ICommand<Result>;
