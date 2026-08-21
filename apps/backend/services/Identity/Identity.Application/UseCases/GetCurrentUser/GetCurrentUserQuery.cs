using Identity.Application.UseCases.Common;
using FluentResults;
using Shared.Application.RequestTypes;

namespace Identity.Application.UseCases.GetCurrentUser;

public record GetCurrentUserQuery(Guid UserId) : IQuery<Result<UserDto>>;
